{{
    config(materialized='table')
}}

with source_cte as (
    select * from {{ source('mart_sources', 'redfin_housing_market_tracker') }}
)

, cleanse_cte as (
    select
        "PERIOD BEGIN" as start_date
        , "PERIOD END" as end_date
        , "REGION ID" as region_id
        , "REGION NAME" as region_name
        , "REGION TYPE" as region_type
        , "HOMES SOLD" as homes_sold_count
        , "MEDIAN SALE PRICE NSA ($)" as median_sale_price_nsa
        , "MEDIAN DAYS ON MARKET (DAYS)" as median_days_on_market_count
        , "NEW LISTINGS" as new_home_listing_count
        , "ACTIVE LISTINGS" as active_home_listing_count
        , "PENDING SALES" as pending_home_sales_count
        , "MEDIAN NEW LISTING PRICE PER SQ.FT. ($)" as median_new_listing_price_per_square_foot
        , "FREQUENCY" as frequency
        , "IS SEASONALLY ADJUSTED" as is_seasonally_adjusted
        , "HOMES SOLD YOY (%)" as pct_homes_sold_yoy_change
        , "MEDIAN SALE PRICE NSA YOY (%)" as pct_median_sale_price_yoy_change
        , "MEDIAN DAYS ON MARKET YOY (DAYS)" as median_days_on_market_yoy_change
        , "NEW LISTINGS YOY (%)" as pct_new_listings_yoy_change
        , "ACTIVE LISTINGS YOY (%)" as pct_active_listings_yoy_change
        , "PENDING SALES YOY (%)" as pct_pending_sales_yoy_change
        , "MEDIAN NEW LISTING PRICE PER SQ.FT. YOY (%)" as pct_median_new_listing_price_per_square_foot_yoy_change
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
