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
-- Name: golden_record2; Type: TABLE; Schema: public; Owner: yguo; Tablespace: 
--

CREATE TABLE golden_record (
    salaries_emp_no integer,
    salaries_salary integer,
    salaries_from_date date,
    salaries_to_date date,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record2; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (salaries_emp_no, salaries_salary, salaries_from_date, salaries_to_date, type, branch) FROM stdin;
58042	94701	1990-01-06	1991-01-06	excluded	
110000	50000	1994-04-01	1994-04-01	satisfied	PH0
\.


--
-- PostgreSQL database dump complete
--

