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
10072	1942-05-15	Hironoby	Sidou	F	1986-07-21	10072	40000	1979-05-21	1990-05-21	10072	Engineer	1989-05-21	1995-05-21	10072	d005	1989-05-21	9999-01-01	d005	Development	excluded	
10010	1949-01-01	Duangkaew	Piveteau	F	1986-01-01	10010	72488	1984-01-01	1997-11-24	10010	Engineer	1996-11-24	9999-01-01	10010	d004	1996-11-24	2000-06-26	d004	Production	satisfied	PH2
10165	1960-06-16	Miyeon	Macedo	M	1986-01-01	10165	40000	1984-01-01	1989-05-17	10165	Senior Staff	1988-05-17	9999-01-01	10165	d002	1988-05-17	9999-01-01	d002	Finance	satisfied	PH1
50028	1949-01-01	Matk	Alameldin	F	1987-05-14	50028	40000	1987-05-14	1988-05-13	50028	Engineer	1987-05-14	1993-05-13	50028	d004	1987-05-14	9999-01-01	d004	Finance	satisfied	PH0
\.


--
-- PostgreSQL database dump complete
--

