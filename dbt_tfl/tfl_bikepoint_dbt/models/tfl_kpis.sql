{{ config(materialized = 'view') }}

select 
    count(*) as total_stations,
    max(snapshot_ts) as latest_refresh_ts,

    safe_divide(countif(nb_empty_docks>0),
                count(*)
                ) as pct_stations_with_docks_available,

    safe_divide(countif(nb_bikes>0),
                count(*)
                ) as pct_stations_with_bikes_available,
    countif(nb_bikes=0) as empty_stations_now, 
    countif(nb_empty_docks =0) as full_stations_now,
    sum(coalesce(nb_ebikes,0)) as total_ebikes_now,
    avg(coalesce(nb_bikes,0)) as avg_bikes_per_station

    from {{ ref('tfl_current') }}

    where station_id is not null
    and snapshot_ts is not null