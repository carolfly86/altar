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
    purchaseorderheader_purchaseorderid integer,
    purchaseorderheader_revisionnumber smallint,
    purchaseorderheader_status smallint,
    purchaseorderheader_employeeid integer,
    purchaseorderheader_vendorid integer,
    purchaseorderheader_shipmethodid integer,
    purchaseorderheader_orderdate timestamp without time zone,
    purchaseorderheader_shipdate timestamp without time zone,
    purchaseorderheader_subtotal numeric,
    purchaseorderheader_taxamt numeric,
    purchaseorderheader_freight numeric,
    purchaseorderheader_modifieddate timestamp without time zone,
    employee_businessentityid integer,
    employee_nationalidnumber character varying(15),
    employee_loginid character varying(256),
    employee_jobtitle character varying(50),
    employee_birthdate date,
    employee_maritalstatus character(1),
    employee_gender character(1),
    employee_hiredate date,
    employee_salariedflag "Flag",
    employee_vacationhours smallint,
    employee_sickleavehours smallint,
    employee_currentflag "Flag",
    employee_rowguid uuid,
    employee_modifieddate timestamp without time zone,
    employee_organizationnode character varying,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (purchaseorderheader_purchaseorderid, purchaseorderheader_revisionnumber, purchaseorderheader_status, purchaseorderheader_employeeid, purchaseorderheader_vendorid, purchaseorderheader_shipmethodid, purchaseorderheader_orderdate, purchaseorderheader_shipdate, purchaseorderheader_subtotal, purchaseorderheader_taxamt, purchaseorderheader_freight, purchaseorderheader_modifieddate, employee_businessentityid, employee_nationalidnumber, employee_loginid, employee_jobtitle, employee_birthdate, employee_maritalstatus, employee_gender, employee_hiredate, employee_salariedflag, employee_vacationhours, employee_sickleavehours, employee_currentflag, employee_rowguid, employee_modifieddate, employee_organizationnode, type, branch) FROM stdin;
4	4	3	261	1650	4	2011-04-16 00:00:00	2011-04-25 00:00:00	171.0765	13.6861	4.2769	2011-04-25 00:00:00	261	280633567	adventure-works\\reinout0	Purchasing Assistant	1978-01-17	M	M	2009-12-25	f	51	45	t	9825eb00-8e36-4506-93a2-6ddcdc0b13c3	2014-06-30 00:00:00	/4/3/1/11/	excluded	
2	4	1	254	1496	4	2011-04-16 00:00:00	2011-04-25 00:00:00	272.1015	100	6.8025	2011-04-25 00:00:00	254	482810518	adventure-works\\fukiko0	Buyer	1970-11-24	M	M	2010-01-04	f	57	48	t	36cd6636-c657-4fc7-9bfa-cc1bfa9102a2	2014-06-30 00:00:00	/4/3/1/4/	satisfied	PH0
30	4	4	260	1568	4	2012-01-08 00:00:00	2012-01-17 00:00:00	21252	1700.16	531.3	2012-01-17 00:00:00	260	437296311	adventure-works\\annette0	Assistant	1978-01-29	M	F	2009-12-25	f	50	45	t	9e03395f-4d5d-4a53-880e-174bd8c1db59	2014-06-30 00:00:00	/4/3/1/10/	satisfied	PH1
1602	4	4	260	1638	5	2014-01-02 00:00:00	2014-01-11 00:00:00	34644.225	100	866.1056	2014-01-11 00:00:00	260	437296311	adventure-works\\annette0	Assistant	1978-01-29	M	F	2009-12-25	f	50	45	t	9e03395f-4d5d-4a53-880e-174bd8c1db59	2014-06-30 00:00:00	/4/3/1/10/	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

