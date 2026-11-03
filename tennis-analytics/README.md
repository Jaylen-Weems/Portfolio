# Tennis analytics platform

A cloud data-engineering project built around private SwingVision match exports.

```text
SwingVision Excel → Cloud Storage → Python ingestion → BigQuery → analysis
```

## What is in the cloud

- **Cloud Storage:** immutable raw exports; never public or committed to GitHub.
- **BigQuery:** the `tennis_analytics` dataset for clean, queryable tables.
- **GitHub:** code and short documentation, accessible from any device.

## Scripts

- `analyze_match.py` creates a concise local practice snapshot.
- `ingest_shots.py` downloads one private export from Cloud Storage and appends its `Shots` worksheet to BigQuery. It refuses to load a source file twice.

## Run the ingestion script

Install dependencies and authenticate your local machine with Google Cloud before running:

```powershell
python -m pip install -r requirements.txt
python ingest_shots.py "SwingVision-match-2026-10-30 at 19.20.19.xlsx"
```

Raw match files stay out of GitHub. The next engineering step is to load the first export and query the resulting `shots` table.

