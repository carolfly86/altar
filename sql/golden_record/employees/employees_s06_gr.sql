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
    employees_emp_no integer,
    employees_birth_date date,
    employees_first_name character varying(14),
    employees_last_name character varying(16),
    employees_gender gender_enum,
    employees_hire_date date,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (employees_emp_no, employees_birth_date, employees_first_name, employees_last_name, employees_gender, employees_hire_date, type, branch) FROM stdin;
10001	1953-09-02	Georgi	Facello	F	1986-06-26	excluded	
12523	1954-09-26	Tonia	Casley	M	1989-03-03	satisfied	PH0
11234	1961-06-17	Tooru	Vingron	F	1990-08-21	satisfied	PH1
16093	1952-02-03	Luise	Tramer	F	1992-02-28	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

