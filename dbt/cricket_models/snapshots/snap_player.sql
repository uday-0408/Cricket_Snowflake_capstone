
{% snapshot player_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='player_id',
        strategy='check',
        check_cols=['batsman_icc_rating','bowler_icc_rating','contract_id',
                    'role','bowling_style']
    )
}}

SELECT * FROM {{ ref('dim_player') }}

{% endsnapshot %}
