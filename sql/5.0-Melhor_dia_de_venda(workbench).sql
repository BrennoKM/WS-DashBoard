SELECT 
    DAY(ti.data) AS Dia_Do_Mes,
    ROUND(SUM(t.valor), 2) AS Total_Vendas,
    COUNT(t.id_transacao) AS Numero_Transacoes,
    ROUND(SUM(t.valor) / COUNT(t.id_transacao), 2) AS Media_Valor_Transacao
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
WHERE 
    m.tipo_movimentacao = 'pix recebido'  -- Considerando vendas como transações de "Pix recebido"
    AND c.nome_cliente NOT IN ('Reentrada')
    AND (MONTH(ti.data) = IFNULL(1, MONTH(ti.data)))  -- Se o mês for informado, filtra pelo mês; senão, ignora
    AND (YEAR(ti.data) = IFNULL(null, YEAR(ti.data)))    -- Se o ano for informado, filtra pelo ano; senão, ignora
GROUP BY 
    DAY(ti.data)
ORDER BY 
    Total_Vendas DESC;
