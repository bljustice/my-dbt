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
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['payee_name']) }} as dim_ynab_payee_key
        , *
    from
        unique_payees_cte
)

select * from final_cte