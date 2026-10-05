# Shell Data Pipelines

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![GNU awk](https://img.shields.io/badge/GNU%20awk-A42E2B?style=flat-square&logo=gnu&logoColor=white)
![sed](https://img.shields.io/badge/sed-535D6C?style=flat-square)
![grep](https://img.shields.io/badge/grep%20(ERE)-535D6C?style=flat-square)
![gnuplot](https://img.shields.io/badge/gnuplot-1F6FB2?style=flat-square)

**From raw server logs to PNG charts with nothing but bash, awk, sed, and gnuplot — plus a standalone awk toolkit for CSV wrangling. 🐚**

Coursework project — BSc in Applied Data Science, Universitat Oberta de Catalunya (UOC), Scripting Programming course.

A collection of GNU/Linux command-line data-processing work: a five-script log-analysis pipeline (bash + awk + gnuplot) and a small toolkit of standalone awk/sed/grep scripts for CSV wrangling. The kind of plain-text plumbing used daily in bioinformatics and data-engineering work on Unix systems.

> Script comments were translated to English from the original Spanish. The code itself is unchanged, so the messages and chart labels printed by the scripts remain in Spanish.

## Objective

- Demonstrate fluency with the standard Unix text-processing stack: bash control flow and argument validation, awk for aggregation, sed/grep for filtering and recoding, gnuplot for quick visualisation.
- `log-analysis-pipeline/`: download a zip of server logs, verify and summarise each file, filter an Apache access log by HTTP status code, and produce per-URL and per-component aggregates with PNG charts.
- `awk-toolkit/`: single-purpose scripts for CSV quality control, grouped descriptive statistics, and row filtering/recoding.

## Data & methods

The datasets were provided by the course and are **not** redistributed here:

- **Server logs** (`apache.log`, `android.log`), distributed as a zip via a course Google Drive link. The original Drive file ID in `run.sh` has been replaced with the placeholder `YOUR_FILE_ID` — point `a.sh`/`run.sh` at any Google Drive zip of logs (or adapt `a.sh` to a plain `wget`/`curl` download) to reproduce the flow.
- **UFO sightings CSV** (NUFORC-style columns: `datetime, city, state, country, shape, duration (seconds), duration (hours/min), comments, date posted`), used by `csv_quality_check.awk`, `grouped_stats.awk` and `clean_and_recode.sed`. A public version of this dataset is available on Kaggle ("UFO Sightings", NUFORC scrubbed data).
- **Demographic CSV** (`demographic_info.csv`: id, sex, age, native language, other languages), used by the remaining toolkit scripts.

### `log-analysis-pipeline/`

| Script | What it does |
|---|---|
| `a.sh` | Downloads a zip from Google Drive (handles the confirmation-token dance with `wget` and session cookies), extracts it, and reports MD5 checksum, line count, and first/last record date-time for each log file, with per-format parsing (Android vs. Apache timestamp layouts). |
| `b.sh` | Filters `apache.log` by HTTP status code with strict argument validation: parameter count, file existence, allowed codes (200/304/404), and consistency between the requested code and the output filename. Fails fast with explicit error messages. |
| `c.sh` | Aggregates visits per URL with embedded awk (counts, sums, percentages), normalises URLs with sed (`http[s]://`, `www.` prefixes), writes a CSV, and plots two histograms (visit counts and percentage share for URLs above 1%) with gnuplot heredocs. |
| `d.sh` | Parses `android.log`, aggregates entry counts and total seconds per component with awk, sorts the resulting CSV, and renders two gnuplot histograms. |
| `run.sh` | Orchestrates the full A→D flow, including deliberate failing invocations of `b.sh` (missing arguments, wrong file, mismatched code/filename, disallowed code) that exercise its validation paths. |

### `awk-toolkit/`

| Script | What it does |
|---|---|
| `csv_quality_check.awk` | CSV quality control: validates country-code length, integer duration, and date ranges per row, routing failing rows (with header) into three separate `*_wrong.csv` files. |
| `grouped_stats.awk` | Grouped descriptive statistics: parses two date fields with `mktime`, computes the difference in days, and reports count, mean, and standard deviation (sum-of-squares method) per category. |
| `subgroup_percentage.awk` | Percentage of rows in one group that also satisfy a second condition (running counters + `END` block). |
| `filtered_mean.awk` | Mean of a numeric column over rows matching a pattern in either of two fields. |
| `clean_and_recode.sed` | Drops rows with empty fields, then recodes a numeric duration column into `Short`/`Long` categories using numeric-range regexes. |
| `filter_rows_grep.sh` | Row filter with an alternation regex over several CSV fields (`grep -E`). |
| `recode_labels.sh` | sed one-liner set: expands `F`/`M` labels to `Female`/`Male` and drops other rows. |
| `uppercase_field.sh` | Uppercases the fifth CSV field in place using sed's occurrence addressing (`\U&`). |

## Tech stack

bash, GNU awk (gawk), sed, grep (ERE), GNU coreutils (`cut`, `sort`, `tr`, `head`, `tail`, `wc`, `md5sum`), wget, gnuplot.

## How to run

Requires a GNU/Linux environment (or WSL) with `gawk`, `gnuplot`, `wget`, and `unzip` installed.

```bash
# Full pipeline (after replacing YOUR_FILE_ID in run.sh with a real Drive file ID)
cd log-analysis-pipeline
chmod +x *.sh
./run.sh

# Individual steps
./b.sh apache.log 200 out_200.log
./c.sh out_200.log        # -> url_counts.csv + two PNG charts
./d.sh android.log        # -> component_data.csv + two PNG charts

# Toolkit scripts read a CSV from a file argument or stdin, e.g.:
awk -f awk-toolkit/csv_quality_check.awk ufo_sightings.csv
awk -f awk-toolkit/grouped_stats.awk ufo_sightings.csv
sed -f awk-toolkit/clean_and_recode.sed ufo_sightings.csv
```

Note: `grouped_stats.awk` uses `mktime`, which is a gawk extension — plain POSIX awk will not run it.

## Repository structure

```
shell-data-pipelines/
├── log-analysis-pipeline/   # 5-script bash pipeline: download, verify, filter, aggregate, plot
│   ├── a.sh                 # download + per-file log summary (MD5, line counts, first/last record)
│   ├── b.sh                 # HTTP-status filter with strict argument validation
│   ├── c.sh                 # per-URL visit aggregation + gnuplot charts
│   ├── d.sh                 # per-component time aggregation + gnuplot charts
│   └── run.sh               # orchestrator (includes deliberate error-case invocations)
├── awk-toolkit/             # standalone awk/sed/grep scripts for CSV wrangling
└── README.md
```

## Notes

- Scripts were renamed from their original assignment names (`script3_4.awk`, `PEC3_4_a.awk`, ...) to descriptive ones; the code itself is unmodified except for the Google Drive file ID placeholder in `run.sh`.
- Course assignment statements, written reports, and screenshots are not included.
