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
194	mssql	TS20-EGE2-001.core.cvent.org	50000	unknown	staging	SQLEXPRESS	f	2017-01-11 02:53:47.017689	10.20.16.211	Microsoft Windows Server 2008 R2 Standard 	2.10 GB	1	VMware Virtual Platform	0	21	194	sms	public	qrtz_simple_triggers	qrtz_simple_triggers_pkey	0	0.01	109	109	109	0.989071038251366	41249	excluded		empty	empty	empty
170	mssql	PR20-EGE-001.p2.cvent.com	50000	Microsoft SQL Server 2008 R2 (SP2) - 10.50.4000.0 (X64) Express Edition (64-bit)	production	SQLEXPRESS	t	2017-01-11 02:50:43.014044	10.59.12.136	Microsoft Windows Server 2008 R2 Standard 	4.19 GB	2	VMware Virtual Platform	0	21	170	obp	obp	assets	assets_a_original_url_key	31.7394888705688	9.47	0	0	0	0.976608318540323	48250	satisfied	PH0	empty	empty	empty
294	postgres	pr01-pgelog-001.core.cvent.org	5432	9.5.4	production		t	2017-01-11 02:28:42.060845	172.21.52.54	centos_7.3.1611	8.01 GB	4	vmware	7	43	294	scheduling	public	schedule_data	schedule_data_data_id_key	31.7365269461078	1.30	0	0	0	0.996026685638348	1222910	satisfied	PH1	empty	empty	empty
\.


--
-- PostgreSQL database dump complete
--

