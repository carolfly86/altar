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
    dept_emp_emp_no integer,
    dept_emp_dept_no character(4),
    dept_emp_from_date date,
    dept_emp_to_date date,
    departments_dept_no character(4),
    departments_dept_name character varying(40),
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (employees_emp_no, employees_birth_date, employees_first_name, employees_last_name, employees_gender, employees_hire_date, salaries_emp_no, salaries_salary, salaries_from_date, salaries_to_date, titles_emp_no, titles_title, titles_from_date, titles_to_date, dept_emp_emp_no, dept_emp_dept_no, dept_emp_from_date, dept_emp_to_date, departments_dept_no, departments_dept_name, type, branch) FROM stdin;
10009	1947-04-19	Sumant	Peac	F	1985-02-18	10009	40929	1975-02-18	1986-02-18	10009	Assistant Engineer	1985-02-18	1990-02-18	10009	d006	1985-02-18	9999-01-01	d006	Quality Management	excluded	
50389	1945-07-30	Zengping	Anido	M	1992-04-01	50389	48480	1992-04-01	1993-04-01	50389	Staff	1992-04-01	2001-01-31	50389	d002	1982-04-01	2001-01-31	d002	Finance	satisfied	PH0
10117	1961-10-24	Kiyotoshi	Blokdijk	F	1990-05-28	10117	52284	1979-04-25	1993-03-19	10117	Senior Engineer	1992-03-19	9999-01-01	10117	d004	1992-03-19	9999-01-01	d004	Production	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

