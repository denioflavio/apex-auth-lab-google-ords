prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>9252854035907689
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APP_DEMO'
);
wwv_flow_imp_page.create_page(
 p_id=>20
,p_name=>'Credentials generated'
,p_alias=>'CREDENTIALS-GENERATED'
,p_step_title=>'Credentials generated'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'17'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(10891735924954777)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(10859086258292522)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880013062148130)
,p_name=>'P20_FULL_NAME'
,p_item_sequence=>10
,p_prompt=>'Full Name'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880177752148131)
,p_name=>'P20_EMAIL'
,p_item_sequence=>20
,p_prompt=>'Email'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880269112148132)
,p_name=>'P20_PHONE_NUMBER'
,p_item_sequence=>30
,p_prompt=>'Phone Number'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880319703148133)
,p_name=>'P20_CLIENT_NAME'
,p_item_sequence=>40
,p_prompt=>'Client Name'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880483573148134)
,p_name=>'P20_CLIENT_ID'
,p_item_sequence=>50
,p_prompt=>'Client Id'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880555207148135)
,p_name=>'P20_CLIENT_SECRET'
,p_item_sequence=>60
,p_prompt=>'Client Secret'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10880692120148136)
,p_name=>'P20_MESSAGE'
,p_item_sequence=>70
,p_prompt=>'Message'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(10880748862148137)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'FECTH_USER'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_client_name varchar2(255 char);',
'    l_client_id   varchar2(255 char);',
'begin',
'    select full_name, email, phone_number',
'      into :P20_FULL_NAME, :P20_EMAIL, :P20_PHONE_NUMBER',
'      from app_users',
'     where id = :G_APP_USER_ID;',
'',
'    app_user_api.get_credentials_for_display(',
'        p_app_user_id     => :G_APP_USER_ID,',
'        p_out_client_name => l_client_name,',
'        p_out_client_id   => l_client_id',
'    );',
'',
'    :P20_CLIENT_NAME := l_client_name;',
'    :P20_CLIENT_ID   := l_client_id;',
'',
'    if :G_CREDS_CREATED_NOW = ''Y'' then',
'        :P20_CLIENT_SECRET := :G_ORDS_CLIENT_SECRET;',
'        :P20_MESSAGE := ''Credentials were created now. Copy this secret now because it will not be displayed again.'';',
'    else',
'        :P20_CLIENT_SECRET := null;',
'        :P20_MESSAGE := ''An active OAuth client already exists. This demo reuses the existing client and does not regenerate the secret.'';',
'    end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>10880748862148137
);
wwv_flow_imp.component_end;
end;
/
