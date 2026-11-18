-- Q1: Onboarding funnel. How many users reach each step, and where do they drop?
WITH flags AS (
    SELECT u.user_id,
           MAX(e.event_name = 'profile_setup')        AS did_profile,
           MAX(e.event_name = 'create_project')       AS did_project,
           MAX(e.event_name IN ('invite_teammate', 'connect_integration')) AS did_collab,
           MAX(e.event_name = 'view_dashboard')       AS did_dashboard,
           MAX(e.event_name = 'export_report')        AS did_export
    FROM users u
    LEFT JOIN events e ON e.user_id = u.user_id
    GROUP BY u.user_id
),
steps AS (
    SELECT 1 AS step_no, 'Signed up'                            AS step, COUNT(*)           AS users FROM flags
    UNION ALL SELECT 2, 'Completed profile',                    SUM(did_profile)   FROM flags
    UNION ALL SELECT 3, 'Created first project',                SUM(did_project)   FROM flags
    UNION ALL SELECT 4, 'Invited teammate or connected integration', SUM(did_collab) FROM flags
    UNION ALL SELECT 5, 'Viewed dashboard',                     SUM(did_dashboard) FROM flags
    UNION ALL SELECT 6, 'Exported a report',                    SUM(did_export)    FROM flags
)
SELECT step_no, step, users,
       ROUND(100.0 * users / FIRST_VALUE(users) OVER (ORDER BY step_no), 1)      AS pct_of_signups,
       ROUND(100.0 * users / LAG(users) OVER (ORDER BY step_no), 1)              AS pct_of_previous_step
FROM steps
ORDER BY step_no;
