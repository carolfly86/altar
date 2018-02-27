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
    inventory_items_location text,
    inventory_items_subject_visit_id bigint,
    inventory_items_redispense boolean,
    inventory_items_status_changed_at timestamp with time zone,
    inventory_items_quarantine_id bigint,
    inventory_items_uuid text,
    inventory_items_packlist_id bigint,
    inventory_items_expiry_date date,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (lots_id, lots_customer_id1, lots_customer_id2, lots_expiry_date, lots_study_id, lots_uuid, lots_name, lots_depot_id, lots_packrun, lots_release_status, lots_released_at, lots_article_type_id, lots_unnumbered_items_quantity, lots_has_unnumbered_items, inventory_items_id, inventory_items_article_type_id, inventory_items_lot_id, inventory_items_depot_id, inventory_items_site_id, inventory_items_status, inventory_items_subject_id, inventory_items_study_id, inventory_items_item_number, inventory_items_sequence_number, inventory_items_location, inventory_items_subject_visit_id, inventory_items_redispense, inventory_items_status_changed_at, inventory_items_quarantine_id, inventory_items_uuid, inventory_items_packlist_id, inventory_items_expiry_date, type, branch) FROM stdin;
89	\N	\N	2021-12-31	46	6f7c3f4c-556c-4357-a5f2-7c7c5ce807a2	Lot1	133		2	2013-10-23	\N	\N	f	1810255	94	89	133	\N	1	\N	46	Item-4	4	\N	\N	f	\N	\N	180a003b-51d9-4272-9d16-5bba2ac0f3d5	89	2021-12-31	satisfied	PH0
412	\N	\N	2023-02-07	10	23ecf4dc-6024-4a06-86e2-3b7d258246a2	Test Lot	667		2	2014-02-26	\N	\N	f	5591376	51	412	667	2634	4	\N	10	Item-0	0	\N	\N	f	2014-02-26 17:45:25-05	\N	e2a603d6-a0b3-4c5f-873a-3b332639c6d0	413	2023-02-07	satisfied	PH1
89	\N	\N	2021-12-31	0	6f7c3f4c-556c-4357-a5f2-7c7c5ce807a2	Lot1	133		2	2013-10-23	\N	\N	f	1810255	94	89	133	0	1	\N	46	Item-4	4	\N	\N	f	\N	\N	180a003b-51d9-4272-9d16-5bba2ac0f3d5	89	2021-12-31	excluded	
\.


--
-- PostgreSQL database dump complete
--

