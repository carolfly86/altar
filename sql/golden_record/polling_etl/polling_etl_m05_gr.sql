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
    questions_id uuid,
    questions_minresponses integer,
    questions_maxresponses integer,
    questions_required boolean,
    questions_surveyid bigint,
    questions_label character varying(300),
    questions_status character varying(50),
    questions_imageid bigint,
    questions_questioncode integer,
    questions_etl_time timestamp without time zone,
    questions_questionposition integer,
    questions_externalsystemid integer,
    questions_metadata hstore,
    choices_id uuid,
    choices_questionid uuid,
    choices_type character varying(50),
    choices_value character varying(140),
    choices_label character varying(300),
    choices_active boolean,
    choices_imageid bigint,
    choices_choiceposition integer,
    choices_style character varying(10),
    choices_etl_time timestamp without time zone,
    choices_externalsystemid integer,
    choices_metadata hstore,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (questions_id, questions_minresponses, questions_maxresponses, questions_required, questions_surveyid, questions_label, questions_status, questions_imageid, questions_questioncode, questions_etl_time, questions_questionposition, questions_externalsystemid, questions_metadata, choices_id, choices_questionid, choices_type, choices_value, choices_label, choices_active, choices_imageid, choices_choiceposition, choices_style, choices_etl_time, choices_externalsystemid, choices_metadata, type, branch) FROM stdin;
facafb7e-7466-42da-8551-381b8cdb284b	0	1	t	5	AccessTokens	ENABLED	69	0	2016-12-18 00:00:00	0	80		7d1dedda-efa1-4b11-b794-7d2b55494383	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Normal	Normal	t	26977	0	\N	2017-12-18 00:00:00	55		satisfied	PH5
facafb7e-7466-42da-8551-381b8cdb284b	0	1	t	2	AccessTokens	ENABLED	1000	0	2016-12-18 00:00:00	0	80		8cd09468-137c-4873-a0cd-59ce22b8e166	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Secure	Secure	t	30319	1	\N	2017-12-18 00:00:00	56		satisfied	PH4
3f61f186-64e5-4b7f-8b28-8c5e45d0c767	0	1	t	5	Notes	ENABLED	1000	9	2016-12-18 00:00:00	1	80		84d0ad98-a26e-4121-b6b2-d8bf03af069e	3f61f186-64e5-4b7f-8b28-8c5e45d0c767	LONG_TEXT	Enter Response Here.		t	28598	0	\N	2017-12-18 00:00:00	56		satisfied	PH2
facafb7e-7466-42da-8551-381b8cdb284b	0	1	t	5	AccessTokens	ENABLED	1000	0	2016-12-07 01:00:15.343029	0	80		7d1dedda-efa1-4b11-b794-7d2b55494383	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Normal	Normal	t	26977	0	\N	2017-12-18 00:00:00	55		satisfied	PH1
facafb7e-7466-42da-8551-381b8cdb284b	0	1	t	5	AccessTokens	ENABLED	1000	0	2016-12-18 00:00:00	0	65		7d1dedda-efa1-4b11-b794-7d2b55494383	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Normal	Normal	t	26977	0	\N	2017-12-18 00:00:00	55		satisfied	PH0
990fe6b1-ae96-47da-83b8-860bfed6deef	0	1	t	5	Notes	ENABLED	1000	0	2016-12-18 00:00:00	1	80		57ca0fea-5589-45fb-b827-354546f21e11	990fe6b1-ae96-47da-83b8-860bfed6deef	LONG_TEXT	Enter Response Here.		t	18964	0	\N	2017-12-18 00:00:00	53		excluded	
facafb7e-7466-42da-8551-381b8cdb284b	0	0	t	5	AccessTokens	ENABLED	1000	0	2016-12-18 00:00:00	0	80		7d1dedda-efa1-4b11-b794-7d2b55494383	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Normal	Normal	t	26977	0	\N	2017-12-18 00:00:00	55		excluded	
f006e9bb-fd84-45d6-91ef-84230f903f35	0	1	t	5	What is the timeframe for choosing a solution?	ENABLED	1000	0	2016-12-18 00:00:00	5	80		03cc073c-9bbb-4104-a492-d49b09b7274c	f006e9bb-fd84-45d6-91ef-84230f903f35	SIMPLE_CHOICE	Not Applicable	Not Applicable	t	793	4	\N	2017-01-30 22:48:43.801035	48		satisfied	PH3
\.


--
-- PostgreSQL database dump complete
--

