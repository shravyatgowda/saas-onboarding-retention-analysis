-- Q4: Test candidate "aha moments": combinations of first-week actions.
WITH base AS (
    SELECT u.user_id,
           COALESCE(MAX(e.event_name = 'login' AND e.day_offset BETWEEN 21 AND 30), 0) AS is_retained,
           COALESCE(MAX(e.event_name = 'invite_teammate'    AND e.day_offset <= 6), 0)  AS invited,
           COALESCE(MAX(e.event_name = 'connect_integration' AND e.day_offset <= 6), 0) AS integrated
    FROM users u LEFT JOIN events e ON e.user_id = u.user_id
    GROUP BY u.user_id
),
segments AS (
    SELECT CASE WHEN invited = 1 AND integrated = 1 THEN '1. Invited + integrated in week 1'
                WHEN invited = 1                    THEN '2. Invited only'
                WHEN integrated = 1                 THEN '3. Integrated only'
                ELSE                                     '4. Neither' END AS segment,
           is_retained
    FROM base
)
SELECT segment,
       COUNT(*)                                  AS users,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_users,
       SUM(is_retained)                          AS retained_users,
       ROUND(100.0 * AVG(is_retained), 1)        AS retention_pct
FROM segments
GROUP BY segment
ORDER BY segment;
