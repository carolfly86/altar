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
10147	1964-10-13	Kazuhito	Encarnacion	M	1986-08-21	10147	40000	1987-12-18	1988-12-17	10147	Staff	1987-12-18	1995-12-18	10147	d002	1987-12-18	9999-01-01	d002	Finance	excluded	
50032	1956-10-04	Sudharsan	Anily	M	1989-09-01	50032	64013	1996-07-26	1997-07-26	50032	Engineer	1996-07-26	2001-07-30	50032	d005	1996-07-26	2001-07-30	d005	Development	satisfied	PH0
14476	1965-01-19	Sastry	Marrevee	M	1989-10-19	14476	42512	1999-09-25	2000-09-24	14476	Engineer	1989-09-25	9999-01-01	14476	d004	1989-09-25	9999-01-01	d002	Production	satisfied	PH1
20196	1960-09-20	LiMin	Redmiles	F	1988-01-02	20196	40000	1988-01-02	1989-01-01	20196	Engineer	1988-01-02	1997-01-01	20196	d005	1988-01-02	9999-01-01	d002	Development	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

