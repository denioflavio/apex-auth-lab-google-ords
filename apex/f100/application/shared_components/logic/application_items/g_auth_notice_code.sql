prompt --application/shared_components/logic/application_items/g_auth_notice_code
begin
--   Manifest
--     APPLICATION ITEM: G_AUTH_NOTICE_CODE
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>9252854035907689
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APP_DEMO'
);
wwv_flow_imp_shared.create_flow_item(
 p_id=>wwv_flow_imp.id(12380082120461576)
,p_name=>'G_AUTH_NOTICE_CODE'
,p_protection_level=>'I'
,p_version_scn=>45284500300343
);
wwv_flow_imp.component_end;
end;
/
