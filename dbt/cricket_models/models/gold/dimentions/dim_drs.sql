{{ config(
    materialized='incremental',
    schema='gold',
    unique_key=['drs_review_id']
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
        drs_review_id
        ,drs_reviewed_by
        ,drs_original_decision
        ,drs_outcome
    from source 
    where
        drs_review_id is not null
    qualify row_number() over(
                            partition by drs_review_id
                            order by delivery_timestamp desc)=1
)
select * from data