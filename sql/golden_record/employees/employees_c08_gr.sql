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
10001	1953-09-02	Georgi	Facello	M	1986-06-26	10001	60117	1986-06-26	1987-06-26	10001	Senior Engineer	1986-06-26	9999-01-01	10001	d005	1986-06-26	9999-01-01	d005	Development	excluded	
495538	1960-05-20	Gro	Kawashimo	M	1988-06-27	495538	77337	1991-01-20	1992-01-20	495538	Staff	1991-01-20	2000-01-20	495538	d001	1991-01-20	9999-01-01	d001	Marketing	satisfied	PH0
13796	1953-07-02	Paloma	Thorelli	M	1988-08-28	13796	50962	1996-01-01	1996-12-31	13796	Engineer	1996-01-01	9999-01-01	13796	d005	1996-01-01	9999-01-01	d005	Development	satisfied	PH1
11199	1957-10-14	Ortrud	Srimani	F	1989-05-02	11199	40000	1989-05-02	1990-05-02	11199	Technique Leader	1989-05-02	9999-01-01	11199	d004	1996-01-01	9999-01-01	d004	Production	satisfied	PH2
11715	1959-12-08	Arnd	Albarhamtoshy	F	1989-03-11	11715	48995	1998-02-21	1999-02-21	11715	Staff	1998-02-21	9999-01-01	11715	d007	1998-02-21	9999-01-01	d007	Sales	satisfied	PH3
10042	1956-02-26	Magy	Stamatiou	F	1993-03-21	10042	81662	1993-03-21	1994-03-21	10042	Staff	1993-03-21	2000-03-21	10042	d002	1993-03-21	2000-08-10	d002	Finance	satisfied	PH4
10087	1959-07-23	Xinglin	Eugenio	F	1986-09-08	10087	96750	1997-05-08	1998-05-08	10087	Staff	1997-05-08	2001-01-09	10087	d007	1997-05-08	2001-01-09	d007	Sales	satisfied	PH5
110022	1956-09-12	Margareta	Markovitch	M	1985-01-01	110022	71166	1985-01-01	1986-01-01	110022	Manager	1985-01-01	1991-10-01	110022	d001	1985-01-01	9999-01-01	d001	Marketing	satisfied	PH6
10476	1965-01-01	Kokou	Iisaka	M	1987-09-20	10476	58221	1987-09-20	1988-09-19	10476	Staff	1987-09-20	1994-09-20	10476	d008	1987-09-20	9999-01-01	d008	Research	satisfied	PH7
16220	1956-04-12	Alenka	Sooriamurthi	M	1992-10-02	16220	40000	1995-01-01	1996-01-01	16220	Staff	1995-01-01	2000-01-01	16220	d009	1995-01-01	9999-01-01	d009	Customer Service	satisfied	PH8
20196	1960-09-20	LiMin	Redmiles	F	1988-01-02	20196	40000	1988-01-02	1989-01-01	20196	Engineer	1988-01-02	1997-01-01	20196	d005	1988-01-02	9999-01-01	d005	Development	satisfied	PH9
\.


--
-- PostgreSQL database dump complete
--

