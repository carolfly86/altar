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
64750	1960-01-31	Chriss	Birdsall	F	1986-06-20	64750	60878	1996-01-01	1996-12-31	64750	Staff	1996-01-01	9999-01-01	64750	d007	1996-01-01	9999-01-01	d007	Sales	satisfied	PH0
14750	1958-05-11	Shaowei	Iisaku	F	1985-09-24	10938	68677	1985-09-24	1986-09-24	10938	Staff	1985-09-24	1993-09-24	10938	d001	1985-09-24	9999-01-01	d001	Marketing	excluded	
14750	1958-01-24	Yuping	Alpin	F	1994-05-10	10210	40000	1996-02-24	1997-02-23	10210	Staff	1996-02-24	2002-02-23	10210	d009	1996-02-24	9999-01-01	d009	Customer Service	satisfied	PH1
14750	1958-05-21	Yinghua	Dredge	M	1985-01-01	10050	74366	1990-12-25	1991-12-25	10050	Staff	1990-12-25	1999-12-25	10050	d002	1990-12-25	1992-11-05	d002	Finance	satisfied	PH2
14750	1965-01-24	Juyoung	Seghrouchni	F	1985-01-01	10933	40000	1993-08-02	1994-08-02	10933	Senior Engineer	1993-08-02	9999-01-01	10933	d004	1993-08-02	9999-01-01	d004	Production	satisfied	PH3
14750	1963-06-01	Duangkaew	Piveteau	F	1985-01-01	10010	72488	1996-11-24	1997-11-24	10010	Engineer	1996-11-24	9999-01-01	10010	d004	1996-11-24	2000-06-26	d004	Production	satisfied	PH4
14750	1955-12-15	Heekeun	Majewski	F	1985-01-01	10153	54246	2000-01-08	2001-01-07	10153	Assistant Engineer	2000-01-08	9999-01-01	10153	d005	2000-01-08	9999-01-01	d005	Development	satisfied	PH5
\.


--
-- PostgreSQL database dump complete
--

