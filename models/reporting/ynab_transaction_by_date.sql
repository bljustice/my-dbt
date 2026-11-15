{{
    config(materialized='view')
}}

select
    * exclude (
    dim_date_key,
    stg_ynab_registers_key,
    dim_ynab_account_key,
    dim_ynab_category_key,
    dim_ynab_transaction_status_key
)

from {{ ref('fact_ynab_transaction_by_date') }} f

join {{ ref('dim_date') }} d
    using (dim_date_key)

join {{ ref('dim_ynab_account') }} a
    using (dim_ynab_account_key)

join {{ ref('dim_ynab_category') }} c
    using (dim_ynab_category_key)

join {{ ref('dim_ynab_transaction_status') }} ts
    using (dim_ynab_transaction_status_key)