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
    customer_customerid integer,
    customer_personid integer,
    customer_storeid integer,
    customer_territoryid integer,
    customer_rowguid uuid,
    customer_modifieddate timestamp without time zone,
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
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (customer_customerid, customer_personid, customer_storeid, customer_territoryid, customer_rowguid, customer_modifieddate, person_businessentityid, person_persontype, person_namestyle, person_title, person_firstname, person_middlename, person_lastname, person_suffix, person_emailpromotion, person_additionalcontactinfo, person_demographics, person_rowguid, person_modifieddate, type, branch) FROM stdin;
11000	13531	\N	9	477586b3-2977-4e54-b1a8-569ab2c7c4d4	2014-09-12 11:15:07.263	13531	IN	f	\N	Jon	V	Yang	\N	1	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>4751.05</TotalPurchaseYTD><DateFirstPurchase>2001-07-22Z</DateFirstPurchase><BirthDate>1966-04-08Z</BirthDate><MaritalStatus>M</MaritalStatus><YearlyIncome>75001-100000</YearlyIncome><Gender>M</Gender><TotalChildren>2</TotalChildren><NumberChildrenAtHome>0</NumberChildrenAtHome><Education>Bachelors </Education><Occupation>Professional</Occupation><HomeOwnerFlag>1</HomeOwnerFlag><NumberCarsOwned>0</NumberCarsOwned><CommuteDistance>1-2 Miles</CommuteDistance></IndividualSurvey>	66416a79-00c0-4dee-bc3e-662a3d8f6424	2011-06-21 00:00:00	excluded	
11152	17585	\N	1	5ff2b0f5-9765-4b48-bb05-561491d4eeef	2014-09-12 11:15:07.263	17585	IN	f	\N	James	J	Williams	\N	1	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>-2294.99</TotalPurchaseYTD><DateFirstPurchase>2003-07-13Z</DateFirstPurchase><BirthDate>1976-01-10Z</BirthDate><MaritalStatus>S</MaritalStatus><YearlyIncome>25001-50000</YearlyIncome><Gender>M</Gender><TotalChildren>0</TotalChildren><NumberChildrenAtHome>0</NumberChildrenAtHome><Education>High School</Education><Occupation>Skilled Manual</Occupation><HomeOwnerFlag>1</HomeOwnerFlag><NumberCarsOwned>2</NumberCarsOwned><CommuteDistance>5-10 Miles</CommuteDistance></IndividualSurvey>	ec094284-46b8-430c-9ab6-70be19d050b7	2013-06-11 00:00:00	satisfied	PH0
11009	20229	\N	9	aa4fc27f-b78c-4223-bdba-cfd3e3df8884	2014-09-12 11:15:07.263	20229	IN	f	\N	Shannon	C	Carlson	\N	1	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>1304.07</TotalPurchaseYTD><DateFirstPurchase>2001-07-30Z</DateFirstPurchase><BirthDate>1964-04-01Z</BirthDate><MaritalStatus>S</MaritalStatus><YearlyIncome>50001-75000</YearlyIncome><Gender>M</Gender><TotalChildren>0</TotalChildren><NumberChildrenAtHome>0</NumberChildrenAtHome><Education>Bachelors </Education><Occupation>Professional</Occupation><HomeOwnerFlag>0</HomeOwnerFlag><NumberCarsOwned>1</NumberCarsOwned><CommuteDistance>5-10 Miles</CommuteDistance></IndividualSurvey>	468fd07b-e8de-42ef-9409-dfe798abf678	2011-06-29 00:00:00	satisfied	PH1
12482	7717	\N	7	a4be3972-e938-49af-847e-3692219a76e1	2014-09-12 11:15:07.263	7717	IN	f	\N	Jerome	\N	Browning	\N	1	\N	﻿<IndividualSurvey xmlns=http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey><TotalPurchaseYTD>-49.99</TotalPurchaseYTD><DateFirstPurchase>2004-06-27Z</DateFirstPurchase><BirthDate>1964-03-06Z</BirthDate><MaritalStatus>S</MaritalStatus><YearlyIncome>0-25000</YearlyIncome><Gender>M</Gender><TotalChildren>3</TotalChildren><NumberChildrenAtHome>2</NumberChildrenAtHome><Education>Partial High School</Education><Occupation>Manual</Occupation><HomeOwnerFlag>1</HomeOwnerFlag><NumberCarsOwned>1</NumberCarsOwned><CommuteDistance>0-1 Miles</CommuteDistance></IndividualSurvey>	fcd9137f-4a58-4b51-847f-3d27f3b06454	2014-05-27 00:00:00	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

