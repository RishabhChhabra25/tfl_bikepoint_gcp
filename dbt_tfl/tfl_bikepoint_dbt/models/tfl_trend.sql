{{ config(materialized = 'view') }}

with base as (
    select 
    station_id,
    station_name,
    snapshot_ts,
    nb_bikes,
    nb_empty_docks,
    nb_docks,
    nb_ebikes

    from {{ ref('tfl_flatten') }}
    where snapshot_ts is not null
),

hourly as (
     select
        timestamp_trunc(snapshot_ts, hour) as snapshot_hour,

        count(distinct station_id) as total_stations,

        countif(nb_bikes > 0) as stations_with_bikes_available,
        countif(nb_bikes = 0) as empty_stations,

        countif(nb_empty_docks > 0) as stations_with_docks_available,
        countif(nb_empty_docks = 0) as full_stations,

        sum(coalesce(nb_bikes, 0)) as total_bikes_available,
        sum(coalesce(nb_empty_docks, 0)) as total_empty_docks_available,
        sum(coalesce(nb_ebikes, 0)) as total_ebikes_available,

        avg(coalesce(nb_bikes, 0)) as avg_bikes_per_station,
        avg(coalesce(nb_empty_docks, 0)) as avg_empty_docks_per_station,

        safe_divide(
            countif(nb_bikes > 0),
            count(distinct station_id)
        ) as pct_stations_with_bikes_available,

        safe_divide(
            countif(nb_empty_docks > 0),
            count(distinct station_id)
        ) as pct_stations_with_docks_available,

        safe_divide(
            countif(nb_bikes = 0),
            count(distinct station_id)
        ) as pct_empty_stations,

        safe_divide(
            countif(nb_empty_docks = 0),
            count(distinct station_id)
        ) as pct_full_stations

    from base
    group by 1

)

select *
from hourly
order by snapshot_hour desc
