import pandas as pd
import mysql.connector
import os
import re
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

host = os.getenv('DB_HOST')
user = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
database = os.getenv('DB_NAME')

constante_coins = 115.45

df = pd.read_csv('csvs/Extrato conta corrente - 022025.csv')
print("CSV carregado com sucesso:")
print(df.head())

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

df['Valor'] = df['Valor'].apply(lambda x: float(str(x).replace('.', '').replace(',', '.')) if x != '' else 0.0)

df['Valor'] = df['Valor'].apply(lambda x: f"{x:,.2f}".replace(",", "X").replace(".", ",").replace("X", ","))

df['Descrição'] = df['Descrição'].apply(lambda x: ' '.join([word.capitalize() for word in x.split()]) if isinstance(x, str) else x)

df.to_csv('Extrato conta corrente - 022025_corrected.csv', index=False, encoding='utf-8')

print("CSV corrigido e salvo com sucesso.")

