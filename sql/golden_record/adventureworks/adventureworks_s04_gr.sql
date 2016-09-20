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
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (salesorderheader_salesorderid, salesorderheader_revisionnumber, salesorderheader_orderdate, salesorderheader_duedate, salesorderheader_shipdate, salesorderheader_status, salesorderheader_onlineorderflag, salesorderheader_purchaseordernumber, salesorderheader_accountnumber, salesorderheader_customerid, salesorderheader_salespersonid, salesorderheader_territoryid, salesorderheader_billtoaddressid, salesorderheader_shiptoaddressid, salesorderheader_shipmethodid, salesorderheader_creditcardid, salesorderheader_creditcardapprovalcode, salesorderheader_currencyrateid, salesorderheader_subtotal, salesorderheader_taxamt, salesorderheader_freight, salesorderheader_totaldue, salesorderheader_comment, salesorderheader_rowguid, salesorderheader_modifieddate, type, branch) FROM stdin;
43697	8	2011-05-31 00:00:00	2011-06-12 00:00:00	2011-06-07 00:00:00	5	t	\N	10-4030-021768	21768	\N	6	23148	23148	1	4319	530200Vi22686	4	3578.27	286.2616	89.4568	3953.9884	\N	bc58017d-0735-4e0e-8930-292290c37abd	2011-06-07 00:00:00	excluded	
46929	8	2012-06-30 00:00:00	2012-07-12 00:00:00	2012-07-07 00:00:00	5	f	PO20242176175	10-4020-000390	30058	278	6	510	510	5	3088	55052Vi16259	4728	24.2945	2.3971	0.7491	27.4407	\N	812dac78-3c56-4bbc-94d8-dd5ca1c8d16c	2012-07-07 00:00:00	satisfied	PH0
46569	8	2012-05-25 00:00:00	2012-06-06 00:00:00	2012-06-01 00:00:00	5	t	\N	10-4030-012450	12450	\N	4	24602	24602	1	3008	132353Vi15778	\N	3578.27	286.2616	89.4568	3953.9884	\N	ad8c0ce5-e3e9-426e-a955-7d948617f754	2012-06-01 00:00:00	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

