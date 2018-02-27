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
    address_addressid integer,
    address_addressline1 character varying(60),
    address_addressline2 character varying(60),
    address_city character varying(30),
    address_stateprovinceid integer,
    address_postalcode character varying(15),
    address_spatiallocation character varying(44),
    address_rowguid uuid,
    address_modifieddate timestamp without time zone,
    stateprovince_stateprovinceid integer,
    stateprovince_stateprovincecode character(3),
    stateprovince_countryregioncode character varying(3),
    stateprovince_isonlystateprovinceflag "Flag",
    stateprovince_name "Name",
    stateprovince_territoryid integer,
    stateprovince_rowguid uuid,
    stateprovince_modifieddate timestamp without time zone,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (address_addressid, address_addressline1, address_addressline2, address_city, address_stateprovinceid, address_postalcode, address_spatiallocation, address_rowguid, address_modifieddate, stateprovince_stateprovinceid, stateprovince_stateprovincecode, stateprovince_countryregioncode, stateprovince_isonlystateprovinceflag, stateprovince_name, stateprovince_territoryid, stateprovince_rowguid, stateprovince_modifieddate, type, branch) FROM stdin;
1	1970 Napa Ct.	\N	Bothell	79	98011	E6100000010CAE8BFC28BCE4474067A89189898A5EC0	9aadcb0d-36cf-483f-84d8-585c2d4ec6e9	2007-12-04 00:00:00	79	WA 	US	f	Washington	1	16274df0-6f05-43a6-bc18-ad171017a1eb	2014-02-08 10:17:21.587	excluded	
676	21105, rue de Varenne	\N	Paris	161	75013	E6100000010C1E3FBF66F26B48404227EF0631980240	5964df6a-c654-4ddc-af09-e98deb96d3f7	2013-12-21 10:09:29.423	161	75 	FR	f	Seine (Paris)	7	e117a6fc-24b9-438b-86ff-8455107f4e9f	2008-04-30 00:00:00	satisfied	PH0
\.


--
-- PostgreSQL database dump complete
--

