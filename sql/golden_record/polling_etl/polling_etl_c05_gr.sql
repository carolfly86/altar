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
    choices_style hstore,
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
5386f785-3830-418c-8694-63a473708746	0	0	f	496	Quick Notes	ENABLED	2000	0	2016-12-28 00:00:00	2	80		014d6e38-a6b0-42b4-be71-ede6c34291e6	106583d7-b742-47e4-9e72-771b252a014b	SIMPLE_CHOICE	Schedule Demo	Schedule Demo	t	290	3	\N	2017-01-30 18:30:23.157134	48		satisfied	PH3
5386f785-3830-418c-8694-63a473708746	0	0	t	4	AccessTokens	ENABLED	69	0	2016-12-28 00:00:00	0	80		7d1dedda-efa1-4b11-b794-7d2b55494383	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Normal	Normal	t	2000	2	\N	2017-03-02 16:16:56.585257	55		satisfied	PH2
5386f785-3830-418c-8694-63a473708746	0	1	f	5	Notes	ENABLED	2000	4	2016-12-28 00:00:00	1	80		9226daa0-e965-47ac-9bd4-765a3cf8a52a	088b8518-c7eb-4d8c-9a09-a23f45c9cebe	LONG_TEXT	Enter Response Here.		t	2000	2	\N	2017-02-02 11:23:54.390708	57		satisfied	PH1
5386f785-3830-418c-8694-63a473708746	0	0	f	4	AccessTokens	ENABLED	2000	0	2016-12-07 01:00:15.343029	0	65		7d1dedda-efa1-4b11-b794-7d2b55494383	facafb7e-7466-42da-8551-381b8cdb284b	SIMPLE_CHOICE	Normal	Normal	t	2000	2	\N	2017-03-02 16:16:56.585257	55		satisfied	PH0
5386f785-3830-418c-8694-63a473708746	0	0	f	2522	Quick Notes	ENABLED	2000	0	2016-12-28 00:00:00	2	80		f9d2d7dd-7ba9-4e8b-8e2f-0fd3ff41fe75	cfa9ae6b-f47b-4a55-81f4-912d9a6bffa9	SIMPLE_CHOICE	Add to Mailing List	Add to Mailing List	t	2000	2	\N	2017-04-17 21:30:03.348932	102		excluded	
5386f785-3830-418c-8694-63a473708746	0	0	f	5	Quick Notes	ENABLED	2000	0	2016-12-28 00:00:00	2	80		d415e487-9537-45be-968e-6d930ec76384	5386f735-3830-418c-8694-63a473703748	SIMPLE_CHOICE	Add to Mailing List	Add to Mailing List	t	2000	2	\N	2017-03-17 11:23:54.392242	100		satisfied	PH4
\.


--
-- PostgreSQL database dump complete
--

