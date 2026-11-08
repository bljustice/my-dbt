{{
    config(materialized='table')
}}

with source_cte as (
    select
        *
    from
        {{ source('mart_sources', 'ynab_registers') }}
),

cleaned_cte as (
    select
        coalesce(date, '1900-01-01')::date as date
        , coalesce(account, 'Unknown') as account_name
        , coalesce(category_group, 'Unknown') as category_group
        , coalesce(category, 'Unknown') as category
        , coalesce(flag, 'Unknown') as flag
        , coalesce(payee, 'Unknown') as payee
        , coalesce(memo, 'Unknown') as memo
        , coalesce(cleared, 'Unknown') as cleared
        , replace(inflow, '$', '')::numeric as inflow_usd
        , replace(outflow, '$', '')::numeric as outflow_usd
    from
        source_cte
),

agg_cte as (
    select
        date
        , account_name
        , category_group
        , category
        , flag
        , payee
        , memo
        , cleared
        , sum(inflow_usd) as inflow_usd
        , sum(outflow_usd) as outflow_usd
    from
        cleaned_cte
    group by all
),

final_cte as (
    select 
        {{ dbt_utils.generate_surrogate_key(["date", "account_name", "category_group", "category", "payee", "memo", "cleared"]) }} as stg_ynab_registers_key
        , *
    from
        agg_cte
)

select * from final_cte