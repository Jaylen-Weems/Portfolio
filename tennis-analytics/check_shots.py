"""Check SwingVision Shots identifiers and layout without changing the Excel file."""

from collections import Counter, defaultdict
from tkinter import Tk, filedialog

from openpyxl import load_workbook

# This is the 25-column layout observed in the first SwingVision export.
EXPECTED_HEADERS = [
    "Player", "Shot", "Type", "Stroke", "Spin", "Speed (MPH)", "Point",
    "Game", "Set", "Bounce Depth", "Bounce Zone", "Bounce Side", "Bounce (x)",
    "Bounce (y)", "Hit Depth", "Hit Zone", "Hit Side", "Hit (x)", "Hit (y)",
    "Hit (z)", "Direction", "Result", "Favorited", "Start Time", "Video Time",
]

# 1. Choose the export. A file picker keeps personal paths out of the code.
root = Tk()
root.withdraw()
file_path = filedialog.askopenfilename(
    title="Choose your SwingVision export",
    filetypes=[("Excel workbook", "*.xlsx")],
)
root.destroy()
if not file_path:
    raise SystemExit("No file selected.")

# 2. Open the workbook read-only and confirm its expected layout.
workbook = load_workbook(file_path, read_only=True, data_only=False)
try:
    if "Shots" not in workbook.sheetnames:
        raise ValueError("The workbook does not contain a Shots worksheet.")

    sheet = workbook["Shots"]
    rows = sheet.iter_rows(values_only=True)
    headers = list(next(rows))
    if headers != EXPECTED_HEADERS:
        raise ValueError("Shots headers do not match the expected SwingVision layout.")

    # 3. Read the two fields that identify a shot within this match.
    point_column = headers.index("Point")
    shot_column = headers.index("Shot")
    pairs = []
    for row in rows:
        if all(value is None for value in row):
            continue
        point = row[point_column]
        shot = row[shot_column]
        if (
            isinstance(point, bool)
            or isinstance(shot, bool)
            or not isinstance(point, (int, float))
            or not isinstance(shot, (int, float))
            or point < 1
            or shot < 1
            or point % 1 != 0
            or shot % 1 != 0
        ):
            raise ValueError("Point and Shot must be positive whole numbers.")
        pairs.append((int(point), int(shot)))
finally:
    workbook.close()

if not pairs:
    raise ValueError("The Shots worksheet has no data rows.")

# 4. Check whether Point + Shot identifies each recorded shot once.
pair_counts = Counter(pairs)
duplicate_pairs = sum(count > 1 for count in pair_counts.values())

# 5. Check whether Shot numbering is consecutive within each Point.
shots_by_point = defaultdict(list)
for point, shot in pairs:
    shots_by_point[point].append(shot)

sequence_failures = 0
for shots in shots_by_point.values():
    if sorted(shots) != list(range(1, len(shots) + 1)):
        sequence_failures += 1

# Print aggregate results only, without player names or source rows.
print("Shots worksheet and headers: PASS")
print(f"Shot rows checked: {len(pairs)}")
print(f"Duplicate Point + Shot combinations: {duplicate_pairs}")
print(f"Source sequences checked: {len(shots_by_point)}")
print(f"Sequences with numbering problems: {sequence_failures}")
print("PASS" if duplicate_pairs == 0 and sequence_failures == 0 else "FAIL")

