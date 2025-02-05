SELECT 
    DATE_FORMAT(ti.data, '%Y-%m') AS Mes,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'investimento' THEN t.coins
        ELSE 0 END), 2) AS Coins_Total_Investido,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'pix recebido' THEN -t.coins  -- Subtração das moedas vendidas
        WHEN m.tipo_movimentacao = 'pix enviado' THEN -t.coins  -- Soma das moedas enviadas (compra)
        ELSE 0 END), 2) AS Coins_Total_Vendido,
	ROUND(SUM(CASE 
		WHEN m.tipo_movimentacao = 'investimento' THEN t.coins
        ELSE 0 END) - SUM(CASE 
			WHEN m.tipo_movimentacao = 'pix recebido' THEN -t.coins  -- Subtração das moedas vendidas
			WHEN m.tipo_movimentacao = 'pix enviado' THEN -t.coins  -- Soma das moedas enviadas (compra)
        ELSE 0 END), 2) AS Coins_Restantes
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
WHERE 
    m.tipo_movimentacao IN ('investimento', 'pix recebido', 'pix enviado')
GROUP BY 
    Mes
ORDER BY 
    Mes DESC;
