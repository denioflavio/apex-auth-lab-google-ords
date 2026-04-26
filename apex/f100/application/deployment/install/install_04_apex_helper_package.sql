prompt --application/deployment/install/install_04_apex_helper_package
begin
--   Manifest
--     INSTALL: INSTALL-04 APEX Helper Package
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>9252854035907689
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APP_DEMO'
);
wwv_flow_imp_shared.create_install_script(
 p_id=>wwv_flow_imp.id(10913050000000011)
,p_install_id=>wwv_flow_imp.id(10913044024043292)
,p_name=>'04 APEX Helper Package'
,p_sequence=>40
,p_script_type=>'INSTALL'
,p_script_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'prompt =========================================================',
'prompt 04_apex_helpers.sql',
'prompt Optional APEX helper package for post-authentication',
'prompt =========================================================',
'',
'set define off',
'',
'create or replace package app_apex_auth as',
'    procedure post_login;',
'end app_apex_auth;',
'/',
'',
'create or replace package body app_apex_auth as',
'    procedure post_login is',
'        l_google_sub  varchar2(255 char);',
'        l_app_user_id number;',
'    begin',
'        l_google_sub := apex_util.get_session_state(''G_GOOGLE_SUB'');',
'',
'        if l_google_sub is null then',
'            raise_application_error(',
'                -20050,',
'                ''G_GOOGLE_SUB is null. Check the Social Sign-In attribute mapping.''',
'            );',
'        end if;',
'',
'        begin',
'            select id',
'              into l_app_user_id',
'              from app_users',
'             where google_sub = l_google_sub;',
'',
'            apex_util.set_session_state(''G_APP_USER_ID'', l_app_user_id);',
'        exception',
'            when no_data_found then',
'                apex_util.set_session_state(''G_APP_USER_ID'', null);',
'        end;',
'    end post_login;',
'end app_apex_auth;',
'/',
'',
'show errors'))
);
wwv_flow_imp_shared.create_install_object(
 p_id=>wwv_flow_imp.id(10913050000000012)
,p_script_id=>wwv_flow_imp.id(10913050000000011)
,p_object_owner=>'#OWNER#'
,p_object_type=>'PACKAGE'
,p_object_name=>'APP_APEX_AUTH'
);
wwv_flow_imp_shared.create_install_object(
 p_id=>wwv_flow_imp.id(10913050000000013)
,p_script_id=>wwv_flow_imp.id(10913050000000011)
,p_object_owner=>'#OWNER#'
,p_object_type=>'PACKAGE BODY'
,p_object_name=>'APP_APEX_AUTH'
);
wwv_flow_imp.component_end;
end;
/
