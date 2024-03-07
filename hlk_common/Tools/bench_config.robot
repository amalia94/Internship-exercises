#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#

*** Settings ***
Library    Collections
Library    json
Library    String

*** Variables ***
${EE_architecture}            ${None}
${bench_type}                 ${None}
${pw_use}                     False
${ivi_micom_port}             ${None}
${ivi_bootloader_port}        ${None}
${smartphone_adb_id}          ${None}
${smartphone_bt_name}         ${None}
${ivi_adb_id}                 ${None}
${proxy_addr}                 ${Empty}
${proxy_port}                 0
${debug}                      False
${artifactory_logs_folder}    ${None}
${instance}                   apim
${env}                        ${None}
${relaycard_present}          False
${vehicle_id}                 ${None}
${user_id}                    ${None}
${username}                   ${None}
${password}                   ${None}
${key}                        ${None}
${wifi_ssid}                  ${None}
${wifi_pwd}                   ${None}
${vehicle_config_name}        ${None}
${vehicle_type}               ${None}
${hdmi_out}                   ${None}
${can_e}                      ${None}
${can_m}                      ${None}
${start_can_sequence}         ${None}
${stop_can_sequence}          ${None}
${start_timeout}              ${None}
${stop_timeout}               ${None}
${bench_config_file}          ${None}
${usb_stick_id}               ${None}
${stick_cutter}               ${None}
${stick_cutter_type}          ${None}
${stick_cutter_sub_type}      ${None}
${smartphone_cutter}          ${None}
${smartphone_cutter_type}     ${None}
${smartphone_cutter_sub_type}    ${None}
${bench_eth}                  ${None}
${sgw_mirroring_bench_eth}    ${None}
${trinity_bench}              False
${ivc_access_thru_ivi}        True
${gas_login}                  ${None}
${gas_pswd}                   ${None}
${local_ivc_apn_config}       ${None}
${local_ivi_apn_config}       ${None}
${ivc_sw_branch}              ${None}
${ivi_sw_branch}              ${None}
${CP_present}                 False
${ivc_build_type}             userdebug
${ivc_can}                    True
${ivi_can}                    True
${sgw_can}                    False
${central_panel_can}          False
${meter_can}                  False
${activation_line_state}      probe
${apc_state}                  off
${acc_state}                  off
${usbrelay_type}              ${None}
${boot_sleep_actions}         True

&{bench_proxy_config}         proxy_hostname=${proxy_addr}    proxy_port=${proxy_port}

${bench_config_folder}       /opt/rfw/all_bench_yml

${ivi_bench_type}    ivi2
${ivc_bench_type}    ivc2
${ccs2_bench_type}    ccs2
${sweet400_bench_type}    sweet400
${usb_selector_type}    selector
@{supported_bench_type_word}    ${ivi_bench_type}    ${ivc_bench_type}    ${ccs2_bench_type}    ${sweet400_bench_type}
@{bench_config_interfaces_items}    can_e    can_m    stick_cutter    smartphone_cutter    bench_eth
@{bench_config_general_items}    bench_type    wifi_ssid    wifi_pwd    smartphone_adb_id    smartphone_bt_name    proxy_addr    proxy_port
@{bench_config_vehicle_items}    EE_architecture    key    vehicle_config_name    vehicle_type    hdmi_out    env    vehicle_id    user_id    username    password    client_secret    gas_login    gas_pswd    ivc_sw_branch    ivi_sw_branch
@{bench_config_ivi2_items}    ivi_adb_id    ivi_micom_port    ivi_bootloader_port
@{bench_config_ivc2_items}    serial_id    ctrl_type
@{bench_config_log_items}    debug    artifactory_logs_folder
@{bench_config_power_supply_items}    pw_use
@{bench_config_host_items}    usb_stick_id
@{bench_item_log_tags}    bench_type    EE_architecture    ivi_adb_id    ctrl_type    vehicle_id    user_id    env    instance  
@{bench_ccs2_minimum_variables}    can_e    EE_architecture    key    vehicle_id    user_id    username    password    env    ivi_adb_id    client_secret    ivc_access_thru_ivi
@{bench_ivc2_minimum_variables}    can_e    EE_architecture    key    env
@{bench_ivi2_minimum_variables}    can_e    EE_architecture    key    ivi_adb_id
@{bench_missing_variables}

@{empty_list}
${console_logs}    yes

*** Keywords ***
LOAD BENCH CONFIGURATION
    IF    "${console_logs}" == "yes"
        Log To Console    **** LOAD BENCH CONFIGURATION ****
    END
    GET CURRENT TIMESTAMP
    GET BENCH NAME
    GET TRINITY CONFIG

    ${bench_config_folder_status} =    Run Keyword And Return Status    Directory Should Exist    ${bench_config_folder}
    ${bench_config_file} =    Run Keyword If    "${bench_config_file}" == "${None}" and "${bench_config_folder_status}" == "True"    OperatingSystem.Run    find ${bench_config_folder} -name "*${hostname}.yml"
    IF    $bench_config_folder_status is True and $bench_config_file is None
        ${bench_config_file} =    OperatingSystem.Run    find ${bench_config_folder} -name "*${hostname}.yml"
    END

    IF    not $bench_config_file
        IF    "${console_logs}" == "yes"
            Log   Config file for ${hostname} bench is not available, setting default values.    console=yes    level=WARN
        END
        SET DEFAULT TEST VALUES
    ELSE
        Import Variables    ${bench_config_file}
        GET BENCH CONFIG FILE VALUES
        SET CAN CONFIG FILE
    END

    SET CAN BOOT SLEEP VALUES
    ${config} =    SET TEST CONFIG

    [Return]    ${config}

UNLOAD BENCH CONFIGURATION
    Remove File    ${CURDIR}/can_config_${hostname}.json
    # Set Suite Variable    ${start_can_sequence}    ${None}
    # Set Suite Variable    ${stop_can_sequence}    ${None}
    # Set Suite Variable    ${start_timeout}    ${None}
    # Set Suite Variable    ${stop_timeout}    ${None}

GET TRINITY CONFIG
    Set Suite Variable    ${trinity_bench}    %{TRINITY_SETUP=False}
    Set Tags     [BENCH] Trinity : ${trinity_bench}

SET DEFAULT TEST VALUES
    Run Keyword If    "${can_e}" == '${None}'    Set Suite Variable    ${can_e}                slcan0
    Run Keyword If    "${EE_architecture}" == '${None}'    Set Suite Variable    ${EE_architecture}    C1A-HS
    Run Keyword If    "${bench_type}" == '${None}'    Set Suite Variable    ${bench_type}       ${ccs2_bench_type}
    Run Keyword If    "${instance}" == '${None}'    Set Suite Variable    ${instance}           apim
    Run Keyword If    "${env}" == '${None}'    Set Suite Variable    ${env}                sit-emea
    Run Keyword If    "${key}" == '${None}'    Set Suite Variable    ${key}                000102030405060708090a0b0c0d0e0f
    Run Keyword If    '${ivi_bench_type}' in "'${bench_type}'"    Set Suite Variable    ${ivc_can}                False
    Run Keyword If    '${ivc_bench_type}' in "'${bench_type}'"    Set Suite Variable    ${ivi_can}                False

SET CAN BOOT SLEEP VALUES
    Run Keyword If    "${start_can_sequence}" == '${None}'    Set Suite Variable    ${start_can_sequence}    Start_vehicle_sequence_MMI_ON_FULL_USER_HMI
    Run Keyword If    "${stop_can_sequence}" == '${None}'    Set Suite Variable    ${stop_can_sequence}       Stop_vehicle_sequence_FROM_ON_STATE
    Run Keyword If    "${start_can_sequence}" == "NO_CAN"    Set Suite Variable    ${start_timeout}    0
    ...    ELSE IF    "${start_timeout}" == '${None}'    Set Suite Variable    ${start_timeout}    180
    ...    ELSE IF    "${start_timeout}" != '${None}'    Set Suite Variable    ${start_timeout}    ${start_timeout}
    ...    ELSE    FAIL    Please check your configuration
    Run Keyword If    "${stop_can_sequence}" == "NO_CAN"    Set Suite Variable    ${stop_timeout}    0
    ...    ELSE IF    "${stop_timeout}" == '${None}'    Set Suite Variable    ${stop_timeout}    80
    ...    ELSE IF    "${stop_timeout}" != '${None}'    Set Suite Variable    ${stop_timeout}    ${stop_timeout}
    ...    ELSE    FAIL    Please check your configuration

SET TEST CONFIG
    &{bench_proxy_config}      Create Dictionary      proxy_hostname=${proxy_addr}    proxy_port=${proxy_port}
    &{bench_power_supply_config}     Create Dictionary    use_power_supply=${pw_use}    activation_line=${activation_line_state}    apc=${apc_state}
    &{bench_companion_config}     Create Dictionary    adb_id=${smartphone_adb_id}   bt_name=${smartphone_bt_name}    cutter_id=${smartphone_cutter}

    &{TC_vehicle_config}     Create Dictionary    VIN=${vehicle_id}    USERID=${user_id}    USERNAME=${username}    USER_PIN_CODE=${password}    LOCAL_IVC_APN=${local_ivc_apn_config}    LOCAL_IVI_APN=${local_ivi_apn_config}    IVC_SW_BRANCH=${ivc_sw_branch}    IVI_SW_BRANCH=${ivi_sw_branch}
    &{TC_offboard_config}    Create Dictionary    vehicle=&{TC_vehicle_config}    offboard_env=${env}     vnext_kmr=${instance}

    &{TC_start_stop_config}    Create Dictionary    start_can_sequence=${start_can_sequence}     start_timeout=${start_timeout}    stop_can_sequence=${stop_can_sequence}    stop_timeout=${stop_timeout}
    &{TC_logs_config}     Create Dictionary      enable_logs=${debug}    artifactory_logs_folder=${artifactory_logs_folder}
    &{TC_bench_tools_config}    Create Dictionary    can_architecture=${EE_architecture}    cipher_key=${key}    powersupply_config=&{bench_power_supply_config}    logs_config=&{TC_logs_config}    proxy=&{bench_proxy_config}    companion_config=&{bench_companion_config}    central_panel=${CP_present}

    &{TC_config}           Create Dictionary     bench_type=${bench_type}    offboard_config=&{TC_offboard_config}    bench_tools_config=&{TC_bench_tools_config}    start_stop_config=&{TC_start_stop_config}
    [Return]    ${TC_config}

CHECK BENCH REQUIRED VARIABLES
    ${regexp_value} =    Catenate    SEPARATOR=    (
    ${list_size} =    Get Length    ${supported_bench_type_word}
    ${item_id}   Set Variable    ${1}
    FOR    ${item}   IN    @{supported_bench_type_word}
        ${regexp_value} =    Catenate    SEPARATOR=     ${regexp_value}    ${item}
        ${regexp_value} =    Run Keyword If     ${item_id} != ${list_size}    Catenate    SEPARATOR=     ${regexp_value}    |
        ...    ELSE    Set Variable    ${regexp_value}
        ${item_id} =    Evaluate    ${item_id} + 1
    END
    ${regexp_value} =    Catenate    SEPARATOR=     ${regexp_value}    )
    Should Not Be Equal    ${bench_type}    ${None}    msg=Please specify a valid bench type from @{supported_bench_type_word} list
    Should Match Regexp    ${bench_type}    ${regexp_value}    msg=Please specify a valid bench type containing either @{supported_bench_type_word} word

    @{bench_variables_to_check} =    Run Keyword If    '${ccs2_bench_type}' in "'${bench_type}'" or '${sweet400_bench_type}' in "'${bench_type}'"    Set Variable     ${bench_ccs2_minimum_variables}
    ...    ELSE    Run Keyword If    '${ivc_bench_type}' in "'${bench_type}'"    Set Variable     ${bench_ivc2_minimum_variables}
    ...    ELSE    Run Keyword If    '${ivi_bench_type}' in "'${bench_type}'"    Set Variable     ${bench_ivi2_minimum_variables}

    FOR    ${item}   IN    @{bench_variables_to_check}
        Run Keyword If    "${${item}}" == "${None}"    APPEND TO LIST    ${bench_missing_variables}    ${item}
        Run Keyword If    "${item}" in @{bench_item_log_tags}    Set Tags     [BENCH] ${item} : ${${item}}
    END
    Should Be Empty    ${bench_missing_variables}    msg= Following Bench Variables are required for TC execution: ${bench_missing_variables}. Use -v option or update bench configuration file

SET CONFIG ITEM VALUE
    [Arguments]    ${item_type}    ${item}
    ${config_file_variable} =    Catenate    SEPARATOR=     ${item_type}    ["${item}"]
    ${var}=    Run Keyword If    "${${item}}" == '${None}'     Get Variable Value    ${${config_file_variable}}
    Run Keyword If    """${var}""" != 'None'    Set Suite Variable    ${${item}}    ${var}

SET CONFIG INTERFACES ITEM VALUE
    [Arguments]    ${item}
    ${config_file_type_variable} =    Catenate    SEPARATOR=     interface    ["${item}"]    ["type"]
    ${if_name_variable} =    Catenate    SEPARATOR=     interface    ["${item}"]    ["name"]
    ${usb_ctrl_id_variable} =    Catenate    SEPARATOR=     interface    ["${item}"]    ["serial_id"]
    ${usb_ctrl_cutter_type_variable} =    Catenate    SEPARATOR=     interface    ["${item}"]    ["cutter_type"]
    ${usb_ctrl_line_dut_variable} =    Catenate    SEPARATOR=     interface    ["${item}"]    ["dut_line"]
    ${usb_ctrl_cutter_sub_type_variable} =    Catenate    SEPARATOR=     interface    ["${item}"]    ["cutter_sub_type"]

    ${var_if_type}=    Run Keyword If    "${${item}}" == '${None}'     Get Variable Value    ${${config_file_type_variable}}
    Run Keyword If    """${var_if_type}""" == 'None'    Return From Keyword

    ${var}=    Run Keyword If    "${var_if_type}" == "can" or "${var_if_type}" == "eth"    Get Variable Value    ${${if_name_variable}}
    ...    ELSE    Run Keyword If    "${var_if_type}" == "usb"    Get Variable Value    ${${usb_ctrl_id_variable}}

    ${var_usb_cutter_type}=    Run Keyword If    "${var_if_type}" == "usb"    Get Variable Value    ${${usb_ctrl_cutter_type_variable}}
    Run Keyword If    "${var_usb_cutter_type}" != "${None}" and "${item}" == "stick_cutter"    Set Suite Variable    ${stick_cutter_type}    ${${usb_ctrl_cutter_type_variable}}
    Run Keyword If    "${var_usb_cutter_type}" != "${None}" and "${item}" == "smartphone_cutter"    Set Suite Variable    ${smartphone_cutter_type}    ${${usb_ctrl_cutter_type_variable}}
    Run Keyword If    "${var_usb_cutter_type}" != "${None}" and "${var_if_type}" == "usb" and '${usb_selector_type}' in "'${stick_cutter_type}'"   Set Suite Variable    ${dut_cutter_line}    ${${usb_ctrl_line_dut_variable}}

    ${var_usb_cutter_sub_type}=    Run Keyword If    "${var_if_type}" == "usb"    Get Variable Value    ${${usb_ctrl_cutter_sub_type_variable}}
    Run Keyword If    "${var_usb_cutter_sub_type}" != "${None}" and "${item}" == "stick_cutter"    Set Suite Variable    ${stick_cutter_sub_type}    ${${usb_ctrl_cutter_sub_type_variable}}
    Run Keyword If    "${var_usb_cutter_sub_type}" != "${None}" and "${item}" == "smartphone_cutter"    Set Suite Variable    ${smartphone_cutter_sub_type}    ${${usb_ctrl_cutter_sub_type_variable}}
    
    Set Suite Variable    ${${item}}    ${var}
    Set Tags     [I/F] ${item} : ${${item}}

GET BENCH CONFIG FILE VALUES
    FOR    ${item}   IN    @{bench_config_interfaces_items}
        SET CONFIG INTERFACES ITEM VALUE    ${item}
    END

    FOR    ${item}   IN    @{bench_config_general_items}
        SET CONFIG ITEM VALUE    general    ${item}
    END

    FOR    ${item}   IN    @{bench_config_vehicle_items}
        SET CONFIG ITEM VALUE    vehicle    ${item}
    END

    FOR    ${item}   IN    @{bench_config_ivi2_items}
        SET CONFIG ITEM VALUE    ivi_2    ${item}
    END

    FOR    ${item}   IN    @{bench_config_log_items}
        SET CONFIG ITEM VALUE    log    ${item}
    END

    FOR    ${item}   IN    @{bench_config_power_supply_items}
        SET CONFIG ITEM VALUE    power_supply    ${item}
    END

    FOR    ${item}   IN    @{bench_config_host_items}
        SET CONFIG ITEM VALUE    host    ${item}
    END

SET CAN CONFIG FILE
    ${can_e_protocols_dict}    Create Dictionary    can_uudt=${Empty}    can_uds=${Empty}
    ${can_e_networks_dict}    Create Dictionary    EXT-CAN=@{empty_list}
    ${can_e_dict}    Create Dictionary    channel=${can_e}    bustype=socketcan    can_type=can-hs    networks=${can_e_networks_dict}    protocols=${can_e_protocols_dict}
    ${main_dict}    Create Dictionary    can0=${can_e_dict}

    Run Keyword If    "${can_m}" != '${None}'    ADD CAN M DICT TO    ${main_dict}

    Run Keyword If    '${ivi_bench_type}' in "'${bench_type}'" or '${ccs2_bench_type}' in "'${bench_type}'" or '${sweet400_bench_type}' in "'${bench_type}'"    ADD ETH IVI DICT TO    ${main_dict}
    Run Keyword If    '${ccs2_bench_type}' in "'${bench_type}'" or '${sweet400_bench_type}' in "'${bench_type}'"     ADD ETH IVC DICT TO    ${main_dict}
    Run Keyword If    '${ivc_bench_type}' in "'${bench_type}'"     ADD ETH IVC STD DICT TO    ${main_dict}

    ${main_json}    Json.Dumps    ${main_dict}
    OperatingSystem.Create File    ${CURDIR}/can_config_${hostname}.json    content=${main_json}
    Set Suite Variable    ${can_config}    ${CURDIR}/can_config_${hostname}.json
    Log    CAN Config JSON file created : ${main_json}

ADD CAN M DICT TO
    [Arguments]    ${dict}
    ${can_m_protocols_dict}    Create Dictionary    can_uudt=${Empty}    can_uds=${Empty}
    ${can_m_networks_dict}    Create Dictionary    M-CAN=@{empty_list}
    ${can_m_dict}    Create Dictionary    channel=${can_m}    bustype=socketcan    can_type=can-hs    networks=${can_m_networks_dict}     protocols=${can_m_protocols_dict}
    Set To Dictionary    ${dict}    can1=${can_m_dict}

ADD ETH IVI DICT TO
    [Arguments]    ${dict}
    ${doip_ivi_dict}    Create Dictionary    source_ip=192.168.12.1    target_ip=192.168.12.4    port=${13400}    source_ecu_address=0x0E80    target_ecu_address=0x0058
    ${eth_protocols_dict}    Create Dictionary    do_ip=${doip_ivi_dict}
    ${eth_ivi_protocols}    Create Dictionary    protocols=${eth_protocols_dict}
    Set To Dictionary    ${dict}    eth_ivi=${eth_ivi_protocols}

ADD ETH IVC DICT TO
    [Arguments]    ${dict}
    ${doip_ivc_dict}    Create Dictionary    source_ip=192.168.12.3    target_ip=192.168.12.4    port=${13400}    source_ecu_address=0x0E80    target_ecu_address=0x0077
    ${eth_protocols_dict}    Create Dictionary    do_ip=${doip_ivc_dict}
    ${eth_ivc_protocols}    Create Dictionary    protocols=${eth_protocols_dict}
    Set To Dictionary    ${dict}    eth_ivc=${eth_ivc_protocols}

ADD ETH IVC STD DICT TO
    [Arguments]    ${dict}
    ${doip_ivc_std_dict}    Create Dictionary    source_ip=192.168.12.3    target_ip=192.168.12.1    port=${13400}    source_ecu_address=0x0E80    target_ecu_address=0x0077
    ${eth_protocols_dict}    Create Dictionary    do_ip=${doip_ivc_std_dict}
    ${eth_ivc_std_protocols}    Create Dictionary    protocols=${eth_protocols_dict}
    Set To Dictionary    ${dict}    eth_ivc_std=${eth_ivc_std_protocols}


