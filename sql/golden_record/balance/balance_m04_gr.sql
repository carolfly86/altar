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
    subjects_id bigint,
    subjects_stratum_id bigint,
    subjects_regime_id bigint,
    subjects_dummy_regime_id bigint,
    subjects_site_id bigint,
    subjects_external_id text,
    subjects_remove_from_rand boolean,
    subjects_study_id bigint,
    subjects_random_regime_selector bigint,
    subjects_ranked_regimes text,
    subjects_rand_second_best_prob bigint,
    subjects_remove_from_rand_reason text,
    subjects_comment text,
    subjects_randomized_at timestamp with time zone,
    subjects_dispensed_item_unblinded boolean,
    subjects_study_design_history_id bigint,
    subjects_removed_from_predictive_shipping boolean,
    subjects_removed_from_dispensing boolean,
    subjects_rand_id text,
    subjects_created_at timestamp with time zone,
    subjects_uuid text,
    subjects_titration_level_id bigint,
    subjects_second_best_tiebreak bigint,
    subjects_subject_identifier text,
    subjects_forced_randomization boolean,
    subjects_probability_of_cr bigint,
    subjects_rand_method_selector bigint,
    subjects_cr_or_tiebreak_arm_selector bigint,
    sites_id bigint,
    sites_study_id bigint,
    sites_depot_id bigint,
    sites_external_id bigint,
    sites_name text,
    sites_active_for_drug_shipping boolean,
    sites_simulated_site boolean,
    sites_supply_plan_id bigint,
    sites_activation_date date,
    medidata_sites_id bigint,
    medidata_sites_name text,
    medidata_sites_etag text,
    medidata_sites_city text,
    medidata_sites_number text,
    medidata_sites_country text,
    medidata_sites_state text,
    medidata_sites_phone text,
    medidata_sites_summary text,
    medidata_sites_uuid text,
    medidata_sites_site_uuid text,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (subjects_id, subjects_stratum_id, subjects_regime_id, subjects_dummy_regime_id, subjects_site_id, subjects_external_id, subjects_remove_from_rand, subjects_study_id, subjects_random_regime_selector, subjects_ranked_regimes, subjects_rand_second_best_prob, subjects_remove_from_rand_reason, subjects_comment, subjects_randomized_at, subjects_dispensed_item_unblinded, subjects_study_design_history_id, subjects_removed_from_predictive_shipping, subjects_removed_from_dispensing, subjects_rand_id, subjects_created_at, subjects_uuid, subjects_titration_level_id, subjects_second_best_tiebreak, subjects_subject_identifier, subjects_forced_randomization, subjects_probability_of_cr, subjects_rand_method_selector, subjects_cr_or_tiebreak_arm_selector, sites_id, sites_study_id, sites_depot_id, sites_external_id, sites_name, sites_active_for_drug_shipping, sites_simulated_site, sites_supply_plan_id, sites_activation_date, medidata_sites_id, medidata_sites_name, medidata_sites_etag, medidata_sites_city, medidata_sites_number, medidata_sites_country, medidata_sites_state, medidata_sites_phone, medidata_sites_summary, medidata_sites_uuid, medidata_sites_site_uuid, type, branch) FROM stdin;
13779	955	282	\N	1341	3	t	190	1	--- \n- - Placebo\n  - 1.09090909\n- - Active\n  - 10.90909091\n	15	Non-participant	\N	2013-11-12 22:06:03-05	f	61	t	t	\N	2013-11-12 22:06:03-05	bde5bee1-36f9-4473-8d5e-6e8be0e894c3	\N	\N	003	f	\N	\N	\N	1341	190	\N	1244	\N	f	f	\N	\N	1244	Study Site 1	\N	\N	ss-001	\N	\N	\N	\N	67279a1f-0f2a-4976-b6f2-59edda81890c	7bba4881-7d0b-4967-a704-e671105ea962	excluded	
14165	400	100	\N	1551	119	f	38	12	--- \n- - Arm 1\n  - 0.06103494\n- - Arm 2\n  - 0.12770161\n	15	\N	\N	2013-11-22 15:52:08-05	f	78	f	f	\N	2013-11-22 15:52:07-05	b7b901ba-9cf0-4835-8a5a-1ce4b1024b93	\N	\N	Subject_119	f	\N	\N	\N	1551	38	\N	792	\N	f	f	121	\N	792	Automated Site2001	\N		\N	USA				9827a3f0-45c7-409e-bf8c-23ddd03b050b	747c8c1a-accf-4ca1-8865-983568cb94fc	satisfied	PH0
278	\N	14	\N	9	28	f	1	\N	\N	\N	\N	\N	2013-10-08 22:44:26-04	f	\N	f	f	143237	2013-10-08 22:44:26-04	d40afeb8-f01e-4e18-ba6a-d36120a1618a	\N	\N	Subject_28	f	\N	\N	\N	9	1	12	60	\N	t	f	3	2013-10-09	60	Automated Site2001	\N		2001	USA				47955625-75f5-403d-850c-b8c5584f24a9	\N	satisfied	PH1
254	\N	13	\N	8	2	f	1	\N	\N	\N	\N	\N	2013-10-08 22:43:35-04	f	\N	f	f	182550	2013-10-08 22:43:35-04	56a03841-2e67-4d52-955d-387c7ddd3e26	\N	\N	Subject_2	f	\N	\N	\N	8	1	14	59	\N	f	f	3	\N	59	Automated Site2000	\N	\N	2000	\N	\N	\N	\N	2bbe8e2f-4a8f-40d5-b325-8a69d46ebefe	\N	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

