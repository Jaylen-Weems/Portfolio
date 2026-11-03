# Tennis analytics

A small Python project that turns one SwingVision Excel export into a concise, actionable match snapshot.

## What it does

`analyze_match.py` reads a local export and reports:

- host-player shot count and Net/Out rate;
- the non-serve stroke with the highest Net/Out rate, using strokes with at least 10 shots;
- the most-used serve direction.

The goal is a practical starting point for choosing one area to practice after a match. It is a baseline from one match, not a complete coaching system.

## Run it

Install the one dependency:

```powershell
python -m pip install openpyxl
```

Then run the script from this folder:

```powershell
python analyze_match.py "path\to\SwingVision-match.xlsx"
```

The script reads the `Settings` and `Shots` worksheets without editing the workbook. Keep personal exports out of GitHub.

## Next

Run the script on more matches, track the same three measures, and choose one practice focus at a time. Add charts or deeper analysis only when they answer a specific tennis question.

