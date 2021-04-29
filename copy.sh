#!/bin/bash

scp initialize_database.sh import_trip_data.sh import_fhv_trip_data.sh hs-gauss:/home/gpadmin/nyc-taxi-data/
scp setup_files/create_nyc_taxi_schema.sql setup_files/populate_2014_uber_trips.sql setup_files/add_tract_to_zone_mapping.sql hs-gauss:/home/gpadmin/nyc-taxi-data/setup_files/
