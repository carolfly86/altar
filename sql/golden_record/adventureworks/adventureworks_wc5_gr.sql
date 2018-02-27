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
    salesorderdetail_salesorderid integer,
    salesorderdetail_salesorderdetailid integer,
    salesorderdetail_carriertrackingnumber character varying(25),
    salesorderdetail_orderqty smallint,
    salesorderdetail_productid integer,
    salesorderdetail_specialofferid integer,
    salesorderdetail_unitprice numeric,
    salesorderdetail_unitpricediscount numeric,
    salesorderdetail_rowguid uuid,
    salesorderdetail_modifieddate timestamp without time zone,
    salesorderheader_salesorderid integer,
    salesorderheader_revisionnumber smallint,
    salesorderheader_orderdate timestamp without time zone,
    salesorderheader_duedate timestamp without time zone,
    salesorderheader_shipdate timestamp without time zone,
    salesorderheader_status smallint,
    salesorderheader_onlineorderflag "Flag",
    salesorderheader_purchaseordernumber "OrderNumber",
    salesorderheader_accountnumber "AccountNumber",
    salesorderheader_customerid integer,
    salesorderheader_salespersonid integer,
    salesorderheader_territoryid integer,
    salesorderheader_billtoaddressid integer,
    salesorderheader_shiptoaddressid integer,
    salesorderheader_shipmethodid integer,
    salesorderheader_creditcardid integer,
    salesorderheader_creditcardapprovalcode character varying(15),
    salesorderheader_currencyrateid integer,
    salesorderheader_subtotal numeric,
    salesorderheader_taxamt numeric,
    salesorderheader_freight numeric,
    salesorderheader_totaldue numeric,
    salesorderheader_comment character varying(128),
    salesorderheader_rowguid uuid,
    salesorderheader_modifieddate timestamp without time zone,
    creditcard_creditcardid integer,
    creditcard_cardtype character varying(50),
    creditcard_cardnumber character varying(25),
    creditcard_expmonth smallint,
    creditcard_expyear smallint,
    creditcard_modifieddate timestamp without time zone,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (salesorderdetail_salesorderid, salesorderdetail_salesorderdetailid, salesorderdetail_carriertrackingnumber, salesorderdetail_orderqty, salesorderdetail_productid, salesorderdetail_specialofferid, salesorderdetail_unitprice, salesorderdetail_unitpricediscount, salesorderdetail_rowguid, salesorderdetail_modifieddate, salesorderheader_salesorderid, salesorderheader_revisionnumber, salesorderheader_orderdate, salesorderheader_duedate, salesorderheader_shipdate, salesorderheader_status, salesorderheader_onlineorderflag, salesorderheader_purchaseordernumber, salesorderheader_accountnumber, salesorderheader_customerid, salesorderheader_salespersonid, salesorderheader_territoryid, salesorderheader_billtoaddressid, salesorderheader_shiptoaddressid, salesorderheader_shipmethodid, salesorderheader_creditcardid, salesorderheader_creditcardapprovalcode, salesorderheader_currencyrateid, salesorderheader_subtotal, salesorderheader_taxamt, salesorderheader_freight, salesorderheader_totaldue, salesorderheader_comment, salesorderheader_rowguid, salesorderheader_modifieddate, creditcard_creditcardid, creditcard_cardtype, creditcard_cardnumber, creditcard_expmonth, creditcard_expyear, creditcard_modifieddate, type, branch) FROM stdin;
43875	803	CE1F-4E31-89	12	773	2	1971.9942	0.02	b8a964d9-3be7-4d6e-a329-5553e9b5b241	2011-07-01 00:00:00	43875	8	2011-07-01 00:00:00	2011-07-13 00:00:00	2011-07-08 00:00:00	5	f	PO12586178184	10-4020-000278	29624	279	5	938	30	5	204	116188Vi1051	\N	121761.9396	11871.5033	3709.8448	137343.2877	\N	8ad47dfb-4d6c-4354-ad25-9e3e64af0c64	2011-07-08 00:00:00	204	Distinguish	55556333798473	4	2005	2011-07-01 00:00:00	satisfied	PH0
43875	794	CE1F-4E31-89	6	778	1	2024.994	0	e9e6b048-930a-43c0-826d-347a1f29c7cc	2011-07-01 00:00:00	43875	8	2011-07-01 00:00:00	2011-07-13 00:00:00	2011-07-08 00:00:00	5	f	PO12586178184	10-4020-000278	29624	279	5	938	30	5	204	116188Vi1051	\N	121761.9396	11871.5033	3709.8448	137343.2877	\N	8ad47dfb-4d6c-4354-ad25-9e3e64af0c64	2011-07-08 00:00:00	204	Distinguish	55556333798473	4	2005	2011-07-01 00:00:00	satisfied	PH1
43659	1	4911-403C-98	1	776	1	2024.994	0	b207c96d-d9e6-402b-8470-2cc176c42283	2011-05-31 00:00:00	43659	8	2011-05-31 00:00:00	2011-06-12 00:00:00	2011-06-07 00:00:00	5	f	PO522145787	10-4020-000676	29825	279	5	985	985	5	16281	105041Vi84182	\N	20565.6206	1971.5149	616.0984	23153.2339	\N	79b65321-39ca-4115-9cba-8fe0903e12e6	2011-06-07 00:00:00	16281	ColonialVoice	77777462752259	2	2007	2011-05-31 00:00:00	satisfied	PH2
43664	53	2F44-4BA1-BB	1	772	1	2039.994	0	22db5fa8-8c63-4a68-a038-435efd6d7ea2	2011-05-31 00:00:00	43664	8	2011-05-31 00:00:00	2011-06-12 00:00:00	2011-06-07 00:00:00	5	f	PO16617121983	10-4020-000397	29898	280	1	876	876	5	806	95555Vi4081	\N	24432.6088	2344.9921	732.81	27510.4109	\N	22a8a5da-8c22-42ad-9241-839489b6ef0d	2011-06-07 00:00:00	806	ColonialVoice	77779337333220	7	2008	2011-05-31 00:00:00	satisfied	PH3
43660	13	6431-4D57-83	1	762	1	419.4589	0	419a1302-ac7a-4044-97b2-66d9d14cd02e	2011-05-31 00:00:00	43660	8	2011-05-31 00:00:00	2011-06-12 00:00:00	2011-06-07 00:00:00	4	f	PO18850127500	10-4020-000117	29672	279	1	921	921	5	5618	115213Vi29411	\N	1294.2529	124.2483	38.8276	1457.3288	\N	738dc42d-d03b-48a1-9822-f95a67ea7389	2011-06-07 00:00:00	5618	Vista	11118446131713	4	2007	2011-05-31 00:00:00	excluded	
\.


--
-- PostgreSQL database dump complete
--

