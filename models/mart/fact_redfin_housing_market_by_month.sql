{{
    config(materialized='table')
}}

with redfin_cte as (
    select * from {{ ref('stg_redfin_housing_market_tracker') }}
),

dim_date_cte as (
    select * from {{ ref('dim_date') }}
),

dim_redfin_region_cte as (
    select * from {{ ref('dim_redfin_region') }}
),

fact_cte as (
    select
        r.stg_redfin_housing_market_tracker_key
        , coalesce(d.dim_date_key, -1) as dim_date_key
        , coalesce(rg.dim_redfin_region_key, '-1') as dim_redfin_region_key
        -- degenerate dimensions
        , r.frequency
        , r.is_seasonally_adjusted
        -- additive
        , r.homes_sold_count
        , r.new_home_listing_count
        , r.pending_home_sales_count
        -- semi-additive: do not sum across months
        , r.active_home_listing_count
        -- non-additive
        , r.median_sale_price_nsa
        , r.median_days_on_market_count
        , r.median_new_listing_price_per_square_foot
        , r.pct_homes_sold_yoy_change
        , r.pct_median_sale_price_yoy_change
        , r.median_days_on_market_yoy_change
        , r.pct_new_listings_yoy_change
        , r.pct_active_listings_yoy_change
        , r.pct_pending_sales_yoy_change
        , r.pct_median_new_listing_price_per_square_foot_yoy_change
        -- audit
        , r.redfin_last_updated_date
    from
        redfin_cte r
    left join
        dim_date_cte d
        on d.date = r.start_date
    left join
        dim_redfin_region_cte rg
        using (region_id)
)

select * from fact_cte
