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
    medidata_sites_id bigint,
    medidata_sites_name text,
    medidata_sites_etag text,
    medidata_sites_city text,
    medidata_sites_number text,
    medidata_sites_full_description text,
    medidata_sites_country text,
    medidata_sites_postal_code text,
    medidata_sites_address_line_1 text,
    medidata_sites_address_line_2 text,
    medidata_sites_address_line_3 text,
    medidata_sites_state text,
    medidata_sites_fax text,
    medidata_sites_phone text,
    medidata_sites_summary text,
    medidata_sites_uuid text,
    medidata_sites_site_uuid text,
    sites_id bigint,
    sites_study_id bigint,
    sites_depot_id bigint,
    sites_external_id bigint,
    sites_name text,
    sites_active_for_drug_shipping boolean,
    sites_simulated_site boolean,
    sites_supply_plan_id bigint,
    sites_activation_date date,
    shipments_id bigint,
    shipments_tracking_number text,
    shipments_name text,
    shipments_origin_site_id bigint,
    shipments_destination_site_id bigint,
    shipments_origin_depot_id bigint,
    shipments_destination_depot_id bigint,
    shipments_date_shipped timestamp with time zone,
    shipments_date_received timestamp with time zone,
    shipments_shipper_confirmation_code text,
    shipments_site_confirmation_code text,
    shipments_study_id bigint,
    shipments_status bigint,
    shipments_status_changed_at timestamp with time zone,
    shipments_quarantine_id bigint,
    shipments_uuid text,
    shipments_alert_last_sent timestamp with time zone,
    shipments_date_requested timestamp with time zone,
    shipments_manual boolean,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (medidata_sites_id, medidata_sites_name, medidata_sites_etag, medidata_sites_city, medidata_sites_number, medidata_sites_full_description, medidata_sites_country, medidata_sites_postal_code, medidata_sites_address_line_1, medidata_sites_address_line_2, medidata_sites_address_line_3, medidata_sites_state, medidata_sites_fax, medidata_sites_phone, medidata_sites_summary, medidata_sites_uuid, medidata_sites_site_uuid, sites_id, sites_study_id, sites_depot_id, sites_external_id, sites_name, sites_active_for_drug_shipping, sites_simulated_site, sites_supply_plan_id, sites_activation_date, shipments_id, shipments_tracking_number, shipments_name, shipments_origin_site_id, shipments_destination_site_id, shipments_origin_depot_id, shipments_destination_depot_id, shipments_date_shipped, shipments_date_received, shipments_shipper_confirmation_code, shipments_site_confirmation_code, shipments_study_id, shipments_status, shipments_status_changed_at, shipments_quarantine_id, shipments_uuid, shipments_alert_last_sent, shipments_date_requested, shipments_manual, type, branch) FROM stdin;
703	Hackensack University Medical Center	\N	Hackensack	\N		USA					NJ				877446e8-7e5e-4c71-b6c6-569507aed9e7	95230255-0858-41d2-8a29-875370367f74	1339	19	\N	703	\N	f	f	173	2014-02-12	4654		10001	\N	1339	317	\N	2014-07-17 17:38:58-04	2014-07-17 17:49:38-04	\N	\N	19	4	2014-07-17 17:49:38-04	107	edaee31d-db76-41e9-884b-e33cd8b6b3ab	\N	2014-07-17 17:37:38-04	t	satisfied	PH0
0	Hackensack University Medical Center	\N	Hackensack	\N		China					NJ				877446e8-7e5e-4c71-b6c6-569507aed9e7	95230255-0858-41d2-8a29-875370367f74	1339	0	\N	703	\N	t	f	173	2010-01-01	\N		10001	\N	1339	317	\N	2014-07-17 17:38:58-04	2014-07-17 17:49:38-04	\N	\N	19	4	2014-07-17 17:49:38-04	107	edaee31d-db76-41e9-884b-e33cd8b6b3ab	\N	2014-07-17 17:37:38-04	t	excluded	
\.


--
-- PostgreSQL database dump complete
--

