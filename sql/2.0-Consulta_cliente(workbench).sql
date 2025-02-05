SELECT 
    t.id_transacao AS Transacao,
    c.nome_cliente AS Cliente,
    m.tipo_movimentacao AS Tipo_Movimentacao,
    t.valor AS Valor,
    t.coins AS Coins,
    t.pontos AS Pontos,
    dt.data AS Data
FROM 
    fato_transacao t
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE 
    c.nome_cliente = 'Lucas Barbosa Da Silva'
ORDER BY 
    dt.data DESC; -- Ordenado por data, mais recente primeiro
