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

# 115,45 x (valor em reais) = coins vendidos
constante_coins = 115.45
# 1 coin = 96 gold

df = pd.read_csv('csvs/Extrato-04-09-2024-a-06-02-2025.csv', skiprows=5)
# df_2 = pd.read_csv('Extrato-26-01-2025-a-31-01-2025.csv', skiprows=5)
# df = pd.concat([df, df_2])
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
    if pd.isna(row["Data Lançamento"]) and pd.isna(row["Histórico"]) and pd.isna(row["Descrição"]):
        break
    if pd.isnull(row['Descrição']):
        row['Descrição'] = ""

    if row['Valor'] != '':
        if row['Histórico'] == "Pix enviado" and row["Descrição"].strip().lower() == "brenno kevyn maia de souza":
            row['Histórico'] = "Pagamento efetuado"
            row['Descrição'] = "Fatura cartão Nubank"
            # print("Alterando Histórico e Descrição para: ", row['Histórico'], row['Descrição'])
        

        if row['Histórico'] == "Pix recebido" and row["Descrição"].strip().lower() == "brenno kevyn maia de souza":
            row['Descrição'] = "Desconhecido"

        if row['Histórico'] == "Pix recebido" and (pd.isna(row["Descrição"]) or row["Descrição"].strip() == ""):
            row['Descrição'] = "Desconhecido"

        if row['Histórico'] == "Estorno":
            row['Histórico'] = "Pix recebido"

        if not pd.isna(row["Descrição"]) and row["Descrição"].startswith("Google Play"):
            row['Descrição'] = "Google Play"

        if not pd.isna(row["Descrição"]) and row["Descrição"].startswith("Razer Gold"):
            row['Descrição'] = "Razer Gold"

        data_formatada = datetime.strptime(row['Data Lançamento'], '%d/%m/%Y').strftime('%Y-%m-%d')

        cursor.execute("INSERT IGNORE INTO dim_tempo (data) VALUES (%s)", (data_formatada,))
        cursor.execute("SELECT id_tempo FROM dim_tempo WHERE data = %s", (data_formatada,))
        id_tempo = cursor.fetchall()
        if id_tempo:
            id_tempo = id_tempo[0][0]
        else:
            print(f"Data não encontrada: {data_formatada}")
            continue

        tipo_movimentacao = row['Histórico'].lower()

        cursor.execute("INSERT IGNORE INTO dim_movimentacao (tipo_movimentacao) VALUES (%s)", (tipo_movimentacao,))
        cursor.execute("SELECT id_movimentacao FROM dim_movimentacao WHERE tipo_movimentacao = %s", (tipo_movimentacao,))
        # cursor.execute(f"SELECT id_movimentacao FROM dim_movimentacao WHERE tipo_movimentacao = '{tipo_movimentacao}'")
        id_movimentacao = cursor.fetchall()
        if id_movimentacao:
            id_movimentacao = id_movimentacao[0][0]
        else:
            print(f"Movimentação não encontrada: tipo_movimentacao = {tipo_movimentacao}")
            continue

        # print("Indo inserir o cliente: ", row['Descrição'], "Linha: ", index)

        cursor.execute("INSERT IGNORE INTO dim_cliente (nome_cliente) VALUES (%s)", (row['Descrição'],))
        cursor.execute("SELECT id_cliente FROM dim_cliente WHERE nome_cliente = %s LIMIT 1", (row['Descrição'],))
        id_cliente = cursor.fetchall()
        if id_cliente:
            id_cliente = id_cliente[0][0]
        else:
            print(f"Cliente não encontrado: {row['Conta']}")
            continue

        
        valor_final = str(row['Valor']).replace('.', '').replace(',', '.').strip()
        try:
            valor_final = float(valor_final)
        except ValueError:
            print(f"Valor inválido: {row['Valor']}")
            continue

        coins = valor_final * constante_coins
        try:
            coins = float(coins)
        except ValueError:
            print(f"Valor inválido para Moedas Milagrosas: {coins}")
            continue
        
        if row['Histórico'] == "Pix recebido":
            coins = coins * -1 if coins > 0 else coins

        if row['Histórico'] == "Pix enviado":
            coins = coins * -1 if coins < 0 else coins

        if row['Histórico'] == "Pagamento efetuado" or row['Histórico'] == "Cashback":
            coins = 0

        pontos = 0
        try:
            pontos = int(pontos)
        except ValueError:
            print(f"Valor inválido para Pontos: {pontos}")
            continue

        cursor.execute(
            "INSERT IGNORE INTO fato_transacao (id_tempo, id_cliente, id_movimentacao, valor, coins, pontos) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (id_tempo, id_cliente, id_movimentacao, valor_final, coins, pontos)
        )

        # time.sleep(0.5)
        
print("Inserção de dados finalizada.")
conexao.commit()
cursor.close()
conexao.close()