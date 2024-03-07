#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           String
Library           OperatingSystem
Library           XML
Library           DateTime
Resource          ivi.robot

*** Variables ***

*** Keywords ***
GET CODING STRINGS FROM CONFIG XML
    [Arguments]    ${vehicle_config_name}    ${vehicle_type}
    [Documentation]    Get the coding strings from ota_cs.xml file
    ...    vehicle_config_name: ${vehicle_config_name} and vehicle_type: ${vehicle_type} are variables defined in CI
    Log To Console    Get the coding strings from ota_cs.xml file for ${vehicle_config_name} and ${vehicle_type}
    @{coding_strings} =     Create List
    ${config_pi_ver} =    GET CONFIG PI VERSION
    @{config_pi_ver} =    Split String    ${config_pi_ver}    @
    ${ota_cs_xml} =    Set Variable    ${vehicle_type}/config_scripts_${config_pi_ver}[0]/${vehicle_config_name}/ota_cs.xml
    ${root} =   Parse XML   ${ota_cs_xml}
    ${elem} =    Get Element    ${root}    CONFIG_FILE
    ${elem} =    Get Element    ${elem}    CS_LIST
    @{eles} =    Get Elements    ${elem}    CODING_STRING
    FOR    ${ele}    IN    @{eles}
        ${coding_string} =    Get Element Text    ${ele}
        Append To List    ${coding_strings}    ${coding_string}
    END
    [Return]    @{coding_strings}

GET CONFIG PI VERSION
    [Documentation]    Get the Config PI version from the versions.txt file depending upon the build
    Log To Console    Get the Config PI version from the versions.txt file depending upon the build
    ${ivi_build_id} =    GET IVI BUILD ID
    ${build_no} =    Get Substring    ${ivi_build_id}    4    12
    @{build_no_pos} =    Split String    ${build_no}    .
    ${build_no_pos_0} =    Get From List    ${build_no_pos}    0
    ${build_no_pos_1} =    Get From List    ${build_no_pos}    1
    ${build_no_pos_2} =    Get From List    ${build_no_pos}    2
    ${build_no_pos_0} =    Convert To Integer    ${build_no_pos_0}
    ${build_no_pos_1} =    Convert To Integer    ${build_no_pos_1}
    ${build_no_pos_2} =    Convert To Integer    ${build_no_pos_2}
    ${versions} =    Get File    versions.txt
    @{versions} =    Split To Lines    ${versions}
    ${config_pi_ver_line} =    Set Variable    ${None}
    ${config_previous_pi_ver_line} =    Set Variable    ${None}
    FOR    ${line}    IN    @{versions}
        ${config_pi_ver_line} =    Set Variable If    "${build_no}" in "${line}"    ${line}
        Exit For Loop If    "${config_pi_ver_line}" != "${None}"
        @{range} =    Split String    ${line}    :
        ${start_range} =    Get From List    ${range}    0
        @{start_range_pos} =    Split String    ${start_range}    .
        ${start_range_pos_0} =    Get From List    ${start_range_pos}    0
        ${start_range_pos_1} =    Get From List    ${start_range_pos}    1
        ${start_range_pos_2} =    Get From List    ${start_range_pos}    2
        ${start_range_pos_0} =    Convert To Integer    ${start_range_pos_0}
        ${start_range_pos_1} =    Convert To Integer    ${start_range_pos_1}
        ${start_range_pos_2} =    Convert To Integer    ${start_range_pos_2}

        ${end_range} =    Get From List    ${range}    1
        @{end_range_pos} =    Split String    ${end_range}    .
        ${end_range_pos_0} =    Get From List    ${end_range_pos}    0
        ${end_range_pos_1} =    Get From List    ${end_range_pos}    1
        ${end_range_pos_2} =    Get From List    ${end_range_pos}    2
        @{end_range_pos_2} =    Split String    ${end_range_pos_2}    ->
        ${end_range_pos_2} =    Get From List    ${end_range_pos_2}    0
        ${end_range_pos_0} =    Convert To Integer    ${end_range_pos_0}
        ${end_range_pos_1} =    Convert To Integer    ${end_range_pos_1}
        ${end_range_pos_2} =    Convert To Integer    ${end_range_pos_2}

        ${start_pos_0_status} =    Evaluate    ${build_no_pos_0} >= ${start_range_pos_0}
        ${end_pos_0_status} =    Evaluate    ${build_no_pos_0} <= ${start_range_pos_0}
        Continue For Loop If    "${start_pos_0_status}" == 'False' or "${end_pos_0_status}" == 'False'

        ${start_pos_0_status} =    Evaluate    ${build_no_pos_0} == ${start_range_pos_0}
        ${start_pos_1_status} =    Evaluate    ${build_no_pos_1} < ${start_range_pos_1}
        Continue For Loop If    "${start_pos_0_status}" == 'True' and "${start_pos_1_status}" == 'True'

        ${start_pos_1_status} =    Evaluate    ${build_no_pos_1} == ${start_range_pos_1}
        ${start_pos_2_status} =    Evaluate    ${build_no_pos_2} < ${start_range_pos_2}
        Continue For Loop If    "${start_pos_0_status}" == 'True' and "${start_pos_1_status}" == 'True' and "${start_pos_2_status}" == 'True'

        ${end_pos_0_status} =    Evaluate    ${build_no_pos_0} == ${end_range_pos_0}
        ${end_pos_1_status} =    Evaluate    ${build_no_pos_1} > ${end_range_pos_1}
        Continue For Loop If    "${end_pos_0_status}" == 'True' and "${end_pos_1_status}" == 'True'

        ${end_pos_1_status} =    Evaluate    ${build_no_pos_1} == ${end_range_pos_1}
        ${end_pos_2_status} =    Evaluate    ${build_no_pos_2} > ${end_range_pos_2}
        Continue For Loop If    "${end_pos_0_status}" == 'True' and "${end_pos_1_status}" == 'True' and "${end_pos_2_status}" == 'True'

        ${config_pi_ver_line} =    Set Variable    ${line}
        Exit For Loop
    END
    Should Not Be Equal    ${config_pi_ver_line}    ${None}    msg=Build Number: ${build_no} not identified
    @{config_pi_ver} =    Split String    ${config_pi_ver_line}    ->
    ${config_pi_ver} =    Get From List    ${config_pi_ver}    1
    Log To Console    PI Version selected : ${config_pi_ver}
    [Return]    ${config_pi_ver}

DOWNLOAD VEHICLE CONFIG FILE
    [Arguments]    ${download_url}
    ${last_modified_config_zip_file} =    GET LAST MODIFIED ZIP FILE    ${download_url}
    Set Test Variable    ${last_modified_config_zip_file}    ${last_modified_config_zip_file}
    CHECKSET FILE PRESENT    bench    ${last_modified_config_zip_file}
    ${last_modified_config_file} =    SET UNCOMPRESS FILE    bench    ${last_modified_config_zip_file}

GET LAST MODIFIED ZIP FILE
    [Arguments]    ${zip_path}
    [Documentation]    Get the last modified vehcile_config_zip_file from the artifactory
    ...    ${zip_path}    The path in artifactory from where the name of last modified config file has to be fetched
    Log To Console    Get the last modified vehcile_config_zip_file from the artifactory
    ${modified_dates} =    OperatingSystem.Run    jfrog rt search '${zip_path}*.zip' | grep modified
    @{modified_dates} =    Split To Lines    ${modified_dates}
    ${last_modified_date} =    Set Variable    2000-01-01 01:01:01.100
    ${last_modified_date_str} =    Set Variable    2000-01-01T01:01:01.100
    FOR    ${modified_date_str}    IN    @{modified_dates}
        ${modified_date_str} =    Strip String    ${modified_date_str}
        ${modified_date_str_no_extra} =    Get Substring    ${modified_date_str}    13    -8
        ${modified_date_str} =    Get Substring    ${modified_date_str}    13    -2
        ${modified_date} =    DateTime.Convert Date    ${modified_date_str_no_extra}    date_format=%Y-%m-%dT%H:%M:%S.%f
        ${time} =    DateTime.Subtract Date From Date    ${modified_date}    ${last_modified_date}
        ${last_modified_date} =    Set Variable If    ${time} > ${0}    ${modified_date}    ${last_modified_date}
        ${last_modified_date_str} =    Set Variable If    ${time} > ${0}    ${modified_date_str}    ${last_modified_date_str}
    END
    Log    ${last_modified_date_str}
    ${script_files} =    OperatingSystem.Run    jfrog rt search '${zip_path}*.zip'
    @{script_files} =    Split To Lines    ${script_files}
    @{script_files} =    Get Slice From List    ${script_files}    3    -1
    ${index} =    Get Index From List    ${script_files}    ${SPACE}${SPACE}${SPACE}${SPACE}"modified": "${last_modified_date_str}",
    ${index} =    Evaluate    ${index} - 4
    ${last_modified_zip_file} =    Get From List    ${script_files}    ${index}
    ${last_modified_zip_file} =    Get Substring    ${last_modified_zip_file}    13    -2
    ${last_modified_zip_file} =    Fetch From Right    ${last_modified_zip_file}    /
    [Return]    ${last_modified_zip_file}
