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

## Next section

Choose the file and open the workbook in read-only mode.
