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
23663	11	19	\N	2394	100	f	8	0	--- \n- - Active\n  - 4.0\n- - Placebo\n  - 4.0\n	15	\N	\N	2014-02-12 15:34:51-05	f	\N	f	f	\N	2014-02-12 15:34:28-05	b1c74a83-29e3-4e46-9612-c889508f35d5	28	\N	DSFSDF1	f	\N	\N	\N	2394	8	542	675	\N	t	f	126	2014-02-19	675	Hackensack University Medical Center	\N	Hackensack	HUMC001	USA	NJ			5b87502c-5777-4be3-9021-e8dcc3c243f3	\N	satisfied	PH0
0	\N	14	\N	8	10	f	1	\N	\N	\N	\N	\N	2013-10-08 22:43:47-04	f	\N	f	f	122367	2013-10-08 22:43:47-04	1495e594-7d23-42a7-b393-e07bcbb20d8b	\N	\N	Subject_10	f	\N	\N	\N	8	1	14	59	\N	f	f	3	\N	59	Automated Site2000	\N	\N	2000	\N	\N	\N	\N	2bbe8e2f-4a8f-40d5-b325-8a69d46ebefe	\N	satisfied	PH1
23663	11	10	\N	2394	100	t	8	\N	--- \n- - Active\n  - 4.0\n- - Placebo\n  - 4.0\n	15	\N	\N	2015-10-09 00:00:00-04	f	\N	f	f	\N	2014-02-12 15:34:28-05	b1c74a83-29e3-4e46-9612-c889508f35d5	28	\N	DSFSDF1	f	\N	\N	\N	2394	0	542	675	\N	t	f	0	2014-02-19	675	Hackensack University Medical Center	\N	Hackensack	HUMC001	China	NJ			5b87502c-5777-4be3-9021-e8dcc3c243f3	\N	excluded	
\.


--
-- PostgreSQL database dump complete
--

