#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     WiFi Related Meta-Keywords Library
Library           rfw_services.ivi.AndroidWiFiLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Resource          ${CURDIR}/../network.robot
Variables         ${CURDIR}/../KeyCodes.yaml
Library		      OperatingSystem

*** Variables ***
${console_logs}    yes
${target_id}      ${None}
${wifi_icon}      //*[@resource-id='com.android.car.settings:id/tile_text']
${wifi_pass_id}   android:id/edit
${Ok}             //*[@text='OK'or @text='Ok'or @text='ok']
${Cancel}         //*[@text='Cancel']
${wifi_summary}   android:id/summary
${forget_id}      com.android.car.settings:id/car_ui_toolbar_menu_item_text
${more_button}    //*[@text='More']
${cap_more_button}    //*[@text='MORE']
${network_button}    //*[@text='Network & internet' or @text='Network and internet' or @text='Network and Internet']
${wifi_button}    //*[@text='Wi‑Fi']
${onoff_button_12}    //*[@resource-id='android:id/switch_widget']
${onoff_button_10}    //*[@resource-id='com.android.car.settings:id/master_switch']
${forget_wifi_ssid}    //*[@text='FORGET' or @text='Forget']
${network}    //*[@text='network']
${Connected}      //*[@text='Connected']
${download_url_image}    matrix/artifacts/images/
${img_name}    ok.png
${delete_image}    delete.png
${delete_img}    delete_myf2.png
${Text_zone}    //*[@resource-id='android:id/edit']

*** Keywords ***
CHECK WIFI NETWORK APPIUM
    [Arguments]    ${target_id}    ${hotspot_name}    ${status}
    [Documentation]    Check whether the {hotspot_name} is present in the {target_id} list
    Log To Console    CHECK WIFI NETWORK ivi:${target_id} ssid_to_find:${hotspot_name}    status:${status}
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    Log To Console    Scanning for ssid:${hotspot_name}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${hotspot_name}']    retries=10
    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    Run Keyword If    "${status}" == "on"    Should Be True    ${result}    ${hotspot_name} is not present in the ${target_id} list
    Run Keyword If    "${status}" == "off"    Should Not Be True    ${result}    ${hotspot_name} is present in the ${target_id} list

GOTO WI-FI SETTINGS APPIUM
    [Arguments]    ${target_id}
    [Documentation]    Go to wifi settings and activate it using appium
    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    LAUNCH APP APPIUM    Settings
    Sleep    5
    APPIUM_TAP_XPATH    ${network_button}
    ${status_off} =    rfw_services.ivi.AndroidWiFiLib.CHECK WIFI STATUS    off    ${target_id}
    Run Keyword if    "${status_off}" == "True"    APPIUM_TAP_XPATH     ${onoff_button_${platform_version}}
    Run Keyword If    "${platform_version}" == "10"     APPIUM_TAP_XPATH    ${wifi_button}
    ${is_checked} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${onoff_button_${platform_version}}   checked
    Run Keyword If    "${is_checked}" == "false"    APPIUM_TAP_XPATH    ${onoff_button_${platform_version}}
    Sleep    3

CHECK WIFI STATUS
    [Arguments]    ${target_id}    ${status}
    Log To Console    CHECK WIFI STATUS target_id:${target_id} status:${status}
    ${chk_wifi_status} =    rfw_services.ivi.AndroidWiFiLib.CHECK WIFI STATUS    ${status}    ${target_id}
    Should Be True    ${chk_wifi_status}    Wifi is not ${status} on ${target_id}

CHECKSET WIFI STATUS
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check WiFi status on DUT matches ${status} and if not, set it accordingly
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECKSET WIFI STATUS target_id:${target_id} status:${status}
    ${chk_wifi_status} =    rfw_services.ivi.AndroidWiFiLib.CHECK WIFI STATUS    ${status}    ${target_id}
    Return From Keyword If    ${chk_wifi_status} == True
    ${set_wifi_status} =    Run Keyword If    "${status}"=="on"    rfw_services.ivi.AndroidWiFiLib.SET WIFI STATUS    on
    ...    ELSE    rfw_services.ivi.AndroidWiFiLib.SET WIFI STATUS    off
    Should Be True    ${set_wifi_status}    msg=Wifi is not ${status} on ${target_id}
    ${chk_wifi_status} =    rfw_services.ivi.AndroidWiFiLib.CHECK WIFI STATUS    ${status}    ${target_id}
    Should Be True    ${chk_wifi_status}    Wifi is not ${status} on ${target_id}

SET WIFI DISCONNECT APPIUM
    [Arguments]    ${target_id}    ${ssid}
    [Documentation]    Disconnect from a wifi AP/Hotspot
    Log To Console    SET WIFI DISCONNECT target_id:${target_id} ssid:${ssid}
    CLEAR PACKAGE    com.android.car.settings
    APPIUM_PRESS_KEYCODE    ${KEYCODE_HOME}
    DO WAIT    1000
    START INTENT    com.android.car.settings
    DO WAIT    5000
    SWIPE BY COORDINATES    100    300    1900    300
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    DO WAIT    5000
    SWIPE BY COORDINATES    100    300    1900    300
    DO WAIT    5000
    ${curr_status} =    APPIUM_WAIT_FOR_XPATH    //*[@text= 'Wi‑Fi disabled']
    ${tap_status} =    Run Keyword If    "${curr_status}" == "False"    TAP BY XPATH    ${onoff_button}
    DO WAIT    2000
    APPIUM_PRESS_KEYCODE    ${KEYCODE_HOME}
    
SET WIFI FORGET APPIUM
    [Arguments]    ${target_id}    ${ssid}
    [Documentation]    Remove the ${ssid} from saved network list for ${target_id}
    Log To Console    SET WIFI FORGET target_id:${target_id} ssid:${ssid}
    ${forget_ssid_status} =    FORGET NETWORK APPIUM    ${target_id}    ${ssid}
    Should Be True    ${forget_ssid_status}    The ${ssid} could't be removed from saved network list

FORGET NETWORK APPIUM
    [Arguments]    ${target_id}    ${hotspot_name}
    [Documentation]    Remove the ${ssid} from saved network list
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    Log To Console    Scanning for ssid:${hotspot_name}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${hotspot_name}']
    Run Keyword If    "${result}"=="False"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${network}    direction=down
    ${res} =   APPIUM_WAIT_FOR_XPATH    ${Connected}
    sleep    5
    Run Keyword If    "${res}" == "True"    Run Keywords    TAP BY XPATH    ${Connected}
    ...    AND    APPIUM_TAP_XPATH    ${forget_wifi_ssid}
    [return]    ${result}

CHECK WIFI HOTSPOTS LIST
    [Arguments]    ${target_id}    ${empty_status}    ${timeout}=1
    [Documentation]    Check that Wi-Fi NW list is not empty, during {timeout}
    ${now} =    Get Time    epoch
    FOR    ${var}    IN RANGE    ${now}    ${now} + ${timeout}
        Sleep    1
        ${scan_wifi} =     OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys wifiscanner | grep BSSID
        ${wifi_nw_present} =    Evaluate    "BSSID" in """${scan_wifi}"""
        Run Keyword If    ${wifi_nw_present}    Exit For Loop
    END
    Run Keyword If    "${empty_status}" == "notempty"    Should Be True    ${wifi_nw_present}    Wi-Fi hotspot wanted but not found
    Run Keyword If    "${empty_status}" == "empty"    Should Not Be True    ${wifi_nw_present}    Wi-Fi hotspot unwanted but found

DO WIFI CONNECT APPIUM
    [Arguments]    ${target_id}    ${ssid}    ${password}
    [Documentation]    Connect to a wifi AP/Hotspot using Appium
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO WIFI CONNECT using Appium target_id:${target_id} ssid:${ssid} password:????
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    Sleep    5
    ${is_present} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${ssid}']    direction=down    from_xpath_element=//*[@text='Wi‑Fi']    scroll_tries=15
    Run Keyword If    "${is_present}" == "False"    Run Keyword And Ignore Error      APPIUM_TAP_XPATH    //*[@text='Join other network']    20
    ${is_present} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${ssid}']    direction=down    from_xpath_element=//*[@text='Wi‑Fi']   scroll_tries=20
    Should Be True   ${is_present}    ${ssid} is not present in the Wifi List
    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20
    Sleep    10
    ${wait} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connecting…']    30
    Run Keyword If    "${wait}" == "True"    Sleep    20
    ${elem} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    30
    Run Keyword If    "${elem}" == "True"    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20
    Sleep    2
    ${ele_status} =    APPIUM_WAIT_FOR_XPATH    ${forget_wifi_ssid}    retries=10
    Run Keyword If    "${ele_status}" == "True"    Run Keywords    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    ...    AND    Return From Keyword

    ${verdict}    ${image} =    Run Keyword If    "${platform_version}" == "10"    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${delete_img}    ${CURDIR}
    ...    ELSE    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${delete_image}    ${CURDIR}
    Should Be True    ${verdict}    Failed to download from artifactory the delete image for platform_version:${platform_version}
    ${saved} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Saved']    30
    Run Keyword If    "${saved}" == "True"    Run Keywords    TAP IF IMAGE DISPLAYED ON SCREEN    ${image}
    ...    AND    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20

    ${pop_up_present} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='android:id/edit']    retries=5
    Should be true    ${pop_up_present}
    APPIUM_ENTER_TEXT    ${wifi_pass_id}    ${password}
    IF    "${platform_version}" == "10"
        VALIDATE WIFI CONNECTION A10
    ELSE
        VALIDATE WIFI CONNECTION A12
    END
    Sleep    3
    ${is_present} =    APPIUM_WAIT_FOR_XPATH    //*[@text='OK']   20
    Run Keyword If    "${is_present}" == "True"    VALIDATE WIFI CONNECTION A12

    ${wait} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connecting…']    30
    Run Keyword If    "${wait}" == "True"    Sleep    20
    ${saved} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Saved']    30
    ${conn} =    APPIUM_WAIT_FOR_XPATH    xpath=${Connected}    direction=up    scroll_tries=12
    Run Keyword If    "${conn}"=="False" or "${saved}"=="True"    RECONNECT WIFI APPIUM FOR INSTABILITY    ${ssid}    ${password}
    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20
    Sleep    2
    ${conn_status} =    APPIUM_WAIT_FOR_XPATH    ${forget_wifi_ssid}    retries=10
    Should Be True    ${conn_status}    Failed to connect to ${ssid}
    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    CHECK DATA CONNECTIVITY    available

VALIDATE WIFI CONNECTION A12
    [Documentation]    Validate wifi conection AP/Hotspot using Appium on A12
    ENABLE MULTI WINDOWS
    APPIUM_TAP_XPATH  ${Ok}

VALIDATE WIFI CONNECTION A10
    [Documentation]    Validate wifi conection AP/Hotspot using Appium on A10
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${Ok}
    Run Keyword If    ${elem}==True    Run Keywords
    ...    APPIUM_TAP_XPATH    //*[@text='Ok' or @text='OK']
    ...    AND    Return From Keyword
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${img_name}    ${CURDIR}
    Should be true    ${verdict}    Failed to download '${download_url_image}${img_name}' from artifactory
    TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}

LAUNCH VIRTUAL KEYBOARD USING WIFI
    [Arguments]    ${target_id}    ${ssid}
    [Documentation]    Connect to a wifi AP/Hotspot using Appium for virtual keyboard
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO WIFI CONNECT using Appium target_id:${target_id} ssid:${ssid}
    SET ALL WIFI FORGET APPIUM    ${ivi_adb_id}
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    ${is_present} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${ssid}']    direction=down    from_xpath_element=//*[@text='Wi‑Fi']    scroll_tries=15
    Run Keyword If    "${is_present}" == "False"    Run Keyword And Ignore Error      APPIUM_TAP_XPATH    //*[@text='Join other network']    20
    ${is_present} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${ssid}']    direction=down    from_xpath_element=//*[@text='Wi‑Fi']   scroll_tries=20
    Should Be True   ${is_present}    ${ssid} is not present in the Wifi List
    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20    10
    Sleep   2
    Run Keyword If    "${platform_version}" == "12"    APPIUM_TAP_XPATH    ${Text_zone}
    Sleep   2
    CHECK VIRTUAL KEYBOARD    ${ivi_adb_id}    present
    APPIUM_TAP_XPATH    ${Cancel}
    GO HOME AND CLEAR SETTINGS APP    ${target_id}

SET ALL WIFI FORGET APPIUM
    [Arguments]    ${target_id}
    [Documentation]    Removes all the ssids from saved and connected network list
    Log To Console    Removes all the ssids from saved and connected network list on: ${target_id}
    FOR    ${i}    IN RANGE    0    3
        GOTO WI-FI SETTINGS APPIUM    ${target_id}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Connected' or @text='Saved']
        Run Keyword If    "${result}" == "False"     Run Keywords    GO HOME AND CLEAR SETTINGS APP    ${target_id}
        ...    AND    Exit For Loop
        FORGET ALL NETWORKS APPIUM    ${target_id}
    END
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Connected' or @text='Saved']
    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    Should Not Be True    ${result}    Failed to forget all saved and connected Wi-Fi networks

FORGET ALL NETWORKS APPIUM
    [Arguments]    ${target_id}
    [Documentation]    Forget all networks from saved and connected network list on: ${target_id}
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys wifi | grep 'PROVIDER-NAME'
    Log    ${output}
    ${output} =    Strip String    ${output}    characters=b'    mode=left
    ${output} =    Strip String    ${output}    characters='    mode=right
    Log    ${output}
    @{output} =    Split String    ${output}    \n
    @{ssid_names} =    Create List
    FOR    ${line}    IN    @{output}
        @{line_data} =    Split String    ${line}    " PROVIDER-NAME:
        ${data_length} =    Get Length    ${line_data}
        Continue For Loop If    "${data_length}" == "0"
        ${ssid_name} =    Get From List    ${line_data}    0
        @{ssid_name} =    Split String    ${ssid_name}    SSID: "
        ${ssid_name} =    Get From List    ${ssid_name}    1
        ${ssid_name} =    Strip String    ${ssid_name}
        Append To List    ${ssid_names}    ${ssid_name}
    END
    Log List    ${ssid_names}
    FOR    ${ssid_name}    IN    @{ssid_names}
        ${tap_status} =    Run Keyword And Return Status    APPIUM_TAP_XPATH    //*[@text='${ssid_name}']
        Continue For Loop If    "${tap_status}" == "False"
        Sleep    3
        ${tap_status} =    Run Keyword And Return Status    APPIUM_TAP_XPATH    ${forget_wifi_ssid}
        Run Keyword If    "${tap_status}" == "False"    Run Keywords    APPIUM_TAP_XPATH    //*[@text='${ssid_name}']
        ...    AND    Sleep    3
        ...    AND    APPIUM_TAP_XPATH    ${forget_wifi_ssid}
        Sleep    3
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Connected' or @text='Saved']
        Exit For Loop If    "${result}" == "False"

    END
    GO HOME AND CLEAR SETTINGS APP    ${target_id}

GO HOME AND CLEAR SETTINGS APP
    [Arguments]    ${target_id}
    [Documentation]    Navigate to home screen and clear the application data of settings app on: ${target_id}
    GO HOME SCREEN APPIUM
    CLEAR PACKAGE    com.android.car.settings
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='android:id/message']    retries=20
    IF    "${result}"=="True"
        APPIUM_TAP_XPATH    //*[@text='Go to settings']
        APPIUM_TAP_XPATH    //*[@text='Accept all']
        GO HOME SCREEN APPIUM
        CLEAR PACKAGE    com.android.car.settings
    END

DO SELECT WIFI
    [Arguments]    ${target_id}    ${ssid}
    [Documentation]    Do Select WiFi: ${ssid} on ${target_id}
    GOTO WI-FI SETTINGS APPIUM    ${target_id}
    Run Keyword If    "${platform_version}" == "10"     APPIUM_TAP_XPATH    ${wifi_button}
    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20
    Sleep   5

SET WIFI STATUS
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check WiFi status on DUT matches ${status} and if not, set it accordingly
    Import library    rfw_services.ivi.AndroidWiFiLib    device=${target_id}    WITH NAME    Wifi_lib
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECKSET WIFI STATUS target_id:${target_id} status:${status}
    ${chk_wifi_status} =    Wifi_lib.CHECK WIFI STATUS    ${status}    ${target_id}
    Return From Keyword If    ${chk_wifi_status} == True
    ${set_wifi_status} =    Run Keyword If    "${status}"=="on"    Wifi_lib.SET WIFI STATUS    on
    ...    ELSE    Wifi_lib.SET WIFI STATUS    off
    Should Be True    ${set_wifi_status}    msg=Wifi is not ${status} on ${target_id}

SET HOST PC WIFI STATUS
    [Documentation]    Set accordingly the wifi state of host pc
    [Arguments]       ${status}
    OperatingSystem.Run    nmcli r wifi ${status}
    sleep    5
    Run Keyword if    "${status}" == "on"    CONNECT HOST PC WIFI    ${wifi_ssid}    ${wifi_pwd}
    ...    ELSE    Log To Console    PC HOST IS NOT CONNECTED TO WIFI

CONNECT HOST PC WIFI
    [Documentation]    Connect host pc to a specific WiFi ssid
    [Arguments]     ${wifi_ssid}    ${wifi_pwd}
    ${connection_status}   ${connection_status_out} =    OperatingSystem.Run And Return Rc And Output   nmcli d wifi connect ${wifi_ssid} password ${wifi_pwd}
    Should Contain     ${connection_status_out}      successfully activated

RECONNECT WIFI APPIUM FOR INSTABILITY
    [Documentation]    Reconnects wifi when it goes to saved or connecting instead of being connected.
    [Arguments]    ${ssid}    ${password}
     FOR    ${counter}    IN RANGE    0    2
        APPIUM_TAP_XPATH    //*[@text='${ssid}']    20    direction=up
        APPIUM_TAP_XPATH    ${forget_wifi_ssid}
        APPIUM_TAP_XPATH    //*[@text='${ssid}']    20
        ${pop_up_present} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='android:id/edit']    retries=5
        Should Be True    ${pop_up_present}
        APPIUM_ENTER_TEXT    ${wifi_pass_id}    ${password}
        IF    "${platform_version}" == "10"
            VALIDATE WIFI CONNECTION A10
        ELSE
            VALIDATE WIFI CONNECTION A12
        END
        Sleep    3
        ${is_present} =    APPIUM_WAIT_FOR_XPATH    //*[@text='OK']   20
        Run Keyword If    "${is_present}" == "True"    VALIDATE WIFI CONNECTION A12
        FOR    ${counter}    IN RANGE    0    3
            ${wait} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connecting']    30
            Exit For Loop If    "${wait}" == "False"
            Sleep    20
        END
        ${saved} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Saved']    30
        ${conn} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Connected']    30
        Exit For Loop If    "${saved}" == "False" and "${conn}" == "True"
    END
