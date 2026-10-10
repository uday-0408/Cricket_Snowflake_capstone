{{ config(materialized='table') }}

WITH date_spine AS (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('2000-01-01', 'YYYY-MM-DD')",
        end_date="to_date('2036-01-01', 'YYYY-MM-DD')"
    ) }}

)

SELECT
    TO_NUMBER(TO_CHAR(date_day, 'YYYYMMDD')) AS date_key,
    date_day,

    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month,
    MONTHNAME(date_day) AS month_name,

    DAY(date_day) AS day_of_month,
    DAYOFWEEKISO(date_day) AS day_of_week,
    DAYNAME(date_day) AS day_name,

    WEEKOFYEAR(date_day) AS week_of_year,

    DAYOFWEEKISO(date_day) IN (6, 7) AS is_weekend

FROM date_spine