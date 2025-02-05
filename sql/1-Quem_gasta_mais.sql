SELECT 
    c.nome_cliente AS Cliente,
    ROUND(SUM(CASE WHEN m.tipo_movimentacao = 'Pix recebido' THEN t.valor ELSE 0 END), 2) AS Total_Recebido,
    ROUND(SUM(CASE WHEN m.tipo_movimentacao = 'Pix enviado' THEN t.valor ELSE 0 END), 2) AS Total_Enviado,
    COUNT(t.id_transacao) AS Total_Transacoes, -- Contabiliza o número total de transações
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao IN ('Pix recebido', 'Pix enviado') THEN t.valor 
        ELSE 0 
    END) / COUNT(t.id_transacao), 2) AS Media_Valor_Transacao, -- Calcula a média por transação
    ROUND(SUM(CASE 
        WHEN m.tipo_movimentacao = 'Pix recebido' THEN t.valor
        ELSE t.valor -- Pix enviado já é negativo
    END), 2) AS Diferença
FROM 
    fato_transacao t
JOIN 
    dim_cliente c ON t.id_cliente = c.id_cliente
JOIN 
    dim_movimentacao m ON t.id_movimentacao = m.id_movimentacao
JOIN 
    dim_tempo ti ON t.id_tempo = ti.id_tempo
WHERE 
    m.tipo_movimentacao IN ('Pix recebido', 'Pix enviado') -- Filtra as movimentações de Pix
	AND NOT c.nome_cliente IN ('Reentrada')
    -- AND c.nome_cliente IN ('Matheus Henrique De Souza Pinheiro')
    AND (MONTH(ti.data) = IFNULL(3, MONTH(ti.data)))  -- Se o mês for informado, filtra pelo mês; senão, ignora
    AND (YEAR(ti.data) = IFNULL(2025, YEAR(ti.data)))    -- Se o ano for informado, filtra pelo ano; senão, ignora
GROUP BY 
    c.nome_cliente
ORDER BY 
    Diferença DESC;
