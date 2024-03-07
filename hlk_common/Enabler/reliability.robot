#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     reliability - keywords library
Library           rfw_services.ivi.MonkeyLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ReliabilityLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ReliabilityNavLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ReliabilityCommonLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.FileSystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AudiomediaLib    device=${ivi_adb_id}
Library           rfw_services.ivi.UserProfilLib    device=${ivi_adb_id}
Library           rfw_services.wicket.SystemLib
Library           rfw_services.wicket.DeviceLib
Library           rfw_libraries.toolbox.StatsLib
Library           ../../hlk_common/Reliability/reliability_utils.py
Resource          ../../hlk_common/IVI/Connectivity/bluetooth.robot
Resource          ../../hlk_common/IVI/Connectivity/gps.robot
Resource          ../../hlk_common/IVI/userprofil.robot
Resource          ../../hlk_common/IVI/filesystem.robot
Resource          ../../hlk_common/IVI/network.robot
Resource          ../../hlk_common/IVI/new_hmi.robot
Resource          ../../hlk_common/IVC/ivc_commands.robot
Resource          ../../hlk_common/IVI/audio.robot
Library           Collections
Library           String
Library           DateTime
Library           Process
Library           OperatingSystem
Library           rfw_libraries.tools.RelayCardManager

*** Variables ***
${df_cmd_used_data_before}    ${EMPTY}
${df_cmd_used_data_after}    ${EMPTY}
&{target}         host=bench    dut=ivi
${status_list_no_verdict}
${status_list_verdict}
${ret_step_kw_bool}
${error_string}    Error
${yt_button}    //*[@resource-id="com.google.android.apps.youtube.music:id/skip_button"]
${platform_version}               10
${threshold}            ${15}
@{list_boot_time}
${factory_reset_language_selection}   //*[@resource-id="android:id/title"]
${debug}                    True
${threshold_ccs2_wakeup001}      50.0
${webcam_present}    False

${entering_garage_mode_myf3}    CAR.GarageMode_GarageMode: Entering GarageMode
${entering_garage_mode_myf2}    [GarageMode]: Entering GarageMode
${shutdown_without_garage_mode}    starting shutdown prepare without Garage Mode
${check_garage_mode_budget_accumulation}    checkRemainedBudgetAmount\(\):.* , accumulated Garage time : (?:[0-9]{1,2}|[12][0-9]{2}) seconds

*** Keywords ***
SET LAUNCH MAPS
    [Arguments]    ${ivi}
    [Documentation]    LAUNCH MAPS: launches maps by intent
    ...    arguments: ${ivi}
    launch nav app maps
    is device booted

SET ADDRESS
    [Arguments]    ${target_id}    ${navigation_app}    ${address}
    [Documentation]    ENTER destination: add an address on navigation application
    ...    arguments: ${target_id} ${navigation_app} ${address}
    ${maps} =    Run Keyword And Return Status    Should Contain    ${navigation_app}    google
    Run Keyword If    '${maps}' == 'True'    SET MAPS DESTINATION    ${address}

CLEAR ADDRESS
    [Arguments]    ${ivi}    ${navigationapps}
    [Documentation]    REMOVE destination: remove an existing address on MAPS
    ...    arguments: ${ivi} ${navigationapps}
    ${navigationapps} =     Convert To String    ${navigationapps}
    ${maps} =    Run Keyword And Return Status    Should Contain    ${navigationapps}    google
    Run Keyword If    '${maps}' == 'True'    CLEAR MAPS

REMOVE ADDRESS
    [Arguments]    ${ivi}    ${navigationapps}
    [Documentation]    REMOVE destination: remove an existing address on MAPS
    ...    arguments: ${ivi} ${navigationapps}
    ${navigationapps} =     Convert To String    ${navigationapps}
    ${maps} =    Run Keyword And Return Status    Should Contain    ${navigationapps}    google
    Run Keyword If    '${maps}' == 'True'    REMOVE DESTINATION

CHECK ADDRESS
    [Arguments]    ${ivi}    ${navigationapps}
    [Documentation]    CHECK destination: check an existing address on MAPS
    ...    arguments: ${ivi} ${navigationapps}
    ${maps} =    Run Keyword And Return Status    Should Contain    ${navigationapps}    google
    Run Keyword If    '${maps}' == 'True'    CHECK MAPS DESTINATION

SET LAUNCH MONKEYS
    [Arguments]    ${target}    ${package}    ${time_event}    ${timeout_duration}    ${timelap_memory}    ${blacklist_file}
    [Documentation]    SET LAUNCH MONKEYS
    ...    arguments: ${target} ${package} ${time_event} ${timeout_duration} ${timelap_memory} ${blacklist_file}
    ...    launch monkey campaign
    ${value} =    thread_monkey    ${target}    ${package}    ${time_event}    ${timeout_duration}    ${timelap_memory}    ${blacklist_file}
    [return]    ${value}

CHECK PACKAGE
    [Arguments]    ${ivi}    ${apk_file}
    check_apk    ${apk_file}

GET EMMC SIZE USED
    [Arguments]    ${target_id}
    [Documentation]    GET EMMC SIZE USED on a ${target_id} (ivi or ivc)
    ${verdict}    ${value}    ${comment} =    Run Keyword If    '${target_id}' == 'ivc'    RETRIEVE EMMC SIZE
    ...    ELSE    analyze_emmc
    [Return]    ${value}

UI CHECK MASS STORAGE
    [Arguments]    ${state}    ${mass_storage_name}    ${folder}
    ${ui_check_state} =     UI CHECK STORAGE FOLDER    ${mass_storage_name}    ${folder}
    Log To Console   result ui: ${ui_check_state}
    Run Keyword If    '${state}' == 'missing' and '${ui_check_state}'=='False'   Log    Right return
    Run Keyword If    '${state}' == 'missing' and '${ui_check_state}'=='True'    Fail   Bad return
    Run Keyword If    '${state}' == 'present' and '${ui_check_state}'=='True'    Log    Right return
    Run Keyword If    '${state}' == 'present' and '${ui_check_state}'=='False'   Fail   Bad return

CHECK EXTERNAL DEVICE STATUS
    [Arguments]    ${ivi}    ${status}
    ${cmd_check_state} =     CMD CHECK STORAGE FOLDER
    ${output} =    Run Process    adb -s ${ivi_adb_id} shell df -h    shell=True
    log    ${output.stdout}
    Run Keyword If    '${cmd_check_state}' == 'False' and '${status}' == "plugged"   Fail   Bad return (expected unplugged)
    Run Keyword If    '${cmd_check_state}' == 'False' and '${status}' == "unplugged"   Log    PASS: mass storage unplugged
    Run Keyword If    '${cmd_check_state}' == 'True' and '${status}' == "unplugged"   Fail   Bad return (expected plugged)
    Run Keyword If    '${cmd_check_state}' == 'True' and '${status}' == "plugged"   Log    PASS: mass storage plugged

COMPUTE ITERATION VERDICT
    [Arguments]    ${list_intermediate_status}
    [Documentation]    Return number of intermediate failed steps
    ${count_fail} =    Count Values In List    ${list_intermediate_status}    FAIL
    [Return]    ${count_fail}

CALCULATE PASSRATE
    [Arguments]    ${kpi}=85    ${final_rate}=True
    [Documentation]    fail or pass condition given KPI
    # calculation of nb of element run
    ${nb_element} =    Get length    ${list_iterations_verdict_status}
    IF    "${nb_element}" == "0"
          ${passrate_message} =    Set variable     [RELIABILITY] All Loops BLOCKED ==> No PASS RATE
          Set Tags    ${passrate_message}
          Log To Console    ${passrate_message}
    ELSE
        Run Keyword If    ${nb_element} == 0   Set Tags    No loop executed as expected. No Passrate
        # calculation of PASS
        ${count_pass} =    Count Values In List    ${list_iterations_verdict_status}    PASS
        # calculation of FAIL
        ${int_element_fail} =    Evaluate    ${nb_element}-${count_pass}
        # calculation of passrate
        ${divide_total} =    Evaluate    (${count_pass}/${nb_element})*100
        ${int_divide_total} =    Convert To Integer    ${divide_total}
        ${remove_comma_total} =    Convert To Number    ${int_divide_total}    0
        ${final_passrate} =    Convert To Integer    ${remove_comma_total}
        IF    "${final_rate}" == "False"
            ${passrate_message} =    Set variable     [RELIABILITY] PASS RATE: ${final_passrate}% - Pass: ${count_pass}/${nb_element} - Fail: ${int_element_fail}/${nb_element}
            Log    ${passrate_message}    console=yes
        ELSE
            ${passrate_message} =    Set variable     [RELIABILITY] PASS RATE: ${final_passrate}% (expected: ${kpi}%) - Pass: ${count_pass}/${nb_element} - Fail: ${int_element_fail}/${nb_element}
            Run Keyword If    ${final_passrate} < ${kpi}    Fail    ${passrate_message}    ${passrate_message}
            ...   ELSE    Set Tags    ${passrate_message}
        END
    END

CALCULATE EXECUTION RATE
    [Documentation]    executed or not executed condition given KPI
    # calculation of nb of element run
    ${nb_element} =    Get length    ${list_iterations_no_verdict_status}
    # calculation of Execution
    ${count_executed} =    Count Values In List    ${list_iterations_no_verdict_status}    PASS
    # calculation of FAIL
    ${int_element_fail} =    Evaluate    ${nb_element}-${count_executed}
    # calculation of execution rate
    ${divide_total} =    Evaluate    (${count_executed}/${nb_element})*100
    ${int_divide_total} =    Convert To Integer    ${divide_total}
    ${remove_comma_total} =    Convert To Number    ${int_divide_total}    0
    ${final_passrate} =    Convert To Integer    ${remove_comma_total}
    ${execution_message} =    Set variable     [RELIABILITY] EXECUTION RATE: ${final_passrate}% - Run: ${count_executed}/${nb_element} - Blocked: ${int_element_fail}/${nb_element}
    Log    ${execution_message}    console=yes
    Run Keyword If    ${int_element_fail} == 0    Set Tags    ${execution_message}
    Run Keyword If    ${int_element_fail} > 0    Set Tags    ${execution_message}       nota : Blocked loop(s) are not taken into account in the Passrate

CALCULATE EMMC DELTA
    [Arguments]    ${adb_id}    ${apk_file}    ${value_percent}
    [Documentation]    fail or pass condition given KPI
    ${result_percent} =    APP PERCENT SIZE    ${adb_id}    ${apk_file}    ${value_percent}
    [Return]    ${result_percent}

APP PERCENT SIZE
    [Arguments]    ${adb_id}    ${apk_file}    ${value_percent}
    ${size} =    OperatingSystem.Run    adb -s ${adb_id} shell ls -l ${apk_file}
    @{size_list} =    Split String    ${size}
    ${size_apk} =    Evaluate    ${size_list}[4]
    ${get_percent} =    Evaluate    int(${size_apk}) * int(${value_percent}) / 100
    ${result_percent} =    Evaluate    (int(${get_percent}) / 1024) / 1024
    ${convert_to_float} =    Convert To Number    ${result_percent}    2
    [Return]    ${convert_to_float}

CHECK PERSISTENCE
    [Arguments]    ${target_id}    ${app}
    [Documentation]    Check the persistence of the ${app}
    Run Keyword If    '${app}' == 'maps'    CHECK MAPS DESTINATION
    ...    ELSE    Log    Unknown ${app}    WARN

STAT BOOTIME
    [Documentation]    provide min, max, average, median & square root of the boot time
    Return From Keyword If    "${ivi_can}" == "False"
    Log    Boot Result : ${list_boot_time}    WARN
    # length of the bootime list (depends of loops)
    ${nb_element} =    Get length    ${list_boot_time}
    # Fail if none hibernation boot happened
    Run Keyword if     "${nb_element}" == "0"    Fail    !! None boot read !!
    # Back up the list
    ${sorted_list}=  Copy List  ${list_boot_time}
    # Sort the list
    Sort List    ${sorted_list}
    # MIN CALCULATION
    Log    Min : ${sorted_list}[0] sec    WARN
    # MAX CALCULATION
    Log    Max : ${sorted_list}[-1] sec    WARN
    # AVERAGE CALCULATION
    ${average_element} =    Evaluate    ${nb_element}/2
    ${sum} =    Set Variable    ${list_boot_time}[0]
    FOR    ${var}    IN RANGE    1    ${nb_element}
        ${sum} =    Evaluate    ${sum}+${list_boot_time}[${var}]
    END
    ${average} =    Evaluate    ${sum}/${nb_element}
    ${average} =    ConVert To Number    ${average}    3
    Log    Average : ${average} sec      WARN
    # MEDIAN CALCULATION
    ${average_element} =   Convert To integer    ${average_element}
    Log    Median : ${sorted_list}[${average_element}] sec    WARN
    # SQUARE ROOT CALCULATION
    @{sqrt_list} =    create list
    FOR    ${var}    IN RANGE    0    ${nb_element}
        ${sqrt_value} =    Evaluate    ${list_boot_time}[${var}]-${average}
        Append to list    ${sqrt_list}    ${sqrt_value}
    END
    @{square_sqrt_list} =    create list
    FOR    ${var_square}    IN RANGE    0    ${nb_element}
        ${square_sqrt_value} =    Evaluate    ${sqrt_list}[${var_square}]*${sqrt_list}[${var_square}]
        Append to list    ${square_sqrt_list}    ${square_sqrt_value}
    END
    @{list_sum_ecart_type_square} =    create list
    ${sum_square} =    Set Variable    ${square_sqrt_list}[0]
    FOR    ${var_average_square}    IN RANGE    1    ${nb_element}
        ${sum_square} =    Evaluate    ${sum_square}+${square_sqrt_list}[${var_average_square}]
    END
    ${sum_square} =    Convert To Number    ${sum_square}    3
    ${sum_average_square_divide} =    Evaluate    ${sum_square}/(${nb_element})
    ${sqrt_calcul} =    SQRT CALCULATION    ${sum_average_square_divide}
    [return]    ${sqrt_calcul}
    ${sqrt_calcul} =    Convert To Number    ${sqrt_calcul}    3
    Log    Standard deviation : ${sqrt_calcul} sec      WARN

CHECK BOOT MODE
    [Arguments]    ${boot_expected}    ${target_id}
    [Documentation]    call check_boot_time function to return the last boot time (float)
    ${time_boot} =    check_boot_time    ${boot_expected}    ${target_id}
    [Return]    ${time_boot}

DO KILL PROCESS
    [Arguments]    ${target_id}    ${process}    ${sleep_after_pkill}=1
    [Documentation]    DO KILL PROCESS: Kill a process in the ${target_id}
    KILL PROCESS    ${process}    ${target_id}    ${sleep_after_pkill}

DO ADB DEVICES
    [Arguments]    ${target_id}
    ${stdout}    ${stderr} =    GET PROP    ro.serialno
    Should be empty    ${stderr}
    ${ret} =    Split String    ${stdout}    "'"
    ${device_id} =    Strip String   ${ret}[1]    characters="\\n'"
    # case of AOSP
    ${status} =    Evaluate    "EMULATOR" in """${device_id}"""
    IF  ${status}
        Set Variable    ${result}    "emulator-5554"
    ELSE
        Set Variable    ${result}    ${device_id}
    END
    [Return]    ${result}

CREATE ZIP ARCHIVE MONKEY LOGS
    [Arguments]    ${ivi_adb_id}
    [Documentation]    Zip monkeys logs as archive file
    ...    ${ivi_adb_id} the dedicated DUT
    ZIP MONKEY LOGS

STEP KW STATUS
    [Arguments]    ${KEYWORD}    ${ret_step_kw_status}    ${which_tab}    ${var}
    ${ret_step_kw_bool} =    Set variable if    "${ret_step_kw_status}" != "True"    FAIL    PASS
    Run Keyword if     "${ret_step_kw_bool}" != "PASS" and "${which_tab}" == "${status_list_no_verdict}"      Log     Loop ${var} blocked: '${KEYWORD}' has failed.    WARN
    Run Keyword if     "${ret_step_kw_bool}" != "PASS" and "${which_tab}" == "${status_list_verdict}"      Log     Loop ${var} Failed: '${KEYWORD}' has failed.    WARN
    Append to list    ${which_tab}    ${ret_step_kw_bool}

CHECK KEYWORD STATUS
    [Arguments]    ${kw_name}      ${expected_step_status}    ${step_status_tab}    ${var}    @{arg_kw}
    [Documentation]    Returns the state of a keyword to store it in a tab (usually used with COMPUTE ITERATION VERDICT).
    ...     ${kw_name}: name of the KW to run/check.
    ...     ${expected_step_status}: keyword step status (no_verdict/verdict)
    ...     ${step_status_tab}: name of the list to append (status_list_verdict/status_list_no_verdict)
    ...     ${var}: actual loop
    ...     @{arg_kw}: keywords's kwargs
    ${ret_step_kw_status} =    Run Keyword And Return Status    ${kw_name}    @{arg_kw}
    ${ret_step_kw_bool} =    Set variable if    "${ret_step_kw_status}" != "True"    FAIL    PASS
    Run Keyword if     "${ret_step_kw_bool}" != "PASS" and "${expected_step_status}" == "no_verdict"    Run Keyword     Log     Loop ${var} blocked: '${kw_name}' has failed.    WARN
    Run Keyword if     "${ret_step_kw_bool}" != "PASS" and "${expected_step_status}" == "verdict"    Run Keyword     Log     Loop ${var} Failed: '${kw_name}' has failed.    WARN
    Run Keyword And Continue On Failure    Append to list    ${step_status_tab}    ${ret_step_kw_bool}

CHECK KEYWORD STATUS AND RETURN VALUES
    [Arguments]    ${kw_name}      ${expected_step_status}    ${step_status_tab}    ${var}    @{arg_kw}
    [Documentation]    Returns the status and values of a keyword to store it in a tab (usually used with COMPUTE ITERATION VERDICT).
    ...     ${kw_name}: name of the KW to run/check.
    ...     ${expected_step_status}: keyword step status (no_verdict/verdict)
    ...     ${step_status_tab}: name of the list to append (status_list_verdict/status_list_no_verdict)
    ...     ${var}: actual loop
    ...     @{arg_kw}: keywords's kwargs
    ${ret_step_kw_bool}     ${return_values} =    Run Keyword And Ignore Error    ${kw_name}    @{arg_kw}
    Run Keyword if     "${ret_step_kw_bool}" != "PASS" and "${expected_step_status}" == "no_verdict"    Run Keyword     Log     Loop ${var} blocked: '${kw_name}' has failed.    WARN
    Run Keyword if     "${ret_step_kw_bool}" != "PASS" and "${expected_step_status}" == "verdict"    Run Keyword     Log     Loop ${var} Failed: '${kw_name}' has failed.    WARN
    Run Keyword And Continue On Failure    Append to list    ${step_status_tab}    ${ret_step_kw_bool}
    [Return]    ${return_values}

GET STORAGE NAME
    [Arguments]    ${ivi_adb_id}
    [Documentation]    Retrieve the storage name from a dedicated DUT
    ...    ${ivi_adb_id} the dedicated DUT
    ${my_storage_name} =    RETURN STORAGE NAME
    [return]    ${my_storage_name}

CHECK BOOT REASON
    [Arguments]    ${boot_expected}    ${ivi_adb_id}
    [Documentation]    check the type of boot (normal or quick)
    retrieve boot reason    ${boot_expected}    ${ivi_adb_id}

CHECK UI DUMPSYS
    [Arguments]    ${ivi_adb_id}    ${app_name}
    Run Keyword And Warn On Failure    LAUNCH APP APPIUM    ${app_name}
    Sleep    2
    ${status}    ${package_and_activity} =    Run Keyword And Warn On Failure    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}
    ${ui_package} =    Set Variable    ${package_and_activity}[0]
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys window | grep mFocusedWindow
    log    ${output}
    ${ret_ui_checked}=  Evaluate   "${ui_package}" in """${output}"""
    # split the string to get the package displayed and return it
    @{split1} =    Split String    ${output}    ${space}
    @{split2} =    Split String    ${split1}[-1]    /
    [return]    ${ret_ui_checked}    ${split2}[0]

PREPARE GARAGE MODE
    [Documentation]    This method configures LOGCAT triggers for validating Garage Mode logic.
    ...    This method assumes the LOGCAT is started, either by starting LOGCAT MONITOR, or by loading LOGCAT FILE

    ${ivi_myF3} =    Set Variable If    '${ivi_my_feature_id}' == 'MyF3'    True    False
    ${entering_garage_mode} =    Set Variable If    ${ivi_myF3}    ${entering_garage_mode_myf3}    ${entering_garage_mode_myf2}

    Run Keyword And Warn On Failure    SET LOGCAT TRIGGER    message=${entering_garage_mode}
    Run Keyword And Warn On Failure    SET LOGCAT TRIGGER    message=${check_garage_mode_budget_accumulation}
    Run Keyword And Warn On Failure    SET LOGCAT TRIGGER    message=${shutdown_without_garage_mode}

CHECK GARAGE MODE
    [Arguments]    ${loop}
    [Documentation]    This method validates the Garage Mode logic, also taking into account the Garage time accumulation.
    ...    This method assumes the LOGCAT is started, either by starting LOGCAT MONITOR, or by loading LOGCAT FILE

    ${ivi_myF3} =    Set Variable If    '${ivi_my_feature_id}' == 'MyF3'    True    False
    ${entering_garage_mode} =    Set Variable If    ${ivi_myF3}    ${entering_garage_mode_myf3}    ${entering_garage_mode_myf2}

    ${status}    ${comment} =    Run Keyword And Ignore Error    WAIT FOR LOGCAT TRIGGER    message=${entering_garage_mode}    timeout=${60}
    IF    "${status}" == "PASS"
        ${status}    ${comment} =    Run Keyword And Ignore Error    WAIT FOR LOGCAT TRIGGER    message=${shutdown_without_garage_mode}    timeout=${60}
        IF    "${status}" == "PASS"
            Log To Console    Starting shutdown without Garage Mode in loop_${loop}.
        ELSE
            ${status}    ${comment} =    Run Keyword And Ignore Error    WAIT FOR LOGCAT TRIGGER    message=${check_garage_mode_budget_accumulation}    timeout=${60}
            IF    "${status}" == "PASS"
                Log To Console    Garage budget is accumulating. Starting shutdown with Garage Mode in loop_${loop}.
            ELSE
                Log    Failed to validate Garage budget in loop_${loop}.    WARN
            END
        END
    ELSE
        Log    Garage Mode did not happen in loop_${loop}.    WARN
    END

START DEVICE IN CAN MODE OR WITH ADB REBOOT
    [Arguments]    ${target_id}    ${can_activation}
    [Documentation]    This KW is used essentialy in Reliability testcase; it allows to start the device in
    ...    CAN mode (power supply on + sending a CAN frame :(device must be offline) or by an adb reboot (if device already ON).
    ...    ${can_activation} variable must be present in the testcase.
    Run Keyword if    "${can_activation}" == "yes"    Run keywords    CAN ACTIVATION & START DEVICE
    ...     ELSE    SET REBOOT    ${ivi}    command line    1
    CHECK STATE EXPECTED    online    ${timeout_adb}    ${ivi_adb_id}
    Sleep     60

START DEVICE IN CAN MODE OR WITH ADB REBOOT AND WITH ARGUMENTS
    [Arguments]    ${can_activation}    ${EE_architecture}
    [Documentation]    This KW is used essentialy in Reliability testcase; it allows to start the device in
    ...    CAN mode (power supply on + sending a CAN frame :(device must be offline) or by an adb reboot (if device already ON).
    ...    ${can_activation} variable must be present in the testcase.
    Run Keyword if    "${can_activation}" == "yes"    CAN ACTIVATION & START DEVICE WITH ARGUMENTS    ${EE_architecture}
    ...     ELSE    SET REBOOT    ${ivi_adb_id}    command line    1
    CHECK STATE EXPECTED    online    180    ${ivi_adb_id}
    Sleep     60

TRIGGER DTC CONDITION
    [Documentation]    Activate relay on relaycard to connect 2 wires, simulating a short circuit
    ...    on A-IVI2, generating a DTC
    Log To Console    Triggering DTC condition

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=USB-RLY08    relay=5
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}     ${comment}

UNTRIGGER_DTC_CONDITION
    [Documentation]    Desactivate relay on relaycard to disconnect 2 wires, removing a
    ...    short circuit on A-IVI2, removing DTC
    Log To Console    Untriggering DTC condition

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=USB-RLY08    relay=5
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}     ${comment}

GET CURRENT WEEK
    [Documentation]  Retrieve the id of the current week
    ${week_number} =    DateTime.Get Current Date    result_format=%W
    [return]    ${week_number}

PREPARE LOG FOR IVC
    [Documentation]   Send a sql request to get the DLT logs in the emmc
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationproperty    activationState    1    propertyName    IVC_Internal_Log_Enabling
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationproperty    activationState    1    propertyName    LogConfiguration
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}
    ${verdict}    ${output} =    SET OF STATE MANAGER    configurationproperty    activationState    1    propertyName    Privacy_Mode_Activation
    Should Be True    ${verdict}    Failed SET OF STATE MANAGER: ${output}
    Should Not Contain    ${output}    ${error_string}

DO LAUNCH AUDIO FILE WITH INTENT
    [Arguments]    ${dut_id}    ${file_name}
    [Documentation]    Launch the given audio {file_name} on native music player
    ...    DO LAUNCH AUDIO FILE ivi AudioVoice.mp3
    LAUNCH AUDIO APK    ${file_name}
    ${output} =    PS PACKAGE    -s com.alliance.media.localplayer
    Run Keyword If    "${output.stdout}" == "b''"    Fail    No music player is running

CALCULATE NUMBER OF ITERATIONS
    [Arguments]    ${iterations_time}
    [Documentation]   Calculates the number of iterations to be run.
    ${status} =    Run Keyword And Return Status    CALCULATE ITERATIONS    ${iterations_time}
    [Return]    ${status}

EXTRACT_TEMPERATURE
    [Documentation]    Extract temperature from the bit value
    [Arguments]    ${start_session_comment}    ${expected_temperature_bit_value}
    ${payload} =    Get Substring    ${start_session_comment}    18    19
    ${payload_binary} =    Convert To Binary    ${payload}    base=16    length=4
    ${temperature_bit} =    Get Substring    ${payload_binary}    2    3
    ${value_verdict} =    Set variable if    "${temperature_bit}" != "${expected_temperature_bit_value}"    FAIL    PASS
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Temperature bit : ${temperature_bit}
    [Return]    ${value_verdict}    ${temperature_bit}

DOIP ECU POWER OFF ON
    [Arguments]    ${platform_type}    ${can_activation}    ${EE_architecture}    ${timeout}=${uds_timeout}    ${tp_management}=False
    [Documentation]    Resets the configurations of the device power off on.
    Run Keyword And Ignore Error    CLOSE SSH SESSION
    IF    "${tp_management}" == "True"
        ${ecu_canakin_name}    ${ecu_eth_name} =    GET ECU DOIP INFO    ${platform_type}
        ${verdict}    ${comment} =    Canakin Stop Tester Present    ${ecu_canakin_name}
        Should be true    ${verdict}    ${comment}
        Sleep    5s
        ${verdict}    ${comment} =    Canakin Close UDS Connection    ${ecu_eth_name}
        Should be true    ${verdict}    ${comment}
        Sleep    120s
    END

    DO POWER OFF BATTERY
    IF    "${sleep_time}"=="True"
        ${random_sleeping} =    Evaluate    random.randint(${sleep_min_time}, ${sleep_max_time})
        Log    Loop: Random off time is: ${random_sleeping}sec.    WARN
        Sleep    ${random_sleeping}
    END
    DO WAIT    2000
    CHECK STATE EXPECTED    offline    60    ${ivi_adb_id}
    DO POWER ON BATTERY
    SEND CAN FRAME    ${startup_sequence}
    CHECK STATE EXPECTED    online    180    ${ivi_adb_id}
    Sleep    120s
    IF    "${tp_management}" == "True"
        ${verdict}    ${comment} =    Canakin Change Diagnostic Session   ${ecu_canakin_name}   3    itf=${ecu_eth_name}    timeout=${timeout}
        Should be true    ${verdict}    ${comment}
        ${verdict}    ${comment} =    Canakin Start Tester Present    ${ecu_canakin_name}    ${tester_present_interval}    itf=${ecu_eth_name}
        Should be true    ${verdict}    ${comment}
    END

SAVE ITERATION CANDUMP FILE CONTENTS
    [Arguments]    ${loop_folder}    ${can_setup}=ivc+ivi
    ${candump_file_name} =    Run keyword if   "${can_setup}" == "ivc" or "${can_setup}" == "ivc+ivi"    GET CANDUMP FILE NAME    slcan0
    Run keyword if   "${can_setup}" == "ivc" or "${can_setup}" == "ivc+ivi"      Run Keywords    Copy Files    ${candump_file_name}.txt    ${loop_folder}
    ...    AND    CLEAR CANDUMP FILE CONTENTS    slcan0
    ${candump_file_name} =    Run keyword if   "${can_setup}" == "ivi" or "${can_setup}" == "ivc+ivi"    GET CANDUMP FILE NAME    slcan1
    Run keyword if   "${can_setup}" == "ivi" or "${can_setup}" == "ivc+ivi"      Run Keywords    Copy Files    ${candump_file_name}.txt    ${loop_folder}
    ...    AND    CLEAR CANDUMP FILE CONTENTS    slcan1

ZIP DLT
    [Documentation]    It creates an archive for generated logs
    [Arguments]    ${current_tc_name}
    ${code_value}=    Run Keyword And Return Status    OperatingSystem.Run And Return Rc And Output    zip -r /rhw/debug_logs/${current_tc_name}.zip /rhw/debug_logs/${current_tc_name}
    Run keyword if   "${code_value}" == "True"    SET DELETE FOLDER ON BENCH    /rhw/debug_logs/${current_tc_name}

REMOVE AUDIO FILE FROM PASSED LOOPS
    [Arguments]    ${loops_where_audio_failed}    ${audio_source}    ${tc_loops}
    ${loop_for} =    Evaluate    ${tc_loops} + 1
    FOR    ${var}    IN RANGE    1    ${loop_for}
        ${passed_loop} =    Run Keyword And Return Status    List Should Not Contain Value    ${loops_where_audio_failed}    ${var}
        Run Keyword If    "${passed_loop}" == "True"    OperatingSystem.Run    rm -rf /rhw/debug_logs/${current_tc_name}/loop_${var}/${audio_source}/audio_*
    END

SAVE AUDIO FILE FROM FAILED LOOPS
    [Arguments]    ${status_list_verdict}    ${var}    ${loop_folder}    ${audio_source}
    ${verdict_last_keyword} =    Get From List    ${status_list_verdict}    -1
    IF    "${audio_source}" == "audio_usb"
        IF    "${verdict_last_keyword}" == "FAIL"
            ${previous_loop} =    Evaluate    ${var} - 1
            ${next_loop} =    Evaluate    ${var} + 1
            Append To List    ${loops_where_usb_audio_failed}    ${previous_loop}
            Append To List    ${loops_where_usb_audio_failed}    ${var}
            Append To List    ${loops_where_usb_audio_failed}    ${next_loop}
        END
        ${loops_where_usb_audio_failed} =    Remove Duplicates    ${loops_where_usb_audio_failed}
        Set Test Variable    ${loops_where_usb_audio_failed}
        ${loop_folder_usb} =    Set variable    ${loop_folder}/${audio_source}
        Create Directory    ${loop_folder_usb}
        OperatingSystem.Run    mv audio_* ${loop_folder_usb}
    ELSE IF    "${audio_source}" == "audio_bluetooth"
        IF    "${verdict_last_keyword}" == "FAIL"
            ${previous_loop} =    Evaluate    ${var} - 1
            ${next_loop} =    Evaluate    ${var} + 1
            Append To List    ${loops_where_BT_audio_failed}    ${previous_loop}
            Append To List    ${loops_where_BT_audio_failed}    ${var}
            Append To List    ${loops_where_BT_audio_failed}    ${next_loop}
        END
        ${loops_where_BT_audio_failed} =    Remove Duplicates    ${loops_where_BT_audio_failed}
        Set Test Variable    ${loops_where_BT_audio_failed}
        ${loop_folder_BT} =    Set variable    ${loop_folder}/${audio_source}
        Create Directory    ${loop_folder_BT}
        OperatingSystem.Run    mv audio_* ${loop_folder_BT}
    ELSE IF    "${audio_source}" == "audio_radio"
        IF    "${verdict_last_keyword}" == "FAIL"
            ${previous_loop} =    Evaluate    ${var} - 1
            ${next_loop} =    Evaluate    ${var} + 1
            Append To List    ${loops_where_radio_audio_failed}    ${previous_loop}
            Append To List    ${loops_where_radio_audio_failed}    ${var}
            Append To List    ${loops_where_radio_audio_failed}    ${next_loop}
        END
        ${loops_where_radio_audio_failed} =    Remove Duplicates    ${loops_where_radio_audio_failed}
        Set Test Variable    ${loops_where_radio_audio_failed}
        ${loop_folder_BT} =    Set variable    ${loop_folder}/${audio_source}
        Create Directory    ${loop_folder_BT}
        OperatingSystem.Run    mv audio_* ${loop_folder_BT}
    ELSE IF    "${audio_source}" == "audio_random"
        IF    "${verdict_last_keyword}" == "FAIL"
            ${previous_loop} =    Evaluate    ${var} - 1
            ${next_loop} =    Evaluate    ${var} + 1
            Append To List    ${loops_where_random_audio_failed}    ${previous_loop}
            Append To List    ${loops_where_random_audio_failed}    ${var}
            Append To List    ${loops_where_random_audio_failed}    ${next_loop}
        END
        ${loops_where_random_audio_failed} =    Remove Duplicates    ${loops_where_random_audio_failed}
        Set Test Variable    ${loops_where_random_audio_failed}
        ${loop_folder_BT} =    Set variable    ${loop_folder}/${audio_source}
        Create Directory    ${loop_folder_BT}
        OperatingSystem.Run    mv audio_* ${loop_folder_BT}
    END

SWITCH RANDOMLY TO ANOTHER USER PROFILE
    [Documentation]    switch randomly to another user profile which are created
    [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    ${current_user_name}    ${current_user_id} =    ADB_AM_GET_CURRENT_USER_NAME
    ${loop_for} =    Evaluate    999
    FOR    ${var}    IN RANGE    1    ${loop_for}
        ${random_choice} =    Evaluate  random.choice(${list_of_profiles})
        IF    "${random_choice}" != "${current_user_name}"
            ENABLE MULTI WINDOWS
            SELECT USER PROFILE    ${random_choice}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        END
        Exit For Loop If    "${current_user_name}" != "${random_choice}"
    END

CREATE MORE USER PROFILES
    [Documentation]
    [Arguments]    ${admin_profile}=Driver    ${number_of_profiles}=2    ${platform_version}=10
    ${loop_for} =    Evaluate    ${number_of_profiles} + 1
    @{list_of_profiles}=    Create List
    Append To List    ${list_of_profiles}    ${admin_profile}
    FOR    ${var}    IN RANGE    1    ${loop_for}
        CREATE APPIUM DRIVER
        ADD NEW USER PROFILE    ${platform_version}
        Sleep    15
        REMOVE APPIUM DRIVER
        CREATE APPIUM DRIVER
        ENABLE MULTI WINDOWS
        APPIUM LAUNCH USER MANAGEMENT
        EDIT PROFILE NAME    Profile_${var}
        REMOVE APPIUM DRIVER
        Append To List    ${list_of_profiles}    Profile_${var}
    END
    Set Test Variable    ${list_of_profiles}
    CREATE APPIUM DRIVER
    ENABLE MULTI WINDOWS
    SELECT USER PROFILE    ${admin_profile}
    Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    OperatingSystem.Run    adb -s ${ivi_adb_id} shell input tap 109 1485
    Sleep    15

REMOVE CREATED USER PROFILES
    [Documentation]
    [Arguments]    ${admin_profile}=Driver    ${number_of_profiles}=2
    ${loop_for} =    Evaluate    ${number_of_profiles} + 1
    CREATE APPIUM DRIVER
    ENABLE MULTI WINDOWS
    SELECT USER PROFILE    ${admin_profile}
    CREATE APPIUM DRIVER
    FOR    ${var}    IN RANGE    1    ${loop_for}
        REMOVE USER PROFILE    Profile_${var}
        Sleep    10
    END
    REMOVE APPIUM DRIVER

SET FULL TEST
    [Arguments]    ${dut_id}    ${gas_login}   ${gas_pswd}    ${ivi}
    [Documentation]    set BT and GPS on, and add a google account
    SET ROOT
    CHECKSET BT STATUS APPIUM    ${dut_id}    on
    CHECKSET GPS   ${ivi}    on
    Run Keyword And Ignore Error    SET ADD GOOGLE ACCOUNT    ${ivi}    ${gas_login}    ${gas_pswd}

SEND VEHICLE VOLUME BY SWRC
    [Arguments]    ${volume_status}
    [Documentation]    Increase / decrease the volume with Steering Wheel Remote Command
    ...    ${volume_status}   up / down
    Log To Console    SEND VEHICLE VOLUME on IVI using SWRC : ${volume_status}
    ${button} =    Set Variable If    "${volume_status}" == "up"    6    7

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.CONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}    ${comment}

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH ON    card_id=USB-RLY08    relay=${button}
    Should Be True    ${verdict}    ${comment}
    Sleep    0.5

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.SWITCH OFF    card_id=USB-RLY08    relay=${button}
    Should Be True    ${verdict}    ${comment}
    Sleep    1

    ${verdict}    ${comment} =    rfw_libraries.tools.RelayCardManager.DISCONNECT    card_id=USB-RLY08
    Should Be True    ${verdict}     ${comment}


EXTRACT ANDROID BUG REPORTS
    [Arguments]    ${ivi_adb_id}
    [Documentation]    Generate and extract IVI Android bug reports
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell rm /bugreports/*
    Sleep    1
    ${status} =    Run Keyword And Return Status    OperatingSystem.Run    adb -s ${ivi_adb_id} bugreport
    Run Keyword If    "${status}" == "True"    Log To Console    Bug report generation status: ${status}
    ${bug_report_folder_content} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell ls -al -ah /bugreports/
    Log To Console    ${bug_report_folder_content}

    ${result} =    IS DEVICE BOOTED    on    ${ivi_adb_id}
    Run Keyword If    "${result}" == "True"    PULL     /bugreports/     ${logs_top_folder}
    Sleep    1

RESET ANDROID BUG REPORTS
    [Arguments]    ${ivi_adb_id}    ${android_logcat_path}=/data/misc/logd/
    [Documentation]    Generate and extract IVI Android bug reports
    ${return2} =    OperatingSystem.Run    adb -s ${ivi_adb_id} logcat -b all -c
    Run Keyword If    "${return2}" == "True"    Log To Console    logcat buffers reset have been made...

TAP ON THE MAIN APPS
     [Arguments]    ${ivi_adb_id}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
     [Documentation]    Tap on the all main apps
     ${extracted_list} =    Catenate    SEPARATOR=   top_menu_order_apps_ivi_android_    ${platform_version}
     @{apps_name} =    Set Variable    ${${extracted_list}}
     FOR    ${app}    IN    @{apps_name}
         ${coordinates} =    GET COORDINATES NAME FROM APP    ${app}
         ${tap_location} =    Create Dictionary    x=${coordinates}[0]    y=${coordinates}[1]
         Run Keyword And Continue On Failure    APPIUM_TAP_LOCATION    ${tap_location}
         Sleep    3
         ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app}
         ${ui_package} =    Set Variable    ${app_package}/${app_activity}
         ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys window | grep mFocusedWindow
         log    ${output}
         ${ret_ui_checked}=  Evaluate   "${ui_package}" in """${output}"""
         Run Keyword If    "${ret_ui_checked}" != "True"     SAVE SCREENSHOT APPIUM     ${path_to_save}     ${screenshot_name}
         # split the string to get the package displayed and return it
         @{split1} =    Split String    ${output}    ${space}
         @{split2} =    Split String    ${split1}[-1]    /
     END
     [Return]    ${ret_ui_checked}    ${split2}[0]

CHECK AND LAUNCH MEDIA PLAYER ON SMARTPHONE
      [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
      [Documentation]    Check if MusicPlayer is launched and play the audio file on the list.
      ...    The player can be found on Play Store searching for "Simple Music Player" (additional seeking info: the headset icon)
      ...    Artifactory link to sample audio files: https://artifactory.dt.renault.com:443/artifactory/matrix/artifacts/reliability/AudioVoice.mp3
      ...    https://artifactory.dt.renault.com:443/artifactory/matrix/artifacts/reliability/Over_the_Horizon.mp3
      ...    https://artifactory.dt.renault.com:443/artifactory/matrix/artifacts/reliability/test_file.mp3
      LAUNCH APP APPIUM      MusicPlayer    smartphone     platform_version=${smartphone_platform_version}
      Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
      Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Tracks']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
      TAP_ON_ELEMENT_USING_XPATH    //*[@text='01/08/2018' or @text='test_file' or @text='Over the Horizon']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
      Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
      Sleep    2
      APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
      Sleep    2
      APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
      Sleep    2
      APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

SQRT CALCULATION
    [Arguments]    ${value}
    ${result} =     Evaluate    int($value)**.5
    [Return]    ${result}

CHECK VNEXT SERVICE ACTIVATION STATUS WITH RETRY
      [Arguments]    ${service_to_test}    ${checked_status}     ${loop}     ${number_of_retries}=9
      [Documentation]    Check if a given  service is activated or deactivated, and try by pressing Check for Update button.
      ${status_to_check}=    Set Variable If    "${checked_status}" == "Deactivated"    DeactivationInProgress    ActivationInProgress
      Run Keyword And Ignore Error    RETRY MECHANISM FOR READING SA STATUS    ${service_to_test}    ${checked_status}
      FOR    ${var}    IN RANGE    1    ${number_of_retries}
          Exit For Loop If    "${current_status}" != "${status_to_check}"
          Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${current_status} - Press Check for update ${var}
          CREATE APPIUM DRIVER
          Sleep    5
          CHECK FOR UPDATE    ${checked_status}
          Sleep    60s
          REMOVE APPIUM DRIVER
          Log    Verdict for iteration ${loop} is: FAIL , because service status change was forced.    WARN
          Run Keyword And Ignore Error    CHECK VNEXT SERVICE ACTIVATION STATUS   ${service_to_test}     ${checked_status}
      END
      ${verdict} =    Set variable if    "${current_status}" != "DeactivationInProgress" or "${current_status}" != "ActivationInProgress"    PASS    FAIL

START RELIABILITY LOOP
    [Arguments]        ${status_list_verdict}    ${status_list_no_verdict}    ${var}    ${loops}=?
    [Documentation]    Steps which are performing in all reliability TC's at the beginning of the loop
    ${start_time} =   Get Time
    Log    ------- [RELIABILITY] Loop ${var}/${loops} started --------    console=${console_logs}
    @{status_list_verdict} =    create list
    @{status_list_no_verdict} =    create list
    Set Global Variable     ${setup_fail}    False
    Set Global Variable   ${status_list_verdict}
    Set Global Variable   ${status_list_no_verdict}
    Set Global Variable   ${var}
    Set Global Variable   ${start_time}
    ${loop_folder} =    Set variable    /rhw/debug_logs/${current_tc_name}/loop_${var}
    Create Directory    ${loop_folder}
    Set Global Variable   ${loop_folder}

END RELIABILITY LOOP
    [Arguments]    ${status_list_verdict}    ${status_list_no_verdict}    ${var}    ${start_time}    ${loops}=?
    [Documentation]    Steps which are performing in all reliability TC's at the end of the loop
    ${end_time} =    Get Time
    ${iteration_time} =    DateTime.Subtract Date From Date    ${end_time}    ${start_time}    result_format=timedelta
    # EXECUTION RATE: NO VERDICT STEPS CALCULATION
    ${iteration_no_verdict}=    Run Keyword    COMPUTE ITERATION VERDICT    ${status_list_no_verdict}
    ${iteration_no_verdict_status}=    Set Variable If    ${iteration_no_verdict} > 0    BLOCKED    PASS
    Run Keyword if    "${iteration_no_verdict_status}" == "BLOCKED"    Log     \nITERATION NUMBER:${var} HAS THE VERDICT:${iteration_no_verdict_status} ITERATION_TIME: ${iteration_time}    console=yes
    Run Keyword if    "${iteration_no_verdict_status}" == "BLOCKED"    Log     [RELIABILITY]: Loop ${var} - Status ${iteration_no_verdict_status}    console=yes
    Append To List    ${list_iterations_no_verdict_status}    ${iteration_no_verdict_status}
    # PASS RATE: VERDICT STEPS CALCULATION
    ${iteration_verdict}=    Run Keyword    COMPUTE ITERATION VERDICT    ${status_list_verdict}
    ${iteration_verdict_status}=    Set Variable If    ${iteration_verdict} > 0    FAIL    PASS
    Run Keyword if     "${iteration_no_verdict_status}" != "BLOCKED"    Log     \nITERATION NUMBER:${var} HAS THE VERDICT:${iteration_verdict_status} ITERATION_TIME: ${iteration_time}    console=yes
    Run Keyword if     "${iteration_no_verdict_status}" != "BLOCKED"    Log     [RELIABILITY]: Loop ${var} - Status ${iteration_verdict_status}    console=yes
    Run Keyword if     "${iteration_no_verdict_status}" != "BLOCKED"    append to list    ${list_iterations_verdict_status}    ${iteration_verdict_status}
    Run Keyword If     "${iteration_no_verdict_status}" == "PASS"    Append To List    ${iterations_time}    ${iteration_time}
    CALCULATE PASSRATE    final_rate=False
    Log    ------- [RELIABILITY] Loop ${var}/${loops} ended --------    console=${console_logs}

CALCULATE RELIABILITY PASSRATE
    [Arguments]    ${kpi_value}
    [Documentation]    Steps to calculate the execution and passrate for an execution campaign
    CALCULATE NUMBER OF ITERATIONS    ${iterations_time}
    CALCULATE EXECUTION RATE
    CALCULATE PASSRATE    ${kpi_value}

SET MAPS DESTINATION
    [Arguments]    ${address}
    # To be implemented : CCAR-63785
    Fail    SET MAPS DESTINATION should implemented using Appium LLKs

FORGET DEVICE AND BLUETOOTH CONNECT
    [Arguments]    ${spcx_popup}=no
    [Documentation]    Do forget bluetooth device and after connect to the phone
    Run Keyword and Ignore Error    GO BT MENU APPIUM    ${ivi_adb_id}
    ${phone_name} =    GET PHONE NAME    ${smartphone_adb_id}
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${phone_name}']    10
    ${phone_is_paired} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']   10
    ${pair_status} =    Set Variable if    "${phone_is_paired}" != "True"    FAIL    PASS
    CREATE APPIUM DRIVER    DeviceManager    smartphone    ${smartphone_adb_id}    ${smartphone_platform_version}
    Return From Keyword If     "${pair_status}" == "PASS" and "${result}" == "True"
    Run Keyword If    "${spcx_popup}"=="yes"    DISABLE ANDROID AUTO ON SMARTPHONE
    DO BLUETOOTH FORGET ON SMARTPHONE APPIUM    ${smartphone_adb_id}
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    Run Keyword And Continue On Failure    RECONFIRM DATA PRIVACY
    IF    "${ivi_my_feature_id}" == "MyF3"
        LAUNCH APP APPIUM    DeviceManager
        TURN BLUETOOTH ON DEVICE
    END
    Run Keyword And Ignore Error    BLUETOOTH FORGET DEVICE
    Sleep    5s
    LAUNCH APP APPIUM    DeviceManager
    TURN BLUETOOTH ON DEVICE
    TURN BLUETOOTH ON DEVICE    device_name=phone
    REMOVE APPIUM DRIVER
    Run Keyword And Ignore Error    REMOVE APPIUM DRIVER    ${smartphone_capabilities}
    Sleep    2s
    Wait Until Keyword Succeeds    5x    1m     PAIR IVI AND PHONE    ${smartphone_adb_id}    True
    CREATE APPIUM DRIVER    DeviceManager    smartphone    ${smartphone_adb_id}    ${smartphone_platform_version}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

SET SPCX DOWNLOAD URL
    [Documentation]   get the size of the screen and set the download url for SPCX TC
    ${screen_resolution}=    GET PHYSICAL SCREEN SIZE   ${ivi_adb_id}
    ${small_screen} =    Set Variable    1250x834
    ${big_screen} =    Set Variable    1250x1562
    ${screen_size} =    Set Variable If    "${screen_resolution}" == "${big_screen}"    12_inch    9_inch
    IF    "${screen_size}" == "9_inch"
        ${download_url} =    Set Variable    matrix/artifacts/reliability/spcx_9inch/
    ELSE IF    "${screen_size}" == "12_inch" and "${ivi_my_feature_id}" == "MyF1"
         ${download_url} =    Set Variable    matrix/artifacts/reliability/spcx_12inch_myf1/
    ELSE
        ${download_url} =    Set Variable    matrix/artifacts/reliability/spcx_12inch_myf2/
    END
    Set Global Variable    ${download_url}
    Set Global Variable    ${screen_resolution}

CHECK AND RETRIEVE BOOT MODE
    [Arguments]    ${boot_expected}
    [Documentation]   check boot mode and retrieve boot info
    ${bootmode_loop_list} =    Run Keyword And Ignore Error    CHECK BOOT MODE    ${boot_expected}    ${ivi_adb_id}
    ${bootmode_status} =    Get From List    ${bootmode_loop_list}    ${0}
    Append to list    ${status_list_verdict}    ${bootmode_status}
    ${bootduration_loop} =    Get From List    ${bootmode_loop_list}    ${1}
    Run Keyword if    "${bootmode_status}" != "PASS"    Log    Loop ${var} failed : 'ANDROID BOOT (${bootduration_loop})' has failed.    WARN
    ${bootduration_loop} =    Set Variable if    'ValueError' in str($bootduration_loop)   0.0    ${bootduration_loop}
    # Warning in case of boot too long
    Run Keyword if    "${bootmode_status}" == "PASS" and ${bootduration_loop} > ${threshold} and "${boot_expected}" == "ecs"    Log    Loop ${var} PASS with warning: 'ANDROID BOOT (current boot ${bootduration_loop}sec > ${threshold}sec)' is too long.    WARN
    ${is float}=      Evaluate     isinstance($bootduration_loop, float)
    ${time_boot_float} =    Run Keyword if    "${is float}" == "True"    Convert To Number    ${bootduration_loop}
    Run Keyword if    "${is float}" == "True" and "${bootduration_loop}" > "0"    Append to list    ${list_boot_time}    ${time_boot_float}
    Run Keyword if    "${is float}" == "True" and "${bootduration_loop}" > "0"    Log    List: @{list_boot_time}

ENABLE TO SET THE DESTINATION
    [Documentation]    Enable the location from home find image on screen
    GO HOME SCREEN APPIUM
    ENABLE MULTI WINDOWS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Review privacy settings']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Review privacy settings']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Go to Settings']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Go to Settings']
    Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    LAUNCH APP APPIUM    Navigation
    Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM    Maps
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Go to Settings']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Go to Settings']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Review privacy settings']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Review privacy settings']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Turn on']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Turn on']
    Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    LAUNCH APP APPIUM    Navigation
    Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM    Maps
    Sleep   3s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Review privacy settings']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Review privacy settings']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Done']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Done']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Close']    retries=10
    Run Keyword If     "${result}"=="True"    TAP ON IVI TEXT    //*[@text='Close']

TAP ON IVI TEXT
    [Arguments]    ${ivi_text}
    [Documentation]    Find on the IVI screen the specific text
    ${location} =   APPIUM_GET_XPATH_LOCATION    ${ivi_text}
    APPIUM_TAP_LOCATION    ${location}

REMOVE SCREENSHOTS FROM PASSED LOOPS
    [Documentation]    Remove the screenshots from passed loops
    ${passed_verdict_loop} =    Run Keyword And Return Status    List Should Not Contain Value    ${status_list_verdict}    FAIL
    ${passed_no_verdict_loop} =    Run Keyword And Return Status    List Should Not Contain Value    ${status_list_no_verdict}    FAIL
    Run Keyword If    "${passed_verdict_loop}" == "True" and "${passed_no_verdict_loop}" == "True"    OperatingSystem.Run    rm -rf debug_logs/${current_tc_name}/loop_${var}/*.png

CHECK AND CHANGE THE VOLUME
    [Arguments]    ${volume_status}    ${sound_channel}    ${status}    ${new_volume}=40    ${relaycard_present}=False
    [Documentation]    Increase / decrease the volume and check the sound if is present
    ...    volume_status: up
    IF    "${relaycard_present}" == "False" or "${relaycard_present}" == ${None}
        SET MEDIA VOLUME    3    ${new_volume}
    ELSE
        FOR    ${var}  IN RANGE    1    999
           ${sound_value} =    GET SOUND VALUE
           Run Keyword If    "${sound_value}" <= "${new_volume}"     SEND VEHICLE VOLUME BY SWRC    ${volume_status}
           Run Keyword If    "${sound_value}" >= "${new_volume}"    exit for loop
        END
    END
    Log To Console    Check if sound is present
    ${status} =    Set Variable If    "${status}" == "present"    ${True}    ${False}
    ${sound_status} =    wait_until_keyword_succeeds    3x    5s    CHECK LOUD SPEAKER     ${status}
    Run Keyword If    "${status}" == "True"    SOUND PRESENT    ${sound_status}
    ...       ELSE    SOUND NOT PRESENT    ${sound_status}

CHECK THE NOTIFICATION BAR
    [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    Verify the notification bar to check the IVI is not frozen
    ${status} =    Run Keyword And Return Status    OPEN OR CLOSE THE NOTIFICATION BAR    expand
    ${clear_button} =   Run Keyword If    "${status}"=="True"    APPIUM_WAIT_FOR_XPATH    //*[@text='Clear all']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}    scroll_tries=50
    Run Keyword If    "${clear_button}"=="True"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Clear all']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Sleep    3
    OPEN OR CLOSE THE NOTIFICATION BAR

RELIABILITY KPI START
    @{list_boot_time} =    create list
    @{list_iterations_verdict_status} =    create list
    @{list_iterations_no_verdict_status} =    create list
    @{iterations_time} =    create list
    Set Global Variable    ${list_boot_time}
    Set Global Variable    ${list_iterations_verdict_status}
    Set Global Variable    ${list_iterations_no_verdict_status}
    Set Global Variable    ${iterations_time}

RELIABILITY KPI STOP
    [Arguments]    ${kpi}=100
    Run Keyword and Ignore Error    STAT BOOTIME
    CALCULATE RELIABILITY PASSRATE    ${kpi}

RELIABILITY LOOPS
    [Arguments]    ${steps}=${None}    ${stop_start_end_loop}=True    ${loops}=2    ${kpi}=100    @{arg_kw}
    IF    '${steps}' == '${None}'
        Log     Reliability Loop not executed bcause no steps specified     WARN
        Return From Keyword
    END

    IF    '${loops}' == '0'
        Log     Reliability Loop not executed bcause loops value = 0     WARN
        Return From Keyword
    END

    RELIABILITY KPI START
    Log    ${TEST NAME} has started    console=${console_logs}

    FOR    ${loop}    IN RANGE    1    ${loops} + 1
        Set Test Variable    ${loop}
        START RELIABILITY LOOP    ${status_list_verdict}    ${status_list_no_verdict}    ${loop}    ${loops}

        RELIAB_FUN_KW    ${steps}    @{arg_kw}

        IF    "${loop}" != "${loops}"
            Run Keyword And Ignore Error    STOP ONBOARD LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]
            IF    '${stop_start_end_loop}' == 'True'
                RELIABILITY LOOP STOP VEHICLE
            END
            Run Keyword And Ignore Error    STOP LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]    artifactory_logs_folder=${tc_config}[bench_tools_config][logs_config][artifactory_logs_folder]
        END

        END RELIABILITY LOOP    ${status_list_verdict}    ${status_list_no_verdict}    ${loop}    ${start_time}    ${loops}

        IF    "${loop}" != "${loops}"
            ${next_loop_id} =    Evaluate    ${loop} + 1
            ${next_loop} =    CONVERT LOOP    ${next_loop_id}
            Run Keyword And Ignore Error    START LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]    output_folder=loop_${next_loop}    artifactory_logs_folder=${tc_config}[bench_tools_config][logs_config][artifactory_logs_folder]
            IF    '${stop_start_end_loop}' == 'True'
                RELIABILITY LOOP START VEHICLE
            END
            Run Keyword And Ignore Error    START ONBOARD LOGS TOOLS    setup_type=${tc_config}[bench_type]    enable_logs=${tc_config}[bench_tools_config][logs_config][enable_logs]
        END
    END

    RELIABILITY KPI STOP    ${kpi}

RELIABILITY LOOP START VEHICLE
    START VEHICLE    ${tc_config}[start_stop_config][start_can_sequence]
    WAIT VEHICLE BOOT COMPLETED    ${tc_config}[bench_type]    ${tc_config}[start_stop_config][start_timeout]
    IF    '${ivi_hmi_action}' == 'True'
        CREATE APPIUM DRIVER
        Run Keyword If    "${ivi_screen_record}" != "False"    START SCREEN RECORD
    END

RELIABILITY LOOP STOP VEHICLE
    IF    '${ivi_hmi_action}' == 'True'
        Run Keyword If    "${ivi_screen_record}" != "False"    STOP SCREEN RECORD    ${logs_folder}/ivi_screen_record.mp4
        REMOVE APPIUM DRIVER
    END
    STOP VEHICLE    ${tc_config}[start_stop_config][stop_can_sequence]
    WAIT VEHICLE SLEEP MODE    ${tc_config}[bench_type]    ${tc_config}[start_stop_config][stop_timeout]


CHECK IVI BOOT INFO
    Log    **** Check boot reason ****    console=yes
    CHECK KEYWORD STATUS    CHECK BOOT REASON    verdict    ${status_list_verdict}    ${var}    ecs    ${ivi_adb_id}
    Run Keyword if    "${console_logs}" == "yes"     Log    **** Check kernel panic ****    console=yes
     ${value_verdict} =    Run Keyword And Continue On Failure    CHECK KERNEL PANIC    ${current_tc_name}    ${var}    ${ivi_adb_id}
    Run Keyword if     "${value_verdict}" == "False"     Log     Loop ${var} failed: kernel_panic    WARN

 # STEP_02: CHECK BOOT MODE : Retrieve boot info
    Log    **** Check boot mode ****    console=yes
    ${bootmode_loop_list} =    Run Keyword And Ignore Error    CHECK BOOT MODE    ecs    ${ivi_adb_id}
    ${bootmode_status} =    Get From List    ${bootmode_loop_list}    ${0}
    Append to list    ${status_list_verdict}    ${bootmode_status}
    ${bootduration_loop} =    Get From List    ${bootmode_loop_list}    ${1}
#    fail in case of no boot
    Run Keyword if    "${bootmode_status}" != "PASS"    Log    Loop ${var} failed : 'ANDROID BOOT (${bootduration_loop})' has failed.    WARN
    ${bootduration_loop} =    Set Variable if    'ValueError' in str($bootduration_loop)   0.0    ${bootduration_loop}
#        Warning in case of boot too long
    Run Keyword if    "${bootmode_status}" == "PASS" and "${bootduration_loop}" > "${threshold_ccs2_wakeup001}"    Log    Loop ${var} PASS with warning: 'ANDROID BOOT (current boot ${bootduration_loop}sec > ${threshold_ccs2_wakeup001}sec)' is too long.    WARN
    ${is float}=      Evaluate     isinstance($bootduration_loop, float)
    ${time_boot_float} =    Run Keyword if    "${is float}" == "True"    Convert To Number    ${bootduration_loop}
    Run Keyword if    "${is float}" == "True" and "${bootduration_loop}" > "0"    Append to list    ${list_boot_time}    ${time_boot_float}
    Run Keyword if    "${is float}" == "True" and "${bootduration_loop}" > "0"    Log    List: @{list_boot_time}
    Sleep    60

CHECK IVI PLAYSTORE
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_PLAYSTORE
    CHECK KEYWORD STATUS AND RETURN VALUES    CHECK PLAYSTORE APP    verdict    ${status_list_verdict}    ${var}    ${loop_folder}    screenshot_CHECK_PLAYSTORE_APP_failed
    INJECT LOGCAT MESSAGE    ccar    END_CHECK_PLAYSTORE

CREATE USER PROFILE WITH NAME
    [Arguments]    ${admin_profile}=Driver    ${number_of_profiles}=2    ${platform_version}=10   ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    Create new profile with name and check the notification bar
    ${loop_for} =    Evaluate    ${number_of_profiles} + 1
    @{list_of_profiles}=    Create List
    Append To List    ${list_of_profiles}    ${admin_profile}
    FOR    ${var}    IN RANGE    1    ${loop_for}
        CREATE APPIUM DRIVER
        ADD NEW USER PROFILE    ${platform_version}
        Sleep    1
        REMOVE APPIUM DRIVER
        CREATE APPIUM DRIVER
        ENABLE MULTI WINDOWS
        APPIUM LAUNCH USER MANAGEMENT
        Sleep    10
        EDIT PROFILE NAME    Profile_${var}
        CHECK THE NOTIFICATION BAR   ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
        REMOVE APPIUM DRIVER
        Append To List    ${list_of_profiles}    Profile_${var}
    END
    Set Test Variable    ${list_of_profiles}

CONFIGURE IVC STDRX
    [Documentation]    Allows the transition from StOn to StDRX state
    SET DRX STATE    1
    SET DRX DURATION    0
    SET MQTT AON DURATION    1C20
    SET MQTT KEEP ALIVE DURATION    003C
    CHECKSET IVC STDRX CONFIGURATION
    ${verdict}    ${output} =    SET IVC KM    1000
    Should Be True    ${verdict}    Failed SET IVC KM: ${output}

CHECK IVC CONNECTIVITY
    [Documentation]    Check IVC MQTT connection
    CHECK KEYWORD STATUS    CHECK IVC MQTT CONNECTION STATUS    verdict    ${status_list_verdict}    ${var}    success    8    10
    CHECK KEYWORD STATUS    CHECK IVC INTERNET CONNECTION    verdict    ${status_list_verdict}    ${var}    240    RELIABILITY

CHECK IVI INTERNET
    [Documentation]    Ping 8.8.8.8 to check if network is reachable
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_DATA_CONNECTIVITY
    ${verdict}    ${comment} =    Run Keyword and Ignore Error    Wait Until Keyword Succeeds    24x    10s    CHECK DATA CONNECTIVITY    available
    INJECT LOGCAT MESSAGE    ccar    END_CHECK_DATA_CONNECTIVITY
    Run Keyword If    "${verdict}" != "PASS"    Fail    ${comment}

CHECK IVC STATE TRANSITION
    [Documentation]    KW for Reliability Connectivity TC to check IVC states
    ${w}    ${w_error} =   START DLT CONVERSION    StOffData_Enter    1    ${10}
    IF    ${w}
        ${count_stoffdata} =    Evaluate    ${count_stoffdata} + 1
        Set Test Variable    ${count_stoffdata}
        Log    Loop_${var} - IVC state -> StOffData    WARN
    END
    ${w}    ${w_error} =   START DLT CONVERSION    StDrx_Enter    1    ${10}
    IF    ${w}
        ${count_stdrx} =    Evaluate    ${count_stdrx} + 1
        Set Test Variable    ${count_stdrx}
        Log    Loop_${var} - IVC state -> StDrx    WARN
    END
    ${w}    ${w_error} =   START DLT CONVERSION    StOff_Enter    1    ${10}
    IF    ${w}
        ${count_stoff} =    Evaluate    ${count_stoff} + 1
        Set Test Variable    ${count_stoff}
        Log    Loop_${var} - !!! IVC state -> StOff !!!    WARN
    END

WEBCAM PICTURES ON HMI
    [Documentation]    Make pictures with the webcam on the HMI
    [Arguments]    ${device_path}    ${path}
    Run Process     sudo chmod 777 ${device_path}    shell=True
    picture webcam    ${path}

UNLOCK PROFILE
    [Arguments]   ${pin_code}
    [Documentation]    Unlock admin and user profile with pin code using adb cmd
    unlock_admin_profile_with_pin_code   ${pin_code}

RELIAB_FUN_KW
    [Arguments]    ${steps}=${None}    @{arg_kw}
    CHECK KEYWORD STATUS    ${steps}    verdict    ${status_list_verdict}    ${loop}    @{arg_kw}

RELIAB_ENV_KW
    [Arguments]    ${steps}=${None}    @{arg_kw}
    CHECK KEYWORD STATUS    ${steps}    no_verdict    ${status_list_no_verdict}    ${loop}    @{arg_kw}

CONVERT LOOP
    [Arguments]    ${loop}
    ${loop_id} =    Set Variable    00${loop}
    # ${loop}    Convert To Integer    ${loop}
    IF    ${loop} > 9 and ${loop} <= 99
        ${loop_id} =    Set Variable    0${loop}
    ELSE IF    ${loop} > 99
        ${loop_id} =    Set Variable    ${loop}
    END
    [Return]    ${loop_id}