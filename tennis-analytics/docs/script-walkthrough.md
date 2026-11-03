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

## Next section

Define the expected workbook layout: the 25 required `Shots` headers.
