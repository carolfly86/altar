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
    dept_manager_emp_no integer,
    dept_manager_dept_no character(4),
    dept_manager_from_date date,
    dept_manager_to_date date,
    dept_emp_emp_no integer,
    dept_emp_dept_no character(4),
    dept_emp_from_date date,
    dept_emp_to_date date,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (dept_manager_emp_no, dept_manager_dept_no, dept_manager_from_date, dept_manager_to_date, dept_emp_emp_no, dept_emp_dept_no, dept_emp_from_date, dept_emp_to_date, type, branch) FROM stdin;
110511	d005	1985-01-01	1992-04-25	10001	d005	1986-06-26	9999-01-01	excluded	
111133	d007	1991-03-07	9999-01-01	10002	d007	1996-08-03	9999-01-01	satisfied	PH0
110039	d001	1991-10-01	9999-01-01	23858	d001	1991-10-01	9999-01-01	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

