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
10500	1957-04-29	Vojin	Narwekar	M	1996-12-16	10500	42688	1996-12-16	1997-12-16	10500	Engineer	1996-12-16	9999-01-01	excluded	
10001	1953-09-02	Georgi	Facello	M	1986-06-26	10001	60117	1986-06-26	1987-06-26	10001	Senior Engineer	1986-06-26	9999-01-01	satisfied	PH0
18199	1953-02-25	Teruyuki	Sridhar	M	1990-01-01	18199	43128	1990-01-01	1991-01-01	18199	Senior Staff	1990-01-01	9999-01-01	satisfied	PH1
11715	1959-12-08	Arnd	Albarhamtoshy	F	1989-03-11	11715	48995	1998-02-21	1999-02-21	11715	Staff	1998-02-21	9999-01-01	satisfied	PH2
229120	1964-12-16	Aimee	Baja	M	1985-02-06	229120	67400	1985-02-06	1985-06-12	229120	Staff	1985-02-06	1985-06-12	satisfied	PH3
10933	1965-01-24	Juyoung	Seghrouchni	F	1993-08-02	10933	40000	1993-08-02	1994-08-02	10933	Senior Engineer	1993-08-02	9999-01-01	satisfied	PH4
237205	1960-04-02	Tadanori	Worfolk	F	1993-01-01	237205	58944	1993-01-01	1993-01-01	237205	Staff	1993-01-01	1993-01-01	satisfied	PH5
\.


--
-- PostgreSQL database dump complete
--

