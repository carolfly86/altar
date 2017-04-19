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
    medidata_depots_city text,
    medidata_depots_state text,
    medidata_depots_country text,
    medidata_depots_deleted boolean,
    medidata_depots_parent_uuid text,
    depots_id bigint,
    depots_parent_id bigint,
    depots_study_id bigint,
    depots_medidata_depot_id bigint,
    depots_active_for_drug_shipping boolean,
    depots_emails text,
    inventory_items_id bigint,
    inventory_items_article_type_id bigint,
    inventory_items_lot_id bigint,
    inventory_items_depot_id bigint,
    inventory_items_site_id bigint,
    inventory_items_status bigint,
    inventory_items_subject_id bigint,
    inventory_items_study_id bigint,
    inventory_items_item_number text,
    inventory_items_sequence_number bigint,
    inventory_items_subject_visit_id bigint,
    inventory_items_redispense boolean,
    inventory_items_status_changed_at timestamp with time zone,
    inventory_items_quarantine_id bigint,
    inventory_items_uuid text,
    inventory_items_packlist_id bigint,
    inventory_items_expiry_date date,
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

COPY golden_record (medidata_depots_id, medidata_depots_uuid, medidata_depots_name, medidata_depots_number, medidata_depots_city, medidata_depots_state, medidata_depots_country, medidata_depots_deleted, medidata_depots_parent_uuid, depots_id, depots_parent_id, depots_study_id, depots_medidata_depot_id, depots_active_for_drug_shipping, depots_emails, inventory_items_id, inventory_items_article_type_id, inventory_items_lot_id, inventory_items_depot_id, inventory_items_site_id, inventory_items_status, inventory_items_subject_id, inventory_items_study_id, inventory_items_item_number, inventory_items_sequence_number, inventory_items_subject_visit_id, inventory_items_redispense, inventory_items_status_changed_at, inventory_items_quarantine_id, inventory_items_uuid, inventory_items_packlist_id, inventory_items_expiry_date, lots_id, lots_customer_id1, lots_customer_id2, lots_expiry_date, lots_study_id, lots_uuid, lots_name, lots_depot_id, lots_packrun, lots_release_status, lots_released_at, lots_article_type_id, lots_unnumbered_items_quantity, lots_has_unnumbered_items, article_types_id, article_types_name, article_types_description, article_types_study_design_id, article_types_uuid, article_types_internal_inventory_identifier, article_types_is_unnumbered, article_types_is_open_label, type, branch) FROM stdin;
709	5eccfaa2-eb18-4af5-8c66-b33efde87f12	Depot 2					f	01f8091b-3d64-4cf9-be74-f88ec616bb13	710	\N	441	709	f	\N	5761434	451	883	710	\N	1	\N	441	Item-6129	60139	\N	f	\N	\N	649602e3-468b-4550-8995-43f14c397472	418	2020-06-30	883	\N	\N	2020-06-30	441	25e53b84-9422-4a2b-afcb-20a56830e502	LotU11	710		3	2014-06-18	538	1	t	538	Un AT1		508	56a30a89-059e-44f4-a53d-cd5f2f7fcac2		t	f	satisfied	PH1
531	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	excluded	
531	0183d0ae-9b68-4eb7-809c-15e85576e36b	Depot1					f	85fcce02-00d8-4871-934a-7ccd7f101973	531	\N	441	531	t	\N	5761399	451	765	531	\N	6	\N	441	Item-6094	60104	\N	f	\N	\N	92933c0c-fb1b-4de0-819a-948aae620eb7	418	2020-04-30	765	\N	\N	2020-04-30	441	cbc6ae0f-6c23-4020-928c-42c3212faacf	LotU2	531	501	2	2014-04-29	538	\N	t	538	Un AT1		508	56a30a89-059e-44f4-a53d-cd5f2f7fcac2		t	f	satisfied	PH0
531	46ba6192-7393-41c3-bc25-8c25ed842f5a	Depot141					f	226cebc5-c126-4115-888c-4de89bd886fd	711	\N	441	710	f	\N	5761432	451	902	711	\N	1	\N	441	Item-6127	60137	\N	f	\N	\N	dd5240b4-9e8a-4c66-bdae-836522e4b558	418	2014-06-27	902	\N	\N	2020-06-30	441	2894b2f4-bbf5-4f47-b57d-64f3ad1616cf	Lot302	711		2	2014-07-15	538	2	t	538	Un AT1		508	56a30a89-059e-44f4-a53d-cd5f2f7fcac2		t	f	satisfied	PH2
531	0183d0ae-9b68-4eb7-809c-15e85576e36b	Depot1					f	85fcce02-00d8-4871-934a-7ccd7f101973	531	\N	441	531	t	\N	5761408	451	933	531	\N	1	\N	441	Item-6103	60113	\N	f	\N	\N	d2fafd7d-5919-4aa3-b997-44c4a49354cc	418	2020-06-30	933	\N	\N	2020-06-30	441	9ad68a40-d01f-4c4e-98a6-6a76964d5be5	Lot2020	531		1	\N	538	1	t	538	Un AT1		508	56a30a89-059e-44f4-a53d-cd5f2f7fcac2		t	f	satisfied	PH3
\.


--
-- PostgreSQL database dump complete
--

