prompt --application/pages/page_00011
begin
--   Manifest
--     PAGE: 00011
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
 p_id=>11
,p_name=>'Create custom account'
,p_alias=>'CREATE-CUSTOM-ACCOUNT'
,p_step_title=>'Create custom account'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12259111633641435)
,p_button_sequence=>70
,p_button_name=>'CREATE_CUSTOM_ACCOUNT'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Create Account'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12312570087831504)
,p_button_sequence=>80
,p_button_name=>'Cancel'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--link:t-Button--pillEnd'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_redirect_url=>'f?p=&APP_ID.:9999:&SESSION.::&DEBUG.:::'
,p_grid_new_row=>'N'
,p_grid_new_column=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12258453269641428)
,p_name=>'P11_EMAIL'
,p_is_required=>true
,p_item_sequence=>10
,p_prompt=>'Email'
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
 p_id=>wwv_flow_imp.id(12258513278641429)
,p_name=>'P11_FULL_NAME'
,p_item_sequence=>20
,p_prompt=>'Full Name'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12258611157641430)
,p_name=>'P11_BIRTH_DATE'
,p_is_required=>true
,p_item_sequence=>30
,p_prompt=>'Birth Date'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
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
 p_id=>wwv_flow_imp.id(12258732385641431)
,p_name=>'P11_PHONE_NUMBER'
,p_is_required=>true
,p_item_sequence=>40
,p_prompt=>'Phone Number'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12258884173641432)
,p_name=>'P11_PASSWORD'
,p_is_required=>true
,p_item_sequence=>50
,p_prompt=>'Password'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12258968360641433)
,p_name=>'P11_CONFIRM_PASSWORD'
,p_item_sequence=>60
,p_prompt=>'Confirm Password'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(12259061490641434)
,p_validation_name=>'Verify Matching Passwords'
,p_validation_sequence=>10
,p_validation=>'P11_CONFIRM_PASSWORD'
,p_validation2=>'&P11_PASSWORD.'
,p_validation_type=>'ITEM_IN_VALIDATION_EQ_STRING2'
,p_error_message=>'Passowords doesn''t match.'
,p_associated_item=>wwv_flow_imp.id(12258968360641433)
,p_error_display_location=>'INLINE_WITH_FIELD'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12259268763641436)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Create new custom user'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    app_multi_auth.create_custom_user(',
'        p_email                => :P11_EMAIL,',
'        p_full_name            => :P11_FULL_NAME,',
'        p_birth_date           => :P11_BIRTH_DATE,',
'        p_phone_number         => :P11_PHONE_NUMBER,',
'        p_password             => :P11_PASSWORD,',
'        p_out_app_user_id      => :G_APP_USER_ID,',
'        p_out_client_name      => :G_ORDS_CLIENT_NAME,',
'        p_out_client_id        => :G_ORDS_CLIENT_ID,',
'        p_out_client_secret    => :G_ORDS_CLIENT_SECRET,',
'        p_out_created_now_flag => :G_CREDS_CREATED_NOW',
'    );',
'',
'    apex_authentication.login(',
'        p_username           => :P11_EMAIL,',
'        p_password           => :P11_PASSWORD,',
'        p_uppercase_username => false',
'    );',
'',
'    apex_util.redirect_url(',
'        p_url => apex_page.get_url(p_page => 20)',
'    );',
'',
'    apex_application.stop_apex_engine;',
'end;',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(12259111633641435)
,p_process_success_message=>'User created'
,p_internal_uid=>12259268763641436
);
wwv_flow_imp.component_end;
end;
/
