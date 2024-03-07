#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Resource          ../IVI/appium_hlks.robot
Resource          mobile_adb_command.robot
Resource          ../IVI/new_hmi.robot
Resource          ../IVI/referencephone.robot
Variables         myrenault_ids.yaml
Variables         ../IVI/KeyCodes.yaml

*** Variables ***
${mobile_appPackage}       com.renault.myrenault.one.valid
${mobile_activityName}     com.accenture.myrenault.activities.splashscreen.SplashScreenActivity
${mobile_adb_id}      R58NC1NPL6A
${automation_name}    UiAutomator2
${platform_name}    Android
${mobile_platform_version}    11
${myrenault_username}    None
${myrenault_password}    None
${days}    Mon,Tue
${vehicle_id}    None
${mobile_driver}    None
${error_messages}    An error has occurred. Please try again. Security conditions in the vehicle have not been met.${\n}Check them before you start again."    "Mmm... we have a problem.    This PIN code is incorrect    Mmm... we have a problem.${\n}Try again or contact customer support.

*** Keywords ***
LAUNCH AND LOGIN THE APPLICATION
    [Arguments]    ${myrenault_username}   ${myrenault_password}
    [Documentation]    == High Level Description: ==
    ...   Launches the MyR One Valid android application and Login
    ...    == Parameters: ==
    ...    myrenault_username: username for MyR application login
    ...    myrenault_password: password for MyR application login
    Return From Keyword If    "${myrenault_username}" == "None"  or  "${myrenault_password}" == "None"
    LAUNCH_MYRENAULT_APP    ${mobile_appPackage}    ${mobile_activityName}
    Log To Console     MyRenault App started
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['pop_up_launch_i_agree']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['pop_up_launch_i_agree']}    10
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['sign_in']}    12
    sleep   5
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['sign_in']}    10
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['signin_email']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['signin_email']}     ${myrenault_username}
    sleep    5
    HIDE_KEYBOARD
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['signin_password']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['signin_password']}      ${myrenault_password}
    Log To Console   Password entered
    HIDE_KEYBOARD
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['signin_button']}      1
    ${status} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['title_privacy']}    20
    Run Keyword If    ${status} == ${True}    TAP_ON_ELEMENT_USING_ID      ${My_Renault['allow_cookies']}    10

HIDE_KEYBOARD
    [Documentation]    == High Level Description: ==
    ...    To hide keyboard in android application
    hide_mobile_keyboard

CHECK PLUGSTATUS
   [Arguments]    ${plugstatustext}    ${expected_result}    ${privacy_mode}=off
   [Documentation]    == High Level Description: ==
    ...   Checks for the  PlugStatus in MyR One Valid android application
    ...    == Parameters: ==
    ...    plugstatustext: Values may be Plugged in,Unplugged
    ...    expected_result: Values may be False for unexpected, True for expected
    ...    privacy_mode: The IVI data privacy, could be on/off
   REFRESH_LAYOUT
   ${plug_or_unplug} =    Run Keyword If    '${plugstatustext}'=='Plugged in'    Set Variable    plugged_in_search
   ...    ELSE IF    '${plugstatustext}'=='Unplugged'    Set Variable    unplugged_search
   ${text_status} =    Run Keyword If    "${privacy_mode}" == "on"    APPIUM_WAIT_FOR_XPATH    ${My_Renault['battery_privacyon']}    20
   Run Keyword If    "${privacy_mode}" == "on" and "${text_status}" == "${expected_result}"
   ...    Return From Keyword
   ...    ELSE IF    "${privacy_mode}" == "on"    FAIL    Plug status is not as expected
   Sleep    15
   ${status} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['${plug_or_unplug}']}    20
   IF    "${expected_result}" == "False"
       Should Be True    '${status}' == 'False'    Plug-In Status is Available
       Return From Keyword
   END
   ${text_retrieved} =    Wait Until Keyword Succeeds    30s    2s    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['${plug_or_unplug}']}
   Run Keyword If  ${expected_result}==True  Should Be Equal As Strings    ${text_retrieved}    ${plugstatustext}
   ...    ELSE IF  ${expected_result}==False  Should Not Be Equal As Strings    ${text_retrieved}    ${plugstatustext}

REFRESH_LAYOUT
    [Documentation]    == High Level Description: ==
    ...   Refresh Layout in MyR One Valid android application
    [Tags]    Automated    Refresh Layout    MY RENAULT APP
    RUN KEYWORD IF    ${mobile_driver}    CHECK AND SWITCH DRIVER    ${mobile_driver}
    sleep    5
    swipe_down   1
    swipe_up   0.2
    sleep   5

LOGOUT_APPLICATION
    [Documentation]    == High Level Description: ==
    ...   Log out of MyR One Valid android application
    [Tags]    Automated    User Logout    MY RENAULT APP
    RUN KEYWORD IF    ${mobile_driver}    CHECK AND SWITCH DRIVER    ${mobile_driver}
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['profile_bottom_tab']}      10
    ${element_logout} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['logout']}    12
    ${check_logout} =    Run Keyword If    "${element_logout}" == "True"    Run Keywords
    ...    SCROLL_TO_ELEMENT    ${My_Renault['logout']}    down    3
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['logout']}    10
    ...    ELSE    Run Keywords
    ...    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['sign_out']}    12
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['sign_out']}    10
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['sign_in']}    12

HANDLE_RATE_LATER_ALERT
    [Documentation]    == High Level Description: ==
    ...   HANDLE_RATE_LATER_ALERT in MyR One Valid android application
    [Tags]    Automated    HANDLE_RATE_LATER_ALERT    MY RENAULT APP
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['ratelater_text']}   25
    Run Keyword If  ${elmt} is ${TRUE}      TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['ratelater_text']}       10

LAUNCH_MYRENAULT_APP
    [Arguments]    ${mobile_appPackage}    ${mobile_activityName}
    [Documentation]    == High Level Description: ==
    ...   Launching MyR One Valid android application
    [Tags]    Automated    Launch My Renault    MY RENAULT APP
    ${mobile_platform_version} =    GET_MOBILE_PLATFORM_VERSION
    Import Library    rfw_services.ivi.AppiumLib    platformName=${platform_name}
    ...    platformVersion=${mobile_platform_version}    deviceName=${mobile_adb_id}    udid=${mobile_adb_id}    appPackage=${mobile_appPackage}
    ...    appActivity=${mobile_activityName}    autoGrantPermissions=true    automationName=${automation_name}
    ${desired_capabilities} =    Create dictionary    platformName=${platform_name}
    ...    platformVersion=${mobile_platform_version}    deviceName=${mobile_adb_id}    udid=${mobile_adb_id}    appPackage=${mobile_appPackage}
    ...    appActivity=${mobile_activityName}    autoGrantPermissions=true    automationName=${automation_name}    systemPort=8214
    ${mobile_driver} =    driver_creation    ${desired_capabilities}
    Should Not Be True   '${mobile_driver}' == 'None'   The Mobile Driver is not created
    Set Test Variable    ${smartphone_capabilities}    ${desired_capabilities}
    Set Test Variable   ${mobile_driver}

SEND MYRENAULT APP REQUEST REFRESH CAR POSITION
    [Arguments]    ${expected_result}=True
    [Documentation]    == High Level Description: ==
    ...   Check for the car is refreshed in MyR One Valid android application
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['warning_popup']}    10
    Run Keyword If    "${elmt}" == "False"    Run Keywords
    ...    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['home_car']}    15
    ...    AND    Sleep    5
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    10
    IF    "${expected_result}"=="True"
        Sleep    15
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    10
        Sleep    5
        ${result} =  APPIUM_WAIT_FOR_XPATH    ${My_Renault['car_icon']}    10
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${My_Renault['car_icon']}
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['refresh_button']}    10
        Sleep    5
        ${result_content} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['car_location']}
        Run Keyword If    "Vehicle position at:" in """${result_content}"""    Log    Vehicle position is ok
        ...    ELSE    Fail    Vehicle position is not ok
    END
    IF    "${expected_result}"=="False"
        ${result_content} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['warning_popup']}    10
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['warning_popup_click']}    10
    END
    [Return]    ${result_content}

CHECK MYRENAULT APP CAR LOCATION ON SMART PHONE
    [Documentation]    == High Level Description: ==
    ...   Check for the car location in MyR One Valid android application
    ${last_car_address} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['car_address']}
    Sleep    5
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    30
    Sleep    15
    FOR    ${each}    IN RANGE    1    5
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['car_icon']}    20
        ${elem} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['car_address']}    20
        Exit For Loop If    ${elem}==True
    END
    ${car_symbolized_address} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['car_address']}    50
    Should Be Equal    ${last_car_address}    ${car_symbolized_address}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['home_car']}    20

CHECK MYRENAULT APP CAR LOCATION SERVICE DEACTIVATED
     [Documentation]    == High Level Description: ==
    ...   Check for the car location in MyR One Valid android application with MCAF service deactivated
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    10
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    10
    ${result} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['refresh_button']}    10
    Should Not Be True    ${result}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['button_location_menu']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['speed_dial_button']}    10
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['button_add_new_position']}    10
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['button_delete_pin_position']}    10

CHECKSET MYRENAULT APP INSTALLED ON SMARTPHONE
    [Documentation]    == High Level Description: ==
    ...   Check for the MyR One Valid android application is installed on smartphone
    Log to console    CHECKSET MYRENAULT APP INSTALLED ON SMARTPHONE Keyword not implemented

CHECK REMOTE NOTIFICATION
     [Arguments]    ${status}
     [Documentation]    == High Level Description: ==
     ...    Checking The Remote Service Notification From MyR One Valid android application
     ...    == Parameters: ==
     ...    status: Values may be start_horn_lights/Locked/Unlocked/negative_result
     [Tags]    Automated    Remote Notification    MY RENAULT APP
     ${elem} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['toast_message_banner']}    90
     ${notificationtext} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT    ${My_Renault['toast_message_banner']}
     log to console    ${notificationtext}
     Run Keyword If    "${status}" == "start_horn_lights"    Should Be Equal   "${notificationtext}"    "Your car has just honked and turned on its headlights"
     ...    ELSE IF    "${status}" == "Locked"    Should Be Equal   "${notificationtext}"    "Your car has just been locked"
     ...    ELSE IF    "${status}" == "Unlocked"    Should Be Equal   "${notificationtext}"    "Your car has just been unlocked"
     ...    ELSE IF    "${status}" == "negative_result"    Should Contain Any   ${error_messages}    ${notificationtext}
     ...    Try again or contact customer support."    your PIN code has been blocked.
     ...    ELSE IF    "${status}" == "start_lights_only"    Should Be Equal   "${notificationtext}"    "Your car has just turned on its headlights"
     ...    ELSE IF    "${status}" == "start_horns_only"    Should Be Equal   "${notificationtext}"    "Your car has just honked"
     ...    ELSE IF    "${status}".lower() == "incorrect_pin"    Should Contain    "${notificationtext}"    This PIN code is incorrect
     ...    ELSE IF    "${status}".lower() == "pin_blocked"    Should Contain Any    ${notificationtext}    your PIN code has been blocked
     sleep    10
     TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

CHECK REMOTE NOTIFICATION DEBUG APP
     [Arguments]    ${status}
     [Documentation]    == High Level Description: ==
     ...    Checking The Remote Service Notification From MyR One Valid android application
     ...    == Parameters: ==
     ...    status: Values may be start_horn_lights/Locked/Unlocked/negative_result
     [Tags]    Automated    Remote Notification    MY RENAULT APP
     ${elem} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['toast_message_banner_debug']}    90
     ${notificationtext} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT    ${My_Renault['toast_message_banner_debug']}
     log to console    ${notificationtext}
     Run Keyword If    '${sweet400_bench_type}' not in "'${tc_config}[bench_type]'"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
     Run Keyword If    "${status}" == "start_horn_lights"    Should Be Equal   "${notificationtext}"    "Your car has just honked and turned on its headlights"
     ...    ELSE IF    "${status}" == "Locked"    Should Be Equal   "${notificationtext}"    "Your car has just been locked"
     ...    ELSE IF    "${status}" == "Unlocked"    Should Be Equal   "${notificationtext}"    "Your car has just been unlocked"
     ...    ELSE IF    "${status}" == "negative_result"    Should Contain Any   ${error_messages}    ${notificationtext}
     ...    Try again or contact customer support."    your PIN code has been blocked.
     ...    ELSE IF    "${status}" == "start_lights_only"    Should Be Equal   "${notificationtext}"    "Your car has just turned on its headlights"
     ...    ELSE IF    "${status}" == "start_horns_only"    Should Be Equal   "${notificationtext}"    "Your car has just honked"
     ...    ELSE IF    "${status}".lower() == "incorrect_pin"    Should Contain    "${notificationtext}"    This PIN code is incorrect
     ...    ELSE IF    "${status}".lower() == "pin_blocked"    Should Contain Any    ${notificationtext}    your PIN code has been blocked
     sleep    10

SEND RHL REQUEST FROM MYR
	[Arguments]    ${pincode}    ${rhl_button}=active
    [Documentation]    == High Level Description: ==
    ...    Checks rhl icon is present and enable horns and lights from MYR
    ...    == Parameters: ==
    ...    pincode: pincode required to start horn and lights from MYR
    [Tags]    Automated    Remote Services   MY RENAULT APP
    ${rhl_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rhl_button']}    20
    Return From Keyword If    "${rhl_button_find}" == "True" and "${rhl_button}" == "inactive"
    Run Keyword If    ${rhl_button_find}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    ...    ELSE    Run Keyword If    ${rhl_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['hornlight_button']}    10
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['pincode_view']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['pincode_view']}    ${pincode}

SEND RHL REQUEST FROM MYR DEBUG APP
	[Arguments]    ${pincode}    ${rhl_button}=active
    [Documentation]    == High Level Description: ==
    ...    Checks rhl icon is present and enable horns and lights from MYR
    ...    == Parameters: ==
    ...    pincode: pincode required to start horn and lights from MYR
    [Tags]    Automated    Remote Services   MY RENAULT APP
    ENABLE MULTI WINDOWS
    ${rhl_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rhl_button']}    10
    Return From Keyword If    "${rhl_button_find}" == "True" and "${rhl_button}" == "inactive"
    Run Keyword If    ${rhl_button_find}==True    Repeat Keyword    2 times    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    10
    ...    ELSE    Run Keyword If    ${rhl_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button_debug']}   10
    ...    AND    Repeat Keyword    2 times    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button_debug']}    10
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['hornlight_button_debug']}    10
    Return From Keyword If    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['pincode_view_debug']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['pincode_view_debug']}    ${pincode}

SEND Horns_Only REQUEST FROM MYR DEBUG APP
    [Arguments]    ${pincode}    ${My_Renault_Vin_Name}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    == High Level Description: ==
    ...    Checks rhl icon is present and enable horns from MYR
    ...    == Parameters: ==
    ...    pincode: pincode required to start horns from MYR
    [Tags]    Automated    Remote Services   MY RENAULT APP
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 2
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH    //*[@resource-id="com.renault.myrenault.one.valid.debug:id/vehicle_selection_text_view"]    30    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_vehicle_selection
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@text='${My_Renault_Vin_Name}' or @text='${vehicle_id}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_${My_Renault_Vin_Name}
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    ${rhl_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rhl_button']}    20
    Run Keyword If    ${rhl_button_find}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    ...    ELSE    Run Keyword If    ${rhl_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button_debug']}   10
    ...    AND    Repeat Keyword    2 times    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button_debug']}    10
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['horn_only_button_debug']}    10
    Return From Keyword If    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['pincode_view_debug']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['pincode_view_debug']}    ${pincode}

SEND RLU REQUEST FROM MYR
    [Arguments]    ${pincode}
    [Documentation]    == High Level Description: ==
    ...    Checks rlu icon is present and enable lock or unlock from MYR
    ...    == Parameters: ==
    ...    pincode: pincode required to send remote service from MYR
    [Tags]    Automated    Remote Services   MY RENAULT APP
    ${rlu_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rlu_button']}    20
    Run Keyword If    ${rlu_button_find}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rlu_button']}    20
    ...    ELSE    Run Keyword If    ${rlu_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rlu_button']}    20
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['lock_unlock_button']}    10
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['pincode_view']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['pincode_view']}    ${pincode}

SEND Lights_Only REQUEST FROM MYR
    [Arguments]    ${pincode}
    [Documentation]    == High Level Description: ==
    ...    Checks rhl icon is present and enable lights from MYR
    ...    == Parameters: ==
    ...    pincode: pincode required to start lights from MYR
    [Tags]    Automated    Remote Services   MY RENAULT APP
    ${rhl_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rhl_button']}    20
    Run Keyword If    ${rhl_button_find}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    ...    ELSE    Run Keyword If    ${rhl_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['light_only_button']}    10
    Return From Keyword If    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['pincode_view']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['pincode_view']}    ${pincode}

SEND Horns_Only REQUEST FROM MYR
    [Arguments]    ${pincode}
    [Documentation]    == High Level Description: ==
    ...    Checks rhl icon is present and enable horns from MYR
    ...    == Parameters: ==
    ...    pincode: pincode required to start horns from MYR
    [Tags]    Automated    Remote Services   MY RENAULT APP
    ${rhl_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rhl_button']}    20
    Run Keyword If    ${rhl_button_find}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    ...    ELSE    Run Keyword If    ${rhl_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['rhl_button']}    20
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['horn_only_button']}    10
    Return From Keyword If    '${sweet400_bench_type}' in "'${tc_config}[bench_type]'"
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['pincode_view']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['pincode_view']}    ${pincode}

CHECK LOCKSTATUS TEXT
   [Arguments]    ${lockstatustext}    ${status}
   [Documentation]    == High Level Description: ==
    ...   Checks for the  Lockstatus in MyR One Valid android application
    ...    == Parameters: ==
    ...    lockstatustext: Values may be Locked,Unlocked
    ...    status: success/Fail Value is success if your obtained result and expectation are same
    ...                               Value is fail if your obtained result and expectation are different
   [Tags]    Automated    Remote Services   MY RENAULT APP
   REFRESH_LAYOUT
   ${locked_or_unlocked} =    Run Keyword If    '${lockstatustext}'=='Locked'    Set Variable    lockstatus_text
   ...    ELSE IF    '${lockstatustext}'=='Unlocked'    Set Variable    unlockstatus_text
   ${text_retrieved_lockstatus} =    Wait Until Keyword Succeeds    30s    2s    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['${locked_or_unlocked}']}
   Run keyword If   "${status}".lower() == 'success'    Should Be Equal As Strings    ${text_retrieved_lockstatus}    ${lockstatustext}
   ...    ELSE    Should Not be Equal As Strings    ${text_retrieved_lockstatus}    ${lockstatustext}

CHECK LOCKSTATUS STATE
    [Documentation]    == High Level Description: ==
    ...     Checks if the service is active.
    ...     lockstatus states: Locked/Unlocked
    REFRESH_LAYOUT
    ${text_retrieved_lockstatus} =    APPIUM_GET_TEXT    ${My_Renault['lockunlockstatus_text']}    20
    Run keyword if    "${text_retrieved_lockstatus}" == "Locked" or "${text_retrieved_lockstatus}" == "Unlocked"    Log    Service is active
    ...     ELSE    Fail    Service is not active.
    [Return]    ${text_retrieved_lockstatus}

SELECT_REQUIRED_VEHICLE
    [Documentation]    == High Level Description: ==
    ...   Choose the vehicle from MyR Application
    [Tags]    Automated    Vehicle Selection    MY RENAULT APP
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_spring_button']}     10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['select_first_vehicle']}    15

CHECK_AUTONOMY_TEXT
   [Arguments]    ${vehicle_autonomy}
   [Documentation]    == High Level Description: ==
    ...   Checks for the Vehicle Autonomy and  Autonomy text displayed in MyR One Valid android application
    ...    == Parameters: ==
    ...    vehicle_autonomy: Autonomy value to send through can and to be reflected in MyR (Eg:150)
   [Tags]    Automated    Check Autonomy in Vehicle and MYR    MY RENAULT APP
   ${text_retrieved_autonomy} =    APPIUM_GET_TEXT    ${My_Renault['autonomy_text']}
   Should Be Equal    " ~ ${vehicle_autonomy} km"    "${text_retrieved_autonomy}"

CHECK CHARGE STATUS AND BATTERY PERCENTAGE
    [Arguments]    ${needed_battery_percentage}    ${needed_charge}    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Checks the battery percentage and charge status in MyR application
    ...    == Parameters: ==
    ...    needed_battery_percentage: required battery level send to the app(Eg:45)
    ...    needed_charge: required battery level send to the app(Eg: charge_in_progress)
    ...    expected_status: True/False based on result expected
    [Tags]    Automated    Display   MY RENAULT APP
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['battery_percentage']}    15
    ${battery_percentage_text} =    Run Keyword If    "${verdict}" == "True"    APPIUM_GET_TEXT    ${My_Renault['battery_percentage']}    20
    ${charge_status_text} =    Wait Until Keyword Succeeds    80s    2s    APPIUM_GET_TEXT    ${My_Renault['charge_status']}    20
    Run Keyword If    ${expected_status}==True    Should Be Equal    "${battery_percentage_text}"    "${needed_battery_percentage}%"
    ...    Should Be Equal    "${charge_status_text}"    "${needed_charge.replace("_"," ")}"
    ...    ELSE IF    ${expected_status}==False    Should Not Be Equal    "${battery_percentage_text}"    "${needed_battery_percentage}%"
    ...    Should Not Be Equal    "${charge_status_text}"    "${needed_charge.replace("_"," ")}"

SEND MYRENAULT APP REQUEST SET PINCODE
    [Arguments]    ${status}=Success
    [Documentation]     Send a request to set the pin using MYR application
    ...    == Parameters: ==
    ...    status: Success/Fail based on the condition needed for PIN setting
    SCROLL_TO_ELEMENT       ${My_Renault['scroll_to_pin_box']}
    APPIUM_TAP_XPATH        ${My_Renault['tap_on_pin_box']}
    # Tap on START
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['tap_on_start']}      12
    Sleep    5
    # get text    1.You need to turn on your engine
    ${found_start_engine} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['read_text_title1']}
    Should Be Equal    "${found_start_engine}"    "1. You need to turn on your engine"
    # get text    2.Your multimedia system must be turned on
    ${found_multimedia_text} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['read_text_title2']}
    Should Be Equal    "${found_multimedia_text}"    "2. Your multimedia system must be turned on"
    # get text    3.Ensure to be in a network-covered area
    #  read_text_title3: com.renault.myrenault.one.valid:id/init_pin_step1_title3
    # ${found_network_covered_text} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['read_text_title3']}
    # Should Be Equal    "${found_network_covered_text}"    "3. Ensure to be in a network-covered area"
    can_remote_services.DO PRESS START VEHICLE BUTTON DURING    5sec
    # Tap on the done button
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['tap_done_button']}      12
    Sleep    5
    # introduce pin number
    APPIUM_ENTER_TEXT    ${My_Renault['enter_text_in_window']}    ${password}
    Sleep    5
    HIDE_KEYBOARD
    Sleep    5    
    # tap on save
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['tap_on_save']}      30
    Sleep    15
    Return From Keyword If    "${status}"!="Success"
    # Search for text:    "1. You need to turn off your engine"
    ${found_stop_engine} =    APPIUM_GET_TEXT_BY_ID     ${My_Renault['read_text_step_3_1']}    30
    Should Be Equal    "${found_stop_engine}"    "1. You need to turn off your engine"
    # Search for text:    2.Turn on your engine again
    ${found_start_engine} =  APPIUM_GET_TEXT_BY_ID    ${My_Renault['read_text_step_3_2']}
    Should Be Equal    "${found_start_engine}"    "2. Turn on your engine again"
    can_remote_services.DO PRESS START VEHICLE BUTTON DURING    10sec
    Sleep    5
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['tap_on_done_step3']}    15
    Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_ID    ${My_Renault['tap_on_done_step3']}    5
    SCROLL_TO_ELEMENT    ${MyRenault['vehicle_details']}    up    4

CHECK MYRENAULT PINCODE INIT STATUS
    [Arguments]    ${status}
    [Documentation]    Checks as a workaround some text on screen from the MYR application
    ...    status: the status of the PIN CODE INIT
    Run Keyword If    "${status}".lower()!="success"    Fail    Not implemented for variable ${status}
    REFRESH_LAYOUT
    ${notificationtext} =    GET LAST VEHICLE ACTIVITY TIME
    Should Contain    ${notificationtext}    Last vehicle activity    Failed to return to main page

DO ADD CAR INTO MYRENAULT APP ON SMARTPHONE
    [Arguments]    ${vehicle_id}
    ADD_THE_VEHICLE    ${vehicle_id}

SEND MYRENAULT SYNCHRONIZATION REQUEST
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['synchronisation_tab']}    10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['pairing_ivi_connect_button']}   10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['pairing_ivi_begin_button']}   10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['display_code_button']}   10

DO ENTER OTP ON MYRENAULT APP
    RUN KEYWORD IF    ${mobile_driver}    CHECK AND SWITCH DRIVER    ${mobile_driver}
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['otp_view']}     10
    APPIUM_ENTER_TEXT    ${My_Renault['otp_view']}    ${otp_code}
    sleep   20

CHECK MYRENAULT SYNCRONIZATION
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['iunderstood_button']}    15
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['pairing_success_gif']}    15
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

INSTALL APP
    [Documentation]    Installs the application required
    ...    appName: the application name
    [Arguments]    ${appName}
    Log    Keyword INSTALL APP not implemented for the moment    WARN

ADD_THE_VEHICLE
    [Arguments]    ${vehicle_id}
    [Documentation]    == High Level Description: ==
    ...   Add the vehicle to the user in MYR Application
    ...    == Parameters: ==
    ...    vehicle_id: Vehicle id need to be added with the MYR user
    [Tags]    Automated    Add Vehicle in MYR    MY RENAULT APP
    TAP_ON_ELEMENT_USING_XPATH      ${My_Renault['vin_tab']}    10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['add_vehicle_button']}   10
    APPIUM_ENTER_TEXT    ${My_Renault['add_vehicle_button']}   ${vehicle_id}
    HIDE_KEYBOARD
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['submit_button']}   10

PAIR_THE_VEHICLE
    [Documentation]    == High Level Description: ==
    ...   Pair vehicle with the user in MyR Application
    [Tags]    Automated    Vehicle Pairing    MY RENAULT APP
    SEND MYRENAULT SYNCHRONIZATION REQUEST
    GET_OTP_FROM_IVI
    DO ENTER OTP ON MYRENAULT APP
    CHECK MYRENAULT SYNCRONIZATION

SCHEDULE_CHARGE
    [Arguments]    ${days}
    [Documentation]    == High Level Description: ==
    ...    Schedule Charge Preconditioning from MYR
    ...    == Parameters: ==
    ...    days: days to schedule the charge Eg:Mon,Tue
    [Tags]    Automated    EV Services   MY RENAULT APP
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['precondition_tab']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['select_planner']}     10
    @{day_list} =  Split String    ${days}   ,
    FOR  ${day}  IN   @{day_list}
        ${selected_day} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['days']["${day}"]}    checked
        Sleep    2
        Run Keyword If    "${selected_day}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['days']["${day}"]}     10
    END
    TAP_ON_ELEMENT_USING_XPATH   ${My_Renault['hour_picker']}    10
    TAP_ON_ELEMENT_USING_XPATH   ${My_Renault['min_picker']}    10
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['submit_schedule']}    10
    ${switch_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['switch_button']}    checked
    Sleep    5
    Run Keyword If    "${switch_selected}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['switch_button']}    10
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['save_schedule']}    10
    Sleep    40
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    GET_NOTIFY_FROM_MOBILE    The information was sent to the vehicle. A notification will be sent to you.     True

LAUNCH AND LOGOUT THE APPLICATION
    [Documentation]    == High Level Description: ==
    ...   Launches the MyR One Valid android application and if Login make Logout
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell input keyevent 82
    LAUNCH_MYRENAULT_APP    ${mobile_appPackage}    ${mobile_activityName}
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    Log To Console     MyRenault App started
    Sleep    10
    HIDE_KEYBOARD
    Sleep    2
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['iunderstand_xpath']}   10
    Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['iunderstand_xpath']}    5
    ${status} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['title_privacy']}    20
    Run Keyword If    ${status} == ${True}    TAP_ON_ELEMENT_USING_ID      ${My_Renault['allow_cookies']}    10
    ${status} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['sign_in']}    20
    Return From Keyword If    ${status} == ${True}
    ${status} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['car_bottom_tab']}    15
    Run Keyword If    ${status} == ${True}    LOGOUT_APPLICATION

CHECK TIME TAKEN FOR MYRENAULT REMOTE REQUEST
    [Arguments]    ${wait_time}=${00}
    [Documentation]    == High Level Description: ==
    ...    Set Current Timestamp
    ...    output: send current time to the function call
    ${processed_time} =    robot.libraries.DateTime.Subtract Date from Date    @{end_time}    @{start_time}
    ${convert} =    robot.libraries.DateTime.Subtract Time From Time    ${processed_time}    ${wait_time}
    log to console    TOTAL PROCESSED TIME IS ${convert}
    [Return]    ${convert}

CHECK MYR DISTANCE TEXT
   [Arguments]    ${distance_travelled}
   [Documentation]    == High Level Description: ==
    ...   Checks for the Vehicle Distance Travelled and  Distance text displayed in MyR One Valid android application
    ...    == Parameters: ==
    ...    vehicle_autonomy: Autonomy value to send through can and to be reflected in MyR (Eg:150)
   [Tags]    Automated    Check Autonomy in Vehicle and MYR    MY RENAULT APP
   REFRESH_LAYOUT
   ${text_retrieved_autonomy} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['distance_text']}
   Should Contain    ${text_retrieved_autonomy}    ${distance_travelled}

GET_NOTIFY_FROM_MOBILE
    [Arguments]    ${text}    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Gets the notification appears on the Mobile.
    ...    == Parameters: ==
    ...    text: Votre charge a commencé,Votre charge est terminée
    ...    expected_status: True,False
    REFRESH_LAYOUT
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 1
    Sleep    5
    ${notify_presence} =   APPIUM_WAIT_FOR_XPATH    //android.widget.TextView[contains(@text,'${text}')]    25
    ${notification_text} =   Run Keyword If  ${notify_presence}==True   APPIUM_GET_TEXT    //android.widget.TextView[contains(@text,'${text}')]
    ...    ELSE    Set Variable    ${None}
    Log To Console    ${notification_text}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Run Keyword If    ${expected_status} == True    Should Contain    ${notification_text}    ${text}
    ...    ELSE IF    ${expected_status} == False    Should Be Equal    ${notification_text}    ${None}

ESTIMATE CHARGE TIME LEFT
    [Arguments]    ${time_left_to_finish_charge}
    [Documentation]    Verify the estimated time left fits the one sent as parameter
    ${text_retrieved} =   Wait Until Keyword Succeeds    80s    2s    APPIUM_GET_TEXT    ${My_Renault['charge_time_left']}
    Should Be Equal As Strings    ${text_retrieved}    ${time_left_to_finish_charge}

CHECK MYRENAULT CHARGE STATUS UPDATE
    [Arguments]    ${device}    ${expected_status}
    [Documentation]    Checks the values displayed on the screen of the MYR app after the
    ...      values have been properly set using can
    CHECK PLUGSTATUS    Plugged in    True
    # search for BATTERY LEVEL 70%
    # search for charge is in progress
    CHECK CHARGE STATUS AND BATTERY PERCENTAGE    70    charge_in_progress    True
    # search for Full charge in 00:20
    ESTIMATE CHARGE TIME LEFT    00:20
    # search for 201 km
    CHECK_AUTONOMY_TEXT    201

DELETE VEHICLE
    [Documentation]    == High Level Description: ==
    ...   Delete with no reason selected in MYR Application
    FOR    ${i}    IN RANGE    0    5
        Sleep    10
        SCROLL_TO_ELEMENT    ${My_Renault['delete_vehicle']}    down    3
        ${result} =    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_ID      ${My_Renault['delete_vehicle']}      10
        Return From Keyword If    '${result}[0]' == "FAIL"
        Sleep    1s
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['yes_button']}    4
        Sleep    5
    END

CHECK MYRENAULT APP HVAC LAUNCH OPTION
    [Arguments]    ${state}=active
    [Documentation]    == High Level Description: ==
    ...   To check the AC launch option is active with the option to launch.
    ...   Note that, the battery level should be more than 0% for this step to be success.
    REFRESH_LAYOUT
    ${hvac_text_find} =    APPIUM_WAIT_FOR_XPATH   ${My_Renault['hvac_text']}    20
    Run Keyword If    "${hvac_text_find}" == "False"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
    ${text} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['hvac_text']}   10
    Run Keyword If    "${state}" == "active"    Should Contain Any    ${text}    air-condition    launch    ELSE IF    "${state}" == "inactive"    Should Contain    "${text}"    in progress

SEND MYRENAULT APP REQUEST HVAC
    [Documentation]    == High Level Description: ==
    ...    Sends HVAC preconditioning start request to vehicle from MyRenault APP
    ${hvac_button_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['hvac_button']}    20
    Run Keyword If    ${hvac_button_find}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['hvac_button']}    20
    ...    ELSE    Run Keyword If    ${hvac_button_find}==False    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['hvac_button']}    20

CHECK MYRENAULT APP REQUEST AVAILABLE
    [Arguments]    ${searched_string}    ${state_expected}
    [Documentation]    == High Level Description: ==
    ...   Checks if button for selected request is enabled or disabled and return the status
    ...    == Parameters: ==
    ...    searched_string: air-condition, open/close, identify my vehicle, launch
    ...    state_expected: enabled, disabled
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['scroll_button']}    10
    ${find_button} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.renault.myrenault.one.valid:id/tvLabel' and (@text='${searched_string}')]    20
    IF    "${find_button}" == "False" and "${elmt}" == "True"
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
        ${fi_btn} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.renault.myrenault.one.valid:id/tvLabel' and (@text='${searched_string}')]    20
        Should be True    ${fi_btn}
    END
    ${state_present} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //*[@resource-id='com.renault.myrenault.one.valid:id/tvLabel' and (@text='${searched_string}')]    enabled
    Run Keyword If    "${state_expected}" == "enabled"    Should Be Equal    ${state_present}    true
    Run Keyword If    "${state_expected}" == "disabled"    Should Be Equal    ${state_present}    false

LAUNCH MYRENAULT APP ACTION
    [Arguments]    ${action}
    [Documentation]    == High Level Description: ==
    ...   Press the action button if present and return the status
    ...    == Parameters: ==
    ...    action: air-condition, open/close, identify my vehicle, launch
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['scroll_button']}    10
    ${find_button} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.renault.myrenault.one.valid:id/tvLabel' and (@text='${action}')]    20
    IF    "${find_button}" == "False" and "${elmt}" == "True"
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
        ${fi_btn} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.renault.myrenault.one.valid:id/tvLabel' and (@text='${action}')]    20
        Should be True    ${fi_btn}
    END
    TAP_ON_ELEMENT_USING_XPATH    //*[@resource-id='com.renault.myrenault.one.valid:id/tvLabel' and (@text='${action}')]    20

CHECK MYRENAULT NOTIF STATUS
    [Arguments]    ${status}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    == High Level Description: ==
    ...    Check MyR APP shows success message for HVAC preconditioning start requested by the user.
    ...    == Parameters: ==
    ...    status: status of the action. success/fail
    Sleep    15
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 1
    Sleep    5

    IF    "${smartphone_platform_version}" != "12"
        ${notify_presence} =   APPIUM_WAIT_FOR_XPATH    ${My_Renault['My_renault_text']}    15    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        Should Be True    ${notify_presence}    Fail to retrieve the pop-up
    END

    ${notify_presence} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['Myr_notification_succed']}    15    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Run Keyword If    "${status}".lower() == "success" and "${notify_presence}" == "True"
    ...    Should Be True    ${notify_presence}    Fail to retrieve the text from pop-up
    ${notify_presence} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['Myr_notification_failed']}    15    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Run Keyword If    "${status}".lower() == "failed" and "${notify_presence}" == "True"
    ...    Should Be True    ${notify_presence}    Fail to retrieve the text from pop-up
    Sleep    5
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 2
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

CHECK MYRENAULT HVAC COMPLETED
    REFRESH_LAYOUT
    Sleep    20
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 2
    ${text} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['label_ID']}
    Should Contain Any    ${text}    launch    air-condition    HVAC FAILED

SET SP LOCATION STATUS
    [Arguments]    ${state}
    [Documentation]    Set location ON/OFF on SP
    Run Keyword If    "${state}"=="on"    SET GPS STATUS    ${mobile_adb_id}    on
    ...    ELSE IF    "${state}"=="off"    SET GPS STATUS    ${mobile_adb_id}    off

SET SP AIRPLANE MODE
    [Arguments]    ${state}
    [Documentation]    Set location ON/OFF on SP
    Run Keyword If    "${state}"=="on"    Run Keywords
    ...    OperatingSystem.Run    adb -s ${mobile_adb_id} shell settings put global airplane_mode_on 1
    ...    AND    SET WIFI STATUS    ${mobile_adb_id}    off
    ...    AND    OperatingSystem.Run    adb -s ${mobile_adb_id} shell svc data disable
    ...    ELSE IF    "${state}"=="off"    Run Keywords
    ...    OperatingSystem.Run    adb -s ${mobile_adb_id} shell settings put global airplane_mode_on 0
    ...    AND    SET WIFI STATUS    ${mobile_adb_id}    on
    ...    AND    OperatingSystem.Run    adb -s ${mobile_adb_id} shell svc data enable

ENTER DESTINATION ON SP
    [Arguments]    ${dest_address}
    [Documentation]    Enter the destination address and search EPOI there
    ...    == Parameters: ==
    ...    dest_address: The Required destination address to be searched in SP
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['destination_address']}    10
    Sleep    2
    APPIUM_ENTER_TEXT    ${My_Renault['destination_address_enter']}      ${dest_address}
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['first_search_for_destination']}    10

SEARCH AND VERIFY EPOI ON SP
    [Arguments]    ${available_epoi_address}=${None}
    [Documentation]    Select EPOI select button and check the hard coded EPOI address if provided
    ...    == Parameters: ==
    ...    available_epoi_address: The address of one epoi available and active
    Log    ${available_epoi_address}
    ${search_element} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['search_area_button']}    10
    Run Keyword If    "${search_element}"=="True"    TAP_ON_ELEMENT_USING_ID      ${My_Renault['search_area_button']}    10
    ...    ELSE    TAP_ON_ELEMENT_USING_ID      ${My_Renault['epoi_search_button']}    10
    Sleep    15
    Run Keyword If    "${available_epoi_address}" != "None"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['first_epoi_button']}    10
    ${epoi_address} =    Run Keyword If    "${available_epoi_address}" != "None"    APPIUM_GET_TEXT    ${My_Renault['top_pannel_address']}
    ...    ELSE    APPIUM_GET_TEXT    ${My_Renault['no_epoi_available']}
    Run Keyword If    "${available_epoi_address}" != "None"    Should Be Equal    ${epoi_address}    ${available_epoi_address}
    ...    ELSE    Should Be Equal    "${epoi_address}"    "Sorry no result found"

SLIDE IN MAP WITH POSITION
    [Documentation]    Slide in the Navigation map to some random location
    swipe_by_coordinates    530    1060    100    500    2000

CHECK MOBILE LOCATION
    [Documentation]    Tap on the location button to see the mobile location
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['mobile_location']}    10

SET AND VERIFY FILTERS ON PLUG TYPE AND CHARGING POWER ON SP
    [Arguments]    ${available_epoi_address}    ${needed_filters_plug}    ${needed_filters_charging_power}
    [Documentation]    Search in the new area for EPOI and verify it with button
    ...    == Parameters: ==
    ...    available_epoi_address: The address of one epoi available and active
    ...    needed_filters_plug: The list of filters needed in plug type
    ...    needed_filters_charging_power: The list of filters needed in charging power
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['filter_button']}    10
    FOR    ${each}    IN RANGE    1    5
        ${text_charge_type} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]/android.widget.TextView
        ${charging_power_visibility} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]/android.widget.TextView    selected
        Run Keyword If    "${text_charge_type}" in ${needed_filters_charging_power} and "${charging_power_visibility}" != "true"
        ...    TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]    20
        ...    ELSE IF    "${charging_power_visibility}" == "true"    TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]    20
    END
    TAP_ON_BUTTON    ${My_Renault['plug_filter']}    20
    FOR    ${each}    IN RANGE    1    16
        ${text_plug_type} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.TextView
        Run Keyword If    "${text_plug_type}" not in ${needed_filters_plug}
        ...   TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]    20
        Run Keyword If    ${each}==6    SCROLL_TO_ELEMENT    //android.widget.TextView[@text='Tesla']    down    3
    END
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['see_results_button']}    10
    Sleep    5
    Run Keyword If    "${available_epoi_address}" != "None"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['first_epoi_button']}    10
    ${epoi_address} =    Run Keyword If    "${available_epoi_address}" != "None"    APPIUM_GET_TEXT    ${My_Renault['top_pannel_address']}
    ...    ELSE    APPIUM_GET_TEXT    ${My_Renault['no_epoi_available']}
    Run Keyword If    "${available_epoi_address}" != "None"    Should Be Equal    ${epoi_address}    ${available_epoi_address}
    ...    ELSE    Should Be Equal    "${epoi_address}"    "Sorry no result found"
    ${charging_power} =    Run Keyword If    "${available_epoi_address}" != "None"     GET EPOI CHARGING POWER

GET EPOI CHARGING POWER
    [Documentation]    Get the charging power value for selected EPOI
    swipe_by_coordinates    500    2000    600    20    1000
    ${epoi_charging_power} =    APPIUM_GET_TEXT    ${My_Renault['epoi_connector_power']}
    Log To Console    The epoi charging power: ${epoi_charging_power} which is in range selected
    Log    The epoi charging power: ${epoi_charging_power} which is in range selected
    swipe_by_coordinates    600    288    500    2000    1000
    [Return]    ${epoi_charging_power}

SET FILTERS ON PLUG TYPE ONLY ON SP
    [Arguments]    ${available_epoi_address}    ${needed_filters_plug}
    [Documentation]    Search in the new area for EPOI and verify it with button
    ...    == Parameters: ==
    ...    available_epoi_address: The address of one epoi available and active
    ...    needed_filters_plug: The list of filters needed in plug type
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['filter_button']}    10
    TAP_ON_BUTTON    ${My_Renault['plug_filter']}    20
    FOR    ${each}    IN RANGE    1    16
        ${text_plug_type} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.TextView
        Run Keyword If    "${text_plug_type}" not in ${needed_filters_plug}
        ...   TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]    20
        Run Keyword If    ${each}==6    SCROLL_TO_ELEMENT     //android.widget.TextView[@text='Tesla']    down    3
    END
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['see_results_button']}    10
    Sleep    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['first_epoi_button']}    10
    ${epoi_address} =    Run Keyword If    "${available_epoi_address}" != "None"    APPIUM_GET_TEXT    ${My_Renault['top_pannel_address']}
    ...    ELSE    APPIUM_GET_TEXT    ${My_Renault['no_epoi_available']}
    Run Keyword If    "${available_epoi_address}" != "None"    Should Be Equal    ${epoi_address}    ${available_epoi_address}
    ...    ELSE    Should Be Equal    "${epoi_address}"    "Sorry no result found"

CHECK EPOI AVAILABILITY STATUS
    [Arguments]    ${needed_availability_status}
    [Documentation]    Check the Availability of the EPOI selected
    ...    == Parameters: ==
    ...    available_epoi_address: The address of one epoi available and active
    swipe_by_coordinates    500    2000    600    20    1000
    ${unknown_plug_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['unknown_plug_status']}    enabled
    ${reserved_plug_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['reserved_plug_status']}    enabled
    ${available_plug_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['available_plug_status']}    enabled
    Run Keyword If    "${needed_availability_status}" == "Unknown"    Should Be Equal    "${unknown_plug_visibility}"    "true"
    ...    ELSE IF    "${needed_availability_status}" == "Occupied"    Should Be Equal    "${reserved_plug_visibility}"    "true"
    ...    ELSE IF    "${needed_availability_status}" == "Available"    Should Be Equal    "${available_plug_visibility}"    "true"

SEND REFRESH CAR POSITION VEHICLE DISCONNECTED
    [Arguments]    ${goto_map}=False
    [Documentation]    == High Level Description: ==
    ...   Check for the car is refreshed in MyR One Valid android application and vehicle position is not find
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['warning_popup']}    10
    Run Keyword If    "${elmt}" == "False"    Run Keywords
    ...    TAP_ON_BUTTON    ${My_Renault['map_navigation']}    10
    ...    AND    Sleep    5
    ...    AND    TAP_ON_BUTTON    ${My_Renault['vehicle_position']}    10
    ...    AND    Sleep    5
    VALIDATE DATA SHARING OFF TEXT
    TAP_ON_BUTTON    ${My_Renault['understand_btn_vehicle_disconnected']}    10
    Sleep    5
    Run Keyword If    "${goto_map}" == "True"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    10
    ...    AND    Sleep    5
    ...    AND    TAP_ON_BUTTON    ${My_Renault['understand_btn_vehicle_disconnected']}    10

FETCH DETAILED INFORMATION OF EPOI ON SP
    [Arguments]    ${needed_result_epoi_name}=${None}
    [Documentation]    Get the Detailed Information of the EPOI selected
    ...    == Parameters: ==
    ...    available_epoi_address: The address of one epoi available and active
    ${epoi_address} =    Run Keyword If    "${needed_result_epoi_name}" != "None"    APPIUM_GET_TEXT    ${My_Renault['top_pannel_address']}
    ...    ELSE    APPIUM_GET_TEXT    ${My_Renault['no_epoi_available']}
    Run Keyword If    "${needed_result_epoi_name}" != "None"    Should Be Equal    ${epoi_address}    ${needed_result_epoi_name}
    ...    ELSE    Should Be Equal    "${epoi_address}"    "Sorry no result found"
    swipe_by_coordinates    500    2000    600    20    1000
    ${detailed_available_information} =    Create Dictionary
    ${EPOI_distance} =    APPIUM_GET_TEXT    ${My_Renault['distance_value_epoi']}
    ${EPOI_full_address} =    APPIUM_GET_TEXT    ${My_Renault['full_address_epoi']}
    ${EPOI_name_plug} =    APPIUM_GET_TEXT    ${My_Renault['name_plug_epoi']}
    ${EPOI_charging_power} =    APPIUM_GET_TEXT    ${My_Renault['epoi_connector_power']}
    ${unknown_plug_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['unknown_plug_status']}    enabled
    ${reserved_plug_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['reserved_plug_status']}    enabled
    ${available_plug_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['available_plug_status']}    enabled
    ${EPOI_availability} =    Set Variable If     "${unknown_plug_visibility}" == "true"    Unknown
    ...    "${reserved_plug_visibility}" == "true"    Occupied    "${available_plug_visibility}" == "true"    Available
    Set To Dictionary    ${detailed_available_information}    Selected_EPOI_Distance    ${EPOI_distance}
    ...    Selected_EPOI_full_address    ${EPOI_full_address}
    ...    Selected_EPOI_name_plug    ${EPOI_name_plug}
    ...    Selected_EPOI_charging_power    ${EPOI_charging_power}    Selected_EPOI_availability    ${EPOI_availability}
    [Return]    ${detailed_available_information}

CHANGE WIFI STATE
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    Sets the wifi connectivity, swipe down notifications menu and deactivate the mobile connectivity
    ...    == Parameters: ==
    ...    state: on/off based on the input state wifi will change
    swipe_by_coordinates    200    20    200    800    2000
    Sleep    3
    swipe_by_coordinates    400    200    400    1100    2000
    Sleep    5
    Run Keyword If    "${state}"=="on"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['wifi_button_off']}    10
    ...    ELSE    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['wifi_button_on']}    10
    Sleep    5
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    4
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    4

CHECK CHARGE NOTIF SERVICE NOT ENABLED
    [Documentation]    Checks the state of Charge Notif service from the OEM app
    ...    == Parameters: ==
    ...    status: enabled/disabled based on the input status notification will change
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['profile_bottom_tab']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['my_notifications_tab']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['bcb_ccs2_tab_vehicle']}    10
    Sleep    5
    ${result} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['toast_message_banner']}    90
    Should Be True    ${result}

CHARGE NOTIFICATION STATE IN OEM
    [Arguments]    ${state}
    [Documentation]    turn off the charge Notifications in OEM App
    ...    == Parameters: ==
    ...    state: on/off based on the input state notification will change
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['profile_bottom_tab']}      10
    Sleep     5
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['my_notifications_tab']}      10
    Sleep     5
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['bcb_ccs2_tab_vehicle']}      10
    Sleep     5
    ${current_notification_state} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['charge_switch_button']}    checked
    Log To Console    ${current_notification_state}
    Run Keyword If    "${state}"=="on" and "${current_notification_state}"=="false"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['charge_switch_button']}    5
    ...    ELSE IF    "${state}"=="off" and "${current_notification_state}"=="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['charge_switch_button']}    5
    ${submit_button_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['notif_submit_button']}    enabled
    TAP_ON_BUTTON    ${My_Renault['notif_submit_button']}    5
    ${elem} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['toast_message_banner']}    90
    ${notificationtext} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT    ${My_Renault['toast_message_banner']}
    Run Keyword If    "${submit_button_status}"=="true"    Should Be Equal   "${notificationtext}"    "Your modifications have been saved."
    ...    ELSE    Should Be Equal   "${notificationtext}"    "None"
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['car_bottom_tab']}    5

RESET NOTIFICATIONS ON OEM
    [Documentation]    Turn off and Turn on notifications in MyR App
    ...    == Parameters: ==
    ...    state: on/off based on the input state notification will change
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['profile_bottom_tab']}      10
    Sleep     5
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['my_notifications_tab']}      10
    Sleep     5
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['bcb_ccs2_tab_vehicle']}      10
    Sleep     5
    ${current_notification_remote} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['remote_charging_button']}    checked
    Log To Console    ${current_notification_remote}
    Run Keyword If    "${current_notification_remote}"=="false"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['remote_charging_button']}    5
    ...    ELSE    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['remote_charging_button']}    5
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['remote_charging_button']}    5
    ${current_notification_charge} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['charge_switch_button']}    checked
    Log To Console    ${current_notification_charge}
    Run Keyword If    "${current_notification_charge}"=="false"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['charge_switch_button']}    5
    ...    ELSE    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['charge_switch_button']}    5
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['charge_switch_button']}    5
    ${submit_button_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['notif_submit_button']}    enabled
    TAP_ON_BUTTON    ${My_Renault['notif_submit_button']}    5
    ${notificationtext} =    APPIUM_GET_TEXT    ${My_Renault['toast_message_banner']}    90
    log to console    ${notificationtext}
    Should Be Equal   "${notificationtext}"    "Your modifications have been saved."
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['car_bottom_tab']}    5

GET LAST VEHICLE ACTIVITY TIME
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['time_on_car_xpath']}    10
    ${notificationtext} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT_USING_XPATH   ${My_Renault['time_on_car_xpath']}
    [Return]    ${notificationtext}

CHECK VEHICLE NOT CONNECTED
    [Arguments]    ${state}=true
    [Documentation]    == High Level Description: ==
    ...   Checks vehicle connectivity in MY Renault app
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['warning_popup']}    10
    Run Keyword If    "${elmt}" == "True"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['warning_popup_click']}    30
    Sleep    30
    REFRESH_LAYOUT
    ${notificationtext} =    GET LAST VEHICLE ACTIVITY TIME
    @{notif_list} =    Create List    Vehicle not connected    Last vehicle activity:${SPACE}${SPACE}-    Last vehicle activity:${SPACE}-
    ${verdict} =    Evaluate    "${notificationtext}" in @{notif_list}
    Should be true    ${verdict}    Vehicle is connected!

NAVIGATE TO THE CAR WITH GOOGLE MAPS
    [Documentation]    == High Level Description: ==
    ...   Check the Route to the car with Google Maps
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    30
    Sleep    15
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    30
    Sleep    2
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['refresh_button']}    20
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['speed_dial_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['open_with_default_app']}    10
    sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['google_maps_direction_button']}    10
    sleep    5
    ${time} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['maps_time_estimation']}
    ${distance} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['maps_distance_estimation']}
    Should Contain    ${time}    min    ESTIMATION TIME FAILED
    Should Contain Any    ${distance}    km    m    DISTANCE FAILED

SETUP NEW DEVICE FOR APPIUM
    [Arguments]    ${device_id}
    [Documentation]    == High Level Description: ==
    ...   Set new device for appium
    rfw_services.ivi.AndroidDriverLib.Setup Device    ${device_id}

SWITCH FROM PROFILE TAB TO VEHICLE TAB
    [Documentation]    Switch from Profile tab to vehicle tab in the bottom of Navigation bar
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['profile_bottom_tab']}      10
    Sleep     5
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['car_bottom_tab']}    5

CHECK MYRENAULT CLIMATE CONTROL SETTINGS
    [Arguments]    ${planned}
    [Documentation]    == High Level Description: ==
    ...   Check in MyR One Valid android application have the HVAC planned
    ...    == Parameters: ==
    ...    _planned_: no_plan, two_plans, four_plans
    Run Keyword If    "${planned}" == "no_plan"    NO PLANNED HVAC CALENDARS
    ...    ELSE IF    "${planned}" == "two_plans" or "${planned}" == "two_calendars_hvac" or "${planned}" == "four_plans" or "${planned}" == "one_plan"   PLANNED HVAC CALENDARS    ${planned}
    ...    ELSE    FAIL    Profile "${planned}" doesn't exist

ADD SECOND HVAC CALENDAR
    [Documentation]    == High Level Description: ==
    ...    Add new HVAC planner in MyR One Valid in second spot.
    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['hvac_menu']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['monday_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['friday_button']}    10
    TAP_ON_BUTTON    ${My_Renault['hvac_validate_button']}    10
    ${elem} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['second_hvac_on_off_schedule']}    checked
    Run Keyword If    "${elem}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['second_hvac_on_off_schedule']}   10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['save_hvac_schedule_button']}    10
    Sleep    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_back_button']}    10

NO PLANNED HVAC CALENDARS
    [Documentation]    == High Level Description: ==
    ...   Check in MyR One Valid android application don't have the HVAC planned
    Sleep    2
    REFRESH_LAYOUT
    Sleep    2
    ${element_hvac} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['hvac_plan']}    10
    ${check_plan_hvac} =    Run Keyword If    "${element_hvac}" == "True"   APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['hvac_plan']}
    Run Keyword If    """Programming: Disabled""" in """${check_plan_hvac}"""   Log    We don't have any plan!
    ...    ELSE    Run Keywords
    ...    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    ...    AND    DELETE PLANS FROM PHONE
    ...    AND    REFRESH_LAYOUT
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

PLANNED HVAC CALENDARS
    [Arguments]    ${planned}
    [Documentation]    == High Level Description: ==
    ...   Check in MyR One Valid android application have two calendars planned
    REFRESH_LAYOUT
    ${length} =    Get Length    ${My_Renault_calendars['${planned}']}
    ${element} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['pre_conditioning_hvac']}    10
    Run Keyword If    "${element}" == "True"    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    FOR    ${each}    IN    1    ${length}
        ${planner_mode} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    checked
        Should Contain    "${planner_mode}"    "true"
        ${start_time} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.TextView[2]
        Should Contain    ${My_Renault_calendars['${planned}']['calendar${each}']['hour']}    ${start_time}
        ${retrieved_text} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.TextView[3]
        ${selected_days} =    Run Keyword If    "${retrieved_text}" == "at"    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.TextView[5]
        ...    ELSE    Set Variable    ${retrieved_text}
        Should Contain    ${selected_days}    ${My_Renault_calendars['${planned}']['calendar${each}']['days']}
    END
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

SWIPE TO TIME MyR
    [Arguments]    ${time}    ${hour_or_min}=hour    ${xpath_default_hour_or_min}=${None}    ${top_xpath_hour_or_min}=${None}    ${bottom_xpath_hour_or_min}=${None}    ${calendar_type}=scheduled
    [Documentation]     Set start time hour for charge management program
    ...    == Parameters ==:
    ...    time : value of the hour you want to set
    ...    hour_or_min: parameter used to select hour or minutes in calendar
    ...    xpath_default_hour_or_min: select the start time or end time default hour or minutes
    ...    top_xpath_hour_or_min : select hour or minute top button for start time or end time
    ...    bottom_xpath_hour_or_min : select hour or minute bottom button for start time or end time
    ...    calendar_type: selects the type of calendar that will be set
    ...    == Expected Result ==: Hour is set correctly if this is executed.
    ${get_hour} =       APPIUM_GET_TEXT_USING_XPATH     ${xpath_default_hour_or_min}
    ${convert_hour} =    Convert To Integer    ${get_hour}
    Return From Keyword If    ${time} - ${convert_hour} == 0
    ${direction} =    Set Variable    no_direction
    ${nr_taps} =    Set Variable    ${0}
    ${direction} =    Set Variable If    ${time} > ${convert_hour}    down    up
    ${nr_taps} =    Run Keyword If    ${time} > ${convert_hour}    Evaluate    (${time} - ${convert_hour})
    ...     ELSE    Evaluate    (${convert_hour} - ${time})
    FOR    ${i}    IN RANGE    0   ${nr_taps}
        Run Keyword If      "${direction}" == "up"    Run Keywords
        ...     TAP_ON_ELEMENT_USING_XPATH    ${top_xpath_hour_or_min}    10
        ...     AND    Sleep    0.2
        ...     ELSE IF     "${direction}" == "down"    Run Keywords
        ...     TAP_ON_ELEMENT_USING_XPATH    ${bottom_xpath_hour_or_min}    10
        ...     AND    Sleep    0.2
    END
    ${get_hour} =       APPIUM_GET_TEXT_USING_XPATH     ${xpath_default_hour_or_min}
    ${convert_hour} =    Convert To Integer    ${get_hour}
    Run Keyword if      ${convert_hour} - ${time} == 0
    ...    Log    The hour was successfully set.

DISABLED DAYS MyR
    [Arguments]    @{days}
    [Documentation]    Disabled the days @{days} from MyR program
    ...    All days are enabled by default, we need to disabled the unnecessary ones
    ${button_check} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['choose_all_days']}    checked
    Run Keyword If    "${button_check}" == "false"    TAP_ON_BUTTON    ${My_Renault['choose_all_days']}    10
    FOR    ${i}    IN    @{days}
        Log     ${i}
        Return From Keyword If    "${i}" == ""
        ${is_checked} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['days_hvac']["${i}"]}    checked
        Run Keyword If    "${is_checked}" == "false"    APPIUM_TAP_XPATH    ${My_Renault['days_hvac']["${i}"]}
        Sleep    0.5
    END

SET MYRENAULT CLIMATE CONTROL SETTINGS
    [Arguments]    ${planned}
    [Documentation]    == High Level Description: ==
    ...   Set in MyR One Valid android application the HVAC planned
    ...    == Parameters: ==
    ...    _planned_: set_two_plan
    REFRESH_LAYOUT
    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    Run Keyword If    "${planned}" == "set_two_calendars"    SET TWO PLAN HVAC CALENDARS
    ...    ELSE IF    "${planned}" == "set_one_calendar"    SET ONE PLAN HVAC CALENDAR
    ...    ELSE    FAIL    Profile "${planned}" doesn't exist

SET ONE PLAN HVAC CALENDAR
    [Documentation]    == High Level Description: ==
    ...   Set in MyR One Valid android application two calendars
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HVAC    IVI CMD
    APPIUM_TAP_XPATH    ${My_Renault['program_one']}
    Sleep    1
    SWIPE TO TIME MyR    00    min    ${My_Renault['hvac_start_min']}    ${My_Renault['hvac_min_top_button']}    ${My_Renault['hvac_min_bottom_button']}    ${None}
    SWIPE TO TIME MyR    14    hour    ${My_Renault['hvac_start_hour']}    ${My_Renault['hvac_hour_top_button']}    ${My_Renault['hvac_hour_bottom_button']}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['choose_all_days']}    10
    ${days_off} =    CREATE LIST    Thu    Tue    Sat    Sun
    DISABLED DAYS MyR    @{days_off}
    Sleep    0.5
    TAP_ON_BUTTON    ${My_Renault['submit_program']}    10
    Sleep    0.5

    ${switch_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['switch_button']}    checked
    Sleep    5
    Run Keyword If    "${switch_selected}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['switch_button']}    10
    ${retrieved_text} =    APPIUM_GET_TEXT    ${My_Renault['save_schedule']}
    Run Keyword If    "${retrieved_text}.lower()" == "save"   TAP_ON_BUTTON    ${My_Renault['save_schedule']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from program

    Sleep    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    Sleep    15

SET TWO PLAN HVAC CALENDARS
    [Documentation]    == High Level Description: ==
    ...   Set in MyR One Valid android application two calendars
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HVAC    IVI CMD
    APPIUM_TAP_XPATH    ${My_Renault['program_one']}
    Sleep    1
    ${element} =     WAIT ELEMENT BY XPATH    ${My_Renault['hvac_current_meridiem']}    10
    IF   "${element}" == "True"
        SWIPE TO TIME MyR    15    min    ${My_Renault['hvac_start_min']}    ${My_Renault['hvac_min_top_button']}    ${My_Renault['hvac_min_bottom_button']}
        SWIPE TO TIME MyR    10    hour       ${My_Renault['hvac_start_hour']}    ${My_Renault['hvac_hour_top_button']}    ${My_Renault['hvac_hour_bottom_button']}
        SWIPE TO MERIDIEM MyR    ${My_Renault['hvac_current_meridiem']}    ${My_Renault['hvac_meridiem_navigate']}
    ELSE
        SWIPE TO TIME MyR    15    min    ${My_Renault['hvac_start_min']}    ${My_Renault['hvac_min_top_button']}    ${My_Renault['hvac_min_bottom_button']}
        SWIPE TO TIME MyR    10    hour       ${My_Renault['hvac_start_hour']}    ${My_Renault['hvac_hour_top_button']}    ${My_Renault['hvac_hour_bottom_button']}
    END

    ${days_off} =    CREATE LIST    Wed    Thu    Fri    Sat    Sun
    DISABLED DAYS MyR    @{days_off}
    Sleep    0.5
    TAP_ON_BUTTON    ${My_Renault['submit_program']}    10
    Sleep    0.5

    ${switch_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['switch_button']}    checked
    Sleep    5
    Run Keyword If    "${switch_selected}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['switch_button']}    10

    APPIUM_TAP_XPATH    ${My_Renault['program_two']}
    Sleep    1
    IF   "${element}" == "True"
        SWIPE TO TIME MyR    30    min    ${My_Renault['hvac_start_min']}    ${My_Renault['hvac_min_top_button']}    ${My_Renault['hvac_min_bottom_button']}
        SWIPE TO TIME MyR    11    hour   ${My_Renault['hvac_start_hour']}    ${My_Renault['hvac_hour_top_button']}    ${My_Renault['hvac_hour_bottom_button']}
        SWIPE TO MERIDIEM MyR    ${My_Renault['hvac_current_meridiem']}    ${My_Renault['hvac_meridiem_navigate']}    PM
    ELSE
        SWIPE TO TIME MyR    30    min    ${My_Renault['hvac_start_min']}    ${My_Renault['hvac_min_top_button']}    ${My_Renault['hvac_min_bottom_button']}
        SWIPE TO TIME MyR    23    hour   ${My_Renault['hvac_start_hour']}    ${My_Renault['hvac_hour_top_button']}    ${My_Renault['hvac_hour_bottom_button']}
    END

    ${days_off} =    CREATE LIST    Mon    Tue   Fri    Sat    Sun
    DISABLED DAYS MyR    @{days_off}
    Sleep    0.5
    TAP_ON_BUTTON    ${My_Renault['submit_program']}    10
    Sleep    5

    ${switch_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['switch_button2']}    checked
    Sleep    5
    Run Keyword If    "${switch_selected}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['switch_button2']}    10

    ${retrieved_text} =    APPIUM_GET_TEXT    ${My_Renault['save_schedule']}
    Run Keyword If    "${retrieved_text}.lower()" == "save"    TAP_ON_BUTTON    ${My_Renault['save_schedule']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from program
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    Sleep    15

DELETE PLANS FROM PHONE
    FOR    ${each}    IN RANGE    1    5
        ${text_preconditioning} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch
        Exit For Loop If    "${text_preconditioning}"=="OFF"
        TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    20
    END
    Sleep    5
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['save_schedule']}    10
    ${element} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['deactivate_plan']}    5
    Run Keyword If    "${element}" == "True"    TAP_ON_BUTTON    ${My_Renault['deactivate_plan']}    5
    Sleep    15

SET CHARGE MODE INSTANT
	[Documentation]    setting the charge mode instant in OEM App
	CHECK AND SWITCH DRIVER    ${mobile_driver}
	Sleep    10
	TAP_ON_ELEMENT_USING_ID    ${My_Renault['chargeScheduleButton']}    10
	Sleep    2
	TAP_ON_ELEMENT_USING_ID    ${My_Renault['instant_charge']}    10
	TAP_ON_ELEMENT_USING_ID    ${My_Renault['save_schedule']}    10
	Sleep    20
	TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}  10
	Sleep    5

SET CHARGE CUSTOMIZE MANAGEMENT
    [Arguments]    ${days}
    [Documentation]    setting the customize charge schedule in OEM App
    ...    == Parameters: ==
    ...    days: days to schedule the charge Eg:Mon,Tue
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    Sleep    10
    REFRESH_LAYOUT
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['chargeScheduleButton']}    20
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['customized_schedule']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['customize_program_1_tab']}    20
    Sleep     3
    ${allday_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['choose_all_days']}    checked
    Run Keyword If    "${allday_status}"=="true"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['choose_all_days']}    30
    ...    ELSE IF    "${allday_status}"=="false"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['choose_all_days']}    30
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['choose_all_days']}    30
    Sleep    3
    @{day_list} =  Split String    ${days}   ,
    FOR  ${day}  IN   @{day_list}
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['days']["${day}"]}     10
    END
    SWIPE TO TIME MyR    ${My_Renault_calendars['one_calendar']['calendar1']['start_min']}    min    ${My_Renault['start_time_min']}
    ...     ${My_Renault['st_min_top_button']}    ${My_Renault['st_min_bottom_button']}    ${None}
    SWIPE TO TIME MyR    ${My_Renault_calendars['one_calendar']['calendar1']['start_hour']}    hour    ${My_Renault['start_time_hour']}
    ...     ${My_Renault['st_hour_top_button']}    ${My_Renault['st_hour_bottom_button']}    ${None}
    SWIPE TO TIME MyR    ${My_Renault_calendars['one_calendar']['calendar1']['end_min']}    min    ${My_Renault['end_time_min']}
    ...     ${My_Renault['et_min_top_button']}    ${My_Renault['et_min_bottom_button']}    ${None}
    SWIPE TO TIME MyR    ${My_Renault_calendars['one_calendar']['calendar1']['end_hour']}    hour    ${My_Renault['end_time_hour']}
    ...     ${My_Renault['et_hour_top_button']}    ${My_Renault['et_hour_bottom_button']}    ${None}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['submit_schedule']}    10
    ${switch_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['switch_button']}    checked
    Sleep    5
    Run Keyword If    "${switch_selected}"!="true"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['switch_button']}    10
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['save_schedule']}    20
    Sleep    40
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    50
    Sleep    5

SELECT CHARGE HISTORY IN MYR
    [Documentation]    View charge history in MYR application
    ${find_elem} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${My_Renault['charge_history_tab']}    direction=down
    Run Keyword If    "${find_elem}"!="True"    Fail    Charge history is not displayed
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['charge_history_tab']}      10
    Sleep     5
    ${total_charging_numbers} =    APPIUM_GET_TEXT    ${My_Renault['total_charge_numbers']}
    Log To Console    ${total_charging_numbers}
    ${total_charging_duration} =    APPIUM_GET_TEXT    ${My_Renault['total_charging_durations']}
    ${total_charging_duration} =    Replace String    "${total_charging_duration}"    m    ${Empty}
    Log To Console    ${total_charging_duration}
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    [Return]     ${total_charging_numbers}    ${total_charging_duration}

CHECK SCHEDULED CHARGE
    [Arguments]    ${start_time}    ${end_time}    ${days}    ${program_number}
    [Documentation]    Check a particular schedule is synchonized in MyR
    ...    == Parameters: ==
    ...    start_time: start time of the schedule Eg:21:15
    ...    end_time: end time of the schedule Eg:23:15
    ...    days: days to schedule the charge Eg:Monday,Tuesday
    CHECK AND SWITCH DRIVER   ${mobile_driver}
    REFRESH_LAYOUT
    ${mode_check} =     APPIUM_GET_TEXT    ${My_Renault['selected_mode']}
    Should Be Equal    "${mode_check}"    "Selected mode: Custom "
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['chargeScheduleButton']}    10
    Sleep     4
    ${button_check} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${program_number}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    checked
    ${required_start_time} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${program_number}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.TextView[2]
    ${required_end_time} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${program_number}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.TextView[4]
    ${required_days} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${program_number}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.TextView[5]
    Should Be Equal   "${required_start_time}"    "${start_time}"
    Should Be Equal   "${required_end_time}"    "${end_time}"
    Should Be Equal   "${required_days}"    "${days}"
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

CHECK SCHEDULE ACTIVATION IN MYR
    [Arguments]    ${schedule_number}    ${status}
    [Documentation]    Check a particular schedule is synchonized in MyR
    ...    == Parameters: ==
    ...    schedule_number: The Schedule number in the list Eg:2
    ...    status: True/False based on checked/unchecked
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    REFRESH_LAYOUT
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['chargeScheduleButton']}    10
    Sleep     4
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['customized_schedule']}    10
    Sleep     3
    ${switch_status} =     APPIUM_GET_ATTRIBUTE_BY_XPATH     //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${schedule_number}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    checked
    Should Be Equal    "${switch_status}"    "${status}"
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

SEARCH AND VERIFY ON MAP FOR PLANNED ROUTE
    [Arguments]    ${battery_percentage}    ${arrival_address}
    [Documentation]    == High Level Description: ==
    ...   Search for the planned route in Map
    ...    == Parameters: ==
    ...    battery_percentage: The battery percentage to get set for the planned route
    ...    arrival_address: The arrival address to get verified on planned route
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['speed_dial']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_fab']}    10
    sleep    2
    ADD PASSENGER TO ERP ITINERARY    1
    sleep    2
    ADD LUGGAGE TO ERP ITINERARY    1
    sleep    2
    SET BATTERY VALUE ON ERP SETTINGS    ${battery_percentage}
    sleep    2
    SELECT AVOID TOLLS ON ERP    check
    sleep    2
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
    sleep    60
    ${itenary_result_text} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['itenary_result_text']}
    ${itenary_arrrival_text} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['itenary_arrrival_text']}
    should contain    ${itenary_result_text}    km    /    including    charge
    should contain    ${itenary_arrrival_text}    Arrival    estimated
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['swipe_button']}    10
    Sleep    2
    ${element} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['arrival_address']}    10
    Run Keyword If    "${element}" == "False"    SCROLL_TO_ELEMENT    ${My_Renault['arrival_address']}    down    5
    ${arrival_details} =    APPIUM_GET_TEXT    ${My_Renault['arrival_address']}
    Should Contain    ${arrival_details}    ${arrival_address}
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

SEND MYRENAULT CHARGE MODE CHANGE REQUEST
    [Arguments]    ${mode}    ${profile}=${None}    ${delayed_hour}=19    ${delayed_min}=50
    [Documentation]    Send request to change 'Charge Mode' to customized mode
    ...    == Parameters: ==
    ...    _mode_: set charge mode, set charge profile
    RUN KEYWORD IF    ${mobile_driver}    CHECK AND SWITCH DRIVER    ${mobile_driver}
    REFRESH_LAYOUT
    Sleep    10s
    ${element} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['chargeScheduleButton']}    15
    Run keyword If    ${element} == True    TAP_ON_ELEMENT_USING_ID     ${My_Renault['chargeScheduleButton']}    15
    Run Keyword If    "${mode}" == "instant"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['charge_mode_instant']}    10
    ...    ELSE IF    "${mode}" == "delayed"    SEND DELAYED CHARGE REQUEST    ${delayed_hour}    ${delayed_min}
    ...    ELSE IF    "${mode}" == "scheduled"    SET MY RENAULT CALENDARS    ${profile}
    ...    ELSE    Fail    Profile not existing
    TAP_ON_ELEMENT_USING_ID    ${My_renault['save_schedule']}    10
    Sleep    35
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

SEND MYR MULTIPLE SCHEDULED CHARGE REQUESTS
    [Arguments]    ${profile}    ${number_of_loops}    ${max_calendars}=5
    [Documentation]    Sends multiple scheduled requests.
    ...     == Parameters: ==
    ...     profile: calendar provived.
    ...     number_of_loops: number of charge requests that will be made.
    sleep    5
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['chargeScheduleButton']}    10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['charge_mode_customized']}    10
    FOR    ${each}    IN RANGE    1    ${number_of_loops}
        EXIT FOR LOOP IF    ${each} > ${max_calendars}
        ${check_prog} =    APPIUM_WAIT_FOR_XPATH    //android.widget.TextView[@resource-id='com.renault.myrenault.one.valid:id/tv_schedule_title' and contains(@text, 'Program ${each}')]    10
        Run keyword if    "${check_prog}" == "False"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=//android.widget.TextView[@resource-id='com.renault.myrenault.one.valid:id/tv_schedule_title' and contains(@text, 'Program ${each}')]    direction=down    scroll_tries=10
        TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[@resource-id='com.renault.myrenault.one.valid:id/tv_schedule_title' and contains(@text, 'Program ${each}')]    10
        ${days_off} =    Split String    ${My_Renault_calendars['${profile}']['calendar1']['days']}     ,
        DISABLED DAYS MyR    @{days_off}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar1']['start_min']}    min    ${My_Renault['start_time_min']}
        ...     ${My_Renault['st_min_top_button']}    ${My_Renault['st_min_bottom_button']}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar1']['start_hour']}    hour    ${My_Renault['start_time_hour']}
        ...     ${My_Renault['st_hour_top_button']}    ${My_Renault['st_hour_bottom_button']}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar1']['end_min']}    min    ${My_Renault['end_time_min']}
        ...     ${My_Renault['et_min_top_button']}    ${My_Renault['et_min_bottom_button']}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar1']['end_hour']}    hour    ${My_Renault['end_time_hour']}
        ...     ${My_Renault['et_hour_top_button']}    ${My_Renault['et_hour_bottom_button']}
        TAP_ON_ELEMENT_USING_ID     ${My_Renault['submit_schedule']}    10
    END
    TAP_ON_ELEMENT_USING_ID     ${My_renault['save_schedule']}      10
    Sleep   30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    ACTIVATE ALL MYR CALENDARS

ACTIVATE ALL MYR CALENDARS
    [Documentation]    This kw is used to turn on all the calendars available in MyR app
    REFRESH_LAYOUT
    sleep    5
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['chargeScheduleButton']}    10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['charge_mode_customized']}    10
    FOR    ${i}    IN    1    2
        ${plan_status} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    checked
        Run Keyword if      "${plan_status}" == "false"
        ...     TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    10
        ...     ELSE    Log     Program is already on.
    END
    ${check_next_cal} =    APPIUM_WAIT_FOR_XPATH    //android.widget.Switch[@resource-id='com.renault.myrenault.one.valid:id/switch_button' and @checked='false']    10
    Run keyword if    "${check_next_cal}" == "False"    SCROLL_TO_ELEMENT    //android.widget.Switch[@resource-id='com.renault.myrenault.one.valid:id/switch_button' and @checked='false']    down    3
    FOR    ${i}    IN RANGE    1    4
        ${plan_status} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    checked
        Run Keyword if      "${plan_status}" == "false"
        ...     TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    10
        ...     ELSE    Log     Program is already on.
    END
    TAP_ON_ELEMENT_USING_ID     ${My_renault['save_schedule']}      10
    Sleep   10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

CHECK EXTRA CALENDARS CANNOT BE ADDED
    [Documentation]    This keyword is used to check that the app doesn't allow user to create more than 5 calendars.
    REFRESH_LAYOUT
    sleep    5
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['chargeScheduleButton']}    10
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['charge_mode_customized']}    10
    ${check_prog} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['unavailable_calendar']}    10
    ${verdict} =    Run keyword if    "${check_prog}" == "False"    SCROLL_TO_ELEMENT    ${My_Renault['unavailable_calendar']}
    Should not be true    ${verdict}
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

SET MY RENAULT CALENDARS
    [Arguments]    ${profile}
    [Documentation]    Set charge calendars on My Renult app
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['charge_mode_customized']}    10
    ${length} =    Get Length    ${My_Renault_calendars['${profile}']}
    FOR    ${each}    IN RANGE    1    ${length}
        TAP_ON_ELEMENT_USING_XPATH    //android.view.ViewGroup/androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]    10
        ${days_off} =    Split String    ${My_Renault_calendars['${profile}']['calendar${each}']['days']}     ,
        DISABLED DAYS MyR    @{days_off}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar${each}']['start_min']}    min    ${My_Renault['start_time_min']}
        ...     ${My_Renault['st_min_top_button']}    ${My_Renault['st_min_bottom_button']}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar${each}']['start_hour']}    hour    ${My_Renault['start_time_hour']}
        ...     ${My_Renault['st_hour_top_button']}    ${My_Renault['st_hour_bottom_button']}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar${each}']['end_min']}    min    ${My_Renault['end_time_min']}
        ...     ${My_Renault['et_min_top_button']}    ${My_Renault['et_min_bottom_button']}
        SWIPE TO TIME MyR    ${My_Renault_calendars['${profile}']['calendar${each}']['end_hour']}    hour    ${My_Renault['end_time_hour']}
        ...     ${My_Renault['et_hour_top_button']}    ${My_Renault['et_hour_bottom_button']}
        TAP_ON_ELEMENT_USING_ID     ${My_Renault['submit_schedule']}    10
        ${plan_status}=    APPIUM_GET_ATTRIBUTE_BY_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    checked
        Run Keyword if      "${plan_status}" == "false"
        ...     TAP_ON_ELEMENT_USING_XPATH      //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${each}]/android.widget.FrameLayout/android.view.ViewGroup/android.widget.Switch    10
        ...     ELSE    Log     Program is already on.
    END

CHECK MYRENAULT ELEMENT IS CLICKABLE
    [Arguments]    ${element}    ${state}
    [Documentation]    Check element not active on MY Renault app
    ...    == Parameters: ==
    ...    _element_: element to be checked if active on MY Renault app
    ...    _state_: true/false
    ${resource_id} =    Set Variable If    "${element}" == "delayed"    ${My_Renault['chargeScheduleButton']}    FAIL    Only 'delayed' is currently supported for the element argument.
    ${ret} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${resource_id}    clickable
    Should Be Equal    ${state}    ${ret}

CHECK MYR CHARGE HISTORY VALUE
    [Arguments]    ${status}    ${charge_numbers}    ${charge_duration}
    [Documentation]    Check whether MyR app have some charge history or showing empty results based on status
    ...    == Parameters: ==
    ...    status: The Expected status for value(Eg: true if value should be there, False if privacy on)
    ...    charge_numbers: The Number of charge fetched from MyR app
    ...    charge_duration: The duration of charge fetched from MyR app
    REFRESH_LAYOUT
    Run Keyword If    "${status}"=="True"    Should Not Be Equal    "-"    "${charge_numbers}"
    ...    Should Not be Equal    "-"    "${charge_duration}"
    ...    ELSE IF    "${status}"=="False"    Should Be Equal    "-"    "${charge_numbers}"
    ...    Should Be Equal    "-"    "${charge_duration}"
    REFRESH_LAYOUT

CHECK MYRENAULT APP VEHICLE
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    This keyword is used to check if vehicle is present in MY Renault application.
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    LAUNCH_MYRENAULT_APP    ${mobile_appPackage}    ${mobile_activityName}
    Sleep    10
    Log To Console     MyRenault App started
    SCROLL_TO_ELEMENT    ${MyRenault['vehicle_details']}    down    4
    TAP_ON_ELEMENT_USING_XPATH    ${MyRenault['vehicle_details']}    10
    sleep    2
    ${get_VIN} =    APPIUM_GET_TEXT_USING_XPATH    //android.widget.TextView[@resource-id='com.renault.myrenault.one.valid:id/informations_row_value' and contains(@text, '${vehicle_id}')]
    ${vehicle_status} =    Run Keyword If    "${get_VIN}" != " "    Set Variable    present
    ...    ELSE    Set Variable    not_present
    Run Keyword if    "${vehicle_status}" == "${status}"    Log    Vehicle is present in MyR app.
    ...    ELSE    Fail    Vehicle is not present in MyR app.
    TAP_ON_ELEMENT_USING_XPATH    ${MyRenault['back_button']}    10
    SCROLL_TO_ELEMENT    ${My_Renault['time_on_car']}    up    3

DO IVI CREATE MYRENAULT ACCOUNT
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to create MyRenault account.
    log to console    DO IVI CREATE MYRENAULT ACCOUNT keyword is not implemented.

SELECT ON ERP BUTTON
    [Documentation]    User selects on the ERP button
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['speed_dial']}    10
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_fab']}    10

ENTER VEHICLE LOCATION ON SP
    [Arguments]    ${vehicle_location_on_sp}
    [Documentation]    Entering vehicle location on the ERP itinerary page
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['cancel_button_on_vehicle_location']}    10
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['vehicle_location']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_location_enter']}    10
    Sleep    2
    APPIUM_ENTER_TEXT    ${My_Renault['vehicle_location_enter']}    ${vehicle_location_on_sp}
	Sleep    2
	TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['first_search_source_address']}    10

AVAILABLE INFORMATION ON ERP ITINERARY
    [Arguments]    ${battery_percentage}
    [Documentation]    Enter the vehicle location on SP and search
    ADD PASSENGER TO ERP ITINERARY    1
    sleep    2
    ADD LUGGAGE TO ERP ITINERARY    1
    sleep    2
    SET BATTERY VALUE ON ERP SETTINGS    ${battery_percentage}
    sleep    2
    SUBMIT AND VIEW ERP ITINERARY
    Sleep    2
    ${available_information_on_itinerary} =    Create Dictionary
    @{epoi_lists} =    Create List
    ${departure_details} =    APPIUM_GET_TEXT    ${My_Renault['departure_address']}
    ${count} =    Set Variable    0
    FOR    ${i}    IN RANGE    2     15
        SCROLL_TO_ELEMENT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]    down    3
        ${element} =     APPIUM_WAIT_FOR_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]    10
        Exit For Loop If    "${element}"=="False"
        ${epoi_element} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]
        Append To List    ${epoi_lists}    ${epoi_element}
        ${count} =    Evaluate    ${count} + 1
    END
    ${arrival_details} =    APPIUM_GET_TEXT    ${My_Renault['arrival_address']}
    Set To Dictionary    ${available_information_on_itinerary}    Selected_departure_details    ${departure_details}
    ...    Selected_arrival_details    ${arrival_details}    Selected_epoi_count    ${count}    Selected_epois    ${epoi_lists}
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    [Return]    ${available_information_on_itinerary}

CHECK DEPARTURE AND ARRIVAL INFO ON ERP INFO
    [Arguments]    ${available_information_on_itinerary}    ${departure}    ${arrival}
	[Documentation]    Checking the given departure and arrival details with available information details
	Log    ${available_information_on_itinerary}
	${departure_value} =    Run Keyword And Return Status    Should Contain    ${available_information_on_itinerary['Selected_departure_details']}    ${departure}
	${arrival_value} =    Run Keyword And Return Status    Should Contain    ${available_information_on_itinerary['Selected_arrival_details']}    ${arrival}
    Run Keyword If    '${departure_value}' == 'True' and '${arrival_value}' == 'True'    Pass Execution    Departure and arrival details are matched
    ...    ELSE    Fail    Departure and arrival Details are not matched

SELECT AVOID TOLLS ON ERP
    [Arguments]    ${condition}
    [Documentation]     Selecting the avoid motor ways based on the condition
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_modify_route']}    10
    ${checkbox_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['itenary_avoid_tolls']}    checked
    Run Keyword If    "${condition}"=="check" and "${checkbox_status}"=="false"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_avoid_tolls']}    5
    ...    ELSE IF    "${condition}"=="uncheck" and "${checkbox_status}"=="true"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_avoid_tolls']}    5
    Sleep    3
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10

SET CHARGE MODE DELAYED
    [Documentation]    setting the delayed charge schedule in OEM App
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['chargeScheduleButton']}    10
	TAP_ON_ELEMENT_USING_ID    ${My_Renault['delayed_schedule']}    20
	TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['schedule_delay_charge']}    20
    TAP_ON_ELEMENT_USING_XPATH   ${My_Renault['min_picker']}    20
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['delay_submit_button']}    20
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['save_schedule']}    20
    Sleep    40
	TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
	REFRESH_LAYOUT
	Sleep    10

SELECT CHARGE PLUGS ON ITINERARY
    [Arguments]    ${needed_charge_plugs}
    [Documentation]    Select the charge plugs that are given as inputs in list
    ...    == Parameters: ==
    ...    needed_charge_plugs: The list containing the needed filters for filtering
    SCROLL_TO_ELEMENT    ${My_Renault['socket_title']}    down    3
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['modify_plug']}    10
    FOR    ${each}    IN RANGE    1    7
        ${text_plug_type} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]/android.widget.TextView
        ${element_find} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]    selected
        Run Keyword If   "${element_find}"!="false" and "${text_plug_type}" not in ${needed_charge_plugs}    TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]    20
        Run Keyword If   "${element_find}"!="true" and "${text_plug_type}" in ${needed_charge_plugs}    TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.widget.LinearLayout[${each}]    20
    END
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
    SCROLL_TO_ELEMENT    ${My_Renault['header_title']}    up    3

CHECK DEPARTURE IS SAME AS VEHICLE LOCATION
    [Arguments]    ${available_information_on_itinerary}    ${departure}
    [Documentation]    Checking the departure location is same as the vehicle location
    ...    == Parameters: ==
    ...    available_information_on_itinerary: The dictionary containing the departure, arrival and charging stations details and count
    ...    departure: The departure address that the user givem for verification
    ${departure_value} =    Run Keyword And Return Status    Should Contain    ${available_information_on_itinerary['Selected_departure_details']}    ${departure}
    Run Keyword If    '${departure_value}' == 'True'    Pass Execution    Departure details are matched
    ...    ELSE    Fail    Departure details are not matched

CHECK CHARGING MODE
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if the charging mode is available on MyR App.
    ...    parameter is used to check if information is available or not.
    REFRESH_LAYOUT
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['chargeScheduleButton']}    15
    ${subtitle} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['chargeMode_SubTitle']}
    ${is_enabled} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['chargeMode_SubTitle']}    Enabled
    IF    "${status}".lower() == "available"
        Should Be True    '${is_enabled}' == 'true'
        Should Not Contain    ${subtitle}    Unknown
    ELSE IF    "${status}".lower() == "not available"
        Should Be True    '${is_enabled}' == 'false'
        Should Contain    ${subtitle}    Unknown
    END

CHECK HVAC MODE
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...     Checks if the HVAC service on MyR is activated.
    REFRESH_LAYOUT
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['pre_conditioning_hvac']}    10
    ${subtitle} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['HVAC_SubTitle']}
    ${is_enabled} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['HVAC_SubTitle']}    Enabled
    IF    "${status}".lower() == "available"
        Should Be True    '${is_enabled}' == 'true'
        Should Not Contain    ${subtitle}    Connected data not available
    ELSE IF    "${status}".lower() == "not available"
        Should Be True    '${is_enabled}' == 'false'
        Should Contain    ${subtitle}    Connected data not available
    END

CHECK MYRENAULT APP
    [Arguments]    ${value}
    [Documentation]    This keyword is used to check MyR informations are displayed and have valid values.
    RUN KEYWORD IF    ${mobile_driver}    CHECK AND SWITCH DRIVER    ${mobile_driver}
    IF    "${value}" == "information_enabled"
        CHECK LOCKSTATUS STATE
        CHECK PLUGSTATUS    Plugged in    True
        CHECK CHARGE STATUS AND BATTERY PERCENTAGE    48    charge_in_progress    True
        CHECK MYR DISTANCE TEXT   1 000 km
        CHECK CHARGING MODE    available
        CHECK MYRENAULT APP VEHICLE    present
    ELSE IF    "${value}" == "information_disabled"
        ${status} =    Run Keyword And Return Status    CHECK LOCKSTATUS STATE
        Should Be True    '${status}' == 'False'    Lock Status is Available
        CHECK PLUGSTATUS    Plugged in    False
        CHECK MYR DISTANCE TEXT   Mileage
        CHECK CHARGING MODE    not available
        CHECK HVAC MODE    not available
    END

SELECT AVOID MOTORWAYS ON ERP
    [Arguments]    ${condition}
    [Documentation]     Selecting the avoid motor ways based on the condition
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_modify_route']}    10
    ${checkbox_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['itenary_avoid_motorways']}    checked
    Run Keyword If    "${condition}"=="check" and "${checkbox_status}"=="false"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_avoid_motorways']}    5
    ...    ELSE IF    "${condition}"=="uncheck" and "${checkbox_status}"=="true"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_avoid_motorways']}    5
    Sleep    3
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
    Sleep    3
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10

SELECT ITENARY BACK BUTTON
    [Documentation]    Selecting on the itenary back navigation button
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_back_button']}    10
    Sleep    2

INFORMATION OF ERP ITENARY WITH SPECIFIC OPTION
    [Documentation]    Checking ERP itenary information with selected options
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['swipe_button']}    10
    Sleep    2
    ${available_information_on_itinerary} =    Create Dictionary
    ${departure_details} =    APPIUM_GET_TEXT    ${My_Renault['departure_address']}
    ${arrival_details} =    APPIUM_GET_TEXT    ${My_Renault['arrival_address']}
    ${count} =    Set Variable    0
    @{epoi_station_name} =    Create List
    FOR    ${i}    IN RANGE    2     10
        ${element} =     APPIUM_WAIT_FOR_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]    10
        Exit For Loop If    "${element}"=="False"
        ${element_name} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]
        Log    ${element_name}
        ${count} =    Evaluate    ${count} + 1
        Append To List    ${epoi_station_name}    ${element_name}
    END
    Log    ${epoi_station_name}
    Set To Dictionary    ${available_information_on_itinerary}    Selected_departure_details    ${departure_details}
    ...    Selected_arrival_details    ${arrival_details}    Selected_epoi_count    ${count}
    ...    Selected_epoi_station_name    ${epoi_station_name}
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    [Return]    ${available_information_on_itinerary}

GET BATTERY STATUS IN MYR
	[Documentation]    Getting the vehicle battery status in the MYR application
	REFRESH_LAYOUT
    ${battery_percentage_text} =    APPIUM_GET_TEXT    ${My_Renault['battery_percentage']}    20
	[Return]    ${battery_percentage_text}

GET THE BATTERY STATUS FROM ITINERARY OPTIONS PAGE
	[Documentation]    Getting the battery status in the EPR itenary page
	TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_modify_battery']}    10
	Sleep    2
    ${erp_battery_percentage} =    APPIUM_GET_TEXT    ${My_Renault['erp_options_percentage']}    20
	TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
	Sleep    2
	[Return]    ${erp_battery_percentage}

GET THE BATTERY STATUS OF PLAN A ROUTE PAGE IN ITINERARY
	[Documentation]    Getting the battery percentage from the plan a route page in the itinerary
	TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
	Sleep    60
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['swipe_button']}    10
	Sleep    2
    ${departure_percentage_text} =    APPIUM_GET_TEXT    ${My_Renault['departure_battery_percentage']}    20
    ${remove_space_departure_percentage_text} =    Remove String    ${departure_percentage_text}    ${SPACE}
	Sleep    2
	TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
	[Return]    ${remove_space_departure_percentage_text}

SET TIME FORMAT FOR SMARTPHONE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...     Setting time format on smartphone.
    ...     parameter value is used to select type format (12/24)
    ${smartphone_driver} =    CREATE APPIUM DRIVER    Settings    smartphone    ${smartphone_adb_id}    11
    SCROLL_TO_ELEMENT    ${SmartPhone['general_management']}    down    5
    APPIUM_TAP_XPATH    ${SmartPhone['general_management']}
    sleep    0.5
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${SmartPhone['date_and_time_xpath']}    10
    Run Keyword If    ${elemt}==True    APPIUM_TAP_XPATH    ${SmartPhone['date_and_time_xpath']}    10
    sleep    0.5
    ${retrieve_text} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${SmartPhone['time_format']}    checked
    Run Keyword If    "${value}" == "12" and "${retrieve_text}" == "true"    APPIUM_TAP_XPATH    ${SmartPhone['time_format']}
    Run Keyword If    "${value}" == "24" and "${retrieve_text}" == "false"    APPIUM_TAP_XPATH    ${SmartPhone['time_format']}
    REMOVE APPIUM DRIVER    ${smartphone_capabilities}

CHECK VEHICLE LOCATION NOT SHOWN IN MYR
    [Documentation]    Check vehicle location icon not found when vehicle not linked
    TAP_ON_BUTTON    ${My_Renault['map_navigation']}    10
    Sleep    5
    ${location_element} =     APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['vehicle_position']}    10
    Should Not Be True    ${location_element}

CHECK CHARGING STOPS NOT AVAILABLE IN ERP
    [Documentation]    CHECK CHARGING STOPS NOT AVAILABLE IN ERP when vehicle is not paired
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['swipe_button_without_stop']}    10
    Sleep    2
    ${source_address} =    APPIUM_GET_TEXT    ${My_Renault['source_location']}
    Should Not Be Empty    ${source_address}
    ${destination_address} =    APPIUM_GET_TEXT    ${My_Renault['destination_location']}
    Should Not Be Empty    ${destination_address}
    ${disclaimer_text} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['disclaimer_text']}    20
    Should Be True    ${disclaimer_text}
    ${distance_text} =    APPIUM_GET_TEXT    ${My_Renault['distance_value_trip']}
    @{distance_text_split} =    Split String    ${distance_text}   /
    ${distance_value} =    Replace String    ${distance_text_split}[1]    ${space}    ${Empty}
    ${distance_only_value} =    Replace String    ${distance_value}    km    ${Empty}
    ${distance_value_integer} =    Convert To Integer    ${distance_only_value}
    Log To Console    ${distance_value_integer}
    Should Be True    ${distance_value_integer}>300

CHECK NO VEHICLE IS ADDED IN ACCOUNT
    [Documentation]    Check no vehicle is added to the account
    ${elem_found} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['vin_tab']}    20
    Should Be True    ${elem_found}    The Account should be a Fresh one with no vehicle added

SET BATTERY VALUE ON ERP SETTINGS
    [Arguments]    ${battery_percentage}
    [Documentation]    Set the battery status in the EPR itenary page to the given value
    ...    == Parameters: ==
    ...    battery_percentage: Battery percentage to be set on the itinerary page
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_modify_battery']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['itenary_charge_text']}    ${battery_percentage}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10

CHECK DEPARTURE AT REQUIRED LOCATION
    [Arguments]    ${required_location}
    [Documentation]    Check departure is at phone or vehicle location based on condition
    ...    == Parameters: ==
    ...    required_location: Vehicle/Smartphone - which location we expect as departure in ERP
    ${departure_value} =    APPIUM_GET_TEXT    ${My_Renault['vehicle_location']}
    Sleep    5
    Run Keyword If    "${required_location}"=="Vehicle"    Should Be Equal    "${departure_value}"    "Vehicle location"
    ...    ELSE    Should Be Equal    "${departure_value}"    "My location"

ADD PASSENGER TO ERP ITINERARY
    [Arguments]    ${add_Passenger}
    [Documentation]    Add passengers to ERP itinerary
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_modify_passenger']}    10
    FOR    ${each}    IN RANGE    1    5
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_remove']}    10
        ${elem} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['least_passenger']}    10
        Exit For Loop If    ${elem}==True
    END
    FOR    ${x}    IN RANGE    ${add_Passenger}
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_add_passenger']}    10
        Sleep    1
    END
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
    Sleep    3

ADD LUGGAGE TO ERP ITINERARY
    [Arguments]    ${add_Luggages}
    [Documentation]    Add luggagess to ERP itinerary
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itenary_modify_luggage']}    10
    FOR    ${each}    IN RANGE    1    5
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_remove']}    10
        ${elem} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['least_luggage']}    10
        Exit For Loop If    ${elem}==True
    END
    FOR    ${y}    IN RANGE    ${add_Luggages}
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_add_luggage']}    10
        Sleep    1
    END
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
    Sleep    3

SUBMIT AND VIEW ERP ITINERARY
    [Documentation]    Submit and generate ERP itinerary
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['itenary_submit_button']}    10
    Sleep    60
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['swipe_button']}    10
    Sleep    2

GET DISTANCE COVERED FOR ERP
    ${erp_kms} =    APPIUM_GET_TEXT    ${My_Renault['departure_to_arrival_distance_and_time']}
    Log To Console    ${erp_kms}
    SELECT ITENARY BACK BUTTON
    [Return]    ${erp_kms}

VERIFY CAR LOCATION IN ERP ITINERARY
    [Arguments]    ${default_location}
    [Documentation]    To verify car location in ERP itinerary
    ${EPOI_address} =    APPIUM_GET_TEXT    ${My_Renault['full_address_epoi']}
    log to console    ${EPOI_address}
    SELECT ITENARY BACK BUTTON
    Should Contain    ${EPOI_address}    ${default_location}

CHECK PLANE A ROUTE WITH LOCATION STATUS
    [Arguments]    ${location_status}
    [Documentation]    == High Level Description: ==
    ...     Setting location status and plane a route
    ...     parameter value is used to select the location status (on/off)
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['home_car']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    10
    IF    "${location_status}"=="off"
        SET SP LOCATION STATUS    off
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['decline_activation_location']}    10
        Sleep    2
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    10
        Sleep    2
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['speed_dial_button']}    10
        Sleep    2
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['plan_route']}    10
        ${result} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['warning_banner']}    10
        Should Be True    ${result}
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button_plan_route']}    10
    END
    IF    "${location_status}"=="on"
        SET SP LOCATION STATUS    on
    END

SEND DELAYED CHARGE REQUEST
    [Arguments]     ${hour}    ${min}
    [Documentation]    Sends a MY Renault delayed charge time
    ...    == Parameters: ==
    ...   _delayed_: time when the charge should start
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['charge_mode_delayed']}    10
    ${ele_present} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['schedule_a_delayed_charge']}    10
    Run Keyword If    "${ele_present}" == "True"   TAP_ON_ELEMENT_USING_ID    ${My_Renault['schedule_a_delayed_charge']}    10
    ...    ELSE    TAP_ON_ELEMENT_USING_ID    ${My_Renault['start_time_id']}    10
    #Check if submit button is active
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['check_delay_submit_button']}    20
    Run Keyword If    "${verdict}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['delayed_min_top_button']}    10
    SWIPE TO TIME MyR    ${min}   min    ${My_Renault['delayed_start_min']}    ${My_Renault['delayed_min_top_button']}    ${My_Renault['delayed_min_bottom_button']}    delayed
    SWIPE TO TIME MyR    ${hour}   hour    ${My_Renault['delayed_start_hour']}    ${My_Renault['delayed_hour_top_button']}    ${My_Renault['delayed_hour_bottom_button']}
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['delay_submit_button']}    10

CHECK PINCODE NOTIFICATION
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...     Checking the Notification after changing the PIN code
    ...     expected_status: Success/ Fail based on result needed
    ${notificationtext} =    APPIUM_GET_TEXT    ${My_Renault['toast_message_banner']}    90
    log to console    ${notificationtext}
    Run Keyword If    "${expected_status}" == "Success"    Should Be Equal   "${notificationtext}"    "Your PIN code has been registered"
    ...    ELSE    Should Be Equal   "${notificationtext}"    "An error occured during the confirmation of your PIN code. Please try again."
    Run Keyword If    "${expected_status}" != "Success"    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

CHECK MYRENAULT LOCATION PRIVACY ON
    [Documentation]    == High Level Description: ==
    ...   Check for the car location in MyR One Valid android application when the Privacy mode On
    TAP_ON_BUTTON    ${My_Renault['home_car']}    10
    TAP_ON_BUTTON    ${My_Renault['map_navigation']}    10
    Sleep    2
    TAP_ON_BUTTON    ${My_Renault['vehicle_position']}    10
    TAP_ON_BUTTON    ${My_Renault['button_privacy_banner']}    10

CHECK MYRENAULT CHARGE MODE
    [Arguments]    ${charge_mode_expected}
    [Documentation]    == High Level Description: ==
    ...     Checking the charge mode
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['selected_mode']}    20
    ${charge_mode} =    APPIUM_GET_TEXT    ${My_Renault['selected_mode']}
    Should Contain    ${charge_mode}     ${charge_mode_expected}

DETAILED AVAILABLE INFORMATION ON ERP ITINERARY
    [Documentation]    Enter the vehicle location on SP and search
    ${available_information_on_itinerary} =    Create Dictionary
    @{epoi_lists} =    Create List
    ${departure_details} =    APPIUM_GET_TEXT    ${My_Renault['departure_address']}
    ${departure_percentageof_text} =    APPIUM_GET_TEXT    ${My_Renault['departure_battery_percentage']}
    ${departure_to_arrival_distance_and_time_result} =    APPIUM_GET_TEXT    ${My_Renault['departure_to_arrival_distance_and_time']}
    ${count} =    Set Variable    0
    FOR    ${i}    IN RANGE    2     15
        SCROLL_TO_ELEMENT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]    down    3
        ${element} =     APPIUM_WAIT_FOR_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]    10
        Exit For Loop If    "${element}"=="False"
        ${epoi_element} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[1]
        ${epoi_soc_before_charge} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[3]
        ${epoi_soc_after_charge} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[4]
        ${epoi_time_spent_charging} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.TextView[2]
        ${epoi_distance} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.TextView
        TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.view.ViewGroup/android.widget.ImageView[3]    10
        ${epoi_address} =    APPIUM_GET_TEXT    //android.widget.LinearLayout/android.widget.ScrollView/android.view.ViewGroup/android.widget.TextView[3]
        ${epoi_power_text} =    APPIUM_GET_TEXT    //android.view.ViewGroup/androidx.recyclerview.widget.RecyclerView[1]/android.view.ViewGroup/android.widget.TextView
        Append To List    ${epoi_lists}    "epoi_name":${epoi_element}    "epoi_soc_before_charge":${epoi_soc_before_charge}    "epoi_soc_after_charge":${epoi_soc_after_charge}
        ...    "epoi_time_spent_charging":${epoi_time_spent_charging}    "epoi_distance":${epoi_distance}    "epoi_power_output_text":${epoi_power_text}
        ...    "epoi_address":${epoi_address}
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
        ${count} =    Evaluate    ${count} + 1
    END
    ${arrival_details} =    APPIUM_GET_TEXT    ${My_Renault['arrival_address']}
    ${arrival_percentage_of_text} =    APPIUM_GET_TEXT    ${My_Renault['arrival_battery_percentage']}
    ${arrival_estimate_time_text} =    APPIUM_GET_TEXT    ${My_Renault['arrival_estimate_time']}
    Set To Dictionary    ${available_information_on_itinerary}    Selected_departure_details    ${departure_details}
    ...    Selected_arrival_details    ${arrival_details}    Selected_epoi_count    ${count}    Selected_epois    ${epoi_lists}
    ...    Selected_departure_percentageof_text    ${departure_percentageof_text}
    ...    Selected_departure_to_arrival_distance_and_time_result    ${departure_to_arrival_distance_and_time_result}
    ...    Selected_arrival_percentage_of_text    ${arrival_percentage_of_text}    Selected_arrival_estimate_time_text    ${arrival_estimate_time_text}
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    [Return]    ${available_information_on_itinerary}

FETCH AVAILABLE INFORMATION ON GOOGLE MAPS
    [Documentation]    Fetching the available information on google maps
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['itinerary_button_for_maps']}    10
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['swipe_on_maps']}    10
    @{epoi_stations_name} =    Create List
    ${available_information_on_maps} =    Create Dictionary
    ${departure_details_on_maps} =    APPIUM_GET_TEXT    ${My_Renault['departure_on_maps']}
    ${epoi_count_on_maps} =    Set Variable    0
    FOR    ${i}    IN RANGE    2     10
        ${element} =     APPIUM_WAIT_FOR_XPATH    //android.widget.FrameLayout/android.support.v7.widget.RecyclerView/android.widget.LinearLayout[1]/android.widget.LinearLayout[${i}]/android.widget.TextView[2]    10
        Exit For Loop If    "${element}"=="False"
        ${element_name} =     APPIUM_WAIT_FOR_XPATH    //android.widget.FrameLayout/android.support.v7.widget.RecyclerView/android.widget.LinearLayout[1]/android.widget.LinearLayout[${i}]/android.widget.TextView[2]    10
        ${epoi_count_on_maps} =    Evaluate    ${epoi_count_on_maps} + 1
        Append To List    ${epoi_stations_name}    ${element_name}
    END
    ${arrival_details_on_maps} =    APPIUM_GET_TEXT    ${My_Renault['arrival_on_maps']}
    Set To Dictionary    ${available_information_on_maps}    Selected_departure_details_on_maps    ${departure_details_on_maps}
    ...    Selected_arrival_details_on_maps    ${arrival_details_on_maps}    Selected_epoi_count_on_maps    ${epoi_count_on_maps}
    ...    Selected_epoi_stations_name    ${epoi_stations_name}
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['swipe_on_maps']}    10
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_navigation']}    10
    [Return]    ${available_information_on_maps}

CHECK DEPARTURE AND ARRIVAL INFO ON GOOGLE MAPS
    [Arguments]    ${available_information_on_maps}    ${departure}    ${arrival}
    [Documentation]    Checking the given departure and arrival details with available information details
    Log    ${available_information_on_maps}
    ${departure_value} =    Run Keyword And Return Status    Should Contain    ${available_information_on_maps['Selected_departure_details_on_maps']}    ${departure}
    ${arrival_value} =    Run Keyword And Return Status    Should Contain    ${available_information_on_maps['Selected_arrival_details_on_maps']}    ${arrival}
    Run Keyword If    '${departure_value}' == 'True' and '${arrival_value}' == 'True'    Pass Execution    Departure and arrival details are matched
    ...    ELSE    Fail    Departure and arrival details are not matched

SELECT MAP NAVIGATION ON MYR
    [Documentation]    Selecting on map navigation in MYR application
    TAP_ON_BUTTON    ${My_Renault['map_navigation']}    10
    Sleep    5

CHECK MYRENAULT APP HOLDS NEEDED VIN
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    This keyword is used to check if needed vehicle is present in MY Renault application.
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'ADD MY VEHICLE')]
    IF    "${result}" == "True"
        log to console    No paired vehicle
        ${check_vehicle_match} =    Set Variable    wrong
        Return From Keyword    ${check_vehicle_match}
    END
    Sleep    5
    SCROLL_TO_ELEMENT    ${MyRenault['vehicle_details']}    down    3
    TAP_ON_ELEMENT_USING_XPATH    ${MyRenault['vehicle_details']}    10
    sleep    2
    Log To Console    ${vehicle_id}
    ${elem_found} =  APPIUM_WAIT_FOR_XPATH    //*[@text='${vehicle_id}']    10
    ${get_VIN} =    Run Keyword If    "${elem_found}" == "True"    APPIUM_GET_TEXT_USING_XPATH    //*[@text='${vehicle_id}']
    ${vehicle_status} =    Run Keyword If    "${get_VIN}" != " " and "${get_VIN}" == "${vehicle_id}"    Set Variable    present
    ...    ELSE    Set Variable    not_present
    ${check_vehicle_match} =    Run Keyword if    "${vehicle_status}" == "${status}"    Set Variable    correct
    ...    ELSE    Set Variable    wrong
    TAP_ON_ELEMENT_USING_XPATH    ${MyRenault['back_button']}    10
    SCROLL_TO_ELEMENT    ${My_Renault['time_on_car']}    up    3
    [Return]     ${check_vehicle_match}

CHECK VEHICLE PRESENCE AND PAIRING STATUS
    [Arguments]    ${paired_status}
    [Documentation]    This keyword is to check the vehicle presence and pairing status
    REFRESH_LAYOUT
    ${start} =    Set Variable    1
    ${stop} =    Set Variable    6
    FOR    ${i}    IN RANGE    ${start}    ${stop}
        TAP_ON_ELEMENT_USING_ID    ${My_renault['vehicle_selection_button']}    10
        Sleep    2
        ${vin} =    APPIUM_WAIT_FOR_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.TextView[1]   20
        Exit For Loop If    "${vin}"=="False"
        TAP_ON_ELEMENT_USING_XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.TextView[1]    10
        Sleep    10
        ${check_vehicle_match} =    CHECK MYRENAULT APP HOLDS NEEDED VIN    present
        Continue For Loop If    "${check_vehicle_match}"=="wrong"
        Sleep    10
        REFRESH_LAYOUT
        ${paired_element} =    APPIUM_WAIT_FOR_XPATH    ${My_renault['synchronization_tab']}    20
        Run Keyword If    "${paired_status}" == "paired"    Should Be Equal    "${paired_element}"    "False"
        ...    ELSE   Should Be Equal    "${paired_element}"    "True"
        Exit For Loop If    "${check_vehicle_match}"=="correct"
    END

GET MYR CHARGE STATUS
    [Documentation]    Getting charge status of my renault application
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['charge_status']}    20
    Run keyword if    "${verdict}" == "True"    Log    Element found
    ...     ELSE    Fail    Element not found.
    Sleep    10
    ${value} =    APPIUM_GET_TEXT    ${My_Renault['charge_status']}
    ${status} =    Run Keyword If    "${value}" == "Full charge in" or "${value}" == "Charge in progress"    Set Variable    Charge in progress
    [Return]    ${status}

CHECK BUTTON NOT PRESENT
    [Arguments]    ${required_button}
    [Documentation]    == High Level Description: ==
    ...     Checking whether the lock button in MYR is not present
    FOR    ${icon}    IN RANGE    4
        ${element_found} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rlu_rhl_button']}    20
        Should Be True    ${element_found}
        ${value_text} =    APPIUM_GET_TEXT    ${My_Renault['button_text']}
        Run Keyword If    "${required_button}" == "Lockunlock"    Should Not Be Equal    "${value_text}"    "OPEN/CLOSE"
        ...    ELSE IF    "${required_button}" == "Hornlights"    Should Not Be Equal    "${value_text}"    "IDENTIFY MY VEHICLE"
        ${element_found_scroll} =    APPIUM_WAIT_FOR_ELEMENT   ${My_Renault['scroll_button_left']}    20
        Run Keyword If    "${element_found_scroll}" == "True"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button_left']}   10
    END

CHECK REMOTE ACTIONS NOT ENABLED
    [Arguments]    ${required_text}
    [Documentation]    Check RHL or RLU action cant be performed when privacy on
    FOR    ${icon}    IN RANGE    4
        Sleep    5
        ${element_found_scroll} =    APPIUM_WAIT_FOR_XPATH   ${My_Renault['button_text']}    20
        ${value_text} =    Run Keyword If    "${element_found_scroll}" == "True"    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['button_text']}   10
        Exit For Loop If     "${value_text}" == "${required_text}"
        Sleep    5
        ${element_found_scroll} =    APPIUM_WAIT_FOR_ELEMENT   ${My_Renault['scroll_button']}    20
        Run Keyword If    "${element_found_scroll}" == "True"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}   10
        ${element_found} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['rlu_rhl_button']}    20
        Should Be True    ${element_found}
    END
    TAP_ON_ELEMENT_USING_XPATH    ${My_renault['rlu_rhl_button']}    10
    TAP_ON_BUTTON    ${My_Renault['understand_btn_vehicle_disconnected']}    10

CHECK HVAC OPTION NOT ENABLED
    [Documentation]    Check Pre-conditioning tab is not enabled when privacy on
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['warning_popup']}    10
    Run Keyword If    "${elmt}" == "True"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['warning_popup_click']}    10
    ${tab_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['precondition_tab']}    enabled
    Should Be Equal    "false"    "${tab_visibility}"

DEACTIVATE HVAC SCHEDULE IN MYR
    [Documentation]    == High Level Description: ==
    ...   Make the MyR One Valid android application to deactivate all schedules
    Sleep    2
    REFRESH_LAYOUT
    Sleep    2
    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    DELETE PLANS FROM PHONE
    Sleep    4
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

CHECK CHARGING MODE OPTION NOT ENABLED
    [Documentation]    Check the charging mode tab is not enabled when privacy on
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['iunderstand_xpath']}   10
    Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['iunderstand_xpath']}    5
    ${tab_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['charging_mode']}    enabled
    Should Be Equal    "false"    "${tab_visibility}"

CHECKSET SMARTPHONE DATA PLAN
    [Arguments]    ${status}
    [Documentation]    Verified we have on/off one channel connection
    LAUNCH_MYRENAULT_APP    com.android.settings    .homepage.SettingsHomepageActivity
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${SmartPhone['connections']}    20
    swipe_by_coordinates    350    150    350    300    1000
    sleep    2
    ${value} =    APPIUM_GET_TEXT    ${SmartPhone['wi-fi_off']}
    Run Keyword If    "${value}" == "On"    APPIUM_TAP_XPATH    ${SmartPhone['wi-fi_off']}
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['data_usage']}
    sleep    2
    ${value} =    APPIUM_GET_TEXT    ${SmartPhone['mobile_data']}
    Run Keyword If    "${value}" != "${status}"    APPIUM_TAP_XPATH    ${SmartPhone['mobile_data']}
    sleep    2
    ${output} =    OperatingSystem.Run    adb -s ${mobile_adb_id} shell dumpsys telephony.registry | grep -E "mDataConnectionState"
    ${eval} =    Evaluate   "mDataConnectionState=2" in """${output}"""
    SHOULD BE TRUE    "${eval}" == "True"    Failed... we don't have connection mobile data.
    sleep    2
    MOBILE START INTENT    -n com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity

SET SMARTPHONE HOTSPOT
    [Arguments]    ${status}    ${name_hotspot}    ${password_hotspot}
    [Documentation]    Try on/off one channel connection to the phone ex:hotspot
    Run Keyword If    "${name_hotspot}" == "None" or "${password_hotspot}" == "None"    Fail    No credentials for network
    MOBILE START INTENT    -n com.android.settings/.homepage.SettingsHomepageActivity
    TAP_ON_ELEMENT_USING_XPATH    ${SmartPhone['connections']}    20
    swipe_by_coordinates    350    150    350    300    1000
    sleep    2
    ${value} =    APPIUM_GET_TEXT    ${SmartPhone['wi-fi_off']}
    Run Keyword If    "${value}" == "On"    APPIUM_TAP_XPATH    ${SmartPhone['wi-fi_off']}
    swipe_by_coordinates    350    300    350    150    1000
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['hotspot_tethering']}
    sleep    2
    ${value} =    APPIUM_GET_TEXT    ${SmartPhone['switch_hotspot']}
    Run Keyword If    "${value}" != "${status}"    APPIUM_TAP_XPATH    ${SmartPhone['switch_hotspot']}
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['mobile_hotspot']}
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['configure_hotspot']}
    sleep    2
    TAP_ON_ELEMENT_USING_ID      ${SmartPhone['ssid_edit']}    10
    APPIUM_ENTER_TEXT    ${SmartPhone['ssid_edit']}    ${name_hotspot}
    sleep    2
    HIDE_KEYBOARD
    TAP_ON_ELEMENT_USING_ID      ${SmartPhone['password_edit']}    10
    APPIUM_ENTER_TEXT    ${SmartPhone['password_edit']}    ${password_hotspot}
    Log To Console   Password entered
    HIDE_KEYBOARD
    sleep    2
    TAP_ON_ELEMENT_USING_ID    ${SmartPhone['save_hotspot']}    10
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['navigate_up']}
    sleep    2
    MOBILE START INTENT    -n com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity

CHECKSET SMARTPHONE INTERNET TRAFFIC
    [Documentation]    Try on/off one channel connection to the browser ex:internet
    CHECK AND SWITCH DRIVER   ${mobile_driver}
    Sleep    5
    Log to console    RUN APP _ CONNECTIONS
    LAUNCH_MYRENAULT_APP    com.android.settings    .homepage.SettingsHomepageActivity
    sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${SmartPhone['connections']}    20
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['hotspot_tethering']}
    sleep    2
    APPIUM_TAP_XPATH    ${SmartPhone['mobile_hotspot']}
    sleep    2
    ${output} =    APPIUM_GET_TEXT    ${SmartPhone['connected_devices']}
    ${eval} =    Evaluate   "No devices" in """${output}"""
    Run Keyword If    "${eval}" == "False"    APPIUM_TAP_XPATH    ${SmartPhone['connected_devices']}
    ...    ELSE    Fail    Don't have connected devices.
    sleep    5
    MOBILE START INTENT    -n com.sec.android.app.launcher/com.sec.android.app.launcher.activities.LauncherActivity

SEND INSTANT HVAC FROM MYR
    sleep   10
    APPIUM_TAP_XPATH    ${My_Renault['instant_hvac']}

CHECK HVAC IN PROGRESS
    [Documentation]    Check HVAC button is in progress
    ...    -expected output -: == Passed/failed
    ${hvac_inprogress} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['hvac_button_inprogress']}    selected
    Should Be True    "${hvac_inprogress}".lower() == "false"    HVAC is not in progress

CHANGE TIME VALUE ON MYR APP
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...     Changing the time value on app
    ...     parameter value is used to select time setting on / off
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    LAUNCH APP APPIUM    Settings    Smartphone
    SCROLL_TO_ELEMENT    ${SmartPhone['system']}    down    5
    APPIUM_TAP_XPATH    ${SmartPhone['system']}
    sleep    0.5
    APPIUM_TAP_XPATH    ${SmartPhone['date_and_time']}
    sleep    0.5
    ${retrieve_text} =    APPIUM_GET_TEXT_USING_XPATH    ${SmartPhone['time_change']}
    Run Keyword If    "${value}" == "on" and "${retrieve_text}" == "Off"    APPIUM_TAP_XPATH    ${SmartPhone['time_change']}
    Run Keyword If    "${value}" == "off" and "${retrieve_text}" == "ON"    APPIUM_TAP_XPATH    ${SmartPhone['time_change']}
    Run Keyword If    "${value}" == "off"    Run Keywords
    ...    APPIUM_TAP_XPATH    ${My_Renault['setting_time']}
    ...    AND    APPIUM_TAP_XPATH    ${My_Renault['set_time_element']}
    ...    AND    TAP_ON_BUTTON    ${My_Renault['set_time_ok_button']}    5

CHECK VEHICLE POSITION NOT RETRIEVED ERROR MSG
    [Arguments]    ${refresh_required}=False    ${geolocation_disabled}=False
    [Documentation]    == High Level Description: ==
    ...   Check for the car is refreshed in MyR One Valid android application
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['warning_popup']}    10
    Run Keyword If    "${elmt}" == "False"    Run Keywords
    ...    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['home_car']}    15
    ...    AND    Sleep    5
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    10
    IF    ${geolocation_disabled}==True
        ${elm} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['vehicle_position']}    10
        Run Keyword If    "${elm}" == "True"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    10
        ${elmt} =    APPIUM_WAIT_FOR_XPATH      ${My_Renault['geolocation_popup']}   10
        Should be True    ${elmt}   Check why the geolocation pop up is not present
        ${pop} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['iunderstand_xpath']}   10
        Run Keyword If    ${pop} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['iunderstand_xpath']}    5
        ${back} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['back_geolocation_popup']}   10
        Run Keyword If    ${back} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_geolocation_popup']}    5
    END
    Return from Keyword If    "${elmt}" == "True" and "${geolocation_disabled}" == "True"
    IF    "${elmt}" == "True" and "${geolocation_disabled}" == "False"
        ${result} =    APPIUM_GET_TEXT_BY_ID    ${My_Renault['warning_popup']}
        log to console    ${result}
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['warning_popup_click']}    10
        Should Contain    ${result}    Important: data sharing in your vehicle has been disabled
    END
    Return from Keyword If    "${elmt}" == "True" and "${geolocation_disabled}" == "False"
    Run Keyword If    ${refresh_required}==True    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    10
    ...    AND    Sleep    3
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['refresh_button']}    10
    ...    AND    Sleep    7
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['refresh_button']}    10
    ${elem} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['toast_message_banner']}    90
    ${notificationtext} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT    ${My_Renault['toast_message_banner']}
    log to console    ${notificationtext}
    Should Be Equal   "${notificationtext}"    "We couldn't retrieve the position of the vehicle"
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['home_car']}    20

DO KILL MYR APP
    [Documentation]    Kill the application and the app is no more running in the background
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell pm clear ${mobile_appPackage}

LAUNCH AFTER KILL AND LOGIN THE APPLICATION
    [Arguments]    ${myrenault_username}   ${myrenault_password}
    [Documentation]    == High Level Description: ==
    ...   Launches the MyR One Valid android application and Login
    ...    == Parameters: ==
    ...    myrenault_username: username for MyR application login
    ...    myrenault_password: password for MyR application login
    Return From Keyword If    "${myrenault_username}" == "None"  or  "${myrenault_password}" == "None"
    LAUNCH_MYRENAULT_APP    ${mobile_appPackage}    ${mobile_activityName}
    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow all']    25
    sleep    25
    swipe_by_coordinates    950    1100    125    1100
    sleep    3
    swipe_by_coordinates    950    1100    125    1100
    sleep    3
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['beta_done']}    10
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['sign_in']}    12
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['beta_alert']}    25
    sleep   5
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['sign_in']}    10
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['signin_email']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['signin_email']}    ${myrenault_username}
    sleep    5
    HIDE_KEYBOARD
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['signin_password']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['signin_password']}    ${myrenault_password}
    HIDE_KEYBOARD
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['signin_button']}    15
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['car_bottom_tab']}    15

CLOSE MYR APP
    [Documentation]    == High Level Description: ==
    ...     Close the myr app
    RUN KEYWORD IF    ${mobile_driver}    CHECK AND SWITCH DRIVER    ${mobile_driver}

ENABLE OR DISABLE ONE DAY IN MyR
    [Arguments]    ${days}
    [Documentation]    Disabled the days @{days} from MyR program
    ...    All days are enabled by default, we need to disabled the unnecessary ones
    REFRESH_LAYOUT
    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    Sleep    2
    APPIUM_TAP_XPATH    ${My_Renault['program_one']}
    Sleep    2
    APPIUM_TAP_XPATH    ${My_Renault['days_hvac']["${days}"]}
    TAP_ON_BUTTON    ${My_Renault['submit_program']}    10
    ${retrieved_text} =    APPIUM_GET_TEXT    ${My_Renault['save_schedule']}
    Run Keyword If    "${retrieved_text}" == "save"    TAP_ON_BUTTON    ${My_Renault['save_schedule']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from program
    Sleep    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    Sleep    15

ENABLE OR DISABLE ONE DAY FOR HVAC IN MyR DEBUG APP
    [Arguments]    ${My_Renault_Vin_Name}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    Disabled the days @{days} from MyR program
    ...    All days are enabled by default, we need to disabled the unnecessary ones
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 2
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH    //*[@resource-id="com.renault.myrenault.one.valid.debug:id/vehicle_selection_text_view"]    30    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_vehicle_selection
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@text='${My_Renault_Vin_Name}' or @text='${vehicle_id}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_${My_Renault_Vin_Name}
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@text='Climate control' or @text='Air conditioning']     10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_Climate control    scroll_tries=50
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     (//android.widget.TextView[@text='Start time'])[1]    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_Select_Program
    Sleep    3
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@resource-id="com.renault.myrenault.one.valid.debug:id/toggle_btn" and @text='W']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_select_day
    TAP_ON_ELEMENT_USING_ID    charge_calendar_btn_validate    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_charge_calendar_btn_validate
    TAP_ON_ELEMENT_USING_ID    btnSave    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_btnSave
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

ENABLE OR DISABLE ONE DAY FOR SCHEDULE CHARGE IN MyR DEBUG APP
    [Arguments]    ${My_Renault_Vin_Name}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    Disabled the days @{days} from MyR program
    ...    All days are enabled by default, we need to disabled the unnecessary ones
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell service call statusbar 2
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH    //*[@resource-id="com.renault.myrenault.one.valid.debug:id/vehicle_selection_text_view"]    30    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_vehicle_selection
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@text='${My_Renault_Vin_Name}' or @text='${vehicle_id}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_${My_Renault_Vin_Name}
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    swipe_by_coordinates    500    600    500    1300
    Sleep    5
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@text='Charging mode']     10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_Charging_mode    scroll_tries=50
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     (//android.widget.TextView[@text='Start time'])[1]    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_Select_Program
    Sleep    3
    Run Keyword And Continue On Failure    TAP_ON_ELEMENT_USING_XPATH     //*[@resource-id="com.renault.myrenault.one.valid.debug:id/toggle_btn" and @text='W']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_select_day
    TAP_ON_ELEMENT_USING_ID    charge_calendar_btn_validate    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_charge_calendar_btn_validate
    TAP_ON_ELEMENT_USING_ID    btnSave    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}_btnSave
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

GET HVAC SCHEDULE DAYS
    [Documentation]    == High Level Description: ==
    ...    Get the scheduled days in a HVAC calender
    REFRESH_LAYOUT
    TAP_ON_BUTTON    ${My_Renault['pre_conditioning_hvac']}    10
    ${fetch_days} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['schedule_hvac_days']}
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    Sleep    5
    [Return]    ${fetch_days}

RETRIEVE DISTANCE TRAVELLED FROM MYR
   [Documentation]    == High Level Description: ==
    ...   Get the Vehicle Distance Travelled in MyR One Valid android application
   [Tags]    Automated    Check Autonomy in Vehicle and MYR    MY RENAULT APP
   REFRESH_LAYOUT
   ${text_retrieved_autonomy} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['distance_text']}
   [Return]    ${text_retrieved_autonomy}

CHECK INSTANT HVAC NOT PRESENT
    [Documentation]    == High Level Description: ==
    ...    CHECK HVAC preconditioning start request to vehicle can't be send from MyRenault APP on Smart Phone.
    ${hvac_text_find} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['hvac_text']}    20
    Run Keyword If    "${hvac_text_find}" == "False"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['scroll_button']}    10
    ${elem} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['hvac_text']}    enabled
    Should Be Equal    "${elem}"    "false"

VALIDATE DATA SHARING OFF TEXT
    [Documentation]    == High Level Description: ==
    ...    Checks the text "data sharing off" in the notification displayed
    ${data_sharing_off_text} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['data_sharing_off']}    10
    Should Be True    ${data_sharing_off_text}

GET USER INFORMATION FROM MYR
    [Documentation]    == High Level Description: ==
    ...    Get the firstname and lastname of the user account
    CHECK AND SWITCH DRIVER    ${mobile_driver}
    TAP_ON_ELEMENT_USING_ID     ${My_Renault['profile_bottom_tab']}      10
    Sleep     5
    ${firstname} =    APPIUM_GET_TEXT    ${My_Renault['firstname_profile']}
    ${lastname} =    APPIUM_GET_TEXT    ${My_Renault['lastname_profile']}
    ${fullname} =   Catenate    ${firstname}   ${lastname}
    [Return]    ${fullname}

CHECK AND DELETE VEHICLE
    [Documentation]    == High Level Description: ==
    ...    This keyword is used to check if needed vehicle is present in MY Renault application.
    Sleep    5
    SCROLL_TO_ELEMENT    ${MyRenault['vehicle_details']}    down    3
    TAP_ON_ELEMENT_USING_XPATH    ${MyRenault['vehicle_details']}    10
    sleep    2
    Log To Console    ${vehicle_id}
    ${elem_found} =  APPIUM_WAIT_FOR_XPATH    //*[@text='${vehicle_id}']    10
    ${get_VIN} =    Run Keyword If    "${elem_found}" == "True"    APPIUM_GET_TEXT_USING_XPATH    //*[@text='${vehicle_id}']
    TAP_ON_ELEMENT_USING_XPATH    ${MyRenault['back_button']}    10
    Run Keyword If    "${get_VIN}" != " " and "${get_VIN}" == "${vehicle_id}"    Run Keywords    DELETE VEHICLE
    ...     ELSE    Log    No vehicle Present

CHECK CAR ICON IS REFRESHED INSIDE MAP
    [Documentation]    == High Level Description: ==
    ...   Check for the car pin is refreshed in MyR One Valid android application
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['home_car']}    15
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['map_navigation']}    20
    Sleep    15
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['vehicle_position']}    20
    Sleep    5
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['car_icon']}    30
    Should Be True    ${elemt}

SAVE LOCATION ON GOOGLE MAP IN MYR
    [Arguments]    ${dest_address}
    [Documentation]    Enter the location and save in google map
    ...    == Parameters: ==
    ...    dest_address: The Required destination address to be searched in SP
    Run Keyword and Ignore Error    enable_multi_windows
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_search']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_search']}    10
    APPIUM_ENTER_TEXT    ${My_Renault['gmap_location']}      ${dest_address}
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_select_location']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_select_location']}    10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_saved_button']}    30
    Run Keyword If    ${elemt}==True    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_saved_button']}    10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['remove_starred_place']}    10
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_done_button']}    10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_save_button']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_save_button']}    30
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_starred_checkbox']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_starred_checkbox']}    10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_done_button']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_done_button']}    10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_x_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_x_button']}    10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_signin_button']}    10

GET GOOGLE MAIL ADDRESS FROM SP
    [Documentation]    Get the google mail address using gmap

    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_signin_button']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['gmap_signin_button']}    10
    Sleep    5s
    ${sp_email_address} =    APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['gmap_account']}
    ${gmap_close} =   APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_signin_close']}    10
    ${pop_close} =    Create Dictionary    x=986    y=196
    Run Keyword If    ${gmap_close}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_signin_close']}    10
    ...    ELSE    APPIUM_TAP_LOCATION    ${pop_close}
    [Return]    ${sp_email_address}

VERIFY NO SAVED LOCATION ON MYR
    [Arguments]    ${destination}
    [Documentation]    Search for saved location not in MYR
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_saved_button']}   20
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_starred_places']}    20
    Sleep    2
    ${gmap_saved} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${destination}')]
    SHOULD NOT BE TRUE    ${gmap_saved}
    Sleep    2
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_back_button']}   10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_back_button']}   10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_explore']}   10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_explore']}   10

CHECK RECENT LOCATION ON MAP
    [Documentation]    This KW is used to check the recent location in maps
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_search']}    12
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_search']}    30
    Sleep    5
    swipe_by_coordinates    472    1184    472    278
    Sleep    5
    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['most_recent_search']}    30
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['most_recent_search']}    30
    Sleep    5
    ${recent_way} =   APPIUM_GET_TEXT_USING_XPATH    ${My_Renault['recent_place']}
    Sleep    5
    SHOULD BE EQUAL    "${recent_way}"    "${destination}"
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['recent_place']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['map_directions']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['map_walk']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['map_start']}    30

CHECK SAVED LOCATION ON GMAP SP
    [Arguments]    ${destination}
    [Documentation]    This KW is used for check saved location present in gmap
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_saved_button']}   20
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_starred_places']}    20
    Sleep    2
    ${gmap_saved} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${destination}')]    10
    SHOULD BE TRUE    ${gmap_saved}
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_back_button']}   10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_back_button']}   10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_explore']}   10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_explore']}   10

WAIT CONFIRM MESSAGE HVAC
    [Arguments]    ${start_time}    ${timeout}=60
    [Documentation]     Waiting message confirmation from Vnext confirmed in locat
    FOR    ${try}    IN RANGE    ${timeout}
        ${logcat} =    Run process    adb    -s    ${smartphone_adb_id}    shell    logcat    -d    |    grep    "com.accenture.myrenault.workmanager.workers.HvacSchedulerWorker returned a Success"
        Sleep    2
        Log To Console    Logcat returns ${logcat.stdout}
        Exit For Loop If    '${logcat.stdout}' != ''
    END
    ${logcat_remote_status}    ${logcat_remote_comment} =    Run Keyword And Ignore Error    Should Not be Empty    ${logcat.stdout}    Command Confirmation Error or Not Received
    Log    logcat_remote_status = ${logcat_remote_status}    WARN
    Log    logcat_remote_comment = ${logcat_remote_comment}    WARN
    ${received_date} =    robot.libraries.DateTime.Get Current Date
    Log To Console    receiving message at ${received_date}
    ${delta_time} =    robot.libraries.DateTime.Subtract Date From Date    ${received_date}    ${start_time}    result_format=compact
    Log To Console    Delta time: ${delta_time}
    Run Keyword If    "${logcat_remote_status}" != "PASS"    Fail    Remote Order Failed

WAIT CONFIRM MESSAGE SCHEDULE_CHARGE
    [Arguments]    ${start_time}    ${timeout}=60
    [Documentation]     Waiting message confirmation from Vnext confirmed in locat
    FOR    ${try}    IN RANGE    ${timeout}
        ${logcat} =    Run process    adb    -s    ${smartphone_adb_id}    shell    logcat    -d    |    grep    "com.accenture.myrenault.workmanager.workers.ChargeSchedulerWorker returned a Success"
        Sleep    2
        Log To Console    Logcat returns ${logcat.stdout}
        Exit For Loop If    '${logcat.stdout}' != ''
    END
    ${logcat_remote_status}    ${logcat_remote_comment} =    Run Keyword And Ignore Error    Should Not be Empty    ${logcat.stdout}    Command Confirmation Error or Not Received
    Log    logcat_remote_status = ${logcat_remote_status}    WARN
    Log    logcat_remote_comment = ${logcat_remote_comment}    WARN
    ${received_date} =    robot.libraries.DateTime.Get Current Date
    Log To Console    receiving message at ${received_date}
    ${delta_time} =    robot.libraries.DateTime.Subtract Date From Date    ${received_date}    ${start_time}    result_format=compact
    Log To Console    Delta time: ${delta_time}
    Run Keyword If    "${logcat_remote_status}" != "PASS"    Fail    Remote Order Failed

EXIT FROM SAVED PLACE IN GMAP
    [Documentation]    Return back from starred place to search location
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_navigation']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['explore_button']}    10

CHECK CHARGING MODE OPTION ENABLED
    [Documentation]    Check the charging mode tab is not enabled when privacy on
    ${tab_visibility} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${My_Renault['charging_mode']}    enabled
    Should Be Equal    "true"    "${tab_visibility}"

CHECK MYRENAULT APP CHARGE HISTORY
    [Arguments]    ${start_time}    ${stop_time}    ${start_percent}    ${end_percent}    ${privacy}=False
    [Documentation]     expand the last last charge history and check values
    REFRESH_LAYOUT
    ${find_elem} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${My_Renault['charge_history_tab']}    direction=down
    Run Keyword If    "${find_elem}"!="True"    Fail    Charge history is not displayed
    IF    "${privacy}"=="True"
        ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['iunderstand_xpath']}   10
        Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['iunderstand_xpath']}    5
        ${charge_history_not_clickable} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['charge_history_privacy']}    clickable
        Should Be Equal    ${charge_history_not_clickable}   false      Element is clickable
        Return From Keyword
    END
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['charge_history_tab']}      10
    Sleep     5
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['last_charge']}      10
    Sleep     5
    ${ch_start_percent} =    APPIUM_GET_TEXT    ${My_Renault['ch_start_percent']}
    ${start_percent_fetched} =    Fetch From Left    ${ch_start_percent}    %
    should be equal as integers    ${start_percent_fetched}    ${start_percent}
    ${ch_end_percent} =    APPIUM_GET_TEXT    ${My_Renault['ch_end_percent']}
    ${end_percent_fetched} =    Fetch From Left    ${ch_end_percent}    %
    should be equal as integers    ${end_percent_fetched}    ${end_percent}
    ${time_start} =	DateTime.Convert Date    ${start_time}    result_format=%Y-%m-%d %H:%M    date_format=%m%d%H%M%Y
    ${time_stop} =	DateTime.Convert Date    ${stop_time}    result_format=%Y-%m-%d %H:%M    date_format=%m%d%H%M%Y
    ${ch_start_time} =    APPIUM_GET_TEXT    ${My_Renault['ch_start_time']}
    ${ch_start_time_str} =     Remove String    ${ch_start_time}    at
    ${ch_start_time_str} =     Replace String     ${ch_start_time_str}    ${SPACE * 2}    ${SPACE}
    ${time} =	DateTime.Convert Date    ${ch_start_time_str}    result_format=%Y-%m-%d %H:%M    date_format=%m/%d/%y %H:%M
    ${verdict} =    Evaluate    '''${time_start}''' <= '''${time}''' <= '''${time_stop}'''
    Should Be True    ${verdict}    The timestamp from MYR is not as expected
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10

CHECK CALL STATUS IN SMARTPHONE
    [Documentation]    To check the current Call status in SmartPhone
    [Arguments]    ${call_type}=ringing
    ${call_state} =    Set Variable If    "${call_type}"=="ringing"    1
    ...    "${call_type}"=="active_call"    2
    ...    "${call_type}"=="idle"    0
    Wait Until Keyword Succeeds    10m    2s    RETRY CHECK CALL STATUS    ${call_state}

RETRY CHECK CALL STATUS
    [Documentation]    Retry the call status check
    [Arguments]    ${call_state}
    ${response} =    OperatingSystem.Run    adb -s ${mobile_adb_id} shell dumpsys telephony.registry | grep mCallState
    Should Contain    ${response}    mCallState=${call_state}    Response does not contain the expected State: ${call_state}

CHECKSET MYRACCOUNT IS PAIRED WITH CAR
    [Arguments]     ${vehicle_id}    ${privacy}=False
    [Documentation]     Keyword used to check if MyR account is paired with car and if not do the pairing.
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['warning_popup']}    10
    Run Keyword If    "${elmt}" == "True"    TAP_ON_ELEMENT_USING_ID    ${My_Renault['warning_popup_click']}    10
    ${verdict} =    CHECK MYRENAULT APP HOLDS NEEDED VIN    present
    IF    "${verdict}" == "wrong"
        CHECK AND SWITCH DRIVER    ${ivi_driver}
        DO IVI ADD MYRENAULT ACCOUNT    ${myrenault_username}    ${myrenault_password}
        LOGOUT_APPLICATION
        LAUNCH AND LOGIN THE APPLICATION    ${myrenault_username}    ${myrenault_password}
    END
    Run keyword If    ${privacy}==True     Return from keyword
    CHECK VEHICLE CONNECTIVITY STATUS ON MYR APP ON SMART PHONE

CHECK IF MYRENAULT APP IS PAIRED WITH CAR
    [Arguments]     ${vehicle_id}
    [Documentation]     Checks if MyR account is paired with car.
    ${verdict} =    CHECK MYRENAULT APP HOLDS NEEDED VIN    present
    Should Be True    "${verdict}" != "wrong"    MYR Account is not Paired
    CHECK VEHICLE CONNECTIVITY STATUS ON MYR APP ON SMART PHONE

CHECK VEHICLE CONNECTIVITY STATUS ON MYR APP ON SMART PHONE
    [Documentation]     Takes date and time from IVC and smartphone and compare them to check if they're connected.
    ${verdict}    ${date_ivc} =     GET DATE ON IVC    date_format="+%-m/%-d/%y"
    ${date_myr} =     GET LAST VEHICLE ACTIVITY TIME
    @{elts}=  SPLIT STRING  ${date_myr}  ${SPACE}
    ${output}=  GET FROM LIST  ${elts}  3
    ${extract_date} =    Replace String    ${date_ivc}    ${\n}    ${EMPTY}
    ${verdict} =    Evaluate    '''${output}''' == '''${extract_date}'''
    IF    "${verdict}" == "False"
        ${output} =	DateTime.Convert Date    ${output}    result_format=%m/%d/%y    date_format=%d/%m/%y
        ${extract_date} =	DateTime.Convert Date    ${extract_date}    result_format=%d/%m/%y    date_format=%d/%m/%y
    END
    Should Contain    ${output}    ${extract_date}    IVC and MYR Account time is not matching.

CHECK NO CHARGE HISTORY AVAILABLE
    [Arguments]    ${start_time}    ${stop_time}=${None}    ${privacy_mode}=off
    [Documentation]     This kw is used to check no history available when privacy on and off
    REFRESH_LAYOUT
    Sleep    10
    ${find_elem} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${My_Renault['charge_history_tab']}    direction=down
    Run Keyword If    "${find_elem}"!="True"    Fail    Charge history is not displayed
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['charge_history_tab']}      10
    Sleep     5
    ${no_history} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['no_charge_result']}    12
    Run Keyword If    "${no_history}"=="True"    Run Keywords
    ...    Log To Console    No charge history is available
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${My_Renault['home_car']}    10
    ...    AND    Return From Keyword
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['ecch_left_arrow']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_ID      ${My_Renault['ecch_right_arrow']}    10
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['last_charge']}      10
    Sleep     5
    ${time_start} =	DateTime.Convert Date    ${start_time}    result_format=%Y-%m-%d %H:%M    date_format=%m%d%H%M%Y
    IF    "${privacy_mode}" == "on"
        ${time_stop} =	DateTime.Convert Date    ${stop_time}    result_format=%Y-%m-%d %H:%M    date_format=%m%d%H%M%Y
        ${ch_start_time} =    APPIUM_GET_TEXT    ${My_Renault['ch_start_time']}
        ${ch_start_time_str} =     Remove String    ${ch_start_time}    at
        ${ch_start_time_str} =     Replace String     ${ch_start_time_str}    ${SPACE * 2}    ${SPACE}
        ${time} =	DateTime.Convert Date    ${ch_start_time_str}    result_format=%Y-%m-%d %H:%M    date_format=%m/%d/%y %H:%M
        ${verdict} =    Evaluate    '''${time_start}''' <= '''${time}''' <= '''${time_stop}'''
        Should Not Be True    ${verdict}    The timestamp from MYR is not as expected
        Sleep    20
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['home_car']}    10
    END
    Return from Keyword If    "${privacy_mode}" == "on"
    ${ch_start_time} =    APPIUM_GET_TEXT    ${My_Renault['ch_start_time']}
    ${ch_start_time_str} =     Remove String    ${ch_start_time}    at
    ${ch_start_time_str} =     Replace String     ${ch_start_time_str}    ${SPACE * 2}    ${SPACE}
    ${time} =	DateTime.Convert Date    ${ch_start_time_str}    result_format=%Y-%m-%d %H:%M    date_format=%m/%d/%y %H:%M
    ${verdict} =    Evaluate    '''${time_start}''' <= '''${time}'''
    Should Not Be True    ${verdict}    The timestamp from MYR is not as expected
    Sleep    20
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    TAP_ON_ELEMENT_USING_ID    ${My_Renault['home_car']}    10

GET SP TIMESTAMP
    [Documentation]     This kw is used to fetch the current timestamp from smart phone
    ${get_time} =    OperatingSystem.Run    adb -s ${mobile_adb_id} shell date +%m%d%H%M%Y
    [Return]    ${get_time}
    
DO KILL APP FROM SP
    [Arguments]    ${appPackage}
    [Documentation]    Kill the application specified and the app is no more running in the background
    OperatingSystem.Run    adb -s ${mobile_adb_id} shell pm clear ${appPackage}
    
CHECK AND SWITCH GOOGLE ACCOUNT ON PHONE
    [Arguments]    ${mail_adress}
    [Documentation]     CHECK IF THE GOOGLE ACCOUNT PROVIDED IS THE MAIN ONE AND IF NOT SWITCH

    START INTENT    com.google.android.maps.MapsActivity
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_signin_button']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['gmap_signin_button']}    10
    ${exists} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mail_adress}')]   20
    Return From Keyword If    ${exists}==True
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_account_arrow']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_account_arrow']}   10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mail_adress}')]    10
    TAP_ON_ELEMENT_USING_XPATH    //*[contains(@text,'${mail_adress}')]    10

LOGIN WITH GOOGLE ACCOUNT ON PHONE
    [Arguments]    ${mail_adress}    ${password}
    [Documentation]     Login in google account on the phone or switches the google account if it already exists but it's not the main one

    START INTENT    com.google.android.maps.MapsActivity
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_skip']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_skip']}   10
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_signin_button']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['gmap_signin_button']}    10
    ${exists} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mail_adress}')]   20
    Return From Keyword If    ${exists}==True
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_account_arrow']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_account_arrow']}   10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mail_adress}')]    10
    IF    ${elemt}==True
        TAP_ON_ELEMENT_USING_XPATH    //*[contains(@text,'${mail_adress}')]    10
        ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_signin_button']}    10
        Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['gmap_signin_button']}    10
        ${exists} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mail_adress}')]   20
        Return From Keyword If    ${exists}==True
    END
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_add_account']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_add_account']}   10
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_no_account_sign_in']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['gmap_no_account_sign_in']}   10
    APPIUM_WAIT_FOR_XPATH    ${User_profile['edit_google_mail']}    120
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['edit_google_mail']}    ${mail_adress}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    APPIUM_WAIT_FOR_XPATH    ${User_profile['edit_google_password']}    120
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['edit_google_password']}    ${password}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_agree']}    60
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_agree']}    10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_turn_on_backup']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_turn_on_backup']}   10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_accept']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_accept']}   10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_accept']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_accept']}   10

LOGOUT GOOGLE ACCOUNT ON PHONE
    [Arguments]    ${mail_adress}
    [Documentation]    Logout from google account on phone

    START INTENT    com.google.android.maps.MapsActivity
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['gmap_signin_button']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_ID    ${My_Renault['gmap_signin_button']}    10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_account_arrow']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_account_arrow']}   10
    ${exists} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_no_account_sign_in']}   10
    Return From Keyword If    ${exists}==True
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_manage_accounts']}   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_manage_accounts']}   10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mail_adress}')]   10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    //*[contains(@text,'${mail_adress}')]  10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_remove_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_remove_account']}    10
    APPIUM_WAIT_FOR_XPATH    ${My_Renault['gmap_remove_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['gmap_remove_account']}    10

SWIPE TO MERIDIEM MyR
    [Arguments]    ${xpath_current_meridiem}=${None}    ${xpath_hvac_meridiem_navigate}=${None}    ${req_meridiem}=AM
    [Documentation]    To Set the AM / PM to the time in 12 hour's time format
    ...    == Parameters ==:
    ...    xpath_current_meridiem: select the AM / PM default status
    ...    xpath_hvac_meridiem_navigate: select hour or minute top button for start time or end time
    ...    req_meridiem: the status that needs to be set
    ...    == Expected Result ==: AM / PM is set correctly if this is executed.
    ${get_meridiem} =    APPIUM_GET_TEXT_USING_XPATH     ${xpath_current_meridiem}
    Return From Keyword If    '${get_meridiem}' == '${req_meridiem}'
    Run Keyword if     '${get_meridiem}' != '${req_meridiem}'   Run Keywords
    ...     TAP_ON_ELEMENT_USING_XPATH    ${xpath_hvac_meridiem_navigate}    10
    ...     AND    Sleep    0.2
    ...     ELSE   Log    The time was successfully set.

CHECK MYRENAULT CHARGE SESSION AVAILABILITY
    [Arguments]    ${start_time}    ${start_percent}=${None}    ${end_percent}=${None}    ${available}=True    ${privacy}=False
    [Documentation]     expand the last last charge history and check values
    REFRESH_LAYOUT
    ${find_elem} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${My_Renault['charge_history_tab']}    direction=down
    Run Keyword If    "${find_elem}"!="True"    Fail    Charge history is not displayed
    IF    "${privacy}"=="True"
        ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${My_Renault['iunderstand_xpath']}   10
        Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['iunderstand_xpath']}    5
        ${charge_history_not_clickable} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${My_Renault['charge_history_privacy']}    clickable
        Should Be Equal    ${charge_history_not_clickable}   false      Element is clickable
        Return From Keyword
    END
    TAP_ON_ELEMENT_USING_XPATH     ${My_Renault['charge_history_tab']}      10
    Sleep     5
    ${output} =	DateTime.Convert Date    ${start_time}    result_format=%-m/%-d/%y %H:%M    date_format=%m%d%H%M%Y
    @{elts}=  SPLIT STRING  ${output}  ${SPACE}
    ${st_date}=  GET FROM LIST  ${elts}  0
    ${st_time}=  GET FROM LIST  ${elts}  1
    ${s_Hor} =   Fetch From Left    ${st_time}   :
    ${S_Min} =   Fetch From Right    ${st_time}   :
    ${H} =   Convert To Integer    ${s_Hor}
    ${sm_time} =   Convert To Integer    ${S_Min}

    FOR    ${i}    IN RANGE    ${sm_time}    ${sm_time}+5
        TAP_ON_ELEMENT_USING_ID     ${My_Renault['ecch_left_arrow']}    10
        Sleep    5
        TAP_ON_ELEMENT_USING_ID    ${My_Renault['ecch_right_arrow']}    10
        Sleep    5
        IF    ${i}>=60
            ${ii} =    Evaluate    ${i} - 60
            ${HH} =    Evaluate    ${H} + 1
        ELSE
            ${ii} =    Set Variable    ${i}
            ${HH} =    Set Variable    ${H}
        END
        ${j} =    Set Variable   0
        ${dt} =    Convert To String    ${j}
        ${dtc} =    Convert To String    ${ii}
        ${nb} =    GET LENGTH    ${dtc}
        IF    ${nb}==1
            ${str1} =    Catenate    SEPARATOR=    ${dt}    ${dtc}
            ${elem} =   SCROLL_TO_ELEMENT    xpath=//android.widget.TextView[contains(@text,'${st_date}') and contains(@text,'${HH}:${str1}')]    down    10
            ${elem1} =    Set Variable    ${elem}
            Run Keyword If    "${elem}" == "True"    TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[contains(@text, '${st_date}') and contains(@text, '${HH}:${str1}')]    10
            ${ch_start_percent} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT    //android.widget.TextView[contains(@text, '${st_date}') and contains(@text, '${HH}:${str1}')]/preceding-sibling::android.widget.TextView
        ELSE
            ${elem} =   SCROLL_TO_ELEMENT    xpath=//android.widget.TextView[contains(@text, '${st_date}') and contains(@text, '${HH}:${ii}')]    down    10
            ${elem1} =    Set Variable    ${elem}
            Run Keyword If    "${elem}" == "True"    TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[contains(@text, '${st_date}') and contains(@text, '${HH}:${ii}')]    10
            ${ch_start_percent} =    Run Keyword If    "${elem}" == "True"    APPIUM_GET_TEXT    //android.widget.TextView[contains(@text, '${st_date}') and contains(@text, '${HH}:${ii}')]/preceding-sibling::android.widget.TextView
        END
        Exit For Loop If    "${elem}"=="True"
    END
    IF    ${available}==False
        Should Not Be True    ${elem1}
        TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
        SCROLL_TO_ELEMENT    ${My_Renault['time_on_car']}    up    3
    END
    Return from Keyword If    "${available}" == "False"
    ${start_percent_fetched} =    Fetch From Left    ${ch_start_percent}    %
    should be equal as integers    ${start_percent_fetched}    ${start_percent}
    ${end_charge} =    APPIUM_WAIT_FOR_ELEMENT    ${My_Renault['ch_end_percent']}    10
    Run Keyword If    ${end_charge}==False    Run Keywords
    ...    SCROLL_TO_ELEMENT    ${My_Renault['ch_end_percent']}    down    2
    ...    AND    Sleep    5
    ${ch_end_percent} =    APPIUM_GET_TEXT    ${My_Renault['ch_end_percent']}
    ${end_percent_fetched} =    Fetch From Left    ${ch_end_percent}    %
    should be equal as integers    ${end_percent_fetched}    ${end_percent}
    TAP_ON_ELEMENT_USING_XPATH    ${My_Renault['back_button']}    10
    SCROLL_TO_ELEMENT    ${My_Renault['time_on_car']}    up    3
