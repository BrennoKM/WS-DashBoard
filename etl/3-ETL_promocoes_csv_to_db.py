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

df = pd.read_csv('csvs/Warspear - Histórico promoções  - Promoções.csv', skiprows=1)
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
    if pd.isna(row["Quantidade"]) and pd.isna(row["Valor com Desconto"]):
        break
    # if pd.isnull(row['Item']) and pd.isnull(row['Quantidade']) and pd.isnull(row['Valor com Desconto']):
    #     break
    if row['Item'] != '':
        data_formatada = datetime.strptime(row['Data'], '%d/%m/%Y').strftime('%Y-%m-%d')

        cursor.execute("INSERT IGNORE INTO dim_tempo (data) VALUES (%s)", (data_formatada,))
        cursor.execute("SELECT id_tempo FROM dim_tempo WHERE data = %s", (data_formatada,))
        id_tempo = cursor.fetchall()
        if id_tempo:
            id_tempo = id_tempo[0][0]
        else:
            print(f"Data não encontrada: {data_formatada}")
            continue

        nome_item = row['Item']

        nome_abreviacao = row['Abreviação']
        
        cursor.execute("INSERT IGNORE INTO dim_item (nome_item, nome_abreviacao) VALUES (%s, %s)", (nome_item, nome_abreviacao))
        cursor.execute("SELECT id_item FROM dim_item WHERE nome_item = %s", (nome_item,))
        id_item = cursor.fetchall()
        if id_item:
            id_item = id_item[0][0]
        else:
            print(f"Item não encontrado: {nome_item}")

        evento = row['Evento']

        cursor.execute("INSERT IGNORE INTO dim_evento (nome_evento) VALUES (%s)", (evento,))
        cursor.execute("SELECT id_evento FROM dim_evento WHERE nome_evento = %s", (evento,))
        id_evento = cursor.fetchall()
        if id_evento:
            id_evento = id_evento[0][0]
        else:
            print(f"Evento não encontrado: {evento}")


        valor_coin = row['Valor com Desconto']
        if pd.isna(row["Valor Original"]) or row['Valor Original'] == '':
            valor_coin_original = row['Valor com Desconto'] * 2
        else:
            valor_coin_original = row['Valor Original']

        quantidade = row['Quantidade']

        # print(f"Data: {data_formatada}, Item: {nome_item}, Evento: {evento}, Quantidade: {quantidade}, Valor Coin: {valor_coin}, Valor Coin Original: {valor_coin_original}")
        cursor.execute(
            "INSERT IGNORE INTO fato_promocao (id_tempo, id_item, id_evento, quantidade, valor_coin, valor_coin_original) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (id_tempo, id_item, id_evento, quantidade, valor_coin, valor_coin_original)
        )

        # time.sleep(0.5)

print("Inserção de dados finalizada.")
conexao.commit()
cursor.close()
conexao.close()