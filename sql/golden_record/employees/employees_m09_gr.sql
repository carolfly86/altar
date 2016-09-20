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
10509	1953-10-03	Abdelwaheb	Riesenhuber	F	1990-02-23	10509	49292	1992-10-06	1993-10-06	10509	Staff	1992-10-06	1997-10-06	excluded	
14248	1955-10-13	Mark	Alblas	M	1989-05-24	14248	40000	1989-05-24	1990-05-24	14248	Engineer	1989-05-24	1994-05-24	satisfied	PH1
11015	1965-01-24	Jeanna	Riesenhuber	F	1992-05-29	11015	57076	1998-03-14	1999-03-14	11015	Senior Staff	1998-03-14	2000-02-22	satisfied	PH2
10001	1953-09-02	Georgi	Facello	F	1986-06-26	10001	49292	1986-06-26	1987-06-26	10001	Engineer	1986-06-26	9999-01-01	satisfied	PH0
\.


--
-- PostgreSQL database dump complete
--

