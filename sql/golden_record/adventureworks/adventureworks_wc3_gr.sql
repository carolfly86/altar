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
    purchaseorderdetail_purchaseorderid integer,
    purchaseorderdetail_purchaseorderdetailid integer,
    purchaseorderdetail_duedate timestamp without time zone,
    purchaseorderdetail_orderqty smallint,
    purchaseorderdetail_productid integer,
    purchaseorderdetail_unitprice numeric,
    purchaseorderdetail_receivedqty numeric(8,2),
    purchaseorderdetail_rejectedqty numeric(8,2),
    purchaseorderdetail_modifieddate timestamp without time zone,
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
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (product_productid, product_name, product_productnumber, product_makeflag, product_finishedgoodsflag, product_color, product_safetystocklevel, product_reorderpoint, product_standardcost, product_listprice, product_size, product_sizeunitmeasurecode, product_weightunitmeasurecode, product_weight, product_daystomanufacture, product_productline, product_class, product_style, product_productsubcategoryid, product_productmodelid, product_sellstartdate, product_sellenddate, product_discontinueddate, product_rowguid, product_modifieddate, purchaseorderdetail_purchaseorderid, purchaseorderdetail_purchaseorderdetailid, purchaseorderdetail_duedate, purchaseorderdetail_orderqty, purchaseorderdetail_productid, purchaseorderdetail_unitprice, purchaseorderdetail_receivedqty, purchaseorderdetail_rejectedqty, purchaseorderdetail_modifieddate, purchaseorderheader_purchaseorderid, purchaseorderheader_revisionnumber, purchaseorderheader_status, purchaseorderheader_employeeid, purchaseorderheader_vendorid, purchaseorderheader_shipmethodid, purchaseorderheader_orderdate, purchaseorderheader_shipdate, purchaseorderheader_subtotal, purchaseorderheader_taxamt, purchaseorderheader_freight, purchaseorderheader_modifieddate, type, branch) FROM stdin;
523	LL Spindle/Axle	SD-2342	f	f	\N	500	375	0	0	\N	\N	\N	\N	0	\N	L 	\N	\N	\N	2008-04-30 00:00:00	\N	\N	d2bd1f55-2cd4-4998-89fa-28ff2e28de2c	2014-02-08 10:01:36.827	17	35	2011-12-29 00:00:00	550	523	10.731	550.00	0.00	2011-12-22 00:00:00	17	4	4	255	1560	5	2011-12-15 00:00:00	2011-12-24 00:00:00	13669.425	1093.554	341.7356	2011-12-24 00:00:00	excluded	
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	2011-04-30 00:00:00	4	1	50.26	3.00	0.00	2011-04-23 00:00:00	1	4	4	258	1580	3	2011-04-16 00:00:00	2011-04-25 00:00:00	201.04	16.0832	5.026	2011-04-25 00:00:00	satisfied	PH0
879	All-Purpose Bike Stand	ST-1401	f	t	\N	4	3	59.466	159	\N	\N	\N	\N	0	M 	\N	\N	27	122	2013-05-30 00:00:00	\N	\N	c7bb564b-a637-40f5-b21b-cbf7e4f713be	2014-02-08 10:01:36.827	4011	8840	2014-07-24 00:00:00	400	879	59.46	400.00	0.00	2015-08-12 12:25:46.47	4011	10	2	254	1546	3	2014-06-24 00:00:00	2014-07-19 00:00:00	54492.5	4359.4	1089.85	2015-08-12 12:25:46.47	satisfied	PH1
506	Reflector	RF-9198	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	1c850499-38ed-4c2d-8665-7edb6a7ce93d	2014-02-08 10:01:36.827	20	47	2011-12-29 00:00:00	60	506	9.198	60.00	0.00	2011-12-22 00:00:00	20	4	4	260	1504	1	2011-12-15 00:00:00	2011-12-24 00:00:00	551.88	44.1504	13.797	2011-12-24 00:00:00	satisfied	PH2
512	HL Road Rim	RM-R800	f	f	\N	800	600	0	0	\N	\N	G  	400.00	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	cd9b5c44-fb31-4e0f-9905-3b2086966cc5	2014-02-08 10:01:36.827	5	6	2011-05-14 00:00:00	550	512	37.086	550.00	0.00	2011-05-07 00:00:00	5	4	4	251	1654	4	2011-04-30 00:00:00	2011-05-09 00:00:00	20397.3	1631.784	509.9325	2011-05-09 00:00:00	satisfied	PH3
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	2011-04-30 00:00:00	4	1	50.26	3.00	0.00	2011-04-23 00:00:00	1	4	4	258	1580	3	2011-04-16 00:00:00	2011-04-25 00:00:00	201.04	16.0832	5.026	2011-04-25 00:00:00	satisfied	PH4
317	LL Crankarm	CA-5965	f	f	Black	500	375	0	0	\N	\N	\N	\N	0	\N	L 	\N	\N	\N	2008-04-30 00:00:00	\N	\N	3c9d10b7-a6b2-4774-9963-c19dcee72fea	2014-02-08 10:01:36.827	7	8	2011-05-14 00:00:00	550	317	27.0585	550.00	0.00	2011-05-07 00:00:00	7	4	4	255	1678	3	2011-04-30 00:00:00	2011-05-09 00:00:00	58685.55	4694.844	1467.1388	2011-05-09 00:00:00	satisfied	PH5
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	2011-04-30 00:00:00	4	1	50.26	3.00	0.00	2011-04-23 00:00:00	1	4	4	258	1580	3	2011-04-16 00:00:00	2011-04-25 00:00:00	201.04	16.0832	5.026	2011-04-25 00:00:00	satisfied	PH6
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	2011-04-30 00:00:00	4	1	50.26	3.00	0.00	2011-04-23 00:00:00	1	4	4	258	1580	3	2011-04-16 00:00:00	2011-04-25 00:00:00	201.04	16.0832	5.026	2011-04-25 00:00:00	satisfied	PH7
\.


--
-- PostgreSQL database dump complete
--

