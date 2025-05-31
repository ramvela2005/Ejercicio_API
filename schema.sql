--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 15.13 (Debian 15.13-1.pgdg120+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: category; Type: TABLE; Schema: public; Owner: apiuser
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.category OWNER TO apiuser;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: apiuser
--

CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_id_seq OWNER TO apiuser;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: apiuser
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: incident; Type: TABLE; Schema: public; Owner: apiuser
--
CREATE TYPE incident_status AS ENUM ('Pendiente', 'En proceso', 'Resuelto');

CREATE TABLE public.incident (
    id integer NOT NULL,
    reporter character varying(100) NOT NULL,
    description text NOT NULL,
    status incident_status NOT NULL DEFAULT 'Pendiente',
    created_at timestamp without time zone
);


ALTER TABLE public.incident OWNER TO apiuser;

--
-- Name: incident_categories; Type: TABLE; Schema: public; Owner: apiuser
--

CREATE TABLE public.incident_categories (
    incident_id integer NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE public.incident_categories OWNER TO apiuser;

--
-- Name: incident_id_seq; Type: SEQUENCE; Schema: public; Owner: apiuser
--

CREATE SEQUENCE public.incident_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incident_id_seq OWNER TO apiuser;

--
-- Name: incident_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: apiuser
--

ALTER SEQUENCE public.incident_id_seq OWNED BY public.incident.id;


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: incident id; Type: DEFAULT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.incident ALTER COLUMN id SET DEFAULT nextval('public.incident_id_seq'::regclass);


--
-- Name: category category_name_key; Type: CONSTRAINT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_name_key UNIQUE (name);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: incident_categories incident_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.incident_categories
    ADD CONSTRAINT incident_categories_pkey PRIMARY KEY (incident_id, category_id);


--
-- Name: incident incident_pkey; Type: CONSTRAINT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.incident
    ADD CONSTRAINT incident_pkey PRIMARY KEY (id);


--
-- Name: incident_categories incident_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.incident_categories
    ADD CONSTRAINT incident_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(id);


--
-- Name: incident_categories incident_categories_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: apiuser
--

ALTER TABLE ONLY public.incident_categories
    ADD CONSTRAINT incident_categories_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES public.incident(id);


--
-- PostgreSQL database dump complete
--

-- Crear tipo ENUM para status
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'incident_status') THEN
    CREATE TYPE incident_status AS ENUM ('Pendiente', 'En proceso', 'Resuelto');
  END IF;
END$$;

-- Alterar columna status para que use el nuevo tipo
ALTER TABLE public.incident
  ALTER COLUMN status DROP DEFAULT;

ALTER TABLE public.incident
  ALTER COLUMN status TYPE incident_status USING status::incident_status;

ALTER TABLE public.incident
  ALTER COLUMN status SET DEFAULT 'Pendiente';

CREATE OR REPLACE VIEW incident_with_categories AS
SELECT
  i.id AS incident_id,
  i.reporter,
  i.description,
  i.status,
  i.created_at,
  STRING_AGG(c.name, ', ') AS category_names
FROM incident i
LEFT JOIN incident_categories ic ON i.id = ic.incident_id
LEFT JOIN category c ON ic.category_id = c.id
GROUP BY i.id;
