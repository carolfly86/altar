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
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (salesorderdetail_salesorderid, salesorderdetail_salesorderdetailid, salesorderdetail_carriertrackingnumber, salesorderdetail_orderqty, salesorderdetail_productid, salesorderdetail_specialofferid, salesorderdetail_unitprice, salesorderdetail_unitpricediscount, salesorderdetail_rowguid, salesorderdetail_modifieddate, type, branch) FROM stdin;
43659	8	4911-403C-98	3	714	1	28.8404	0	e9d54907-e7b7-4969-80d9-76ba69f8a836	2011-05-31 00:00:00	excluded	
43659	1	4911-403C-98	1	776	1	2024.994	0	b207c96d-d9e6-402b-8470-2cc176c42283	2011-05-31 00:00:00	satisfied	PH0
51081	35559	EDBF-4FE1-8F	1	989	1	323.994	0	ca582a90-527f-40eb-a672-0bccbe5b15ae	2013-05-30 00:00:00	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

