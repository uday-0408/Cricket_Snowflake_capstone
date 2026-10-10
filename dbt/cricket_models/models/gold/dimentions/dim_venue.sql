{{ config(
    materialized='incremental',
    schema='gold',
    unique_key='venue_id'
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
data as(
    select 
        venue_id,
        venue_name,
        venue_city,
        venue_country
    from
        source
    qualify row_number() 
                    over(
                        partition by venue_id
                        order by venue_name)=1 

)
select * from data