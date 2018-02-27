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
147	sync_engine_stg1	public	qrtz_fired_triggers	pk_qrtz_fired_triggers	99.492385786802	3.07	0	0	0	0.99999315396397	305978	excluded	
132	email	public	email	email_pkey	20	0.03	2	0	0	1	325142	satisfied	PH0
138	object_delta	public	object_delta_tbl_20160516	object_delta_tbl_20160516_sequenceid_idx	-0.435954343690552	1379.87	5021007310	2016440526	2005166222	0.999972893585857	325542	satisfied	PH1
147	obp	obp	badges	badges_b_badge_id_key	68	28	0	0	0	0	326899	satisfied	PH2
148	polling_etl	polling_etl	qrtz_triggers	idx_qrtz_t_jg	50	0.03	1	6	1	0.99999980009508	327143	satisfied	PH3
131	object_delta_test	public	object_delta_tbl_20170327	object_delta_tbl_20170327_ingesttimestamp_entitytype_idx	54	59	0	0	0	0.99999976373234	1504532	satisfied	PH4
\.


--
-- PostgreSQL database dump complete
--

