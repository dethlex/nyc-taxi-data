CREATE TABLE nyct2010_taxi_zones_mapping (
	nyct2010_gid int4 NULL,
	taxi_zone_location_id int2 NULL,
	overlap float8 NULL
)WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1
) DISTRIBUTED BY (nyct2010_gid);

insert into nyct2010_taxi_zones_mapping
SELECT
  ct.gid AS nyct2010_gid,
  tz.locationid AS taxi_zone_location_id,
  ST_Area(ST_Intersection(ct.geom, tz.geom)) / ST_Area(ct.geom) AS overlap
FROM nyct2010 ct, taxi_zones tz
WHERE ST_Intersects(ct.geom, tz.geom)
  AND ST_Area(ST_Intersection(ct.geom, tz.geom)) / ST_Area(ct.geom) > 0.5;
