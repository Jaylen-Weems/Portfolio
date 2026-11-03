# Tennis analytics

A step-by-step portfolio project exploring how to turn SwingVision tennis exports into reliable data for analysis.

## Purpose

Build an understandable workflow, explain each engineering decision, and document the evidence behind it. The initial workflow is simple: Excel export → read-only Python checks → review the results.

## Progress

- Inspected the workbook structure: six worksheets and 25 Shots fields.
- Checked all 596 shot records: Point + Shot is unique, with no missing key values.
- Checked shot numbering: all 188 source sequences start at 1 and have no numbering gaps.

These are initial checks on one export, not full data certification. The source Point field represents a serve-attempt sequence; it must not be counted as a completed scored tennis point.

## Project documentation

Read the [project log](docs/project-log.md) for each step's method, findings and limitations.

## Data privacy

Personal match exports, player-level source rows and credentials are excluded from this public project. Only aggregate validation findings are documented here.

## Next step

Add a small Python script that reproduces the uniqueness and shot-number checks, then explain and document how it works. Future features will be introduced one at a time.
