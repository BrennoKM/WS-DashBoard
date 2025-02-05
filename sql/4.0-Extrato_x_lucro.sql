SELECT 
    DATE_FORMAT(ti.data, '%Y-%m') AS Mes,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'investimento' THEN t.valor 
        ELSE 0 END), 2) AS Total_Investimento,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'pix recebido' THEN t.valor
        WHEN m.tipo_movimentacao = 'cashback' THEN t.valor
        ELSE 0 
    END), 2) AS Total_Recebido,
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'pix enviado' THEN -t.valor
        WHEN m.tipo_movimentacao = 'pagamento efetuado' THEN -t.valor
        ELSE 0 
    END), 2) AS Total_Enviado,
    ROUND(
        SUM(CASE 
            WHEN m.tipo_movimentacao = 'pix recebido' THEN t.valor
            WHEN m.tipo_movimentacao = 'cashback' THEN t.valor
            ELSE 0 
        END) - 
        SUM(CASE 
            WHEN m.tipo_movimentacao = 'pix enviado' THEN -t.valor
            WHEN m.tipo_movimentacao = 'pagamento efetuado' THEN -t.valor
            ELSE 0 
        END), 
    2) AS Saldo_fim_do_mês,
    ROUND(
        (SUM(CASE 
            WHEN m.tipo_movimentacao IN ('pix recebido', 'cashback') THEN t.valor
            WHEN m.tipo_movimentacao IN ('', 'pagamento efetuado') THEN -t.valor
            ELSE 0 
        END) + 
        SUM(CASE 
            WHEN m.tipo_movimentacao IN ('pix enviado', 'pagamento efetuado') THEN t.valor
            ELSE 0 
        END)) - 
        SUM(CASE 
            WHEN m.tipo_movimentacao = 'investimento' THEN t.valor 
            ELSE 0 
        END), 
    2) AS Lucro
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
WHERE 
    m.tipo_movimentacao IN ('pix recebido', 'pix enviado', 'cashback', 'pagamento efetuado', 'investimento')
	AND NOT (m.tipo_movimentacao = 'pix recebido' AND c.nome_cliente = 'Reentrada')
GROUP BY 
    DATE_FORMAT(ti.data, '%Y-%m')
ORDER BY 
    Mes DESC
LIMIT 100;
