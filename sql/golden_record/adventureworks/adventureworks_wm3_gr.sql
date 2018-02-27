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
    productmodel_productmodelid integer,
    productmodel_name "Name",
    productmodel_catalogdescription character varying,
    productmodel_instructions character varying,
    productmodel_rowguid uuid,
    productmodel_modifieddate timestamp without time zone,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO yguo;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: yguo
--

COPY golden_record (product_productid, product_name, product_productnumber, product_makeflag, product_finishedgoodsflag, product_color, product_safetystocklevel, product_reorderpoint, product_standardcost, product_listprice, product_size, product_sizeunitmeasurecode, product_weightunitmeasurecode, product_weight, product_daystomanufacture, product_productline, product_class, product_style, product_productsubcategoryid, product_productmodelid, product_sellstartdate, product_sellenddate, product_discontinueddate, product_rowguid, product_modifieddate, productmodel_productmodelid, productmodel_name, productmodel_catalogdescription, productmodel_instructions, productmodel_rowguid, productmodel_modifieddate, type, branch) FROM stdin;
707	Sport-100 Helmet, Red	HL-U509-R	f	t	Red	4	3	13.0863	34.99	\N	kg 	\N	0.00	0	S 	\N	\N	31	33	2009-05-31 00:00:00	\N	\N	2e1ef41a-c08a-4ff6-8ada-bde58b64a712	2014-02-08 10:01:36.827	33	Sport-100	\N	\N	47f7c450-d16a-4cea-be6e-2d6c8c8f81ee	2011-05-01 00:00:00	excluded	
680	HL Road Frame - Black, 58	FR-R92B-58	t	t	Black	500	375	1059.31	500	58	CM 	KG 	2.00	1	R 	H 	U 	14	6	2009-05-31 00:00:00	\N	\N	43dd68d6-14a4-461f-9069-55309d90ea7e	2014-02-08 10:01:36.827	6	HL Road Frame	\N	\N	4d332ecc-48b3-4e04-b7e7-227f3ac2a7ec	2008-03-31 00:00:00	satisfied	PH0
717	HL Road Frame - Red, 62	FR-R92R-62	t	t	Red	50	375	868.6342	1431.5	62	CM 	KG 	2.00	1	B 	H 	U 	14	6	2011-05-31 00:00:00	\N	\N	052e4f8b-0a2a-46b2-9f42-10febcfae416	2014-02-08 10:01:36.827	6	HL Road Frame	\N	\N	4d332ecc-48b3-4e04-b7e7-227f3ac2a7ec	2008-03-31 00:00:00	satisfied	PH2
749	Road-150 Red, 62	BK-R93R-62	t	t	Red	50	75	2171.2942	500	62	CM 	LB 	15.00	4	B 	H 	U 	2	25	2009-05-31 00:00:00	2012-05-29 00:00:00	\N	bc621e1f-2553-4fdc-b22e-5e44a9003569	2014-02-08 10:01:36.827	25	Road-150	﻿<?xml-stylesheet href="ProductDescription.xsl" type="text/xsl"?><p1:ProductDescription xmlns:p1="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelDescription" xmlns:wm="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelWarrAndMain" xmlns:wf="http://www.adventure-works.com/schemas/OtherFeatures" xmlns:html="http://www.w3.org/1999/xhtml" ProductModelID="25" ProductModelName="Road-150"><p1:Summary><html:p>This bike is ridden by race winners. Developed with the \\n\t\t\tAdventure Works Cycles professional race team, it has a extremely light \\n\t\t\theat-treated aluminum frame, and steering that allows precision control.\\n                        </html:p></p1:Summary><p1:Manufacturer><p1:Name>AdventureWorks</p1:Name><p1:Copyright>2002</p1:Copyright><p1:ProductURL>HTTP://www.Adventure-works.com</p1:ProductURL></p1:Manufacturer><p1:Features>These are the product highlights. \\n                 <wm:Warranty><wm:WarrantyPeriod>4 years</wm:WarrantyPeriod><wm:Description>parts and labor</wm:Description></wm:Warranty><wm:Maintenance><wm:NoOfYears>7 years</wm:NoOfYears><wm:Description>maintenance contact available through dealer or any Adventure Works Cycles retail store.</wm:Description></wm:Maintenance><wf:handlebar>Designed for racers; high-end anatomically shaped bar from aluminum alloy.</wf:handlebar><wf:wheel>Strong wheels with double-walled rims.</wf:wheel><wf:saddle><html:i>Lightweight </html:i> kevlar racing saddle.</wf:saddle><wf:pedal><html:b>Top-of-the-line</html:b> clipless pedals with adjustable tension.</wf:pedal><wf:BikeFrame><html:i>Our lightest and best quality </html:i> aluminum frame made from the newest alloy;\\n\t\t\tit is welded and heat-treated for strength. \\n\t\t\tOur innovative design results in maximum comfort and performance.</wf:BikeFrame></p1:Features><!-- add one or more of these elements... one for each specific product in this product model --><p1:Picture><p1:Angle>front</p1:Angle><p1:Size>small</p1:Size><p1:ProductPhotoID>126</p1:ProductPhotoID></p1:Picture><!-- add any tags in <specifications> --><p1:Specifications> These are the product specifications.\\n<Material>Aluminum</Material><Color>Available in all colors.</Color><ProductLine>Road bike</ProductLine><Style>Unisex</Style><RiderExperience>Intermediate to Professional riders</RiderExperience></p1:Specifications></p1:ProductDescription>	\N	94ffb702-0cbc-4e3f-b840-c51f0d11c8f6	2011-05-01 00:00:00	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

