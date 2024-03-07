#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     System test utility
Resource          ${CURDIR}/Tools/bench_config.robot
Library           OperatingSystem
Resource          ${CURDIR}/power_supply.robot
Resource          ${CURDIR}/Tools/logs.robot
Resource          ${CURDIR}/VNext/apim_notif_remote_services.robot
Resource          ${CURDIR}/KMR/kmr_remote_services.robot
Resource          ${CURDIR}/ASAP/asap_remote_services.robot
Resource          ${CURDIR}/IVI/referencephone.robot
Resource          ${CURDIR}/IVI/app_management.robot
Resource          ${CURDIR}/IVI/ivi.robot
Resource          ${CURDIR}/IVI/hmi.robot
Resource          ${CURDIR}/IVC/ivc_commands.robot
Resource          ${CURDIR}/Vehicle/DOIP/doip.robot
Resource          ${CURDIR}/SGW/sgw.robot

*** Variables ***
${console_logs}    yes
${set_log_level_none}    False
${tc_config}    ${None}
@{tc_missing_variables}
@{tc_required_variables}
${launched_app_name}    ${None}
${ivi_hmi_action}    False
${vehicle_states_can_signal}     0
${path_temp}    sdcard/
${path_host}      /record/
${ivi_screen_record}        False
${TC_folder}    ${None}

*** Keywords ***
CHECK TARGET NOT IN ADB DEVICES LIST
    [Arguments]    ${target_id}    ${timeout}=1
    [Documentation]    Ensure a target is offline
    ...    ${target_id} either the bench or DUT
    Run Keyword if    "${console_logs}" == "yes"     Log    **** CHECK TARGET NOT IN ADB DEVICES LIST start. timeout : ${timeout}s ****    console=yes
    CHECK TARGET PRESENCE    ${target_id}    ${timeout}    False
    Run Keyword if    "${console_logs}" == "yes"     Log    **** CHECK TARGET NOT IN ADB DEVICES LIST end. ****    console=yes

CHECK TARGET IN ADB DEVICES LIST
    [Arguments]    ${target_id}    ${timeout}=1
    [Documentation]    Ensure a target is online
    ...    ${target_id} either the bench or DUT
    CHECK TARGET PRESENCE    ${target_id}    ${timeout}    True
    # Run Keyword If    ${timeout} != 0    CHECK TARGET PRESENCE    ${target_id}    ${timeout}    True

CHECK TARGET PRESENCE
    [Arguments]    ${target_id}    ${timeout}    ${presence}
    [Documentation]    Check target online or offline presence
    ...    ${target_id} either the bench or DUT
    FOR    ${var}    IN RANGE    1    ${timeout}
        Run Keyword if    "${console_logs}" == "yes"     Log    **** CHECK TARGET PRESENCE ${target_id} loop ${var} ${timeout} ****    console=yes
        ${result} =       WAIT FOR ADB DEVICE    ${target_id}    timeout=1   
        Run Keyword if    "${result}" == "True"    Sleep    1
        Exit For Loop If     ${result} == ${presence}
    END
    Log To Console    adb device detection ${result}!

GET BENCH NAME
    # In docker environment, hostname is set to a specific value which is different
    # from the host PC (the purpose is to isolate docker from the host PC environment).
    # So let's get PC hostname from /etc/hosts file instead of using hostname command.
    ${hostname} =    OperatingSystem.Run    hostname
    # ${hostname} =    Set Variable If    ${hostname_cmd} != "b''"    ${hostname_cmd.strip("b'").replace("\n", "").replace("\t", "").split(" ")[4]}    ""
    Run Keyword if    "${console_logs}" == "yes"        Log To Console    ${\n}BENCH NAME : ${hostname}${\n}
    Set Suite Variable    ${hostname}
    Set Tags    [BENCH] host : ${hostname}
    # [Return]    ${hostname}

CHECK PROCESS RUNNING
    [Arguments]    ${target_id}    ${process}    ${status}
    [Documentation]    Check that {process} is running using pgrep
    ${process_id_ivi} =    Run Keyword If    "${target_id}" == "ivi"    PS PACKAGE    ${process}
    ${error_host}    ${process_id_host} =    Run Keyword If    "${target_id}" == "host"    OperatingSystem.Run And Return Rc And Output    pgrep ${process}
    ${process_id} =    Set Variable If    "${target_id}" == "ivi"    ${process_id_ivi}    ${process_id_host}
    ${evaluation_running} =    Run Keyword If    "${target_id}" == "ivi"    Evaluate    ${process_id} == True
    ...    ELSE IF    "${target_id}" == "host"    Evaluate    """${process_id}""" != """${EMPTY}"""
    Run Keyword If    "${status}" == "running"    Should Be True    ${evaluation_running}    Process ${process} is not running for target ${target_id}
    Run Keyword If    "${status}" == "not_running"    Should Not Be True    ${evaluation_running}    Process ${process} is running for target ${target_id}

GET CURRENT TIMESTAMP
    [Documentation]  Generates a custom timestamp format for the test case name archive
    ${CurrentDate} =   DateTime.Get Current Date    LOCAL    result_format=%Y-%m-%dT%H:%M:%SZ
    ${current_timestamp} =    DateTime.Convert Date    ${CurrentDate}    result_format=%Y%m%d_%H%M%S
    Run Keyword if    "${console_logs}" == "yes"        Log To Console    ${\n}CURRENT TIMESTAMP : ${current_timestamp}${\n}
    Set Suite Variable    ${current_timestamp}

CHECK TEST CASE REQUIRED VARIABLES
    [Arguments]    ${variables_list}=${tc_required_variables}
    Run Keyword If     ${variables_list} == []    Return From Keyword

    FOR    ${item}   IN    @{variables_list}
        Run Keyword If    "${${item}}" == "${None}"    APPEND TO LIST    ${tc_missing_variables}    ${item}
    END
    Should Be Empty    ${tc_missing_variables}    msg= Following Variables are required for TC execution: ${tc_missing_variables}. Use -v option or update bench configuration file

LOAD TEST CASE CONFIGURATION
    [Arguments]    ${variables_list}=${tc_required_variables}
    ${tc_config} =    LOAD BENCH CONFIGURATION
    Set Suite Variable    ${tc_config}
    ${tc_name} =    Replace String    ${SUITE NAME}    ${space}    _
    Set Suite Variable     ${current_tc_name}    ${tc_name}_${current_timestamp}
    CHECK BENCH REQUIRED VARIABLES
    CHECK TEST CASE REQUIRED VARIABLES    ${variables_list}

START TEST CASE
    [Arguments]    ${variables_list}=${tc_required_variables}    ${ivi_hmi_action}=False    ${check_get_signal_strength}=False    ${keep_doip}=False
    Run Keyword if    "${console_logs}" == "yes"        Log To Console    ${\n}**** START TEST CASE ****${\n}
    LOAD TEST CASE CONFIGURATION    ${variables_list}
    START OFFBOARD TOOLS    setup_type=${tc_config}[bench_type]    offboard_init_params=${tc_config}[offboard_config]
    START LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]    setup_phase=True    artifactory_logs_folder=${tc_config}[bench_tools_config][logs_config][artifactory_logs_folder]
    START BENCH TOOLS    setup_type=${tc_config}[bench_type]    bench_init_params=${tc_config}[bench_tools_config]
    START VEHICLE    ${tc_config}[start_stop_config][start_can_sequence]
    START SGW CONFIG    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]    keep_doip=${keep_doip}
    WAIT VEHICLE BOOT COMPLETED    ${tc_config}[bench_type]    ${tc_config}[start_stop_config][start_timeout]
    START ONBOARD LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]    setup_phase=True
    LAUNCH ACTIONS AFTER BOOT    ${tc_config}[bench_type]    ${ivi_hmi_action}    ${tc_config}[start_stop_config][start_timeout]    ${check_get_signal_strength}    bench_init_params=${tc_config}[bench_tools_config]
    Run Keyword if    "${console_logs}" == "yes"         Log To Console    ${\n}**** End of START TEST CASE ****${\n}

STOP TEST CASE
    Run Keyword if    "${console_logs}" == "yes"     Log To Console   ${\n}**** STOP TEST CASE ****${\n}
    STOP COMPANION TOOLS    tc_variables=${tc_required_variables}    companion_params=${tc_config}[bench_tools_config][companion_config]
    STOP ONBOARD LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]    teardown_phase=True
    LAUNCH ACTIONS BEFORE SLEEP    ${tc_config}[bench_type]    ${ivi_hmi_action}
    STOP SGW CONFIG    setup_type=${tc_config}[bench_type]
    STOP VEHICLE    ${tc_config}[start_stop_config][stop_can_sequence]
    WAIT VEHICLE SLEEP MODE    ${tc_config}[bench_type]    ${tc_config}[start_stop_config][stop_timeout]
    STOP OFFBOARD TOOLS    setup_type=${tc_config}[bench_type]    offboard_stop_params=${tc_config}[offboard_config]
    STOP BENCH TOOLS    setup_type=${tc_config}[bench_type]    bench_stop_params=${tc_config}[bench_tools_config]    teardown_phase=True
    UNLOAD BENCH CONFIGURATION
    Run Keyword If    '${ivc_bench_type}' in "'${tc_config}[bench_type]'" or '${ccs2_bench_type}' in "'${tc_config}[bench_type]'" or '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"    CLOSE SSH SESSION
    Run Keyword if    "${console_logs}" == "yes"     Log To Console   ${\n}**** End of STOP TEST CASE ****${\n}

START OFFBOARD TOOLS
    [Arguments]    ${setup_type}    ${offboard_init_params}=${None}
    IF    '${ivi_bench_type}' in "'${setup_type}'" or "${offboard_init_params}[vnext_kmr]" == "${None}" or "${ivc_can}" == "False"
        Return From Keyword
    END
    IF    "${console_logs}" == "yes"
        Log To Console   **** START OFFBOARD TOOLS ****
    END
    IF    $trinity_bench
        Log To Console    Using Trinity configured CIRRUS GRPC server
    ELSE
        RETRIEVE VNEXT USER
        Remove From Dictionary   ${offboard_init_params['vehicle']}    USERID
        Set To Dictionary    ${offboard_init_params['vehicle']}    USERID    ${user_id}
        CIRRUS SET USER CONFIG    ${offboard_init_params['vehicle']}
    END
    START EVENT HUB CAPTURE
    IF   "${offboard_init_params}[vnext_kmr]" == "kmr" and ('${ivc_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'")
        Wait Until Keyword Succeeds    3 times    5s    SEND KMR GET TOKEN
        RETRIEVE KMR USER
        CHECKSET KMR USER CREATED    ${user_id}
        CHECKSET KMR USER ASSOCIATED WITH VIN    ${user_id}
    END

STOP OFFBOARD TOOLS
    [Arguments]    ${setup_type}    ${offboard_stop_params}=${None}
    Return From Keyword If    '${ivi_bench_type}' in "'${setup_type}'" or "${offboard_stop_params}[vnext_kmr]" == "${None}" or "${ivc_can}" == "False"
    IF    "${console_logs}" == "yes"
        Log To Console    **** STOP OFF BOARD TOOLS ****
    END
    STOP EVENT HUB CAPTURE

START BENCH TOOLS
    [Arguments]    ${setup_type}    ${bench_init_params}=${None}
    IF    "${console_logs}" == "yes"
        Log To Console    **** START BENCH TOOLS ****
    END
    IF    not "${bench_init_params}[can_architecture]" or "${bench_init_params}[can_architecture]" == "None"
        FAIL    [ERROR] No CAN Architecture specified.
    END
    LOAD CAN SCENARIOS
    LOAD DOIP CONFIGURATION

START SGW CONFIG
    [Arguments]    ${setup_type}    ${enable_logs}=False    ${keep_doip}=False

    IF    '${sweet400_bench_type}' not in "'${setup_type}'"
        Return From Keyword
    END
    IF    "${console_logs}" == "yes"
        Log To Console    **** START SGW CONFIG ****
    END

    # SET APC STATUS    status=${apc_state}
    # SET ACC STATUS    status=${acc_state}
    DOIP PLUG OBD PROBE
    Run Keyword And Ignore Error    GET SGW INFO
    Set Tags     [SGW] Build ID: ${sgw_sw}
    Set Tags     [SGW] Calib: ${sgw_calib}
    Set Tags     [SGW] Mode: ${sgw_mode}
    Set Tags     [SGW] Pairing: ${sgw_pairing}
    Set Tags     [SGW] VIN: ${sgw_vin}
    IF    "${sgw_vin}" != "${vehicle_id}"
        Log    SGW VIN ${sgw_vin} is not aligned with others ECUs ${vehicle_id}    WARN
    END
    IF    "${sgw_pairing}" == "00"
        Log    SGW Pairing is not done    WARN
    END
    START SGW ONBOARD LOGS    ${enable_logs}
    IF    "${keep_doip}" == "False"
        DOIP UNPLUG OBD PROBE
    END

STOP SGW CONFIG
    [Arguments]    ${setup_type}
    IF    '${sweet400_bench_type}' not in "'${setup_type}'"
        Return From Keyword
    END
    IF    "${console_logs}" == "yes"
        Log To Console    **** STOP SGW CONFIG ****
    END

    DOIP PLUG OBD PROBE
    STOP SGW ONBOARD LOGS
    DOIP UNPLUG OBD PROBE
    SET APC STATUS    status=off
    SET ACC STATUS    status=off

STOP BENCH TOOLS
    [Arguments]    ${setup_type}    ${bench_stop_params}=${None}    ${teardown_phase}=False
    IF    "${console_logs}" == "yes"
        Log To Console    **** STOP BENCH TOOLS ****
    END
    STOP LOGS TOOLS    setup_type=${setup_type}    enable_logs=${bench_stop_params}[logs_config][enable_logs]    artifactory_logs_folder=${bench_stop_params}[logs_config][artifactory_logs_folder]    teardown_phase=${teardown_phase}
    IF    "${bench_stop_params}[can_architecture]" != "${None}"
        QUIT CAN TOOL
    END
    IF    '${sweet400_bench_type}' in "'${setup_type}'"
        DOIP UNPLUG OBD PROBE
        SET APC STATUS    status=off
        SET ACC STATUS    status=off
    END

START VEHICLE
    [Arguments]    ${start_can_sequence}=${None}
    IF    "${console_logs}" == "yes"
        Log To Console    **** START VEHICLE ****
    END

    IF    "${start_can_sequence}" == "NO_CAN" or "${start_can_sequence}" == "None"
        Return From Keyword
    END

    LAUNCH INITIAL SEQUENCE    ${start_can_sequence}

STOP VEHICLE
    [Arguments]    ${stop_can_sequence}=${None}
    Run Keyword if    "${stop_can_sequence}" == "${None}" or "${stop_can_sequence}" == "NO_CAN"    Return From Keyword
    Run Keyword if    "${console_logs}" == "yes"     Log    **** STOP VEHICLE ****    console=yes
    Should Not Be Empty    ${stop_can_sequence}    [ERROR] Please specify CAN Stop sequence

    SEND CAN SEQUENCE TO STOP VEHICLE
    Sleep    5
    STOP CAN WRITING

WAIT VEHICLE BOOT COMPLETED
    [Arguments]    ${setup_type}    ${start_timeout}=${None}
    Run Keyword if    "${start_timeout}" == "0"    Return From Keyword

    Run Keyword if    "${console_logs}" == "yes"     Log    **** WAIT VEHICLE BOOT COMPLETED ****    console=yes
    Should Not Be Empty    ${setup_type}    [ERROR] Please specify Device Under Test configuration

    Run Keyword If    '${ivi_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"    CHECK IVI BOOT COMPLETED    booted    ${start_timeout}
    IF    '${ivc_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"
        CHECK IVC BOOT COMPLETED    ${start_timeout}    ${set_log_level_none}
        CHECK VEHICLE SIGNAL    IVC_FOTA_Status_v2    0x0    timeout=180
    END
    IF    "${CP_present}" == "True" and '${vehicle_states_can_signal}' >= '2' # = CUTOFFPENDING
        CHECK CENTRAL DISPLAY ACTIVATION
    END

WAIT VEHICLE SLEEP MODE
    [Arguments]    ${setup_type}    ${stop_timeout}=${None}
    Run Keyword if    "${stop_timeout}" == "0"    Return From Keyword

    Run Keyword if    "${console_logs}" == "yes"     Log    **** WAIT VEHICLE SLEEP MODE ****    console=yes
    Should Not Be Empty    ${setup_type}    [ERROR] Please specify Device Under Test configuration

    Run Keyword If    '${ivi_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"    CHECK TARGET NOT IN ADB DEVICES LIST    ${ivi_adb_id}    ${stop_timeout}
    Run Keyword if    "${console_logs}" == "yes"     Log    **** WAIT VEHICLE SLEEP MODE 1 ****    console=yes
    ${verdict} =  SKIP IVC HLK IF IVI USER BUILD  0
    Return From Keyword If    "${verdict}" == "True"
    Run Keyword if    "${console_logs}" == "yes"     Log    **** WAIT VEHICLE SLEEP MODE 2 ****    console=yes
    Run Keyword If    '${ivc_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"    CHECK IVC DISCONNECTED    ${stop_timeout}
    Run Keyword if    "${console_logs}" == "yes"     Log    **** WAIT VEHICLE SLEEP MODE 3 ****    console=yes

LAUNCH ACTIONS AFTER BOOT
    [Arguments]     ${setup_type}    ${ivi_hmi_action}=False    ${start_timeout}=${None}    ${check_get_signal_strength}=False    ${bench_init_params}=${tc_config}[bench_tools_config]
    START COMPANION TOOLS    tc_variables=${tc_required_variables}    companion_params=${bench_init_params}[companion_config]
    Set Suite Variable    ${ivi_hmi_action}
    Run Keyword if    "${start_timeout}" == "0" or "${boot_sleep_actions}" == "False"   Return From Keyword
    Run Keyword If    "${console_logs}" == "yes"     Log    **** LAUNCH ACTIONS AFTER BOOT start ****    console=yes
    Run Keyword If    "${TC_folder}"!="RELIABILITY" and '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"    CHECK ECUS FEATURE SW

    ${verdict} =  SKIP IVC HLK IF IVI USER BUILD  90
    IF    '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'" and "${verdict}" != "True"
        SET IVI IP TABLES FOR IVC SSH CONNECTION
        CHECK VIN AND PART ASSOCIATION    ivi
    END

    Run Keyword If    '${ivi_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"    Run Keywords    GET IVI INFO
    ...    AND    CHECKSET IVI SW FEATURE    ${tc_config}[offboard_config][vehicle][IVI_SW_BRANCH]
    ...    AND    CHECK VIN AND PART ASSOCIATION    ivi_id
    ...    AND    CHECK VIN CONFIG ON    ivi_id
    ...    AND    Run Keyword And Ignore Error    SWITCH IVI TO ADMIN USER
    ...    AND    CHECKSET IVI PLATFORM VERSION
    ...    AND    Run Keyword If    '${ivi_hmi_action}' == 'True'    CONFIGURE IVI WITH APPIUM
    ...    AND    Run Keyword And Ignore Error    BYPASS WIZARD PAGE    ${ivi_adb_id}

    Return From Keyword If    "${verdict}" == "True"

    Run Keyword If    '${ivc_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'"    Run Keywords    GET IVC INFO
    ...    AND    CHECKSET IVC SW FEATURE    ${tc_config}[offboard_config][vehicle][IVC_SW_BRANCH]
    ...    AND    CHECK VIN AND PART ASSOCIATION    ivc
    ...    AND    CHECKSET IVC LOCAL APN CONFIG    ${tc_config}[offboard_config][vehicle][LOCAL_IVC_APN]    ${tc_config}[offboard_config][vehicle][LOCAL_IVI_APN]
    ...    AND    CHECK IVC MQTT CONNECTION STATUS
    ...    AND    CHECK CERTIFICATE IS PRESENT ON    ivc_id
    ...    AND    CHECKSET VNEXT URL CONFIG    ivc
    ...    AND    CHECK VIN CONFIG ON    ivc
    ...    AND    SET VNEXT TIME AND DATE ON IVC
    ...    AND    CHECK PIN CODE STORED ON IVC    false
    Run Keyword If    '${ivc_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" and "${check_get_signal_strength.lower()}" == "true" or '${sweet400_bench_type}' in "'${setup_type}'" and "${check_get_signal_strength.lower()}" == "true"    RILSHELL IVC COMMAND CHECK SIGNAL STRENGTH
    Run Keyword If    "${console_logs}" == "yes"     Log    **** LAUNCH ACTIONS AFTER BOOT end ****    console=yes

LAUNCH ACTIONS BEFORE SLEEP
    [Arguments]     ${setup_type}    ${ivi_hmi_action}=False
    Run Keyword if    "${stop_timeout}" == "0" or "${boot_sleep_actions}" == "False"   Return From Keyword
    Run Keyword If    "${console_logs}" == "yes"     Log    **** LAUNCH ACTIONS BEFORE SLEEP ****    console=yes
    Run Keyword If    ('${ivi_bench_type}' in "'${setup_type}'" or '${ccs2_bench_type}' in "'${setup_type}'" or '${sweet400_bench_type}' in "'${setup_type}'") and '${ivi_hmi_action}' == 'True'    Run Keyword And Ignore Error    UNCONFIGURE IVI WITH APPIUM
    Run Keyword If    "${smartphone_capabilities}" != "${None}"    Run Keyword And Ignore Error    REMOVE APPIUM DRIVER    ${smartphone_capabilities}

CONFIGURE IVI WITH APPIUM
    CREATE APPIUM DRIVER
    RECONFIRM DATA PRIVACY
    DO HMI LANGUAGE SELECTION APPIUM    ${ivi_adb_id}    English
    LAUNCH APP APPIUM    Navigation
    GO HOME SCREEN APPIUM
    CLEAR PACKAGE    com.android.car.settings
    Run Keyword If    "${ivi_screen_record}" != "False"    START SCREEN RECORD

UNCONFIGURE IVI WITH APPIUM
    LAUNCH APP APPIUM    Navigation
    Run Keyword If    "${ivi_screen_record}" != "False"    STOP SCREEN RECORD    ${logs_folder}/ivi_screen_record.mp4
    REMOVE APPIUM DRIVER    ${ivi_capabilities}

SKIP IVC HLK IF IVI USER BUILD
    [Arguments]    ${timeout}=90
    [Documentation]    If requested by user, to switch in IVI User build mode, some IVC HLKs may be skipped
    ${verdict} =  Set Variable  False
    Run Keyword If    ('${ccs2_bench_type}' in "'${bench_type}'" or '${sweet400_bench_type}' in "'${bench_type}'") and '${ivc_access_thru_ivi}' == 'False'    Sleep    ${timeout}
    ${verdict} =   Run Keyword If    ('${ccs2_bench_type}' in "'${bench_type}'" or '${sweet400_bench_type}' in "'${bench_type}'") and '${ivc_access_thru_ivi}' == 'False'   Set Variable  True
    [Return]    ${verdict}

CHECKSET IVC SW FEATURE
    [Arguments]    ${sw_branch_input}=None
    [Documentation]    Compares IVC sw feature given with the one present on the bench setup and sets a global variable.
    Log    ${sw_branch_input}
    ${ivc_feature_id} =    GET IVC MY FEATURE ID
    IF    "${sw_branch_input}" == "${None}"
        ${ivc_my_feature_id} =    Set Variable    ${ivc_feature_id}
    ELSE
        ${ivc_my_feature_id} =    Set Variable    ${sw_branch_input}
        Run Keyword If    "${sw_branch_input}" != "${ivc_feature_id}"    LOG    There is a mismatch between the My_Feature provided by the user and the build version flashed.    level=WARN
    END
    Run Keyword if    "${console_logs}" == "yes"        Log To Console    IVC ${ivc_my_feature_id}
    Set Global Variable    ${ivc_my_feature_id}
    Set Tags     [IVC] MyFeature ID: ${ivc_my_feature_id}

CHECKSET IVI SW FEATURE
    [Arguments]    ${sw_branch_input}=None
    [Documentation]    Compares IVI sw feature given with the one present on the bench setup and sets a global variable.
    ${ivi_feature_id} =    GET IVI MY FEATURE ID
    IF    "${sw_branch_input}" == "${None}"
        ${ivi_my_feature_id} =    Set Variable    ${ivi_feature_id}
    ELSE
        ${ivi_my_feature_id} =    Set Variable    ${sw_branch_input}
        Run Keyword If    "${sw_branch_input}" != "${ivi_feature_id}"    LOG    There is a mismatch between the My_Feature provided by the user and the build version flashed.    level=WARN
    END
    Run Keyword if    "${console_logs}" == "yes"        Log To Console    IVI ${ivi_my_feature_id}
    Set Global Variable    ${ivi_my_feature_id}
    Set Tags     [IVI] MyFeature ID: ${ivi_my_feature_id}

CHECKSET IVI PLATFORM VERSION
    [Documentation]    Recuperate the platform version and sets a global variable.
    ${platform_version} =    GET PLATFORM VERSION
    Run Keyword if    "${console_logs}" == "yes"        Log To Console    IVI Android ${platform_version}
    Set Global Variable    ${platform_version}
    
CHECK ECUS FEATURE SW
    [Documentation]    Compares IVI and IVC feature sw in case of a mismatch.
    ${get_ivi_feature} =    GET IVI MY FEATURE ID
    ${get_ivc_feature} =    GET IVC MY FEATURE ID
    IF    "${get_ivi_feature}" == "${get_ivc_feature}"
        LOG    IVI and IVC have the same SW feature.
    ELSE
        FAIL   SW features on IVI and IVC are different.
    END

OBJECT DETECTION SETUP
    [Arguments]    ${config_name} 
    [Documentation]    Setup the configuration that contains objects needed to be detected. 
    @{config_list} =    TURNKEY GET CONFIGURATION
    Should Contain   ${config_list}   ${config_name}
    ${output} =    TURNKEY CHOOSE CONFIGURATION    ${config_name}
    Should Be True   ${output}

DETECT OBJECT BY IMAGE
    [Arguments]    ${objects_names_in_image}    ${image_name}    ${threshold}=70 
    [Documentation]    Check objects existence: ${objects_names_in_image} on ${image_name} For the ${threshold} to be fixed at 70.
    TAKE SCREENSHOT    ${path_temp}    ${image_name}      ${path_host}
    ${output}   ${error} =    PULL     ${path_temp}${image_name}     ${path_host}
    Should Contain     ${output}    file pulled
    ${features} =    TURNKEY START INFERENCE ON IMAGE   ${path_host}${image_name}
    ${output}   ${content} =    TURNKEY CHECK OJECTS EXIST BY NAME    ${objects_names_in_image}    ${threshold}
    TURNKEY STOP INFERENCE
    Should Be True   ${output}    ${content}
