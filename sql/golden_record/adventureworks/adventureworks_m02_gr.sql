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
    person_businessentityid integer,
    person_persontype character(2),
    person_namestyle "NameStyle",
    person_title character varying(8),
    person_firstname "Name",
    person_middlename "Name",
    person_lastname "Name",
    person_suffix character varying(10),
    person_emailpromotion integer,
    person_additionalcontactinfo text,
    person_demographics text,
    person_rowguid uuid,
    person_modifieddate timestamp without time zone,
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

COPY golden_record (person_businessentityid, person_persontype, person_namestyle, person_title, person_firstname, person_middlename, person_lastname, person_suffix, person_emailpromotion, person_additionalcontactinfo, person_demographics, person_rowguid, person_modifieddate, employee_businessentityid, employee_nationalidnumber, employee_loginid, employee_jobtitle, employee_birthdate, employee_maritalstatus, employee_gender, employee_hiredate, employee_salariedflag, employee_vacationhours, employee_sickleavehours, employee_currentflag, employee_rowguid, employee_modifieddate, employee_organizationnode, type, branch) FROM stdin;
2	EM	f	\N	Terri	Lee	Duffy	\N	1	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>	d8763459-8aa8-47cc-aff7-c9079af79033	2008-01-24 00:00:00	2	245797967	adventure-works\\terri0	Vice President of Engineering	1971-08-01	S	F	2008-01-31	t	1	20	t	45e8f437-670d-4409-93cb-f9424a40d6ee	2014-06-30 00:00:00	/1/	excluded	
3	EM	f	\N	Roberto	\N	Tamburello	\N	0	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>	e1a2555e-0828-434b-a33b-6f38136a37de	2007-11-04 00:00:00	3	509647174	adventure-works\\roberto0	Engineering Manager	1974-11-12	M	M	2007-11-11	t	2	21	t	9bbbfb2c-efbb-4217-9ab7-f97689328841	2014-06-30 00:00:00	/1/1/	satisfied	PH0
11	EM	f	\N	Ovidiu	V	Cracium	\N	0	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>	d2cc2577-ef6b-4408-bd8c-747337fe5645	2010-11-28 00:00:00	11	974026903	adventure-works\\ovidiu0	Senior Tool Designer	1978-01-17	S	M	2010-12-05	f	7	23	t	f68c7c19-fac1-438c-9bb7-ac33fcc341c3	2014-06-30 00:00:00	/1/1/5/	satisfied	PH1
1	EM	f	\N	Ken	J	Sánchez	\N	0	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>	92c4279f-1207-48a3-8448-4636514eb7e2	2009-01-07 00:00:00	1	295847284	adventure-works\\ken0	Chief Executive Officer	1969-01-29	S	M	2009-01-14	t	99	69	t	f01251e5-96a3-448d-981e-0f99d789110d	2014-06-30 00:00:00	/	satisfied	PH2
6	EM	f	Mr.	Jossef	H	Goldberg	\N	0	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>	0dea28fd-effe-482a-afd3-b7e8f199d56f	2013-12-16 00:00:00	6	998320692	adventure-works\\jossef0	Design Engineer	1959-03-11	M	M	2008-01-24	t	6	23	t	e39056f1-9cd5-478d-8945-14aca7fbdcdd	2014-06-30 00:00:00	/1/1/3/	satisfied	PH3
5	EM	f	Ms.	Gail	A	Erickson	\N	0	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>0</TotalPurchaseYTD></IndividualSurvey>	f3a3f6b4-ae3b-430c-a754-9f2231ba6fef	2007-12-30 00:00:00	5	695256908	adventure-works\\gail0	Design Engineer	1952-09-27	M	F	2008-01-06	t	5	22	t	ec84ae09-f9b8-4a15-b4a9-6ccbab919b08	2014-06-30 00:00:00	/1/1/2/	satisfied	PH4
\.


--
-- PostgreSQL database dump complete
--

