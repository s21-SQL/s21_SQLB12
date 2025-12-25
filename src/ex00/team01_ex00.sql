WITH latest_currency AS (SELECT DISTINCT ON (id, name) id,
                                                       name,
                                                       rate_to_usd
                         FROM currency
                         ORDER BY id, name, updated DESC),
     balance_aggregated AS (SELECT user_id,
                                   type,
                                   currency_id,
                                   SUM(money) AS volume
                            FROM balance
                            GROUP BY user_id, type, currency_id)
SELECT COALESCE(u.name, 'not defined')                 AS name,
       COALESCE(u.lastname, 'not defined')             AS lastname,
       ba.type,
       ba.volume,
       COALESCE(lc.name, 'not defined')                AS currency_name,
       COALESCE(lc.rate_to_usd, 1)                     AS last_rate_to_usd,
       (ba.volume * COALESCE(lc.rate_to_usd, 1))::real AS total_volume_in_usd
FROM balance_aggregated ba
         LEFT JOIN "user" u ON u.id = ba.user_id
         LEFT JOIN latest_currency lc ON lc.id = ba.currency_id
ORDER BY name DESC, lastname ASC, ba.type ASC;