prompt =========================================================
prompt 06_test_calls.sql
prompt Support queries for manual validation
prompt =========================================================

set linesize 200
set pagesize 100
col google_sub format a40
col email format a40
col full_name format a30
col ords_client_name format a35
col ords_client_id format a40
col event_type format a20
col current_user_value format a30
col remote_user_value format a30
col client_identifier format a30

prompt === Registered application users
select id,
       google_sub,
       email,
       full_name,
       birth_date,
       phone_number,
       status,
       created_at,
       updated_at
  from app_users
 order by id;

prompt === Linked OAuth clients
select id,
       app_user_id,
       ords_client_name,
       ords_client_id,
       active_flag,
       created_at
  from app_user_oauth_clients
 order by id;

prompt === ORDS clients created in the schema
select id,
       name,
       client_id,
       auth_flow,
       support_email,
       created_on
  from user_ords_clients
 order by id;

prompt === Endpoint diagnostics log
select id,
       event_type,
       event_at,
       ords_client_id,
       ords_client_name,
       current_user_value,
       remote_user_value,
       remote_ident_value,
       client_identifier,
       notes
  from app_api_event_log
 order by id desc;
