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
    medidata_studies_id bigint,
    medidata_studies_name text,
    medidata_studies_parent_id bigint,
    medidata_studies_oid text,
    medidata_studies_type text,
    medidata_studies_protocol text,
    medidata_studies_enrollment_target text,
    medidata_studies_live_date timestamp with time zone,
    medidata_studies_is_production boolean,
    medidata_studies_uuid text,
    medidata_studies_close_date date,
    studies_id bigint,
    studies_study_design_id bigint,
    studies_name text,
    studies_external_id bigint,
    studies_parent_study_id bigint,
    studies_environment_id bigint,
    studies_live boolean,
    studies_external_name text,
    studies_rand_only boolean,
    studies_unblinded boolean,
    studies_is_shipping_algorithm_running boolean,
    studies_randomization_api_locked boolean,
    studies_dispensation_api_locked boolean,
    studies_include_address_in_shipping_email boolean,
    studies_allow_quarantining boolean,
    studies_file_upload_rules bigint,
    studies_needs_design_by_wizard boolean,
    studies_can_generate_blocks boolean,
    studies_advanced_dosing boolean,
    studies_capping boolean,
    studies_subject_identification_version bigint,
    studies_new_countries_require_qp_release boolean,
    studies_lots_are_blinded boolean,
    studies_conditional_treatment_unblinded_subjects bigint,
    depots_id bigint,
    depots_parent_id bigint,
    depots_study_id bigint,
    depots_medidata_depot_id bigint,
    depots_active_for_drug_shipping boolean,
    depots_emails text,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (medidata_studies_id, medidata_studies_name, medidata_studies_parent_id, medidata_studies_oid, medidata_studies_type, medidata_studies_protocol, medidata_studies_enrollment_target, medidata_studies_live_date, medidata_studies_is_production, medidata_studies_uuid, medidata_studies_close_date, studies_id, studies_study_design_id, studies_name, studies_external_id, studies_parent_study_id, studies_environment_id, studies_live, studies_external_name, studies_rand_only, studies_unblinded, studies_is_shipping_algorithm_running, studies_randomization_api_locked, studies_dispensation_api_locked, studies_include_address_in_shipping_email, studies_allow_quarantining, studies_file_upload_rules, studies_needs_design_by_wizard, studies_can_generate_blocks, studies_advanced_dosing, studies_capping, studies_subject_identification_version, studies_new_countries_require_qp_release, studies_lots_are_blinded, studies_conditional_treatment_unblinded_subjects, depots_id, depots_parent_id, depots_study_id, depots_medidata_depot_id, depots_active_for_drug_shipping, depots_emails, type, branch) FROM stdin;
2018	BalRaveSandboxStudy004 (QTP)	284	BRS004-qtp	\N			\N	f	5fa7cd61-e388-4222-a7dc-2df5366ea3d7	2014-02-01	24	32	BalRaveSandboxStudy004 (QTP)	2018	\N	\N	f	\N	f	t	f	f	f	f	f	0	f	f	f	f	1	f	t	0	311	\N	24	311	t	\N	excluded	
2017	PGI Study 1	239	31415926	\N			\N	t	73a4aa00-b656-4b2d-a567-cce1ecc745aa	2014-02-01	23	26	PGI Study 1	2017	\N	\N	t	\N	f	f	f	f	f	f	f	0	f	f	t	f	1	f	t	0	50	\N	23	50	t	\N	satisfied	PH0
159	Mediflexs	135	Mediflexs	\N			\N	t	1e829b5f-039d-4636-9a9a-8d3ea6512e5f	2014-02-01	580	643	Mediflexs	159	\N	\N	f	\N	f	f	f	f	f	f	f	0	f	f	t	f	1	f	t	0	1878	\N	580	1877	t	\N	satisfied	PH1
161	Mediflexs (UAT)	135	MediflexsUAT	\N	Mediflex UAT Protocol		\N	f	167fbbef-f5f9-4108-a609-010b83d3ae15	2014-02-01	582	646	Mediflexs (UAT)	161	\N	\N	f	\N	f	f	f	f	f	f	f	0	f	f	t	t	1	f	t	0	1880	\N	582	1879	t	\N	satisfied	PH2
20147	KChiu_testing	239	9001	\N			\N	f	a221bc7a-42ea-4584-b132-1bc99c838208	2014-02-01	588	657	KChiu_testing	20147	\N	\N	f	\N	f	f	f	f	f	f	t	2	f	f	t	f	1	f	f	0	1955	\N	588	1954	t	\N	satisfied	PH4
20155	NandanStudy	239	101	\N			\N	f	e76dda3b-0085-4e89-9902-973184fc07e4	2014-02-01	589	658	NandanStudy	20155	\N	\N	f	\N	f	f	f	f	f	f	t	2	f	t	t	t	1	f	f	0	1960	\N	589	1959	t	\N	satisfied	PH5
314	MRK Study	239	MRKSTUDY	\N			\N	f	73cd58b2-3efc-4556-91f7-dfe031805b20	2014-02-01	11	11	MRK Study	314	\N	\N	f	\N	f	f	f	f	f	f	t	1	f	t	t	t	1	f	f	0	2009	\N	11	2008	t	\N	satisfied	PH6
2017	PGI Study 1	239	31415926	\N			\N	t	73a4aa00-b656-4b2d-a567-cce1ecc745aa	2014-02-01	23	26	PGI Study 1	2017	\N	\N	t	\N	f	f	f	f	f	f	f	0	f	f	t	f	1	f	t	0	50	\N	23	50	t	\N	satisfied	PH7
\.


--
-- PostgreSQL database dump complete
--

