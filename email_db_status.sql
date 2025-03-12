--set colsep "|"
set feedback off
set lines 300
set pages 300
prompt
prompt || Database Health Check Report Post Patching !! ||
prompt
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
select 'DATE: '||sysdate "DATE" from dual;

prompt
prompt || Database Status ||
set lines 300
col host_name for a20
SELECT NAME,DB_UNIQUE_NAME,instance_name, host_name, logins, DATABASE_ROLE, OPEN_MODE, startup_time  FROM V$DATABASE, v$instance;
prompt
prompt
prompt || Database Release Version ||
select VERSION_FULL from product_component_version;
prompt
prompt
prompt || List of Invalid Objects ||
select 'Invalid Object Count: '||count(*) "INVALID OBJECT COUNT" from dba_objects where status='INVALID';
prompt
prompt
prompt || DB Patch Status ||
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
description,patch_id FROM sys.dba_registry_sqlpatch ORDER by action_time DESC FETCH FIRST 10 ROWS ONLY;
prompt
prompt
prompt || Database Comp Status ||
col comp_id for a10
col version for a11
col status for a10
col comp_name for a37
select comp_id,comp_name,version,status from dba_registry
where status not in ('INVALID');
prompt
prompt
prompt || DBA_REGISTRY_SQLPATCH ||
SET LINESIZE 500
SET PAGESIZE 1000
SET SERVEROUT ON
SET LONG 2000000
COLUMN action_time FORMAT A12
COLUMN action FORMAT A10
COLUMN patch_type FORMAT A10
COLUMN description FORMAT A60
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
order by action_time desc FETCH FIRST 6 ROWS ONLY;

exit


