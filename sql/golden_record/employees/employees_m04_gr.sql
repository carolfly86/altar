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
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (employees_emp_no, employees_birth_date, employees_first_name, employees_last_name, employees_gender, employees_hire_date, salaries_emp_no, salaries_salary, salaries_from_date, salaries_to_date, type, branch) FROM stdin;
100967	1958-06-01	Chikara	Perelgut	M	1990-03-01	100967	56918	1997-02-27	1998-02-27	excluded	
10001	1953-09-02	Georgi	Facello	M	1986-06-26	10001	60117	1986-06-26	1987-06-26	satisfied	PH0
101299	1963-10-10	Vivian	Horswill	F	1990-01-01	101299	107354	1990-01-01	1991-01-01	satisfied	PH1
11715	1959-12-08	Arnd	Albarhamtoshy	F	1989-03-11	11715	48995	1998-02-21	1999-02-21	satisfied	PH2
101379	1952-04-06	Ult	Lienhardt	M	1985-10-14	101379	54260	1985-10-14	1985-12-10	satisfied	PH3
10095	1965-01-03	Hilari	Morton	M	1986-07-15	10095	63668	1994-03-10	1995-03-10	satisfied	PH4
109334	1955-08-02	Tsutomu	Alameldin	M	1985-02-15	109334	151484	1998-02-12	1999-02-12	satisfied	PH5
\.


--
-- PostgreSQL database dump complete
--

