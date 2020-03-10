SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: exchange_rate_integer; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.exchange_rate_integer AS bigint NOT NULL DEFAULT 0;


--
-- Name: gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gender AS ENUM (
    'F',
    'M',
    'U'
);


--
-- Name: money_integer; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.money_integer AS integer NOT NULL DEFAULT 0;


--
-- Name: temp_table_info; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.temp_table_info AS (
	schema_name text,
	table_name text
);


--
-- Name: three_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.three_state AS ENUM (
    'Y',
    'N',
    'U'
);


--
-- Name: hash_password(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.hash_password(password text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  password = crypt(password, gen_salt('bf', 8));

  RETURN password;
END;
$$;


--
-- Name: temp_table_exists(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.temp_table_exists(character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
  BEGIN
    /* check the table exist in database and is visible*/
    PERFORM n.nspname, c.relname
    FROM pg_catalog.pg_class c
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname LIKE 'pg_temp_%' AND pg_catalog.pg_table_is_visible(c.oid)
    AND relname = $1;

    IF FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  END;
$_$;


--
-- Name: unique_random_string(text, text, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.unique_random_string(table_name text, column_name text, string_length integer DEFAULT 6, prefix text DEFAULT ''::text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  DECLARE
    key TEXT;
    qry TEXT;
    found TEXT;
    letter TEXT;
    iterator INTEGER;
  BEGIN

    qry := 'SELECT ' || column_name || ' FROM ' || table_name || ' WHERE ' || column_name || '=';

    LOOP

      key := prefix;
      iterator := 0;

      WHILE iterator < string_length
      LOOP

        SELECT c INTO letter
        FROM regexp_split_to_table(
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          ''
        ) c
        ORDER BY random()
        LIMIT 1;

        key := key || letter;

        iterator := iterator + 1;
      END LOOP;

      EXECUTE qry || quote_literal(key) INTO found;

      IF found IS NULL THEN
        EXIT;
      END IF;

    END LOOP;

    RETURN key;
  END;
$$;


--
-- Name: valid_email_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.valid_email_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.email = validate_email(NEW.email);

  RETURN NEW;
END;
$$;


--
-- Name: validate_email(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_email(email text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF email IS NOT NULL THEN
    IF email !~* '\\A[^@\\s;./[\\]\\\\]+(\\.[^@\\s;./[\\]\\\\]+)*@[^@\\s;./[\\]\\\\]+(\\.[^@\\s;./[\\]\\\\]+)*\\.[^@\\s;./[\\]\\\\]+\\Z' THEN
      RAISE EXCEPTION 'Invalid E-mail format %', email
          USING HINT = 'Please check your E-mail format.';
    END IF ;
    email = lower(email);
  END IF ;

  RETURN email;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO public;

INSERT INTO "schema_migrations" (version) VALUES
('20200224204858'),
('20200224204925'),
('20200224210423'),
('20200224211748');


