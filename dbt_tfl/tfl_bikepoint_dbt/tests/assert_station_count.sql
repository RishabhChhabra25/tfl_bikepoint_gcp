select * from 
{{ ref('tfl_kpis') }}
where total_stations <=0
