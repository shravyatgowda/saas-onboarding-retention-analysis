# Nudge proposals

These are hypotheses based on the synthetic analysis. Each should be tested with an A/B experiment before rollout. No uplift is claimed.

## Nudge 1: Prompt a teammate invite right after the first project is created
- **Finding:** inviting a teammate in week 1 has the largest retention lift (+42.3 pts); only about 15% of all signups do it.
- **Where:** immediately after "Create project" succeeds, with a one-click invite panel.
- **Target:** users who created a project but have not invited anyone within 24 hours.
- **Success metric:** share of new users who invite a teammate within 7 days; guardrail: project-creation completion rate.

## Nudge 2: Surface integrations on day 2 for users with a project
- **Finding:** connecting an integration is the second strongest signal (+30.5 pts), and "invited + integrated" users retain at 75.1%.
- **Where:** an email plus an in-app checklist item on day 2.
- **Target:** users with a project but no integration.
- **Success metric:** integration connect rate within 7 days; day 21-30 retention of the nudged group vs control.

## Nudge 3: Rescue users who stall between profile and first project
- **Finding:** 37.1% of users who complete their profile never create a project, and project creation shows a +23.4 pt lift.
- **Where:** a template-based "start your first project in 60 seconds" prompt on the next login, plus a day-3 email.
- **Target:** profile complete, no project after 48 hours.
- **Success metric:** project-creation rate within 7 days of signup.

## How to test
1. Randomly split eligible users 50/50 (nudge vs no nudge).
2. Fix the primary metric and run time in advance.
3. Compare day 21-30 retention at the end, not just click-through.
