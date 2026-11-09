{{
    config(materialized='table')
}}

with register_cte as (
    select 
        *
    from 
        {{ ref('stg_ynab_registers') }}
),

unique_category_cte as (
    select
        distinct category_name
        , category_group_name
    from
        register_cte
    where 
        (category_name != 'Unknown' and category_group_name != 'Unknown')
),

unknown_row_cte as (
    select
        '-1' as dim_ynab_category_key
        , 'Unknown' as category_name
        , 'Unknown' as category_group_name
),

final_cte as (
    select
        {{ dbt_utils.generate_surrogate_key(['category_name', 'category_group_name']) }} as dim_ynab_category_key
        , category_name
        , category_group_name
    from
        unique_category_cte
    union 
    select
        dim_ynab_category_key
        , category_name
        , category_group_name
    from
        unknown_row_cte
)

select * from final_cte