select *
from {{ ref('tfl_current') }}
where nb_bikes < 0
   or nb_empty_docks < 0
   or nb_docks < 0
   or coalesce(nb_ebikes, 0) < 0
   or coalesce(nb_standard_bikes, 0) < 0
   or nb_bikes > nb_docks
   or nb_empty_docks > nb_docks
