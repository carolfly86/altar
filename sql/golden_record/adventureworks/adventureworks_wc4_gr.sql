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
1	Adjustable Race	AR-5381	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	694215b7-08f7-4c0d-acb1-d734ba44c0c8	2014-02-08 10:01:36.827	1	1	2011-04-30 00:00:00	4	1	50.26	3.00	0.00	2011-04-23 00:00:00	1	4	4	258	1580	3	2011-04-16 00:00:00	2011-04-25 00:00:00	201.04	16.0832	5.026	2011-04-25 00:00:00	satisfied	PH0
941	Touring Pedal	PD-T852	f	t	Silver/Black	500	375	35.9596	80.99	\N	\N	\N	\N	1	T 	\N	\N	13	53	2013-05-30 00:00:00	\N	\N	6967c816-3ebb-45fa-8547-cef00e08573e	2014-02-08 10:01:36.827	12	28	2011-12-28 00:00:00	550	941	62.9895	550.00	82.00	2011-12-21 00:00:00	12	4	4	254	1628	5	2011-12-14 00:00:00	2011-12-23 00:00:00	34644.225	2771.538	866.1056	2011-12-23 00:00:00	satisfied	PH1
506	Reflector	RF-9198	f	f	\N	1000	750	0	0	\N	\N	\N	\N	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	1c850499-38ed-4c2d-8665-7edb6a7ce93d	2014-02-08 10:01:36.827	20	47	2011-12-29 00:00:00	60	506	9.198	60.00	0.00	2011-12-22 00:00:00	20	4	4	260	1504	1	2011-12-15 00:00:00	2011-12-24 00:00:00	551.88	44.1504	13.797	2011-12-24 00:00:00	satisfied	PH2
908	LL Mountain Seat/Saddle	SE-M236	f	t	\N	500	375	12.0413	27.12	\N	\N	\N	\N	1	M 	L 	\N	15	79	2013-05-30 00:00:00	\N	\N	4dab53c5-31e7-47d6-a5a0-940f8d4dad22	2014-02-08 10:01:36.827	3729	8208	2014-07-31 00:00:00	550	908	21.0945	550.00	0.00	2014-07-24 00:00:00	3729	4	4	255	1570	2	2014-07-17 00:00:00	2014-07-26 00:00:00	50860.425	4068.834	1271.5106	2014-07-26 00:00:00	satisfied	PH3
512	HL Road Rim	RM-R800	f	f	\N	800	600	0	0	\N	\N	G  	400.00	0	\N	\N	\N	\N	\N	2008-04-30 00:00:00	\N	\N	cd9b5c44-fb31-4e0f-9905-3b2086966cc5	2014-02-08 10:01:36.827	5	6	2011-05-14 00:00:00	550	512	37.086	550.00	0.00	2011-05-07 00:00:00	5	4	1	251	1654	4	2011-04-30 00:00:00	2011-05-09 00:00:00	20397.3	1631.784	509.9325	2011-05-09 00:00:00	excluded	
941	Touring Pedal	PD-T852	f	t	Silver/Black	500	375	35.9596	80.99	\N	\N	\N	\N	1	T 	\N	\N	13	53	2013-05-30 00:00:00	\N	\N	6967c816-3ebb-45fa-8547-cef00e08573e	2014-02-08 10:01:36.827	12	28	2011-12-28 00:00:00	4	941	62.9895	550.00	82.00	2011-12-21 00:00:00	12	4	4	254	1628	5	2011-12-14 00:00:00	2011-12-23 00:00:00	34644.225	2771.538	866.1056	2011-12-23 00:00:00	satisfied	PH4
\.


--
-- PostgreSQL database dump complete
--

