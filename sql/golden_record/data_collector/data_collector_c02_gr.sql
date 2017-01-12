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
159	mssql	LD20-EGE-005.core.cvent.org	50000	unknown	staging	SQLEXPRESS	f	2017-01-11 02:49:39.042215	10.20.16.249	Microsoft Windows Server 2008 R2 Standard 	4.19 GB	2	VMware Virtual Platform	0	21	159	email	public	email	email_pkey	0	0.01	626082	626080	626079	0.99999680669827	1258471	excluded	
132	mssql	DR20-EGE-202.p2.cvent.com	50000	unknown	production	SQLEXPRESS	f	2017-01-11 02:50:42.14757	\N	\N	\N	\N	\N	\N	\N	132	quartz	public	qrtz_job_details	qrtz_job_details_pkey	8	79	0	0	0	-1	118647	satisfied	PH0
170	mssql	PR20-EGE-001.p2.cvent.com	50000	Microsoft SQL Server 2008 R2 (SP2) - 10.50.4000.0 (X64) Express Edition (64-bit)	production	SQLEXPRESS	t	2017-01-11 02:50:43.014044	10.59.12.136	Microsoft Windows Server 2008 R2 Standard 	4.19 GB	2	VMware Virtual Platform	0	21	170	obp	obp	qrtz_calendars	qrtz_calendars_pkey	53	78	0	0	0	-1	126911	satisfied	PH1
198	postgres	ap20-pgcsn-001.core.cvent.org	5432	9.5.2	alpha		t	2017-01-11 03:17:20.530322	10.20.16.79	centos_7.3.1611	8.01 GB	4	vmware	0	28	198	identity_mapping	public	user_mapping	user_mapping_pkey	16	8	0	0	0	0.964912280701754	140489	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

