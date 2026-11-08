{{
    config(materialized='table')
}}

with registers_cte as (
    select
        *
    from
        {{ ref('stg_ynab_registers') }}
),

unique_accounts_cte as (
    select
        distinct account_name
    from
        registers_cte
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['account_name']) }} as dim_ynab_account_key
        , account_name
    from
        unique_accounts_cte
)

select * from final_cte