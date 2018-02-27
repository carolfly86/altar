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
660	41f93d91-6d13-45ca-8555-59df3de36cf0	Depot5							f	3938fcd1-931b-4e89-9afb-0606751ba064	661	\N	441	660	f	\N	16	37	901	661	\N	1	3e4931d7-88c8-49c0-beb1-eb838a6040a5	441	\N	\N	f	\N	901	\N	\N	2015-07-31	441	6ed31280-acf4-4f2a-b056-d3715988d3b7	Lot17	661		2	2015-03-06	551	51	t	551	Un AT2		508	edd62a4a-7d14-4413-97d8-94c09e661c61		t	f	satisfied	PH1
317	8edb1e2b-d059-49f6-a260-92f88811c801		\N	Floor 8	New York	NY	10003	USA	t	112939d7-fb98-4608-bbbb-bff97b763103	317	0	1000	317	f	ebitzegaio@mdsol.com	153	49	1078	317	\N	0	b09900fa-2de8-477c-978a-8253fa33258f	19	\N	\N	f	\N	1078	\N	\N	2014-10-15	19	a02f8e25-4d9b-4451-995d-009253d988d6	Open Label Lot	317		0	2014-07-30	692	100	t	692	Pamphlet		21	b7ef2bf8-b694-4467-950f-3eb1731cc20a		t	t	excluded	
\.


--
-- PostgreSQL database dump complete
--

