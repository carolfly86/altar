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
-- Name: golden_record; Type: TABLE; Schema: public; Owner: myuser; Tablespace: 
--

CREATE TABLE golden_record (
    medidata_depots_id bigint,
    medidata_depots_uuid text,
    medidata_depots_name text,
    medidata_depots_number text,
    medidata_depots_address_line_2 text,
    medidata_depots_city text,
    medidata_depots_state text,
    medidata_depots_postal_code text,
    medidata_depots_country text,
    medidata_depots_deleted boolean,
    medidata_depots_parent_uuid text,
    depots_id bigint,
    depots_parent_id bigint,
    depots_study_id bigint,
    depots_medidata_depot_id bigint,
    depots_active_for_drug_shipping boolean,
    depots_emails text,
    unnumbered_inventory_items_id bigint,
    unnumbered_inventory_items_quantity bigint,
    unnumbered_inventory_items_lot_id bigint,
    unnumbered_inventory_items_depot_id bigint,
    unnumbered_inventory_items_site_id bigint,
    unnumbered_inventory_items_status bigint,
    unnumbered_inventory_items_uuid text,
    unnumbered_inventory_items_study_id bigint,
    unnumbered_inventory_items_subject_id bigint,
    unnumbered_inventory_items_subject_visit_id bigint,
    unnumbered_inventory_items_redispense boolean,
    unnumbered_inventory_items_quarantine_id bigint,
    lots_id bigint,
    lots_customer_id1 text,
    lots_customer_id2 text,
    lots_expiry_date date,
    lots_study_id bigint,
    lots_uuid text,
    lots_name text,
    lots_depot_id bigint,
    lots_packrun text,
    lots_release_status bigint,
    lots_released_at date,
    lots_article_type_id bigint,
    lots_unnumbered_items_quantity bigint,
    lots_has_unnumbered_items boolean,
    article_types_id bigint,
    article_types_name text,
    article_types_description text,
    article_types_study_design_id bigint,
    article_types_uuid text,
    article_types_internal_inventory_identifier text,
    article_types_is_unnumbered boolean,
    article_types_is_open_label boolean,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (medidata_depots_id, medidata_depots_uuid, medidata_depots_name, medidata_depots_number, medidata_depots_address_line_2, medidata_depots_city, medidata_depots_state, medidata_depots_postal_code, medidata_depots_country, medidata_depots_deleted, medidata_depots_parent_uuid, depots_id, depots_parent_id, depots_study_id, depots_medidata_depot_id, depots_active_for_drug_shipping, depots_emails, unnumbered_inventory_items_id, unnumbered_inventory_items_quantity, unnumbered_inventory_items_lot_id, unnumbered_inventory_items_depot_id, unnumbered_inventory_items_site_id, unnumbered_inventory_items_status, unnumbered_inventory_items_uuid, unnumbered_inventory_items_study_id, unnumbered_inventory_items_subject_id, unnumbered_inventory_items_subject_visit_id, unnumbered_inventory_items_redispense, unnumbered_inventory_items_quarantine_id, lots_id, lots_customer_id1, lots_customer_id2, lots_expiry_date, lots_study_id, lots_uuid, lots_name, lots_depot_id, lots_packrun, lots_release_status, lots_released_at, lots_article_type_id, lots_unnumbered_items_quantity, lots_has_unnumbered_items, article_types_id, article_types_name, article_types_description, article_types_study_design_id, article_types_uuid, article_types_internal_inventory_identifier, article_types_is_unnumbered, article_types_is_open_label, type, branch) FROM stdin;
317	8edb1e2b-d059-49f6-a260-92f88811c801	DepotNY	DNY001	Floor 8	New York	NY	10003	USA	f	112939d7-fb98-4608-bbbb-bff97b763103	317	\N	19	317	f	ebitzegaio@mdsol.com	153	49	1078	317	\N	1	b09900fa-2de8-477c-978a-8253fa33258f	19	\N	\N	f	\N	1078	\N	\N	2014-10-15	19	a02f8e25-4d9b-4451-995d-009253d988d6	Open Label Lot	317		2	2014-07-30	692	100	t	692	Pamphlet		21	b7ef2bf8-b694-4467-950f-3eb1731cc20a		t	t	satisfied	PH0
531	0183d0ae-9b68-4eb7-809c-15e85576e36b	Depot1							f	85fcce02-00d8-4871-934a-7ccd7f101973	531	\N	441	531	t	\N	14	1	890	531	\N	1	9a6889d6-cc9e-4a1b-8264-d3ff91443fa2	441	\N	\N	f	\N	890	\N	\N	2014-06-11	441	a2ea42a1-8ad7-4cb6-82a9-ef696ab362fd	2	531		3	2014-06-11	538	21	t	538	Un AT1		508	56a30a89-059e-44f4-a53d-cd5f2f7fcac2		t	f	satisfied	PH1
545	3023b7ce-dc8e-4db2-92e5-c609a1a4b9c9	Depot1							f	85fcce02-00d8-4871-934a-7ccd7f101973	545	\N	466	545	t	\N	9253	75	1894	545	2397	3	46f42366-822e-4bf8-8347-8967248e5351	466	\N	\N	f	\N	1894	\N	\N	2021-04-30	466	8500b8a6-473d-4ff5-bb22-421001cb82fc	Lot2	545		2	2015-04-01	1336	100	t	1336	Energy drinks		510	fe6603e5-22af-443e-85aa-b9e5f6b37b8c		t	f	satisfied	PH2
1876	cc42ebf9-3e93-4cbe-8966-dd7394dcaadd	Depot1							f	\N	1877	\N	563	1876	t	hvardhinedi@mdsol.com	10113	9965	2104	1877	\N	1	71fbafac-139e-4302-be0c-daa8d064845e	563	\N	\N	f	\N	2104	\N	\N	2022-04-30	563	91d628d4-6808-4bea-914d-6d9e43fc9483	DKG123489	1877		2	2015-05-01	640	10000	t	640	10 MG Zen Active		624	59cda629-5bd2-4c1f-aaba-2173804c5cbd		t	f	satisfied	PH3
1934	af3ee49d-2178-44ea-854d-be1116c1d467	Depot1							f	85fcce02-00d8-4871-934a-7ccd7f101973	1935	\N	382	1934	t	\N	272	5	1060	1935	4187	2	c40f1192-316a-4323-9532-1d49aea15ce5	382	\N	\N	f	\N	1060	\N	\N	2020-07-01	382	cd0d1664-3cfb-4b6a-b353-364d888dbc8d	Lot_with_UnItems	1935	100	2	2014-07-18	691	1000	t	691	glucose monitor		655	ac134184-81c8-48fb-9279-5e488287b0fc		t	t	satisfied	PH4
1934	af3ee49d-2178-44ea-854d-be1116c1d467	Depot1							f	85fcce02-00d8-4871-934a-7ccd7f101973	1935	\N	382	1934	t	\N	133	990	1060	1935	\N	1	3304a142-f28b-4bf7-b0b9-ad28a8d08404	382	\N	\N	f	\N	1060	\N	\N	2020-07-01	382	cd0d1664-3cfb-4b6a-b353-364d888dbc8d	Lot_with_UnItems	1935	100	2	2014-07-18	691	1000	t	691	glucose monitor		655	ac134184-81c8-48fb-9279-5e488287b0fc		t	t	satisfied	PH5
2096	4050d85d-2d76-4ca1-88ca-08217e798bdd	NY Depot	NY Depot		New York	NY	10014	USA	f	\N	2097	\N	692	2096	t	\N	455	2	1438	2097	4584	5	42bfb175-b44c-4f9e-b00a-8f50eb7d52a6	692	25497	26156	f	\N	1438	\N	\N	2025-02-28	692	5637431f-37e5-41b9-8519-f5856a8e6b7b	Unnumbered Lot 2	2097		2	2015-02-05	1157	300	t	1157	syringes		775	4a30e6de-d176-4d8e-9519-0c575b93c929		t	t	satisfied	PH6
2321	a82a8f42-3f08-4965-86d9-644f1356a3d4	Depot2							t	ef2a1f4c-0a83-4fcb-978d-d4daea388d72	2323	\N	585	2321	f	\N	10548	300	2217	2323	\N	1	b2fb6f30-506b-4631-b7a6-8b069a243ced	585	\N	\N	f	\N	2217	\N	\N	2025-06-30	585	dacd63af-06d7-4a2f-8678-d73eeefb2f07	Lot-Syringe-300	2323		2	2015-06-02	680	300	t	680	Syringe		652	6d8196e1-1d2f-4486-bdf6-4d06ba24886e	S-1	t	f	satisfied	PH7
0	8edb1e2b-d059-49f6-a260-92f88811c801	DepotNY	DNY001	Floor 8	New York	NY	10003	USA	f	112939d7-fb98-4608-bbbb-bff97b763103	0	\N	19	317	f		153	0	1078	317	\N	1	b09900fa-2de8-477c-978a-8253fa33258f	0	\N	\N	f	\N	0	\N	\N	1986-01-01	19	a02f8e25-4d9b-4451-995d-009253d988d6	Open Label Lot	317		2	1986-01-01	0	100	t	692			21	b7ef2bf8-b694-4467-950f-3eb1731cc20a		t	t	excluded	
\.


--
-- PostgreSQL database dump complete
--

