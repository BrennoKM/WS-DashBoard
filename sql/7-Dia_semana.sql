SELECT 
    CASE DAYOFWEEK(ti.data)
        WHEN 1 THEN 'Domingo'
        WHEN 2 THEN 'Segunda-feira'
        WHEN 3 THEN 'Terça-feira'
        WHEN 4 THEN 'Quarta-feira'
        WHEN 5 THEN 'Quinta-feira'
        WHEN 6 THEN 'Sexta-feira'
        WHEN 7 THEN 'Sábado'
    END AS Dia_Semana,  -- Traduzindo para português
    ROUND(SUM(t.valor), 2) AS Total_Vendas
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
WHERE 
    m.tipo_movimentacao = 'pix recebido'  -- Considerando vendas como transações de "Pix recebido"
    AND (MONTH(ti.data) = IFNULL(null, MONTH(ti.data)))  -- Se o mês for informado, filtra pelo mês; senão, ignora
    AND (YEAR(ti.data) = IFNULL(null, YEAR(ti.data)))    -- Se o ano for informado, filtra pelo ano; senão, ignora
GROUP BY 
    Dia_Semana
ORDER BY 
    Total_Vendas DESC
LIMIT 7;
