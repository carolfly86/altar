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
158	messaging_datamart	public	mta_transactions	ix_mta_transactions_vmta	0	52	0	0	0	0.5	237172	excluded	
131	object_delta_partition	public	object_delta_tbl_20160307	object_delta_tbl_20160307_pkey	0.634236142633782	1239.18	0	0	0	0.000175965290510635	258569	satisfied	PH0
132	email	public	email	email_pkey	20	0.03	2	0	0	1	261225	satisfied	PH1
\.


--
-- PostgreSQL database dump complete
--

