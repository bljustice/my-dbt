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
    where account_name != 'Unknown'
),

unknown_account_cte as (
    select
        '-1' as dim_ynab_account_key
        , 'Unknown' as account_name
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['account_name']) }} as dim_ynab_account_key
        , account_name
    from
        unique_accounts_cte
    union
    select
        dim_ynab_account_key
        , account_name
    from
        unknown_account_cte
)

select * from final_cte