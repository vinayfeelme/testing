-- Retrieve the database name
--SELECT name INTO :DB_NAME FROM v$database;
--DEFINE DB_NAME = '&DB_NAME'
COLUMN db_name NEW_VALUE db_name
SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) AS db_name FROM dual;

-- Get the current timestamp (you can customize the format as per your requirement)
COLUMN timestamp NEW_VALUE timestamp
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24:MI:SS') AS timestamp FROM dual;

-- Define the spool file with the database name and timestamp
SPOOL /tmp/Auto_Patch_log/DB_Prechecks_&db_name._&timestamp..lst;
spool

prompt
prompt || Health Check Report Generating started !! ||
prompt
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
select 'Health Check Report Generating started !! '||sysdate from dual;

select sid, serial#, process from v$session where program like '%PMON%';

prompt
prompt || DB Status ||
prompt
set serveroutput on size 1000000
set linesize 512
set trimspool on
begin
     for x in ( select host_name,db.name as name,db.DB_UNIQUE_NAME as DB_UNIQUE_NAME,instance_name,version,to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') as started,
     logins, db.database_role as db_role,db.open_mode as open_mode,SWITCHOVER_STATUS, INSTANCE_NUMBER,INSTANCE_ROLE, LOG_MODE, FLASHBACK_ON,
     FORCE_LOGGING,floor(sysdate - startup_time) || trunc( 24*((sysdate-startup_time) - trunc(sysdate-startup_time)))
     || ' hour(s) ' || mod(trunc(1440*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||' minute(s) '
     || mod(trunc(86400*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||' seconds' uptime
                from
                gv$instance , gv$database db
                where
                gv$instance.inst_id=db.inst_id )
     loop
             dbms_output.put_line( CHR(13) || CHR(10));
             dbms_output.put_line( 'HOSTNAME             : '||x.host_name);
             dbms_output.put_line( 'DATABASE NAME        : '||x.name);
             dbms_output.put_line( 'DATABASE UNIQUE NAME : '||x.db_unique_name);
             dbms_output.put_line( 'DATABASE VERSION     : '||x.version);
             dbms_output.put_line( 'DATABASE ROLE        : '||x.db_role);
             dbms_output.put_line( 'OPEN MODE            : '||x.open_mode);
             dbms_output.put_line( 'INSTANCE #           : '||x.instance_number);
             dbms_output.put_line( 'INSTANCE NAME        : '||x.instance_name);
             dbms_output.put_line( 'INSTANCE ROLE        : '||x.instance_role);
             dbms_output.put_line( 'LOGINS               : '||x.logins);
             dbms_output.put_line( 'SWITCH-OVER          : '||x.switchover_status);
             dbms_output.put_line( 'LOG MODE             : '||x.log_mode);
                         dbms_output.put_line( 'FLASHBACK STATUS     : '||x.flashback_on);
             dbms_output.put_line( 'FORCE LOGGING        : '||x.force_logging);
             dbms_output.put_line( 'STARTED AT           : '||x.started);
             dbms_output.put_line( 'UPTIME               : '||x.uptime);
             dbms_output.put_line( CHR(13) || CHR(10));
     end loop;
end;
/


prompt
prompt ||  Run on Primary DB ||
prompt
select vdb.name,vdb.database_role, max(sequence#) "Last Primary Seq Generated"
from v$archived_log val, v$database vdb
where val.resetlogs_change# = vdb.resetlogs_change#
group by vdb.name,vdb.database_role;


prompt
prompt || Run on Standby and HA DB ||
prompt
SELECT TO_CHAR(STANDBY_BECAME_PRIMARY_SCN) FROM V$DATABASE;

prompt || Lag Info ||
SELECT al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied", (almax -lhmax ) diff FROM (select thread# thrd, MAX(sequence#) almax FROM v$archived_log
WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v$database) GROUP BY thread#) al, (SELECT thread# thrd, MAX(sequence#) lhmax FROM v$log_history
WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v$database) GROUP BY thread#) lh WHERE al.thrd = lh.thrd;


prompt
prompt || Database Size ||
prompt
col "Database Size" format a20
col "Free space" format a20
col "Used space" format a20
select round(sum(used.bytes) / 1024 / 1024 / 1024 ) || ' GB' "Database Size"
, round(sum(used.bytes) / 1024 / 1024 / 1024 ) -
round(free.p / 1024 / 1024 / 1024) || ' GB' "Used space"
, round(free.p / 1024 / 1024 / 1024) || ' GB' "Free space"
from (select bytes
from v$datafile
union all
select bytes
from v$tempfile
union all
select bytes
from v$log) used
, (select sum(bytes) as p
from dba_free_space) free
group by free.p
/

prompt
prompt || TABLESPACE STATUS ||
prompt
col totsiz format 999,999,990 justify c heading 'Total|(MB)'
col avasiz format 999,999,990 justify c heading 'Available|(MB)'
col pctusd format 990 justify c heading 'Pct|Used'
comp sum of totsiz avasiz on report
break on report

select
total.tablespace_name,
total.bytes/1024/1024 totsiz,
nvl(sum(free.bytes)/1024/1024,0) avasiz,
(1-nvl(sum(free.bytes),0)/total.bytes)*100 pctusd
from
(select sum(bytes) bytes,tablespace_name from dba_data_files group by tablespace_name) total,
(select sum(bytes) bytes,tablespace_name from dba_free_space group by tablespace_name) free where
total.tablespace_name = free.tablespace_name(+)
group by
total.tablespace_name,
total.bytes
order by 4
/

prompt
prompt || All Tablespaces Utilization ||
prompt
set timing on
set linesize 300 pages 100 trimspool on numwidth 14
col name format a30
col owner format a15
col "Used (GB)" format a15
col "Free (GB)" format a15
col "(Used) %" format a15
col "Size (GB)" format a15
SELECT /*+ PARALLEL(60) */  d.status "Status", d.tablespace_name "Name",
 TO_CHAR(NVL(a.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Size (GB)",
 TO_CHAR(NVL(a.bytes - NVL(f.bytes, 0), 0)/1024/1024 /1024,'99999999.99') "Used (GB)",
 TO_CHAR(NVL(f.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Free (GB)",
 TO_CHAR(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0), '990.00') "(Used) %"
 FROM sys.dba_tablespaces d,
 (select /*+ PARALLEL(60) */ tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) a,
 (select /*+ PARALLEL(60) */ tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) f WHERE
 d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+) AND NOT
 (d.extent_management like 'LOCAL' AND d.contents like '%TEMP%')
UNION ALL
SELECT /*+ PARALLEL(60) */ d.status
 "Status", d.tablespace_name "Name",
 TO_CHAR(NVL(a.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Size (GB)",
 TO_CHAR(NVL(t.bytes,0)/1024/1024 /1024,'99999999.99') "Used (GB)",
 TO_CHAR(NVL((a.bytes -NVL(t.bytes, 0)) / 1024 / 1024 /1024, 0),'99,999,990.90') "Free (GB)",
 TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "(Used) %"
 FROM sys.dba_tablespaces d,
 (select /*+ PARALLEL(60) */ tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a,
 (select /*+ PARALLEL(60) */ tablespace_name, sum(bytes_cached) bytes from v$temp_extent_pool group by tablespace_name) t
 WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+) AND
 d.extent_management like 'LOCAL' AND d.contents like '%TEMP%'
order by 6;


prompt
prompt || Arch Destination ||
prompt
set linesize 300
 col error format a20
 col DESTINATION format a20
 select dest_id,status,target,error,destination from v$archive_dest
 where status not in ('INACTIVE');


prompt
prompt || RMAN Backup Details ||
prompt
set linesize 300 ;
set pagesize 100 ;
col command_id format a40 heading "Command"
col input_type format a10 heading "Type"
col status format a10 heading "Status"
col start_time format a17 heading "Start Time"
col elapsed_secs format 9,999,999 heading "Elapsed Secs"
col InputGb format 9,999.999 heading "InputGb"
col OutputGb format 9,999.999 heading "OutputGb"
col compression_ratio format 9,999.9 heading "CompRatio"
col InGbHr format 9,999.9 heading "InGbHr"
col OutGbHr format 9,999.9 heading "OutGbHr"
select command_id , input_type, status, to_char(start_time,'mm-dd-yy HH24:MI:SS') start_time,
elapsed_seconds elapsed_secs, input_bytes/1024/1024/1024 InputGb, output_bytes/1024/1024/1024 OutputGb,
compression_ratio, input_bytes_per_sec/1024/1024/1024*(3600) InGbHr,
output_bytes_per_sec/1024/1024/1024*(3600) OutGbHr
from v$rman_backup_job_details
ORDER BY start_time DESC
FETCH FIRST 10 ROWS ONLY;


prompt
prompt || RMAN Backup Running Jobs ||
prompt
COLUMN sid FORM 99999
COLUMN serial# FORM 99999
COLUMN opname FORM A35
COLUMN sofar FORM 999999999
COLUMN pct_complete FORM 99999999.99 HEAD "% Comp."

SELECT sid, serial#, sofar, totalwork, opname,
round(sofar/totalwork*100,2) AS pct_complete
FROM v$session_longops
WHERE opname LIKE 'RMAN%'
AND opname NOT LIKE '%aggregate%'
AND totalwork != 0
AND sofar <> totalwork;


prompt
prompt || HANDLING STUCK TRANSACTIONS ||
prompt
SELECT LOCAL_TRAN_ID, GLOBAL_TRAN_ID, STATE, MIXED, COMMIT# FROM DBA_2PC_PENDING;


prompt
prompt || List of Invalid Objects ||
prompt
col owner for a15
col object_name for a35
select OWNER,OBJECT_NAME,OBJECT_TYPE,status from DBA_OBJECTS where
status = 'INVALID';
select count(*) from dba_objects where status='INVALID';


prompt
prompt || Database Parameter ||
prompt
show parameter NLS_LENGTH_SEMANTICS
show parameter CLUSTER_DATABASE
show parameter parallel_max_server
show parameter undo_management
show parameter job_queue_process
show parameter pool
show parameter remote_login_password
show parameter spfile
show parameter pga
show parameter sga
show parameter disk_as



prompt
prompt || DB Patch Status ||
prompt
SET LINESIZE 500
SET PAGESIZE 1000
SET SERVEROUT ON
SET LONG 2000000
COLUMN action_time FORMAT A12
COLUMN action FORMAT A10
COLUMN comments FORMAT A30
COLUMN description FORMAT A60
COLUMN namespace FORMAT A20
COLUMN status FORMAT A10
SELECT TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time,action,status,
description,patch_id FROM sys.dba_registry_sqlpatch ORDER by action_time;


prompt
prompt || Database Comp Status ||
prompt
col comp_id for a10
col version for a11
col status for a10
col comp_name for a37
select comp_id,comp_name,version,status from dba_registry;


prompt
prompt || DBA_REGISTRY_SQLPATCH ||
prompt
SET LINESIZE 500
SET PAGESIZE 1000
SET SERVEROUT ON
SET LONG 2000000
COLUMN action_time FORMAT A12
COLUMN action FORMAT A10
COLUMN patch_type FORMAT A10
COLUMN description FORMAT A32
COLUMN status FORMAT A10
COLUMN version FORMAT A10
select CON_ID,
TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time,
PATCH_ID,
PATCH_TYPE,
ACTION,
DESCRIPTION,
SOURCE_VERSION,
TARGET_VERSION
from CDB_REGISTRY_SQLPATCH
order by CON_ID, action_time, patch_id;

spool off

exit


