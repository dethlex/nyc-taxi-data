CREATE EXTENSION if not exists postgis;

CREATE TABLE green_tripdata_staging (
  id bigserial,
  vendor_id text,
  lpep_pickup_datetime text,
  lpep_dropoff_datetime text,
  store_and_fwd_flag text,
  rate_code_id text,
  pickup_longitude numeric,
  pickup_latitude numeric,
  dropoff_longitude numeric,
  dropoff_latitude numeric,
  passenger_count text,
  trip_distance text,
  fare_amount text,
  extra text,
  mta_tax text,
  tip_amount text,
  tolls_amount text,
  ehail_fee text,
  improvement_surcharge text,
  total_amount text,
  payment_type text,
  trip_type text,
  pickup_location_id text,
  dropoff_location_id text,
  congestion_surcharge text,
  junk1 text,
  junk2 text
)
WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1, autovacuum_enabled = false
) distributed by (id);
/*
N.B. junk columns are there because some tripdata file headers are
inconsistent with the actual data, e.g. header says 20 or 21 columns per row,
but data actually has 22 or 23 columns per row, which COPY doesn't like.
junk1 and junk2 should always be null
*/

CREATE TABLE yellow_tripdata_staging (
  id bigserial,
  vendor_id text,
  tpep_pickup_datetime text,
  tpep_dropoff_datetime text,
  passenger_count text,
  trip_distance text,
  pickup_longitude numeric,
  pickup_latitude numeric,
  rate_code_id text,
  store_and_fwd_flag text,
  dropoff_longitude numeric,
  dropoff_latitude numeric,
  payment_type text,
  fare_amount text,
  extra text,
  mta_tax text,
  tip_amount text,
  tolls_amount text,
  improvement_surcharge text,
  total_amount text,
  pickup_location_id text,
  dropoff_location_id text,
  congestion_surcharge text,
  junk1 text,
  junk2 text
)
WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1, autovacuum_enabled = false
) distributed by (id);

CREATE TABLE uber_trips_2014 (
  id serial,
  pickup_datetime timestamp without time zone,
  pickup_latitude numeric,
  pickup_longitude numeric,
  base_code text
) WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1
) distributed by (id);

CREATE TABLE fhv_trips_staging (
  dispatching_base_num text,
  pickup_datetime text,
  dropoff_datetime text,
  pickup_location_id text,
  dropoff_location_id text,
  shared_ride text,
  hvfhs_license_num text,
  junk text
)
WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1, autovacuum_enabled = false
) distributed replicated;

CREATE TABLE fhv_trips (
  id bigserial,
  dispatching_base_num text,
  pickup_datetime timestamp without time zone,
  dropoff_datetime timestamp without time zone,
  pickup_location_id integer,
  dropoff_location_id integer,
  shared_ride integer,
  hvfhs_license_num text
) WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1
) 
distributed by (id)
partition by range (pickup_datetime) (
start (date '2009-01-01') inclusive
end (date '2019-01-01') exclusive
every (interval '1 year'),
default partition default_p);

CREATE TABLE fhv_bases (
  base_number text,
  base_name text,
  dba text,
  dba_category text
) WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1
) distributed by (base_number);

CREATE TABLE hvfhs_licenses (
  license_number text primary key,
  company_name text
) distributed replicated;

INSERT INTO hvfhs_licenses
VALUES ('HV0002', 'juno'),
       ('HV0003', 'uber'),
       ('HV0004', 'via'),
       ('HV0005', 'lyft');

CREATE TABLE cab_types (
  id serial primary key,
  type text
) distributed replicated;

INSERT INTO cab_types (type) VALUES ('yellow'), ('green');

CREATE TABLE trips (
  id bigserial,
  cab_type_id integer,
  vendor_id text,
  pickup_datetime timestamp without time zone,
  dropoff_datetime timestamp without time zone,
  store_and_fwd_flag text,
  rate_code_id integer,
  pickup_longitude numeric,
  pickup_latitude numeric,
  dropoff_longitude numeric,
  dropoff_latitude numeric,
  passenger_count integer,
  trip_distance numeric,
  fare_amount numeric,
  extra numeric,
  mta_tax numeric,
  tip_amount numeric,
  tolls_amount numeric,
  ehail_fee numeric,
  improvement_surcharge numeric,
  congestion_surcharge numeric,
  total_amount numeric,
  payment_type text,
  trip_type integer,
  pickup_nyct2010_gid integer,
  dropoff_nyct2010_gid integer,
  pickup_location_id integer,
  dropoff_location_id integer
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=1)
distributed by (id)
partition by range (pickup_datetime) (
start (date '2009-01-01') inclusive
end (date '2019-01-01') exclusive
every (interval '1 year'),
default partition default_p);

CREATE TABLE central_park_weather_observations (
  station_id text,
  station_name text,
  date date primary key,
  precipitation numeric,
  snow_depth numeric,
  snowfall numeric,
  max_temperature numeric,
  min_temperature numeric,
  average_wind_speed numeric
) distributed replicated;

CREATE TABLE nyct2010 (
  gid serial NOT NULL,
  ctlabel varchar(7) NULL,
  borocode varchar(1) NULL,
  boroname varchar(32) NULL,
  ct2010 varchar(6) NULL,
  boroct2010 varchar(7) NULL,
  cdeligibil varchar(1) NULL,
  ntacode varchar(4) NULL,
  ntaname varchar(75) NULL,
  puma varchar(4) NULL,
  shape_leng numeric NULL,
  shape_area numeric NULL,
  geom geometry(MULTIPOLYGON, 4326) NULL
) WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1
) DISTRIBUTED BY (gid);

CREATE TABLE taxi_zones (
  gid serial NOT NULL,
  objectid int4 NULL,
  shape_leng numeric NULL,
  shape_area numeric NULL,
  "zone" varchar(254) NULL,
  locationid int2 NULL,
  borough varchar(254) NULL,
  geom geometry(MULTIPOLYGON, 4326) NULL
) WITH (
  appendonly=true, orientation=column, compresstype=zstd, compresslevel=1
) DISTRIBUTED BY (gid);