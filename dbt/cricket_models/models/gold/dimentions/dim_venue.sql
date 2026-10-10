with source as(
    select 
        *
    from
        {{ ref('cricket_clean')}}
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