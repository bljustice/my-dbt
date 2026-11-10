{{
    config(materialized='table')
}}

with registers_cte as (
    select
        *
    from 
        {{ ref('stg_ynab_registers') }}
    where
        not (cleared_status = 'Unknown' and flag = 'Unknown')
),

unique_pairings_cte as (
    select
        distinct cleared_status
        , flag
    from
        registers_cte
),

unknown_pairing_cte as (
    select
        '-1' as dim_ynab_transaction_status_key
        , 'Unknown' as cleared_status
        , 'Unknown' as flag
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['cleared_status', 'flag']) }} as dim_ynab_transaction_status_key
        , cleared_status
        , flag
    from
        unique_pairings_cte
    union all
    select
        dim_ynab_transaction_status_key
        , cleared_status
        , flag
    from
        unknown_pairing_cte
)

select * from final_cte