SELECT 
    fp.id_promocao AS ID_Promocao,
    di.nome_item AS Nome_Item,
    di.nome_abreviacao AS Abreviacao,
    fp.quantidade AS Quantidade,
    fp.valor_coin AS Valor_Coin,
    fp.valor_coin_original AS Valor_Original,
    ti.data AS Data_Promocao,
    de.nome_evento AS Nome_Evento
FROM 
    fato_promocao fp
JOIN 
    dim_item di ON fp.id_item = di.id_item
JOIN 
    dim_tempo ti ON fp.id_tempo = ti.id_tempo
LEFT JOIN 
    dim_evento de ON fp.id_evento = de.id_evento
ORDER BY 
    ti.data DESC;
