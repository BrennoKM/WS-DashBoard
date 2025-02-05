SELECT 
    DATE_FORMAT(dt.data, '%Y-%m') AS Mes,  
    MAX(c.nome_cliente) AS Cliente,    
    MAX(m.tipo_movimentacao) AS Tipo_Movimentacao,  
    ROUND(SUM(t.valor),2) AS Valor,             
    ROUND(SUM(t.coins),2) AS Coins             
FROM 
    fato_transacao t
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo dt ON t.id_tempo = dt.id_tempo
WHERE 
    c.nome_cliente = 'Rossine Silveira Da Silva'
GROUP BY 
    DATE_FORMAT(dt.data, '%Y-%m')  -- Agrupando por mês (formato 'YYYY-MM')
ORDER BY 
    Mes DESC;  -- Ordenando pelo mês mais recente
