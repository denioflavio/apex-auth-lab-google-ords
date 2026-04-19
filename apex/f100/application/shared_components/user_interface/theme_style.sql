prompt --application/shared_components/user_interface/theme_style
begin
--   Manifest
--     THEME STYLE: 100
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>9252854035907689
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'APP_DEMO'
);
wwv_flow_imp_shared.create_theme_style(
 p_id=>wwv_flow_imp.id(10900506562575311)
,p_theme_id=>42
,p_name=>'Redwood Light (copy_1)'
,p_css_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#APEX_FILES#libraries/oracle-fonts/oraclesans-apex#MIN#.css?v=#APEX_VERSION#',
'#THEME_FILES#css/Redwood#MIN#.css?v=#APEX_VERSION#'))
,p_css_classes=>' rw-pillar--plum rw-layout--fixed t-PageBody--scrollTitle rw-mode-nav--pillar rw-mode-body-header--dark rw-mode-header--pillar rw-mode-body--light'
,p_is_public=>true
,p_is_accessible=>false
,p_theme_roller_input_file_urls=>'#THEME_FILES#less/theme/Redwood-Theme.less'
,p_theme_roller_config=>'{"classes":["rw-pillar--plum","rw-layout--fixed t-PageBody--scrollTitle","rw-mode-nav--pillar","rw-mode-body-header--dark","rw-mode-header--pillar","rw-mode-body--light"],"vars":{},"customCSS":"","useCustomLess":"N"}'
,p_theme_roller_output_file_url=>'#THEME_DB_FILES#10900506562575311.css'
,p_theme_roller_read_only=>false
);
wwv_flow_imp.component_end;
end;
/
