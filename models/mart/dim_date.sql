{{
    config(materialized='table')
}}

with spine_cte as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2015-01-01' as date)",
        end_date="cast('2031-01-01' as date)"
    ) }}
),

calendar_cte as (
    select
        date_day::date as full_date
    from
        spine_cte
),

enriched_cte as (
    select
        strftime(full_date, '%Y%m%d')::int as dim_date_key
        , full_date as date
        , extract(year from full_date) as year_number
        , extract(quarter from full_date) as quarter_number
        , extract(month from full_date) as month_number
        , extract(day from full_date) as day_of_month
        , extract(week from full_date) as week_of_year
        , extract(isodow from full_date) in (6,7) as is_weekend
        , dayname(full_date) as day_name
        , monthname(full_date) as month_name
        , date_trunc('month', full_date) as first_day_of_month
        , last_day(full_date) as last_day_of_month
    from
        calendar_cte
),

unknown_row_cte as (
    select
        -1 as dim_date_key
        , '1900-01-01'::date as date
        , null::int as year_number
        , null::int as quarter_number
        , null::int as month_number
        , null::int as day_of_month
        , null::int as week_of_year
        , false as is_weekend
        , 'Unknown' as day_name
        , 'Unknown' as month_name
        , '1900-01-01'::date as first_day_of_month
        , '1900-01-01'::date as last_day_of_month
),

final_cte as (
    select * from enriched_cte
    union all
    select * from unknown_row_cte
)

select * from final_cte