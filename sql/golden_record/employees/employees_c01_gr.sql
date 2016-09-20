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
32463	1962-12-03	Woody	Anandan	M	1989-06-23	32463	57360	1992-03-16	1993-03-16	32463	Senior Engineer	1992-03-16	2000-06-08	32463	d004	1992-03-16	2000-06-08	d004	Production	satisfied	PH0
10002	1946-06-02	Bezalel	Simmel	F	1985-11-21	10002	45828	1978-12-31	1997-08-03	10002	Staff	1978-12-31	9999-01-01	10002	d007	1978-12-31	9999-01-01	d007	Sales	excluded	
\.


--
-- PostgreSQL database dump complete
--

