{{
    config(materialized='table')
}}

with redfin_cte as (
    select
        *
    from
        {{ ref('stg_redfin_housing_market_tracker') }}
),

-- Type 1: keep the most recent name and type for each region
unique_regions_cte as (
    select
        region_id
        , arg_max(region_name, start_date) as region_name
        , arg_max(region_type, start_date) as region_type
    from
        redfin_cte
    group by
        region_id
),

unknown_region_cte as (
    select
        '-1' as dim_redfin_region_key
        , -1::bigint as region_id
        , 'Unknown' as region_name
        , 'Unknown' as region_type
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['region_id']) }} as dim_redfin_region_key
        , region_id
        , region_name
        , region_type
    from
        unique_regions_cte
    union all
    select
        dim_redfin_region_key
        , region_id
        , region_name
        , region_type
    from
        unknown_region_cte
)

select * from final_cte
