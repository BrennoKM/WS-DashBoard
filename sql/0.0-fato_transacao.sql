SELECT 
    t.id_transacao AS ID_Transacao,
    t.valor AS Valor_Transacao,
    t.desconto AS Desconto,
    t.coins AS Coins,
    t.pontos AS Pontos,
    m.tipo_movimentacao AS Tipo_Movimentacao,
    c.nome_cliente AS Cliente,
    ti.data AS Data_Transacao
FROM 
    fato_transacao t
LEFT JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
LEFT JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
ORDER BY 
    ti.data DESC;
