{{ config(materialized='table') }}

with base as (

    select
        snapshot_ts,
        gcs_url,
        ingested_at,

       parse_json(payload,wide_number_mode => 'round') as payload_json

    from {{ source('tfl_raw', 'snapshots') }}

),

snapshots as (

    select
        snapshot_ts,
        gcs_url,
        ingested_at,

        coalesce(
            json_query_array(payload_json, '$.data'),
            json_query_array(payload_json, '$')
        ) as stations

    from base

),

stations as (

    select
        snapshot_ts,
        gcs_url,
        ingested_at,
        station

    from snapshots,
    unnest(stations) as station

)

select
    snapshot_ts,
    gcs_url,
    ingested_at,

    json_value(station, '$.id') as station_id,
    json_value(station, '$.commonName') as station_name,

    safe_cast(json_value(station, '$.lat') as float64) as lat,
    safe_cast(json_value(station, '$.lon') as float64) as lon,

    safe_cast((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'NbBikes'
    ) as int64) as nb_bikes,

    safe_cast((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'NbEmptyDocks'
    ) as int64) as nb_empty_docks,

    safe_cast((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'NbDocks'
    ) as int64) as nb_docks,

    safe_cast((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'NbStandardBikes'
    ) as int64) as nb_standard_bikes,

    safe_cast((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'NbEBikes'
    ) as int64) as nb_ebikes,

    lower((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'Installed'
    )) = 'true' as installed,

    lower((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'Locked'
    )) = 'true' as locked,

    lower((
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'Temporary'
    )) = 'true' as temporary,

    (
        select any_value(json_value(p, '$.value'))
        from unnest(json_query_array(station, '$.additionalProperties')) p
        where json_value(p, '$.key') = 'TerminalName'
    ) as terminal_name

from stations