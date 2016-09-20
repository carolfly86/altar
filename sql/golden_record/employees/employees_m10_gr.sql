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
    employees_emp_no integer,
    employees_birth_date date,
    employees_first_name character varying(14),
    employees_last_name character varying(16),
    employees_gender gender_enum,
    employees_hire_date date,
    salaries_emp_no integer,
    salaries_salary integer,
    salaries_from_date date,
    salaries_to_date date,
    titles_emp_no integer,
    titles_title character varying(50),
    titles_from_date date,
    titles_to_date date,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (employees_emp_no, employees_birth_date, employees_first_name, employees_last_name, employees_gender, employees_hire_date, salaries_emp_no, salaries_salary, salaries_from_date, salaries_to_date, titles_emp_no, titles_title, titles_from_date, titles_to_date, type, branch) FROM stdin;
10527	1946-09-15	Tetsushi	Barvinok	F	1996-01-25	10527	9999	1996-01-25	1997-01-24	10527	Technique Leader	1996-01-25	9999-01-01	excluded	
20310	1964-08-29	Aksel	Alencar	M	1990-10-24	20310	42894	1990-10-24	1991-10-24	20310	Senior Engineer	1990-10-24	2001-07-26	satisfied	PH0
10001	1946-09-15	Georgi	Facello	F	1986-06-26	10001	9999	1996-01-25	1987-06-26	10001	Engineer	1996-01-25	9999-01-01	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

