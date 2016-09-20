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
109081	1964-08-12	Gennady	Jording	M	1988-03-25	109081	62497	1989-12-29	1990-12-29	excluded	
10001	1953-09-02	Georgi	Facello	M	1986-06-26	10001	60117	1986-06-26	1987-06-26	satisfied	PH0
202815	1958-10-17	Nishit	Guerreiro	M	1985-04-06	202815	78571	1985-04-06	1985-06-15	satisfied	PH3
11715	1959-12-08	Arnd	Albarhamtoshy	F	1989-03-11	11715	48995	1987-01-01	1999-02-21	satisfied	PH2
205000	1956-01-14	Charmane	Griswold	M	1990-06-23	205000	151596	1987-01-01	2001-10-09	satisfied	PH5
20095	1965-01-03	Hilari	Morton	M	1986-07-15	20095	63668	1987-01-01	1995-03-10	satisfied	PH4
200742	1958-11-09	Goh	Lovengreen	F	1994-02-13	200742	44044	1998-11-06	1998-11-06	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

