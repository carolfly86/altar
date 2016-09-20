--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: golden_record; Type: TABLE; Schema: public; Owner: yguo; Tablespace: 
--

CREATE TABLE golden_record (
    emp_no integer,
    birth_date date,
    first_name character varying(14),
    last_name character varying(16),
    gender gender_enum,
    hire_date date,
    salary integer,
    from_date date,
    to_date date,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (emp_no, birth_date, first_name, last_name, gender, hire_date, salary, from_date, to_date, type, branch) FROM stdin;
10003	1959-12-03	Parto	Bamford	F	1986-08-28	40006	1995-12-03	1996-12-02	excluded	
50481	1956-02-04	Danel	Kobuchi	M	1985-04-03	0	1996-12-23	1996-12-23	satisfied	PH0
10001	1953-09-02	Georgi	Facello	M	1986-06-26	60117	1986-06-26	1987-06-26	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

