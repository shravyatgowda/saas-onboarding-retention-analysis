-- SQLite schema used by src/run_analysis.py
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id     INTEGER PRIMARY KEY,
    signup_date TEXT NOT NULL,       -- YYYY-MM-DD
    plan        TEXT NOT NULL,
    channel     TEXT NOT NULL
);

CREATE TABLE events (
    event_id    INTEGER PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(user_id),
    event_name  TEXT NOT NULL,
    event_date  TEXT NOT NULL,
    day_offset  INTEGER NOT NULL     -- days since signup
);

CREATE INDEX idx_events_user ON events(user_id, event_name);
