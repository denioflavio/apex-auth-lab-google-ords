prompt =========================================================
prompt 07_reset_demo_data.sql
prompt Reset demo data and remove generated ORDS OAuth clients
prompt =========================================================

set define off
whenever sqlerror exit failure rollback

declare
begin
    for r in (
        select distinct ords_client_name
          from app_user_oauth_clients
         where ords_client_name is not null
    )
    loop
        begin
            oauth.delete_client(
                p_name => r.ords_client_name
            );
        exception
            when others then
                if sqlcode not in (-20000, -01403) then
                    raise;
                end if;
        end;
    end loop;
end;
/

delete from app_api_event_log;
delete from app_user_oauth_clients;
delete from app_users;

commit;

prompt === Remaining application rows
select 'APP_USERS' as table_name, count(*) as row_count from app_users
union all
select 'APP_USER_OAUTH_CLIENTS', count(*) from app_user_oauth_clients
union all
select 'APP_API_EVENT_LOG', count(*) from app_api_event_log;

prompt === Remaining ORDS clients in schema
select count(*) as ords_client_count
  from user_ords_clients;
