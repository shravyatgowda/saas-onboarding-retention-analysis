"""Generate a SYNTHETIC SaaS onboarding event log.

All data is simulated. Which first-week actions drive retention is an ASSUMPTION
written into this generator (inviting a teammate and connecting an integration
are made to matter most). The project demonstrates the analysis workflow
(SQL -> Python -> insights), not real-world findings.

Usage:
    python src/generate_data.py   # writes data/raw/*.csv (git-ignored)
                                  # and data/sample/*.csv (committed)
"""
from pathlib import Path

import numpy as np
import pandas as pd

SEED = 7
ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
SAMPLE = ROOT / "data" / "sample"

N_USERS = 6000
SIGNUP_START, SIGNUP_END = "2025-01-01", "2025-06-30"
WINDOW_DAYS = 30

PLANS = ["free", "team", "business"]
CHANNELS = ["organic", "paid_search", "referral", "partner"]


def build(rng: np.random.Generator):
    signup_dates = pd.to_datetime(
        rng.choice(pd.date_range(SIGNUP_START, SIGNUP_END), size=N_USERS))
    users = pd.DataFrame({
        "user_id": np.arange(1, N_USERS + 1),
        "signup_date": signup_dates,
        "plan": rng.choice(PLANS, N_USERS, p=[0.6, 0.3, 0.1]),
        "channel": rng.choice(CHANNELS, N_USERS, p=[0.4, 0.25, 0.2, 0.15]),
    })

    events = []

    def add(uid, name, day):
        events.append((uid, name, day))

    for u in users.itertuples():
        add(u.user_id, "signup", 0)
        profile = rng.random() < 0.85
        project = profile and rng.random() < 0.62
        invite = project and rng.random() < 0.38
        integrate = project and rng.random() < 0.32
        dashboard = project and rng.random() < 0.50
        export = dashboard and rng.random() < 0.30

        # Timing: most key actions happen early, some are delayed past day 7
        def when(p_early=0.7):
            return int(rng.integers(0, 7)) if rng.random() < p_early else int(rng.integers(7, 25))

        if profile:
            add(u.user_id, "profile_setup", int(rng.integers(0, 2)))
        if project:
            add(u.user_id, "create_project", int(rng.integers(0, 4)))
        d_invite = when() if invite else None
        d_integrate = when() if integrate else None
        if invite:
            add(u.user_id, "invite_teammate", d_invite)
        if integrate:
            add(u.user_id, "connect_integration", d_integrate)
        if dashboard:
            add(u.user_id, "view_dashboard", when(0.6))
        if export:
            add(u.user_id, "export_report", when(0.5))

        # Assumed retention model: invite and integration in week 1 matter most
        logit = -2.2
        logit += 1.7 * (invite and d_invite <= 6)
        logit += 1.1 * (integrate and d_integrate <= 6)
        logit += 0.5 * bool(project)
        logit += 0.3 * bool(dashboard)
        logit += 0.25 * (u.channel == "referral")
        retained = rng.random() < 1 / (1 + np.exp(-logit))

        # Generic activity (logins) drives the "active" definition
        early_days = rng.choice(np.arange(0, 15), size=int(rng.integers(1, 6)), replace=True)
        for dday in early_days:
            add(u.user_id, "login", int(dday))
        if retained:
            for dday in rng.choice(np.arange(21, WINDOW_DAYS + 1), size=int(rng.integers(1, 5))):
                add(u.user_id, "login", int(dday))
            for dday in rng.choice(np.arange(15, 21), size=int(rng.integers(0, 3))):
                add(u.user_id, "login", int(dday))

    ev = pd.DataFrame(events, columns=["user_id", "event_name", "day_offset"])
    ev = ev.merge(users[["user_id", "signup_date"]], on="user_id")
    ev["event_date"] = ev["signup_date"] + pd.to_timedelta(ev["day_offset"], unit="D")
    ev = ev.sort_values(["user_id", "day_offset"]).reset_index(drop=True)
    ev.insert(0, "event_id", np.arange(1, len(ev) + 1))
    ev["event_date"] = ev["event_date"].dt.date
    users["signup_date"] = users["signup_date"].dt.date
    return users, ev[["event_id", "user_id", "event_name", "event_date", "day_offset"]]


def main() -> None:
    rng = np.random.default_rng(SEED)
    RAW.mkdir(parents=True, exist_ok=True)
    SAMPLE.mkdir(parents=True, exist_ok=True)
    users, events = build(rng)
    users.to_csv(RAW / "users.csv", index=False)
    events.to_csv(RAW / "events.csv", index=False)
    users.head(200).to_csv(SAMPLE / "users_sample.csv", index=False)
    events[events["user_id"] <= 200].to_csv(SAMPLE / "events_sample.csv", index=False)
    print(f"users: {len(users):,} | events: {len(events):,}")


if __name__ == "__main__":
    main()
