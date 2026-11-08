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
        , coalesce(category_group, 'Unknown') as category_group_name
        , coalesce(category, 'Unknown') as category_name
        , coalesce(flag, 'Unknown') as flag
        , coalesce(case 
            when regexp_matches(payee, '^[★\*\\s\\.-]+$') then 'Unknown'
            else payee
            end 
            , 'Unknown') as payee_name
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
        , category_group_name
        , category_name
        , flag
        , payee_name
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
        {{ dbt_utils.generate_surrogate_key(["date", "account_name", "category_group_name", "category_name", "payee_name", "memo", "cleared"]) }} as stg_ynab_registers_key
        , *
    from
        agg_cte
)

select * from final_cte