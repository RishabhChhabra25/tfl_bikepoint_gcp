select *
from {{ ref('tfl_trend') }}
where pct_stations_with_bikes_available < 0
   or pct_stations_with_bikes_available > 1
   or pct_stations_with_docks_available < 0
   or pct_stations_with_docks_available > 1
   or pct_empty_stations < 0
   or pct_empty_stations > 1
   or pct_full_stations < 0
   or pct_full_stations > 1
