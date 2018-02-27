--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: golden_record; Type: TABLE; Schema: public; Owner: dba
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
    branch character varying(30),
    instances_data_center character varying,
    instances_product_line character varying,
    instances_repl_status character varying
);


ALTER TABLE golden_record OWNER TO dba;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: dba
--

COPY golden_record (instances_instance_id, instances_platform, instances_host_name, instances_listen_port, instances_version, instances_environment, instances_instance_name, instances_is_running, instances_last_updated, instances_ip_address, instances_os_platform, instances_memory, instances_cpu, instances_virtualization, instances_backup_retention, instances_application_id, index_stats_instance_id, index_stats_dbname, index_stats_schemaname, index_stats_relname, index_stats_idxname, index_stats_bloat_ratio, index_stats_size_mb, index_stats_idx_scan, index_stats_idx_tup_read, index_stats_idx_tup_fetch, index_stats_idx_blks_hit_ratio, index_stats_stat_id, type, branch, instances_data_center, instances_product_line, instances_repl_status) FROM stdin;
176	mssql	PR20-EGE-007.p2.cvent.com	50000	Microsoft SQL Server 2008 R2 (SP2) - 10.50.4000.0 (X64) Express Edition (64-bit)	production	SQLEXPRESS	t	2017-01-11 02:53:47.069356	10.59.12.140	Microsoft Windows Server 2008 R2 Standard 	4.19 GB	2	VMware Virtual Platform	0	21	176	workflow	public	activated_workflow_audit	activated_workflow_audit_pk	0	0.01	0	0	0	-1	420654	excluded		empty	empty	empty
132	mssql	DR20-EGE-202.p2.cvent.com	50000	unknown	production	SQLEXPRESS	f	2017-01-11 02:50:42.14757	\N	\N	\N	\N	\N	\N	\N	132	email	public	email	email_pkey	20	0.03	2	0	0	1	430331	satisfied	PH0	empty	empty	empty
147	mssql	HQ04L2CSN102.s2.cvent.com	50708	unknown	staging	CSN	f	2017-01-11 02:51:44.145211	\N	\N	\N	\N	\N	\N	\N	147	sync_engine_stg1	public	qrtz_triggers	pk_qrtz_triggers	0	0.01	48208829	819170738	5194661	0.999999954426027	432210	satisfied	PH1	empty	empty	empty
147	mssql	HQ04L2CSN102.s2.cvent.com	50708	unknown	staging	CSN	f	2017-01-11 02:51:44.145211	\N	\N	\N	\N	\N	\N	\N	147	obp	obp	assets	assets_a_original_url_key	4.02576489533011	4.85	0	0	0	0	432086	satisfied	PH2	empty	empty	empty
148	mssql	HQ04L2RPL102.s2.cvent.com	50190	unknown	staging	RPL102	f	2017-01-11 02:52:45.682141	\N	\N	\N	\N	\N	\N	\N	148	polling_etl	polling_etl	qrtz_triggers	idx_qrtz_t_jg	50	0.03	1	6	1	0.999999800416347	432335	satisfied	PH3	empty	empty	empty
131	mssql	DR20-EGE-201.p2.cvent.com	50000	unknown	production	SQLEXPRESS	f	2017-01-11 02:47:30.685987	\N	\N	\N	\N	\N	\N	\N	131	object_delta_test	public	object_delta_tbl_20170327	object_delta_tbl_20170327_ingesttimestamp_entitytype_idx	54	59	0	0	0	0.99999976373234	1504532	satisfied	PH4	empty	empty	empty
309	mysql	pr01-swdb-001.core.cvent.org	3306	5.6.33-79.0-log	production		t	2017-01-11 03:15:03.941163	172.21.52.58	centos_7.3.1611	16.27 GB	8	vmware	7	42	309	polling_etl	polling_etl	answers	PK_answers	37.744286045334	910.25	146659779	724485906	723722449	0.992625566723739	1223821	satisfied	PH5	empty	empty	empty
309	mysql	pr01-swdb-001.core.cvent.org	3306	5.6.33-79.0-log	production		t	2017-01-11 03:15:03.941163	172.21.52.58	centos_7.3.1611	16.27 GB	8	vmware	7	42	309	polling_etl	polling_etl	answers	PK_answers	37.744286045334	910.25	146659779	724485906	723722449	0.992625566723739	1223821	satisfied	PH6	empty	empty	empty
164	mssql	MG20-IDERA-001.core.cvent.org	50000	unknown	dba	SQLdm	f	2017-01-11 02:47:34.797696	\N	\N	\N	\N	\N	\N	\N	164	dev	public	email	email_pkey	61.5126854954524	16.32	1444818	112670649	112641688	0.999213915004181	1258547	satisfied	PH7	empty	empty	empty
\.


--
-- PostgreSQL database dump complete
--

