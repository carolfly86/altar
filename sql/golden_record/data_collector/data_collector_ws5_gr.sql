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
    index_stats_instance_id smallint,
    index_stats_dbname name,
    index_stats_schemaname name,
    index_stats_relname name,
    index_stats_idxname name,
    index_stats_bloat_ratio numeric,
    index_stats_size_mb numeric,
    index_stats_idx_scan bigint,
    index_stats_idx_tup_read bigint,
    index_stats_idx_tup_fetch bigint,
    index_stats_idx_blks_hit_ratio numeric,
    index_stats_stat_id integer,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (index_stats_instance_id, index_stats_dbname, index_stats_schemaname, index_stats_relname, index_stats_idxname, index_stats_bloat_ratio, index_stats_size_mb, index_stats_idx_scan, index_stats_idx_tup_read, index_stats_idx_tup_fetch, index_stats_idx_blks_hit_ratio, index_stats_stat_id, type, branch) FROM stdin;
131	object_delta_partition	public	object_delta_tbl_20160307	object_delta_tbl_20160307_pkey	0.634236142633782	1239.18	0	0	0	0.000175965290510635	280370	excluded	
132	email	public	email	email_pkey	20	0.03	2	0	0	1	283044	satisfied	PH0
138	object_delta	public	object_delta_tbl_20160509	object_delta_tbl_20160509_sequenceid_idx	0.351747398082518	1619.14	4894473362	2194708073	2175989777	0.99994695192695	283447	satisfied	PH1
147	obp	obp	assets	assets_a_original_url_key	4.02576489533011	4.85	0	0	0	0	284803	satisfied	PH2
131	object_delta_test	public	object_delta_tbl_20170327	object_delta_tbl_20170327_ingesttimestamp_entitytype_idx	54	59	0	0	0	0.99999976373234	1504532	satisfied	PH3
\.


--
-- PostgreSQL database dump complete
--

