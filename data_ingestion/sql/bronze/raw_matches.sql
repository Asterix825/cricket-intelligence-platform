CREATE SCHEMA IF NOT EXISTS bronze_raw;

CREATE TABLE IF NOT EXISTS bronze_raw.raw_matches_json (
    match_id TEXT PRIMARY KEY,
    season INT,
    source_file TEXT,
    file_hash TEXT,
    raw_payload JSONB,
    ingested_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_raw_payload_gin
ON bronze_raw.raw_matches_json
USING GIN (raw_payload);
