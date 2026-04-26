prompt --application/shared_components/security/authentications/facebook_login
begin
--   Manifest
--     AUTHENTICATION: FACEBOOK_LOGIN
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
 p_id=>wwv_flow_imp.id(12254868481684549)
,p_name=>'FACEBOOK_LOGIN'
,p_scheme_type=>'NATIVE_SOCIAL'
,p_attribute_01=>wwv_flow_imp.id(12370842741599044)
,p_attribute_02=>'FACEBOOK'
,p_attribute_07=>'public_profile'
,p_attribute_09=>'id'
,p_attribute_10=>'email, name'
,p_attribute_11=>'N'
,p_attribute_13=>'Y'
,p_attribute_14=>'G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME'
,p_invalid_session_type=>'LOGIN'
,p_post_auth_process=>'APP_MULTI_AUTH.POST_LOGIN_FACEBOOK'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_switch_in_session_yn=>'Y'
,p_version_scn=>45284500082629
);
wwv_flow_imp.component_end;
end;
/
