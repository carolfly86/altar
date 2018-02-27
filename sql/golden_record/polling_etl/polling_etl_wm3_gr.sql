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
3f61f186-64e5-4b7f-8b28-8c5e45d0c767	0	0	t	6	Notes	ENABLED	84	9	2016-12-18 00:00:00	1	60		84d0ad98-a26e-4121-b6b2-d8bf03af069e	3f61f186-64e5-4b7f-8b28-8c5e45d0c767	LONG_TEXT	Enter Response Here.		t	28598	3	\N	2017-02-01 11:28:51.373797	56		satisfied	PH1
4fb5ae3c-9821-4208-ac20-2df7d208952e	0	0	t	2036	Notes	ENABLED	2114	0	2017-01-01 22:52:09.150479	1	78		d2c088af-c523-4227-95cd-b842de03be8f	4fb5ae3c-9821-4208-ac20-2df7d208952e	LONG_TEXT	Enter Response Here.		f	45390	3	\N	2017-04-11 22:52:09.159017	100		satisfied	PH0
5386f735-3830-418c-8694-63a473703748	0	-1	f	5	Quick Notes	ENABLED	86	0	2016-12-18 00:00:00	2	60		d415e487-9537-45be-968e-6d930ec76384	5386f735-3830-418c-8694-63a473703748	SIMPLE_CHOICE	Add to Mailing List	Add to Mailing List	f	45699	0	\N	2017-03-17 11:23:54.392242	100		satisfied	PH2
4fb5ae3c-9821-4208-ac20-2df7d208952e	0	0	t	2036	Notes	ENABLED	2114	0	2016-12-18 00:00:00	1	60		d2c088af-c523-4227-95cd-b842de03be8f	4fb5ae3c-9821-4208-ac20-2df7d208952e	LONG_TEXT	Enter Response Here.		f	45390	3	\N	2017-04-11 22:52:09.159017	100		excluded	
\.


--
-- PostgreSQL database dump complete
--

