with source as(
    select 
        *
    from
        {{ref('cricket_clean')}}
),
data as(
    select 
        batting_team_id as team_id,
        batting_team_name as team_name,
        match_date
    from
        source
),
deduplicate as (
    select 
        team_id,
        team_name
    from
        data
    qualify row_number() over(
        partition by team_id
        order by match_date
    )  = 1
)
select * from deduplicate