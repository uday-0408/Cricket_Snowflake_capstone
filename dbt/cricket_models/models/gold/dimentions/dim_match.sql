with source as(
    select 
        *
    from
        {{ ref('cricket_clean')}}
),
data as(
    select 
        match_id,
        {# match_date, #}
        TO_NUMBER(TO_CHAR(match_date, 'YYYYMMDD')) AS match_date_key,
        match_format,
        tournament_name,
        season,
        match_stage,
        toss_decision
    from
        source
    qualify row_number() 
                    over(
                        partition by match_id
                        order by match_date)=1 

)
select * from data