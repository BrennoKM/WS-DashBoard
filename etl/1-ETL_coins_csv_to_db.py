import time
import mysql.connector
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
import os

load_dotenv()

host = os.getenv('DB_HOST')
user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
database = os.getenv('DB_NAME')

df = pd.read_csv('csvs/Warspear - Coins - Moedas milagrosas.csv', skiprows=1)
print("CSV carregado com sucesso:")
print(df.head())


try:
    conexao = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database
    )
    print("Conexão com o banco de dados estabelecida com sucesso.")
except mysql.connector.Error as err:
    print(f"Erro ao conectar ao banco de dados: {err}")
    exit(1)

cursor = conexao.cursor()



for index, row in df.iterrows():
    if pd.isna(row["Data"]) and pd.isna(row["Conta"]) and pd.isna(row["Pontos"]):
        break
    # if pd.isnull(row['Data']) and pd.isnull(row['Conta']) and pd.isnull(row['Pontos']):
    #     break
    if row['Conta'] != '':
        data_formatada = datetime.strptime(row['Data'], '%d/%m/%Y').strftime('%Y-%m-%d')

        cursor.execute("INSERT IGNORE INTO dim_tempo (data) VALUES (%s)", (data_formatada,))
        cursor.execute("SELECT id_tempo FROM dim_tempo WHERE data = %s", (data_formatada,))
        id_tempo = cursor.fetchall()
        if id_tempo:
            id_tempo = id_tempo[0][0]
        else:
            print(f"Data não encontrada: {data_formatada}")
            continue
        
        cursor.execute("INSERT IGNORE INTO dim_movimentacao (tipo_movimentacao) VALUES (%s)", ("investimento",))
        cursor.execute("SELECT id_movimentacao FROM dim_movimentacao WHERE tipo_movimentacao = 'investimento' LIMIT 1")
        id_movimentacao = cursor.fetchall()
        if id_movimentacao:
            id_movimentacao = id_movimentacao[0][0]
        else:
            print("Movimentação não encontrada: tipo_movimentacao = 'investimento'")
            continue

        cursor.execute("INSERT IGNORE INTO dim_cliente (nome_cliente) VALUES (%s)", (row['Conta'],))
        cursor.execute("SELECT id_cliente FROM dim_cliente WHERE nome_cliente = %s LIMIT 1", (row['Conta'],))
        id_cliente = cursor.fetchall()
        if id_cliente:
            id_cliente = id_cliente[0][0]
        else:
            print(f"Cliente não encontrado: {row['Conta']}")
            continue

        valor_final = row['Valor final'].replace(',', '.')
        try:
            valor_final = float(valor_final)
        except ValueError:
            print(f"Valor inválido: {row['Valor final']}")
            continue

        coins = row['Moedas Milagrosas']
        try:
            coins = float(coins)
        except ValueError:
            print(f"Valor inválido para Moedas Milagrosas: {row['Moedas Milagrosas']}")
            continue

        pontos = row['Pontos']
        try:
            pontos = int(pontos)
        except ValueError:
            print(f"Valor inválido para Pontos: {row['Pontos']}")
            continue

        desconto = row['Desconto'].replace(',', '.')
        try:
            desconto = float(desconto)
        except ValueError:
            print(f"Valor inválido para Desconto: {row['Desconto']}")
            continue

        cursor.execute(
            "INSERT IGNORE INTO fato_transacao (id_tempo, id_cliente, id_movimentacao, id_recarga, valor, coins, desconto, pontos) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (id_tempo, id_cliente, id_movimentacao, row['ID'], valor_final, coins, desconto, pontos)
        )

        # time.sleep(0.5)

print("Inserção de dados finalizada.")
conexao.commit()
cursor.close()
conexao.close()