SELECT 
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'investimento' THEN t.desconto 
        ELSE 0 END), 2) AS Total_Desconto_Investimento,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'cashback' THEN t.valor 
        ELSE 0 END), 2) AS Total_Cashback_Creditado,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'investimento' THEN t.pontos  -- Aqui você agrega os pontos
        ELSE 0 END), 2) AS Total_Pontos_Obtidos  -- Coluna para pontos obtidos
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
WHERE 
    m.tipo_movimentacao IN ('investimento', 'cashback');
