#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Pnp test utility
Library           rfw_services.ivi.LemonadLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.LogsLib    device=${ivi_adb_id}
Library           rfw_libraries.lemon.LemonAPILibrary.LemonAPILibrary
Library           String
Library           OperatingSystem
Variables         KeyCodes.yaml

*** Variables ***
${host}           host
${path}           ./
${app}            Development
${app_and_ext}    ${app}.apk
${app_pkg}        com.android.development
${component_name}    ${app_pkg}/.${app}
${crash_type}     Bad Behavior
${crash_option}    CRASH THE MAIN APP THREAD
${rm_apk_file_cmd}    rm ${app_and_ext}
${edit_profile}            //*[@text='Edit profile']
${data_collection}    //*[@text='Refuse sharing' or @text='Share only data' or @text='Share data and position']
${share_data}    //*[@text='Share data and position' and @class='android.widget.RadioButton']
${dont_share_data}    //*[@text='Refuse sharing' and @class='android.widget.RadioButton']
${privacy_file}     privacyManagerActivationStatus.xml

*** Keywords ***

CHECKSET LEMONAD PROVISIONING
    [Arguments]    ${dut_id}
    [Documentation]    Will provision the {dut_id} with the lemonad
    ...    ${dut_id} name of the dedicated dut
    Log To Console     Will provision the ${dut_id} with the lemonad
    SET ROOT
    # TODO discuss with MM team since this has never worked if 1st input is not bench then ValueError is raised
    # rfw_libraries.genivi.fota.libs.ivi.FileSystemLibrary.CREATE FOLDER    /data/misc/    lemonad
    ${output} =    OperatingSystem.Run    ./lemonad-android-setup.sh --azureauto --noproxy --print --date --restart --hwuid=${dut_id}
    ${hwuid_str} =    Set Variable    Set HW Uid to [${dut_id}]
    Should Contain    ${output}    ${hwuid_str}
    Should Not Contain    ${output}    No such file or directory

DO CRASH
    [Arguments]    ${dut_id}
    [Documentation]    Crash the app
    ...    ${dut_id} name of the dedicated dut
    Log To Console     Do Crash on ${dut_id}
    ${is_app_crash} =    CRASH APP
    Should Be True    ${is_app_crash}    App is not crashed

CHECK LEMONAD EVENT ID PRESENCE
    [Arguments]    ${dut_id}
    [Documentation]    Ensures a Lemonad Event is published
    ...    ${dut_id} name of the dedicated dut
    Log To Console     Ensures a Lemonad Event is published on ${dut_id}
    ${ret_value} =    Set Variable    ${False}
    FOR    ${i}    IN RANGE    0    12
        ${ret_value} =    CHECK FOR TEXT LOGCAT    Lemonad    to_delete=${False}
        ${ret_value} =    Run Keyword If    "${ret_value}" == "True"    CHECK FOR TEXT LOGCAT    Event    to_delete=${False}
        Exit For Loop If    "${ret_value}" == "True"
        DO WAIT    10000
    END
    Should Be True    ${ret_value}    search string not found in the logcat log

CHECK LEMONAD BOOT REASON PRESENCE
    [Arguments]    ${dut_id}
    [Documentation]    Check if the boot reason is published in the getprop
    ...    ${dut_id} name of the dedicated dut
    ${is_boot_reason_presence} =    BOOT REASON PRESENCE
    Should Be True    ${is_boot_reason_presence}

CHECK LEMONAD RELIABILITY JOB RUNNING AND REASON PRESENCE
    [Arguments]    ${dut_id}
    [Documentation]    Check that LEMONAD Reliability  is running.
    ...                This agent is responsible for publishing events in the offboard part of Lemonad.
    ...    ${dut_id} name of the dedicated dut
    Log To Console     Ensures a Lemonad Reliability Job is running and reason presence on ${dut_id}
    ${ret_value} =    Set Variable    ${False}
    FOR    ${i}    IN RANGE    0    12
        ${lem_value} =    CHECK FOR TEXT LOGCAT    Lemonad    to_delete=${False}
        ${ret_value} =    Run Keyword If    "${lem_value}" == "True"    CHECK FOR TEXT LOGCAT    published    to_delete=${False}
        Exit For Loop If    "${ret_value}" == "True"
        DO WAIT    10000
    END
    Should Be True    ${ret_value}    search string not found in the logcat log

CHECK LEMONAD RELIABILITY
    [Arguments]    ${dut_id}
    [Documentation]    Ensures a Lemonad Reliability is running
    ...    ${dut_id} name of the dedicated dut
    Log To Console     Ensures a Lemonad Reliability is running on ${dut_id}
    ${ret_value} =    Set Variable    ${False}
    FOR    ${i}    IN RANGE    0    12
        ${ret_value} =    CHECK FOR TEXT LOGCAT    Lemonad.ConfigurationManager    to_delete=${False}
        ${rel_value} =    Run Keyword If    "${ret_value}" == "True"    CHECK FOR TEXT LOGCAT    default_reliability_all_clicktracker    to_delete=${False}
        Exit For Loop If    "${rel_value}" == "True"
        DO WAIT    10000
    END
    Should Be True    ${rel_value}    search string not found in the logcat log

DO START LOGCAT
    [Arguments]    ${dut_id}
    [Documentation]    Clear the logcat and start capturing the logcat in a log file
    ...    ${dut_id} name of the dedicated dut
    Log To Console    Clear and start the logcat capturing and store in Logcat.log file
    SET ROOT
    CLEAR LOGCAT
    DO REBOOT     ${dut_id}    command line
    CHECK TARGET NOT IN ADB DEVICES LIST    ${ivi_adb_id}    10
    CHECK IVI BOOT COMPLETED    booted    60
    ${ret_value} =    START LOGCAT LOG    ${dut_id}
    Should Be True    ${ret_value}    Not able to start the logcat log

DO STOP LOGCAT
    [Arguments]    ${dut_id}
    [Documentation]    Deletes the Logcat.log file
    ...    ${dut_id} name of the dedicated dut
    Log To Console    Stopping logcat and deleteing the Logcat.log file
    OperatingSystem.Run    rm -f Logcat.log

CHECK OFFBOARD LEMON SERVER EVENTS
    [Arguments]    ${status}
    [Documentation]    Checks Offboard Lemonad Server Events on IVI
    ...    ${status} Status to check either True or False
    Log To Console    Checks Offboard Lemonad Server Events on IVI
    ${session_id}    ${seq_nb} =    LEMONAD GET SESSION ID SEQ NB
    ${verdict}    ${payload} =    GET LEMON EVENT DETAILS    ${session_id}    ${seq_nb}
    Run Keyword If    "${status}" == "True"    Should Be True    ${verdict}
    Run Keyword If    "${status}" == "False"    Should Not Be True    ${verdict}

SET DATA COLLECTION APPIUM
    [Arguments]    ${dut_id}    ${privacy_file}    ${status}
    [Documentation]    SET DATA COLLECTION on ${dut_id} to ${status}
    ...    ${dut_id}: name of target_id
    ...    ${privacy_file}: xml file to push for Data Collection
    ...    ${status}: ON / OFF. ON for Data Collection and OFF for not Collecting Data
    Log To Console    SET DATA COLLECTION on ${dut_id} to ${status}
    SET ROOT
    ${output}    ${error} =    PUSH     ${privacy_file}    /data/user/0/com.alliance.lemonad/shared_prefs
    Should Contain    ${output}    privacyManagerActivationStatus.xml: 1 file pushed
    ${app_status} =    LAUNCH APP APPIUM    ProfileSettings
    Should Be True    ${app_status}
    Sleep    5
    APPIUM_TAP_XPATH    ${edit_profile}    retries=20
    APPIUM_TAP_XPATH    ${data_collection}    retries=20
    ${share_status} =    Set Variable If    "${status}" == "ON"    ${share_data}    ${dont_share_data}
    APPIUM_TAP_XPATH    ${share_status}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

DO CLEAR LOGCAT
    [Documentation]    Clear logcat
    CLEAR LOGCAT
