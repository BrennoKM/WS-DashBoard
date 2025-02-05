SELECT 
    ti.data AS Dia_Especifico,
    CASE DAYOFWEEK(ti.data)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Segunda-feira'
        WHEN 3 THEN 'Terça-feira'
        WHEN 4 THEN 'Quarta-feira'
        WHEN 5 THEN 'Quinta-feira'
        WHEN 6 THEN 'Sexta-feira'
        WHEN 7 THEN 'Sábado'
    END AS Dia_Semana, 
    ROUND(SUM(t.valor), 2) AS Total_Vendas,
    COUNT(t.id_transacao) AS Numero_Transacoes,
    ROUND(SUM(t.valor) / COUNT(t.id_transacao), 2) AS Media_Valor_Transacao,
    IFNULL(di.nome_item, 'Nenhum item em promoção') AS Item_Em_Promocao,
    IFNULL(fp.valor_coin, 0) AS Valor_Coin
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
LEFT JOIN 
    fato_promocao fp ON ti.id_tempo = fp.id_tempo
LEFT JOIN 
    dim_item di ON fp.id_item = di.id_item
WHERE 
    m.tipo_movimentacao = 'pix recebido'  -- Considerando vendas como transações de "Pix recebido"
GROUP BY 
    ti.data
ORDER BY 
    Total_Vendas DESC
