{{
    config(materialized='table')
}}

with source_cte as (
    select * from {{ source('mart_sources', 'redfin_housing_market_tracker') }}
),

-- Redfin uses the string 'NA' for missing measures
cleanse_cte as (
    select
        "PERIOD BEGIN" as start_date
        , "PERIOD END" as end_date
        , "REGION ID" as region_id
        , "REGION NAME" as region_name
        , "REGION TYPE" as region_type
        , nullif("HOMES SOLD", 'NA')::integer as homes_sold_count
        , nullif("MEDIAN SALE PRICE NSA ($)", 'NA')::decimal(18,2) as median_sale_price_nsa
        , nullif("MEDIAN DAYS ON MARKET (DAYS)", 'NA')::integer as median_days_on_market_count
        , nullif("NEW LISTINGS", 'NA')::integer as new_home_listing_count
        , nullif("ACTIVE LISTINGS", 'NA')::integer as active_home_listing_count
        , nullif("PENDING SALES", 'NA')::integer as pending_home_sales_count
        , nullif("MEDIAN NEW LISTING PRICE PER SQ.FT. ($)", 'NA')::decimal(18,2) as median_new_listing_price_per_square_foot
        , "FREQUENCY" as frequency
        , "IS SEASONALLY ADJUSTED" as is_seasonally_adjusted
        , nullif("HOMES SOLD YOY (%)", 'NA')::decimal(18,2) as pct_homes_sold_yoy_change
        , nullif("MEDIAN SALE PRICE NSA YOY (%)", 'NA')::decimal(18,2) as pct_median_sale_price_yoy_change
        , nullif("MEDIAN DAYS ON MARKET YOY (DAYS)", 'NA')::integer as median_days_on_market_yoy_change
        , nullif("NEW LISTINGS YOY (%)", 'NA')::decimal(18,2) as pct_new_listings_yoy_change
        , nullif("ACTIVE LISTINGS YOY (%)", 'NA')::decimal(18,2) as pct_active_listings_yoy_change
        , nullif("PENDING SALES YOY (%)", 'NA')::decimal(18,2) as pct_pending_sales_yoy_change
        , nullif("MEDIAN NEW LISTING PRICE PER SQ.FT. YOY (%)", 'NA')::decimal(18,2) as pct_median_new_listing_price_per_square_foot_yoy_change
        , "LAST UPDATED" as redfin_last_updated_date
    from
        source_cte
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['start_date', 'region_id', 'is_seasonally_adjusted']) }} as stg_redfin_housing_market_tracker_key
        , *
    from
        cleanse_cte
)

select * from final_cte
