#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     GPS test library
Library           rfw_services.ivi.GpsLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Variables         ../KeyCodes.yaml


*** Variables ***
${nmea_log_path}        /storage/emulated/0/GPS_InfoAndNMEALogging/
${dlelte_nmea_logs}     *.txt
${app_settings}         com.android.settings
${warn}                 warn
${target_id}            ivi
${enable_location_mode_value}    3
${disable_location_mode_value}    0
${enter_gmail_button}    //*[@resource-id='identifierId']
${enter_gmail_pass_button}    //*[@class='android.widget.EditText']
${add_charging_station}       //*[@text='Add charging stop']
${charging_station}           //android.widget.FrameLayout[@index='0']
${no_result_xpath}           //*[@text='No results found']
${waiting_route_xpath}       //*[@text='Waiting for location...']
${no_route_xpath}            //*[@text='No route found']
${start_button_xpath}        //*[@content-desc='Start']
${frame_layout_split}        android.widget.FrameLayout
${navigation_info_id}        com.google.android.apps.maps:id/place_details_navigation_footer_double_line
${txt_split}                 text="
${place_info_id}             com.google.android.apps.maps:id/place_details_title
${first_element_ct_desc}     //*[@content-desc='1']
${destination_scroll_list}   com.google.android.apps.maps:id/max_width_layout
${stop_button_xpath}        //*[@content-desc='Add stop']
${img_add_stop}             add_stop.png
${time_charge}              //*[contains(@text, "min")]
${setting}    setting.png
${ref_image}    map_dow.png
${privacy_settings}           //*[@text='Review privacy settings' or @text='Go to Location settings']
${Done}           //*[@text='Done'or @text='Turn on']
${Close}           //*[@text='Close']
*** Keywords ***
DO DESTINATION
    [Arguments]    ${navigation_apps}    ${destination}
    [Documentation]    will define the {destination} to research with the {navigationapps} on
    ...    {dutid} and validate the navigation address to start the computation of travel time
    Log To Console    LAUNCHING APP:${navigation_apps} and inputing destination ${destination}
    ENABLE MULTI WINDOWS
    ${Verdict} =    APPIUM_WAIT_FOR_XPATH    ${privacy_settings}
    IF  "${Verdict}" == "True"
        APPIUM_TAP_XPATH    ${privacy_settings}
        APPIUM_TAP_XPATH    ${Done} 
        Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${Close}
    END
    ${destination_entered} =    rfw_services.ivi.GpsLib.DO APP DESTINATION    ${navigation_apps}    ${destination}
    Should Be True    ${destination_entered}

CHECKSET GPS
    [Arguments]    ${target_id}    ${expected_status}
    [Documentation]    CHECKSET GPS
    ...    arguments: ${target_id} ${expected_status} = on or off
    ...    check the GPS current state and set the expected ${expected_status} (on / off)
    ...    if needed.
    Log To Console    CHECKSET GPS: target_id:${target_id} status:${expected_status}
    ${chk_gps_status} =    CHECK GPS STATUS    ${target_id}    ${expected_status}
    ${set_gps_status} =    Run Keyword If   ${chk_gps_status} == True     Return From Keyword
    ...    ELSE    SET GPS STATUS    ${target_id}    ${expected_status}
    Should Be True    ${set_gps_status}    GPS failed to be set to the expected status: ${expected_status}

SET LOCATION MODE
    [Arguments]    ${target_id}    ${mode}
    SET GPS STATUS    ${target_id}    ${mode}

ACCEPT LOCATION PRIVACY APPIUM
    [Documentation]    Accept location conditions
    Log To Console    Accept location conditions
    SET LAUNCH APP    ivi    Maps
    ${search_text} =    Set Variable    Review privacy settings
    ${search_text1} =    Set Variable    Go to Settings
    FOR    ${i}    IN RANGE    0    3
        Run Keyword and Ignore Error    enable_multi_windows
        DO WAIT    5000
        ${status} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${search_text}' or @text='${search_text1}']
        Run Keyword If    "${status}" == "False"    SET LAUNCH APP    ivi    Maps
        Exit For Loop If    "${status}" == "True"
    END
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${search_text}' or @text='${search_text1}']
    Run Keyword If    "${status}" == "True"    Should Be True    "${result}" == "True"    ${search_text} option not found
    # In case Location privacy settings is already accepted
    Return From Keyword If    "${result}" == "${False}"
    TAP BY XPATH    //*[@text='${search_text}' or @text='${search_text1}']

    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='MORE' or @text='More']
    Run Keyword If    "${status}" == "True"    Run Keyword and Ignore Error    Should Be True    "${result}" == "True"    more option not found
    Run Keyword and Ignore Error    TAP BY XPATH    //*[@text='MORE' or @text='More']

    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Done' or @text='Turn on']
    Run Keyword If    "${status}" == "True"    Should Be True    "${result}" == "True"    Done option not found
    ...    ELSE    Log    Location conditions already accepted    console=True
    Run Keyword If    "${status}" == "True"    TAP BY XPATH    //*[@text='Done' or @text='Turn on']
    DO WAIT    3000
    Run Keyword and Ignore Error    APPIUM_TAP_XPATH    //*[@text='Close']
    DO WAIT    3000

CHECK MINIMUM CHARGING TIME ON MAPS
    Log To Console    Checking minimum charging time is displayed or not
    CHECK CHARGING STATIONS APPIUM    ${ivi_adb_id}
    ${charge_station} =    Create Dictionary    x=102   y=456
    APPIUM_TAP_LOCATION   ${charge_station}
    DO WAIT    5000
    Run Keyword and Ignore Error    enable_multi_windows
    CHECK NO ROUTE FOUND
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${img_add_stop}    ${CURDIR}
    Should be true    ${verdict}    Failed to download '${download_url_image}${img_name}' from artifactory
    TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}
    DO WAIT    10000
    ${result} =    APPIUM_GET_TEXT_USING_XPATH     ${time_charge} 
    Log     ${result}

CHECK CHARGING STATIONS
    [Arguments]    ${dut_id}
    [Documentation]   Check if Charging Stations are detected on ${dut_id}
    Log To Console    Check if Charging Stations are detected on ${dut_id}
    # Workaround for Appium issue not able to detect Start button Map MATRIX-30961
    CHECKSET FILE PRESENT    bench    start_button_image.png
    ${status}    ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN    ${dut_id}    start_button_image.png
    SET DELETE FILE    bench    start_button_image.png
    ${x1} =    Get From List    ${start_pt}    0
    ${x1} =    Convert To Integer    ${x1}
    ${y1} =    Get From List    ${start_pt}    1
    ${y1} =    Convert To Integer    ${y1}
    ${x2} =    Get From List    ${end_pt}    0
    ${x2} =    Convert To Integer    ${x2}
    ${y2} =    Get From List    ${end_pt}    1
    ${y2} =    Convert To Integer    ${y2}
    ${x} =    Evaluate    (${x1} + ${x2}) / 2
    ${y} =    Evaluate    (${y1} + ${y2}) / 2
    TAP BY LOCATION    ${x} ${y}
    # Workaround for Appium issue not able to detect Charging Stations on Map MATRIX-30961
    CHECKSET FILE PRESENT    bench    charging_stns.png
    CHECKSET FILE PRESENT    bench    charging_stn_1.png
    FOR    ${i}    IN RANGE    0    10
        DO WAIT    5000
        TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
        ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    charging_stns.png    ${CURDIR}/screen_shot_image.png
        Exit For Loop If    "${status}" == "True"
    END
    FOR    ${i}    IN RANGE    0    10
        DO WAIT    5000
        TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
        ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    charging_stn_1.png    ${CURDIR}/screen_shot_image.png
        Exit For Loop If    "${status}" == "True"
    END
    Should Be True    ${status}
    SET DELETE FILE    bench    charging_stns.png
    SET DELETE FILE    bench    charging_stn_1.png

CHECK CHARGING STATIONS APPIUM
    [Arguments]    ${dut_id}
    [Documentation]   Check if Charging Stations are detected on ${dut_id}
    Log To Console    Check if Charging Stations are detected on ${dut_id}
    DO WAIT    5000
    enable multi windows
    DO WAIT    5000
    APPIUM_TAP_XPATH    //*[@text='Start' or @content-desc='Start']    retries=20
    DO WAIT    5000
    APPIUM_TAP_XPATH    //*[@content-desc='Search along route']    retries=20    
    DO WAIT    5000
    APPIUM_TAP_XPATH    //*[@text='Charging stations' or @content-desc='Charging stations']    retries=20
    DO WAIT    5000
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.google.android.apps.maps:id/navigation_search_results_list']    retries=20
    Should be true    ${result}

CLOSE NAVIGATION
    [Arguments]    ${dut_id}
    [Documentation]   Closes the navigation on ${dut_id}
    Log To Console    Closes the navigation on ${dut_id}
    APPIUM_TAP_XPATH    //*[@content-desc='Close']
    APPIUM_TAP_XPATH    //*[@resource-id='com.google.android.apps.maps:id/status_panel_close_button']

CHECKSET GAS REGISTRATION
    [Arguments]    ${google_user}    ${google_pwd}
    [Documentation]   Performs Google login
    LAUNCH APP APPIUM    Settings
    ${ret_code} =    START INTENT    -n com.android.vending/com.google.android.finsky.carmainactivity.MainActivity
    Should Be Equal    ${ret_code}    ${0}
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Google Play']
    Return From Keyword If    "${res}"=="True"
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    //*[@text='ACCEPT']   10
    Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    //*[@text='ACCEPT']    5
    APPIUM_TAP_XPATH    //*[@text='Sign in']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@text='Sign in on car screen']    20
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_TAB}
    Sleep    5s
    ENABLE MULTI WINDOWS
    APPIUM_ENTER_TEXT_XPATH    ${enter_gmail_button}    ${gas_login}
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    5s
    Run Keyword and Ignore Error    APPIUM_TAP_XPATH    //*[@text='Next']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Couldn't find your Google Account']
    Should Not Be True    ${result}    Please enter valid email id
    APPIUM_ENTER_TEXT_XPATH    ${enter_gmail_pass_button}    ${gas_pswd}
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    APPIUM_TAP_XPATH    //*[@text='Done']    20

CHECK IVI GOOGLEMAPS LOW BATTERY ALERT
    [Arguments]    ${dut_id}    ${alert_status}
    [Documentation]   Check if Low battery alert is detected on ${dut_id}
    Log To Console    Check if Low battery alert is detected on ${dut_id}
    # Workaround for Appium issue not able to detect Start button Map MATRIX-30961
    CHECKSET FILE PRESENT    bench    start_button_image.png
    CHECKSET FILE PRESENT    bench    out_of_battery_range.png
    CHECKSET FILE PRESENT    bench    charging_stns.png
    CHECKSET FILE PRESENT    bench    charging_stn_1.png
    ${status}    ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN    ${dut_id}    start_button_image.png
    SET DELETE FILE    bench    start_button_image.png
    ${x1} =    Get From List    ${start_pt}    0
    ${x1} =    Convert To Integer    ${x1}
    ${y1} =    Get From List    ${start_pt}    1
    ${y1} =    Convert To Integer    ${y1}
    ${x2} =    Get From List    ${end_pt}    0
    ${x2} =    Convert To Integer    ${x2}
    ${y2} =    Get From List    ${end_pt}    1
    ${y2} =    Convert To Integer    ${y2}
    ${x} =    Evaluate    (${x1} + ${x2}) / 2
    ${y} =    Evaluate    (${y1} + ${y2}) / 2
    TAP BY LOCATION    ${x} ${y}
    # Workaround for Appium issue not able to detect Low battery alert and Charging Stations on Map MATRIX-30961
    FOR    ${i}    IN RANGE    0    10
        DO WAIT    5000
        TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
        ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    out_of_battery_range.png    ${CURDIR}/screen_shot_image.png
        Exit For Loop If    "${status}" == "True"
    END
    Run Keyword If    "${alert_status}"=="True"    Should Be True    ${status}
    ...    ELSE    Should Not Be True    ${status}
    FOR    ${i}    IN RANGE    0    10
        DO WAIT    5000
        TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
        ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    charging_stns.png    ${CURDIR}/screen_shot_image.png
        Exit For Loop If    "${status}" == "True"
    END
    Run Keyword If    "${alert_status}"=="True"    Should Be True    ${status}
    ...    ELSE    Should Not Be True    ${status}
    FOR    ${i}    IN RANGE    0    10
        DO WAIT    5000
        TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
        ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    charging_stn_1.png    ${CURDIR}/screen_shot_image.png
        Exit For Loop If    "${status}" == "True"
    END
    Run Keyword If    "${alert_status}"=="True"    Should Be True    ${status}
    ...    ELSE    Should Not Be True    ${status}
    SET DELETE FILE    bench    out_of_battery_range.png
    SET DELETE FILE    bench    charging_stns.png
    SET DELETE FILE    bench    charging_stn_1.png

CHECK GET TRAVEL DESTINATION
    [Arguments]       ${app_gps_used}=GoogleMapsApp    ${check_only}=False
    [Documentation]   Check the travel time is successfully computed
    Skip If           '${app_gps_used}' != 'GoogleMapsApp'      "This Keyword used with Google Maps Only"
    Run Keyword and Ignore Error    enable_multi_windows
    CHECK NO ROUTE FOUND
    Log To Console    "Your destination is identified with success."
    Log               "Your destination is identified with success."
    APPIUM GET DESTINATION INFO    ${check_only}

CHECK NO ROUTE FOUND
    ${verdict} =       APPIUM CHECK ELEMENT BY XPATH     ${no_route_xpath}
    Run Keyword If    ${verdict}    FAIL NO ROUTE
    ${verdict} =       APPIUM CHECK ELEMENT BY XPATH     ${no_result_xpath}
    Run Keyword If    ${verdict}    FAIL NO ROUTE
    ${verdict} =       APPIUM CHECK ELEMENT BY XPATH     ${waiting_route_xpath}
    Run Keyword If    ${verdict}    FAIL NO ROUTE

FAIL NO ROUTE
    Log To Console   "No results found"
    Run Keyword and Ignore Error    SAVE SCREENSHOT APPIUM    path_to_save=/tmp/    screenshot_name=no_root_found
    Fail      "No results found, no destination is identified."

APPIUM GET DESTINATION INFO
    [Arguments]           ${check_only}
    Set Suite Variable    ${destination_data}   ${EMPTY}
    ${verdict}            APPIUM CHECK ELEMENT BY XPATH   ${start_button_xpath}    
    Run Keyword If        ${verdict}    GET START NAVIGATION DATA     
    Run Keyword Unless    ${verdict}    APPIUM SELECT DESTINATION AND GET DATA     ${check_only}

GET START NAVIGATION DATA 
    Log                   ${destination_data}
    ${src}                APPIUM LOG VIEW SOURCE CODE
    @{my_data}            Split String    ${src}   ${frame_layout_split}
    FOR  ${i}    IN       @{my_data}
        ${status}         Run Keyword And Return Status   Should Contain    ${i}    ${navigation_info_id}
        Run Keyword If        ${status}    Set Local Variable    ${local_var_dest}    ${i}
        Exit For Loop If      ${status}
    END
    @{my_data}            Split String    ${local_var_dest}   ${txt_split}
    ${destination_data}     APPIUM_GET_TEXT      ${place_info_id}
    FOR  ${i}    IN       @{my_data}
        @{new_data}           Split String    ${i}   "
        ${destination_data}   Catenate        ${destination_data}    ${new_data}[0]
    END
    Log                   ${destination_data}
    Log To Console        "\n Destination Info: ------------- ${destination_data} ----------"

APPIUM SELECT DESTINATION AND GET DATA 
    [Arguments]           ${check_only}
    # Make sure there is a destination
    ${verdict}            APPIUM CHECK ELEMENT BY XPATH   ${first_element_ct_desc}
    ${status}             Run Keyword And Return Status     Should Not Be True    ${verdict}
    Run Keyword If        ${status}    FAIL NO ROUTE
    # Select one target and click on it
    Run Keyword If    '${check_only}' == 'True'    APPIUM_TAP_XPATH    ${first_element_ct_desc}   
    GET START NAVIGATION DATA

DO DESTINATION SPCX APPIUM
    [Arguments]    ${destination}
    Log To Console    Do destination: ${destination} in the search field of Android Auto SPCX
    TAP IF IMAGE DISPLAYED ON SCREEN    close_image.png
    DO WAIT    5000
    TAP IMAGE DISPLAYED ON SCREEN    Search.png
    DO WAIT    5000
    TAP IMAGE DISPLAYED ON SCREEN    search_destination.png
    DO WAIT    5000
    TAP IMAGE DISPLAYED ON SCREEN    blank_search.png
    DO WAIT    5000
    TAP TEXT ON SCREEN    ${destination}
    TAP IMAGE DISPLAYED ON SCREEN    search_image.png
    DO WAIT    5000
    TAP IMAGE DISPLAYED ON SCREEN    destination_1.png
    DO WAIT    5000

CHECK SPCX MAPS STRING ELLIPSIS
    [Arguments]    ${dut_id}    ${status}
    Log To Console    Checks the SPCX Maps String ellipsis in ${dut_id} with status: ${status}
    ${ellipsis_status} =    FIND IMAGE ON SCREEN APPIUM    str_ellipsis.png
    TAP IF IMAGE DISPLAYED ON SCREEN    close_image.png
    ${ellipsis_status} =    Get From List    ${ellipsis_status}    -1
    Run Keyword If    "${status}" == "${True}"    Should Be True    ${ellipsis_status}
    ...    ELSE    Should Not Be True    ${ellipsis_status}

DO SELECT IVI OFFLINE MAPS 
    [Documentation]    To select  the offline map menu
    Log To Console    Select offline maps
    REMOVE APPIUM DRIVER  
    CREATE APPIUM DRIVER
    ENABLE MULTI WINDOWS
    APPIUM_PRESS_KEYCODE    ${KEYCODE_HOME}
    ${verdict}    ${result} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${setting}    ${CURDIR}
    Should be true    ${verdict}    Failed to download '${download_url_image}${setting}' from artifactory
    TAP IMAGE DISPLAYED ON SCREEN    ${result} 
    DO WAIT    2000  
    APPIUM_TAP_XPATH    //*[@text='Offline maps']

DO SELECT IVI OWN_MAPS 
    [Documentation]    To download the offline map 
    APPIUM_TAP_XPATH    //*[@text='Select your own map'] 
    APPIUM_TAP_XPATH    //*[@text='Download']
    DO WAIT    30000  

CHECK IVI OFFLINE MAP    
    [Documentation]    To check if the offline map is downloaded
    TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
    ${status}    ${res_download} =    DOWNLOAD FILE FROM ARTIFACTORY   ${download_url_image}${ref_image}    ${CURDIR}
    Should Be True    ${status}
    ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    ${res_download}    ${CURDIR}/screen_shot_image.png
    Should Be True    ${status}
