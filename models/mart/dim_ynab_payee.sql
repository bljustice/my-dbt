{{
    config(materialized='table')
}}

with register_cte as (
    select
        *
    from 
        {{ ref('stg_ynab_registers') }}
),

unique_payees_cte as (
    select
        distinct payee_name
    from
        register_cte
    where
        payee_name != 'Unknown'
),

unknown_payee_cte as (
    select
        '-1' as dim_ynab_payee_key
        , 'Unknown' as payee_name
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['payee_name']) }} as dim_ynab_payee_key
        , payee_name
    from
        unique_payees_cte
    union
    select
        dim_ynab_payee_key
        , payee_name
    from
        unknown_payee_cte
)

select * from final_cte