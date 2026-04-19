prompt --application/pages/page_00010
begin
--   Manifest
--     PAGE: 00010
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
 p_id=>10
,p_name=>'Complete your profile'
,p_alias=>'COMPLETE-YOUR-PROFILE'
,p_step_title=>'Complete your profile'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'17'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(10883358175134186)
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(10877899230148108)
,p_button_sequence=>60
,p_button_name=>'BT_GENERATE_CREDENTIALS'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generate Credentials'
,p_icon_css_classes=>'fa-key'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(10879153372148121)
,p_branch_action=>'f?p=&APP_ID.:20:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10877340527148103)
,p_name=>'P10_FULL_NAME'
,p_is_required=>true
,p_item_sequence=>10
,p_item_default=>'G_SOCIAL_FULL_NAME'
,p_item_default_type=>'ITEM'
,p_prompt=>'Full Name'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10877400408148104)
,p_name=>'P10_BIRTH_DATE'
,p_is_required=>true
,p_item_sequence=>20
,p_prompt=>'Birth Date'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10877501261148105)
,p_name=>'P10_PHONE_NUMBER'
,p_is_required=>true
,p_item_sequence=>30
,p_prompt=>'Phone Number'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10877683132148106)
,p_name=>'P10_EMAIL'
,p_item_sequence=>40
,p_item_default=>'G_SOCIAL_EMAIL'
,p_item_default_type=>'ITEM'
,p_prompt=>'Email'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(10877723493148107)
,p_name=>'P10_GOOGLE_SUB'
,p_item_sequence=>50
,p_item_default=>'G_GOOGLE_SUB'
,p_item_default_type=>'ITEM'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(10878078307148110)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_INVOKE_API'
,p_process_name=>'SUBMIT_PROCESS'
,p_attribute_01=>'PLSQL_PACKAGE'
,p_attribute_03=>'APP_USER_API'
,p_attribute_04=>'COMPLETE_REGISTRATION'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>10878078307148110
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878169594148111)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_google_sub'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>10
,p_value_type=>'ITEM'
,p_value=>'P10_GOOGLE_SUB'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878247380148112)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_email'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>20
,p_value_type=>'ITEM'
,p_value=>'P10_EMAIL'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878308231148113)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_full_name'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>30
,p_value_type=>'ITEM'
,p_value=>'P10_FULL_NAME'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878419826148114)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_birth_date'
,p_direction=>'IN'
,p_data_type=>'DATE'
,p_has_default=>false
,p_display_sequence=>40
,p_value_type=>'ITEM'
,p_value=>'P10_BIRTH_DATE'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878515941148115)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_phone_number'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>50
,p_value_type=>'ITEM'
,p_value=>'P10_PHONE_NUMBER'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878623283148116)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_out_app_user_id'
,p_direction=>'OUT'
,p_data_type=>'NUMBER'
,p_ignore_output=>false
,p_display_sequence=>60
,p_value_type=>'ITEM'
,p_value=>'G_APP_USER_ID'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878795796148117)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_out_client_name'
,p_direction=>'OUT'
,p_data_type=>'VARCHAR2'
,p_ignore_output=>false
,p_display_sequence=>70
,p_value_type=>'ITEM'
,p_value=>'G_ORDS_CLIENT_NAME'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878866322148118)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_out_client_id'
,p_direction=>'OUT'
,p_data_type=>'VARCHAR2'
,p_ignore_output=>false
,p_display_sequence=>80
,p_value_type=>'ITEM'
,p_value=>'G_ORDS_CLIENT_ID'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10878901024148119)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_out_client_secret'
,p_direction=>'OUT'
,p_data_type=>'VARCHAR2'
,p_ignore_output=>false
,p_display_sequence=>90
,p_value_type=>'ITEM'
,p_value=>'G_ORDS_CLIENT_SECRET'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(10879048077148120)
,p_page_process_id=>wwv_flow_imp.id(10878078307148110)
,p_page_id=>10
,p_name=>'p_out_created_now_flag'
,p_direction=>'OUT'
,p_data_type=>'VARCHAR2'
,p_ignore_output=>false
,p_display_sequence=>100
,p_value_type=>'ITEM'
,p_value=>'G_CREDS_CREATED_NOW'
);
wwv_flow_imp.component_end;
end;
/
