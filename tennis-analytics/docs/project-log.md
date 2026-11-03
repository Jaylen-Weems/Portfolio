# Tennis analytics project log

## Step 1 — Inspect the source structure

Read the original Excel export without modifying it. Identified six worksheets: Settings, Shots, Points, Games, Sets and Stats. The Shots worksheet contains 25 fields. Each row represents one tracked shot.

Business definition: the source Point field groups serve-attempt sequences, based on the owner's prior confirmation. It must not be counted as completed scored tennis points.

## Step 2 — Test the proposed shot identifier

Read Point and Shot from all 596 nonblank Shots records. Checked for missing values and repeated pairs.

Result: 596 distinct pairs, zero duplicate pairs and zero rows missing either value. Point + Shot is unique within this export. Combining matches will require Match ID + Point + Shot.

Learning: a composite key uses multiple fields together to identify a record. Uniqueness in this file is evidence for the proposed key, not a guarantee about every future export.

## Step 3 — Check shot-number continuity

Grouped records by source Point, sorted each group's Shot values, and compared them with the expected sequence 1 through the number of records in that group.

Result: all 188 source sequences passed. Each starts at Shot 1 and contains consecutive shot numbers. Recorded sequence lengths range from 1 to 14 shots.

Learning: this checks internal numbering consistency. It does not prove that every real-world shot was captured; the tracking system could omit a shot and still number its remaining records consecutively. Gaps between source Point identifiers are a different issue and were not treated as shot-number failures.

## Scope and privacy

These checks were performed read-only on the actual local Excel export. The live Google Sheet was not inspected. No full contract validation, Settings validation, warehouse load or scoring reconstruction has been completed. This log reports aggregate checks only; the personal workbook and source rows remain outside public commits.

## Step 4 — Create and run a reusable Python check

Created `check_shots.py` in VS Code. The script asks the user to choose an Excel export, opens the workbook in read-only mode, reads the Shots worksheet, checks that Point + Shot is unique, and checks that Shot values are consecutive within each Point. It reports only aggregate counts.

Ran the script locally against the original export. Result: 596 rows checked; 0 duplicate Point + Shot combinations; 188 sequences checked; 0 sequences with numbering problems; PASS. `openpyxl` was installed so Python could read `.xlsx` files.

Learning: code turns a manual data-quality check into a repeatable process. File selection means the script can be reused with future exports without placing personal file paths in the code.

## Next small step

Read the script section by section, then add one simple check for whether the expected worksheet and headers exist.
