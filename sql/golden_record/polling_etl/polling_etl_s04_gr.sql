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
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (questions_id, questions_minresponses, questions_maxresponses, questions_required, questions_surveyid, questions_label, questions_status, questions_imageid, questions_questioncode, questions_etl_time, questions_questionposition, questions_externalsystemid, questions_metadata, type, branch) FROM stdin;
5386f735-3830-418c-8694-63a473703748	0	-1	f	5	Quick Notes	ENABLED	86	6	2016-12-07 11:23:54.365754	2	81		excluded	
990fe6b1-ae96-47da-83b8-860bfed6deef	0	1	t	1606	Notes	ENABLED	1684	8	2016-12-26 11:31:19.779501	1	78		satisfied	PH0
990fe6b1-ae96-47da-83b8-860bfed6deef	0	1	t	1606	Notes	ENABLED	1684	8	2016-12-26 11:31:19.779501	1	78		satisfied	PH1
facafb7e-7466-42da-8551-381b8cdb284b	0	1	t	4	AccessTokens	ENABLED	69	6	2016-12-07 01:00:15.343029	0	65		satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

