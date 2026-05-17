{{ config(materialized='view') }}

with ranked as (

    select
        snapshot_ts,
        gcs_url,
        ingested_at,
        station_id,
        station_name,
        lat,
        lon,
        nb_bikes,
        nb_empty_docks,
        nb_docks,
        nb_standard_bikes,
        nb_ebikes,
        installed,
        locked,
        temporary,
        terminal_name,

        row_number() over (
            partition by station_id
            order by snapshot_ts desc, ingested_at desc
        ) as row_num

    from {{ ref('tfl_flatten') }}

)

select
    snapshot_ts,
    gcs_url,
    ingested_at,
    station_id,
    station_name,
    lat,
    lon,
    nb_bikes,
    nb_empty_docks,
    nb_docks,
    nb_standard_bikes,
    nb_ebikes,
    installed,
    locked,
    temporary,
    terminal_name,

    timestamp_diff(current_timestamp(), snapshot_ts, minute) as freshness_minutes

from ranked

where row_num = 1