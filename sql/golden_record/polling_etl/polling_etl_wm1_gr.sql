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
990fe6b1-ae96-47da-83b8-860bfed6deef	0	1	t	1606	Notes	ENABLED	1684	8	2016-12-26 11:31:19.779501	1	78		57ca0fea-5589-45fb-b827-354546f21e11	990fe6b1-ae96-47da-83b8-860bfed6deef	LONG_TEXT	Enter Response Here.		t	18964	0	\N	2017-02-17 11:31:19.788386	53		satisfied	PH0
990fe6b1-ae96-47da-83b8-860bfed6deef	0	0	t	1606	Notes	ENABLED	1684	0	2016-12-10 00:00:00	1	70		57ca0fea-5589-45fb-b827-354546f21e11	990fe6b1-ae96-47da-83b8-860bfed6deef	LONG_TEXT	Enter Response Here.		f	18964	0	\N	2017-02-17 11:31:19.788386	53		excluded	
\.


--
-- PostgreSQL database dump complete
--

