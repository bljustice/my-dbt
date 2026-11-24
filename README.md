# my-dbt

My personal data warehouse built with [dbt](https://docs.getdbt.com/) on [DuckDB](https://duckdb.org/). It models two sources as Kimball-style star schemas:

- **YNAB:** budget plans and transactions from [YNAB](https://www.ynab.com/), pulled through the YNAB API.
- **Redfin:** monthly housing market metrics by metro area, from the [Redfin Data Center](https://www.redfin.com/news/data-center/).

Everything lives in one local DuckDB file, `datamart.duckdb`. It is gitignored.

## Layout

| Path | Contents |
|---|---|
| `models/sources.yml` | Raw tables in the `mart_sources` schema |
| `models/staging/` | `stg_*` models: rename, cast and key the raw data |
| `models/mart/` | `dim_*` and `fact_*` tables |
| `models/reporting/` | Views that join each fact to its dimensions, ready to query |

## Setup

You need Python 3.12 and the [DuckDB CLI](https://duckdb.org/docs/installation/) on your `PATH`.

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install dbt        # dbt 2.0, which includes DuckDB support
dbt deps               # installs dbt_utils
```

`profiles.yml` lives in the repo and points dbt at `./datamart.duckdb`, so no other connection setup is needed.