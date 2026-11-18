-- Q3: Which first-week actions separate retained users from churned ones?
-- retained = logged in on day 21-30. Feature "adopted" = done within the first 7 days (day 0-6).
WITH retained AS (
    SELECT u.user_id,
           COALESCE(MAX(e.event_name = 'login' AND e.day_offset BETWEEN 21 AND 30), 0) AS is_retained
    FROM users u LEFT JOIN events e ON e.user_id = u.user_id
    GROUP BY u.user_id
),
week1 AS (
    SELECT user_id, event_name
    FROM events
    WHERE day_offset BETWEEN 0 AND 6
      AND event_name IN ('profile_setup','create_project','invite_teammate',
                         'connect_integration','view_dashboard','export_report')
    GROUP BY user_id, event_name
),
features AS (
    SELECT DISTINCT event_name AS feature FROM week1
),
grid AS (
    SELECT f.feature, r.user_id, r.is_retained,
           EXISTS (SELECT 1 FROM week1 w WHERE w.user_id = r.user_id AND w.event_name = f.feature) AS adopted
    FROM features f CROSS JOIN retained r
),
summary AS (
    SELECT feature,
           SUM(adopted)                                                        AS adopters,
           ROUND(100.0 * AVG(CASE WHEN adopted = 1 THEN is_retained END), 1)   AS retention_adopters_pct,
           ROUND(100.0 * AVG(CASE WHEN adopted = 0 THEN is_retained END), 1)   AS retention_others_pct
    FROM grid
    GROUP BY feature
)
SELECT feature, adopters, retention_adopters_pct, retention_others_pct,
       ROUND(retention_adopters_pct - retention_others_pct, 1)                 AS lift_pts,
       RANK() OVER (ORDER BY retention_adopters_pct - retention_others_pct DESC) AS lift_rank
FROM summary
ORDER BY lift_rank;
