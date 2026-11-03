
"""Check shot identifiers and numbering without changing the Excel file."""

from collections import Counter, defaultdict
from tkinter import Tk, filedialog

from openpyxl import load_workbook

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

# 2. Read the two columns we need, matching their header names.
workbook = load_workbook(file_path, read_only=True, data_only=False)
try:
    sheet = workbook["Shots"]
    rows = sheet.iter_rows(values_only=True)
    headers = list(next(rows))
    point_column = headers.index("Point")
    shot_column = headers.index("Shot")
    pairs = []
    for row in rows:
        if all(value is None for value in row):
            continue
        point = row[point_column]
        shot = row[shot_column]
        # Stop if identifiers are missing or are not positive whole numbers.
        for value in (point, shot):
            if (
                isinstance(value, bool)
                or not isinstance(value, (int, float))
                or value < 1
                or value % 1 != 0
            ):
                raise ValueError("Point and Shot must be positive whole numbers.")
        pairs.append((int(point), int(shot)))
finally:
    workbook.close()

if not pairs:
    raise ValueError("The Shots worksheet has no data rows.")

# 3. Count how often each Point + Shot pair occurs.
pair_counts = Counter(pairs)
duplicate_pairs = sum(count > 1 for count in pair_counts.values())

# 4. Group shots by Point and compare them with 1, 2, ..., N.
shots_by_point = defaultdict(list)
for point, shot in pairs:
    shots_by_point[point].append(shot)

sequence_failures = 0
for shots in shots_by_point.values():
    expected = list(range(1, len(shots) + 1))
    if sorted(shots) != expected:
        sequence_failures += 1

# Print aggregate results only, without player names or source rows.
print(f"Shot rows checked: {len(pairs)}")
print(f"Duplicate Point + Shot combinations: {duplicate_pairs}")
print(f"Source sequences checked: {len(shots_by_point)}")
print(f"Sequences with numbering problems: {sequence_failures}")
print("PASS" if duplicate_pairs == 0 and sequence_failures == 0 else "FAIL")


