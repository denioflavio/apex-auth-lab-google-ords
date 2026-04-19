prompt =========================================================
prompt 04_apex_helpers.sql
prompt Optional APEX helper package for post-authentication
prompt =========================================================

set define off

create or replace package app_apex_auth as
    procedure post_login;
end app_apex_auth;
/

create or replace package body app_apex_auth as
    procedure post_login is
        l_google_sub  varchar2(255 char);
        l_app_user_id number;
    begin
        l_google_sub := apex_util.get_session_state('G_GOOGLE_SUB');

        if l_google_sub is null then
            raise_application_error(
                -20050,
                'G_GOOGLE_SUB is null. Check the Social Sign-In attribute mapping.'
            );
        end if;

        begin
            select id
              into l_app_user_id
              from app_users
             where google_sub = l_google_sub;

            apex_util.set_session_state('G_APP_USER_ID', l_app_user_id);
        exception
            when no_data_found then
                apex_util.set_session_state('G_APP_USER_ID', null);
        end;
    end post_login;
end app_apex_auth;
/

show errors
