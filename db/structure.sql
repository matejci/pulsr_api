--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: event_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE event_kind AS ENUM (
    'public',
    'private'
);


--
-- Name: count(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count() RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      DECLARE result integer;
      BEGIN
          result := COUNT(*) FROM venues_1;

          RETURN result;
      END;
      $$;


--
-- Name: counting(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION counting() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        venues CURSOR FOR SELECT * FROM venues_9;
        result integer := 0;
      BEGIN
        FOR venue IN venues LOOP
          DECLARE
            row_id venues.id%TYPE;
            category_id categories.id%TYPE;
          BEGIN
            -- RAISE NOTICE 'FACTUAL ID %', venue.factual_id;

            INSERT INTO venues(factual_id,name,street_address,city,zip_code,country,telephone_number,latitude,longitude,url,email,hours,cuisine,created_at,updated_at,short_factual_id,created_by) VALUES (
                            quote_nullable(venue.factual_id),
                            quote_nullable(venue.name),
                            quote_nullable(venue.street_address),
                            quote_nullable(venue.city),
                            quote_nullable(venue.zip_code),
                            quote_nullable(venue.country),
                            quote_nullable(venue.telephone_number),
                            venue.latitude,
                            venue.longitude,
                            quote_nullable(venue.url),
                            quote_nullable(venue.email),
                            venue.hours,
                            venue.cuisine,
                            current_date,
                            current_date,
                            quote_nullable(venue.short_factual_id),
                            'factual'
                            ) RETURNING id INTO row_id;

            -- RAISE NOTICE '%', row_id;
            IF venue.category_ids IS NOT NULL THEN
              FOR category_id IN SELECT * FROM json_array_elements(venue.category_ids)
              LOOP
                INSERT INTO categories_venues (category_id, venue_id, created_at, updated_at)
                VALUES (category_id, row_id, current_date, current_date);
              END LOOP;
            END IF;

          END;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: diff_update_factual_venue_1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION diff_update_factual_venue_1() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        venue venues_diff_1%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR venue IN SELECT * FROM venues_diff_1 LOOP
          CASE venue.delta
          WHEN 'INSERT' THEN
            PERFORM diff_insert_factual_venue_1(venue);
          WHEN 'UPDATE' THEN
            PERFORM diff_update_factual_venue_1(venue);
          WHEN 'DEPRECATE' THEN
            PERFORM diff_merge_factual_venue_1(venue);
          WHEN 'DELETE' THEN
            PERFORM diff_delete_factual_venue_1(venue);
          END CASE;
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: import_process_1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION import_process_1() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        venue venues_1%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR venue IN SELECT * FROM venues_1 LOOP
          PERFORM insert_factual_venue_1(venue);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_1() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_1%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_1 LOOP
          PERFORM insert_instagram_place_1(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_10(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_10() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_10%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_10 LOOP
          PERFORM insert_instagram_place_10(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_11(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_11() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_11%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_11 LOOP
          PERFORM insert_instagram_place_11(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_12(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_12() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_12%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_12 LOOP
          PERFORM insert_instagram_place_12(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_13(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_13() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_13%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_13 LOOP
          PERFORM insert_instagram_place_13(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_14(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_14() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_14%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_14 LOOP
          PERFORM insert_instagram_place_14(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_15(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_15() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_15%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_15 LOOP
          PERFORM insert_instagram_place_15(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_16(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_16() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_16%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_16 LOOP
          PERFORM insert_instagram_place_16(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_17(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_17() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_17%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_17 LOOP
          PERFORM insert_instagram_place_17(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_18(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_18() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_18%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_18 LOOP
          PERFORM insert_instagram_place_18(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_19(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_19() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_19%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_19 LOOP
          PERFORM insert_instagram_place_19(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_2(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_2%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_2 LOOP
          PERFORM insert_instagram_place_2(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_20(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_20() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_20%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_20 LOOP
          PERFORM insert_instagram_place_20(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_21(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_21() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_21%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_21 LOOP
          PERFORM insert_instagram_place_21(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_22(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_22() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_22%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_22 LOOP
          PERFORM insert_instagram_place_22(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_23(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_23() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_23%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_23 LOOP
          PERFORM insert_instagram_place_23(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_3(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_3() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_3%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_3 LOOP
          PERFORM insert_instagram_place_3(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_4(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_4() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_4%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_4 LOOP
          PERFORM insert_instagram_place_4(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_5(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_5() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_5%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_5 LOOP
          PERFORM insert_instagram_place_5(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_6(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_6() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_6%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_6 LOOP
          PERFORM insert_instagram_place_6(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_7(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_7() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_7%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_7 LOOP
          PERFORM insert_instagram_place_7(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_8(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_8() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_8%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_8 LOOP
          PERFORM insert_instagram_place_8(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: instagram_import_9(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION instagram_import_9() RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        place instagram_import_9%ROWTYPE;
        result integer := 0;
      BEGIN
        FOR place IN SELECT * FROM instagram_import_9 LOOP
          PERFORM insert_instagram_place_9(place);
          result := result + 1;
        END LOOP;

        RETURN result;
      END;
      $$;


--
-- Name: truncate_tables(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION truncate_tables(username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE tableowner = username AND schemaname = 'public';
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
    END LOOP;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authentication_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authentication_tokens (
    id integer NOT NULL,
    token character varying,
    user_id integer,
    revoked boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentication_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authentication_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentication_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authentication_tokens_id_seq OWNED BY authentication_tokens.id;


--
-- Name: authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authentications (
    id integer NOT NULL,
    token character varying,
    user_id integer,
    revoked boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authentications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authentications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authentications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authentications_id_seq OWNED BY authentications.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id integer
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: categories_tastes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories_tastes (
    taste_id integer,
    category_id integer
);


--
-- Name: categories_venues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories_venues (
    category_id integer,
    venue_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    zone_id integer
);


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    radius double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    boundaries json,
    location point,
    timezone character varying,
    data jsonb DEFAULT '{}'::jsonb
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_id_seq OWNED BY cities.id;


--
-- Name: contact_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contact_books (
    id integer NOT NULL,
    user_id integer,
    contacts_cache json DEFAULT '[]'::json,
    last_query timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    device_lists json DEFAULT '{}'::json,
    initial_at timestamp without time zone
);


--
-- Name: contact_books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_books_id_seq OWNED BY contact_books.id;


--
-- Name: contact_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contact_values (
    id integer NOT NULL,
    value character varying,
    value_type integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    kind character varying
);


--
-- Name: contact_values_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contact_values_contacts (
    contact_id integer,
    contact_value_id integer
);


--
-- Name: contact_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_values_id_seq OWNED BY contact_values.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contacts (
    id integer NOT NULL,
    user_id integer,
    contact_user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_book_id integer,
    contact_added_at timestamp without time zone,
    first_name character varying,
    last_name character varying,
    hash_key character varying
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE devices (
    id integer NOT NULL,
    user_id integer,
    token character varying,
    enabled boolean,
    platform character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id integer NOT NULL,
    eventful_id character varying,
    eventful_url character varying,
    name character varying,
    description text,
    time_zone character varying,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    all_day boolean,
    free boolean,
    eventful_venue_id character varying,
    links json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    venue_id integer,
    city_id integer,
    data json,
    images character varying[] DEFAULT '{}'::character varying[],
    title text,
    twitter_username character varying,
    hashtag character varying,
    url character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    created_by character varying,
    latest_timetable_at timestamp without time zone,
    location point,
    cached_votes_total integer DEFAULT 0,
    cached_votes_score integer DEFAULT 0,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    cached_weighted_score integer DEFAULT 0,
    cached_weighted_total integer DEFAULT 0,
    cached_weighted_average double precision DEFAULT 0.0,
    lonlat geography(Point,4326),
    user_id integer,
    kind event_kind DEFAULT 'public'::event_kind,
    friends_can_invite boolean,
    photo_processed_at timestamp without time zone,
    timezone_parse_at timestamp without time zone,
    zone_id integer,
    zoned_at timestamp without time zone
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: events_performers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events_performers (
    event_id integer,
    performer_id integer
);


--
-- Name: failures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE failures (
    id integer NOT NULL,
    name character varying,
    data json,
    error character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: failures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE failures_id_seq OWNED BY failures.id;


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE flags (
    id integer NOT NULL,
    user_id integer,
    flaggable_id integer,
    flaggable_type character varying,
    data jsonb DEFAULT '{}'::jsonb,
    latitude numeric,
    longitude numeric,
    lonlat geography(Point,4326),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE flags_id_seq OWNED BY flags.id;


--
-- Name: friend_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friend_actions (
    id integer NOT NULL,
    object_id integer,
    object_type character varying,
    user_id integer,
    invitation_date date,
    action integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: friend_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friend_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friend_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friend_actions_id_seq OWNED BY friend_actions.id;


--
-- Name: friend_recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friend_recommendations (
    id integer NOT NULL,
    user_id integer,
    contact_id integer,
    reason integer,
    action integer,
    status integer,
    status_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: friend_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friend_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friend_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friend_recommendations_id_seq OWNED BY friend_recommendations.id;


--
-- Name: friendships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE friendships (
    id integer NOT NULL,
    sender_id integer,
    recipient_id integer,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    branch_url character varying,
    invite_token character varying
);


--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendships_id_seq OWNED BY friendships.id;


--
-- Name: hashtags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hashtags (
    id integer NOT NULL,
    name character varying,
    city_name character varying,
    period integer,
    counter integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_username boolean
);


--
-- Name: hashtags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hashtags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hashtags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hashtags_id_seq OWNED BY hashtags.id;


--
-- Name: instagram_places; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE instagram_places (
    id integer NOT NULL,
    venue_id integer,
    name character varying,
    factual_id character varying,
    place_id integer
);


--
-- Name: instagram_places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instagram_places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instagram_places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instagram_places_id_seq OWNED BY instagram_places.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE invitations (
    id integer NOT NULL,
    invitable_id integer,
    invitable_type character varying,
    user_id integer,
    sender_id integer,
    message text,
    invite_at timestamp without time zone,
    rsvp character varying,
    invitation_key character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    branch_url character varying,
    invite_token character varying
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invitations_id_seq OWNED BY invitations.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notifications (
    id integer NOT NULL,
    object_id integer,
    object_type character varying,
    user_id integer,
    reason integer,
    status integer,
    action integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data jsonb DEFAULT '{}'::jsonb
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: performers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE performers (
    id integer NOT NULL,
    eventful_id character varying,
    eventful_url character varying,
    name character varying,
    short_bio text,
    long_bio text,
    links json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    images character varying[] DEFAULT '{}'::character varying[],
    processed_at timestamp without time zone,
    twitter character varying,
    data json DEFAULT '{}'::json,
    url character varying,
    created_by character varying,
    instagram character varying,
    user_id integer
);


--
-- Name: performers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE performers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: performers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE performers_id_seq OWNED BY performers.id;


--
-- Name: photo_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE photo_objects (
    id integer NOT NULL,
    object_id integer,
    object_type character varying,
    photo_id integer,
    source character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: photo_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE photo_objects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photo_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE photo_objects_id_seq OWNED BY photo_objects.id;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE photos (
    id integer NOT NULL,
    url character varying,
    data json DEFAULT '{}'::json,
    venue_id integer,
    instagram_place_id integer,
    service character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instagram_id character varying,
    kind integer,
    video_url character varying,
    caption text,
    event integer,
    performer integer,
    meta_data jsonb DEFAULT '{}'::jsonb,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    user_id integer,
    latitude numeric,
    longitude numeric,
    lonlat geography(Point,4326),
    tweet_id integer
);


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE photos_id_seq OWNED BY photos.id;


--
-- Name: places; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE places (
    id integer NOT NULL,
    street_address character varying,
    postal_code character varying,
    address_locality character varying,
    address_region character varying,
    location_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    latitude numeric(10,6),
    longitude numeric(10,6),
    lonlat geography(Point,4326),
    venue_name character varying,
    venue_id integer
);


--
-- Name: places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE places_id_seq OWNED BY places.id;


--
-- Name: point_of_interests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE point_of_interests (
    id integer NOT NULL,
    name character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    taste_data jsonb,
    data jsonb,
    starts_at timestamp without time zone,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    object_id integer,
    object_type character varying,
    lonlat geography(Point,4326),
    street_address character varying,
    city character varying,
    region character varying,
    zip_code character varying,
    country character varying,
    opening_hours json,
    photo json,
    venue_name character varying,
    zone_id integer,
    public boolean,
    weight integer DEFAULT 0
);


--
-- Name: point_of_interests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE point_of_interests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: point_of_interests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE point_of_interests_id_seq OWNED BY point_of_interests.id;


--
-- Name: post_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_types_id_seq OWNED BY post_types.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE posts (
    id integer NOT NULL,
    body text,
    user_id integer,
    photo_id integer,
    item_id integer,
    item_type character varying,
    post_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    latitude numeric,
    longitude numeric,
    lonlat geography(Point,4326),
    source_id integer,
    source_type character varying,
    is_private boolean DEFAULT false,
    cached_votes_total integer DEFAULT 0,
    cached_votes_score integer DEFAULT 0,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    cached_weighted_score integer DEFAULT 0,
    cached_weighted_total integer DEFAULT 0,
    cached_weighted_average double precision DEFAULT 0.0,
    remarks text,
    place_id integer,
    instagram_image_url character varying
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: rpush_apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rpush_apps (
    id integer NOT NULL,
    name character varying NOT NULL,
    environment character varying,
    certificate text,
    password character varying,
    connections integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying NOT NULL,
    auth_key character varying,
    client_id character varying,
    client_secret character varying,
    access_token character varying,
    access_token_expiration timestamp without time zone
);


--
-- Name: rpush_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rpush_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rpush_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rpush_apps_id_seq OWNED BY rpush_apps.id;


--
-- Name: rpush_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rpush_feedback (
    id integer NOT NULL,
    device_token character varying(64) NOT NULL,
    failed_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    app_id integer
);


--
-- Name: rpush_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rpush_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rpush_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rpush_feedback_id_seq OWNED BY rpush_feedback.id;


--
-- Name: rpush_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rpush_notifications (
    id integer NOT NULL,
    badge integer,
    device_token character varying(64),
    sound character varying DEFAULT 'default'::character varying,
    alert character varying,
    data text,
    expiry integer DEFAULT 86400,
    delivered boolean DEFAULT false NOT NULL,
    delivered_at timestamp without time zone,
    failed boolean DEFAULT false NOT NULL,
    failed_at timestamp without time zone,
    error_code integer,
    error_description text,
    deliver_after timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    alert_is_json boolean DEFAULT false,
    type character varying NOT NULL,
    collapse_key character varying,
    delay_while_idle boolean DEFAULT false NOT NULL,
    registration_ids text,
    app_id integer NOT NULL,
    retries integer DEFAULT 0,
    uri character varying,
    fail_after timestamp without time zone,
    processing boolean DEFAULT false NOT NULL,
    priority integer,
    url_args text,
    category character varying
);


--
-- Name: rpush_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rpush_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rpush_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rpush_notifications_id_seq OWNED BY rpush_notifications.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: t_row; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE t_row (
    id integer,
    eventful_id character varying,
    eventful_url character varying,
    name character varying,
    description text,
    category character varying,
    street_address character varying,
    city character varying,
    region character varying,
    zip_code character varying,
    country character varying,
    time_zone character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    images character varying[],
    telephone_number character varying,
    links json,
    email character varying,
    cuisine json,
    hours json,
    factual_id character varying,
    short_factual_id character varying,
    created_by character varying,
    factual_rating numeric,
    factual_price numeric,
    processed_at timestamp without time zone,
    twitter character varying,
    data json,
    url character varying,
    factual_existence numeric,
    pending_at timestamp without time zone
);


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE taggings (
    id integer NOT NULL,
    taggable_id integer,
    taggable_type character varying,
    tag_id integer,
    source character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    zone_id integer
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hidden boolean DEFAULT false
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tags_tastes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags_tastes (
    taste_id integer,
    tag_id integer
);


--
-- Name: taste_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE taste_categories (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taste_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taste_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taste_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taste_categories_id_seq OWNED BY taste_categories.id;


--
-- Name: tastes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tastes (
    id integer NOT NULL,
    name character varying,
    taste_category_id integer,
    description text,
    example text,
    title character varying,
    import_string character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_photo_file_name character varying,
    profile_photo_content_type character varying,
    profile_photo_file_size integer,
    profile_photo_updated_at timestamp without time zone
);


--
-- Name: tastes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tastes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tastes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tastes_id_seq OWNED BY tastes.id;


--
-- Name: timetables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE timetables (
    id integer NOT NULL,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: timetables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE timetables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timetables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE timetables_id_seq OWNED BY timetables.id;


--
-- Name: tweet_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tweet_activities (
    id integer NOT NULL,
    counter integer,
    latitude numeric(10,6),
    longitude numeric(10,6),
    farthest_item json,
    level integer,
    boundaries json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    period integer,
    location point
);


--
-- Name: tweet_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tweet_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tweet_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tweet_activities_id_seq OWNED BY tweet_activities.id;


--
-- Name: tweets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tweets (
    id integer NOT NULL,
    data json,
    latitude numeric(10,6),
    longitude numeric(10,6),
    text text,
    city_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    location point,
    venue_name character varying
);


--
-- Name: tweets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tweets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tweets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tweets_id_seq OWNED BY tweets.id;


--
-- Name: user_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_actions (
    id integer NOT NULL,
    object_id integer,
    object_type character varying,
    user_id integer,
    action character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    starts_at timestamp without time zone
);


--
-- Name: user_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_actions_id_seq OWNED BY user_actions.id;


--
-- Name: user_tastes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_tastes (
    id integer NOT NULL,
    user_id integer,
    taste_id integer,
    score double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_tastes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_tastes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_tastes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_tastes_id_seq OWNED BY user_tastes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_name character varying,
    last_name character varying,
    middle_name character varying,
    facebook_id character varying,
    facebook_token character varying,
    phone_number character varying,
    send_notifications boolean,
    preferences json DEFAULT '{}'::json,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    hometown_latitude numeric(10,6),
    hometown_longitude numeric(10,6),
    hometown_location point,
    active boolean DEFAULT true,
    temp_phone_number character varying,
    phone_number_token character varying,
    phone_number_sent_at timestamp without time zone,
    reported_posts text[] DEFAULT '{}'::text[],
    blocked_users text[] DEFAULT '{}'::text[],
    admin boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE venues (
    id integer NOT NULL,
    eventful_id character varying,
    eventful_url character varying,
    name character varying,
    description text,
    category character varying,
    street_address character varying,
    city character varying,
    region character varying,
    zip_code character varying,
    country character varying,
    time_zone character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    images character varying[] DEFAULT '{}'::character varying[],
    telephone_number character varying,
    links json,
    email character varying,
    cuisine json,
    hours jsonb,
    factual_id character varying,
    short_factual_id character varying,
    created_by character varying,
    factual_rating numeric,
    factual_price numeric,
    processed_at timestamp without time zone,
    twitter character varying,
    data json DEFAULT '{}'::json,
    url character varying,
    factual_existence numeric,
    pending_at timestamp without time zone,
    instagram_at timestamp without time zone,
    location point,
    lonlat geography(Point,4326),
    user_id integer,
    datanew jsonb DEFAULT '{}'::jsonb NOT NULL,
    city_id integer,
    cached_votes_total integer DEFAULT 0,
    cached_votes_score integer DEFAULT 0,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    cached_weighted_score integer DEFAULT 0,
    cached_weighted_total integer DEFAULT 0,
    cached_weighted_average double precision DEFAULT 0.0,
    zone_id integer,
    zoned_at timestamp without time zone
);


--
-- Name: venues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE venues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE venues_id_seq OWNED BY venues.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE votes (
    id integer NOT NULL,
    votable_id integer,
    votable_type character varying,
    voter_id integer,
    voter_type character varying,
    vote_flag boolean,
    vote_scope character varying,
    vote_weight integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentication_tokens ALTER COLUMN id SET DEFAULT nextval('authentication_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications ALTER COLUMN id SET DEFAULT nextval('authentications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities ALTER COLUMN id SET DEFAULT nextval('cities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_books ALTER COLUMN id SET DEFAULT nextval('contact_books_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_values ALTER COLUMN id SET DEFAULT nextval('contact_values_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY failures ALTER COLUMN id SET DEFAULT nextval('failures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY flags ALTER COLUMN id SET DEFAULT nextval('flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friend_actions ALTER COLUMN id SET DEFAULT nextval('friend_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friend_recommendations ALTER COLUMN id SET DEFAULT nextval('friend_recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendships ALTER COLUMN id SET DEFAULT nextval('friendships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hashtags ALTER COLUMN id SET DEFAULT nextval('hashtags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instagram_places ALTER COLUMN id SET DEFAULT nextval('instagram_places_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations ALTER COLUMN id SET DEFAULT nextval('invitations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY performers ALTER COLUMN id SET DEFAULT nextval('performers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY photo_objects ALTER COLUMN id SET DEFAULT nextval('photo_objects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY photos ALTER COLUMN id SET DEFAULT nextval('photos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY places ALTER COLUMN id SET DEFAULT nextval('places_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY point_of_interests ALTER COLUMN id SET DEFAULT nextval('point_of_interests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_types ALTER COLUMN id SET DEFAULT nextval('post_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_apps ALTER COLUMN id SET DEFAULT nextval('rpush_apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_feedback ALTER COLUMN id SET DEFAULT nextval('rpush_feedback_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_notifications ALTER COLUMN id SET DEFAULT nextval('rpush_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taste_categories ALTER COLUMN id SET DEFAULT nextval('taste_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tastes ALTER COLUMN id SET DEFAULT nextval('tastes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetables ALTER COLUMN id SET DEFAULT nextval('timetables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweet_activities ALTER COLUMN id SET DEFAULT nextval('tweet_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweets ALTER COLUMN id SET DEFAULT nextval('tweets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_actions ALTER COLUMN id SET DEFAULT nextval('user_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tastes ALTER COLUMN id SET DEFAULT nextval('user_tastes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues ALTER COLUMN id SET DEFAULT nextval('venues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Name: authentication_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentication_tokens
    ADD CONSTRAINT authentication_tokens_pkey PRIMARY KEY (id);


--
-- Name: authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentications
    ADD CONSTRAINT authentications_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: contact_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_books
    ADD CONSTRAINT contact_books_pkey PRIMARY KEY (id);


--
-- Name: contact_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_values
    ADD CONSTRAINT contact_values_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: failures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY failures
    ADD CONSTRAINT failures_pkey PRIMARY KEY (id);


--
-- Name: flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: friend_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friend_actions
    ADD CONSTRAINT friend_actions_pkey PRIMARY KEY (id);


--
-- Name: friend_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friend_recommendations
    ADD CONSTRAINT friend_recommendations_pkey PRIMARY KEY (id);


--
-- Name: friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hashtags
    ADD CONSTRAINT hashtags_pkey PRIMARY KEY (id);


--
-- Name: instagram_places_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instagram_places
    ADD CONSTRAINT instagram_places_pkey PRIMARY KEY (id);


--
-- Name: invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: performers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY performers
    ADD CONSTRAINT performers_pkey PRIMARY KEY (id);


--
-- Name: photo_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY photo_objects
    ADD CONSTRAINT photo_objects_pkey PRIMARY KEY (id);


--
-- Name: photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: places_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: point_of_interests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY point_of_interests
    ADD CONSTRAINT point_of_interests_pkey PRIMARY KEY (id);


--
-- Name: post_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_types
    ADD CONSTRAINT post_types_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: rpush_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_apps
    ADD CONSTRAINT rpush_apps_pkey PRIMARY KEY (id);


--
-- Name: rpush_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_feedback
    ADD CONSTRAINT rpush_feedback_pkey PRIMARY KEY (id);


--
-- Name: rpush_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rpush_notifications
    ADD CONSTRAINT rpush_notifications_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taste_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taste_categories
    ADD CONSTRAINT taste_categories_pkey PRIMARY KEY (id);


--
-- Name: tastes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tastes
    ADD CONSTRAINT tastes_pkey PRIMARY KEY (id);


--
-- Name: timetables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetables
    ADD CONSTRAINT timetables_pkey PRIMARY KEY (id);


--
-- Name: tweet_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweet_activities
    ADD CONSTRAINT tweet_activities_pkey PRIMARY KEY (id);


--
-- Name: tweets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweets
    ADD CONSTRAINT tweets_pkey PRIMARY KEY (id);


--
-- Name: user_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (id);


--
-- Name: user_tastes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_tastes
    ADD CONSTRAINT user_tastes_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: No duplicated photos; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "No duplicated photos" ON photo_objects USING btree (photo_id, object_id, object_type);


--
-- Name: contact_values_join_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX contact_values_join_index ON contact_values_contacts USING btree (contact_id, contact_value_id);


--
-- Name: index_authentication_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authentication_tokens_on_token ON authentication_tokens USING btree (token);


--
-- Name: index_authentications_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authentications_on_token ON authentications USING btree (token);


--
-- Name: index_categories_tastes_on_taste_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_tastes_on_taste_id_and_category_id ON categories_tastes USING btree (taste_id, category_id);


--
-- Name: index_categories_venues_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_venues_on_category_id ON categories_venues USING btree (category_id);


--
-- Name: index_categories_venues_on_category_id_and_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_venues_on_category_id_and_venue_id ON categories_venues USING btree (category_id, venue_id);


--
-- Name: index_categories_venues_on_category_id_and_zone_id_and_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_venues_on_category_id_and_zone_id_and_venue_id ON categories_venues USING btree (category_id, zone_id, venue_id);


--
-- Name: index_categories_venues_on_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_venues_on_venue_id ON categories_venues USING btree (venue_id);


--
-- Name: index_cities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cities_on_name ON cities USING btree (name);


--
-- Name: index_contact_books_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_books_on_user_id ON contact_books USING btree (user_id);


--
-- Name: index_contact_values_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_values_on_value ON contact_values USING btree (value);


--
-- Name: index_contact_values_on_value_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contact_values_on_value_type ON contact_values USING btree (value_type);


--
-- Name: index_contacts_on_contact_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_contact_user_id ON contacts USING btree (contact_user_id);


--
-- Name: index_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_user_id ON contacts USING btree (user_id);


--
-- Name: index_devices_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_devices_on_user_id ON devices USING btree (user_id);


--
-- Name: index_events_on_cached_votes_down; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_votes_down ON events USING btree (cached_votes_down);


--
-- Name: index_events_on_cached_votes_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_votes_score ON events USING btree (cached_votes_score);


--
-- Name: index_events_on_cached_votes_total; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_votes_total ON events USING btree (cached_votes_total);


--
-- Name: index_events_on_cached_votes_up; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_votes_up ON events USING btree (cached_votes_up);


--
-- Name: index_events_on_cached_weighted_average; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_weighted_average ON events USING btree (cached_weighted_average);


--
-- Name: index_events_on_cached_weighted_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_weighted_score ON events USING btree (cached_weighted_score);


--
-- Name: index_events_on_cached_weighted_total; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cached_weighted_total ON events USING btree (cached_weighted_total);


--
-- Name: index_events_on_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_city_id ON events USING btree (city_id);


--
-- Name: index_events_on_eventful_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_eventful_id ON events USING btree (eventful_id);


--
-- Name: index_events_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_latitude_and_longitude ON events USING btree (latitude, longitude);


--
-- Name: index_events_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_lonlat ON events USING gist (lonlat);


--
-- Name: index_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_user_id ON events USING btree (user_id);


--
-- Name: index_events_on_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_venue_id ON events USING btree (venue_id);


--
-- Name: index_events_on_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_zone_id ON events USING btree (zone_id);


--
-- Name: index_events_on_zoned_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_zoned_at ON events USING btree (zoned_at);


--
-- Name: index_events_performers_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_performers_on_event_id ON events_performers USING btree (event_id);


--
-- Name: index_events_performers_on_event_id_and_performer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_events_performers_on_event_id_and_performer_id ON events_performers USING btree (event_id, performer_id);


--
-- Name: index_events_performers_on_performer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_performers_on_performer_id ON events_performers USING btree (performer_id);


--
-- Name: index_flags_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_lonlat ON flags USING gist (lonlat);


--
-- Name: index_friend_actions_on_object_type_and_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friend_actions_on_object_type_and_object_id ON friend_actions USING btree (object_type, object_id);


--
-- Name: index_friend_actions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friend_actions_on_user_id ON friend_actions USING btree (user_id);


--
-- Name: index_friend_recommendations_on_user_id_and_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friend_recommendations_on_user_id_and_contact_id ON friend_recommendations USING btree (user_id, contact_id);


--
-- Name: index_friendships_on_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_recipient_id ON friendships USING btree (recipient_id);


--
-- Name: index_friendships_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendships_on_sender_id ON friendships USING btree (sender_id);


--
-- Name: index_hashtags_on_name_and_city_name_and_period_and_is_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hashtags_on_name_and_city_name_and_period_and_is_username ON hashtags USING btree (name, city_name, period, is_username);


--
-- Name: index_instagram_places_on_factual_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instagram_places_on_factual_id ON instagram_places USING btree (factual_id);


--
-- Name: index_instagram_places_on_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instagram_places_on_place_id ON instagram_places USING btree (place_id);


--
-- Name: index_instagram_places_on_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instagram_places_on_venue_id ON instagram_places USING btree (venue_id);


--
-- Name: index_invitations_on_invitable_type_and_invitable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_invitable_type_and_invitable_id ON invitations USING btree (invitable_type, invitable_id);


--
-- Name: index_invitations_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_sender_id ON invitations USING btree (sender_id);


--
-- Name: index_invitations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_user_id ON invitations USING btree (user_id);


--
-- Name: index_notifications_on_object_type_and_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_object_type_and_object_id ON notifications USING btree (object_type, object_id);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON notifications USING btree (user_id);


--
-- Name: index_on_events_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_events_location ON events USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_on_point_of_interests_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_point_of_interests_data ON point_of_interests USING gin (data);


--
-- Name: index_on_venues_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_venues_location ON venues USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_performers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_performers_on_user_id ON performers USING btree (user_id);


--
-- Name: index_photo_objects_on_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photo_objects_on_object_id ON photo_objects USING btree (object_id);


--
-- Name: index_photo_objects_on_photo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photo_objects_on_photo_id ON photo_objects USING btree (photo_id);


--
-- Name: index_photos_on_instagram_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_photos_on_instagram_id ON photos USING btree (instagram_id);


--
-- Name: index_photos_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photos_on_lonlat ON photos USING gist (lonlat);


--
-- Name: index_photos_on_tweet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photos_on_tweet_id ON photos USING btree (tweet_id);


--
-- Name: index_photos_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photos_on_user_id ON photos USING btree (user_id);


--
-- Name: index_photos_on_venue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photos_on_venue_id ON photos USING btree (venue_id);


--
-- Name: index_places_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_places_on_lonlat ON places USING gist (lonlat);


--
-- Name: index_point_of_interests_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_latitude_and_longitude ON point_of_interests USING btree (latitude, longitude);


--
-- Name: index_point_of_interests_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_lonlat ON point_of_interests USING gist (lonlat);


--
-- Name: index_point_of_interests_on_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_object_id ON point_of_interests USING btree (object_id);


--
-- Name: index_point_of_interests_on_object_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_object_type ON point_of_interests USING btree (object_type);


--
-- Name: index_point_of_interests_on_public; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_public ON point_of_interests USING btree (public);


--
-- Name: index_point_of_interests_on_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_starts_at ON point_of_interests USING btree (starts_at);


--
-- Name: index_point_of_interests_on_taste_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_taste_data ON point_of_interests USING gin (taste_data);


--
-- Name: index_point_of_interests_on_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_point_of_interests_on_zone_id ON point_of_interests USING btree (zone_id);


--
-- Name: index_posts_on_cached_votes_down; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_votes_down ON posts USING btree (cached_votes_down);


--
-- Name: index_posts_on_cached_votes_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_votes_score ON posts USING btree (cached_votes_score);


--
-- Name: index_posts_on_cached_votes_total; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_votes_total ON posts USING btree (cached_votes_total);


--
-- Name: index_posts_on_cached_votes_up; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_votes_up ON posts USING btree (cached_votes_up);


--
-- Name: index_posts_on_cached_weighted_average; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_weighted_average ON posts USING btree (cached_weighted_average);


--
-- Name: index_posts_on_cached_weighted_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_weighted_score ON posts USING btree (cached_weighted_score);


--
-- Name: index_posts_on_cached_weighted_total; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_cached_weighted_total ON posts USING btree (cached_weighted_total);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON posts USING btree (created_at);


--
-- Name: index_posts_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_item_id ON posts USING btree (item_id);


--
-- Name: index_posts_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_lonlat ON posts USING gist (lonlat);


--
-- Name: index_posts_on_photo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_photo_id ON posts USING btree (photo_id);


--
-- Name: index_posts_on_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_place_id ON posts USING btree (place_id);


--
-- Name: index_posts_on_post_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_post_type_id ON posts USING btree (post_type_id);


--
-- Name: index_posts_on_source_id_and_source_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_source_id_and_source_type ON posts USING btree (source_id, source_type);


--
-- Name: index_posts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_user_id ON posts USING btree (user_id);


--
-- Name: index_rpush_feedback_on_device_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rpush_feedback_on_device_token ON rpush_feedback USING btree (device_token);


--
-- Name: index_rpush_notifications_multi; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rpush_notifications_multi ON rpush_notifications USING btree (delivered, failed) WHERE ((NOT delivered) AND (NOT failed));


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_tag_id_and_zone_id_and_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id_and_zone_id_and_taggable_id ON taggings USING btree (tag_id, zone_id, taggable_id);


--
-- Name: index_taggings_on_taggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id ON taggings USING btree (taggable_id);


--
-- Name: index_taggings_on_taggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_type ON taggings USING btree (taggable_type);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_tags_tastes_on_taste_id_and_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_tastes_on_taste_id_and_tag_id ON tags_tastes USING btree (taste_id, tag_id);


--
-- Name: index_timetables_on_ends_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetables_on_ends_at ON timetables USING btree (ends_at);


--
-- Name: index_timetables_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetables_on_event_id ON timetables USING btree (event_id);


--
-- Name: index_timetables_on_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetables_on_starts_at ON timetables USING btree (starts_at);


--
-- Name: index_tweet_activities_on_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tweet_activities_on_period ON tweet_activities USING btree (period);


--
-- Name: index_tweets_on_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tweets_on_city_id ON tweets USING btree (city_id);


--
-- Name: index_user_actions_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_actions_on_action ON user_actions USING btree (action);


--
-- Name: index_user_actions_on_object_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_actions_on_object_id ON user_actions USING btree (object_id);


--
-- Name: index_user_actions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_actions_on_user_id ON user_actions USING btree (user_id);


--
-- Name: index_user_tastes_on_user_id_and_taste_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_tastes_on_user_id_and_taste_id ON user_tastes USING btree (user_id, taste_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_phone_number ON users USING btree (phone_number);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_venues_on_cached_votes_down; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_votes_down ON venues USING btree (cached_votes_down);


--
-- Name: index_venues_on_cached_votes_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_votes_score ON venues USING btree (cached_votes_score);


--
-- Name: index_venues_on_cached_votes_total; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_votes_total ON venues USING btree (cached_votes_total);


--
-- Name: index_venues_on_cached_votes_up; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_votes_up ON venues USING btree (cached_votes_up);


--
-- Name: index_venues_on_cached_weighted_average; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_weighted_average ON venues USING btree (cached_weighted_average);


--
-- Name: index_venues_on_cached_weighted_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_weighted_score ON venues USING btree (cached_weighted_score);


--
-- Name: index_venues_on_cached_weighted_total; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_cached_weighted_total ON venues USING btree (cached_weighted_total);


--
-- Name: index_venues_on_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_city ON venues USING btree (city);


--
-- Name: index_venues_on_eventful_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_eventful_id ON venues USING btree (eventful_id);


--
-- Name: index_venues_on_factual_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_factual_id ON venues USING btree (factual_id);


--
-- Name: index_venues_on_latitude_and_longitude; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_latitude_and_longitude ON venues USING btree (latitude, longitude);


--
-- Name: index_venues_on_lonlat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_lonlat ON venues USING gist (lonlat);


--
-- Name: index_venues_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_name ON venues USING btree (name);


--
-- Name: index_venues_on_pending_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_pending_at ON venues USING btree (pending_at);


--
-- Name: index_venues_on_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_region ON venues USING btree (region);


--
-- Name: index_venues_on_street_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_street_address ON venues USING btree (street_address);


--
-- Name: index_venues_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_user_id ON venues USING btree (user_id);


--
-- Name: index_venues_on_zip_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_zip_code ON venues USING btree (zip_code);


--
-- Name: index_venues_on_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_zone_id ON venues USING btree (zone_id);


--
-- Name: index_venues_on_zoned_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_venues_on_zoned_at ON venues USING btree (zoned_at);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: photos_center_crop_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX photos_center_crop_index ON photos USING btree (((meta_data -> 'center_crop'::text)));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_lower_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_lower_name_key ON venues USING btree (lower((name)::text));


--
-- Name: venues_hours_keys_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX venues_hours_keys_gin ON venues USING gin (hours);


--
-- Name: fk_rails_708f093c08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instagram_places
    ADD CONSTRAINT fk_rails_708f093c08 FOREIGN KEY (venue_id) REFERENCES venues(id);


--
-- Name: fk_rails_8d2134e55e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT fk_rails_8d2134e55e FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_d9f9e9854b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_books
    ADD CONSTRAINT fk_rails_d9f9e9854b FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20150715103742');

INSERT INTO schema_migrations (version) VALUES ('20150715110823');

INSERT INTO schema_migrations (version) VALUES ('20150715110909');

INSERT INTO schema_migrations (version) VALUES ('20150715111319');

INSERT INTO schema_migrations (version) VALUES ('20150715111531');

INSERT INTO schema_migrations (version) VALUES ('20150715121218');

INSERT INTO schema_migrations (version) VALUES ('20150716205948');

INSERT INTO schema_migrations (version) VALUES ('20150717073933');

INSERT INTO schema_migrations (version) VALUES ('20150721151220');

INSERT INTO schema_migrations (version) VALUES ('20150722134017');

INSERT INTO schema_migrations (version) VALUES ('20150724133153');

INSERT INTO schema_migrations (version) VALUES ('20150724193359');

INSERT INTO schema_migrations (version) VALUES ('20150727165922');

INSERT INTO schema_migrations (version) VALUES ('20150727172834');

INSERT INTO schema_migrations (version) VALUES ('20150727173743');

INSERT INTO schema_migrations (version) VALUES ('20150727174919');

INSERT INTO schema_migrations (version) VALUES ('20150727175127');

INSERT INTO schema_migrations (version) VALUES ('20150728112336');

INSERT INTO schema_migrations (version) VALUES ('20150728113835');

INSERT INTO schema_migrations (version) VALUES ('20150728125810');

INSERT INTO schema_migrations (version) VALUES ('20150728141641');

INSERT INTO schema_migrations (version) VALUES ('20150728165745');

INSERT INTO schema_migrations (version) VALUES ('20150728172729');

INSERT INTO schema_migrations (version) VALUES ('20150728181104');

INSERT INTO schema_migrations (version) VALUES ('20150729074737');

INSERT INTO schema_migrations (version) VALUES ('20150803150007');

INSERT INTO schema_migrations (version) VALUES ('20150803150144');

INSERT INTO schema_migrations (version) VALUES ('20150803150225');

INSERT INTO schema_migrations (version) VALUES ('20150804132822');

INSERT INTO schema_migrations (version) VALUES ('20150804155113');

INSERT INTO schema_migrations (version) VALUES ('20150804182309');

INSERT INTO schema_migrations (version) VALUES ('20150805183340');

INSERT INTO schema_migrations (version) VALUES ('20150806134819');

INSERT INTO schema_migrations (version) VALUES ('20150806175906');

INSERT INTO schema_migrations (version) VALUES ('20150810121807');

INSERT INTO schema_migrations (version) VALUES ('20150824173009');

INSERT INTO schema_migrations (version) VALUES ('20150824183651');

INSERT INTO schema_migrations (version) VALUES ('20150825121205');

INSERT INTO schema_migrations (version) VALUES ('20150825121357');

INSERT INTO schema_migrations (version) VALUES ('20150825145625');

INSERT INTO schema_migrations (version) VALUES ('20150825145708');

INSERT INTO schema_migrations (version) VALUES ('20150827192350');

INSERT INTO schema_migrations (version) VALUES ('20150831112443');

INSERT INTO schema_migrations (version) VALUES ('20150909125214');

INSERT INTO schema_migrations (version) VALUES ('20150910124900');

INSERT INTO schema_migrations (version) VALUES ('20150910175140');

INSERT INTO schema_migrations (version) VALUES ('20150910185206');

INSERT INTO schema_migrations (version) VALUES ('20150910190418');

INSERT INTO schema_migrations (version) VALUES ('20150910210115');

INSERT INTO schema_migrations (version) VALUES ('20150911121342');

INSERT INTO schema_migrations (version) VALUES ('20150911143909');

INSERT INTO schema_migrations (version) VALUES ('20150921064648');

INSERT INTO schema_migrations (version) VALUES ('20150921064718');

INSERT INTO schema_migrations (version) VALUES ('20150921070845');

INSERT INTO schema_migrations (version) VALUES ('20150921164528');

INSERT INTO schema_migrations (version) VALUES ('20150923183656');

INSERT INTO schema_migrations (version) VALUES ('20150924115714');

INSERT INTO schema_migrations (version) VALUES ('20150924130354');

INSERT INTO schema_migrations (version) VALUES ('20150924191730');

INSERT INTO schema_migrations (version) VALUES ('20150925113639');

INSERT INTO schema_migrations (version) VALUES ('20150925155745');

INSERT INTO schema_migrations (version) VALUES ('20150925203311');

INSERT INTO schema_migrations (version) VALUES ('20150925203704');

INSERT INTO schema_migrations (version) VALUES ('20150925210411');

INSERT INTO schema_migrations (version) VALUES ('20150927180527');

INSERT INTO schema_migrations (version) VALUES ('20150928181822');

INSERT INTO schema_migrations (version) VALUES ('20150930172434');

INSERT INTO schema_migrations (version) VALUES ('20150930172550');

INSERT INTO schema_migrations (version) VALUES ('20151002162302');

INSERT INTO schema_migrations (version) VALUES ('20151005152232');

INSERT INTO schema_migrations (version) VALUES ('20151005164904');

INSERT INTO schema_migrations (version) VALUES ('20151005173406');

INSERT INTO schema_migrations (version) VALUES ('20151005194535');

INSERT INTO schema_migrations (version) VALUES ('20151012152821');

INSERT INTO schema_migrations (version) VALUES ('20151012194645');

INSERT INTO schema_migrations (version) VALUES ('20151015112454');

INSERT INTO schema_migrations (version) VALUES ('20151015172607');

INSERT INTO schema_migrations (version) VALUES ('20151015185325');

INSERT INTO schema_migrations (version) VALUES ('20151016174007');

INSERT INTO schema_migrations (version) VALUES ('20151016190612');

INSERT INTO schema_migrations (version) VALUES ('20151019195204');

INSERT INTO schema_migrations (version) VALUES ('20151020164543');

INSERT INTO schema_migrations (version) VALUES ('20151020190057');

INSERT INTO schema_migrations (version) VALUES ('20151022122226');

INSERT INTO schema_migrations (version) VALUES ('20151022123808');

INSERT INTO schema_migrations (version) VALUES ('20151022183912');

INSERT INTO schema_migrations (version) VALUES ('20151023110452');

INSERT INTO schema_migrations (version) VALUES ('20151025210411');

INSERT INTO schema_migrations (version) VALUES ('20151029140750');

INSERT INTO schema_migrations (version) VALUES ('20151029180527');

INSERT INTO schema_migrations (version) VALUES ('20151030134907');

INSERT INTO schema_migrations (version) VALUES ('20151030143144');

INSERT INTO schema_migrations (version) VALUES ('20151030163821');

INSERT INTO schema_migrations (version) VALUES ('20151103132023');

INSERT INTO schema_migrations (version) VALUES ('20151104175012');

INSERT INTO schema_migrations (version) VALUES ('20151109123404');

INSERT INTO schema_migrations (version) VALUES ('20151110125640');

INSERT INTO schema_migrations (version) VALUES ('20151111114152');

INSERT INTO schema_migrations (version) VALUES ('20151111131458');

INSERT INTO schema_migrations (version) VALUES ('20151111132646');

INSERT INTO schema_migrations (version) VALUES ('20151111140341');

INSERT INTO schema_migrations (version) VALUES ('20151113155433');

INSERT INTO schema_migrations (version) VALUES ('20151116203642');

INSERT INTO schema_migrations (version) VALUES ('20151118210544');

INSERT INTO schema_migrations (version) VALUES ('20151120133823');

INSERT INTO schema_migrations (version) VALUES ('20151120145312');

INSERT INTO schema_migrations (version) VALUES ('20151124152520');

INSERT INTO schema_migrations (version) VALUES ('20151124180956');

INSERT INTO schema_migrations (version) VALUES ('20151124181014');

INSERT INTO schema_migrations (version) VALUES ('20151125131514');

INSERT INTO schema_migrations (version) VALUES ('20151125132110');

INSERT INTO schema_migrations (version) VALUES ('20151125132303');

INSERT INTO schema_migrations (version) VALUES ('20151127190204');

INSERT INTO schema_migrations (version) VALUES ('20151127191728');

INSERT INTO schema_migrations (version) VALUES ('20151130113752');

INSERT INTO schema_migrations (version) VALUES ('20151130114913');

INSERT INTO schema_migrations (version) VALUES ('20151130120734');

INSERT INTO schema_migrations (version) VALUES ('20151130120802');

INSERT INTO schema_migrations (version) VALUES ('20151130123119');

INSERT INTO schema_migrations (version) VALUES ('20151130155011');

INSERT INTO schema_migrations (version) VALUES ('20151130171643');

INSERT INTO schema_migrations (version) VALUES ('20151201195622');

INSERT INTO schema_migrations (version) VALUES ('20151206190816');

INSERT INTO schema_migrations (version) VALUES ('20151207151328');

INSERT INTO schema_migrations (version) VALUES ('20151208161222');

INSERT INTO schema_migrations (version) VALUES ('20151208173128');

INSERT INTO schema_migrations (version) VALUES ('20151210125636');

INSERT INTO schema_migrations (version) VALUES ('20151210125658');

INSERT INTO schema_migrations (version) VALUES ('20151210141832');

INSERT INTO schema_migrations (version) VALUES ('20151211104821');

INSERT INTO schema_migrations (version) VALUES ('20151211165723');

INSERT INTO schema_migrations (version) VALUES ('20151217191846');

INSERT INTO schema_migrations (version) VALUES ('20151217191847');

INSERT INTO schema_migrations (version) VALUES ('20151217191848');

INSERT INTO schema_migrations (version) VALUES ('20151218162628');

INSERT INTO schema_migrations (version) VALUES ('20151223180231');

INSERT INTO schema_migrations (version) VALUES ('20151223180317');

INSERT INTO schema_migrations (version) VALUES ('20151229150933');

INSERT INTO schema_migrations (version) VALUES ('20160105124003');

INSERT INTO schema_migrations (version) VALUES ('20160106171947');

INSERT INTO schema_migrations (version) VALUES ('20160108171138');

INSERT INTO schema_migrations (version) VALUES ('20160108171812');

INSERT INTO schema_migrations (version) VALUES ('20160202175317');

INSERT INTO schema_migrations (version) VALUES ('20160210124814');

INSERT INTO schema_migrations (version) VALUES ('20160210125435');

INSERT INTO schema_migrations (version) VALUES ('20160213123804');

INSERT INTO schema_migrations (version) VALUES ('20160217000622');

INSERT INTO schema_migrations (version) VALUES ('20160217125829');

INSERT INTO schema_migrations (version) VALUES ('20160219150436');

INSERT INTO schema_migrations (version) VALUES ('20160219183650');

INSERT INTO schema_migrations (version) VALUES ('20160228123643');

INSERT INTO schema_migrations (version) VALUES ('20160301131859');

INSERT INTO schema_migrations (version) VALUES ('20160303003633');

INSERT INTO schema_migrations (version) VALUES ('20160303133001');

INSERT INTO schema_migrations (version) VALUES ('20160303135339');

INSERT INTO schema_migrations (version) VALUES ('20160303135528');

INSERT INTO schema_migrations (version) VALUES ('20160303144843');

INSERT INTO schema_migrations (version) VALUES ('20160303150327');

INSERT INTO schema_migrations (version) VALUES ('20160304200913');

INSERT INTO schema_migrations (version) VALUES ('20160307155127');

INSERT INTO schema_migrations (version) VALUES ('20160307195425');

INSERT INTO schema_migrations (version) VALUES ('20160307201707');

INSERT INTO schema_migrations (version) VALUES ('20160308123911');

INSERT INTO schema_migrations (version) VALUES ('20160310073122');

INSERT INTO schema_migrations (version) VALUES ('20160311175701');

INSERT INTO schema_migrations (version) VALUES ('20160314190337');

INSERT INTO schema_migrations (version) VALUES ('20160315152615');

INSERT INTO schema_migrations (version) VALUES ('20160406143610');

INSERT INTO schema_migrations (version) VALUES ('20160406143909');

INSERT INTO schema_migrations (version) VALUES ('20160406231509');

INSERT INTO schema_migrations (version) VALUES ('20160412141320');

INSERT INTO schema_migrations (version) VALUES ('20160413201311');

INSERT INTO schema_migrations (version) VALUES ('20160415161437');

INSERT INTO schema_migrations (version) VALUES ('20160415212518');

INSERT INTO schema_migrations (version) VALUES ('20160419210155');

INSERT INTO schema_migrations (version) VALUES ('20160504164039');

INSERT INTO schema_migrations (version) VALUES ('20160517144908');

INSERT INTO schema_migrations (version) VALUES ('20160627141650');

