{{
    config(materialized='table')
}}

with source_cte as (
    select  
        *
    from
        {{ source('mart_sources', 'ynab_plans') }}
),

cleaned_cte as (
    select
        coalesce(strptime(month, '%b %Y'), '1900-01-01')::date as date
        , coalesce(category_group, 'Unknown') as category_group
        , coalesce(category, 'Unknown') as category
        , replace(assigned, '$', '')::numeric as assigned_amount_usd
        , replace(activity, '$', '')::numeric as activity_amount_usd
        , replace(available, '$', '')::numeric as available_amount_usd
    from
        source_cte
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['date', 'category_group', 'category']) }} as stg_ynab_plans_key
        , *
    from
        cleaned_cte
)

select * from final_cte