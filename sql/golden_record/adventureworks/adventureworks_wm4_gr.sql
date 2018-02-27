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
    product_productid integer,
    product_name "Name",
    product_productnumber character varying(25),
    product_makeflag "Flag",
    product_finishedgoodsflag "Flag",
    product_color character varying(15),
    product_safetystocklevel smallint,
    product_reorderpoint smallint,
    product_standardcost numeric,
    product_listprice numeric,
    product_size character varying(5),
    product_sizeunitmeasurecode character(3),
    product_weightunitmeasurecode character(3),
    product_weight numeric(8,2),
    product_daystomanufacture integer,
    product_productline character(2),
    product_class character(2),
    product_style character(2),
    product_productsubcategoryid integer,
    product_productmodelid integer,
    product_sellstartdate timestamp without time zone,
    product_sellenddate timestamp without time zone,
    product_discontinueddate timestamp without time zone,
    product_rowguid uuid,
    product_modifieddate timestamp without time zone,
    productinventory_productid integer,
    productinventory_locationid smallint,
    productinventory_shelf character varying(10),
    productinventory_bin smallint,
    productinventory_quantity smallint,
    productinventory_rowguid uuid,
    productinventory_modifieddate timestamp without time zone,
    location_locationid integer,
    location_name "Name",
    location_costrate numeric,
    location_availability numeric(8,2),
    location_modifieddate timestamp without time zone,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (product_productid, product_name, product_productnumber, product_makeflag, product_finishedgoodsflag, product_color, product_safetystocklevel, product_reorderpoint, product_standardcost, product_listprice, product_size, product_sizeunitmeasurecode, product_weightunitmeasurecode, product_weight, product_daystomanufacture, product_productline, product_class, product_style, product_productsubcategoryid, product_productmodelid, product_sellstartdate, product_sellenddate, product_discontinueddate, product_rowguid, product_modifieddate, productinventory_productid, productinventory_locationid, productinventory_shelf, productinventory_bin, productinventory_quantity, productinventory_rowguid, productinventory_modifieddate, location_locationid, location_name, location_costrate, location_availability, location_modifieddate, type, branch) FROM stdin;
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	B	1	600	47a24246-6c43-48eb-968f-025738a8a410	2014-08-08 00:00:00	1	Tool Crib	100	0.00	2008-04-30 00:00:00	satisfied	PH1
1	Adjustable Race	AR-5381	t	f	Red	1000	750	0	100	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	A	1	408	47a24246-6c43-48eb-968f-025738a8a410	2014-08-08 00:00:00	1	Tool Crib	0	0.00	2008-04-30 00:00:00	satisfied	PH0
327	Down Tube	DT-2377	t	f	Red	800	600	0	100	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	1dad47dd-e259-42b8-b8b4-15a0b7d21b2f	2014-02-08 10:01:36.827	327	50	B	9	513	a3aad1f8-ba38-4f6c-99d3-dbc5e2bc9774	2008-03-31 00:00:00	50	Subassembly	12.25	120.00	2008-04-30 00:00:00	excluded	
\.


--
-- PostgreSQL database dump complete
--

