with source as(
    select 
        *
    from
        {{ ref('cricket_clean')}}
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
)
select * from data