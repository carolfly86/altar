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
35b53e3a-6b2b-4dbf-a87b-4e3b261215f4	0	1	t	642	Lead Score	ENABLED	718	9	2016-12-14 11:22:58.782003	0	76		9ddc254f-e0ef-4d3d-8e6b-c4b8b743d6a0	35b53e3a-6b2b-4dbf-a87b-4e3b261215f4	NUMERIC	\N	\N	t	33951	0	GOLD	2017-02-09 11:22:58.792648	57		satisfied	PH0
35b53e3a-6b2b-4dbf-a87b-4e3b261215f4	0	0	f	642	Lead Score	ENABLED	2000	0	2016-12-08 00:00:00	0	60		9ddc254f-e0ef-4d3d-8e6b-c4b8b743d6a0	35b53e3a-6b2b-4dbf-a87b-4e3b261215f4	NUMERIC	\N	\N	f	100	0	GOLD	2016-12-08 00:00:00	57		excluded	
\.


--
-- PostgreSQL database dump complete
--

