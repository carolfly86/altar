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
    instances_instance_id integer,
    instances_platform character varying(150),
    instances_host_name character varying(150),
    instances_listen_port integer,
    instances_version character varying(250),
    instances_environment character varying(150),
    instances_instance_name character varying(150),
    instances_is_running boolean,
    instances_last_updated timestamp without time zone,
    instances_ip_address inet,
    instances_os_platform character varying(250),
    instances_memory character varying(100),
    instances_cpu integer,
    instances_virtualization character varying(100),
    instances_backup_retention integer,
    instances_application_id integer,
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

COPY golden_record (instances_instance_id, instances_platform, instances_host_name, instances_listen_port, instances_version, instances_environment, instances_instance_name, instances_is_running, instances_last_updated, instances_ip_address, instances_os_platform, instances_memory, instances_cpu, instances_virtualization, instances_backup_retention, instances_application_id, index_stats_instance_id, index_stats_dbname, index_stats_schemaname, index_stats_relname, index_stats_idxname, index_stats_bloat_ratio, index_stats_size_mb, index_stats_idx_scan, index_stats_idx_tup_read, index_stats_idx_tup_fetch, index_stats_idx_blks_hit_ratio, index_stats_stat_id, type, branch) FROM stdin;
132	mssql	DR20-EGE-202.p2.cvent.com	50000	unknown	dev	test	t	2017-01-11 02:50:42.14757	\N	\N	\N	\N	\N	\N	\N	132	test	public	qrtz_scheduler_state	qrtz_scheduler_state_pkey	10	0	10	0	0	-1	20224	satisfied	PH0
0	mssql	DR20-EGE-201.p2.cvent.com	50000	unknown	dev	test	f	2017-01-11 02:47:30.685987	\N	\N	\N	\N	\N	\N	\N	131	test	public	test	object_delta_tbl_20170327_sequenceid_idx	10	24171173.75	10	0	0	0.99999994458172	1	satisfied	PH1
0	mssql	LD20-EGE-001.core.cvent.org	50000	unknown	dev	SQLEXPRESS	t	2017-01-11 02:49:40.594633	10.20.16.245	Microsoft Windows Server 2008 R2 Standard 	4.19 GB	2	VMware Virtual Platform	0	21	155	obp	obp	test	badges_b_badge_id_key	10	0	0	0	0	-1	123223	satisfied	PH2
0	mssql	PR20-EGE-001.p2.cvent.com	50000	Microsoft SQL Server 2008 R2 (SP2) - 10.50.4000.0 (X64) Express Edition (64-bit)	production	test	t	2017-01-11 02:50:43.014044	10.59.12.136	Microsoft Windows Server 2008 R2 Standard 	4.19 GB	2	VMware Virtual Platform	0	21	170	test	obp	test	events_pkey	-50	0	10	0	0	0.983505154639175	8807	satisfied	PH3
0	mssql	DR20-EGE-202.p2.cvent.com	50000	unknown	dev	test	t	2017-01-11 02:50:42.14757	\N	\N	\N	\N	\N	\N	\N	132	test	public	test	qrtz_scheduler_state_pkey	10	0	10	0	0	-1	20224	excluded	
\.


--
-- PostgreSQL database dump complete
--

