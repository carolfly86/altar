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
10018	1954-06-19	Kazuhide	Peha	F	1987-04-03	10018	55881	1987-04-03	1988-04-02	10018	Engineer	1987-04-03	1995-04-03	10018	d004	1992-07-29	9999-01-01	d004	Production	excluded	
481780	1954-07-28	Ibibia	Aloisi	F	1991-01-25	481780	40000	1997-06-22	1998-06-22	481780	Assistant Engineer	1997-06-22	9999-01-01	481780	d004	1999-10-28	9999-01-01	d004	Production	satisfied	PH0
12643	1965-01-30	Morrie	Schurmann	F	1998-07-23	12643	114784	1998-12-31	1999-12-31	12643	Staff	1998-12-31	9999-01-01	12643	d002	1998-12-31	9999-01-01	d002	Finance	satisfied	PH1
10024	1958-09-05	Suzette	Pettey	F	1997-05-19	10024	83733	1998-06-14	1999-06-14	10024	Assistant Engineer	1998-06-14	9999-01-01	10024	d004	1998-06-14	9999-01-01	d004	Production	satisfied	PH2
12611	1963-10-31	Guttorm	McAffer	M	1994-02-08	12611	40000	2000-01-07	2001-01-06	12611	Staff	2000-01-07	9999-01-01	12611	d002	2000-01-07	9999-01-01	d002	Finance	satisfied	PH3
\.


--
-- PostgreSQL database dump complete
--

