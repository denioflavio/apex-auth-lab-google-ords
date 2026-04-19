prompt --application/shared_components/logic/application_items/g_social_email
begin
--   Manifest
--     APPLICATION ITEM: G_SOCIAL_EMAIL
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
 p_id=>wwv_flow_imp.id(10875288264267963)
,p_name=>'G_SOCIAL_EMAIL'
,p_protection_level=>'I'
,p_version_scn=>45283831836480
);
wwv_flow_imp.component_end;
end;
/
