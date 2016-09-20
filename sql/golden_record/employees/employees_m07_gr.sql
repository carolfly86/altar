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
14688	1964-10-20	Ute	Ullian	M	1985-05-23	14688	42041	1985-07-06	1985-08-08	14688	Staff	1985-07-06	1985-08-08	excluded	
33582	1964-08-07	Gil	Standera	F	1989-11-28	33582	100577	1989-11-28	1985-08-08	33582	Staff	1989-11-28	1997-11-28	satisfied	PH3
11715	1959-12-08	Arnd	Albarhamtoshy	F	1985-05-23	11715	48995	1998-02-21	1999-02-21	11715	Staff	1998-02-21	9999-01-01	satisfied	PH1
10933	1965-01-24	Juyoung	Seghrouchni	F	1985-05-23	10933	40000	1993-08-02	1985-08-08	10933	Senior Engineer	1993-08-02	9999-01-01	satisfied	PH2
24751	1953-01-24	Aiman	Hainaut	M	1985-05-23	24751	60951	1990-01-01	1985-08-08	24751	Staff	1990-01-01	1991-08-03	satisfied	PH0
\.


--
-- PostgreSQL database dump complete
--

