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

COPY golden_record (product_productid, product_name, product_productnumber, product_makeflag, product_finishedgoodsflag, product_color, product_safetystocklevel, product_reorderpoint, product_standardcost, product_listprice, product_size, product_sizeunitmeasurecode, product_weightunitmeasurecode, product_weight, product_daystomanufacture, product_productline, product_class, product_style, product_productsubcategoryid, product_productmodelid, product_sellstartdate, product_sellenddate, product_discontinueddate, product_rowguid, product_modifieddate, salesorderdetail_salesorderid, salesorderdetail_salesorderdetailid, salesorderdetail_carriertrackingnumber, salesorderdetail_orderqty, salesorderdetail_productid, salesorderdetail_specialofferid, salesorderdetail_unitprice, salesorderdetail_unitpricediscount, salesorderdetail_rowguid, salesorderdetail_modifieddate, type, branch) FROM stdin;
716	Long-Sleeve Logo Jersey, XL	LJ-0192-X	f	t	Multi	4	3	38.4923	49.99	XL	\N	\N	\N	0	S 	\N	U 	21	11	2011-05-31 00:00:00	\N	\N	6ec47ec9-c041-4dda-b686-2125d539ce9b	2014-02-08 10:01:36.827	43659	9	4911-403C-98	1	716	1	28.8404	0	aa542630-bdcd-4ce5-89a0-c1bf82747725	2011-05-31 00:00:00	excluded	
747	HL Mountain Frame - Black, 38	FR-M94B-38	t	t	Black	500	375	739.041	1349.6	38	CM 	LB 	2.68	2	M 	H 	U 	12	5	2011-05-31 00:00:00	\N	\N	0c548577-3171-4ce2-b9a0-1ed526849de8	2014-02-08 10:01:36.827	43661	17	4E0A-4F89-AE	2	747	1	714.7043	0	b136852e-24c9-4006-8048-b14aefe6c337	2011-05-31 00:00:00	satisfied	PH0
\.


--
-- PostgreSQL database dump complete
--

