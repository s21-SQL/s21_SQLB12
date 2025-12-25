WITH latest_currency AS (SELECT DISTINCT ON (id, name) id,
                                                       name,
                                                       rate_to_usd
                         FROM currency
                         ORDER BY id, name, updated DESC),
     balance_aggregated AS (SELECT b.user_id,
                                   b.type,
                                   b.currency_id,
                                   SUM(b.money) AS volume
                            FROM balance b
                            GROUP BY b.user_id, b.type, b.currency_id)
SELECT COALESCE(u.name, 'not defined')                AS name,
       COALESCE(u.lastname, 'not defined')            AS lastname,
       ba.type,
       ba.volume,
       COALESCE(c.name, 'not defined')                AS currency_name,
       COALESCE(c.rate_to_usd, 1)                     AS last_rate_to_usd,
       (ba.volume * COALESCE(c.rate_to_usd, 1))::REAL AS total_volume_in_usd
FROM balance_aggregated ba
         LEFT JOIN "user" u ON u.id = ba.user_id
         LEFT JOIN latest_currency c ON c.id = ba.currency_id
ORDER BY name DESC, lastname ASC, ba.type ASC;
