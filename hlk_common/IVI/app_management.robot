#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
# EXAMPLE: THIS HLK LIBRARY HAS BEEN MODIFIED IN THIS MR SO ALL SMOKE TESTS THAT USE IT WILL RUN IN # THE PRE_MERGE PIPELINE
*** Settings ***
Documentation    communication/interaction with dut - keywords library
Library          rfw_services.ivi.AudiomediaLib    device=${ivi_adb_id}
Library          rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library          OperatingSystem
Variables        ${CURDIR}/KeyCodes.yaml

*** Variables ***
${ivi_adb_id}         ${None}
${apk_mainentry}      not specified
${apk_package}        not specified
${package}            not specified
${repo}               matrix/artifacts/apps/
${platform_name}      Android
${platform_version}   10
${smartphone_platform_version}    11
&{application}        package=${None}    activity=${None}    app=${None}

*** Keywords ***
DO INSTALL APP
    [Arguments]    ${target_id}    ${app}    ${option}=${None}
    [Documentation]    Install an app named ${app} on the ${target_id} device
    ...    ${target_id} the target where to install the application
    ...    ${app} the application to install
    ...    ${option} the options to pass for the installation
    ...    ${repo} from where to download the application (internal keyword variable that can be defined within test cases)
    OperatingSystem.Run    rm ${app}
    ${status}    ${file} =    DOWNLOAD FILE FROM ARTIFACTORY    ${repo}${app}
    Should Be True    ${status}    Failed to download '${repo}${app}' from artifactory
    INSTALL APK    ${app}

SET LAUNCH APP
    [Arguments]    ${device_type}=ivi    ${app_name}=Navigation    ${TC_folder}=${EMPTY}
    [Documentation]    Launch an App on ${device_type} device
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ${device_type}
    ${app} =    Catenate    SEPARATOR=/    ${app_package}    ${app_activity}
    Log To Console    Inside SETLAUNCHAPP on ${device_type} ${app_package} ${app}
    ${result} =    LAUNCH APP    ${app}    ${app_package}
    Sleep    5
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${result}
    ...    ELSE    Should Be True    ${result}

LAUNCH APPIUM APP ON SMARTPHONE
    [Arguments]    ${app_smartphone}    ${device_type}=smartphone     ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_smartphone}    ${device_type}    ${smartphone_platform_version}
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    ${result} =    START ACTIVITY    ${app_package}    ${app_activity}
    Sleep    10
    Run Keyword If    ${result} != True    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Should Be True    ${result}

GO HOME SCREEN APPIUM
    APPIUM_PRESS_KEYCODE    ${KEYCODE_HOME}
    Sleep    5

SET UNINSTALL APP
    [Arguments]    ${target_id}    ${application_package}
    [Documentation]    Uninstall Application Package: ${application_package} from the ${target_id} and check it is correctly uninstalled
    Log To Console    Uninstall Application package: ${application_package} from target_id: ${target_id}
    ${result} =    UNINSTALL APK    ${application_package}
    Should Be True    ${result}    Application package: ${application_package} could not be removed from target_id: ${target_id}

DO CLEAR APP
    [Arguments]    &{package}
    [Documentation]    Clean the Application (${package}) cache & data
    CLEAR PACKAGE    ${package}[package]

DO CLOSE APP
    [Arguments]    ${device_type}=ivi    ${app_name}=Navigation
    [Documentation]    Stop the ${app_name} on ${device_type} device
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ${device_type}
    Log To Console    DO CLOSE APP device_type: ${device_type} application: ${app_package}
    STOP INTENT    ${app_package}

CHECK STATUS APP
    [Arguments]    ${target_id}    ${expected_status}    ${app_status}    ${app_name}
    [Documentation]  Checks the status of the app according to the expected status
    Log To Console    Checking the status of application: ${app_name}
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ivi
    ${app_status} =    STATUS OF APP    ${target_id}    ${expected_status}    ${app_status}    ${app_package}
    Should Be True    ${app_status}    The check status app failed, expected stauts of ${expected_status} and ${app_status} not met

DO UNINSTALL APP
    [Arguments]    ${target_id}    &{application}
    [Documentation]    Uninstall app package ${apk_package} from the ${target_id} Device
    Log To Console    Uninstalling &{application} on target device: ${target_id}
    UNINSTALL APK    ${application}[package]

DO KILL APP
    [Arguments]    ${device_type}=ivi    ${app_name}=Navigation
    [Documentation]    Kill the application on ${device_type} and the app is no more running in the background
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ${device_type}
    Log To Console    DO KILL APP ${device_type} package:${app_package}
    CLEAR PACKAGE    ${app_package}

SET CLOSE APP
    [Arguments]    ${target_id}    ${app_name}
    [Documentation]    Close the running ${application} and check it is really closed.
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ivi
    STOP INTENT    ${app_package}
    ${result} =    PS PACKAGE    ${app_package}
    Should Not Be True    ${result}    Application package:${app_package} could not be closed

CHECKSET INSTALL APP
    [Arguments]    ${target_id}    ${apk_name}    ${apk_package}    ${folder}=${NONE}
    [Documentation]    To check if the app is installed.  If it is not, it will be installed.
    ...    ${target_id}  the target where to install the application
    ...    ${apk_name}  the application to install (APK name)
    ...    ${apk_package}  the application package name
    ...    ${folder}  Downloading folder for application APK from artifactory
    ${check_apk} =    CHECK APK    ${apk_package}
    Return From Keyword If    "${check_apk}"=="True"    App is already installed
    OperatingSystem.Run    rm ${apk_name}
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${repo}${apk_name}    ${folder}
    Should be true    ${verdict}    Failed to download '${repo}${apk_name}' from artifactory
    LOG TO CONSOLE    DEBUG_download file response: ${result_download}
    INSTALL APK    ${result_download}
    ${check_apk} =    CHECK APK    ${apk_package}
    Should Be True    ${check_apk}    Failed to install the app

CHECKSET UNINSTALL APP
    [Arguments]    ${target_type}=ivi    ${app_name}=Navigation
    [Documentation]    To check if the app is uninstalled.  If it is not, it will be uninstalled.
    ...    ${target_id}  the target where to install the application
    ...    ${app_name}  the application name to uninstall
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    ${app_name}    ${target_type}
    ${check_apk} =    CHECK APK    ${app_package}
    LOG TO CONSOLE    app ${app_package} installed: ${check_apk}
    Return From Keyword If    "${check_apk}"=="False"    App is already uninstalled
    LOG TO CONSOLE    try to uninstall ${app_package}
    UNINSTALL APK    ${app_package}
    ${check_apk} =    CHECK APK    ${app_package}
    Should Be True    "${check_apk}"=="False"    Failed to uninstall the App

INITIALISE_MATRIX_AGENT_LIBRARY
    [Documentation]    Initialise the library required for the Matrix Agent
    Import Library           rfw_services.ivi.android_agent.AndroidAgentTool    device=${ivi_adb_id}

DO IVI START LOCATION SIMULATOR
    [Documentation]    To start LOCATION Simulator
    ...    ${enable_cmd} To enable location simulator app
    ...    ${allow_cmd} To allow permission to location simulator app
    [Arguments]    ${dut_id}    ${enable_cmd}    ${allow_cmd}    ${trk_file_name}
    RUN KEYWORD IF    '${enable_cmd}' != 'None'   OperatingSystem.Run    adb -s ${ivi_adb_id} shell ${enable_cmd}
    RUN KEYWORD IF    '${allow_cmd}' != 'None'    OperatingSystem.Run    adb -s ${ivi_adb_id} shell ${allow_cmd}
    CREATE APPIUM DRIVER
    SLEEP    20
    SET LAUNCH APP    ivi    eHorizon
    SLEEP    5
    TAP BY XPATH    //*[@text='REPLAY']
    SLEEP    2
    ${check_none} =    APPIUM_WAIT_FOR_XPATH    //*[@text='<none>']    20
    RUN KEYWORD IF    '${check_none}' == 'False'    SCROLL_TO_ELEMENT    //*[@text='<none>']    down    3
    TAP BY XPATH    //*[@text='<none>']
    SLEEP    5
    TAP BY XPATH    //*[@text='${trk_file_name}']
    SLEEP    5
    TAP BY XPATH    //*[@text='START']
    SLEEP    100
    TAP BY XPATH    //*[@text='STOP']
    SLEEP    30
    SET CLOSE APP    ivi    eHorizon
    REMOVE APPIUM DRIVER

DO ATTEND ECALL
    [Documentation]    To attend the emergency call
    APPIUM_PRESS_KEYCODE   ${KEYCODE_CALL}
    DO WAIT    10000
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENDCALL}

DISABLE GPS SIMULATION
    [Documentation]    Disable the GPS simulation of IVI.
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pm disable android.support.test.locationsimulator/.LocationSimulatorService
    DELETE FOLDER OR FILE    /data/local/tmp/mtv_tahoe.gpx
