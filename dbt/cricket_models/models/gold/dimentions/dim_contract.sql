{{ config(
    materialized='incremental',
    schema='gold',
    unique_key='contract_id'
) }}
with source as(
    select 
        *
    from
        {{ ref('cricket_clean')}}
    {% if is_incremental() %}
    where
        delivery_timestamp >= (select max(delivery_timestamp) from {{ this }})
    {% endif %}
),
data as (
    select  
        contract_id
        ,contract_grade
        ,annual_retainer_usd
        ,contract_status
        ,delivery_timestamp
        ,md5(contract_status) as hkey
    from 
        source
    where delivery_timestamp is not null
),
scd2 as (
    select
        *,
        row_number() over(
            partition by contract_id,hkey
            order by delivery_timestamp desc
        ) as rn
    from data
    where delivery_timestamp is not null
),
latest as (
    select  
        *,
        row_number() over(
            partition by contract_id, rn 
            order by delivery_timestamp desc) as rn2
    from scd2
    where rn=1
        
),
final as (
    select 
        {# contract_id
        ,contract_grade
        ,annual_retainer_usd
        ,contract_status #}
        *
        ,case 
            when(rn2=1) then 1 ELSE 0
        END AS is_active
        , lead(delivery_timestamp) over(partition by contract_id, rn  order by rn) as velid_from,
        lag(delivery_timestamp) over(partition by contract_id, rn  order by rn) as velid_to
    from    
        latest
    {# where row_number=1 #}
)
select * from final