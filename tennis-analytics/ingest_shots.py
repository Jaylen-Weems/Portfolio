"""Load one private SwingVision export from Cloud Storage into BigQuery."""

from pathlib import Path
import re
import sys
import tempfile

import pandas as pd
from google.cloud import bigquery, storage
from google.api_core.exceptions import NotFound
from openpyxl import load_workbook


PROJECT_ID = "future-infusion-328319"
BUCKET_NAME = "tennis-analytics-raw-future-infusion-328319"
DATASET_ID = "tennis_analytics"
TABLE_ID = f"{PROJECT_ID}.{DATASET_ID}.shots"


def clean_column_name(name):
    """Convert SwingVision column labels into BigQuery-friendly names."""
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def read_shots(workbook_path, source_file):
    """Read the Shots worksheet without changing the original Excel file."""
    workbook = load_workbook(workbook_path, read_only=True, data_only=True)
    try:
        settings = workbook["Settings"]
        settings_rows = settings.iter_rows(values_only=True)
        setting_headers = list(next(settings_rows))
        setting_values = list(next(settings_rows))
        host_name = setting_values[setting_headers.index("Host Team")]

        sheet = workbook["Shots"]
        shot_rows = sheet.iter_rows(values_only=True)
        headers = list(next(shot_rows))
        rows = [
            row
            for row in shot_rows
            if any(value is not None for value in row)
        ]
    finally:
        workbook.close()

    dataframe = pd.DataFrame(rows, columns=[clean_column_name(name) for name in headers])
    dataframe["source_file"] = source_file
    dataframe["host_player"] = host_name
    dataframe["shot_id"] = dataframe.apply(
        lambda row: f"{Path(source_file).stem}-{int(row['point']):04d}-{int(row['shot']):02d}",
        axis=1,
    )
    return dataframe


def main(source_file):
    storage_client = storage.Client(project=PROJECT_ID)
    bigquery_client = bigquery.Client(project=PROJECT_ID)
    blob = storage_client.bucket(BUCKET_NAME).blob(source_file)

    if not blob.exists():
        raise FileNotFoundError(f"{source_file} was not found in {BUCKET_NAME}.")

    with tempfile.TemporaryDirectory() as directory:
        local_file = Path(directory) / Path(source_file).name
        blob.download_to_filename(local_file)
        shots = read_shots(local_file, source_file)

    try:
        bigquery_client.get_table(TABLE_ID)
    except NotFound:
        pass  # The first load creates the table from the dataframe schema.
    else:
        existing = bigquery_client.query(
            f"SELECT COUNT(*) AS count FROM `{TABLE_ID}` WHERE source_file = @source_file",
            job_config=bigquery.QueryJobConfig(
                query_parameters=[bigquery.ScalarQueryParameter("source_file", "STRING", source_file)]
            ),
        ).result()
        if next(existing).count:
            raise ValueError(f"{source_file} has already been loaded. No duplicate rows were added.")

    job = bigquery_client.load_table_from_dataframe(
        shots,
        TABLE_ID,
        job_config=bigquery.LoadJobConfig(write_disposition=bigquery.WriteDisposition.WRITE_APPEND),
    )
    job.result()
    print(f"Loaded {len(shots)} shots from {source_file} into {TABLE_ID}.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python ingest_shots.py path/in/the/bucket.xlsx")
    main(sys.argv[1])

