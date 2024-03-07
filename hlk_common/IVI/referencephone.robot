#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     ReferencePhoneLib Companion - keywords library
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.usb_cutter.UsbCutter
Library           PnP/src/utils/PnpUtils.py

Resource          usb.robot
Resource          appium_hlks.robot

Variables         KeyCodes.yaml

*** Variables ***
${console_logs}      yes
${dut_to_pair}       ${None}
${companion_name}    ${None}
${smartphone_adb_id}     ${None}
${bt_device}         ${companion_name}
&{target}            host=bench    dut=ivi
&{smartphone_settings}        package=com.android.settings    activity=com.android.settings.Settings
${app_notifications}          //*[@text='Apps and notifications']
${app_info}                   //*[@text='App info']
${android_auto}               //*[@text='Android Auto']
${permissions}                //*[@text='Permissions']
${calendar_xpath}             //*[@text='Calendar']
${call_logs}                  //*[@text='Call logs']
${sms}                        //*[@text='SMS']
${contacts}                   //*[@text='Contacts']
${location}                   //*[@text='Location']
${microphone}                 //*[@text='Microphone']
${allow}                      //*[@resource-id='com.android.permissioncontroller:id/allow_radio_button']
${allow_while_app_using}      //*[@resource-id='com.android.permissioncontroller:id/allow_foreground_only_radio_button']

*** Keywords ***
CHECK ANDROID AUTO POPUP
    [Documentation]   To Check & click on android auto popup on ivi
    TAKE SCREENSHOT    sdcard/    popup.png    ./
    Sleep    2
    ${result} =    SEARCH TEXT IN IMAGE    ./    popup.png    Start
    Run Keyword If    "${result}" == "True"    Run Keywords        ${auto_popup_button} =    Create Dictionary    x=490   y=860
    ...                                                            AND  APPIUM_TAP_LOCATION    ${auto_popup_button}

CHECK SMART REPLICATION UI SPCX
    [Documentation]   To verify smartphone replication on ivi
    TAKE SCREENSHOT    sdcard/    maps.png    ./
    Sleep    2
    ${result} =    SEARCH TEXT IN IMAGE    ./    maps.png    Search
    Should Be True    ${result}

SET ADB SMARTPHONE STATE
    [Arguments]    ${adb_state}    ${smartphone_adb_id}
    OperatingSystem.Run    adb ${adb_state} ${smartphone_adb_id}

START COMPANION TOOLS
    [Arguments]    ${tc_variables}=${None}    ${companion_params}=${None}
    Run Keyword If    "${companion_params}[cutter_id]" != "${None}" and "smartphone" in "${tc_variables}"    SET USB STATUS    ${companion_params}[cutter_id]    unplugged    smartphone    after_ivi_boot=False
    Run Keyword If    "${companion_params}[cutter_id]" != "${None}" and "smartphone" not in "${tc_variables}"    CHECKSET USB STATUS    ${companion_params}[cutter_id]    unplugged    after_ivi_boot=False
    Run Keyword If    "smartphone" not in "${tc_variables}"    Return From Keyword
    Run Keyword if    "${console_logs}" == "yes"     Log    **** START COMPANION TOOLS ****    console=yes
    SET ADB SMARTPHONE STATE    connect    ${companion_params}[adb_id]

STOP COMPANION TOOLS
    [Arguments]    ${tc_variables}=${None}    ${companion_params}=${None}
    Run Keyword If    "${companion_params}[cutter_id]" != "${None}" and "smartphone" in "${tc_variables}"    SET USB STATUS    ${companion_params}[cutter_id]    plugged    smartphone    hostpc
    Run Keyword If    "${companion_params}[cutter_id]" != "${None}" and "smartphone" not in "${tc_variables}"    CHECKSET USB STATUS    ${companion_params}[cutter_id]    unplugged
    Run Keyword If    "smartphone" not in "${tc_variables}"    Return From Keyword
    Run Keyword if    "${console_logs}" == "yes"     Log    **** STOP COMPANION TOOLS ****    console=yes
    SET ADB SMARTPHONE STATE    disconnect    ${companion_params}[adb_id]

PAIR IVI AND PHONE
    [Arguments]    ${smartphone_adb_id}    ${hmi_check}=False
    [Documentation]    Pair ivi and phone
    ${output} =    DELETE FOLDER OR FILE    /sdcard/*.xml
    ${output}    ${status}    ${error} =    shellCmd    adb -s ${smartphone_adb_id} shell rm /sdcard/*.xml

    ${phone_name} =    GET PHONE NAME    ${smartphone_adb_id}
    ${pair_status} =    Run Keyword And Ignore Error    CHECK PAIRED CONNECTION    ${phone_name}
    IF    ${hmi_check} == True
        CREATE APPIUM DRIVER
        Run Keyword And Continue On Failure    RECONFIRM DATA PRIVACY
        GO BT MENU APPIUM    ${ivi_adb_id}
        ${phone_is_paired} =    Run Keyword If     "${ivi_my_feature_id}" == "MyF3"    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']   10
        ${pair_status} =    Set Variable if    "${phone_is_paired}" != "True"    FAIL    PASS
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10
        IF    "${ivi_my_feature_id}" != "MyF3"
            Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Pair new device']    10
        END
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${phone_name}']    10
        ${phone_is_paired} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']   10
        ${pair_status} =    Set Variable if    "${phone_is_paired}" != "True"    FAIL    PASS
        Return From Keyword If     "${pair_status}" == "PASS" and "${result}" == "True"
        REMOVE APPIUM DRIVER
    END
    Return From Keyword If     """PASS""" in """${pair_status}"""
    IF    "${ivi_my_feature_id}" == "MyF3"
        CREATE APPIUM DRIVER
        CREATE APPIUM DRIVER    DeviceManager    smartphone    ${smartphone_adb_id}    ${mobile_platform_version}
        Log To Console    ====Enable BT Discoverable on smartphone====
        CHECK AND SWITCH DRIVER     ${mobile_driver}
        Run Keyword And Ignore Error    SET BT DISCOVERABLE ON MOBILE    ${smartphone_adb_id}    ${BT_pair['bt_enable_discoverable']}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']    retries=10
        Run Keyword If    "${result}" == "True"    APPIUM_TAP_XPATH    //*[@text='Allow']
        CHECK AND SWITCH DRIVER    ${ivi_driver}
        GO BT MENU APPIUM    ${ivi_adb_id}
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Pair new device']    10
        APPIUM_WAIT_FOR_XPATH    //*[@text='${phone_name}']    10
        TAP_ON_ELEMENT_USING_XPATH    //*[@text='${phone_name}']    10
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Pair']    10
        Run Keyword If    "${result}"=="True"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Pair']    10
        CHECK AND SWITCH DRIVER    ${mobile_driver}
        TAP_ON_ELEMENT_USING_XPATH    //*[@text='Pair']    10
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10
        CHECK AND SWITCH DRIVER    ${ivi_driver}
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10
        REMOVE APPIUM DRIVER
    ELSE
        Run Keyword And Ignore Error    CLEAR APPIUM PACKAGES    ${ivi_adb_id}
        Run Keyword And Ignore Error    CLEAR APPIUM PACKAGES    ${smartphone_adb_id}

        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Pair new device"    ${smartphone_adb_id}    phone
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Pair new device"    ${ivi_adb_id}    ivi
        Sleep     5
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Add new device"    ${ivi_adb_id}    ivi
        Sleep     5
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "${phone_name}"    ${ivi_adb_id}    ivi
        Sleep     5
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Pair"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Start"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Pair"    ${smartphone_adb_id}    phone
        Sleep     5
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Pair"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Start"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Allow"    ${smartphone_adb_id}    phone
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Start"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Yes"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Allow"    ${smartphone_adb_id}    phone
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Allow"    ${smartphone_adb_id}    phone
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Allow"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Allow"    ${ivi_adb_id}    ivi
        Sleep     2
        Run Keyword And Ignore Error    CHECK TEXT ON DEVICE AND TAP    "Yes"    ${ivi_adb_id}    ivi
    END
    CHECK PAIRED CONNECTION    ${phone_name}
    IF    ${hmi_check} == True
        CREATE APPIUM DRIVER
        GO BT MENU APPIUM    ${ivi_adb_id}
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${phone_name}']    10
        Should Be True    ${result}
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']   10
        Should Be True    ${result}
        REMOVE APPIUM DRIVER
    END

GET PHONE NAME
    [Arguments]    ${smartphone_adb_id}
    [Documentation]   Get phone bluetooth name
    ${bt_phone_name}    ${status}    ${error} =    shellCmd    adb -s ${smartphone_adb_id} shell dumpsys bluetooth_manager | grep name:
    ${bt_phone_name} =    String.Get Regexp Matches    ${bt_phone_name}    name:${SPACE}.+
    ${bt_phone_name} =    Get From List    ${bt_phone_name}    0
    ${bt_phone_name} =    Convert To String    ${bt_phone_name}
    ${bt_phone_name} =    Remove String    ${bt_phone_name}    name:    ${EMPTY}
    ${bt_phone_name} =    Set Variable     ${bt_phone_name.strip()}
    [Return]    ${bt_phone_name}

END CALL BETWEEN PHONES
    [Documentation]   end phone call
    APPIUM_PRESS_KEYCODE    ${KEYCODE_ENDCALL}

CHECK PAIRED CONNECTION
    [Arguments]    ${phone_name}
    [Documentation]    The method checks if the IVI is connected to phone
    ${output}     ${status}    ${error} =    shellCmd    adb -s ${ivi_adb_id} shell uiautomator dump /sdcard/window_dump_pair_status.xml
    ${output}     ${status}    ${error} =    shellCmd    adb -s ${ivi_adb_id} pull /sdcard/window_dump_pair_status.xml /tmp/window_dump_pair_status.xml
    ${verdict} =    FORMAT XML FILE    /tmp    window_dump_pair_status
    Should Be True    ${verdict}
    ${verdict_phone_name}    ${result} =    CHECK WORD IN FILE    ${phone_name}    /tmp    window_dump_pair_status_format.xml
    ${verdict_connection}    ${result} =    CHECK WORD IN FILE    enabled="true    /tmp    window_dump_pair_status_format.xml
    Should Be True    ${verdict_phone_name}
    Should Be True    ${verdict_connection}

CHECK TEXT ON DEVICE AND TAP
    [Arguments]    ${word}     ${device_id}     ${device_type}
    [Documentation]    The method checks a word on the device screen, if the word is present press it
    ${output}     ${status}    ${error} =    shellCmd    adb -s ${device_id} shell uiautomator dump /sdcard/window_dump_${device_type}.xml
    ${output}     ${status}    ${error} =    shellCmd    adb -s ${device_id} pull /sdcard/window_dump_${device_type}.xml /tmp/window_dump_${device_type}.xml
    ${verdict} =    FORMAT XML FILE    /tmp    window_dump_${device_type}
    Should Be True    ${verdict}
    ${verdict}    ${result} =    CHECK WORD IN FILE    ${word}    /tmp    window_dump_${device_type}_format.xml
    ${x1}    ${y1}    ${x2}    ${y2} =    EXTRACT BOUNDS     ${result}
    ${set_var} =     Set Variable    -s ${device_id} shell input tap ${x1} ${y1}
    ${output}     ${status}    ${error} =    shellCmd    adb -s ${device_id} shell input tap ${x1} ${y1}

CLEAR APPIUM PACKAGES
    [Arguments]    ${device_id}
    [Documentation]    The method return a appium packages and send command to clear these
    ${device_packages}     ${status}    ${error} =    shellCmd    adb -s ${device_id} shell pm list packages appium
    ${device_packages} =     Remove String    ${device_packages}    package:    ${EMPTY}
    ${device_packages} =     Split String     ${device_packages}
    ${size_packages} =     Get Length      ${device_packages}
    FOR    ${element}    IN RANGE    ${size_packages}
        ${output}     ${status}    ${error} =    shellCmd    adb -s ${device_id} shell pm clear ${device_packages}[${element}]
    END

DO CALL
    [Arguments]    ${device_id}    ${phone_number}
    [Documentation]    Start a call to a phone number from ${device_id}
    ${output}     ${status}    ${error} =    shellCmd    adb -s ${device_id} shell am start -a ${BT_pair['start_call']}:${phone_number}

SET ANDROID AUTO PERMISSIONS
    [Arguments]    ${dut_id}
    [Documentation]  Allow Android Auto permissions on ${dut_id}
    ...    ${dut_id} adb id of reference smartphone
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    LAUNCH APPIUM APP ON SMARTPHONE    ${dut_id}    &{smartphone_settings}
    DO WAIT    500
    APPIUM_TAP_XPATH    ${app_notifications}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${app_info}    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH   ${app_info}
    APPIUM_TAP_XPATH    ${android_auto}
    APPIUM_TAP_XPATH    ${permissions}
    APPIUM_TAP_XPATH    ${calendar_xpath}
    APPIUM_TAP_XPATH    ${allow}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_TAP_XPATH    ${call_logs}
    APPIUM_TAP_XPATH    ${allow}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_TAP_XPATH    ${contacts}
    APPIUM_TAP_XPATH    ${allow}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_TAP_XPATH    ${location}
    APPIUM_TAP_XPATH    ${allow_while_app_using}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_TAP_XPATH    ${microphone}
    APPIUM_TAP_XPATH    ${allow_while_app_using}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    APPIUM_TAP_XPATH    ${sms}
    APPIUM_TAP_XPATH    ${allow}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

CHECK BT STATUS ON MOBILE
    [Arguments]   ${mobile_adb_id}
    [Documentation]    Check if the bluetooth status on mobile is ON
    ${bt_state} =    OperatingSystem.Run    adb -s ${mobile_adb_id} shell dumpsys bluetooth_manager | grep "state: ON"
    ${verdict} =     Run Keyword If       "${bt_state.lower()}" == "state: on"      Set Variable      True
    ...      ELSE      Set Variable      False
    [Return]    ${verdict}

SET BT STATUS ON MOBILE
    [Arguments]    ${mobile_adb_id}    ${app}
    [Documentation]    set the bt status on smartphone(enable or disable)
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell am start -a ${app}

SET BT DISCOVERABLE ON MOBILE
    [Arguments]    ${mobile_adb_id}    ${app}
    [Documentation]    set the bt status on smartphone(enable or disable)
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell am start -a ${app}

CHECK AND SET PHONE WIFI
    [Arguments]    ${status}
    [Documentation]    Check WiFi status on phone and if not, set it accordingly
    ${output_wifi} =     Run    adb -s ${smartphone_adb_id} shell dumpsys wifi | grep "Wi-Fi is"
    ${wifi_enable} =     Evaluate      "enable" in "${output_wifi}" and "${status.lower()}"=="on"
    ${wifi_disable} =     Evaluate      "disable" in "${output_wifi}" and "${status.lower()}"=="off"
    Return From Keyword If    "${wifi_enable}" == "True" or "${wifi_disable}" == "True"      ${\n}${output_wifi}
    IF      "${status.lower()}"=="on"
        Run      adb -s ${smartphone_adb_id} shell svc wifi enable
        Sleep      2
        ${output_wifi} =     Run    adb -s ${smartphone_adb_id} shell dumpsys wifi | grep "Wi-Fi is"
        ${wifi_enable} =     Evaluate      "enable" in "${output_wifi}"
        Should Be True      ${wifi_enable}
        Log     ${\n}${output_wifi}    console=yes
    ELSE
        Run      adb -s ${smartphone_adb_id} shell svc wifi disable
        Sleep      2
        ${output_wifi} =     Run    adb -s ${smartphone_adb_id} shell dumpsys wifi | grep "Wi-Fi is"
        ${wifi_enable} =     Evaluate      "disable" in "${output_wifi}"
        Should Be True      ${wifi_enable}
        Log     ${\n}${output_wifi}    console=yes
    END

GET MOBILE PLATFORM VERSION
    [Documentation]    Get the platform version of the mobile platform
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: returns the version of the mobile platform
    ${moblie_platform_version} =    OperatingSystem.Run    adb -s ${mobile_adb_id} shell getprop ro.build.version.release
    [Return]    ${moblie_platform_version}
