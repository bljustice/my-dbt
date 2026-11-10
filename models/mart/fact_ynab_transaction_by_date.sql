{{
    config(materialized='table')
}}

with registers_cte as (
    select * from {{ ref('stg_ynab_registers') }}
),

dim_date_cte as (
    select * from {{ ref('dim_date') }}
),

dim_ynab_account_cte as (
    select * from {{ ref('dim_ynab_account') }}
),

dim_ynab_category_cte as (
    select * from {{ ref('dim_ynab_category') }}
),

dim_ynab_transaction_status_cte as (
    select * from {{ ref('dim_ynab_transaction_status') }}
),

fact_cte as (
    select
        r.stg_ynab_registers_key
        , coalesce(dim_date_key, -1) as dim_date_key
        , coalesce(a.dim_ynab_account_key, '-1') as dim_ynab_account_key
        , coalesce(c.dim_ynab_category_key, '-1') as dim_ynab_category_key
        , coalesce(ts.dim_ynab_transaction_status_key, '-1') as dim_ynab_transaction_status_key
        , r.memo
        , r.outflow_usd
        , r.inflow_usd
    from
        registers_cte r
    left join
        dim_date_cte d
        using (date)
    left join
        dim_ynab_account_cte a
        using (account_name)
    left join
        dim_ynab_category_cte c
        using (category_name, category_group_name)
    left join
        dim_ynab_transaction_status_cte ts
        using (cleared_status, flag)
)

select * from fact_cte
