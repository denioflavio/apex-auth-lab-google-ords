prompt --application/shared_components/security/authentications/google_social_sign_in
begin
--   Manifest
--     AUTHENTICATION: Google Social Sign-In
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
 p_id=>wwv_flow_imp.id(10898631635632048)
,p_name=>'Google Social Sign-In'
,p_scheme_type=>'NATIVE_SOCIAL'
,p_attribute_01=>wwv_flow_imp.id(10898206886653858)
,p_attribute_02=>'GOOGLE'
,p_attribute_07=>'profile,openid,email'
,p_attribute_08=>'prompt=select_account'
,p_attribute_09=>'#name#'
,p_attribute_10=>'sub,email,name'
,p_attribute_11=>'N'
,p_attribute_13=>'Y'
,p_attribute_14=>'G_GOOGLE_SUB,G_SOCIAL_EMAIL,G_SOCIAL_FULL_NAME'
,p_invalid_session_type=>'LOGIN'
,p_post_auth_process=>'APP_APEX_AUTH.POST_LOGIN'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_version_scn=>45283845508828
);
wwv_flow_imp.component_end;
end;
/
