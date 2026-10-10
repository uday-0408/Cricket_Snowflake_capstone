
{% snapshot contract_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='contract_id',
        strategy='check',
        check_cols=['contract_grade','annual_retainer_usd','contract_status']
    )
}}

SELECT * FROM {{ ref('dim_contract') }}

{% endsnapshot %}
