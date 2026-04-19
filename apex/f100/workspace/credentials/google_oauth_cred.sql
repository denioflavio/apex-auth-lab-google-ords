prompt --workspace/credentials/google_oauth_cred
begin
--   Manifest
--     CREDENTIAL: GOOGLE_OAUTH_CRED
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>9252854035907689
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APP_DEMO'
);
wwv_imp_workspace.create_credential(
 p_id=>wwv_flow_imp.id(10898206886653858)
,p_name=>'GOOGLE_OAUTH_CRED'
,p_static_id=>'google_oauth_cred'
,p_authentication_type=>'BASIC'
,p_prompt_on_install=>true
);
wwv_flow_imp.component_end;
end;
/
