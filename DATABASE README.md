BEGIN;
LOCK TABLE venues IN SHARE MODE;

SET LOCAL work_mem = '1536 MB';  -- just for this transaction

CREATE TABLE venues_new AS
SELECT uuid_generate_v1() AS tbl_uuid, <list of all columns in order>
FROM   venues
ORDER  BY city;  -- optional cluster table while being at it.

ALTER TABLE venues_new
 , ADD CONSTRAINT PRIMARY KEY (id)
 , ALTER COLUMN id SET NOT NULL
 , ALTER COLUMN id SET DEFAULT nextval('venues_id_seq'::regclass)
 , ALTER COLUMN created_at SET NOT NULL
 , ALTER COLUMN updated_at SET NOT NULL
 , ALTER COLUMN images SET DEFAULT '{}'::character varying[]
 , ALTER COLUMN data SET DEFAULT '{}'::json
 , ADD CONSTRAINT tbl_uuid_uni UNIQUE(tbl_uuid);

-- more constraints, indices, triggers?
CREATE INDEX ON venues_new USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));
CREATE INDEX ON venues_new USING btree (city);
CREATE INDEX ON venues_new USING btree (eventful_id);
CREATE INDEX ON venues_new USING btree (factual_id);
CREATE INDEX ON venues_new USING btree (latitude, longitude);
CREATE INDEX ON venues_new USING gist (lonlat);
CREATE INDEX ON venues_new USING btree (name);
CREATE INDEX ON venues_new USING btree (region);
CREATE INDEX ON venues_new USING btree (street_address);
CREATE INDEX ON venues_new USING btree (user_id);
CREATE INDEX ON venues_new USING btree (zip_code);
CREATE INDEX ON venues_new USING btree (lower((name)::text));

-- DROP TABLE tbl;
-- ALTER TABLE tbl_new RENAME tbl;

-- recreate views etc. if any

COMMIT;


BEGIN;
LOCK TABLE venues IN SHARE MODE;

SET LOCAL work_mem = '2048 MB';  -- just for this transaction

ALTER TABLE venues SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);

-- remove all indexes
ALTER TABLE venues DROP CONSTRAINT IF EXISTS venues_pkey;

DROP INDEX IF EXISTS index_on_venues_location;
DROP INDEX IF EXISTS index_venues_on_city;
DROP INDEX IF EXISTS index_venues_on_eventful_id;
DROP INDEX IF EXISTS index_venues_on_factual_id;
DROP INDEX IF EXISTS index_venues_on_latitude_and_longitude;
DROP INDEX IF EXISTS index_venues_on_lonlat;
DROP INDEX IF EXISTS index_venues_on_name;
DROP INDEX IF EXISTS index_venues_on_region;
DROP INDEX IF EXISTS index_venues_on_street_address;
DROP INDEX IF EXISTS index_venues_on_user_id;
DROP INDEX IF EXISTS index_venues_on_zip_code;
DROP INDEX IF EXISTS users_lower_name_key;

UPDATE venues SET lonlat = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography;

-- recreate all indexes
ALTER TABLE ONLY venues ADD CONSTRAINT venues_pkey PRIMARY KEY (id);

CREATE INDEX index_on_venues_location ON venues USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));
CREATE INDEX index_venues_on_city ON venues USING btree (city);
CREATE INDEX index_venues_on_eventful_id ON venues USING btree (eventful_id);
CREATE INDEX index_venues_on_factual_id ON venues USING btree (factual_id);
CREATE INDEX index_venues_on_latitude_and_longitude ON venues USING btree (latitude, longitude);
CREATE INDEX index_venues_on_lonlat ON venues USING gist (lonlat);
CREATE INDEX index_venues_on_name ON venues USING btree (name);
CREATE INDEX index_venues_on_region ON venues USING btree (region);
CREATE INDEX index_venues_on_street_address ON venues USING btree (street_address);
CREATE INDEX index_venues_on_user_id ON venues USING btree (user_id);
CREATE INDEX index_venues_on_zip_code ON venues USING btree (zip_code);
CREATE INDEX users_lower_name_key ON venues USING btree (lower((name)::text));

ALTER TABLE venues SET (autovacuum_enabled = true, toast.autovacuum_enabled = true);

COMMIT;

-----------------------------------------
-- manual insert for events
-----------------------------------------

BEGIN;
LOCK TABLE events IN SHARE MODE;

SET LOCAL work_mem = '2048 MB';  -- just for this transaction

ALTER TABLE events SET (autovacuum_enabled = false, toast.autovacuum_enabled = false);

-- remove all indexes
ALTER TABLE events DROP CONSTRAINT IF EXISTS events_pkey;

DROP INDEX IF EXISTS index_events_on_cached_votes_down;
DROP INDEX IF EXISTS index_events_on_cached_votes_score;
DROP INDEX IF EXISTS index_events_on_cached_votes_total;
DROP INDEX IF EXISTS index_events_on_cached_votes_up;
DROP INDEX IF EXISTS index_events_on_cached_weighted_average;
DROP INDEX IF EXISTS index_events_on_cached_weighted_score;
DROP INDEX IF EXISTS index_events_on_cached_weighted_total;
DROP INDEX IF EXISTS index_events_on_city_id;
DROP INDEX IF EXISTS index_events_on_eventful_id;
DROP INDEX IF EXISTS index_events_on_latitude_and_longitude;
DROP INDEX IF EXISTS index_events_on_lonlat;
DROP INDEX IF EXISTS index_events_on_user_id;
DROP INDEX IF EXISTS index_events_on_venue_id;
DROP INDEX IF EXISTS index_on_events_location;

ALTER TABLE events ADD timezone_parse_at timestamp without time zone;

-- recreate all indexes
ALTER TABLE ONLY events ADD CONSTRAINT events_pkey PRIMARY KEY (id);

CREATE INDEX index_events_on_cached_votes_down ON events USING btree (cached_votes_down);
CREATE INDEX index_events_on_cached_votes_score ON events USING btree (cached_votes_score);
CREATE INDEX index_events_on_cached_votes_total ON events USING btree (cached_votes_total);
CREATE INDEX index_events_on_cached_votes_up ON events USING btree (cached_votes_up);
CREATE INDEX index_events_on_cached_weighted_average ON events USING btree (cached_weighted_average);
CREATE INDEX index_events_on_cached_weighted_score ON events USING btree (cached_weighted_score);
CREATE INDEX index_events_on_cached_weighted_total ON events USING btree (cached_weighted_total);
CREATE INDEX index_events_on_city_id ON events USING btree (city_id);
CREATE INDEX index_events_on_eventful_id ON events USING btree (eventful_id);
CREATE INDEX index_events_on_latitude_and_longitude ON events USING btree (latitude, longitude);
CREATE INDEX index_events_on_lonlat ON events USING gist (lonlat);
CREATE INDEX index_events_on_user_id ON events USING btree (user_id);
CREATE INDEX index_events_on_venue_id ON events USING btree (venue_id);
CREATE INDEX index_on_events_location ON events USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


ALTER TABLE events SET (autovacuum_enabled = true, toast.autovacuum_enabled = true);

COMMIT;





-----------------------------------------

change
SET temp_buffers='1GB';
ALTER TABLE venues SET (
  autovacuum_enabled = false, toast.autovacuum_enabled = false
);

QUERIES WITH DISABLED VACUUM

reverse
SET temp_buffers='8MB';
ALTER TABLE venues SET (
  autovacuum_enabled = true, toast.autovacuum_enabled = true
);


---------------------------------------
Postpone auto analyze for large updates on venues

ALTER TABLE venues SET (autovacuum_analyze_threshold  = 2000000000);
ALTER TABLE events SET (autovacuum_analyze_threshold  = 2000000000);
ALTER TABLE posts SET (autovacuum_analyze_threshold  = 2000000000);

---------------------------------------------

ALTER TABLE venues SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE venues SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE venues SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE venues SET (autovacuum_analyze_threshold = 5000);

ALTER TABLE events SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE events SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE events SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE events SET (autovacuum_analyze_threshold = 5000);

ALTER TABLE posts SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE posts SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE posts SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE posts SET (autovacuum_analyze_threshold = 5000);


VACUUM ANALYZE venues;
VACUUM ANALYZE events;
VACUUM ANALYZE posts;

----------------------

select relname, last_vacuum,last_analyze from pg_stat_all_tables where schemaname='public';