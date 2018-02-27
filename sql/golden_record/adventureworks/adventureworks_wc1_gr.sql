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
    productvendor_productid integer,
    productvendor_businessentityid integer,
    productvendor_averageleadtime integer,
    productvendor_standardprice numeric,
    productvendor_lastreceiptcost numeric,
    productvendor_lastreceiptdate timestamp without time zone,
    productvendor_minorderqty integer,
    productvendor_maxorderqty integer,
    productvendor_onorderqty integer,
    productvendor_unitmeasurecode character(3),
    productvendor_modifieddate timestamp without time zone,
    vendor_businessentityid integer,
    vendor_accountnumber "AccountNumber",
    vendor_name "Name",
    vendor_creditrating smallint,
    vendor_preferredvendorstatus "Flag",
    vendor_activeflag "Flag",
    vendor_purchasingwebserviceurl character varying(1024),
    vendor_modifieddate timestamp without time zone,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (product_productid, product_name, product_productnumber, product_makeflag, product_finishedgoodsflag, product_color, product_safetystocklevel, product_reorderpoint, product_standardcost, product_listprice, product_size, product_sizeunitmeasurecode, product_weightunitmeasurecode, product_weight, product_daystomanufacture, product_productline, product_class, product_style, product_productsubcategoryid, product_productmodelid, product_sellstartdate, product_sellenddate, product_discontinueddate, product_rowguid, product_modifieddate, productvendor_productid, productvendor_businessentityid, productvendor_averageleadtime, productvendor_standardprice, productvendor_lastreceiptcost, productvendor_lastreceiptdate, productvendor_minorderqty, productvendor_maxorderqty, productvendor_onorderqty, productvendor_unitmeasurecode, productvendor_modifieddate, vendor_businessentityid, vendor_accountnumber, vendor_name, vendor_creditrating, vendor_preferredvendorstatus, vendor_activeflag, vendor_purchasingwebserviceurl, vendor_modifieddate, type, branch) FROM stdin;
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1580	17	47.87	50.2635	2011-08-29 00:00:00	1	5	3	CS 	2011-08-29 00:00:00	1580	LITWARE0001	Litware, Inc.	1	t	t	www.litwareinc.com/	2011-04-25 00:00:00	satisfied	PH0
359	Thin-Jam Hex Nut 9	HJ-1213	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	a63aff3c-4143-4016-bc99-d3f80ec1ade5	2014-02-08 10:01:36.827	359	1496	17	45.41	47.6805	2011-08-29 00:00:00	1	5	3	CS 	2011-08-29 00:00:00	1496	ADVANCED0001	Advanced Bicycles	1	t	t	\N	2011-04-25 00:00:00	satisfied	PH1
317	LL Crankarm	CA-5965	f	f	Black	500	375	0	0	\N	\N	\N	\N	0	\N	L 	\N	\N	\N	2008-04-30 00:00:00	\N	\N	3c9d10b7-a6b2-4774-9963-c19dcee72fea	2014-02-08 10:01:36.827	317	1678	7	25.77	27.0585	2011-08-25 00:00:00	100	1000	\N	EA 	2011-08-25 00:00:00	1678	PROSE0001	Proseware, Inc.	4	f	f	www.proseware.com/	2011-05-09 00:00:00	excluded	
\.


--
-- PostgreSQL database dump complete
--

