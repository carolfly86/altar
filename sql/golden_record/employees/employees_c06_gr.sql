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
480245	1960-01-04	Arnd	Trystram	M	1992-11-25	480245	86357	1996-02-13	1997-02-12	480245	Senior Staff	1996-02-13	9999-01-01	480245	d001	2000-07-22	9999-01-01	d001	Marketing	satisfied	PH0
10157	1954-04-23	Nigel	Aloisi	M	1985-11-02	10157	48770	1997-12-10	1998-12-10	10157	Senior Engineer	1997-12-10	9999-01-01	10157	d005	1997-12-10	9999-01-01	d005	Development	satisfied	PH1
10132	1956-12-15	Ayakannu	Skrikant	M	1994-10-30	10132	61590	1997-06-18	1998-06-18	10132	Staff	1997-06-18	9999-01-01	10132	d002	1997-06-18	9999-01-01	d002	Finance	satisfied	PH2
10122	1965-01-19	Ohad	Esposito	M	1992-12-23	10122	42284	1998-08-06	1999-08-06	10122	Technique Leader	1998-08-06	9999-01-01	10122	d005	1998-08-06	9999-01-01	d005	Development	satisfied	PH3
10024	1958-09-05	Suzette	Pettey	F	1997-05-19	10024	83733	1998-06-14	1999-06-14	10024	Assistant Engineer	1998-06-14	9999-01-01	10024	d004	1998-06-14	9999-01-01	d004	Production	satisfied	PH4
12611	1963-10-31	Guttorm	McAffer	M	1994-02-08	12611	40000	2000-01-07	2001-01-06	12611	Staff	2000-01-07	9999-01-01	12611	d002	2000-01-07	9999-01-01	d002	Finance	satisfied	PH5
\.


--
-- PostgreSQL database dump complete
--

