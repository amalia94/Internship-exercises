#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#

*** Settings ***
Library           Collections
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.WaitForAdbDevice
Library           rfw_services.ivi.DiagnosticLib    device=${ivi_adb_id}
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Variables         ${CURDIR}/KeyCodes.yaml


*** Variables ***
${console_logs}      yes
${ivi_adb_id}        ZX1G424JNN

*** Keywords ***
ADB_ENTER
    [Arguments]    ${dut_id}
    [Documentation]    == High Level Description: ==
    ...    Press ENTER on ${dut_id} adb device
    ...    == Parameters: ==
    ...    - dut_id: the adb device id that perform the command
    ...    == Expected Results: ==
    ...    output: passed/failed
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    1s

ADB_REBOOT
    rfw_services.ivi.SystemLib.Reboot
    Sleep    10s

ADB_SET_ROOT
    SET ROOT
    log to console    IVI device ${ivi_adb_id} is now rooted
    Sleep   5s

ADB_SET_UNROOT
    SET UNROOT
    log to console    the device ${ivi_adb_id} is unrooted
    sleep    10s

ADB_CHECK_CURRENT_PACKAGE
    [Arguments]    ${app_package}
    [Documentation]    == High Level Description: ==
    ...    fail if current package is not the one in agument
    ...    == Parameters: ==
    ...    - ivi_adb_id: adb id of the device
    ...    - app_package: application package name
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${result} =    PS PACKAGE    ${app_package}
    should be true    ${result}

ADB_AM_GET_CURRENT_USER_NAME
    ${user_id} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell am get-current-user
    ${user_name} =    GET CURRENT USER NAME
    Run Keyword if    "${console_logs}" == "yes"     log to console    current user: ${user_name}
    Run Keyword if    "${console_logs}" == "yes"     log to console    current id: ${user_id}
    [Return]    ${user_name}    ${user_id}

ADB_PM_CREATE_USER
    [Arguments]    ${user_name}
    ${result}  ${comment} =    CREATE USER    ${user_name}
    should contain    ${result}    Success    'Coundn't create a new user,check if the maximum number of user is reached'    False

ADB_PM_REMOVE_USER
    [Arguments]    ${user_name}=New
    [Documentation]    == High Level Description: ==
    ...    BE CAREFULL DOESNT WORK FOR THE GUEST if you have never connect to it after a reboot
    ...    == Parameters: ==
    ...    - user_name: name of the user in the android device
    ...    == Expected Results: ==
    ...    output: passed/failed
    ADB_AM_SWITCH_TO_ROOT_USER
    ${username_id} =    GET USER ID BY NAME    ${user_name}
    ${result}    ${error} =    DELETE USER    ${username_id}

ADB_AM_SWITCH_USER
    [Arguments]    ${user_name}
    [Documentation]    == High Level Description: ==
    ...    BE CAREFULL DOESNT WORK FOR THE GUEST if you have never connect to it after a reboot
    ...    == Parameters: ==
    ...    - user_name: name of the user in the android device
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${user_id} =    GET USER ID BY NAME    ${user_name}
    ${result}    ${error} =    SWITCH TO USER    ${user_id}
    ${current_user_id} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell am get-current-user
    should be equal    ${current_user_id}    ${user_id}    'the switch haven't occured!check if ${user_name} is correct'    False

ADB_AM_SWITCH_TO_ROOT_USER
    ${driver_id} =    GET USER ID BY NAME    "Driver"
    ${result}    ${error} =    SWITCH TO USER    ${driver_id}
    Sleep    5s

UNINSTALL_APPIUM_LIBRARIES
    [Documentation]    == High Level Description: ==
    ...    To uninstall apk's installed by appium while launch app
    ...    == Expected Results: ==
    ...    appium apps should be uninstalled
    UNINSTALL APK    io.appium.settings
    UNINSTALL APK    io.appium.uiautomator2.server
    UNINSTALL APK    io.appium.uiautomator2.server.test

CHECKSET IVI PBO STATUS
    [Arguments]    ${status}
    [Documentation]    To set PBO status to True or False on IVI if it's not already done.
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECKSET IVI PBO STATUS
    SET ROOT
    ${verdict}    ${comment} =    CHECK PBO STATUS    ${ivi_adb_id}    ${status}
    IF    "${verdict}"=="False" and "different than desired one" in "${comment}"
        ${verdict}    ${output} =    SET PBO STATUS    ${ivi_adb_id}    ${status}
        CHECK PBO ACTIVATION STATUS ON IVI    ${status}
    END
    Should Be True    ${verdict}    ${comment}

CHECK PBO ACTIVATION STATUS ON IVI
    [Arguments]    ${status}
    [Documentation]    To check PBO status.
    ${verdict}    ${output} =    CHECK PBO STATUS    ${ivi_adb_id}    ${status}
    Should Be True    ${verdict}    ${output}

EXEC IVI LOCAL COMMAND
    [Arguments]    ${exec_command}
    [Documentation]    execute a command in command prompt
    ${output} =    OperatingSystem.Run    ${exec_command}
    [Return]    ${output}

CHECK IVI DATE AND TIME
    [Documentation]    == High Level Description: ==
    ...    Get the Date & Time in both IVI & IVC. Compare the result and check both are equal.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    Pass if date and time are good
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Services Common    IVI CMD
    Log To Console    CHECK IVI DATE AND TIME
    ${ivi_time_stamp} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell date -u '+%Y-%m-%d%H:%M:%S'
    ${ivi_time_stamp} =    DateTime.Convert Date    ${ivi_time_stamp}    result_format=%Y-%m-%d %H:%M:%S
    ${verdict}    ${ivc_time_stamp} =    GET DATE ON IVC    '+%Y-%m-%d %H:%M:%S'
    Should Be True    ${verdict}    Failed to GET DATE ON IVC: ${ivc_time_stamp}
    ${time_diff} =    DateTime.Subtract Date From Date    ${ivc_time_stamp}    ${ivi_time_stamp}
    ${time_diff_converted} =    Evaluate     int(abs(${time_diff}))
    Should Be True    ${time_diff_converted} <= 20    IVI and IVC timestamp is not matching.
    [return]    ${ivi_time_stamp}

CHECK IVI SERVICE ACTIVATION FEATURE STATUS
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check that the service activation feature is not yet enabled by PBO.
    ...    == Parameters: ==
    ...    - _status_: enabled, disabled
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Service subscription management    IVI CMD
    ${expected_value} =    Set Variable If    "${status}" == "enabled"    true   "${status}" == "disabled"    false
    ${verdict}    ${output} =    CHECK PBO STATUS    ${ivi_adb_id}    ${expected_value}
    Run keyword If    "${status}"=="enabled"    Should Be True    ${verdict}    PBO is not activated
    Run keyword If    "${status}"=="disabled"   Should Be True    ${verdict}    PBO is activated

GET IVI ADB ID
    [Documentation]    Get IVI ADB ID only (in case more than 1 adb devices connected)
    ${adb_devices_cmd} =    OperatingSystem.Run    adb devices -l | grep 'usb.*ivi2'
    ${adb_id} =    Fetch From Left    ${adb_devices_cmd}    ${SPACE}
    [Return]    ${adb_id}

GET IVI BOARD TYPE
    [Documentation]    Get IVI board type (BDV/C/etc...)
    ${output} =    GET PROP    persist.board.type
    ${board_type} =    Get Substring    ${output}    2    -3
    Should Not Contain    ${board_type}    None
    [Return]    ${board_type}

GET IVI BUILD TYPE
    [Documentation]    Get IVI build type (user/userdebug...)
    ${output}    ${error} =    GET PROP    ro.product.build.type
    Should Not Contain    ${output}    None
    [Return]    ${output}

DO DELETE LICENCE_ID
    [Documentation]    Delete the license and key from IVI
    [Arguments]    ${ivi_adb_id}
    ADB_SET_ROOT
    DELETE FOLDER OR FILE    /data/misc/keystore/user_0/1000_USRCERT_licenseKey_vnext
    DELETE FOLDER OR FILE    /data/misc/keystore/user_0/1000_USRPKEY_licenseKey_vnext

DO RESTART EHorizonService
    [Documentation]    Restart EHorizon Service
    [Arguments]    ${ivi_adb_id}
    ADB_SET_ROOT
    RUN COMMAND AND CHECK RESULT    "am force-stop com.elektrobit.ehorizon"    ${EMPTY}

SET IVI LOGCAT VERBOSE
    [Documentation]    Set IVI logcat to Verbose
    [Arguments]    ${ivi_adb_id}
    ADB_SET_ROOT
    RUN COMMAND AND CHECK RESULT    "setprop persist.log.tag VERBOSE"    ${EMPTY}

SET LOGCAT TRIGGER FOR EHORIZON
    [Documentation]    Set logcat trigger for EHorizon
    ${log_trace} =    Set Variable If    '${sweet400_bench_type}' in "'${bench_type}'"    License Token=    License token=
    SET LOGCAT TRIGGER    message=${log_trace}

WAIT LOGCAT TRIGGER FOR EHORIZON
    [Documentation]    Wait to logcat trigger for EHorizon
    ${log_trace} =    Set Variable If    '${sweet400_bench_type}' in "'${bench_type}'"    License Token=    License token=
    WAIT FOR LOGCAT TRIGGER    message=${log_trace}   timeout=${300}

CHECK MAP REGIONS ON IVI
    [Documentation]    Check if the MapRegion is populated with the following files
    [Arguments]    ${map}
    CHECK MAP FILE PRESENT ON IVI    ${map}    HOME_AREA.DB
    CHECK MAP FILE PRESENT ON IVI    ${map}    ROOT.NDS
    IF    '${sweet400_bench_type}' in "'${bench_type}'"
        CHECK MAP FILE PRESENT ON IVI    ${map}    PRODUCT_53_22
    ELSE
        CHECK MAP FILE PRESENT ON IVI    ${map}    PRODUCT_3_22
    END

CHECK EHORIZON LICENCE_ID IS DOWNLOADED
    [Documentation]    Check if the license and key has got downloaded or not in IVI
    [Arguments]    ${ivi_adb_id}
    SET ROOT
    IF    '${sweet400_bench_type}' in "'${bench_type}'"
        @{output} =    LISTING CONTENTS    -la /data/user/0/com.elektrobit.ehorizon/shared_prefs/licenses.xml
        ${evaluate} =    Evaluate    'No such file or directory' not in @{output}
        Should Be True    ${evaluate}
        @{output} =    LISTING CONTENTS    -la /data/user/0/com.elektrobit.ehorizon/shared_prefs/licenses.xml
        ${evaluate} =    Evaluate    'No such file or directory' not in @{output}
        Should Be True    ${evaluate}
    ELSE
        @{output} =    LISTING CONTENTS    -ltr /data/misc/keystore/user_0/1000_USRCERT_licenseKey_vnext
        ${evaluate} =    Evaluate    'No such file or directory' not in @{output}
        Should Be True    ${evaluate}
        @{output} =    LISTING CONTENTS    -ltr /data/misc/keystore/user_0/1000_USRPKEY_licenseKey_vnext
        ${evaluate} =    Evaluate    'No such file or directory' not in @{output}
        Should Be True    ${evaluate}
    END

DO DELETE SA_DATA
    [Documentation]    Delete the SA
    DELETE FOLDER OR FILE    /mnt/product/persist-alliance/data/SA_data

SET EHORIZON MULTIMEDIA CONFIG
    [Documentation]    Set the ehorizon config for multimedia for License retrieval ehorizon
    ...    == Parameters: ==
    ...    - _parameter_: Name of the ehorizon multimedia config
    ...    - _value_: Depending on the parameter, could be any one ACC, OSP, ACC_OSP
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Arguments]    ${ehorizon_config}
    ${result} =     Evaluate     "${ehorizon_config}"=="ACC" or "${ehorizon_config}"=="ACC_OSP" or "${ehorizon_config}"=="OSP" or "${ehorizon_config}"=="NO_CONFIG"
    Should be True     ${result}     Wrong config type is provided for ehorizon multimedia
    ${long_range} =    Set Variable If    "${ehorizon_config}"=="ACC" or "${ehorizon_config}"=="ACC_OSP"    1    "${ehorizon_config}"=="OSP" or "${ehorizon_config}"=="NO_CONFIG"    0
    ${short_range} =    Set Variable If    "${ehorizon_config}"=="ACC" or "${ehorizon_config}"=="NO_CONFIG"   0    "${ehorizon_config}"=="OSP" or "${ehorizon_config}"=="ACC_OSP"    1
    DIAG SET CONFIG    multimedia_config/ehorizon/adasisv2_long_range    ${long_range}
    Sleep    5
    DIAG SET CONFIG    multimedia_config/ehorizon/adasisv2_short_range    ${short_range}
    Sleep    5
    ADB_REBOOT
    Sleep   30

CHECK EHORIZON MULTIMEDIA CONFIG
    [Documentation]    Verify the ehorizon multimedia config for ACC and OSP
    ...    == Parameters: ==
    ...    - _parameter_: Name of the multimedia config (ACC, OSP, ACC_OSP)
    ...    - _value_: Depending on the parameter, could be any one ACC, OSP, ACC_OSP
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Arguments]    ${ehorizon_config}
    ${result} =     Evaluate     "${ehorizon_config}"=="ACC" or "${ehorizon_config}"=="ACC_OSP" or "${ehorizon_config}"=="OSP" or "${ehorizon_config}"=="NO_CONFIG"
    Should be True     ${result}     Wrong config type is provided for ehorizon multimedia
    ${long_range} =    Set Variable If    "${ehorizon_config}"=="ACC" or "${ehorizon_config}"=="ACC_OSP"    1    "${ehorizon_config}"=="OSP" or "${ehorizon_config}"=="NO_CONFIG"    0
    ${short_range} =    Set Variable If    "${ehorizon_config}"=="ACC" or "${ehorizon_config}"=="NO_CONFIG"    0    "${ehorizon_config}"=="OSP" or "${ehorizon_config}"=="ACC_OSP"    1
    ${verdict}     ${response} =    GET IVI EHORIZON MULTIMEDIA CONFIG      ${ivi_adb_id}
    Should Be True    ${verdict}    Fail to get ivi ehorizon multimedia config
    ${adasisv2_provider} =     Evaluate    "adasisv2_short_range:(${short_range})adasisv2_long_range:(${long_range})" in """${response}"""
    Should Be True    ${adasisv2_provider}    ACC Or OSP service is not activated

CHECK FLAG STATE FOR IVI
    [Arguments]    ${state}    ${name_of_service_from_commet}
    [Documentation]    Check on the IVI platform ${name_of_service_from_commet} with value ${state}
    ...    == Parameters: ==
    ...    - _name_of_service_from_commet_: Name of the parameter, could be:
    ...    charge_scheduler_activation, presoak_scheduler_activation, responce_bcm_ev_timeout, ev_smartcharging_activation_status
    ...    - _state_: Depending on the parameter, could be ON/OFF or a numeric value
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Check Flag    IVI CMD
    ${status} =    Set Variable If    "${state}" == "activate"    ON    "${state}" == "deactivate"    OFF
    ...    ELSE    Log To Console    Invalid data flag storage status:${status}
    ${service_from_commet} =    Fetch From Left    ${name_of_service_from_commet}    .
    ${name_of_service_from_commet} =    Fetch From Right    ${name_of_service_from_commet}    .
    ${name_of_service_from_commet} =    Convert To Lower Case    ${name_of_service_from_commet}
    ${output} =    DIAG READ CONFIG    ${service_from_commet}/${name_of_service_from_commet}/status
    ${verdict} =    Evaluate    "${status}" in """${output}"""
    Should be true    ${verdict}    Fail to execute DIAG READ CONFIG
    [Return]    ${verdict}

SWITCH AND CHECK USER PROFILE BEFORE ECS BOOT
    [Arguments]    ${current_profile}    ${profile1}    ${profile2}    ${loop}
    SWITCH PROFILE    ${current_profile}    ${profile1}    ${profile2}
    ${changed_profile} =     ADB_AM_GET_CURRENT_USER_NAME
    Set Test Variable    ${changed_profile}
    Should Not Be Equal    ${changed_profile}    ${current_profile}
    ${profile_change_occured} =    Evaluate    ${profile_change_occured} + 1
    Set Test Variable    ${profile_change_occured}
    Append To List    ${loops_where_profile_was_changed}    ${loop}
    Set Test Variable    ${loops_where_profile_was_changed}

SWITCH PROFILE
    [Arguments]    ${current_profile}    ${profile1}    ${profile2}
    Run Keyword If     "${current_profile}" == "${profile1}"    Run Keywords
    ...    ADB_AM_SWITCH_USER    ${profile2}
    ...    AND    Sleep    10
    Run Keyword If     "${current_profile}" == "${profile2}"    Run Keywords
    ...    ADB_AM_SWITCH_USER    ${profile1}
    ...    AND    Sleep    10

CREATE A PROFILE AND SWITCH TO IT
    [Arguments]    ${new_profile}
    ADB_PM_CREATE_USER    ${new_profile}
    Sleep    2
    ADB_AM_SWITCH_USER    ${new_profile}
    Sleep    10

CHECK EHORIZON LICENCE_ID IS NOT DOWNLOADED
    [Documentation]    Check if the license and key has not downloaded in IVI
    [Arguments]    ${ivi_adb_id}
    SET ROOT
    @{output} =    LISTING CONTENTS    -ltr /data/misc/keystore/user_0/1000_USRCERT_licenseKey_vnext
    ${evaluate} =    Evaluate    'No such file or directory' not in @{output}
    Should Be True    ${evaluate}
    @{output} =    LISTING CONTENTS    -ltr /data/misc/keystore/user_0/1000_USRPKEY_licenseKey_vnext
    ${evaluate} =    Evaluate    'No such file or directory' not in @{output}
    Should Be True    ${evaluate}

REPLACE CORRUPT EHORIZON LICENSE
    [Arguments]    ${source_file}=${CURDIR}/Resources    ${destination_file}=/data/misc/keystore/user_0
    [Documentation]    Check if the license and key has not downloaded in IVI
    SET ROOT
    DO DELETE LICENCE_ID    ${ivi_adb_id}
    PUSH    ${source_file}/user_0    ${destination_file}

CHECKSET TRK FILE FOR EHORIZON SERVICE
    [Arguments]    ${trk_file_path}    ${trk_file_name}
    [Documentation]     This KW is used to add trk file on IVI.
    ${check_privacy_file} =    CHECK FILE PRESENT    ivi    /data/ehorizon/records/${trk_file_name}
    Return from keyword If    "${check_privacy_file}" == "True"
    SET ROOT
    ${output}    ${error} =    PUSH    ${trk_file_path}/${trk_file_name}    /data/ehorizon/records/
    Should Contain    ${output}    ${trk_file_name}: 1 file pushed

RUN COMMAND AND CHECK RESULT
    [Arguments]    ${adb_cmd}    ${value}
    [Documentation]     This KW is used to send adb command by using OperatingSystem.Run
    ...    == Parameters: ==
    ...    - value: output value to verify
    ...    - adb_cmd: adb command to send
    ...    == Expected Results: ==
    ...    output: returns the output of adb command
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell ${adb_cmd}
    Should Contain    ${output}    ${value}    Expected output not found in adb command output

CHECK IVI CONFIG PARAMETER VALUE ALLIANCE
    [Arguments]    ${parameter}=${None}
    [Documentation]     This KW is used to check IVI alliance car service configurations and parameter values by using RUN COMMAND AND CHECK RESULT.
    ...    == Parameters: ==
    ...    - parameter: alliance car parrameters to verify
    ...    == Expected Results: ==
    ...    output: returns the output of the adb command displaying all alliance car services if no parameter is mentioned and display specific parameter alliance car services if any parameter is mentioned.
    IF    '${parameter}' == '${None}'
            RUN COMMAND AND CHECK RESULT    dumpsys alliance_car_service   dump all services
    ELSE
            RUN COMMAND AND CHECK RESULT    dumpsys alliance_car_service | grep ${parameter}   ${parameter}
    END
