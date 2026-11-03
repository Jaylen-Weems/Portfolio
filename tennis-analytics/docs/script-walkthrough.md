# Script walkthrough

This document explains `check_shots.py` in the order it runs. It is intentionally built one small section at a time.

## Section 1 — Purpose and imports

The first line, called a **docstring**, states the program’s job:

> Check SwingVision Shots identifiers and layout without changing the Excel file.

That scope matters. The program reads an export and reports findings; it never edits the workbook.

The script imports three groups of tools:

| Import | Purpose in this project |
|---|---|
| `Counter` | Counts each `Point + Shot` pair to identify duplicates. |
| `defaultdict` | Groups Shot numbers under their Point number to test numbering continuity. |
| `Tk, filedialog` | Opens a file picker so the user chooses an export instead of placing a personal file path in code. |
| `load_workbook` from `openpyxl` | Opens Excel workbooks for reading. |

An **import** lets a Python program use code that already exists elsewhere. This keeps the script focused on its task instead of recreating common tools.

### Interview explanation

“I built a small read-only Python validator. I used an Excel library to open the export, standard-library collection tools to detect duplicates and group sequences, and a file picker so the code could be reused without hardcoding a personal path.”

## Section 2 — Expected headers

`EXPECTED_HEADERS` is a Python **list**: an ordered collection of values. In this case, each value is the exact name of one field that appeared in your SwingVision `Shots` worksheet.

The list has 25 items, beginning with `Player`, `Shot`, `Type`, and `Stroke`, and ending with `Favorited`, `Start Time`, and `Video Time`.

The script compares the workbook's header row with this list:

```python
if headers != EXPECTED_HEADERS:
    raise ValueError("Shots headers do not match the expected SwingVision layout.")
```

The `!=` symbol means “is not equal to.” If the worksheet is missing a field, has an unexpected extra field, renames one, or changes their order, the comparison fails. `raise ValueError` stops the program and gives a useful reason.

This is a **schema check**. A schema is the agreed structure of a dataset: its field names, order, and often their meanings and expected types.

### Why this comes first

All later code refers to columns by name. If the source layout changes first, later calculations could point to the wrong field or fail less clearly. Checking structure at the start makes the failure immediate and understandable.

### Current evidence

The original workbook passed this check: it has a `Shots` worksheet and exactly 25 headers matching the expected list. The list is based on this one export, so it is a starting contract rather than a claim that every SwingVision export will always look the same.

### Interview explanation

“Before analyzing shot data, I added a schema check. The script verifies the expected worksheet and its 25 headers so a source-format change fails early, instead of silently creating misleading analysis.”

## Section 3 — Choose and open the workbook

The script uses a file picker:

```python
file_path = filedialog.askopenfilename(
    title="Choose your SwingVision export",
    filetypes=[("Excel workbook", "*.xlsx")],
)
```

This displays a window where you select the export you want to check. The selected location is stored temporarily in `file_path`. The location is not written into the script, printed in the report, or committed to GitHub.

If you cancel the picker, the script ends immediately:

```python
if not file_path:
    raise SystemExit("No file selected.")
```

That protects the rest of the program from trying to open an empty location.

Next, the script opens the file:

```python
workbook = load_workbook(file_path, read_only=True, data_only=False)
```

`read_only=True` is the important setting. It tells the Excel library to read the workbook without preparing it for edits. The script also never calls a save function. Its job is to inspect, not modify.

`data_only=False` preserves source cells as they are stored. It avoids making this validation step depend on recalculated formula results. Your SwingVision export is static data, but this setting makes the script's reading behavior explicit.

The `try ... finally` block closes the workbook even if a check fails:

```python
try:
    # inspect workbook contents
finally:
    workbook.close()
```

This is cleanup. It releases the file after reading so Excel or another program can use it normally.

### Interview explanation

“I made the validator reusable with a file picker and opened each workbook in read-only mode. The code does not save the file, and its cleanup block closes the workbook even when validation stops because of a problem.”

## Section 4 — Find the Shots table

After opening the workbook, the script first checks that a worksheet named `Shots` exists:

```python
if "Shots" not in workbook.sheetnames:
    raise ValueError("The workbook does not contain a Shots worksheet.")
```

`workbook.sheetnames` is the list of worksheet names in the file. This check prevents an unclear error later if the wrong workbook is selected or SwingVision changes the worksheet name.

Then the script selects that worksheet and prepares to read it one row at a time:

```python
sheet = workbook["Shots"]
rows = sheet.iter_rows(values_only=True)
headers = list(next(rows))
```

`sheet` is the selected worksheet. `iter_rows` creates an **iterator**, which means Python can work through rows one at a time instead of loading the entire worksheet into a custom structure first.

`next(rows)` takes the first available row. In an exported data table, that first row is the header row—the labels such as `Player`, `Shot`, and `Point`. `list(...)` turns that row into an ordinary Python list so it can be compared with `EXPECTED_HEADERS`.

The next test is the schema check:

```python
if headers != EXPECTED_HEADERS:
    raise ValueError("Shots headers do not match the expected SwingVision layout.")
```

If this check passes, every later line can safely refer to the columns it needs. If it fails, the script stops before attempting any calculations.

### Interview explanation

“I validate the worksheet before reading records. The code confirms the expected table exists, treats the first row as the schema, and stops early if that schema differs from the documented SwingVision layout.”

## Next section

Read the Point and Shot values and check that each is a valid positive whole number.
