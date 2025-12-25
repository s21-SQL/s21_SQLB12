INSERT INTO currency VALUES (100, 'EUR', 0.85, '2022-01-01 13:29');
INSERT INTO currency VALUES (100, 'EUR', 0.79, '2022-01-08 13:29');

WITH balance_with_nearest_rate AS (
    SELECT 
        b.user_id,
        b.money,
        b.currency_id,
        b.updated AS balance_date,
        COALESCE(
            (SELECT c.rate_to_usd 
             FROM currency c 
             WHERE c.id = b.currency_id 
               AND c.updated <= b.updated 
             ORDER BY c.updated DESC 
             LIMIT 1),
            (SELECT c.rate_to_usd 
             FROM currency c 
             WHERE c.id = b.currency_id 
               AND c.updated >= b.updated 
             ORDER BY c.updated ASC 
             LIMIT 1)
        ) AS rate_to_usd
    FROM balance b
    WHERE EXISTS (
        SELECT 1 
        FROM currency c 
        WHERE c.id = b.currency_id
    )
),
currency_name_lookup AS (
    SELECT DISTINCT ON (id) id, name
    FROM currency
    ORDER BY id, updated DESC
)
SELECT 
    COALESCE(u.name, 'not defined') AS name,
    COALESCE(u.lastname, 'not defined') AS lastname,
    cnl.name AS currency_name,
    (bnr.money * bnr.rate_to_usd)::REAL AS currency_in_usd
FROM balance_with_nearest_rate bnr
LEFT JOIN currency_name_lookup cnl ON bnr.currency_id = cnl.id
LEFT JOIN "user" u ON bnr.user_id = u.id
ORDER BY name DESC, lastname ASC, currency_name ASC;