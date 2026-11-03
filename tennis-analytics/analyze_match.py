"""Create a concise, local tennis report from one SwingVision Excel export."""

from collections import Counter, defaultdict
from pathlib import Path
import sys

from openpyxl import load_workbook


def percentage(part, whole):
    return 0 if whole == 0 else part / whole * 100


def main(path):
    workbook = load_workbook(path, read_only=True, data_only=True)
    try:
        settings = workbook["Settings"]
        setting_rows = settings.iter_rows(values_only=True)
        setting_headers = list(next(setting_rows))
        setting_values = list(next(setting_rows))
        host_name = setting_values[setting_headers.index("Host Team")]

        shots = workbook["Shots"]
        headers = list(next(shots.iter_rows(values_only=True)))
        player_column = headers.index("Player")
        rows = [
            dict(zip(headers, row))
            for row in shots.iter_rows(values_only=True)
            if any(value is not None for value in row) and row[player_column] == host_name
        ]
    finally:
        workbook.close()

    if not rows:
        raise ValueError("No host-player shot records were found.")

    def errors(group):
        return sum(row["Result"] in ("Net", "Out") for row in group)

    strokes = defaultdict(list)
    for row in rows:
        strokes[row["Stroke"]].append(row)

    meaningful_strokes = [
        (stroke, values)
        for stroke, values in strokes.items()
        if stroke != "Serve" and len(values) >= 10
    ]
    focus_stroke, focus_rows = max(
        meaningful_strokes,
        key=lambda item: percentage(errors(item[1]), len(item[1])),
    )

    serves = [row for row in rows if row["Type"] == "serve"]
    directions = Counter(row["Direction"] for row in serves)
    most_common_direction, direction_count = directions.most_common(1)[0]

    print("SWINGVISION MATCH SNAPSHOT")
    print(f"Host-player shots: {len(rows)}")
    print(f"Net or Out rate: {percentage(errors(rows), len(rows)):.1f}%")
    print()
    print("PRACTICE FOCUS")
    print(
        f"{focus_stroke}: {percentage(errors(focus_rows), len(focus_rows)):.1f}% "
        f"Net/Out across {len(focus_rows)} shots."
    )
    print()
    print("SERVE PATTERN")
    print(
        f"Most common direction: {most_common_direction} "
        f"({direction_count} of {len(serves)} serves, "
        f"{percentage(direction_count, len(serves)):.1f}%)."
    )
    print()
    print("Use this as a practice baseline, not a verdict from one match.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python analyze_match.py path/to/export.xlsx")
    main(Path(sys.argv[1]))

