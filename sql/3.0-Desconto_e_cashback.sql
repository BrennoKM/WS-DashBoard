SELECT 
    c.nome_cliente AS Cliente,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'investimento' THEN t.desconto 
        ELSE 0 END), 2) AS Total_Desconto_Investimento,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'cashback' THEN t.valor 
        ELSE 0 END), 2) AS Total_Cashback_Creditado,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'investimento' THEN t.pontos  -- Supondo que 'pontos' seja a coluna para pontos obtidos
        ELSE 0 END), 2) AS Total_Pontos_Obtidos
FROM 
    fato_transacao t
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
WHERE 
    m.tipo_movimentacao IN ('investimento', 'cashback')
GROUP BY 
    c.nome_cliente
ORDER BY 
    Total_Cashback_Creditado DESC;
