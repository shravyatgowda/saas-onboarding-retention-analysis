-- Q2: Weekly activity retention by signup-month cohort.
-- A user is "active" in a week if they logged in during that window after signup.
WITH cohort AS (
    SELECT user_id, strftime('%Y-%m', signup_date) AS cohort_month FROM users
),
weekly AS (
    SELECT c.cohort_month,
           c.user_id,
           COALESCE(MAX(e.day_offset BETWEEN 0  AND 6), 0)  AS w0,
           COALESCE(MAX(e.day_offset BETWEEN 7  AND 13), 0) AS w1,
           COALESCE(MAX(e.day_offset BETWEEN 14 AND 20), 0) AS w2,
           COALESCE(MAX(e.day_offset BETWEEN 21 AND 30), 0) AS w3_plus
    FROM cohort c
    LEFT JOIN events e ON e.user_id = c.user_id AND e.event_name = 'login'
    GROUP BY c.cohort_month, c.user_id
)
SELECT cohort_month,
       COUNT(*)                          AS users,
       ROUND(100.0 * AVG(w0), 1)         AS week0_pct,
       ROUND(100.0 * AVG(w1), 1)         AS week1_pct,
       ROUND(100.0 * AVG(w2), 1)         AS week2_pct,
       ROUND(100.0 * AVG(w3_plus), 1)    AS day21_30_pct
FROM weekly
GROUP BY cohort_month
ORDER BY cohort_month;
