with source as(
    select 
        *
    from
        {{ref('cricket_clean')}}
),
data as(
    select 
        delivery_id
        ,delivery_timestamp
        ,innings_no
        ,over_no
        ,ball_in_over
        ,runs_off_bat
        ,extra_type
        ,extra_runs
        ,total_runs
        ,is_wicket
        ,dismissal_type
        ,ball_speed_kmph
        ,non_striker_id
        ,shot_type
        ,shot_region
        ,match_id
        ,venue_id
        ,batting_team_id
        ,bowling_team_id
        ,batsman_id
        ,bowler_id
        ,drs_review_id
    from source

)
select * from  data