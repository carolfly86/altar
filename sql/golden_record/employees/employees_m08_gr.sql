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
22446	1956-10-30	Shugo	Albarhamtoshy	M	1993-08-17	22446	50205	1993-08-17	1994-08-17	22446	Engineer	1993-08-17	9999-01-01	satisfied	PH0
11015	1965-01-24	Jeanna	Riesenhuber	M	1992-05-29	11015	57076	1988-03-14	1999-03-14	11015	Senior Staff	1998-03-14	2000-02-22	satisfied	PH1
12446	1953-09-02	Georgi	Facello	F	1986-06-26	12446	40205	1985-06-26	1985-08-26	12446	Senior Engineer	1985-06-26	9999-01-01	excluded	
\.


--
-- PostgreSQL database dump complete
--

