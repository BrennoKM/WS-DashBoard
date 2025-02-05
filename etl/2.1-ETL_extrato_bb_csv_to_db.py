import time
import mysql.connector
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
import os
import re

load_dotenv()

host = os.getenv('DB_HOST')
user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
database = os.getenv('DB_NAME')

# 115,45 x (valor em reais) = coins vendidos
constante_coins = 115.45
# 1 coin = 96 gold


df = pd.read_csv('csvs/Extrato conta corrente - 052025.csv')
# df_2 = pd.read_csv('csvs/Extrato conta corrente - 042025.csv')
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

df.rename(columns={
    'Data': 'Data Lançamento',
    'Valor': 'Valor',
    'Lançamento': 'Histórico'
}, inplace=True)

def separar_detalhes(row):
    detalhes = row['Detalhes']
    if pd.isnull(detalhes):
        return pd.Series([None, None, None, None])
    
    # Expressão regular para extrair data, hora, CPF/CNPJ (se presente) e nome
    match = re.search(r'(\d{2}/\d{2})?\s*(\d{2}:\d{2})?\s*(\d+)?\s*(.+)', detalhes)
    if match:
        data = match.group(1) if match.group(1) else ''
        hora = match.group(2) if match.group(2) else ''
        cpf = match.group(3) if match.group(3) else ''
        nome = match.group(4) if match.group(4) else ''
    else:
        data, hora, cpf, nome = '', '', '', detalhes
    
    return pd.Series([data, hora, cpf, nome.strip()])

df[['Data Detalhes', 'Hora', 'CPF', 'Descrição']] = df.apply(separar_detalhes, axis=1)

def substituir_data(row):
    if row['Data Detalhes'] and row['Data Detalhes'] != row['Data Lançamento'][:5]:
        ano = row['Data Lançamento'][-4:]
        nova_data = f"{row['Data Detalhes']}/{ano}"
        return nova_data
    return row['Data Lançamento']

df['Data Lançamento'] = df.apply(substituir_data, axis=1)

df = df.fillna({
    'Hora': '',
    'CPF': '',
    'Descrição': '',
    'Valor': 0.0
})

df['CPF'] = df['CPF'].apply(lambda x: str(x).zfill(14) if pd.notnull(x) else x)

df['Valor'] = df['Valor'].apply(lambda x: float(str(x).replace('.', '').replace(',', '.')) if x != '' else 0.0)

# df['Valor'] = df['Valor'].apply(lambda x: f"{x:,.2f}".replace(",", "X").replace(".", ",").replace("X", ","))

df['Descrição'] = df['Descrição'].apply(lambda x: ' '.join([word.capitalize() for word in x.split()])[:10] if isinstance(x, str) else x)

#df.to_csv('Extrato conta corrente - 022025_corrected.csv', index=False)

for index, row in df.iterrows():
    if pd.isna(row["Data Lançamento"]) and pd.isna(row["Histórico"]) and pd.isna(row["Descrição"]):
        break
    if pd.isnull(row['Descrição']):
        row['Descrição'] = ""

    if row['Histórico'] == "Pix - Recebido":
        row['Histórico'] = "Pix recebido"

    if row['Histórico'] == "Pix-Recebido QR Code":
        row['Histórico'] = "Pix recebido"

    if row['Histórico'] == "Pix - Rejeitado":
        row['Histórico'] = "Pix recebido"

    if row['Histórico'] == "Pix-Envio devolvido":
        row['Histórico'] = "Pix recebido"

    if row['Histórico'] == "Transferência recebida":
        row['Histórico'] = "Pix recebido"

    if row['Histórico'] == "Pix - Enviado":
        row['Histórico'] = "Pix enviado"

    if "Brenno Ke" in row['Descrição']:
        row['Descrição'] = "Brenno Kevyn Maia de Souza"

    if row['Valor'] != '' and row['Histórico'] != 'Saldo Anterior' and row['Histórico'] != 'Saldo do dia' and row['Histórico'] != 'S A L D O':
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

        #print("Indo inserir o cliente: ", row['Descrição'], "Linha: ", index)

        if row['CPF'] != '00000000000000':
            cursor.execute("SELECT id_cliente, nome_cliente FROM dim_cliente WHERE cpf = %s LIMIT 1", (row['CPF'],))
            cliente = cursor.fetchone()
        else:
            cursor.execute("SELECT id_cliente, cpf FROM dim_cliente WHERE nome_cliente = %s LIMIT 1", (row['Descrição'],))
            cliente = cursor.fetchone()

        if cliente:
            id_cliente, nome_existente = cliente
            if row['CPF'] != '00000000000000':
                # Atualizar o CPF se estiver ausente no banco de dados
                cursor.execute("UPDATE IGNORE dim_cliente SET cpf = %s WHERE id_cliente = %s", (row['CPF'], id_cliente))
            if nome_existente != row['Descrição']:
                # Atualizar o nome se estiver abreviado no banco de dados
                cursor.execute("UPDATE IGNORE dim_cliente SET nome_cliente = %s WHERE id_cliente = %s", (row['Descrição'], id_cliente))
        else:
            # Inserir cliente com nome e CPF (se disponível)
            if row['CPF'] != '00000000000000':
                cursor.execute("INSERT IGNORE INTO dim_cliente (nome_cliente, cpf) VALUES (%s, %s)", (row['Descrição'], row['CPF']))
            else:
                cursor.execute("INSERT IGNORE INTO dim_cliente (nome_cliente) VALUES (%s)", (row['Descrição'],))
            # Selecionar cliente com base no nome após inserção
            cursor.execute("SELECT id_cliente FROM dim_cliente WHERE nome_cliente = %s LIMIT 1", (row['Descrição'],))
            cliente = cursor.fetchone()
            if cliente:
                id_cliente = cliente[0]
            else:
                print(f"Erro ao inserir ou selecionar o cliente: {row['Descrição']}")
                continue
        
        if row['Hora']:
            cursor.execute("INSERT IGNORE INTO dim_hora (hora) VALUES (%s)", (row['Hora'],))
            cursor.execute("SELECT id_hora FROM dim_hora WHERE hora = %s", (row['Hora'],))
            id_hora = cursor.fetchone()
            if id_hora:
                id_hora = id_hora[0]
            else:
                print(f"Erro ao inserir ou selecionar a hora: {row['Hora']}")
                continue
        else:
            id_hora = None
            
        n_documento = row['N° documento']
        try:
            n_documento = str(int(n_documento))
        except ValueError:
            print(f"Valor inválido para N° documento: {n_documento}")
            continue
        
        valor_final = row['Valor']
        # valor_final = str(row['Valor']).replace('.','').replace(',', '.').strip()
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
            "INSERT IGNORE INTO fato_transacao (id_tempo, id_hora, id_cliente, id_movimentacao, n_documento, valor, coins, pontos) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
            (id_tempo, id_hora, id_cliente, id_movimentacao, n_documento, valor_final, coins, pontos)
        )

        # time.sleep(0.5)
        
print("Inserção de dados finalizada.")
conexao.commit()
cursor.close()
conexao.close()