prompt --application/shared_components/security/authentications/custom_login
begin
--   Manifest
--     AUTHENTICATION: Custom Login
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>9252854035907689
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APP_DEMO'
);
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(12254442905727874)
,p_name=>'Custom Login'
,p_scheme_type=>'NATIVE_CUSTOM'
,p_attribute_03=>'APP_MULTI_AUTH.AUTHENTICATE_CUSTOM'
,p_attribute_05=>'N'
,p_invalid_session_type=>'LOGIN'
,p_post_auth_process=>'APP_MULTI_AUTH.POST_LOGIN_CUSTOM'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_switch_in_session_yn=>'Y'
,p_version_scn=>45284476864636
);
wwv_flow_imp.component_end;
end;
/
