#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Bluetooth Related Meta-Keywords Library
Library           rfw_services.ivi.AndroidBluetoothLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_libraries.connectivity.BluetoothCtlLib

Resource          ../../Smartphone/myrenault.robot
Resource          ../../Smartphone/mobile_adb_command.robot

Variables         ${CURDIR}/../KeyCodes.yaml

*** Variables ***
${bt_device}         ${none}
${BLUETOOTH_STATUS}    BLUETOOTH_STATUS
${STATUS} =    status
${MESSAGE} =    message
${EXTRA_ARG} =    DEVICE_TO_FIND
${CHECK_BLUETOOTH_PERMISSIONS}    CHECK_BLUETOOTH_PERMISSIONS
${bluetooth_button}       //*[@text='Bluetooth']
${more_button}            //*[@text='More' or @text='MORE']
${bluetooth_switch_10}    //*[@resource-id='com.android.car.settings:id/car_ui_toolbar_menu_item_switch']
${bluetooth_switch_12}    //*[@content-desc='Bluetooth toggle switch']
${bluetooth_switch}    //*[@resource-id='com.android.car.settings:id/car_ui_toolbar_menu_item_switch']
${pair_new_device}        //*[@text='Pair new device']
${vehicle_name}           //*[@text='Vehicle name']
# ${ok_button}              //*[@text='OK']
${ok_button_for_bluetooth_pair}              //*[@resource-id='com.alliance.engineering.btengsetting:id/btn_ok' or @text='Pair']
${connected_device}       //*[@text='Connected']
${paired_devices}         //*[@text='Paired devices']
${disconnect_device}      //*[@text='Your vehicle will disconnect from']
${ok_button_appium}       //*[@resource-id='com.alliance.engineering.btengsetting:id/btn_ok']
${bt_device_settings}     //*[@resource-id='android:id/widget_frame']
${forget_devices}         //*[@text='Forget']
&{Bluetooth_show_devices}           package=com.android.settings    activity=com.android.settings.Settings$BluetoothSettingsActivity
&{smartphone_bluetooth}    package=com.android.settings    activity=.Settings
&{smartphone_music}       package=com.google.android.apps.nbu.files    activity=.home.HomeActivity
${tool_bar}               //*[@resource-id='com.android.car.media:id/car_ui_toolbar_logo']
${app_name}               //*[@text='Bluetooth Audio']
${Bluetooth_devices}      //*[@text='Connected devices']
${song}                   //*[@resource-id='com.google.android.apps.nbu.files:id/title']
${audio_files}            //*[@text='Audio']
${Pair}                   //*[@text='Pair']
${settings_button}        //*[@resource-id='com.android.settings:id/settings_button' or @resource-id='com.android.settings:id/deviceDetails']
${smartphone_forget}             //*[@text='Forget' or @text='Unpair']
${smartphone_forget_device}     //*[@text='Forget device' or @text='Unpair']
${play_pause_button}        //*[@resource-id='com.android.car.media:id/play_pause_stop']
${conn_pref}              //*[@text='Connection preferences']
${bluetooth}              //*[@text='Bluetooth']
${bluetooth_status_button}       //*[@resource-id='com.android.settings:id/switch_text']
${allow}                  //*[@text='Allow']
${unpair_smartphone}       //*[@text='Connected for calls and audio']
${my_car}                 //*[@text='MY_CAR']
${smartphone_bluetooth_button}    //*[@text='Connections' or @text='Connected devices' or @text='Paired devices']
${bt_ressource_id}        android:id/summary
&{nexus_home_page}        package=com.google.android.apps.nexuslauncher    activity=.NexusLauncherActivity
${apk_name}               MatrixAgent-1.0.apk
${apk_package}            com.renault.matrixandroidagent
${download_url}           matrix/artifacts/images/
${ok_img}                 ok.png
${parameter_img}          parameter.png

*** Keywords ***
CHECK BT STATUS
    [Arguments]    ${target_id}    ${state}
    [Documentation]    Check the Bluetooth Status of the target device using agent
    Log To Console    Checking Bluetooth target:${target_id} is: ${state} using agent
    DO INSTALL APP    ${ivi_adb_id}    ${apk_name}
    INITIALISE_MATRIX_AGENT_LIBRARY
    ${result} =    EXEC AGENT COMMAND    ${BLUETOOTH_STATUS}
    ${value} =    GET FROM RESULT    ${result}    ${STATUS}
    Run Keyword If    "${state}" == "on"    Should Be True    "${value}" == "true"    Bluetooth is not enabled
    Run Keyword If    "${state}" == "off"    Should Be True    "${value}" == "false"    Bluetooth is not disabled

SET BT STATUS
    [Arguments]    ${target_id}    ${state}
    [Documentation]    Set and check the Bluetooth State of the ${target_id} using agent
    INITIALISE_MATRIX_AGENT_LIBRARY
    Run Keyword If    "${state}" == "enable"    SET LOCATION MODE    IVI    on
    Run Keyword If    "${state}" == "disable"    SET LOCATION MODE    IVI    off
    ${result_enable} =    Run Keyword If    "${state}" == "enable"    EXEC AGENT COMMAND    BLUETOOTH_ON
    ${enable_message} =    Run Keyword If    "${state}" == "enable"    GET FROM RESULT    ${result_enable}    ${MESSAGE}
    ${result_disable} =    Run Keyword If    "${state}" == "disable"    EXEC AGENT COMMAND    BLUETOOTH_OFF
    ${disable_message} =    Run Keyword If    "${state}" == "disable"    GET FROM RESULT    ${result_disable}    ${MESSAGE}
    Run Keyword If    "${state}" == "disable"    Should Not Be True    "${disable_message}" == "Try to turn Bluetooth on"    Expected bluetooth message not received

CHECKSET BT STATUS
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check and set the Bluetooth State of the DUT
    Log To Console    Setting ${target_id} Bluetooth state: ${status}
    ${bluetooth_status_ivi} =    Run Keyword If    "${target_id}" == "${ivi_adb_id}"    CHECK BT STATUS    ${target_id}    ${status}
    ${bluetooth_status_bt_device} =    Run Keyword If    "${target_id}" == "${bt_device}"    CHECK BT STATUS    ${target_id}    ${status}
    ${ivi_result_true} =    Run Keyword If    "${target_id}" == "${ivi_adb_id}" and "${bluetooth_status_ivi}" == "[True, None]"    Log To Console    Bluetooth is already ${status} on ${target_id}    ${ivi_adb_id}
    ${ivi_result_false} =    Run Keyword If    "${target_id}" == "${ivi_adb_id}" and "${bluetooth_status_ivi}" == "[False, None]"    SET BT STATUS    ${status}    ${ivi_adb_id}
    ${bt_device_result_true} =    Run Keyword If    "${target_id}" == "${bt_device}" and "${bluetooth_status_bt_device}" == "[None, True]"    Log To Console    Bluetooth is already ${status} on ${target_id}    ${ivi_adb_id}
    ${bt_device_result_false} =    Run Keyword If    "${target_id}" == "${bt_device}" and "${bluetooth_status_bt_device}" == "[None, False]"    SET BT STATUS    ${status}    ${bt_device}
    Run Keyword If    "${target_id}" == "pchost" and "${status}" == "on"    POWER ON HOST BLUETOOTH
    Run Keyword If    "${target_id}" == "pchost" and "${status}" == "off"    POWER OFF HOST BLUETOOTH
    Run Keyword If    "${target_id}" == "pchost"    Sleep    1   # Allow Bluetooth status to refresh
    ${result} =    Run Keyword If    "${target_id}" != "pchost"    CHECK BT STATUS    ${target_id}    ${status}
    Run Keyword If    "${target_id}" == "${ivi_adb_id}"    Should Be True    ${result}[0]    Bluetooth is not ${status} on device: ${target_id}
    Run Keyword If    "${target_id}" == "${bt_device}"    Should Be True    ${result}[1]    Bluetooth is not ${status} on device: ${target_id}

CHECKSET HMI BT UNPAIR
    [Arguments]    ${target_id}    ${bt_name}
    [Documentation]    Unpair either a specific Bluetooth Device, or all Bluetooth Devices
    Log To Console    Unpair ${bt_name} device(s) from device: ${target_id}
    ${result} =     UNPAIR DEVICES    ${bt_name}    ${target_id}
    Should Be True    ${result}    ${bt_name} could not be unpaired from ${target_id}

UNPAIR DEVICES 
    [Arguments]        ${bt_name}      ${target_id}
    [Documentation]    Function to remove all paired devices from the DUT.
    ${verdict} =  Set Variable    False
    IF  "${target_id}" == "${ivi_adb_id}"
        ${res} =    Run Keyword And Return Status       rfw_services.ivi.AndroidBluetoothLib.Check Bt Status      on 
        IF   ${res} == False 
            ${verdict} =  Set Variable    False    
        ELSE
            APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
            LAUNCH APP APPIUM    Settings
            ${output}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url}${parameter_img}    ${CURDIR}
            Should be true    ${output}    Failed to download '${download_url}${parameter_img}' from artifactory
            APPIUM_TAP_XPATH    ${bluetooth}
            ${existed_device} =  APPIUM_WAIT_FOR_XPATH    ${paired_devices}    10
            IF  ${existed_device} 
                TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}     
                Sleep    5
                APPIUM_TAP_XPATH    ${forget_devices}
                ${verdict} =  Set Variable    True
            ELSE
                ${verdict} =  Set Variable    True
                Log To Console    No device connected on ${target_id}
            END
        END
    ELSE IF  "${target_id}" == "${bt_device}"
        CHECK AND SWITCH DRIVER    ${mobile_driver}
        CONFIGURE SMARTPHONE WITH APPIUM     ${app_smartphone}
        CHECKSET BT STATE SMARTPHONE APPIUM    ${bt_device}   on    ${app_smartphone}
        Sleep    5
        ${existed_device_on_smartphone} =  APPIUM_WAIT_FOR_XPATH    ${paired_devices}    10
        IF  ${existed_device_on_smartphone} 
            APPIUM_TAP_XPATH    ${unpair_smartphone} 
            ${verdict} =  Set Variable    True
        END
    END 
   [return]        ${verdict}

SET HMI BT SCAN
    [Arguments]    ${target_id}    ${bt_name}    ${status}
    [Documentation]    Perform a scan on the ${target_id} via HMI and check that ${bt_name} is present/absent
    Log To Console    Device: ${target_id} is preparing to scan for Bluetooth device: ${bt_name}
    ${ivi_result} =    Run Keyword If    "${target_id}" == "${ivi_adb_id}"    BLUETOOTH SCAN APPIUM    ${target_id}    ${bt_name}
    ${bt_device_result} =    Run Keyword If    "${target_id}" == "${bt_device}"    BLUETOOTH SCAN SMARTPHONE APPIUM   ${bt_name}    ${status}    ${timeout}=60    &{smartphone_home_page}
    Run Keyword If    "${target_id}" == "${ivi_adb_id}" and "${status}" == "present"    Should Be True    ${ivi_result}    ${bt_name} was not discovered by ${target_id}
    Run Keyword If    "${target_id}" == "${ivi_adb_id}" and "${status}" == "absent"    Should Not Be True    ${ivi_result}    ${bt_name} was discovered by ${target_id}
    Run Keyword If    "${target_id}" == "${bt_device}" and "${status}" == "present"    Should Be True    ${bt_device_result}    ${bt_name} was not discovered by ${target_id}
    Run Keyword If    "${target_id}" == "${bt_device}" and "${status}" == "absent"    Should Not Be True    ${bt_device_result}    ${bt_name} was discovered by ${target_id}

BLUETOOTH SCAN SMARTPHONE APPIUM
    [Arguments]    ${device_to_find}    ${status}     ${timeout}=60     &{smartphone_home_page}
    Log to Console   BT Scanning for ${device_to_find} device
    Sleep   5
    ${output} =    GET PROPERTY    ro.product.manufacturer
    ${smartphone_home_page} =    Set Variable If    "Xiaomi" in "${output}"    &{redmi_home_page}
    ...    "Google" in "${output}"    &{nexus_home_page}
    LAUNCH APPIUM APP ON SMARTPHONE    ${bt_device}    &{smartphone_home_page}
    GO SMARTPHONE BT MENU APPIUM    ${bt_device}
    APPIUM_TAP_XPATH    ${bluetooth}
    ${existed} =  APPIUM_WAIT_FOR_XPATH    ${paired_devices}    30
    Should Be True    ${existed}    Bluetooth Scanning Menu cannot be found
    ${device_to_find_appium}    Set Variable    //*[@text='${device_to_find}']
    ${scanning_timeout} =    Convert To Integer    ${timeout}
    ${existed} =    APPIUM_WAIT_FOR_XPATH    ${device_to_find_appium}    ${scanning_timeout}
    Log To Console    BT Scan result: ${existed}
    Run Keyword If    "${status}" == "present"    Should Be True    "${existed}" == "True"    Bluetooth Device: ${device_to_find} was not discovered
    Run Keyword If    "${status}" == "absent"    Should Not Be True    "${existed}" == "True"    Bluetooth Device: ${device_to_find} is still visible

CHECKSET HMI BT NAME
    [Arguments]    ${target_id}    ${bt_name}
    [Documentation]    Checks/Sets that the friendly Bluetooth name of ${target_id} is set to ${bt_name}
    Log To Console    Checking/Setting that the friendly Bluetooth name of ${target_id} is set to ${bt_name}
    LAUNCH APP APPIUM    Settings
    APPIUM_TAP_XPATH    ${bluetooth_button} 
    APPIUM_TAP_XPATH    ${pair_new_device}    30
    ${getted_txt} =     APPIUM_GET_TEXT_BY_ID     ${bt_ressource_id}
    IF  "${getted_txt}" != "${bt_name}"
        APPIUM_TAP_XPATH    ${vehicle_name}    30
        Sleep    5s
        ${length} = 	Get Length    ${getted_txt}
        FOR  ${var}    IN RANGE    ${length}
            APPIUM_PRESS_KEYCODE   ${KEYCODE_DELETE}
        END
        OperatingSystem.Run    adb -s ${ivi_adb_id} shell input text ${bt_name}
        ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url}${ok_img}    ${CURDIR}
        Should be true    ${verdict}    Failed to download '${download_url}${ok_img}' from artifactory
        TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}     
        Sleep    5
        GO HOME AND CLEAR SETTINGS APP    ${target_id}
    END  

SET HMI BT VISIBILITY
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Set the ${target_id} to be visible or invisible according to ${status}
    Log To Console    Setting ${target_id} to be ${status} to other devices
    # TODO implement below actions until then FAIL the TC. CCAR-63734
    Fail    GOTO BLUETOOTH SETTINGS to be reimplemented. CCAR-63734
    #Run Keyword If    "${target_id}" == "${ivi_adb_id}" and "${status}" == "visible"    rfw_services.ivi.AndroidBluetoothLib.GOTO BLUETOOTH SETTINGS
    Run Keyword If    "${target_id}" == "${ivi_adb_id}" and "${status}" == "invisible"    GO HOME SCREEN APPIUM
    # TODO implement below actions until then FAIL the TC. CCAR-63734
    Fail    ENABLE VISIBILITY to be reimplemented. CCAR-63734
    #Run Keyword If    "${target_id}" == "${bt_device}" and "${status}" == "visible"    rfw_services.ivi.BluetoothReferenceLib.ENABLE VISIBILITY    ${target_id}
    #Run Keyword If    "${target_id}" == "${bt_device}" and "${status}" == "invisible"    rfw_services.ivi.ReferencePhoneLib.GO HOME SECURE    ${target_id}

SET BT VISIBILITY
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Set the ${target_id} to be visible or invisible according to ${status}
    Log To Console    Setting ${target_id} to be ${status} to other devices
    Run Keyword If    "${target_id}" == "pchost" and "${status}" == "visible"    MAKE DISCOVERABLE HOST BLUETOOTH
    Run Keyword If    "${target_id}" == "pchost" and "${status}" == "invisible"    MAKE UNDISCOVERABLE HOST BLUETOOTH

CHECK BT PAIRED LIST
    [Arguments]    ${target_id}    ${bt_name}    ${status}
    [Documentation]    Check that the ${bt_name} is present/absent on the ${target_id} according to the value of ${status}
    Log To Console    Checking that ${bt_name} is ${status} on ${target_id}
    ${check_result} =    rfw_services.ivi.AndroidBluetoothLib.IS DEVICE BT PAIRED    ${bt_name}    ${target_id}
    Run Keyword If    "${status}" == "present"    Should Be True    ${check_result}    ${bt_name} is not present on ${target_id}
    Run Keyword If    "${status}" == "absent"    Should Not Be True    ${check_result}    ${bt_name} is present on ${target_id}

GET BT NAME
    [Arguments]    ${target_id}
    [Documentation]    Get the friendly name of the ${target_id} and return it so it can be used by other keywords
    # ${status}    ${pc_hostname} =    rfw_services.ivi.AndroidDriverLib.GET HOST NAME
    # Should Be True    ${status}    Hostname not retrieved

    ${pc_hostname} =    GET NAME HOST BLUETOOTH
    Log To Console    Bluetooth Controller Name: ${pc_hostname}
    Set Suite Variable    ${pc_hostname}

SET HOST PINCODE PAIRING
    SET AGENT OFF ON HOST BLUETOOTH
    SEND BLUETOOTHCTL COMMAND    agent KeyboardDisplay
    SET DEFAULT AGENT ON HOST BLUETOOTH

SET HOST SILENT PAIRING
    SET AGENT OFF ON HOST BLUETOOTH
    SILENT PAIRING ON HOST BLUETOOTH
    SET DEFAULT AGENT ON HOST BLUETOOTH

SET BT STATUS UI
    [Arguments]    ${ivi_adb_id}   ${status}
    [Documentation]    Change the BT status by UI
    SET BLUETOOTH UI    ${status}

CHECK BT STATUS BY COMMAND
    [Arguments]    ${ivi_adb_id}   ${status}
    [Documentation]    Check the BT status
    ${ret_bt} =    rfw_services.ivi.AndroidBluetoothLib.Check Bt Status    ${status}
    [return]    ${ret_bt}

GO BT MENU APPIUM
    [Arguments]    ${dut_id}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    GO HOME AND CLEAR SETTINGS APP    ${dut_id}
    LAUNCH APP APPIUM    Settings
    IF    "${ivi_my_feature_id}" != "MyF3"
        ${result} =   APPIUM_WAIT_FOR_XPATH    ${more_button}    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        Run Keyword If    "${result}" == "True"    TAP BY XPATH    ${more_button}
    END
    Log To Console    Bluetooth Button: ${bluetooth_button}
    APPIUM_TAP_XPATH    ${bluetooth_button}     10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${pair_new_device}    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Should Be True    "${result}" == "True"    Bluetooth Menu cannot be displayed
    [Return]    ${result}

CHECKSET BT STATUS APPIUM
    [Arguments]    ${dut_id}    ${status}
    [Documentation]    Check and set the Bluetooth State of the DUT
    Log To Console    Setting Bluetooth state: ${status}
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    GO BT MENU APPIUM    ${dut_id}
    sleep    05
    ${output} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Bluetooth will turn on to pair']
    ${isToggleEnabled} =      Set Variable If    "${output}" == "${True}"    OFF    ON
    Log to Console   BT toggle status check: ${isToggleEnabled}
    Run Keyword If    "${isToggleEnabled}" == "OFF" and "${status}" == "on"    TAP BY XPATH    ${bluetooth_switch_${platform_version}}
    Run Keyword If    "${isToggleEnabled}" == "ON" and "${status}" == "off"    TAP BY XPATH    ${bluetooth_switch_${platform_version}}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}

BLUETOOTH SCAN APPIUM
    [Arguments]    ${device_to_find}    ${status}    ${timeout}=60
    Log to Console   BT Scanning for ${device_to_find} device
    Sleep   5
    LAUNCH APP APPIUM    Settings
    APPIUM_TAP_XPATH    ${bluetooth_button} 
    APPIUM_TAP_XPATH    ${pair_new_device}    30
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${vehicle_name}    30
    Should Be True    "${result}" == "True"    Bluetooth Scanning Menu cannot be found
    ${device_to_find_appium}    Set Variable    //*[@text='${device_to_find}']
    ${scanning_timeout} =    Convert To Integer    ${timeout}
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${device_to_find_appium}    ${scanning_timeout}
    Log To Console    BT Scan result: ${result}
    Run Keyword If    "${status}" == "present"    Should Be True    "${result}" == "True"    Bluetooth Device: ${device_to_find} was not discovered
    Run Keyword If    "${status}" == "absent"    Should Not Be True    "${result}" == "True"    Bluetooth Device: ${device_to_find} is still visible

BLUETOOTH PAIR APPIUM
    [Arguments]    ${device_to_pair}
    Log to Console   BT Pairing for ${device_to_pair} device
    ${device_to_pair_appium}    Set Variable    //*[@text='${device_to_pair}']
    TAP BY XPATH    ${device_to_pair_appium}
    Sleep    5
    BLUETOOTH ACCEPT PAIRING APPIUM

CHECK BLUETOOTH PAIRING STATUS
    [Arguments]    ${dut_id}    ${device_to_pair}    ${expected_result}    ${direction}=down
    ...    ${scroll_tries}=10

    # GO BT MENU APPIUM    ${dut_id}
    Log to Console   Check BT Pairing for ${device_to_pair} device
    ${device_to_pair_appium}    Set Variable    //*[@text='${device_to_pair}']
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${paired_devices}    30    ${direction}    ${scroll_tries}
    Should Be True    "${result}" == "True"    No device already paired
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${device_to_pair_appium}    30    ${direction}    ${scroll_tries}
    Log To Console    Device ${device_to_pair} Paired result: ${result}
    Run Keyword If    "${expected_result}" == "paired"    Should Be True    "${result}" == "True"    Bluetooth Device: ${device_to_pair} is not paired
    Run Keyword If    "${expected_result}" == "unpaired"    Should Not Be True    "${result}" == "True"    Bluetooth Device: ${device_to_pair} is already paired

BLUETOOTH FORGET DEVICE
    Log to Console   Forget paired device
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    Run Keyword and Ignore Error    GO BT MENU APPIUM    ${ivi_adb_id}
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${paired_devices}    30
    IF    "${result}" == "False"
        Log To Console    No paired device under bluetooth
    ELSE
        Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    APPIUM_TAP_XPATH    ${bt_device_settings}    30
        Sleep    5
        ${result}=    Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected' or @text='${smartphone_bt_name}']    30
        Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${result}"=="False"    Run Keywords    APPIUM_TAP_XPATH    //*[@text='${smartphone_bt_name}']    30
        ...    AND     APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    30
        Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${result}"=="True"    APPIUM_TAP_XPATH    //*[@text='Connected' or @text='${smartphone_bt_name}']    30
        APPIUM_TAP_XPATH    ${forget_devices}    30
        Sleep    5
    END
    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    Sleep    2s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_HOME}

BLUETOOTH ACCEPT PAIRING APPIUM
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${ok_button_for_bluetooth_pair}    30
    Run Keyword If    "${result}" == "True"    TAP BY XPATH    ${ok_button_for_bluetooth_pair}
    Sleep    5

GO BT MUSIC MENU ON IVI
    [Arguments]    ${dut_id}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}    ${tap_play_button}=False
    [Documentation]   To open bluetooth music app on ivi & tap on play button if ${tap_play_button}=True
    ...    ${dut_id} name of dut-id
    IF    "${tap_play_button}" == "True"
        GO BT MENU APPIUM    ${dut_id}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        Sleep    2
        Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    TAP_ON_ELEMENT_USING_XPATH    ${bluetooth_switch}    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        sleep    2
        Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    TAP_ON_ELEMENT_USING_XPATH    ${bluetooth_switch}    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        Sleep    5
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        APPIUM_WAIT_FOR_XPATH    //*[@text='${smartphone_bt_name}']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        ${phone_is_connected} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    20   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        Run Keyword If    "${phone_is_connected}" != "True"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${smartphone_bt_name}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        IF    "${ivi_my_feature_id}" == "MyF3"
            Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Connect']    10   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        ELSE
            Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        END
        Sleep    5
        IF    "${ivi_my_feature_id}" == "MyF3"
            LAUNCH APP APPIUM    MediaSource2
        ELSE
            LAUNCH APP APPIUM    MediaSource
        END
        TAP_ON_ELEMENT_USING_XPATH    //*[@text='Bluetooth Audio' or @text='Bluetooth audio']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        Sleep    5
        ${status} =    Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    Run Keyword And Ignore Error    CHECK IMAGE DISPLAYED ON SCREEN    ${dut_id}    playbutton.png
        ${status} =    Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${phone_is_connected}" != "True"    Run Keyword And Ignore Error    CHECK IMAGE DISPLAYED ON SCREEN    ${dut_id}    playbutton_myf3.png
        Sleep    5
        Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    Run Keyword And Ignore Error    CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    playbutton.png
        Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${phone_is_connected}" != "True"    Run Keyword And Ignore Error    CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    playbutton_myf3.png
    END
#    Workaround for MediaDispatcher until ticket CCSEXT-65220 & CCSEXT-65321 will be solved
    IF    "${tap_play_button}" != "True"
        LAUNCH APP APPIUM    MediaDispatcher
        SLEEP    5
        LAUNCH APP APPIUM    MediaSource
        TAP_ON_ELEMENT_USING_XPATH    //*[@text='Bluetooth Audio'or @text='Bluetooth audio']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    END

CHECK BT PAIRED LIST FOR MYF3
    [Arguments]    ${dut_id}    ${status}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]   Checl if the the smartphone is connected/disconnected on the bluetooth list
     IF    "${status}"=="present"
         GO BT MENU APPIUM    ${dut_id}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
         Sleep    2
         APPIUM_WAIT_FOR_XPATH    //*[@text='${smartphone_bt_name}']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
         ${phone_is_connected} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    20   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
         Run Keyword If    "${phone_is_connected}" == "True"    log to console    The smartphone is still connected
     ELSE
       GO BT MENU APPIUM    ${dut_id}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
       ${result}=    APPIUM_WAIT_FOR_XPATH    //*[@text='${smartphone_bt_name}']    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
       Run Keyword If    "${result}" == "False"    log to console    The smartphone is not connect
     END

GO SMARTPHONE BT MENU APPIUM
    [Arguments]    ${dut_id}
    [Documentation]   To open bluetooth app on smartphone
    ...    ${dut_id} name of dut-id
    LAUNCH APPIUM APP ON SMARTPHONE    DeviceManager
    SLEEP    5
    Run Keyword and Ignore error    APPIUM_TAP_XPATH    ${smartphone_bluetooth_button}

ADB SMARTPHONE BLUETOOTH PAIR IVI
    [Documentation]   Open bluetooth app on android phone and pair with an IVI
    LAUNCH_MYRENAULT_APP    com.android.settings    com.android.settings.Settings$BluetoothSettingsActivity
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    MOBILE START INTENT    -n com.android.settings/com.android.settings.Settings$BluetoothSettingsActivity
    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_connections']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_Bluetooth']}    20
    ${BT_status} =    APPIUM_GET_TEXT_USING_XPATH    ${SP_bluetooth['BT_enable']}
    ${BT_status} =    Evaluate    "Off" in """${BT_status}"""
    Run Keyword If    "${BT_status}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_enable']}    10
    Wait Until Keyword Succeeds    60s    5s    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_select_IVI']}    20

    CHECK AND SWITCH DRIVER    ${ivi_driver}
    BLUETOOTH ACCEPT PAIRING APPIUM

    CHECK AND SWITCH DRIVER    ${mobile_driver}
    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_OK']}    20
    Run Keyword and Ignore error    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_allow']}    30
    Run Keyword and Ignore error    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_allow']}    30

    CHECK AND SWITCH DRIVER    ${ivi_driver}
    BLUETOOTH ACCEPT PAIRING APPIUM

    CHECK AND SWITCH DRIVER    ${mobile_driver}
    ${connection_status} =    APPIUM_GET_TEXT_USING_XPATH    ${SP_bluetooth['BT_status']}
    ${connection_status} =    Evaluate    "Connected" in """${connection_status}"""
    Run Keyword If    "${connection_status}" != "True"    Fail    Connection not established

ADB SMARTPHONE BLUETOOTH UNPAIR IVI
    [Documentation]   Unpair smartphone and IVI in BT application
    LAUNCH APPIUM APP ON SMARTPHONE    ${mobile_adb_id}    &{Bluetooth_show_devices}
    TAP_ON_ELEMENT_USING_ID    ${SP_bluetooth['BT_device_details']}    20
    Sleep    1s
    TAP_ON_ELEMENT_USING_XPATH    ${SP_bluetooth['BT_unpair']}    20

CHECKSET BT STATE SMARTPHONE APPIUM
    [Arguments]    ${dut_id}    ${status}    ${app_smartphone}
    [Documentation]   To set bluetooth on/off on smartphone
    ...    ${dut_id} name of dut-id
    ...    ${status} on/off
    IF  "${app_smartphone}" == "HomePage"
        GO SMARTPHONE BT MENU APPIUM    ${dut_id}
        APPIUM_TAP_XPATH    ${bluetooth}
        ${bluetooth_state} =    APPIUM_GET_TEXT_USING_XPATH    ${bluetooth_status_button}
        Run Keyword If    ("${bluetooth_state}" == "On" and "${status}" == "off") or ("${bluetooth_state}" == "Off" and "${status}" == "on")    APPIUM_TAP_XPATH    ${bluetooth_status_button}
    ELSE
        LAUNCH APPIUM APP ON SMARTPHONE    ${app_smartphone}    smartphone
        GO SMARTPHONE BT MENU APPIUM    ${dut_id}
        APPIUM_TAP_XPATH    ${conn_pref}
        APPIUM_TAP_XPATH    ${bluetooth}
        ${bluetooth_state} =    APPIUM_GET_TEXT_USING_XPATH    ${bluetooth_status_button}
        Run Keyword If    ("${bluetooth_state}" == "On" and "${status}" == "off") or ("${bluetooth_state}" == "Off" and "${status}" == "on")    APPIUM_TAP_XPATH    ${bluetooth_status_button}
        Run Keyword If    "${status}" == "on"    APPIUM_TAP_XPATH    ${pair_new_device}
    END 

SET BT VISIBILITY SMARTPHONE APPIUM
    [Arguments]    ${dut_id}    ${status}
    [Documentation]   To set bluetooth visible/invisible on smartphone
    ...    ${dut_id} name of dut-id
    ...    ${status} visible/invisible
    Log To Console    Please make sure Bluetooth visibility is set to ON in smartphone

DO SMARTPHONE BT PAIRING REQUEST ON IVI APPIUM
    [Arguments]    ${dut_id}    ${smartphone_bt_name}
    [Documentation]   To send bluetooth pair request from ivi to smartphone
    ...    ${dut_id} name of dut-id
    ...    ${smartphone_bt_name} name of smartphone bluetooth
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    BLUETOOTH FORGET DEVICE
    GO BT MENU APPIUM    ${dut_id}
    APPIUM_TAP_XPATH     ${pair_new_device}
    APPIUM_TAP_XPATH     //*[@text='${smartphone_bt_name}']    retries=20
    APPIUM_TAP_XPATH     ${Pair}

DO BT PAIRING ACCEPT ON SMARTPHONE APPIUM
    [Arguments]    ${dut_id}
    [Documentation]   To accept bluetooth pair request from ivi
    ...    ${dut_id} name of dut-id
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    APPIUM_TAP_XPATH    ${Pair}    retries=20
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${allow}    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${allow}

DO BLUETOOTH FORGET ON SMARTPHONE APPIUM
    [Arguments]    ${dut_id}
    [Documentation]   To forget bluetooth on smartphone
    ...    ${dut_id} name of dut-id
    GO SMARTPHONE BT MENU APPIUM    ${dut_id}
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${Bluetooth_button}
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${Bluetooth_devices}
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${settings_button}
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${smartphone_forget}
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${smartphone_forget_device}

CHECK BT PAIRED LIST APPIUM
    [Arguments]    ${target_id}    ${bt_name}    ${status}
    [Documentation]    Check that the ${bt_name} is present/absent on the ${target_id} according to the value of ${status}
    Log To Console    Checking that ${bt_name} is ${status} on ${target_id}
    LAUNCH APP APPIUM    Settings
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${bt_name}']    retries=20
    Run Keyword If    "${result}" == "${False}"    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    APPIUM_TAP_XPATH    //*[@text='${bt_name}']
    IF    "${ivi_my_feature_id}" == "MyF3"
        ${check_result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    retries=20
    ELSE
        ${check_result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Your vehicle will disconnect from ${bt_name}.']    retries=20
        ${cancel_result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Cancel']    retries=20
        Run Keyword If    "${cancel_result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Cancel']
    END
    Run Keyword If    "${status}" == "present"    Should Be True    ${check_result}    ${bt_name} is not present on ${target_id}
    Run Keyword If    "${status}" == "absent"    Should Not Be True    ${check_result}    ${bt_name} is present on ${target_id}

GO SMARTPHONE YT MUSIC AND PLAY
    [Arguments]    ${dut_id}
    [Documentation]   Launch YT MUSIC on smartphone and play
    ...    ${dut_id} name of dut-id
    LAUNCH APPIUM APP ON SMARTPHONE    YoutubePlayer    smartphone
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Explore']    retries=20
    Run Keyword If    "${result}" == "${False}"    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    APPIUM_TAP_XPATH     //*[@text='Explore']
    APPIUM_TAP_XPATH     //*[@resource-id='com.google.android.apps.youtube.music:id/action_search_button']
    APPIUM_ENTER_TEXT_XPATH    //*[@resource-id='com.google.android.apps.youtube.music:id/search_edit_text']    Rain, Rain, Go Away Nursery Rhyme
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    APPIUM_TAP_XPATH     //*[@resource-id='com.google.android.apps.youtube.music:id/title' and @text='Rain, Rain, Go Away Nursery Rhyme']

CHECKSET BT CONNECTED ON IVI
    [Arguments]    ${dut_id}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]   check and set the conection between ivi and smartphone
    ...    ${dut_id} name of dut-id
    GO BT MENU APPIUM    ${dut_id}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Sleep    2
    APPIUM_WAIT_FOR_XPATH    //*[@text='${smartphone_bt_name}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    ${phone_is_connected} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    10   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Run Keyword If    "${phone_is_connected}" != "True"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${smartphone_bt_name}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}

CONNECT AND DISCONNECT BLUETOOTH
    [Documentation]    Connect and disconnect the bluetooth connection on ivi
    Run Keyword and Ignore Error    GO BT MENU APPIUM    ${ivi_adb_id}
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${paired_devices}    30
    IF    "${result}" == "False"
        APPIUM_TAP_XPATH    ${bt_device_settings}    30
        Sleep    5
        APPIUM_TAP_XPATH    //*[@text='Connect']   30
        Sleep    5
    ELSE
        APPIUM_TAP_XPATH    ${bt_device_settings}    30
        Sleep    5
        APPIUM_TAP_XPATH    //*[@text='Disconnect']    30
        Sleep    5
        APPIUM_TAP_XPATH    //*[@text='Connect']    30
        Sleep    5
    END
    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE   ${KEYCODE_HOME}
