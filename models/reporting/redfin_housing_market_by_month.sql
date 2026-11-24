{{
    config(materialized='view')
}}

-- Only the not-seasonally-adjusted rows cover every metro, so this view uses those.
-- Query the fact table directly for the seasonally adjusted rows.
select
    * exclude (
    dim_date_key,
    stg_redfin_housing_market_tracker_key,
    dim_redfin_region_key
)

from {{ ref('fact_redfin_housing_market_by_month') }} f

join {{ ref('dim_date') }} d
    using (dim_date_key)

join {{ ref('dim_redfin_region') }} rg
    using (dim_redfin_region_key)

where
    f.is_seasonally_adjusted = false
