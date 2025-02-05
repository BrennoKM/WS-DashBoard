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
    2) AS Saldo_fim_do_dia,
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
    2) AS Lucro,
    IFNULL(di.nome_item, 'Nenhum item em promoção') AS Item_Em_Promocao
FROM 
    fato_transacao t
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
LEFT JOIN 
    fato_promocao fp ON ti.id_tempo = fp.id_tempo
LEFT JOIN 
    dim_item di ON fp.id_item = di.id_item
WHERE 
    m.tipo_movimentacao IN ('pix recebido', 'pix enviado', 'cashback', 'pagamento efetuado', 'investimento')
    AND NOT (m.tipo_movimentacao = 'pix recebido' AND c.nome_cliente = 'Reentrada')
GROUP BY 
    ti.data, Dia_Semana, di.nome_item
ORDER BY
	ti.data Desc
