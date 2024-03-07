#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
# New libary that should be used for all HMI interactions
*** Settings ***
Documentation    Library used for IVI HMI interactions
Library          rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library          rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library          rfw_services.ivi.ServiceLib    device=${ivi_adb_id}
Library          rfw_services.ivi.DiagnosticLib    device=${ivi_adb_id}
Library	         rfw_services.wicket.DeviceLib
Library          Collections
Library          OperatingSystem
Library          String
Resource         ../Smartphone/myrenault.robot
Variables        ../unsorted/on_board_ids.yaml
Variables        ../unsorted/PM_profiles.yaml
Variables        ../unsorted/calendars.yaml
Variables        KeyCodes.yaml

*** Variables ***
${english}    //*[@text='English' or @text='English (United Kingdom)']
${climate_or_comfort}    //*[@text='Charge & Climate' or @text='Charge & Comfort' or @text='Programs']
${instant_charge}     //android.widget.TextView[@text='Instant Charge' or @text='Instant charge']
${charge_delay}    //android.widget.TextView[@text='Charge Delay' or @text='Delayed charge']
${program}    //android.widget.TextView[@text='Program' or @text='Charge Planner' or @text='Programs']
${check_programs}    //android.widget.Button[@resource-id='com.renault.evservices:id/weeklyProgramMyPrograms']
${advanced_program}    //android.widget.TextView[@text='Climate' or @text='Thermal comfort']
${maps_app}    //android.widget.TextView[@text='Maps']
&{settings}       appPackage_ivi=com.android.car.settings    activityName_ivi=.Settings
${network_button}    //*[@text='Network & internet' or @text='Network and internet' or @text='Network and Internet']
${wifi_button}    //*[@text='Wi‑Fi']
${onoff_button}    //*[@resource-id='com.android.car.settings:id/car_ui_toolbar_menu_item_switch']
${network}    //*[@text='network']
${destination}    com.google.android.apps.maps:id/edittext_view
${destination_button}    //*[@resource-id='android:id/content']
${big_screen}    yes
${small_screen}    no
${battery_settings}    //*[@text='Battery Settings']
${Ok}      //*[@text='Ok' or @text='OK' or @text='ok']
${maps}   //*[@text='Maps']
${close_button}    //*[@resource-id='com.google.android.gms:id/close_button']
${check_connection}    //*[@resource-id='com.android.vending:id/0_resource_name_obfuscated']
${back_button}    //*[@resource-id='com.android.car.settings:id/car_ui_toolbar_nav_icon']
${check_connection_FR}    //*[@resource-id='com.android.vending:id/unauth_home_sign_in_button']
${data_screen_wifi}        //*[@resource-id='com.renault.connectivity:id/toolbar_nav']
${privacy_file}     privacyManagerActivationStatus.xml
${privacy_file_path}    matrix/artifacts/lemonad/privacyManagerActivationStatus.xml
${edit_profile}    //*[@text='Edit profile' or @text='Data & position shared with Renault' or @text='Privacy settings']
${share_only_data}    //*[@text='Share only data']
${share_data_and_position}    //*[@text='Share data and position']
${data_position_sharing}    //*[@text='Data & position shared with Renault']
${refuse_sharing}    //*[@text='Refuse sharing']
${console_logs}    yes
${ivi_adb_id}    ZX1G424JNN
${platform_name}    Android
${platform_version}    10
${appPackage}    com.renault.myrenault.one.valid
${activityName}    com.accenture.myrenault.activities.splashscreen.SplashScreenActivity
${automation_name}    UiAutomator2
${screen_orientation}    portrait
${ivi_user_pin_code}    1236
${ivi_user_password}    123456
${ivi_user_pattern}     12369
${ivi_user_otp_code}    356795
${push_message_notification}    //*[@text='Code ${ivi_user_otp_code} to be entered']
${launch_android_auto}     launch_android_auto.png
${wrong_pin_password}    1234
${go_to_settings}        //*[@text='Go to settings']
${accept_all}            //*[@text='Accept all']
${privacy_later_id}     android:id/button2
@{standard_factory_modes}    normal    static1
#software version to be completed

*** Keywords ***
SET IVI DATA PRIVACY
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    Checks SW version in order if we have MyF1, MyF2 or Myf3 build.
    ...    Through IVI HMI, go in settings menu and activate the data collection
    ...    Data collection 'ON' means that privacy is disabled and thus data is shared
    ...    == Parameters: ==
    ...    - _state_: on, off
    ...    == Expected Results: ==
    ...    Pass if executed
    [Tags]    Automated    Remote Services Common    IVI CMD
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    Sleep    5
    IF    "${ivi_my_feature_id}" == "MyF1"
        SET IVI DATA PRIVACY FOR MYF1    ${state}
    ELSE IF    "${ivi_my_feature_id}" == "MyF2"
        SET IVI DATA PRIVACY FOR MYF2    ${state}
    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "DOM" not in "${ivi_build_id}"
        SET IVI DATA PRIVACY FOR MYF3    ${state}
    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "DOM" in "${ivi_build_id}"
        SET IVI DATA PRIVACY FOR MYF3 GRANULAR    ${state}
    ELSE
        FAIL    Not implemented for this scenario ${ivi_my_feature_id}
    END

SET IVI DATA PRIVACY FOR MYF1
    [Arguments]    ${state}
    LAUNCH APP APPIUM    Privacy
    Sleep    5
    ${text_retrieved} =    APPIUM_GET_TEXT_BY_ID    ${car_settings['data_collection']}    20
    Run Keyword If    "${state}"=="${text_retrieved}".lower()    TAP_ON_BUTTON    ${car_settings['data_collection']}    20

SET IVI DATA PRIVACY FOR MYF2
    [Arguments]    ${state}
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${edit_profile}
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${share_only_data}
    Run Keyword If    "${result}" == "True"    APPIUM_TAP_XPATH    ${share_only_data}
    ...    ELSE    APPIUM_TAP_XPATH    ${data_position_sharing}
    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${share_data_and_position}    direction=down
    Run Keyword If    "${state}".lower() == "off data off" or "${state}".lower() == "off geolocation on"    APPIUM_TAP_XPATH    ${car_settings['share_only_data']}
    Run Keyword If    "${state}".lower() == "on"    APPIUM_TAP_XPATH    ${car_settings['refuse_sharing']}
    Run Keyword If    "${state}".lower() == "off" or "${state}".lower() == "off geolocation off"    APPIUM_TAP_XPATH    ${car_settings['share_data_and_geolocation']}
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${data_position_sharing}
    Run Keyword If    "${result}" == "True"    APPIUM_TAP_XPATH    ${data_position_sharing}
    ...    ELSE    APPIUM_TAP_XPATH    ${share_only_data}
    Sleep    5

SET IVI DATA PRIVACY FOR MYF3
    [Arguments]    ${state}
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10
    Should Be True    ${verdict}
    APPIUM_TAP_XPATH    ${edit_profile}
    ${result} =    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${car_settings['privacy_settings']}    direction=down
    Should Be True    ${result}
    APPIUM_TAP_XPATH    ${car_settings['privacy_settings']}
    Run Keyword If    "${state}".lower() == "off data off" or "${state}".lower() == "off geolocation on"    APPIUM_TAP_XPATH    ${car_settings['share_only_data']}
    Run Keyword If    "${state}".lower() == "on"    APPIUM_TAP_XPATH    ${car_settings['refuse_sharing']}
    Run Keyword If    "${state}".lower() == "off" or "${state}".lower() == "off geolocation off"    APPIUM_TAP_XPATH    ${car_settings['accept_sharing_granular']}
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${Ok}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${Ok}

SET IVI DATA PRIVACY FOR MYF3 GRANULAR
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and activate the data collection
    ...    Data collection 'ON' means that privacy is disabled and thus data is shared
    ...    == Parameters: ==
    ...    - _state_: on, off
    ...    == Expected Results: ==
    ...    Pass if executed
    [Tags]    Automated    Remote Services Common    IVI CMD
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10    down    20    5
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${edit_profile}
    Run Keyword If    "${state}".lower() == "off data off" or "${state}".lower() == "off geolocation on"    FAIL    Option is not available
    Run Keyword If    "${state}".lower() == "on"    APPIUM_TAP_XPATH    ${car_settings['refuse_sharing_granular']}
    Run Keyword If    "${state}".lower() == "off" or "${state}".lower() == "off geolocation off"    APPIUM_TAP_XPATH    ${car_settings['accept_sharing_granular']}
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['back_privacy_settings']}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}
    Sleep    2
    LAUNCH APP APPIUM    Navigation

CHECK THE CHARGING SETTINGS ON HMI
    [Arguments]    ${mode}    ${profile_value}=${None}
    [Documentation]    == High Level Description: ==
    ...    Check that the charging settings are properly displayed on the HMI
    ...    == Parameters: ==
    ...    - _mode_: represents the charging modes available (instant, delayed and scheduled)
    ...    _profile_value_: represents an optional parameter that contains the required settings for each mode
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    IVI CMD
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    LAUNCH APP APPIUM    EvMenu
    Sleep    2
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    Sleep    2
    APPIUM_TAP_XPATH    ${climate_or_comfort}
    Sleep    1
    Run Keyword If    "${mode}" == "scheduled"    CHECK HMI SCHEDULED CHARGE SETTINGS    ${profile_value}
    ...    ELSE IF    "${mode}" == "instant"    CHECK HMI INSTANT CHARGE SETTINGS
    ...    ELSE IF    "${mode}" == "delayed"    CHECK HMI DELAYED CHARGE SETTINGS
    ...    ELSE    Fail    The current mode: ${mode} does not exist!

CHECK HMI SCHEDULED CHARGE SETTINGS
    [Arguments]    ${profile_value}
    [Documentation]    == High Level Description: ==
    ...    Check that the charging settings for scheduled mode are properly displayed on the HMI
    ...    == Parameters: ==
    ...    _profile_value_: represents the parameter that contains the required settings for scheduled mode
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    IVI CMD
    @{Cal_Activation_Status_Expected} =    Create List
    @{Cal_Activation_Status} =    Create List
    ${key} =    Set Variable    ${calendars['${profile_value}']['expected_status']}
    FOR    ${status}    IN    @{key}
        Append To List    ${Cal_Activation_Status_Expected}    ${status}
    END
    APPIUM_TAP_XPATH    ${program}
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${check_programs}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${check_programs}
    Sleep    2
    @{calendar_status} =    APPIUM_GET_ELEMENTS_BY_CLASS    android.widget.Switch
    ${length} =    Get Length    ${calendar_status}
    ${length} =    Evaluate    ${length} + 1
    FOR    ${i}    IN RANGE    1    ${length}
        ${text_retrieved} =    APPIUM_GET_TEXT_USING_XPATH    //android.widget.FrameLayout[${i}]/android.view.ViewGroup/android.widget.Switch
        Append To List    ${Cal_Activation_Status}    ${text_retrieved}
    END
    Lists Should Be Equal    ${Cal_Activation_Status}    ${Cal_Activation_Status_Expected}    Status for charging schedules does not match!
    ${length} =    Get Length    ${calendar_status}
    ${length} =    Evaluate    ${length} + 1
    FOR    ${i}    IN RANGE    1    ${length}
        ${calendar_path} =    Set Variable    //android.widget.TextView[contains(@text, 'Charge ${calendars['${profile_value}']['charge_calendar${i}']['expected_start_time']}')]
        APPIUM_TAP_XPATH    ${calendar_path}
        ${Days_Activation_Status} =    Create List
        ${days_list} =    Set Variable    ${calendars['${profile_value}']['days_list']}
        FOR    ${day}    IN    @{days_list}
            ${day_text} =    APPIUM_GET_ATTRIBUTE_BY_ID    com.renault.evservices:id/calendar${day}Button    text
            ${day_checked} =    APPIUM_GET_ATTRIBUTE_BY_ID    com.renault.evservices:id/calendar${day}Button    checked
            Append To List     ${Days_Activation_Status}   ${day_text}: ${day_checked}
        END
        @{Days_Activation_Status_Expected}    Create List
        ${key} =    Set Variable    ${calendars['${profile_value}']['charge_calendar${i}']['days']}
        FOR    ${day_status}    IN    @{key}
            Append To List    ${Days_Activation_Status_Expected}    ${day_status}
        END
        Lists Should Be Equal    ${Days_Activation_Status}    ${Days_Activation_Status_Expected}    One of the expected days is not set properly in the current settings! Expected: ${Days_Activation_Status_Expected} but found: ${Days_Activation_Status}.
        ${start_time} =    APPIUM_GET_TEXT    ${EV_services['simple_charge_start_time']}
        ${end_time} =    APPIUM_GET_TEXT    ${EV_services['simple_charge_end_time']}
        ${expected_start_time} =    Set Variable    ${calendars['${profile_value}']['charge_calendar${i}']['expected_start_time']}
        ${expected_end_time} =    Set Variable    ${calendars['${profile_value}']['charge_calendar${i}']['expected_end_time']}
        Run Keyword If    "${start_time}" != "${expected_start_time}" or "${end_time}" != "${expected_end_time}"    Fail    Check time failed! Expected start time: ${expected_start_time}; end time: ${expected_end_time} but found: start time: ${start_time}; end time: ${end_time}
        APPIUM_TAP_ELEMENTID    ${EV_services['back_button']}
    END

CHECK HMI INSTANT CHARGE SETTINGS
    [Documentation]    == High Level Description: ==
    ...    Check that instant charge mode is properly displayed on the HMI
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    IVI CMD
    ${instant_charge_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${instant_charge}    selected
    Should Be True   "${instant_charge_selected}".lower() == "true"    Instant charge mode is not enabled!

CHECK HMI DELAYED CHARGE SETTINGS
    [Documentation]    == High Level Description: ==
    ...    Check that the delayed charge mode is properly displayed on the HMI
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    IVI CMD
    ${retrieve_hour} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell "date '+%Y-%m-%d %H:%M:%S'"
    ${convert_time_and_date} =    robot.libraries.DateTime.Convert Date    ${retrieve_hour}    result_format=%H
    ${charge_delay_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${charge_delay}    selected
    Should Be True    "${charge_delay_selected}".lower() == "true"    Delay charge mode is not enabled!
    ${expected_hour_flag} =    APPIUM_WAIT_FOR_XPATH    //android.widget.TextView[@text='${convert_time_and_date}']    10
    Should Be True    ${expected_hour_flag}    The charging start hour displayed does not match with the expected one!

CONFIGURE THE CHARGING MODE
    [Arguments]    ${mode}    ${profile_value}=${None}
    [Documentation]    == High Level Description: ==
    ...    Setting up a charging profile on the HMI
    ...    == Parameters: ==
    ...    _mode_: represents the charging modes available (instant, delayed and scheduled)
    ...    _profile_value_: represents an optional parameter that contains the required settings to be set onboard
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HMI    IVI CMD
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    Run Keyword If    "${mode}" == "instant"    SET HMI INSTANT CHARGE
    ...    ELSE IF    "${mode}" == "scheduled"    SET HMI SCHEDULED CHARGE    ${profile_value}
    ...    ELSE IF    "${mode}" == "delayed"    SET HMI DELAYED CHARGE
    ...    ELSE    Fail    Current mode: ${mode} is not supported!

APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    [Documentation]    Tap on Charge&Climate tab from EVServices application
    Log to console    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${climate_or_comfort}
    Run Keyword If      "${retrieved_text}" == "Charge & Climate" or "${retrieved_text}" == "Charge & Comfort" or "${retrieved_text}" == "Programs"   APPIUM_TAP_XPATH    ${climate_or_comfort}
    ...    ELSE    Fail    Wrong button for "Charge & Climate" button
    Sleep    0.2
VALIDATE TEXT ON SCREEN
    [Arguments]    ${screen_text}
    ${is_present} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${screen_text}')]    10
    Should Be True    ${is_present}

SET HMI INSTANT CHARGE
    [Documentation]    == High Level Description: ==
    ...    Set an instant charge on the HMI
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    IVI CMD
    ${instant_charge_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${instant_charge}    selected
    Run Keyword If    "${instant_charge_selected}".lower() == "false"    APPIUM_TAP_XPATH    ${instant_charge}

SET HMI SCHEDULED CHARGE
    [Arguments]    ${profile_value}
    [Documentation]    == High Level Description: ==
    ...    Set a scheduled charge with a certain {profile_value} on the HMI
    ...    == Parameters: ==
    ...    _profile_value_: represents the parameter that contains the required settings for scheduled charge to be set onboard
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    IVI CMD
    ${text} =    APPIUM TAP EVSERVICES PROGRAM

    ${element} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['new_program']}    10

    Run Keyword If    "My program" in """${text}""" or "${element}" == "True"    APPIUM_REMOVE_CALENDARS

    ${simple_charge_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['charge']}    selected
    Run Keyword If    "${simple_charge_selected}".lower() == "false"    APPIUM_TAP_XPATH    ${EV_services['charge']}
    Sleep    1
    ${simple_charge_first_hour} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${EV_services['simple_charge_first_hour']}    text
    ${simple_charge_second_hour} =    APPIUM_GET_ATTRIBUTE_BY_ID    ${EV_services['simple_charge_second_hour']}    text
    APPIUM_TAP_ELEMENTID     ${EV_services['simple_charge_hours']}
    Sleep    1
    ${first_hour} =    Fetch From Left    ${simple_charge_first_hour}    :
    ${second_hour} =    Fetch From Left    ${simple_charge_second_hour}    :

    ${location_first_hour} =    APPIUM_GET_XPATH_LOCATION    //android.widget.TextView[contains(@text, '${first_hour}')]
    ${location_second_hour} =    APPIUM_GET_XPATH_LOCATION    //android.widget.TextView[contains(@text, '${second_hour}')]

    ${x}    ${y}    ${new_x}    ${new_y} =    EXTRACTING COORDINATES     ${location_first_hour}    ${210}    ${90}

    TIME SETTING    ${calendars['${profile_value}']['begin_hour']}    simple_charge_start_hour    ${x}    ${y}    ${x}    ${new_y}
    TIME SETTING    ${calendars['${profile_value}']['begin_min']}    simple_charge_start_min    ${new_x}    ${y}    ${new_x}    ${new_y}

    ${x}    ${y}    ${new_x}    ${new_y} =    EXTRACTING COORDINATES     ${location_second_hour}    ${210}    ${90}

    TIME SETTING    ${calendars['${profile_value}']['end_hour']}    simple_charge_end_hour    ${x}    ${y}    ${x}    ${new_y}
    TIME SETTING    ${calendars['${profile_value}']['end_min']}    simple_charge_end_min    ${new_x}    ${y}    ${new_x}    ${new_y}

    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['simple_charge_time_setting_save_btn']}
    Run Keyword If    "${retrieved_text}".lower() == "save"    TAP_ON_BUTTON    ${EV_services['simple_charge_time_setting_save_btn']}    5
    ...    ELSE    Fail    Wrong PATH for "Save" button from hours selection menu

    ${active_days} =    Set Variable    ${calendars['${profile_value}']['active_days']}
    FOR    ${day}    IN    @{active_days}
        ${day_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    com.renault.evservices:id/calendar${day}Button    checked
        Run Keyword If    "${day_status}".lower() == "false"    TAP_ON_BUTTON    com.renault.evservices:id/calendar${day}Button    5
    END

    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    Run Keyword If    "${retrieved_text}".lower() == "save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    5
    ...    ELSE    Fail    Wrong PATH for "Save" button from days selection menu

SET HMI DELAYED CHARGE
    APPIUM_TAP_XPATH    ${EV_services['Charge_delay_mode']}
    Sleep   3
    CHANGE_MIN_DELAYEDCHARGE

CHANGE_MIN_DELAYEDCHARGE
    swipe_by_coordinates    680    560    680    490    200
    Sleep    2s
    APPIUM_TAP_ELEMENTID   ${EV_services['delay_program_savebutton']}


SET SOC BATTERY FULL LEVEL APPIUM
    LAUNCH APP APPIUM    EvSettings
    SLEEP    5
    ${result} =   WAIT ELEMENT BY XPATH    //*[@text='Battery']
    RUN KEYWORD IF    '${result}' == 'True'     APPIUM_TAP_XPATH    //*[@text='Battery']
    SLEEP    5
    ${result} =   WAIT ELEMENT BY XPATH    //*[@text='100 %']
    RUN KEYWORD IF    "${result}" == "True"    SET CLOSE APP    ivi    EvSettings
    RUN KEYWORD IF    "${result}" == "True"    RETURN FROM KEYWORD
    FOR  ${i}  IN RANGE    1    20
        ${result} =   WAIT ELEMENT BY XPATH    //*[@text='95 %']
        APPIUM_TAP_ELEMENTID   ${EV_services['SOC_increase']}
        RUN KEYWORD IF    "${result}" == "True"    Exit for loop
    END
    SLEEP    5
    ${result} =   WAIT ELEMENT BY XPATH    //*[@text='Permanent']
    RUN KEYWORD IF    '${result}' == 'True'     APPIUM_TAP_XPATH    //*[@text='Permanent']

SWIPE TO TIME
    [Arguments]    ${time}   ${hour_or_min}=hour    ${default_time}=7
    [Documentation]    Swipe until you find the wanted time for your calendar using xpath
    ...    == Parameters: ==
    ...    - _time_: value of time you want to set
    ...    - _x1_: the x value from where to start swiping
    ...    - _y1_: the y value from where to start swiping
    ...    - _hour_or_min_: could have the values: "hour or "min"
    ...    - _default_time_: the value of the hour/minute you want to change
    ...    == Expected Results: ==
    ...    Pass if executed
    Return From Keyword If    ${time} - ${default_time} == 0
    ${xpath} =    Set Variable If    ${default_time} < 10    //android.widget.TextView[@text='0${default_time}']
    ...    //android.widget.TextView[@text='${default_time}']
    ${coordinates} =    APPIUM_GET_XPATH_LOCATION    ${xpath}
    ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
    ${x1} =    Evaluate    ${x1} * 1.1
    ${y1} =    Evaluate    ${y1} * 1.1

    ${direction} =    Set Variable If    ${default_time} < ${time}    up    down
    ${nr_swipe} =    Run Keyword If    "${direction}" == "up"
    ...    Evaluate    ${time} - ${default_time}
    ...    ELSE    Evaluate    ${default_time} - ${time}
    ${nr_swipe} =    Run Keyword If    "${hour_or_min}" == "min"
    ...    Evaluate     ${nr_swipe} / 5
    ...    ELSE    Set Variable     ${nr_swipe}

    ${screen_size_x}    ${screen_size_y} =    GET DEVICE SCREEN SIZE

    IF    "${direction}" == "up"
        IF    ($screen_size_x > 1250 or $screen_size_y > 1400) and "${ivi_my_feature_id}" != "MyF3"
            ${y2} =    Evaluate    ${y1} - 100
        ELSE
            ${y2} =    Evaluate    ${y1} - 50
        END
    ELSE
        IF    $screen_size_x > 1250 or $screen_size_y > 1400
            ${y2} =    Evaluate    ${y1} + 100
        ELSE
            ${y2} =    Evaluate    ${y1} + 50
        END
    END

    ${x1} =    Evaluate    math.ceil(${x1})
    ${y1} =    Evaluate    math.ceil(${y1})
    ${y2} =    Evaluate    math.ceil(${y2})

    FOR    ${i}    IN RANGE    0    ${nr_swipe}
        swipe_by_coordinates    ${x1}    ${y1}    ${x1}    ${y2}    200
        Sleep    0.2
    END

APPIUM TAP EVSERVICES PROGRAM
    [Documentation]    Tap on Charge Planner tab from EVServices application
    Sleep    1
    APPIUM_TAP_XPATH    ${program}
    Sleep    1

    ${element} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['my_programs']}    10
    ${retrieved_text} =    Run Keyword If    '${element}' == "True"    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['my_programs']}

    Run Keyword If    "${retrieved_text}" == "Add" or "My program" in """${retrieved_text}"""    APPIUM_TAP_XPATH    ${EV_services['my_programs']}    30
    Sleep    0.2
    [Return]    ${retrieved_text}

TIME SETTING
    [Documentation]    Swipe until you find the wanted time for your calendar using xpath
    [Arguments]    ${time}   ${index}    ${x1}    ${y1}    ${x2}    ${y2}
    FOR    ${i}    IN RANGE    1    24
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['${index}']}
        Run Keyword If    "${retrieved_text}" != "${time}"    SWIPE    ${x1}    ${y1}    ${x2}    ${y2}
        ...    ELSE    Return From Keyword
    END

SWIPE
    [Documentation]    Swipe function based on the given coordinates
    [Arguments]    ${x1}    ${y1}    ${x2}    ${y2}
    ${x1} =    Evaluate    math.ceil(${x1})
    ${y1} =    Evaluate    math.ceil(${y1})
    ${x2} =    Evaluate    math.ceil(${x2})
    ${y2} =    Evaluate    math.ceil(${y2})
    swipe_by_coordinates    ${x1}    ${y1}    ${x2}    ${y2}    200
    Sleep    1
    @{time_setting_list} =    APPIUM_GET_ELEMENTS_BY_ID    ${EV_services['simple_charge_time_setting_menu']}
    Set Test Variable    @{time_setting_list}

SCHEDULE ONE CALENDAR
    [Arguments]    ${charge_switch_status}=on    ${temperature}=18
    [Documentation]    Schedule one calendar in EVServices application
    ...    Tap on advanced programs, enable/disable confort switch, select time to 21:15, all days on
    ...    == Parameters: ==
    ...    charge_switch_status: Represents the charge switch in HVAC to be on or off during scheduling
    ...    - _temperature_: The temperature value to be set
    APPIUM_TAP_XPATH    ${advanced_program}
    Sleep    0.1

    SWIPE TO TIME    21
    SWIPE TO TIME    15    min    0

    IF    "${ivi_my_feature_id}" == "MyF2"
        ${days_on} =    CREATE LIST   Monday    Tuesday    Wednesday    Thursday    Friday    Saturday    Sunday
        ENABLED DAYS    @{days_on}
    END

    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${EV_services['advanced_program_switch']}    10
    Run Keyword If    "${charge_switch_status}"=="off" and "${verdict}" == "True"    TAP_ON_ELEMENT_USING_ID    ${EV_services['advanced_program_switch']    10
    CONFIGURE TEMPERATURE    ${temperature}
    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from calendar

SCHEDULE TWO CALENDARS
    [Documentation]    Schedule two calendars in EVServices application
    ...    1st calendar: enable confort switch, select time to 14:00, disable monday and tuesday, set temperature to requested value
    ...    2nd calendar: disable charge switch, select time to 07:30, enable monday and friday, set temperature to requested value
     ...    == Parameters: ==
    ...    - _temperature_: The temperature value to be set
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Arguments]    ${temperature}=21
    Sleep    1
    APPIUM_TAP_XPATH    ${advanced_program}
    Sleep    1

    SWIPE TO TIME    14
    SWIPE TO TIME    0    min    0

    IF    "${ivi_my_feature_id}" == "MyF1"
        ${days_off} =    CREATE LIST   Monday    Tuesday
        DISABLED DAYS    @{days_off}
    ELSE
        ${days_on} =    CREATE LIST   Wednesday    Thursday    Friday    Saturday    Sunday
        ENABLED DAYS    @{days_on}
    END

    CONFIGURE TEMPERATURE    ${temperature}

    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    sleep    10
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from calendar
    sleep    10

    APPIUM TAP EVSERVICES PROGRAM
    Sleep    2
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['new_program']}

    Run Keyword If    "${retrieved_text}" == "New program" or "${retrieved_text}" == "New Program"    APPIUM_TAP_XPATH    ${EV_services['new_program']}
    ...    ELSE    Fail    Wrong XPATH for "New program" button
    Sleep    2

    APPIUM_TAP_XPATH    ${advanced_program}
    Sleep    1

    SWIPE TO TIME    7
    SWIPE TO TIME    30    min    0

    IF    "${ivi_my_feature_id}" == "MyF1"
        ${days_off} =    CREATE LIST   Tuesday    Wednesday    Thursday    Saturday    Sunday
        DISABLED DAYS    @{days_off}
    ELSE
        ${days_on} =    CREATE LIST   Monday    Friday
        ENABLED DAYS    @{days_on}
    END

    CONFIGURE TEMPERATURE    ${temperature}

    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from calendar

SCHEDULE TWO CALENDARS FOR MYF3
    [Documentation]    Schedule two calendars in EVServices application
    ...    1st calendar: enable confort switch, select time to 14:30, enable monday and thursday, set temperature to requested value
    ...    2nd calendar: disable charge switch, select time to 07:45, enable wednesday, friday and sunday, set temperature to requested value
     ...    == Parameters: ==
    ...    - _temperature_: The temperature value to be set
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Arguments]    ${temperature}=20
    Sleep    1
    LAUNCH APP APPIUM    EvMenu
    APPIUM_TAP_XPATH    ${climate_or_comfort}
    ${status}=    APPIUM_WAIT_FOR_XPATH    //*[@text='Add']
    Run Keyword If    "${status}"=="True"    APPIUM_TAP_XPATH    //*[@text='Add']
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Monday_myf3"]}
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Thursday_myf3"]}
    Sleep    1
    SWIPE TO TIME    14
    SWIPE TO TIME    30    min    0
    APPIUM_TAP_XPATH    //*[@text='Save']
    CONFIGURE TEMPERATURE    ${temperature}
    ${status}=    APPIUM_WAIT_FOR_XPATH    //*[@text='Add']
    Run Keyword If    "${status}"=="True"    APPIUM_TAP_XPATH    //*[@text='Add']
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Wednesday_myf3"]}
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Friday_myf3"]}
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Sunday_myf3"]}
    Sleep    1
    APPIUM_TAP_ELEMENTID    ${EV_services['charge_switch']}    10
    Sleep    1
    SWIPE TO TIME    7
    SWIPE TO TIME    45    min    0
    APPIUM_TAP_XPATH    //*[@text='Save']

SCHEDULE TWO MORE CALENDARS
    [Documentation]    == High Level Description: ==
    ...    Set two more calendars on the HMI.
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HVAC    IVI CMD
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${program}    10
    Run Keyword If    "${result}"=="True"     APPIUM_TAP_XPATH    ${program}
    Sleep    2
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['new_program']}

    Run Keyword If    "${retrieved_text}" == "New program" or "${retrieved_text}" == "New Program"    APPIUM_TAP_XPATH    ${EV_services['new_program']}
    ...    ELSE    Fail    Wrong XPATH for "New program" button
    Sleep    2
    APPIUM_TAP_XPATH    ${advanced_program}
    Sleep    1

    SWIPE TO TIME    22
    SWIPE TO TIME    10    min    0

    ${days_off} =    CREATE LIST   Monday    Wednesday    Thursday    Friday    Sunday
    DISABLED DAYS    @{days_off}
    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    sleep    10
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from calendar
    sleep    10

    ${result} =    APPIUM_WAIT_FOR_XPATH    ${program}    5
    Run Keyword If    "${result}"=="True"     APPIUM_TAP_XPATH    ${program}
    Sleep    2
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['new_program']}

    Run Keyword If    "${retrieved_text}" == "New program" or "${retrieved_text}" == "New Program"    APPIUM_TAP_XPATH    ${EV_services['new_program']}
    ...    ELSE    Fail    Wrong XPATH for "New program" button
    Sleep    2

    APPIUM_TAP_XPATH    ${advanced_program}
    Sleep    1

    SWIPE TO TIME    12
    SWIPE TO TIME    10    min    0

    ${days_off} =    CREATE LIST   Monday    Tuesday    Wednesday    Thursday    Saturday
    DISABLED DAYS    @{days_off}

    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10

APPIUM_REMOVE_CALENDARS
    [Documentation]    Remove existing calendars
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    ${wait_menu} =    APPIUM_WAIT_FOR_XPATH    ${program}    10
    Run Keyword If    "${wait_menu}" == "True"    APPIUM_TAP_XPATH    ${program}
    ${verdict} =    Run Keyword If    "${ivi_my_feature_id}"!="MyF3"    APPIUM_WAIT_FOR_XPATH    ${check_programs}    10
    Run Keyword If    "${verdict}" == "True" and "${ivi_my_feature_id}"!="MyF3"    APPIUM_TAP_XPATH    ${check_programs}
    Run Keyword If    "${ivi_my_feature_id}"=="MyF3"    APPIUM_WAIT_FOR_XPATH    //*[@text='No activated program']    10
    FOR    ${i}    IN RANGE    1    10
        ${verdict} =    Run Keyword If    "${ivi_my_feature_id}"!="MyF3"    APPIUM_WAIT_FOR_XPATH    ${EV_services['active_schedule_mode']}    10
        Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${EV_services['schedule_mode']}
        Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${EV_services['delete_icon']}
        Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${EV_services['delete_icon_myf3']}
        Sleep    3
        ${status}    ${text_retrieved} =     Run Keyword If    "${ivi_my_feature_id}"=="MyF3"    Run Keyword And Ignore Error    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['delete_button_myf3']}
        ...    ELSE    Run Keyword And Ignore Error    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['delete_button']}
        Run Keyword And Ignore Error    Exit For Loop If    "${status}" != "PASS"
        IF   "${ivi_my_feature_id}" != "MyF3"
            APPIUM_TAP_XPATH    ${EV_services['delete_button']}
        ELSE
            APPIUM_TAP_XPATH    ${EV_services['delete_button_myf3']}
        END
    END
    Sleep    1
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    APPIUM TAP EVSERVICES PROGRAM

ENABLED DAYS
    [Arguments]    @{days}
    [Documentation]    Enable the days @{days} from EV charge planner
    ...    All days are disabled by default, we need to enable the needed ones
    FOR    ${i}    IN    @{days}
        Log     ${i}
        ${is_checked} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['days']["${i}"]}    checked
        Run Keyword If    "${is_checked}" == "false"    APPIUM_TAP_XPATH    ${EV_services['days']["${i}"]}
        Sleep    0.2
    END

DISABLED DAYS
    [Arguments]    @{days}
    [Documentation]    Disabled the days @{days} from EV charge planner
    ...    All days are enabled by default, we need to disabled the unnecessary ones
    FOR    ${i}    IN    @{days}
        Log     ${i}
        ${is_checked} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['days']["${i}"]}    checked
        Run Keyword If    "${is_checked}" == "true"    APPIUM_TAP_XPATH    ${EV_services['days']["${i}"]}
        Sleep    0.2
    END

CHECK DAYS IN HMI
    [Arguments]    ${calendar_profile}
    [Documentation]        == High Level Description: ==
    ...    Check the Days enabled in IVI for the Caledar Program
    ...    == Parameters: ==
    ...    _calendar_profile_: calendars to be checked
    @{programmed_days} =   Create List
    Log    Values from the Calendar Profile ${calendar_profile} is: ${kmr_calendars["${calendar_profile}"]}
    ${size} =    Get Length    ${kmr_calendars["${calendar_profile}"]}
    FOR    ${index}    IN RANGE    0    ${size}
        ${dict_key} =    Get Dictionary Keys    ${kmr_calendars["${calendar_profile}"][${index}]}
        Append To List    ${programmed_days}    ${dict_key}[0]
    END
    Log    List of Days Programmed: ${programmed_days}

    @{days_enabled_in_IVI} =    Create List
    @{days_in_week} =    Create List    monday    tuesday    wednesday    thursday    friday    saturday    sunday
    FOR    ${index}    IN RANGE    1    8
        IF    '${sweet400_bench_type}' in "'${bench_type}'"
            ${day_xpath} =    Catenate    SEPARATOR=    ${EV_services['check_calendar_day_myf3']}    [${index}]
        ELSE
            ${day_xpath} =    Catenate    SEPARATOR=    ${EV_services['check_calendar_day']}    [${index}]
        END
        Log    The xpath of the Day element is: ${day_xpath}
        ${is_enabled} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${day_xpath}    enabled
        Run Keyword If    "${is_enabled}" == "true"    Append To List    ${days_enabled_in_IVI}    ${days_in_week[${index}-1]}
    END
    Log    List of Days Enabled in IVI: ${days_enabled_in_IVI}
    Lists Should Be Equal    ${programmed_days}    ${days_enabled_in_IVI}    Days Enabled in IVI is not matching with the Programmed Days

ONE CALENDAR
    [Documentation]    Check if one calendar profile was set properly in EVServices application
    IF    '${sweet400_bench_type}' in "'${bench_type}'"
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendar_myf3']}
    ELSE
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendar']}
    END
    Run Keyword If    "Ready at 14:00" in """${retrieved_text}"""    Log    Calendar 1 is ok
    ...    ELSE    Fail    Calendar isn't set properly
    CHECK DAYS IN HMI    one_active_calendar

TWO CALENDARS
    [Documentation]    Check if two calendars profile was set properly in EVServices application
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendars_1']}
    Run Keyword If    "Ready at 07:30 · 21 °C" in """${retrieved_text}"""    Log    Calendar 1 is ok
    ...    ELSE    Fail    Calendar 1 isn't set properly
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendars_2']}
    Run Keyword If    "Ready at 14:00 · 21 °C · Off-peak" in """${retrieved_text}"""    Log    Calendar 2 is ok
    ...    ELSE    Fail    Calendar 2 isn't set properly
    APPIUM_TAP_XPATH    ${EV_services['icon_navigation_bar']}
    Sleep    0.2
    APPIUM TAP EVSERVICES PROGRAM

TWO CALENDARS FROM MYR
    [Documentation]    Check if two calendars profile was set properly in EVServices application
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendars_1']}
    Should Contain    ${retrieved_text}    ${My_Renault_calendars['two_calendars_hvac']['calendar1']['hour']}
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendars_2']}
    Should Contain    ${retrieved_text}    ${My_Renault_calendars['two_calendars_hvac']['calendar2']['hour']}
    Sleep    0.2

EXTRACTING COORDINATES
    [Arguments]    ${dict}    ${delta_x}    ${delta_y}    ${delta}=True
    [Documentation]    == High Level Description: ==
    ...    Used for extracting the x,y values from a 2D representation and adding a delta to those values
    ...    == Parameters: ==
    ...    _dict_: a dictionary containing the linear representation
    ...    _delta_x_: an integer representing the desired value to be added to x
    ...    _delta_y_: an integer representing the desired value to be added to y
    ...    == Expected Results: ==
    ...    output: the initial and the new values
    [Tags]    Automated    RCSS    IVI CMD
    ${x} =    Get From Dictionary   ${dict}    x
    ${y} =    Get From Dictionary    ${dict}    y
    ${new_x} =    Evaluate    ${x} + ${delta_x}
    ${new_y} =    Evaluate    ${y} + ${delta_y}
    [Return]    ${x}    ${y}    ${new_x}    ${new_y}

*** Keywords ***
# High level keywords

CONFIGURE PRESOAK SETTINGS
    [Arguments]    ${profile}   ${charge_switch_status}=on
    [Documentation]    == High Level Description: ==
    ...    Make sure that a schedule with one/two calendars active are already set on IVI
    ...    == Parameters: ==
    ...    _profile_: Represents the number of calendars to be schedule
    ...    Could have the values: schedule_one_calendar/schedule_two_calendars
    ...    charge_switch_status: Represents the charge switch in HVAC to be on or off during scheduling
    ...    Could have the values: on/off
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HMI    IVI CMD
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    Sleep    5
    Run Keyword If    "${profile}" != "schedule_four_calendars"    LAUNCH EV AND REMOVE CALENDARS
    IF    "${ivi_my_feature_id}" != "MyF3"
        Run Keyword If    "${profile}" == "schedule_one_calendar"    SCHEDULE ONE CALENDAR    ${charge_switch_status}
        ...    ELSE IF    "${profile}" == "schedule_two_calendars"    SCHEDULE TWO CALENDARS
        ...    ELSE IF    "${profile}" == "schedule_four_calendars"    SCHEDULE TWO MORE CALENDARS
        ...    ELSE    FAIL    Profile "${profile}" doesn't exist
    ELSE
        Run Keyword If    "${profile}" == "schedule_two_calendars"    SCHEDULE TWO CALENDARS FOR MYF3
        ...    ELSE    FAIL    Profile "${profile}" doesn't exist
    END

LAUNCH EV AND REMOVE CALENDARS
    Sleep    1
    LAUNCH APP APPIUM    EvMenu
    Sleep    2
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    Sleep    5
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    Run Keyword If    "${ivi_my_feature_id}"!="MyF3"    APPIUM TAP EVSERVICES PROGRAM
    APPIUM_REMOVE_CALENDARS

CHECK THE HVAC SETTINGS ON HMI
    [Arguments]    ${profile}
    [Documentation]    == High Level Description: ==
    ...    Check the calendars properties that appear on the IVI display.
    ...    == Parameters: ==
    ...    - _profile_: The profile to be checked
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HVAC    IVI CMD
    IF    '${sweet400_bench_type}' in "'${bench_type}'"
        CHECK THE HVAC SETTINGS ON HMI FOR SW400    ${profile}
    ELSE
        CHECK THE HVAC SETTINGS ON HMI FOR SW200    ${profile}
    END


CHECK CALL IS IN PROGRESS
    [Documentation]    Check if phonecall is present on ivi
    IF    '${ivi_my_feature_id}'=='MyF3'
        ${call_in_progress} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell logcat -d | grep AudioModeChanged | grep MODE_IN_CALL
        Should Contain    ${call_in_progress}    MODE_IN_CALL
    ELSE
        ${call_in_progress} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell logcat -d | grep CallAudioRouteStateMachine | grep SPEAKER
        Should Contain    ${call_in_progress}    CallAudioRouteStateMachine
    END

TURN BLUETOOTH ON DEVICE
    [Arguments]    ${action}=ON      ${device_name}=ivi
    [Documentation]    Set device bluetooth ON/OFF
    ...    action: ON | OFF
    ...    device_name: IVI/PHONE

    Run Keyword If    "${device_name.lower()}" == "ivi"    CHECK AND SWITCH DRIVER    ${ivi_driver}
    ...      ELSE IF    "${device_name.lower()}" == "phone"    CHECK AND SWITCH DRIVER    ${mobile_driver}
    ...      ELSE      Fail    The ${device_name} is wrong!

    ${verdict} =    Run Keyword If      "${device_name.lower()}" == "ivi"     rfw_services.ivi.AndroidBluetoothLib.CHECK BT STATUS    device=${ivi_adb_id}
    ...      ELSE IF      "${device_name.lower()}" == "phone"     CHECK BT STATUS ON MOBILE   ${smartphone_adb_id}
    ...      ELSE      Fail    The ${device_name} is wrong!
    ${req_type}=    Set Variable If    "${action}" == "ON"    bt_enable_request    bt_disable_request
    Run Keyword If      "${verdict}" == "False" and "${device_name.lower()}" == "phone"    SET BT STATUS ON MOBILE    ${smartphone_adb_id}    ${BT_pair['${req_type}']}
    ...     ELSE      START INTENT    -a ${BT_pair['${req_type}']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']    retries=10
    Run Keyword If    "${result}" == "True"    APPIUM_TAP_XPATH    //*[@text='Allow']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Bluetooth']    retries=10
    Run Keyword If    "${result}" == "True"    APPIUM_TAP_XPATH    //*[@text='Bluetooth']

CONFIGURE TEMPERATURE
    [Arguments]    ${temperature}
    [Documentation]    == High Level Description: ==
    ...    Sets temperature for each IVI calendars.
    ...    == Parameters: ==
    ...    - _temperature_: The temperature value to be set
    ...    == Expected Results: ==
    ...    output: passed/failed
    IF    "${ivi_my_feature_id}" != "MyF3"
        ${element} =    APPIUM_WAIT_FOR_ELEMENT    ${EV_services['temperature']}    10
        Return From Keyword If    ${element} == False
        ${retrieved_temp_text} =    APPIUM_GET_TEXT    ${EV_services['temperature']}
    ELSE
        APPIUM_TAP_ELEMENTID    ${EV_services['set_temperature']}    10
        ${element} =    APPIUM_WAIT_FOR_ELEMENT    ${EV_services['temperature_myf3']}    10
        Return From Keyword If    ${element} == False
        ${retrieved_temp_text} =    APPIUM_GET_TEXT    ${EV_services['temperature_myf3']}
    END
    ${direction} =    Set Variable if   ${retrieved_temp_text} < ${temperature}    'right'    'left'
    ${nr_taps} =    Run Keyword If    ${retrieved_temp_text} < ${temperature}    Evaluate    (${temperature} - ${retrieved_temp_text})
    ...    ELSE    Evaluate    (${retrieved_temp_text} - ${temperature})
    FOR    ${i}    IN RANGE    0    ${nr_taps}
        Run Keyword If    (${direction} == 'right' and "${ivi_my_feature_id}" != "MyF3")    Run Keywords
        ...    TAP_ON_BUTTON    ${EV_services['right_arrow']}    10
        ...    AND    Sleep    0.2
        ...    ELSE IF    (${direction} == 'right' and "${ivi_my_feature_id}" == "MyF3")    Run Keywords
        ...    TAP_ON_BUTTON    ${EV_services['right_arrow_myf3']}    10
        ...    AND    Sleep    0.2
        ...    ELSE IF    (${direction} == 'left' and "${ivi_my_feature_id}" != "MyF3")    Run Keywords
        ...    TAP_ON_BUTTON    ${EV_services['left_arrow']}    10
        ...    AND    Sleep    0.2
        ...    ELSE IF    (${direction} == 'left' and "${ivi_my_feature_id}" == "MyF3")   Run Keywords
        ...    TAP_ON_BUTTON    ${EV_services['left_arrow_myf3']}    10
        ...    AND    Sleep    0.2
    END
    Run Keyword If    "${ivi_my_feature_id}"=="MyF3"    APPIUM_TAP_XPATH    //*[@text='Save']

LAUNCH MAPS APPIUM
    [Documentation]    == High Level Description: ==
    ...    Launch maps app
    LAUNCH APP APPIUM    AppsMenu
    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${maps_app}    direction=down
    APPIUM_TAP_XPATH    ${maps_app}

SET DESTINATION APPIUM MAPS
    [Arguments]    ${dest_address}    ${country}=RO
    [Documentation]    == High Level Description: ==
    ...   Set a destination
    ENABLE MULTI WINDOWS
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['search_button_map']}    20
    Sleep    2s
    TAP_ON_ELEMENT_USING_ID    ${car_settings['search_destination']}     5
    Sleep    2s
    ${status}     ${error} =    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_ID    ${car_settings['search_edit']}     5
    Run Keyword If    "${status}" == "FAIL"       TAP_ON_ELEMENT_USING_ID    ${car_settings['search_edit_FR']}     5
    Sleep    5s
    ${status}     ${error} =    Run Keyword And Ignore Error    APPIUM_ENTER_TEXT    ${car_settings['search_edit']}      ${dest_address}
    Run Keyword If    "${status}" == "FAIL"        APPIUM_ENTER_TEXT    ${car_settings['search_edit_FR']}      ${dest_address}
    sleep    10s
    APPIUM_TAP_XPATH    //*[@text='${dest_address}' and @class='android.widget.TextView']
    Sleep    10s
    ${status}     ${error} =    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_ID     ${car_settings['start_button']}    10
    Run Keyword If    "${status}" == "FAIL"        TAP_ON_ELEMENT_USING_ID     ${car_settings['start_button_FR']}    10
    Sleep    10s
    ${charging} =     WAIT ELEMENT BY XPATH    ${car_settings['charging_stations_route']}
    Sleep    2s
    Run Keyword If    "${charging}"=="True"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['charging_stations_route']}    5
    Sleep    5s

WIFI CONNECT APPIUM
    [Arguments]    ${target_id}    ${ssid}    ${password}
    [Documentation]    Connect to a wifi AP/Hotspot using Appium
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    DO WIFI CONNECT using Appium target_id:${target_id} ssid:${ssid} password:????
    LAUNCH APP APPIUM    Settings
    Run Keyword and Ignore Error    enable_multi_windows
    sleep    5
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${network_button}    5
    APPIUM_TAP_XPATH    ${network_button}
    APPIUM_TAP_XPATH    ${wifi_button}
    IF    "${platform_version}" == "10"
          ${curr_status} =    APPIUM_WAIT_FOR_XPATH    //*[@text= 'Wi‑Fi disabled']    10
          Run Keyword If    "${curr_status}" == "True"    TAP_ON_ELEMENT_USING_XPATH     ${onoff_button}    10
    ELSE IF    "${platform_version}" == "12"
           APPIUM_TAP_XPATH    //*[@text='Join other network']
           ${curr_status} =    APPIUM_WAIT_FOR_XPATH    //*[@text= 'Wi‑Fi disabled']    10
           Run Keyword If    "${curr_status}" == "True"    APPIUM_TAP_XPATH    ${wifi_button}
    END
    ${result}=    APPIUM_WAIT_FOR_XPATH    //*[@text='${ssid}']    20
    Run Keyword If   "${result}"=="False"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${network}    direction=down
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${ssid}']    20
    Should Be True    ${res}
    APPIUM_TAP_XPATH    //*[@text='${ssid}']
    sleep    3
    ENTER TEXT    ${wifi_pass_id}    ${password}
    sleep    5
    ${res} =    WAIT ELEMENT BY XPATH    //*[@text='Connected']    retries=20
    ${result} =   WAIT ELEMENT BY XPATH    ${Ok}
    Run Keyword If    "${result}"=="True"    TAP BY XPATH    ${Ok}
    sleep    5
    Run Keyword If    "${result}"=="False"    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    ${result} =   WAIT ELEMENT BY XPATH    ${Ok}
    Run Keyword If    "${result}"=="True"    TAP BY XPATH    ${Ok}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    ${ok_button} =    Create Dictionary    x=1093   y=670
    APPIUM_TAP_LOCATION    ${ok_button}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${Ok}    10
    Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    ${Ok}
    Run Keyword If    "${result}"=="False"    APPIUM_TAP_LOCATION    ${ok_button}
    ${ok_button} =    Create Dictionary    x=1093   y=670
    APPIUM_TAP_LOCATION    ${ok_button}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${Ok}    10
    Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    ${Ok}
    Run Keyword If    "${result}"=="False"    Run Keyword and Ignore Error    APPIUM_TAP_LOCATION    ${ok_button}
    sleep    3
    ${verdict} =     APPIUM_TAP_XPATH    ${data_screen_wifi}
    Sleep    1
    ${verdict} =     APPIUM_TAP_XPATH    ${data_screen_wifi}
    Sleep    1
    ${verdict} =     APPIUM_TAP_XPATH    ${back_button}
    Sleep    1
    ${verdict} =     APPIUM_TAP_XPATH    ${back_button}
    Sleep    3

FORGET WIFI APPIUM
    [Arguments]    ${target_id}    ${ssid}    ${password}
    [Documentation]    Forget WIFI with appium
    LAUNCH APP APPIUM    Settings
    Run Keyword and Ignore Error    enable_multi_windows
    sleep    5
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${network_button}    5
    APPIUM_TAP_XPATH    ${network_button}
    APPIUM_TAP_XPATH    ${wifi_button}
    Run Keyword If   "${result}"=="False"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${network}    direction=down
    ${res} =    WAIT ELEMENT BY XPATH    //*[@text='Connected']    retries=20
    Run Keyword If    "${res}"=="True"    Run Keywords    APPIUM_TAP_XPATH    //*[@text='${ssid}']    20
    ...    AND    APPIUM_TAP_XPATH    //*[@text= 'Forget']
    Repeat Keyword    2 times    APPIUM_TAP_XPATH    ${back_button}

REMOVE ADDRESS APPIUM
    [Documentation]    Remove the destination from maps
    ${delete_popup} =    Create Dictionary    x=385    y=206
    ${delete_address1} =    Create Dictionary    x=66    y=1011
    ${delete_address2} =    Create Dictionary    x=78    y=586
    sleep    10
    Run Keyword If    "${big_screen}" == "yes"    Run keywords   APPIUM_TAP_LOCATION    ${delete_popup}
    ...    AND    sleep    5
    ...    AND    APPIUM_TAP_LOCATION    ${delete_address1}
    ...    ELSE IF    "${small_screen}" == "yes"    APPIUM_TAP_LOCATION    ${delete_address2}

CHECK THE CHARGE SETTING MODE
    [Arguments]    ${mode}   ${presence}=true
    [Documentation]    == High Level Description: ==
    ...    Check that charging settings are displaying the schedule mode
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    Sleep    40
    ${instant_mode} =    APPIUM_GET_ATTRIBUTE_BY_XPATH   ${EV_services['instant_mode']}    selected
    ${delayed_mode} =    APPIUM_GET_ATTRIBUTE_BY_XPATH   ${EV_services['delayed_mode']}    selected
    ${schedule_mode} =    APPIUM_GET_ATTRIBUTE_BY_XPATH   ${EV_services['schedule_mode']}    selected
    Run Keyword If    "${mode}"=="instant"    Should Be True    "${instant_mode}" == "${presence}"
    ...    ELSE IF    "${mode}"=="delayed"    Should Be True    "${delayed_mode}" == "${presence}"
    ...    ELSE IF    "${mode}"=="scheduled"    Should Be True    "${schedule_mode}" == "${presence}"
    ...    ELSE    FAIL    Profile "${mode}" doesn't exist

DEACTIVATE ONE SCHEDULE
    [Documentation]    Deactivating existing charge schedules
    LAUNCH APP APPIUM    EvMenu
    Sleep    5
    APPIUM_TAP_XPATH    ${climate_or_comfort}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${EV_services['switch_button']}    20
    Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    ${EV_services['my_programs']}    30
    ${schedule_status} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['switch_button']}    checked
    Run Keyword If    "${schedule_status}"=="true"    appium_hlks.APPIUM_TAP_XPATH    ${EV_services['switch_button']}

APPIUM TAP ON BATTERY
    [Documentation]    Tap on Battery tab from EVSERVICES application
    Log to console    APPIUM TAP ON BATTERY
    ${received_text} =    appium_hlks.APPIUM_GET_TEXT_USING_XPATH    ${car_settings['ivi_battery']}
    Run Keyword If    "${received_text}" == "Battery" or "${received_text}" == "Battery Settings"    appium_hlks.APPIUM_TAP_XPATH    ${car_settings['ivi_battery']}
    ...    ELSE    Fail    Wrong button for "Battery"
    Sleep    0.2

CHECK BATTERY PERCENTAGE IN HMI
    [Arguments]    ${value}
    [Documentation]    Checking the battery percenatge in hmi
    ${percentage_value} =    APPIUM_GET_TEXT_BY_ID    ${car_settings['percentage']}
    Should Be Equal    ${value}    ${percentage_value}

CHECK IVI MYRENAULT ACCOUNT
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...     Check the MyRenault account is added or not, depending on the state, in the setting page of ivi
    IF    "${ivi_my_feature_id}" == "MyF2"
        CHECK IVI MYRENAULT ACCOUNT FOR MYF2    ${state}
    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "DOM" in "${ivi_build_id}"
        CHECK IVI MYRENAULT ACCOUNT FOR MYF3 DOM    ${state}
    ELSE
        FAIL    Not implemented for this scenario ${ivi_my_feature_id}
    END

CHECK IVI MYRENAULT ACCOUNT FOR MYF2
    [Arguments]    ${state}
    MANAGE ACCOUNT IN IVI
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['myr_account']}    20
    Run Keyword If    "${verdict}" == "True" and "${state}".lower() == "false"    Run Keywords
    ...     TAP_ON_ELEMENT_USING_XPATH    ${User_profile['myr_account']}    10
    ...     AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_account']}    10
    ...     AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_remove']}    10
    ${check_myr_acc} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['myr_account']}    20
    Run Keyword If    "${check_myr_acc}" == "False" and "${state}".lower() == "false"    Log    No account added
    ...    ELSE    LOG    Account was added.
    [Return]    ${verdict}

CHECK IVI MYRENAULT ACCOUNT FOR MYF3 DOM
    [Arguments]    ${state}
    APPIUM LAUNCH USER MANAGEMENT
    APPIUM_TAP_XPATH    ${User_profile['myr_profile_dom']}
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['myr_account']}    20
    Run Keyword If    "${verdict}" == "True" and "${state}".lower() == "false"    Run Keywords
    ...     TAP_ON_ELEMENT_USING_XPATH    ${User_profile['myr_account']}    10
    ...     AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_account_dom']}    10
    ...     AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_remove']}    10
    ${check_myr_acc} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['myr_account']}    20
    Run Keyword If    "${check_myr_acc}" == "False" and "${state}".lower() == "false"    Log    No account added
    ...    ELSE    LOG    Account was added.
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['back_privacy_settings']}    20
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}
    [Return]    ${verdict}

DO IVI ADD MYRENAULT ACCOUNT
    [Arguments]    ${email_id}    ${password}    ${pairing_available}=True
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a MyR account on IVI.
    IF    "${ivi_my_feature_id}" == "MyF2"
        DO IVI ADD MYRENAULT ACCOUNT FOR MYF2    ${email_id}    ${password}    ${pairing_available}
    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "DOM" in "${ivi_build_id}"
        DO IVI ADD MYRENAULT ACCOUNT FOR MYF3 DOM    ${email_id}    ${password}
    ELSE
        FAIL    Not implemented for this scenario ${ivi_my_feature_id}
    END

DO IVI ADD MYRENAULT ACCOUNT FOR MYF2
    [Arguments]    ${email_id}    ${password}    ${pairing_available}=True
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a MyR account on IVI.
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['select_myr']}    10
    SIGN IN TO MYRENAULT ACCOUNT IN IVI     ${email_id}    ${password}
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['skip_btn']}    20
    Run Keyword If     "${verdict}" == "True" and "${pairing_available}" == "False"    Run Keywords
    ...     APPIUM_TAP_ELEMENTID    ${User_profile['skip_btn']}
    ...     AND    APPIUM_WAIT_FOR_XPATH    ${User_profile['pairing_unsuccessful']}
    ...     AND    Return from keyword
    Sleep    5s
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['pairing_successful']}    20
    Run Keyword If     "${verdict}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['pairing_successful']}
    ${login_status} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${email_id}')]
    SHOULD BE TRUE    ${login_status}
    Log to console    Account was successfully added.

DO IVI ADD MYRENAULT ACCOUNT FOR MYF3 DOM
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a MyR account on IVI.
    APPIUM LAUNCH USER MANAGEMENT
    APPIUM_TAP_XPATH    ${User_profile['myr_profile_dom']}
    SIGN IN TO MYRENAULT ACCOUNT IN IVI MYF3     ${email_id}    ${password}
    ${login_status} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${email_id}')]
    SHOULD BE TRUE    ${login_status}
    Log to console    Account was successfully added.

DO IVI MYRENAULT UNPAIRING
    [Documentation]    == High Level Description: ==
    ...    Remove MyRenault account from IVI
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['myr_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_remove']}    10

CHECK PLAYSTORE APP
    [Documentation]    Check the internet connectivity - We should be on home screen or no notif bar before this KW
    [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    Run Keyword If    "${ivi_bench_type}" in "${bench_type}"    CHECKSET WIFI STATUS    ${ivi_adb_id}    on
    ENABLE MULTI WINDOWS
    Run Keyword And Ignore Error    LAUNCH APP APPIUM      PlayStore2
    Run Keyword And Ignore Error    LAUNCH APP APPIUM    PlayStore_FR
    APPIUM_WAIT_FOR_XPATH    //*[@text='Android phone' or @text='Sign in']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    ${status}     ${error} =    Run Keyword And Ignore Error    TAP BY XPATH    ${check_connection}
    Run Keyword If    "${status}" == "FAIL"    TAP BY XPATH    ${check_connection_FR}
    ${res} =    WAIT ELEMENT BY XPATH    //*[@text='Android phone' or @text='Sign in']
    GO HOME SCREEN APPIUM

CHECK IVI PUSH MESSAGE
    [Documentation]    Check the push message is present on IVI
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    expand
    Should Be True    ${verdict}
    Sleep    5
    ${res} =    WAIT ELEMENT BY XPATH    //*[@text='Dual Connectivity Test OK']    retries=10
    Should Be True    ${res}
    ${retrieved_text} =     APPIUM_GET_TEXT    //*[@resource-id='com.android.systemui:id/notification_body_title']
    Sleep    5

CHECK THE DESTINATION
    [Documentation]    Check the destination if is set
    [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_HOME}
    Run Keyword and Ignore Error    enable_multi_windows
    ${charging} =     WAIT ELEMENT BY XPATH    ${car_settings['charging_stations_route']}    retries=30
    Run Keyword If    "${charging}"=="True"    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    ${result} =   WAIT ELEMENT BY XPATH    //*[@text='Duranus']    retries=30
    Run Keyword If    "${result}"=="False"    Run Keyword    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['second_destination_button']}    5    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    ${result} =    WAIT ELEMENT BY XPATH    //*[@text='Duranus']    retries=30
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    [Return]    ${result}

CHECK SCHEDULE NOT SYNCHRONIZED IN HMI
    [Documentation]    Check the HVAC schedule is not synchronized in HMI as MYR
    ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['check_calendar']}
    Run Keyword If    "Ready at 14:00" not in """${retrieved_text}"""    Log    Calendar 1 is not synchronized
    ...    ELSE    Fail    Calendar is set properly

CHECK IVI SOFTWARE UPDATE FAILED
    [Documentation]    Check the Software Update Failed
    ${retrieved_text} =     APPIUM_GET_TEXT    ${car_settings['software_update_failed']}
    Should Contain    ${retrieved_text}    Software update failed

DO ENABLE IVI LEMON PRIVACY MANAGER
    [Documentation]     This KW is used to configure lemonade on IVI.
    ${check_privacy_file} =    CHECK FILE PRESENT    ivi    ${privacy_file}
    Run Keyword If    "${check_privacy_file}" == "True"    Return from keyword
    Run Keyword If    "${check_privacy_file}" == "False"
    ...     DOWNLOAD ARTIFACTORY FILE    ${privacy_file_path}
    SET ROOT
    ${output}    ${error} =    PUSH    ${privacy_file}    /data/user/0/com.alliance.lemonad/shared_prefs
    Should Contain    ${output}    privacyManagerActivationStatus.xml: 1 file pushed
    rfw_services.ivi.SystemLib.REBOOT

CHECK TEMPERATURE UNCHANGED IN CAMAN MODE
    [Documentation]    Check the temperature cant be changed when vehicle in CAMAN configuration
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    APPIUM_TAP_XPATH    ${program}
    Sleep    1

    TAP_ON_ELEMENT_USING_ID    ${EV_services['first_HVAC_schedule']}    10
    TAP_ON_ELEMENT_USING_ID    ${EV_services['climate_temperature']}    10
    ${right_scroll_found} =    APPIUM_WAIT_FOR_ELEMENT    ${EV_services['climate_change_right']}    10
    Should Be Equal    "False"    "${right_scroll_found}"
    ${left_scroll_found} =    APPIUM_WAIT_FOR_ELEMENT    ${EV_services['climate_change_left']}    10
    Should Be Equal    "False"    "${left_scroll_found}"

    APPIUM_TAP_ELEMENTID    ${EV_services['back_button']}

CHECK PLAN IS DEACTIVATED IN HMI
    [Documentation]    Check the expected schedule is deactivated in HMI
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    APPIUM_TAP_XPATH    ${program}
    Sleep    1
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${EV_services['switch_button']}    20
    Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    ${EV_services['my_programs']}    30
    ${schedule_status} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['switch_button']}    checked
    Should Not Be Equal    "true"    "${schedule_status}"
    Should Be Equal    "false"    "${schedule_status}"

SELECT WIDGET ON IVI
    [Arguments]    ${widget_name}
    [Documentation]    Select the widget in IVI
    ...    == Parameters: ==
    ...    - _widget_name_: Driving Eco , Audio , EVServices ,..
    LAUNCH APP APPIUM    Navigation
    ${text_con} =    APPIUM_GET_TEXT_USING_XPATH    ${car_settings['text_second_widget']}
    Run Keyword If    "${text_con}" == "Google Assistant"    LONG PRESS ELEMENT APPIUM    ${car_settings['first_widget_below']}
    ...    ELSE    LONG PRESS ELEMENT APPIUM    ${car_settings['second_widget_below']}
    Sleep    10
    FOR    ${i}    IN RANGE    1    8
        ${day_status} =    APPIUM_GET_TEXT_USING_XPATH    (//android.widget.TextView[@resource-id='com.renault.launcher:id/application_component_text_view'])[${i}]
        Run Keyword if    "${day_status}".lower() == "${widget_name}".lower()    Run Keywords    TAP_ON_ELEMENT_USING_XPATH    (//android.widget.TextView[@resource-id='com.renault.launcher:id/application_component_text_view'])[${i}]    10
        ...     AND    Exit for loop
    END
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['widget_back_button']}    20
    Sleep    5

CHECK CHARGE WIDGET UPDATE
    [Arguments]    ${expected_text}
    [Documentation]    Check the charge widget in IVI is updated with the mode
    ...    == Parameters: ==
    ...    - _expected_text_: The text we needed in charge widget
    LAUNCH APP APPIUM    Navigation
    ${received_text} =    APPIUM_GET_TEXT    ${car_settings['text_first_widget']}
    Should Be Equal    "${expected_text}"    "${received_text}"

SCHEDULE ONE CHARGING CALENDAR AND ONE CLIMATE CALENDAR
    [Documentation]    == High Level Description: ==
    ...    Checks SW version in order if we have MyF1, MyF2 or Myf3 build.
    ...    Set a charging and climate calendar on the HMI
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS/HVAC    IVI CMD
    IF    "${ivi_my_feature_id}" == "MyF3"
        SCHEDULE ONE CHARGING CALENDAR AND ONE CLIMATE CALENDAR FOR MYF3
    ELSE
        SCHEDULE ONE CHARGING CALENDAR AND ONE CLIMATE CALENDAR FOR MyF1 AND MyF2
    END

SCHEDULE ONE CHARGING CALENDAR AND ONE CLIMATE CALENDAR FOR MyF1 AND MyF2
    [Documentation]    == High Level Description: ==
    ...    Set a charging and climate calendar on the HMI for MyF1 and MyF2
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS/HVAC    IVI CMD
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    APPIUM TAP EVSERVICES PROGRAM
    APPIUM_WAIT_FOR_XPATH    ${EV_services['new_program']}    10
    ${simple_charge_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['charge']}    selected
    Run Keyword If    "${simple_charge_selected}".lower() == "false"    APPIUM_TAP_XPATH    ${EV_services['charge']}
    Sleep    1
    ${active_days} =    Set Variable    ${calendars['scheduled_one_calendar']['active_days']}
    FOR    ${day}    IN    @{active_days}
        ${day_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    com.renault.evservices:id/calendar${day}Button    checked
        Run Keyword If    "${day_status}".lower() == "false"    TAP_ON_BUTTON    com.renault.evservices:id/calendar${day}Button    5
    END
    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    Run Keyword If    "${retrieved_text}".lower() == "save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    5
    ...    ELSE    Fail    Wrong PATH for "Save" button from days selection menu
    ${physical_screen_size} =    GET PHYSICAL SCREEN SIZE    ${ivi_adb_id}
    Run Keyword If    "${physical_screen_size}" == "1250x834"    APPIUM TAP EVSERVICES PROGRAM
    TAP_ON_ELEMENT_USING_ID    ${EV_services['NewProgram']}    10
    TAP_ON_ELEMENT_USING_ID    ${EV_services['advanced_program_climate']}    10
    APPIUM_TAP_XPATH    ${EV_services['days']["Monday"]}
    Sleep    0.2
    APPIUM_TAP_XPATH    ${EV_services['days']["Tuesday"]}
    Sleep    0.2
    SWIPE TO TIME    21
    SWIPE TO TIME    15    min    0
    CONFIGURE TEMPERATURE    19
    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from calendar

SCHEDULE ONE CHARGING CALENDAR AND ONE CLIMATE CALENDAR FOR MYF3
    [Documentation]    == High Level Description: ==
    ...    Set a charging and climate calendar on the HMI for MyF3
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS/HVAC    IVI CMD
    LAUNCH APP APPIUM    EvMenu
    APPIUM_TAP_XPATH    ${climate_or_comfort}
    ${status}=    APPIUM_WAIT_FOR_XPATH    //*[@text='Add']
    Run Keyword If    "${status}"=="True"    APPIUM_TAP_XPATH    //*[@text='Add']
    Sleep    1
    ${active_days} =    Set Variable    ${calendars['scheduled_one_calendar']['active_days']}
    FOR    ${day}    IN    @{active_days}
        ${day_status} =    APPIUM_GET_ATTRIBUTE_BY_ID    com.renault.car.evservices:id/newProgramCalendar${day}Button    checked
        Run Keyword If    "${day_status}".lower() == "false"    TAP_ON_BUTTON    com.renault.car.evservices:id/newProgramCalendar${day}Button    5
    END
    APPIUM_TAP_XPATH    //*[@text='Save']
    ${status}=    APPIUM_WAIT_FOR_XPATH    //*[@text='Add']
    Run Keyword If    "${status}"=="True"    APPIUM_TAP_XPATH    //*[@text='Add']
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Monday_myf3"]}
    Sleep    1
    APPIUM_TAP_XPATH    ${EV_services['days']["Tuesday_myf3"]}
    Sleep    1
    SWIPE TO TIME    21
    SWIPE TO TIME    15    min    0
    APPIUM_TAP_XPATH    //*[@text='Save']

CHANGE HVAC SCHEDULE DAYS
    [Documentation]    Remove some days from HVAC schedule
    LAUNCH APP APPIUM    EvMenu
    Sleep    2
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    Sleep    5
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    APPIUM TAP EVSERVICES PROGRAM
    APPIUM_TAP_XPATH    ${EV_services['first_schedule']}
    ${days_off} =    CREATE LIST   Thursday    Friday    Saturday    Sunday
    DISABLED DAYS    @{days_off}

    ${retrieved_text} =    APPIUM_GET_TEXT    ${EV_services['program_save_button']}
    sleep    10
    Run Keyword If    "${retrieved_text}" == "Save"    TAP_ON_BUTTON    ${EV_services['program_save_button']}    10
    ...    ELSE    Fail    Wrong PATH for "Save" button from calendar
    sleep    10

CHECK ONE HVAC SCHEDULE PRESENT
    [Documentation]    Remove some days from HVAC schedule
    ${only_first_element} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['first_schedule']}    20
    Should Be True    ${only_first_element}
    ${second_element} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['second_schedule']}    20
    Should Not Be True    ${second_element}

WIFI CONNECTION
    [Documentation]    Remove the last connection to the wifi and reconnect
    ${result} =    CHECK THE WIFI CONNECTION
    IF  "${result}"!="True"
        Run Keyword And Ignore Error    FORGET WIFI APPIUM    ${ivi_adb_id}    ${wifi_ssid}    ${wifi_pwd}
        Run Keyword And Ignore Error    WIFI CONNECT APPIUM    ${ivi_adb_id}    ${wifi_ssid}    ${wifi_pwd}
    END
    Sleep    1
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${back_button}
    Sleep    1
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${back_button}
    Sleep    3

CHECK THE WIFI CONNECTION
    [Documentation]    This is checking the IVI wifi connection to the right network
    LAUNCH APP APPIUM    Settings
    Run Keyword and Ignore Error    enable_multi_windows
    sleep    5
    APPIUM_WAIT_FOR_XPATH    ${network_button}    5
    APPIUM_TAP_XPATH    ${network_button}
    ${result}=    APPIUM_WAIT_FOR_XPATH    //*[@text='${wifi_ssid}']    20
    Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    //*[@text='${wifi_ssid}']
    Run Keyword If   "${result}"=="False"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${wifi_ssid}    direction=down
    ${wifi_verdict} =    Run Keyword If    "${result}"=="True"    WAIT ELEMENT BY XPATH    //*[@text='Connected' or @text='Disconnect']    retries=20
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${back_button}
    Sleep    1
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${back_button}
    Sleep    1
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${back_button}
    [Return]    ${wifi_verdict}

DO IVI ADD MYRENAULT ACCOUNT FAILED
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a MyR account on IVI and check its failing.
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['select_myr']}    10
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['Activate']}    10
    Run Keyword If    "${verdict}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['Activate']}    10
    Sleep    5
    SIGN IN TO MYRENAULT ACCOUNT IN IVI     ${email_id}    ${password}
    ${success_id} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['pairing_successful']}    10
    Run Keyword If    "${success_id}" == "True"    Fail   Account was added successfully
    Should Be Equal    "${success_id}"    "False"
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['skip_element']}    10
    Log to console    Account was not added due to connectivity lack

CHECK IVI GOOGLE ACCOUNT
    [Arguments]    ${mode}    ${state}
    [Documentation]    == High Level Description: ==
    ...     Check the Google account is NOT added in the setting page of ivi
    MANAGE ACCOUNT IN IVI
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_account']}    20
    Run Keyword If    "${verdict}" == "True" and "${state}".lower() == "false"    Run Keywords
    ...     TAP_ON_ELEMENT_USING_XPATH    ${User_profile['google_account']}    10
    ...     AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_account']}    10
    ...     AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_remove']}    10
    ${check_myr_acc} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_account']}    20
    Run Keyword If    "${check_myr_acc}" == "False" and "${state}".lower() == "false"    Log    No account added
    ...    ELSE    LOG    Account was added.

DO IVI PART AUTHENTICATION
    [Documentation]    == High Level Description: ==
    ...    Do the part authentication status on IVI
    ...    == Parameters: ==
    ...    - none
    ...    == Expected Results: ==
    ...    pass when output contains: CertificateInstalled
    ...    fails otherwise
    DO RESET IVI PART AUTHENTICATION STATUS
    DO BCM STANDBY
    CONFIGURE VEHICLE STUB PROFILE    keep_ivc_and_ivi_on_vehicle_running
    CHECK IVI TO VNEXT MESSAGE VA    certificateInstalled
    CHECK VNEXT VIN CERTIFICATE STATUS    IVI    Burnt

SET HMI BATTERY ENERGY LEVEL
    [Arguments]    ${value}    ${status}
    [Documentation]    Set and check battery level to expected value or not
    LAUNCH APP APPIUM    EvMenu
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@text='Battery']
    Sleep    5s
    IF    "${ivi_my_feature_id}" == "MyF2"
        SET HMI BATTERY ENERGY LEVEL FOR MYF2    ${value}    ${status}
    ELSE
        SET HMI BATTERY ENERGY LEVEL FOR MYF3    ${value}    ${status}
    END

SET HMI BATTERY ENERGY LEVEL FOR MYF2
    [Arguments]    ${value}    ${status}
    [Documentation]    Set and check battery level to expected value or not in MyF2
    ${current_battery_level} =   APPIUM_GET_TEXT    ${EVMenu['battery_level']}
    @{current_battery_level} =    Split String    ${current_battery_level}    ${space}
    ${output} =    Evaluate    int((${current_battery_level}[0] - ${value})/5)
    log   ${current_battery_level}[0]
    ${result} =    Evaluate    ${output} > 0
    ${output} =    Run Keyword If    "${result}" == "True"    Evaluate    ${output} - 1
    ...    ELSE    Evaluate    ${output} + 1
    ${result1} =    Evaluate    abs(${output})
    ${button} =    Set Variable If    "${result}" == "True"    ${EVMenu['left_battery_button']}    ${EVMenu['right_battery_button']}
    FOR    ${index}    IN RANGE    0    ${result1}
        APPIUM_TAP_XPATH    ${button}
        Sleep    5s
    END
    ${result} =   WAIT ELEMENT BY XPATH    ${button}
    Should Be Equal    ${result}    ${status}

SET HMI BATTERY ENERGY LEVEL FOR MYF3
    [Arguments]    ${value}    ${status}
    [Documentation]    Set and check battery level to expected value or not in MyF3
    ${current_battery_level} =   APPIUM_GET_TEXT    ${EVMenu['battery_level']}
    @{current_battery_level} =    Split String    ${current_battery_level}    ${space}
    ${output} =    Evaluate    int((${current_battery_level}[0] - ${value})/5)
    log   ${current_battery_level}[0]
    ${result} =    Evaluate    ${output} > 0
    ${result1} =    Evaluate    abs(${output})  
    FOR    ${i}    IN RANGE    0    ${result1}
        ${coordinates} =    APPIUM_GET_XPATH_LOCATION    ${EVMenu['max_value_dot']}
        ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
        ${swipe_left_x} =     Evaluate       ${x1}-50
        ${swipe_right_x} =     Evaluate       ${x1}+50
        ${swipe_x} =    Set Variable If    "${result}" == "True"    ${swipe_left_x}    ${swipe_right_x}
        drag_drop_from_element_xpath_to_coordinates      ${EVMenu['max_value_dot']}     ${swipe_x}      ${y1}
        ${current_battery_level} =   APPIUM_GET_TEXT    ${EVMenu['battery_level']}
        log   ${current_battery_level}
        Sleep    5s
    END
    ${updated_battery_level} =   APPIUM_GET_TEXT    ${EVMenu['battery_level']}
    ${result} =    Set variable if    "${updated_battery_level}" == "${value}"    ${True}    ${False}
    Sleep    5s
    Should Be Equal    ${result}    ${status}

VERIFY GUEST USER
    [Documentation]    == High Level Description: ==
    ...     Check the Guest user profile is not changed
    Sleep    10s
    APPIUM LAUNCH USER MANAGEMENT
    Sleep    5s
    ${user_profile} =    APPIUM_GET_TEXT    ${User_profile['guest']}    10
    Should Contain    ${user_profile}    Guest

CHECK NO MYR ACCOUNT NOTIFICATION DISPLAYED
    [Documentation]    == High Level Description: ==
    ...     Check no myrenault account notification is displayed
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['no_myrenault_account_notification']}    10
    ${sign_in_button} =    APPIUM_GET_TEXT    ${User_profile['myr_sign_in']}    10
    Should Contain    ${sign_in_button}    Sign in

VERIFY AUTOMATIC PAIRING ENABLED
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...     Enable the automatic pairing and check in the myr setting page of ivi
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['myr_account']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['myr_settings']}    20
    Sleep    2
    ${text_retrieved} =    APPIUM_GET_TEXT   ${User_profile['automatic_connection_status']}    20
    Run Keyword If    "${state}"!="${text_retrieved}".lower()    TAP_ON_ELEMENT_USING_ID    ${User_profile['automatic_connection']}    20

SIGN IN TO MYRENAULT ACCOUNT IN IVI
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to signin to MY Renault account on IVI
    SCROLL_TO_ELEMENT    ${User_profile['acc_sign_in']}    down    5
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['acc_sign_in']}    10
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['next']}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['next']}
    APPIUM_TAP_ELEMENTID    ${User_profile['sign_in_username']}
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['auto_fill']}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['auto_fill']}
    APPIUM_ENTER_TEXT    ${User_profile['sign_in_username']}     ${email_id}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    sleep    2
    APPIUM_ENTER_TEXT    ${User_profile['sign_in_password']}    ${password}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Log To Console   Password entered
    sleep    2
    APPIUM_TAP_ELEMENTID    ${User_profile['connect']}
    sleep    15

SIGN IN TO MYRENAULT ACCOUNT IN IVI MYF3
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to signin to MY Renault account on IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['acc_sign_in_dom']}    10
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['next']}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['next']}
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['auto_fill']}    10
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['auto_fill']}
    APPIUM_ENTER_TEXT    ${User_profile['sign_in_username_dom']}     ${email_id}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['connect_pairing_dom']}    10
    APPIUM_ENTER_TEXT    ${User_profile['sign_in_password_dom']}    ${password}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Log To Console   Password entered
    sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['connect_pairing_dom']}    10
    Sleep    30
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['next_pairing_dom']}   10
    Run Keyword If    ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_pairing_dom']}    5
    sleep    15

CHECK MYR ACCOUNT SIGNIN FAILED WHEN NO CONNECTIVITY
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to check signin to MY Renault account failed on IVI
    ...     when there is no connectivity
    SIGN IN TO MYRENAULT ACCOUNT IN IVI     ${email_id}    ${password}
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['myrenaullt_signin_error_content']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['skip_element']}    10
    APPIUM_WAIT_FOR_XPATH    ${User_profile['myrenault_account_not_connected']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['accept_google_services']}    10

ACCEPT TERMS AND CONDITION
    [Arguments]    ${res}=False
    [Documentation]    == High Level Description: ==
    ...     This KW is used to accepts google terms and condition from welcome page
    TAP_ON_ELEMENT_USING_ID    ${User_profile['welcome_begin']}    60
    Sleep    2s
    IF    "${ivi_my_feature_id}" == "MyF1"
        ACCEPT TERMS AND CONDITION FOR MYF1
    ELSE
        ACCEPT TERMS AND CONDITION FOR MYF2
    END
    Return From Keyword If    "${res}"=="True"    Sleep    2s
    APPIUM_TAP_XPATH    ${User_profile['finished_for_now_button']}    retries=20

ACCEPT TERMS AND CONDITION FOR MYF1
    [Documentation]    This keyword is used to accept google terms and condition from welcome page in MYF1
    SCROLL_TO_ELEMENT    xpath=${User_profile['privacy_confirm']}    down    8
    Sleep    2s
    APPIUM_TAP_XPATH    ${User_profile['accept_terms']}    30
    TAP_ON_ELEMENT_USING_ID    ${User_profile['privacy_confirm']}    30
    Sleep    2s
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['google_terms_accept']}    30
    Run Keyword If    "${elemt}"=="True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['google_terms_accept']}    30
    Sleep    2s
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['next_button']}    30
    Run Keyword If    "${elem}"=="True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_button']}    30

ACCEPT TERMS AND CONDITION FOR MYF2
    [Documentation]    This keyword is used to accept google terms and condition from welcome page in MYF2
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['skip_button']}    30
    Run Keyword If    "${elemt}"=="True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['skip_button']}    15
    Sleep    5s
    SCROLL_TO_ELEMENT    xpath=${User_profile['privacy_confirm']}    down    8
    Sleep    2s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['accept_terms']}    30
    TAP_ON_ELEMENT_USING_ID    ${User_profile['privacy_confirm']}    30
    Sleep    2s
    ${elemt} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['google_terms_accept']}    30
    Run Keyword If    "${elemt}"=="True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['google_terms_accept']}    30
    Sleep    2s
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['next_button']}    30
    Run Keyword If    "${elem}"=="True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_button']}    30

VERIFY SUMMARY SCREEN
    [Documentation]    == High Level Description: ==
    ...     This KW is used to check buttons are present in summary screen
    ${element1} =    APPIUM_GET_TEXT    ${User_profile['data_plan']}    10
    Should Contain    ${element1}    Activate the data plan
    ${element2} =    APPIUM_GET_TEXT    ${User_profile['suw_gbutton']}    10
    Should Contain    ${element2}    Set up Google Assistant and apps
    ${element3} =    APPIUM_GET_TEXT    ${User_profile['suw_profile']}    10
    Should Contain    ${element3}    Customise your profile

CHECK DATA PLAN
    [Documentation]    == High Level Description: ==
    ...     Check if the data plan option is available
    ${element} =    APPIUM_GET_TEXT    ${User_profile['data_plan']}    10
    Should Contain    ${element}    Activate the data plan

VERIFY MYR ACCOUNT PAIRING NOTIFICATION
    [Documentation]    == High Level Description: ==
    ...     Check the ivi receive the notification for myr not connected and myr connected
    APPIUM_SCROLL_NOTIFICATION_BAR     620    20    620    250
    Sleep    5s
    ${no_myr_account_msg} =    APPIUM_GET_TEXT    ${User_profile['no_myr_account']}    10
    Should Contain    ${no_myr_account_msg}    Your MY Renault account is not connected
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['no_myr_account']}    10
    Sleep    80s
    APPIUM_SCROLL_NOTIFICATION_BAR     620    20    620    250
    Sleep    20s
    ${myr_account_msg} =    APPIUM_GET_TEXT    ${User_profile['myr_account_connected']}    10
    Should Contain    ${myr_account_msg}    Your MY Renault account is connected

VERIFY NO MYR ACCOUNT CONNECTED
    [Documentation]    == High Level Description: ==
    ...     Verify no myr account connected notification
    LAUNCH APP APPIUM    Navigation
    Sleep    6s
    APPIUM_SCROLL_NOTIFICATION_BAR     620    20    620    250
    Sleep    6s
    ${no_myr_account_msg} =    APPIUM_GET_TEXT    ${User_profile['no_myr_account_msg']}    10
    Should Contain    ${no_myr_account_msg}    No My Renault account connected.

ADD MYR ACCOUNT IN IVI USING NOTIFICATION
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     Add myr account using ivi notification
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['no_myr_account_msg']}    10
    Sleep    5s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['activate_option']}    10
    Sleep    5s
    SIGN IN TO MYRENAULT ACCOUNT IN IVI    ${email_id}    ${password}
    APPIUM_TAP_ELEMENTID    ${User_profile['pairing_successful']}
    Log to console    Account was successfully added.

ADD MYR ACCOUNT FOR PROFILE IN IVI
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a MyR account on IVI (initial steps)
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['select_myr']}    10

ADD MYRENAULT ACCOUNT PRIVACY ON
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a MyR account on IVI when privacy on and check its failing.
    ADD MYR ACCOUNT FOR PROFILE IN IVI
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['cancel_button']}    10
    Run Keyword If    "${verdict}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['cancel_button']}    10
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['privacyok_button']}    10
    Run Keyword If    "${verdict}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['privacyok_button']}    10
    Sleep    5
    SCROLL_TO_ELEMENT    ${User_profile['acc_sign_in']}    down    5
    ${enabled} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${User_profile['acc_sign_in']}    enabled
    Should Be Equal    "${enabled}"    "false"

CHECK AUTOMATIC PAIRING ACTIVATED
    [Documentation]    == High Level Description: ==
    ...     Click on Notification appears when automatic pairing is ON
    Sleep    80
    APPIUM_SCROLL_NOTIFICATION_BAR     620    20    620    250
    sleep    20
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['myr_account_connected']}    10
    Sleep    5

COMPLETE PROFILE SETUP
    [Arguments]    ${set_myr_account}=False    ${email_id}=None    ${password}=None    ${skip_myr_account}=False    ${set_google_account}=False    ${via_notification}=False
    [Documentation]    == High Level Description: ==
    ...    Complete Profile settings in the setup wizard
    ...    == Parameters: ==
    ...    - set_myr_account: set myr account during setup
    ...    - email_id: myr account mail id
    ...    - password: myr account password
    ...    - skip_myr_account: skip myr account sign in
    ...    - set_google_account: set google account in set up wizard
    ...    - via_notification: complete profile setup using notification
    ...    == Expected Results: ==
    ...    output: Profile settings should be finished
    IF    "${ivi_my_feature_id}" == "MyF1"
        COMPLETE PROFILE SETUP CONTINUATION FOR MYF1    ${set_myr_account}    ${email_id}    ${password}    ${skip_myr_account}    ${set_google_account}    ${via_notification}
    ELSE
        COMPLETE PROFILE SETUP CONTINUATION FOR MYF2    ${set_myr_account}    ${email_id}    ${password}    ${skip_myr_account}    ${set_google_account}    ${via_notification}
    END

COMPLETE PROFILE SETUP CONTINUATION FOR MYF1
    [Documentation]    Continuing complete profile setup for MYF1
    [Arguments]    ${set_myr_account}=False    ${email_id}=None    ${password}=None    ${skip_myr_account}=False    ${set_google_account}=False    ${via_notification}=False
    IF    "${via_notification}" == "False"
        START INTENT    -n com.google.android.car.setupwizard/.CarSetupWizardTestActivity
    END
    Sleep    3s
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['suw_renault_logo']}    60
    ${get_language} =    APPIUM_GET_TEXT    ${User_profile['suw_language_summary']}
    Run Keyword If    '${get_language}'!='English'     Run Keywords
    ...      TAP_ON_ELEMENT_USING_ID    ${User_profile['change_language']}    15
    ...      AND    SCROLL_TO_ELEMENT     xpath=${User_profile['language_english']}    down    30
    ...      AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['language_english']}    30
    ...      AND    APPIUM_TAP_XPATH    ${User_profile['language_english_UK']}
    TAP_ON_ELEMENT_USING_ID    ${User_profile['welcome_begin']}    15
    Sleep    5s
    APPIUM_WAIT_FOR_XPATH    ${User_profile['suw_privacy_terms_screen']}    30
    FOR  ${i}  IN RANGE    0    5
        #swipe_by_coordinates    550    1100    550    238
        SCROLL_TO_ELEMENT    xpath=${User_profile['privacy_confirm']}    down    5
        Sleep     5s
        @{share_services} =    APPIUM_GET_ELEMENTS_BY_XPATH    ${User_profile['accept_terms']}
        ${count} =    Get length     ${share_services}
        Exit For Loop If    ${count} == 1
    END
    APPIUM_TAP_XPATH    ${User_profile['accept_terms']}    30
    Sleep    3s
    TAP_ON_ELEMENT_USING_ID    ${User_profile['privacy_confirm']}    30
    Sleep    10s
    Run Keyword If    ${skip_myr_account}==True    Run Keywords
    ...      TAP_ON_ELEMENT_USING_XPATH    ${User_profile['setup_skip_button']}    30
    ...      AND    TAP_ON_ELEMENT_USING_ID     ${User_profile['unsuccessful_next']}    30
    Run Keyword If    ${set_myr_account}==True    SIGN IN TO MYRENAULT ACCOUNT IN IVI    ${email_id}    ${password}
    ${pair} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['pairing_successful']}    10
    Run Keyword If    "${pair}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['pairing_successful']}
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['suw_google_services_title']}    20
    ${acc_term} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['google_terms_accept']}    10
    Run Keyword If    "${acc_term}" == "True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['google_terms_accept']}    30
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['next_button']}   10
    Run Keyword If    "${elmt}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_button']}    30
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['suw_summary_screen_title']}    20
    IF    "${set_google_account}" == "True"
        Return From Keyword
    ELSE
        APPIUM_TAP_XPATH    ${User_profile['finished_for_now_button']}    retries=20
    END

COMPLETE PROFILE SETUP CONTINUATION FOR MYF2
    [Documentation]    Continuing complete profile setup for MYF2
    [Arguments]    ${set_myr_account}=False    ${email_id}=None    ${password}=None    ${skip_myr_account}=False    ${set_google_account}=False    ${via_notification}=False
    IF    "${via_notification}" == "False"
        START INTENT    -n com.google.android.car.setupwizard/.CarSetupWizardTestActivity
    END
    Sleep    3s
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['suw_renault_logo']}    60
    ${get_language} =    APPIUM_GET_TEXT    ${User_profile['suw_language_summary']}
    Run Keyword If    '${get_language}'!='English'     Run Keywords
    ...      TAP_ON_ELEMENT_USING_ID    ${User_profile['change_language']}    15
    ...      AND    SCROLL_TO_ELEMENT     xpath=${User_profile['language_english']}    down    30
    ...      AND    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['language_english']}    30
    ...      AND    APPIUM_TAP_XPATH    ${User_profile['language_english_UK']}
    TAP_ON_ELEMENT_USING_ID    ${User_profile['welcome_begin']}    15
    Sleep    5s
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    //*[@text='OK']   10
    Run Keyword If    "${elmt}" == "True"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='OK']    30
    ${skip} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['skip_button']}    10
    Run Keyword If    "${skip}" == "True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['skip_button']}    15
    ${privacy_terms} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['suw_privacy_terms_screen']}    30
    IF    "${privacy_terms}" == "True"
        FOR  ${i}  IN RANGE    0    5
            #swipe_by_coordinates    550    1100    550    238
            SCROLL_TO_ELEMENT    xpath=${User_profile['privacy_confirm']}    down    5
            Sleep     5s
            @{share_services} =    APPIUM_GET_ELEMENTS_BY_XPATH    ${User_profile['accept_terms']}
            ${count} =    Get length     ${share_services}
            Exit For Loop If    ${count} == 1
        END
    END
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['accept_terms']}    30
    Run Keyword If    "${elmt}" == "True"    APPIUM_TAP_XPATH    ${User_profile['accept_terms']}    30
    Sleep    3s
    ${privacy_conf} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['privacy_confirm']}    30
    Run Keyword If    "${privacy_conf}" == "True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['privacy_confirm']}    30
    Sleep    10s
    Run Keyword If    ${skip_myr_account}==True    Run Keywords
    ...      TAP_ON_ELEMENT_USING_XPATH    ${User_profile['setup_skip_button']}    30
    ...      AND    TAP_ON_ELEMENT_USING_ID     ${User_profile['unsuccessful_next']}    30
    Run Keyword If    ${set_myr_account}==True    SIGN IN TO MYRENAULT ACCOUNT IN IVI    ${email_id}    ${password}
    ${pair} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['pairing_successful']}    10
    Run Keyword If    "${pair}" == "True"    APPIUM_TAP_ELEMENTID    ${User_profile['pairing_successful']}
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['suw_google_services_title']}    20
    ${acc_term} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['google_terms_accept']}    10
    Run Keyword If    "${acc_term}" == "True"    TAP_ON_ELEMENT_USING_ID    ${User_profile['google_terms_accept']}    30
    ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['next_button']}   10
    Run Keyword If    "${elmt}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_button']}    30
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['suw_summary_screen_title']}    20
    IF    "${set_google_account}" == "True"
        Return From Keyword
    ELSE
        APPIUM_TAP_XPATH    ${User_profile['finished_for_now_button']}    retries=20
    END

ACTIVATE SOUND THEME
    [Arguments]    ${theme}=Neutral
    [Documentation]    == High Level Description: ==
    ...    Activating Sound schemes on the HMI
    ...    == Parameters: ==
    ...    _scheme_: represents the schemes (Neutral, Pure , Smile and Expressive)
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    HMI    IVI CMD
    LAUNCH APP APPIUM    EvMenu
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['settings']}    40
    FOR    ${index}    IN RANGE    1    4
        ${text_retrieved} =    APPIUM_GET_TEXT   //*[@resource-id='com.renault.evservices:id/radio_group']/android.widget.RadioButton[${index}]    20
        Run Keyword If    "${theme}"=="${text_retrieved}"    Run Keywords    TAP_ON_ELEMENT_USING_XPATH   //*[@resource-id='com.renault.evservices:id/radio_group']/android.widget.RadioButton[${index}]    10
        ...     AND    Exit for loop
    END

VALIDATE THEME SELECTION
    [Arguments]    ${theme}=Neutral
    [Documentation]    == High Level Description: ==
    ...    Validating Sound schemes with IVC signals
    ...    == Parameters: ==
    ...    _scheme_: represents the schemes (Neutral, Pure , Smile and Expressive)
    ...    == Expected Results: ==
    ...    output: passed/failed
    LAUNCH APP APPIUM    EvMenu
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['settings']}    10
    FOR    ${index}    IN RANGE    1    4
        ${text_retrieved} =    APPIUM_GET_TEXT   //*[@resource-id='com.renault.evservices:id/radio_group']/android.widget.RadioButton[${index}]    20
        ${signal_value} =    Convert To String    ${index}
        Run Keyword If    "${theme}"=="${text_retrieved}"     CHECK SIGNAL VALUE    VSPsoundChoiceActivationRequest2    ${signal_value}
        Exit For Loop If    "${theme}"=="${text_retrieved}"
        Run Keyword If    "${index}" == "3"    Fail      Theme is not present
    END

ACTIVATE SEVEN CHOICESOUNDS
    [Documentation]    == High Level Description: ==
    ...     Activate 7 choice of pedestrian warning sounds
    DIAG SET CONFIG    hmi_config/drivingmode/vsp_choicesounds   7
    rfw_services.ivi.SystemLib.REBOOT
    WAIT BOARD BOOTED    1    60     ${ivi_adb_id}
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER
    Sleep   20s

VERIFY ADMIN USER NAME WITH MYR USER NAME
    [Arguments]    ${first_name}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to verify the first name in ivi userprofile page
    APPIUM LAUNCH USER MANAGEMENT
    ${name} =    APPIUM_GET_TEXT_BY_ID    ${User_profile['user_name_UM_menu']}    10
    Should Contain    ${name}    ${first_name}

CLEAR USER PROFILE SECURITY CREDENTIALS
    [Documentation]    == High Level Description: ==
    ...     This KW is used to unlock profile using pin options.
    APPIUM LAUNCH USER MANAGEMENT
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['edit_profile']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['profile_protection']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['clear_lock']}    10
    Sleep   5s
    Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['ok_button']}    30
    Sleep   2s

CHECK MYRENAULT CREDENTIALS INVALID
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a google account on IVI and check its failing.
    ADD MYR ACCOUNT FOR PROFILE IN IVI
    SIGN IN TO MYRENAULT ACCOUNT IN IVI    ${email_id}    ${password}
    ${wrong_credentials} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['wrong_credentials']}    10
    Should Be Equal    "${wrong_credentials}"    "True"

MANAGE ACCOUNT IN IVI
   [Documentation]    == High Level Description: ==
    ...     This KW is used to add a myrenault , google account on IVI
    APPIUM LAUNCH USER MANAGEMENT
    ${settings_icon} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['user_settings_button']}    20
    Run Keyword If    "${settings_icon}" == "False"    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    20
    TAP_ON_ELEMENT_USING_ID    ${User_profile['user_settings_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['manage_accounts']}    10

LOGIN GOOGLE ACCOUNT IN IVI
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a google account on IVI and check its failing.
    ...    == Parameters: ==
    ...    - email_id - : Username to login the google account
    ...    - password - : Username to login the google account
    ${sign_in_car} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_sign_in']}    10
    Run Keyword If    "${sign_in_car}" == "False"    LAUNCH APP APPIUM    GoogleSignin
    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_sign_in']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['google_sign_in']}    10
    Sleep   10
    APPIUM_WAIT_FOR_XPATH    ${User_profile['edit_google_mail']}    10
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['edit_google_mail']}    ${email_id}
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['gmap_next']}    10
    Sleep    2
    APPIUM_WAIT_FOR_XPATH    ${User_profile['edit_google_password']}    10
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['edit_google_password']}    ${password}
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['gmap_next']}    10
    Sleep    2

ADD GOOGLE ACCOUNT IN IVI
    [Arguments]    ${email_id}    ${password}   ${state}=success
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a google account on IVI and check its failing.
    ...    == Parameters: ==
    ...    - email_id - : Username to login the google account
    ...    - password - : Username to login the google account
    ...    - state - : To perform proper login (success), fail (to validate fails), wrongpassword(validate with wrong password)
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['select_google']}    10
    IF   "${state}"=="success"
        LOGIN GOOGLE ACCOUNT IN IVI    ${email_id}    ${password}
        APPIUM_WAIT_FOR_ELEMENT    ${User_profile['gmail_login_success']}    20
        TAP_ON_BUTTON    ${User_profile['gmail_login_success']}    10
        Sleep  5
    ELSE IF    "${state}"=="fail"
        ${not_signin_text} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['not_signed_in_text']}    10
        Run Keyword If    "${not_signin_text}" == "False"    Fail   Account is Added
        ${no_network} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['no_network']}    10
        Run Keyword If    "${no_network}" == "False"    Fail   Network is there
    ELSE IF    "${state}"=="wrongpassword"
        LOGIN GOOGLE ACCOUNT IN IVI    ${email_id}    ${password}
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${User_profile['wrong_pass_banner']}
        Run Keyword If      "${retrieved_text}" == "Wrong password. Try again or click ‘Forgot password’ to reset it."   Log    Password is Wrong
        ...    ELSE    Fail    Please provide wrong password or check error banner text.
        Sleep    0.2
    ELSE
        Log    Provide the proper option.
    END
    DO CLOSE APP    ivi    GoogleSignin

SELECT SECURITY LOCK TYPE OPTION
    [Documentation]    == High Level Description: ==
    ...     This KW is used to Click on Choose a lock type option
    APPIUM LAUNCH USER MANAGEMENT
    Sleep   3s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['edit_profile']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['profile_protection']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['choose_lock_type']}    10
    Sleep   5s

### Keywords moved from android_library.robot

CHECK IVI HMI NOTIFICATION
    [Arguments]    ${notification_name}    ${otp_code}=${None}
    [Documentation]    == High Level Description: ==
    ...    Check a notification appears on the IVI display. The notification content shall be checked.
    ...    == Parameters: ==
    ...    - _notification_name_: name of the notification corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Push Messages    IVI CMD
    ${appPackage} =    Set variable    com.renault.launcher
    ${activityName} =    Set variable    com.renault.launcher.NavigationActivity
    ${expected_text} =    Run Keyword If    "${otp_code}"=="${None}"
    ...    Set Variable     ${PM_profiles['${notification_name}']['Text'][0]}
    ...    ELSE    Set variable    ${otp_code}
    APPIUM_LAUNCH_APP    ${appPackage}    ${activityName}
    Sleep    5
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    expand
    Should Be True    ${verdict}
    Sleep    2
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${expected_text}']    15
    ${result1} =    RUN KEYWORD IF    '${result}'=='False'    APPIUM_WAIT_FOR_XPATH    ${push_message_notification}    15
    Sleep    2
    Should Be True    "${result}" == "True" or "${result1}" == "True"    Failed, push message notification not received
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Done']    10
    Run Keyword If    "${result}"=="True"    TAP BY XPATH    //*[@text='Done']
    Sleep    2
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}

GET_OTP_FROM_IVI
    [Documentation]    == High Level Description: ==
    ...    Gets the otp from the notification appears on the IVI display.
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    ${appPackage} =    Set variable    com.renault.launcher
    ${activityName} =    Set variable    com.renault.launcher.NavigationActivity
    APPIUM_LAUNCH_APP    ${appPackage}    ${activityName}
    Sleep    5s
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    expand
    Should Be True    ${verdict}
    Sleep    2s
    ${code_notification} =   APPIUM_GET_TEXT    //android.widget.TextView[contains(@text,'Code')]
    ${otp_code} =  Fetch From Right   ${code_notification}   ${SPACE}
    Log to console    Otpcode : ${otp_code}
    Set Test Variable   ${otp_code}

CHECKSET IVI PA
    [Arguments]    ${status}
    [Documentation]    Check PA status for IVI (if the status is wrong, VA_UC_02 to be executed)
    ...    == Parameters: ==
    ...    ${status}   notdone / done
    ...    == Expected Results: ==
    ...    output: pass if ivi status is PASTATE_SUCCESS, fail otherwise
    [Tags]    Automated    CHECKSET IVI PA    IVI CMD    VA
    Log To Console    Set IVI in root mode
    SET ROOT
    Sleep    1
    Log To Console    Check IVI PA status
    IF    "${ivi_my_feature_id}"=="MyF1"
        ${pa_check_status_verify} =    GET IVI PART AUTHENTICATION STATUS FOR MyF1    ${status}
    ELSE IF    "${ivi_my_feature_id}"=="MyF2"
        ${pa_check_status_verify} =    GET IVI PART AUTHENTICATION STATUS FOR MyF2    ${status}
    ELSE IF    "${ivi_my_feature_id}"=="MyF3"        
        ${pa_check_status_verify} =    GET IVI PART AUTHENTICATION STATUS FOR MyF3    ${status}
    ELSE
        LOG    IVI_My_feature_id: ${ivi_my_feature_id}
    END
    Sleep    5
    Run Keyword if    "${pa_check_status_verify}" != "True"    Run Keywords    Log    **** PA not Done ****    console=yes
    ...    AND    DO RESET IVI PART AUTHENTICATION STATUS    ${status}
    ...    AND    Log    CHECKSET IVI PA finished.
    Log    CHECKSET IVI PA finished.

GET IVI PART AUTHENTICATION STATUS FOR MyF1
    [Arguments]    ${status}
    [Documentation]    Get part authentification status to either and compare with status
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pa_helper 6 get
    Should Be True    "PASTATE_SUCCESS" in """${output}""" or "PASTATE_UNINITIALIZED" in """${output}"""    part authentification status is empty or not correct
    ${pa_status_str} =    Set Variable If    "${status}"=="pa_done"    PASTATE_SUCCESS    PASTATE_UNINITIALIZED   
    ${pa_check_status_verify} =    Run Keyword And Return Status    Should Contain    ${output}    ${pa_status_str}
    [Return]    ${pa_check_status_verify}

GET IVI PART AUTHENTICATION STATUS FOR MyF2
    [Arguments]    ${status}
    [Documentation]    Get part authentification status to either and compare with status
    SET ROOT
    Sleep   10s
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pa_helper 6 get
    Log    ${output}
    Should Be True    "PASTATE_SUCCESS" in """${output}""" or "PASTATE_UNINITIALIZED" in """${output}"""    part authentification status is empty or not correct
    Sleep    5s
    ${pa_status_str} =    Set Variable If    "${status}"=="pa_done"    PASTATE_SUCCESS    PASTATE_UNINITIALIZED
    ${pa_check_status_verify} =    Run Keyword And Return Status    Should Contain    ${output}    ${pa_status_str}
    [Return]    ${pa_check_status_verify}

DO RESET IVI PART AUTHENTICATION STATUS
    [Arguments]    ${status}=pa_notdone
    [Documentation]    Reset part authentification status to either PASTATE_UNINITIALIZED or PASTATE_SUCCESS
    ...    for IVI depending upon the status value
    ...    == Parameters: ==
    ...    ${status}   pa_notdone / pa_done
    ...    == Expected Results: ==
    ...    output: pass if ivi is set as root, set to permissive mode and PA status is reset to
    ...    PASTATE_UNINITIALIZED if status=pa_notdone and PASTATE_SUCCESS if status=pa_done
    ...    fail otherwise
    [Tags]    Automated    Reset PA    IVI CMD    VA
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set IVI in root mode
    SET ROOT
    Sleep    1
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Set IVI PA status
    IF    "${ivi_my_feature_id}"=="MyF1"
        RESET IVI PART AUTHENTICATION STATUS FOR MyF1    ${status}
    ELSE IF    "${ivi_my_feature_id}"=="MyF2"
        RESET IVI PART AUTHENTICATION STATUS FOR MyF2    ${status}
    ELSE IF    "${ivi_my_feature_id}"=="MyF3"
        RESET IVI PART AUTHENTICATION STATUS FOR MyF3    ${status}
    ELSE
        LOG    IVI_My_feature_id: ${ivi_my_feature_id}
    END

RESET IVI PART AUTHENTICATION STATUS FOR MyF1
    [Arguments]    ${status}
    [Documentation]    Reset part authentification status to either PASTATE_UNINITIALIZED or PASTATE_SUCCESS
    ...    for IVI depending upon the status value
    ...    == Parameters: ==
    ...    ${status}   pa_notdone / pa_done
    ...    == Expected Results: ==
    ...    output: pass if ivi is set as root, set to permissive mode and PA status is reset to
    ...    PASTATE_UNINITIALIZED if status=pa_notdone and PASTATE_SUCCESS if status=pa_done
    ...    fail otherwise
    [Tags]    Automated    Reset PA    IVI CMD    VA    MyF1
    ${pa_cmd} =    Set Variable If    "${status}"=="pa_done"    pa_helper 6 set 1    pa_helper 6 set 0
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell ${pa_cmd}
    ${pa_status_str} =    Set Variable If    "${status}"=="pa_done"    PASTATE_SUCCESS    PASTATE_UNINITIALIZED
    Should Contain    ${output}     ${pa_status_str}

RESET IVI PART AUTHENTICATION STATUS FOR MyF2
   [Arguments]    ${status}
    [Documentation]    Reset part authentification status to either PASTATE_UNINITIALIZED or PASTATE_SUCCESS
    ...    for IVI depending upon the status value
    ...    == Parameters: ==
    ...    ${status}   pa_notdone / pa_done
    ...    == Expected Results: ==
    ...    output: pass if ivi is set as root, set to permissive mode and PA status is reset to
    ...    PASTATE_UNINITIALIZED if status=pa_notdone and PASTATE_SUCCESS if status=pa_done
    ...    fail otherwise
    [Tags]    Automated    Reset PA    IVI CMD    VA    MyF2
   OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb setBootMode STATIC1
   Sleep    2s
   ${response} =    DIAG EMULATOR HARDRESET
   ${response} =    GET FROM LIST    ${response}    0
   SHOULD CONTAIN    ${response}    Success
   Sleep    60s
   SET ROOT
   Sleep   10s
   ${pa_cmd} =    Set Variable If    "${status}"=="pa_done"    pa_helper 6 set 1    pa_helper 6 set 0
   ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell ${pa_cmd}
   Sleep    5s
   OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb setBootMode NORMAL
   Sleep    10s
   ${response} =    DIAG EMULATOR HARDRESET
   ${response} =    GET FROM LIST    ${response}    0
   SHOULD CONTAIN    ${response}    Success
   ${pa_status_str} =    Set Variable If    "${status}"=="pa_done"    PASTATE_SUCCESS    PASTATE_UNINITIALIZED
   Should Contain    ${output}     ${pa_status_str}

RESET IVI PART AUTHENTICATION STATUS FOR MyF3
    [Arguments]    ${status}
    [Documentation]    Reset part authentification status to either PASTATE_UNINITIALIZED or PASTATE_SUCCESS
    ...    for IVI depending upon the status value
    ...    == Parameters: ==
    ...    ${status}   pa_notdone / pa_done
    ...    == Expected Results: ==
    ...    output: pass if ivi is set as root, set to permissive mode and PA status is reset to
    ...    PASTATE_UNINITIALIZED if status=pa_notdone and PASTATE_SUCCESS if status=pa_done
    ...    fail otherwise
    [Tags]    Automated    Reset PA    IVI CMD    VA    MyF3
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb setBootMode STATIC1
    Sleep    2s
    ${response} =    DIAG EMULATOR HARDRESET
    Sleep    60s
    SET ROOT
    Sleep   10s
    ${pa_cmd} =    Set Variable If    "${status}"=="pa_done"    pa_helper 6 set 1    pa_helper 6 set 0
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell ${pa_cmd}
    Sleep    5s
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb setBootMode NORMAL
    Sleep    10s
    ${response} =    DIAG EMULATOR HARDRESET
    ${pa_reset_status} =    Set Variable If    "${status}"=="pa_done"    PASTATE_SUCCESS    PASTATE_UNINITIALIZED
    Should Be True    "${pa_reset_status}" in """${output}"""    WRONG PA STATUS => ${\n}${output}

CHECKSET FLAG STATE FOR
    [Arguments]    ${parameter}    ${value}
    [Documentation]    Set on the IVI platform ${parameter} with value ${value}
    ...    == Parameters: ==
    ...    - _parameter_: Name of the parameter, could be:
    ...    charge_scheduler_activation, presoak_scheduler_activation, responce_bcm_ev_timeout, ev_smartcharging_activation_status
    ...    - _value_: Depending on the parameter, could be ON/OFF or a numeric value
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Set Flag    IVI CMD

    IF    '${sweet400_bench_type}' in "'${bench_type}'"
        CHECKSET FLAG STATE FOR SW400    ${parameter}    ${value}
    ELSE
        CHECKSET FLAG STATE FOR SW200    ${parameter}    ${value}
    END

CHECKSET FLAG STATE FOR SW200
    [Arguments]    ${parameter}    ${value}
    ${value} =    Convert To Upper Case    ${value}
    ${output} =    DIAG READ CONFIG    EV/${parameter}/status
    ${contains} =    Evaluate    "${value}" in """${output}"""
    Return From Keyword If    "${contains}" == "True"
    DIAG SET CONFIG    EV/${parameter}/status    \"\'${value}\'\"
    rfw_services.ivi.SystemLib.REBOOT
    Sleep    30
    ${output} =    DIAG READ CONFIG    EV/${parameter}/status
    ${contains} =    Evaluate    "${value}" in """${output}"""
    Should Be True    ${contains}    Failed to set config parameter: EV/${parameter}/status

CHECKSET FLAG STATE FOR SW400
    [Arguments]    ${parameter}    ${value}
    ${value} =    Convert To Upper Case    ${value}
    Should Contain    "${parameter}"    "charge_scheduler_activation" or "presoak_scheduler_activation"    FAIL: Not implemented for others parameters
    ${parameter} =    Set Variable If
    ...  "${parameter}" == "charge_scheduler_activation"    Charge_Scheduler_Activation
    ...  "${parameter}" == "presoak_scheduler_activation"    Presoak_Scheduler_Activation
    ${output} =    DIAG GET DESCMO CONFIG    EV.${parameter}@Status
    ${output} =    Get Substring    ${output}    70
    ${contains} =    Evaluate    "${value}" in '${output}'
    Return From Keyword If    "${contains}" == "True"
    DIAG SET DESCMO CONFIG    EV.${parameter}@Status    \"${value}\"
    rfw_services.ivi.SystemLib.REBOOT
    Sleep    30
    ${output} =    DIAG GET DESCMO CONFIG    EV.${parameter}@Status
    ${output} =    Get Substring    ${output}    70
    ${contains} =    Evaluate    "${value}" in '${output}'
    Should Be True    ${contains}    Failed to set config parameter: EV.${parameter}@Status

APPIUM_LAUNCH_APP
    [Arguments]    ${appPackage}    ${activityName}
    Import Library    rfw_services.ivi.AppiumLib    platformName=${platform_name}
    ...    platformVersion=${platform_version}    deviceName=${ivi_adb_id}    appPackage=${appPackage}
    ...    appActivity=${activityName}    autoGrantPermissions=true    automationName=${automation_name}   udid=${ivi_adb_id}
    ${desired_capabilities} =    Create dictionary    platformName=${platform_name}    platformVersion=${platform_version}
    ...    deviceName=${ivi_adb_id}    appPackage=${appPackage}    appActivity=${activityName}    autoGrantPermissions=true
    ...    automationName=${automation_name}   udid=${ivi_adb_id}    systemPort=8210
    ${ivi_driver} =    rfw_services.ivi.AppiumLib.driver_creation    ${desired_capabilities}
    Set Test Variable   ${ivi_driver}

SET TIMEZONE IN SUW
    [Arguments]    ${timezone}
    [Documentation]    == High Level Description: ==
    ...    Set timezone in the set up wizard
    ...    == Parameters: ==
    ...    - timezone: name of the timezone
    ...    == Expected Results: ==
    ...    output: passed/failed
    TAP_ON_ELEMENT_USING_XPATH    ${DateTime['select_country']}    30
    Sleep    5
    SCROLL_TO_ELEMENT     xpath=//*[@text='${timezone}']//ancestor::android.widget.RelativeLayout    down
    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${timezone}']//ancestor::android.widget.RelativeLayout    15

SELECT USER PROFILE
    [Arguments]    ${ivi_user_profile_name}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    == High Level Description: ==
    ...    Select a user profile from Notification manager
    ...    == Parameters: ==
    ...    - ivi_user_profile_name: profile name of the user
    ...    == Expected Results: ==
    ...    output: Given user profile should be selected
    APPIUM LAUNCH USER MANAGEMENT
    Sleep    20
    IF    '${ivi_my_feature_id}' == 'MyF1' or '${ivi_my_feature_id}' == 'MyF2'
        ${admin_profile} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['admin_str']}    20
        Sleep    5
        ${guest} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'Guest')]    60
        Run Keyword If    "${admin_profile}" == "False" and "${guest}" == "False"    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    20
    END
    run keyword and ignore error    RECONFIRM DATA PRIVACY
    TAP_ON_ELEMENT_USING_XPATH    //*[contains(@text,'${ivi_user_profile_name}')]//preceding-sibling::android.widget.ImageView    30    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    REMOVE APPIUM DRIVER

QUIT SESSION
    [Documentation]    == High Level Description: ==
    ...    To close appium session
    driver_teardown

APPIUM LAUNCH USER MANAGEMENT
    [Documentation]    == High Level Description: ==
    ...    Start user management application
    LAUNCH APP APPIUM    UserManagement
    Sleep   3s

APPIUM LAUNCH NAVIGATION
    [Documentation]    == High Level Description: ==
    ...    Start IVI home screen
    LAUNCH APP APPIUM    Navigation

ADD NEW USER PROFILE
    [Arguments]    ${platform_version}=10
    [Documentation]    == High Level Description: ==
    ...    Add a new user profile
    ...    == Expected Results: ==
    ...    output: passed/failed
    APPIUM LAUNCH USER MANAGEMENT
    IF    '${ivi_my_feature_id}' == 'MyF1' or '${ivi_my_feature_id}' == 'MyF2'
        ${admin_profile} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['admin_str']}    20
        Run Keyword If    "${admin_profile}" == "False"    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    20
        TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_user']}    10
        Sleep    20s
        APPIUM_TAP_ELEMENTID    ${User_profile['confirm_add_user']}
    ELSE IF    '${ivi_my_feature_id}' == 'MyF3'
        APPIUM_TAP_XPATH    ${User_profile['add_user']}
        Sleep    2s
        TAP_ON_ELEMENT_USING_ID    ${User_profile['confirm_add_user_myf3']}    10
    ELSE
        Log    IVI My Feature Id is wrong! ${ivi_my_feature_id}
    END
    Sleep    60s
    REMOVE APPIUM DRIVER
    Sleep    5s
    CREATE APPIUM DRIVER
    Sleep    60s

REMOVE USER PROFILE
    [Arguments]    ${ivi_user_profile_name}=New
    [Documentation]    == High Level Description: ==
    ...    Remove 'new profile' profile
    ...    == Parameters: ==
    ...    - ivi_user_profile_name: profile name of the user
    ...    == Expected Results: ==
    ...    The "new profile" in the profiles tab to be deleted
    MANAGE PROFILE IN IVI
    APPIUM_TAP_XPATH    //android.widget.TextView[contains(@text,'${ivi_user_profile_name}')]    20
    IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"
        APPIUM_TAP_XPATH    ${User_profile['confirm_delete_myf3']}    20
        APPIUM_TAP_XPATH    ${User_profile['confirm_delete']}    20
    ELSE
        APPIUM_TAP_XPATH    ${User_profile['confirm_delete']}    20
        APPIUM_TAP_XPATH    ${User_profile['confirm_delete']}    20
    END
    IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"
        Sleep    2
        APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
        Sleep    2
        APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    END

LOCK CURRENT PROFILE
    [Arguments]    ${lock_type}    ${code}=None
    [Documentation]    == High Level Description: ==
    ...    Set up a lock for current profile
    ...    == Parameters: ==
    ...    - lock_type: The lock type (Could be pin/password/pattern)
    ...    - code: The code which will be assigned to the user
    ...    == Expected Results: ==
    ...    output: One lock type should be succesufully assigned
    Run Keyword If    "${lock_type}".lower()=="pin"
    ...    SETUP_PINCODE_FOR_USER    ${code}
    ...    ELSE IF    "${lock_type}".lower()=="password"
    ...    SETUP_PASSWORD_FOR_USER    ${code}
    ...    ELSE IF    "${lock_type}".lower()=="pattern"
    ...    SETUP_PATTERN_FOR_USER    ${code}
    ...    ELSE    Fail    ${lock_type} doesn't exist

SETUP_PINCODE_FOR_USER
    [Arguments]    ${ivi_user_pin_code}    ${start_app}=True
    [Documentation]    == High Level Description: ==
    ...    Set up a pin code for a new user in setup wizard
    ...    == Parameters: ==
    ...    - ivi_user_pin_code: A 4 digit pin code which needs to be assigned to the user(ex: 1234)
    ...    == Expected Results: ==
    ...    output: Pin code assignment to the user should be success
    Run Keyword If    "${start_app}"=="True"    START INTENT    com.android.car.settings/com.android.car.settings.security.SettingsScreenLockActivity
    sleep   15
    Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['pin_button']}    30
    sleep    2
    ENTER PINCODE KEYS    ${ivi_user_pincode}    True
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['continue_button']}    50
    ENTER PINCODE KEYS    ${ivi_user_pincode}    True
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_button']}    50

REMOVE_PINCODE_FOR_USER
    [Arguments]    ${ivi_user_pin_code}
    [Documentation]    == High Level Description: ==
    ...    Remove pin code for a new user in setup wizard
    ...    == Parameters: ==
    ...    - ivi_user_pin_code: The 4 digit pin code which needs to be assigned to the user(ex: 1234)
    ...    == Expected Results: ==
    ...    output: Pin code should be removed.
    sleep    4
    START INTENT    -n com.android.car.settings/com.android.car.settings.security.SettingsScreenLockActivity
    sleep    2
    UNLOCK PROFILE USING PINCODE    ${ivi_user_pin_code}    True
    Sleep    4s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['none_pin_button']}    40
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_pin_button']}    40

SETUP_PASSWORD_FOR_USER
    [Arguments]    ${ivi_user_password}    ${start_app}=True
    [Documentation]    == High Level Description: ==
    ...    Set up a password for a new user in setup wizard
    ...    == Parameters: ==
    ...    - ivi_user_password: Password which needs to be assigned to the user
    ...    == Expected Results: ==
    ...    output: password assignment to the user should be success
    Run Keyword If    "${start_app}"=="True"    START INTENT    -n com.android.car.settings/com.android.car.settings.security.SettingsScreenLockActivity
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['password_button']}    30
    UNLOCK PROFILE USING PASSWORD     ${ivi_user_password}    True
    Sleep   2s
    UNLOCK PROFILE USING PASSWORD     ${ivi_user_password}    True
    Sleep    5s

REMOVE_PASSWORD_FOR_USER
    [Arguments]    ${ivi_user_password}
    [Documentation]    == High Level Description: ==
    ...    Remove password code user
    ...    == Parameters: ==
    ...    - ivi_user_password: The password which needs to be deleted to the user(ex: 36987a)
    ...    == Expected Results: ==
    ...    output: Password code should be removed.
    START INTENT    -n com.android.car.settings/com.android.car.settings.security.SettingsScreenLockActivity
    Sleep    2s
    UNLOCK PROFILE USING PASSWORD     ${ivi_user_password}    True
    Sleep    2s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['none_pin_button']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_pin_button']}    20

SETUP_PATTERN_FOR_USER
    [Arguments]    ${ivi_user_pattern}    ${start_app}=True
    [Documentation]    == High Level Description: ==
    ...    Set up a pattern for a new user in setup wizard
    ...    == Parameters: ==
    ...    - ivi_user_pattern: pattern which needs to be assigned to the user
    ...    == Expected Results: ==
    ...    output: pattern assignment to the user should be success
    Run Keyword If    "${start_app}"=="True"    START INTENT    -n com.android.car.settings/com.android.car.settings.security.SettingsScreenLockActivity
    Sleep    5s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['pattern_button']}    30
    Sleep    2s
    UNLOCK PROFILE USING PATTERN     ${ivi_user_pattern}     True     54
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['continue_button']}    30
    Sleep    2s
    UNLOCK PROFILE USING PATTERN     ${ivi_user_pattern}     True     54
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_button']}    30
    Sleep    5s

REMOVE_PATTERN_FOR_USER
    [Arguments]    ${ivi_user_pattern}
    [Documentation]    == High Level Description: ==
    ...    Remove pattern code user
    ...    == Parameters: ==
    ...    - ivi_user_pattern: The pattern code which needs to be deleted to the user(ex: 36987)
    ...    == Expected Results: ==
    ...    output: Pattern code should be removed.
    START INTENT    -n com.android.car.settings/com.android.car.settings.security.SettingsScreenLockActivity
    Sleep    3s
    UNLOCK PROFILE USING PATTERN     ${ivi_user_pattern}     True     54
    Sleep    2s
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['none_pin_button']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_pin_button']}    20

APPIUM_FACTORY_RESET
    [Documentation]    == High Level Description: ==
    ...    Factory Reset (available only for Admin)
    ...    == Expected Results: ==
    ...    output: Profile is reset and lands at SUW
    START INTENT    -a android.settings.SETTINGS
    Sleep    5s
    ${verdict} =   APPIUM_WAIT_FOR_XPATH    ${car_settings['system_button']}    direction=down    scroll_tries=12
    Run Keyword If    "${verdict}"=="True"    APPIUM_TAP_XPATH    ${car_settings['system_button']}    20
    APPIUM_TAP_XPATH    ${car_settings['reset_option']}    20
    ${retrieved_text} =    Run Keyword and Ignore Error    APPIUM_GET_TEXT_USING_XPATH
    ...    ${car_settings['factory_reset']}
    ${app_reset} =    Run Keyword and Ignore Error    APPIUM_GET_TEXT_USING_XPATH
    ...    ${car_settings['app_reset']}
    Run Keyword And Return If    "${current_user}" != "${admin_user}" and "FAIL" in """${retrieved_text}"""
    ...    Should Be Equal   "${app_reset}"    "('PASS', 'Reset app preferences')"
    APPIUM_TAP_XPATH    ${car_settings['factory_reset']}    20
    APPIUM_TAP_XPATH    ${car_settings['reset_option']}    20
    APPIUM_TAP_XPATH    ${car_settings['reset_option']}    20

SET_UP_LANGUAGE_IN_SUW
    [Arguments]    ${language_name}
    [Documentation]    == High Level Description: ==
    ...    Set language in the set up wizard
    ...    == Parameters: ==
    ...    - language_name: name of the language
    ...    == Expected Results: ==
    ...    output: passed/failed
    START INTENT    -n com.renault.setupwizardoverlay/com.renault.setupwizardoverlay.welcome.WelcomeActivity
    Sleep    3s
    TAP_ON_ELEMENT_USING_ID    ${User_profile['change_language']}    15
    SCROLL_TO_ELEMENT     xpath=//android.widget.TextView[contains(@text,'${language_name}')]    down    30
    TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[contains(@text,'${language_name}')]    30

CHECK FOR UPDATE
    [Arguments]    ${service_request}
    APPIUM_LAUNCH_APP    ${car_settings['appPackage_vehicle_settings']}    ${car_settings['activityName_vehicle_settings']}
    Sleep    2
    APPIUM_TAP_XPATH    ${car_settings['update_menu']}
    Sleep    2
    APPIUM_TAP_XPATH    ${car_settings['check_for_update_button']}
    Sleep    1
    ${text_retrieved} =    APPIUM_GET_TEXT    ${car_settings['no_campaign']}
    Sleep    2
    Return From Keyword If    "${service_request}" == "Inventory"
    Run Keyword If    "${text_retrieved}".lower() != "checking for update"    Fail    Checking for updates not started
    Sleep    60s
    ${text_retrieved} =    Run Keyword If    "${service_request}" == "DeactivationInProgress" or "${service_request}" == "ActivationInProgress"     APPIUM_GET_TEXT    ${car_settings['no_campaign']}
    ...    ELSE    APPIUM_GET_TEXT    ${car_settings['campaign_ongoing']}
    Run Keyword If    "${service_request}" == "DeactivationInProgress"    Should Be Equal    "${text_retrieved}"    "No update available for your vehicle."    Fail to get desired text
    Run Keyword If    "${service_request}" == "DeactivationInProgress"    TAP_ON_BUTTON    ${car_settings['back_check_for_update_button']}    20
    Run Keyword If    "${service_request}" == "ActivationInProgress"    Should Be Equal    "${text_retrieved}"    "No update available for your vehicle."    Fail to get desired text
    Run Keyword If    "${service_request}" == "ActivationInProgress"    TAP_ON_BUTTON    ${car_settings['back_check_for_update_button']}    20
    Run Keyword If    "${service_request}" == "campaign_completed"    Should Be Equal    "${text_retrieved}"    "No update available for your vehicle"    Fail to get desired text
    Run Keyword If    "${service_request}" == "campaign_completed"    TAP_ON_BUTTON    ${car_settings['back_check_for_update_button']}    20

EDIT PROFILE NAME
    [Arguments]    ${ivi_user_profile_name}
    [Documentation]    == High Level Description: ==
    ...    Edit Profile
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${big_screen} =    Set Variable    Physical size: 1250x1562
    ${small_screen} =    Set Variable    Physical size: 1250x834
    ${common_screen} =    Set Variable    Physical size: 1280x720
    ENABLE MULTI WINDOWS
    ${screen_resolution} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell wm size
    ${width} =    Set Variable    1150
    IF    "${ivi_my_feature_id}" == "MyF3"
        ${height} =    Set Variable If    "${screen_resolution}" == "${big_screen}"    1480    700
    ELSE
        ${height} =    Set Variable If    "${screen_resolution}" == "${big_screen}"    1400    700
    END
    ${keyboard_done_element} =    Create Dictionary    x=${width}   y=${height}
    APPIUM LAUNCH USER MANAGEMENT
    run keyword and ignore error    RECONFIRM DATA PRIVACY
    ${ed_btn} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Edit profile']    20
    Run Keyword If    "${ed_btn}" == "True"    APPIUM_TAP_XPATH    //*[@text='Edit profile']
    APPIUM_TAP_XPATH    ${User_profile['user_name_text']}
    IF    "${ivi_my_feature_id}" == "MyF3"
        APPIUM_TAP_ELEMENTID    ${User_profile['user_name_input_box_myf3']}
        APPIUM_ENTER_TEXT    ${User_profile['user_name_input_box_myf3']}    ${ivi_user_profile_name}
    ELSE
        APPIUM_TAP_ELEMENTID    ${User_profile['user_name_input_box']}
        APPIUM_ENTER_TEXT    ${User_profile['user_name_input_box']}    ${ivi_user_profile_name}
    END
    IF    "${screen_resolution}" == "${small_screen}" or "${screen_resolution}" == "${big_screen}" or "${screen_resolution}" == "${common_screen}"
        #UNTIL MATRIX-38119
        Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${screen_resolution}" == "${big_screen}"  OperatingSystem.Run    adb -s ${ivi_adb_id} shell input tap 1240 1550
        ...    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "${screen_resolution}" == "${small_screen}"  OperatingSystem.Run    adb -s ${ivi_adb_id} shell input tap 1200 800
        ...    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "${screen_resolution}" == "${common_screen}"  OperatingSystem.Run    adb -s ${ivi_adb_id} shell input tap 1200 700
        ...    ELSE    APPIUM_TAP_LOCATION    ${keyboard_done_element}
    ELSE
        ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${img_name}    ${CURDIR}
        Should be true    ${verdict}    Failed to download '${download_url_image}${img_name}' from artifactory
        TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}
    END
    ${text_retrieved} =    APPIUM_GET_TEXT_USING_XPATH    ${User_profile['user_name_UM_menu']}
    Should Contain    ${text_retrieved}    ${ivi_user_profile_name}
    IF    "${screen_resolution}" == "${small_screen}"
        IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_full"
            ${back_button} =    Create Dictionary    x=53   y=190
        ELSE
            ${back_button} =    Create Dictionary    x=13   y=150
        END
        APPIUM_TAP_LOCATION    ${back_button}
    ELSE IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"
        APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    END
    Sleep    5s
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER

EDIT PROFILE PICTURE
    [Documentation]    == High Level Description: ==
    ...    Edit Profiler
    ...    == Expected Results: ==
    ...    output: passed/failed
    APPIUM LAUNCH USER MANAGEMENT
    APPIUM_TAP_XPATH    //*[@text='Picture']
    ${picture}=     Generate random string    1    123456789
    APPIUM_TAP_XPATH   (//android.widget.ImageView[@content-desc="User profile picture" or @content-desc="Profile picture"])[${picture}]    15

COMPARE IVI DATE
    [Arguments]    ${day}    ${month}    ${year}
    [Documentation]    == High Level Description: ==
    ...    Fetches current IVI date and compares it with user input(day, month and year)
    ...    == Parameters: ==
    ...    - _day_:  day of month to be compared
    ...    - _month_:  month to be compared
    ...    - _year_:  year to be compared
    ...    == Expected Results: ==
    ...    Pass if executed
    [Tags]    Automated    Compare IVI Date    IVI CMD
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell date
    Should Contain    ${output}    ${month}    FAILED.. Month is incorrect
    Should Contain    ${output}    ${year}    FAILED.. Year is incorrect
    Should Contain    ${output}    ${day}    FAILED.. Day is incorrect

APPIUM_GET_ELEMENTS_BY_ID
    [Arguments]    ${resource_id}
    [Documentation]    == High Level Description: ==
    ...    Returns the elements that corresponds to a certain resource id
    ...    == Parameters: ==
    ...    - _resource_id_: represents the resource_id of the element
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${elements} =    get_elements_by_id    ${resource_id}
    [Return]    ${elements}

CONFIGURE IP TUNNELING
    [Arguments]    ${dut_id}
    [Documentation]    Configure the ip tunneling between IVI & IVC
    # To be enabled after https://jira.dt.renault.com/browse/CCAR-66418
#    RILSHELL IVC COMMAND CHECK DUAL APN
    IF    '${sweet400_bench_type}' not in '${tc_config}[bench_type]'  #check DNS was removed on sweet400
        ${verdict} =    CHECK DUAL DNS    ${dut_id}
        Should Be True    ${verdict}    Dual DNS is not configured
    END
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@content-desc='Open drawer' or @content-desc='AllianceKitchenSink']
    Sleep    3s
    ${is_present} =   APPIUM_WAIT_FOR_XPATH    //*[@text='CONNECTIVITY_MANAGER']    10
    Run Keyword If    "${is_present}" == "False"    SCROLL TO EXACT ELEMENT    //*[@text='CONNECTIVITY_MANAGER']    direction=down
    APPIUM_TAP_XPATH    //*[@text='CONNECTIVITY_MANAGER']

    APPIUM_TAP_XPATH    //*[@text='001-Query available networks']
    Sleep    3s

    SCROLL TO EXACT ELEMENT    //*[@text='016-Cancel network request']    direction=down
    APPIUM_TAP_XPATH    //*[@text='016-Cancel network request']

    APPIUM_TAP_XPATH    //*[@text='016-Cancel network request']

    Sleep    3
    SCROLL TO EXACT ELEMENT    //*[@text='Check network Address']    direction=down
    APPIUM_TAP_XPATH    //*[@text='Check network Address']

    APPIUM_TAP_XPATH    //*[@text='INTERNET']

    APPIUM_TAP_XPATH    //*[@text='Test']
    Sleep    3s

    ${internet_capability} =    APPIUM_GET_TEXT_BY_ID    ${kitchensink['get_text']}
    Should Not Contain    ${internet_capability}    Fail    internet capability test failed
    Log To Console    ${internet_capability}
    Sleep    3s

    APPIUM_TAP_XPATH    //*[@text='OEM_PAID with SIT' or @text='OEM_PAID WITH SIT']

    APPIUM_TAP_XPATH    //*[@text='REQUEST TEST']
    Sleep    25s

    ${oem_capability} =    APPIUM_GET_TEXT_BY_ID    ${kitchensink['get_text']}
    Should Not Contain    ${oem_capability}    Fail    oem capability test failed
    Log To Console    ${oem_capability}

FIND_APPLICATION_IN_GOOGLESTORE
    [Arguments]    ${appPackage}    ${activityName}    ${app_name}
    [Documentation]    == High Level Description: ==
    ...    Finds the application in IVI from PlayStore
    ...    == Parameters: ==
    ...    - app_name: represents the application name from Playstore
    ...    == Expected Results: ==
    ...    output: passed/failed
    APPIUM_LAUNCH_APP    ${appPackage}    ${activityName}
    Sleep  20
    APPIUM_WAIT_FOR_XPATH    ${PlayStore['search_bar']}    15
    TAP_ON_ELEMENT_USING_XPATH    ${PlayStore['search_bar']}   20
    Sleep  15
    APPIUM_ENTER_TEXT_XPATH   ${PlayStore['search_inbox']}   ${app_name}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}

INSTALL_SPOTIFY_APPLICATION
    [Arguments]    ${response}=True
    [Documentation]    == High Level Description: ==
    ...    Install App from a playstore in HMI
    ...    == Parameters: ==
    ...    _response_: this parameter is to validate the installation for both success and fail scenarios
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['spotify_app']}   10
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${PlayStore['install_button']}    retries=10
    Run Keyword And Return If    "${result}"=="False" and "${response}"=="False"    Log To Console    Install button not present
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['install_button']}  10
    log to console   Waiting for the installation to complete
    ${uninstall_button} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['uninstall_button']}    1
    WHILE    "${uninstall_button}" == "False"
        ${uninstall_button} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['uninstall_button']}    120
        Run Keyword If    "${uninstall_button}" == "False"    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['install_button']}    10
        ${uninstall_button} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['uninstall_button']}    120
    END

LOGIN_SPOTIFY_AND_PLAYMUSIC
    [Arguments]    ${spotify_username}   ${spotify_password}
    [Documentation]    == High Level Description: ==
    ...    Installs the application in IVI from PlayStore
    ...    == Parameters: ==
    ...    -spotify_username: represents the username for Spotify application login
    ...    -spotify_password: represents the password for Spotify application login
    FIND_APPLICATION_IN_GOOGLESTORE    ${appPackage}    ${activityName}    Spotify
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['spotify_app']}   10
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['open_app']}  10
    TAP_ON_ELEMENT_USING_ID   ${Spotify['error_button']}    10
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${Spotify['login']}    10
    Run Keyword If  ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_ID   ${Spotify['login']}    10
    APPIUM_ENTER_TEXT    ${Spotify['enter_username']}   ${spotify_username}
    TAP_ON_ELEMENT_USING_ID   ${Spotify['login_password']}    10
    APPIUM_ENTER_TEXT    ${Spotify['login_password']}   ${spotify_password}
    TAP_ON_ELEMENT_USING_ID   ${Spotify['do_login']}   10
    Sleep    10s
    ${elmt} =    APPIUM_WAIT_FOR_ELEMENT    ${Spotify['autofill']}    10
    Run Keyword If  ${elmt} is ${TRUE}    TAP_ON_ELEMENT_USING_ID   ${Spotify['autofill']}  5
    TAP_ON_ELEMENT_USING_XPATH    ${Spotify['search']}   120
    APPIUM_ENTER_TEXT   ${Spotify['searchbar']}   ViralHits
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    TAP_ON_ELEMENT_USING_XPATH   ${Spotify['first_search']}    20
    ${ele_present} =    WAIT ELEMENT BY XPATH    ${Spotify['first_search']}    retries=10
    Run Keyword If    "${ele_present}"=="True"    TAP_ON_ELEMENT_USING_XPATH   ${Spotify['first_search']}    20
    sleep   20s
    TAP_ON_ELEMENT_USING_ID   ${Spotify['play_pause']}  10
    TAP_ON_ELEMENT_USING_XPATH    ${Spotify['settings']}   10
    TAP_ON_ELEMENT_USING_XPATH    ${Spotify['logout']}   10
    TAP_ON_ELEMENT_USING_ID    ${Spotify['logout_positive']}   10

UNINSTALL_SPOTIFY_APPLICATION
    [Arguments]    ${response}=True
    [Documentation]    == High Level Description: ==
    ...    Uninstall App from a playstore in HMI
    ...    == Parameters: ==
    ...    _response_: this parameter is to validate the uninstallation for both success and fail scenarios
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['spotify_app']}   10
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['uninstall_button']}  10
    ${pop_up_uninstall} =    WAIT ELEMENT BY XPATH    ${PlayStore['uninstall_button']}  10
    Run Keyword If    "${pop_up_uninstall}"=="True"    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['uninstall_button']}  10    20
    ${presence} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['install_button']}    120
    Run Keyword If    "${response}" == "${False}"    Run Keywords    Should Not Be True    ${presence}
    ...    AND    Return from keyword
    Run Keyword If    "${response}"== "${True}"    TAP_ON_ELEMENT_USING_ID    android:id/button1   10
    sleep   5s

VERIFY_ECODRIVING_SCORE
    [Documentation]    == High Level Description: ==
    ...    Verifies the eco driving score in IVI
    START INTENT    com.renault.drivingeco/com.renault.drivingeco.page.activities.main.MainActivity
    TAP_ON_ELEMENT_USING_XPATH    //android.widget.LinearLayout/android.widget.FrameLayout/android.view.ViewGroup/android.widget.LinearLayout/android.view.ViewGroup[2]    5
    ${eco_driving_score} =    APPIUM_GET_TEXT    com.renault.drivingeco:id/drivingEcoScoreValue
    Log to Console  ECO_DRIVING_SCORE : ${eco_driving_score}
     Should Not Be Equal    ${eco_driving_score}    --

CHECK_VEHICLE_TRIP_PARAMETERS
    [Arguments]    ${a_trip_distance_km}   ${a_average_speed}    ${expected_status}=True
    [Documentation]    == High Level Description: ==
    ...    Checks for the vehicle trip distance,average speed and consumption
    START INTENT    com.renault.drivingeco/com.renault.drivingeco.page.activities.main.MainActivity
    ${trip_distance_km} =    APPIUM_GET_TEXT_USING_XPATH    (//*[@resource-id='com.renault.drivingeco:id/tripInfoCellValue'])[1]
    Log to console    TRIP_DISTANCE : ${trip_distance_km}km
    ${average_speed} =    APPIUM_GET_TEXT_USING_XPATH    (//*[@resource-id='com.renault.drivingeco:id/tripInfoCellValue'])[2]
    Log to console    AVERAGE_SPEED : ${average_speed}km/h
    Run Keyword If    ${expected_status}==True    Should Be Equal    ${trip_distance_km}    ${a_trip_distance_km}.0
    ...    Should Be Equal    ${average_speed}    ${a_average_speed}.0
    ...    ELSE IF    ${expected_status}==False    Should Not Be Equal    ${trip_distance_km}    ${a_trip_distance_km}.0
    ...    Should Not Be Equal    ${average_speed}    ${a_average_speed}.0

CHECKSET IVI DATA COLLECTION DESCMO SERVICE ACTIVATION STATUS
    [Arguments]    ${status}
    [Documentation]    To check the status of Data Collection service activation status and set it to ON if its not ON.
    ...    == Parameters: ==
    ...    ${status}   on / off
    ...    == Expected Results: ==
    ...    output: pass if service status is on, fail otherwise
    [Tags]    Automated    CHECKSET IVI DATA COLLECTION DESCMO SERVICE ACTIVATION STATUS    IVI CMD    DESCMO
    ${status} =    Convert To Upper Case    ${status}
    ${output} =    DIAG GET DESCMO CONFIG    DC.DataCollection_technical_activation@Status
    Return From Keyword If    "${status}" in '''${output}'''
    DIAG SET DESCMO CONFIG    DC.DataCollection_technical_activation@Status    ON
    ${output} =    DIAG GET DESCMO CONFIG    DC.DataCollection_technical_activation@Status
    ${verdict} =    Evaluate    "${status}" in """${output}"""
    Should Be True    ${verdict}    Failed Descmo status is different

SET IVI LOCATION STATUS
    [Arguments]    ${state}
    [Documentation]    Set location ON/OFF on IVI
    IF    "DOM" in "${ivi_build_id}"
        LAUNCH APP APPIUM    Settings_Full
        Sleep    5
        TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[@text='Location']    20
    ELSE
        LAUNCH APP APPIUM    Location
    END
    ${Location_statusIVI} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['location_button']}    checked
    Run Keyword If    "${state}"=="on" and "${Location_statusIVI}"=="false"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['location_button']}    5
    ...    ELSE IF    "${state}"=="off" and "${Location_statusIVI}"=="true"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['location_button']}    5
    IF    "${state}"=="off" and "DOM" in "${ivi_build_id}"
        ${pop_up_location} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['pop_up_location_off_DOM']}    10
        Run Keyword If    "${pop_up_location}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['pop_up_location_ok_button']}     5
        ${location_driver_assistance_status} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['location_button_driver_assistance']}    checked
        Run Keyword If    "${location_driver_assistance_status}"=="true"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['location_button_driver_assistance']}    5
        ${pop_up_location_driver_assistance} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['pop_up_location_driver_assistance']}    10
        Run Keyword If    "${pop_up_location_driver_assistance}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['pop_up_location_turn_off_button']}    5
    END

CHECK SPOTIFY PLAYER
    [Arguments]    ${state}=on
    [Documentation]    Play a song on Spotify
    ${music_menu_button} =    Create Dictionary    x=390   y=95
    APPIUM_TAP_LOCATION    ${music_menu_button}
    sleep    3
    ${switch_app_check} =    WAIT ELEMENT BY XPATH    ${PlayStore['check_app_status']}    retries=10
    Run Keyword If    "${state}"=="off"    Should Not Be True    ${switch_app_check}
    Return From Keyword If    "${state}"=="off"
    TAP_ON_ELEMENT_USING_XPATH    ${MusicPlayer['switch_app']}    20
    sleep    30
    TAP_ON_ELEMENT_USING_XPATH    ${MusicPlayer['select_spotify']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${MusicPlayer['spotify_search_bar']}    20
    APPIUM_ENTER_TEXT    ${MusicPlayer['spotify_search_inbox']}    ViralHits
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    TAP_ON_ELEMENT_USING_XPATH   ${MusicPlayer['first_element_from_list']}    20
    ${res} =    APPIUM_WAIT_FOR_ELEMENT    ${MusicPlayer['open_player_menu']}    20
    Run Keyword If    "${res}" == "True"    TAP_ON_ELEMENT_USING_ID    ${MusicPlayer['open_player_menu']}    20
    ...    ELSE    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH   ${MusicPlayer['first_element_from_list']}    20
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${MusicPlayer['open_player_menu']}    50
    ${spotify_time_played_first} =    GET TEXT BY XPATH    ${MusicPlayer['current_time']}
    Sleep    20
    TAP_ON_ELEMENT_USING_ID    ${MusicPlayer['play_pause_button']}    10
    Sleep    20
    ${spotify_time_played_second} =    GET TEXT BY XPATH    ${MusicPlayer['current_time']}
    Should Not Be Equal    ${spotify_time_played_first}    ${spotify_time_played_second}
    TAP_ON_ELEMENT_USING_ID    ${MusicPlayer['play_pause_button']}    10
    TAP_ON_ELEMENT_USING_ID    ${MusicPlayer['back_button']}    10

CHECK PLAYSTORE CONNECTIVITY
    [Arguments]    ${state}=on
    [Documentation]    Check GAS connectivity on Play Store
    ${app_status_check} =    WAIT ELEMENT BY XPATH    ${PlayStore['search_bar']}    retries=10
    Run Keyword If    "${state}"=="off"    Should Not Be True    ${app_status_check}
    Return From Keyword If    "${state}"=="off"
    TAP_ON_ELEMENT_USING_XPATH    ${PlayStore['search_bar']}    20
    APPIUM_ENTER_TEXT    ${PlayStore['search_inbox']}    podcast
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    TAP_ON_ELEMENT_USING_XPATH    ${PlayStore['select_result']}    30
    WAIT ELEMENT BY XPATH    ${PlayStore['check_app_status']}    retries=10
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

SEARCH VEHICLE LOCATION ON IVI
    [Documentation]    Search for vehicle location in IVI
    CREATE APPIUM DRIVER
    Sleep    10s
    LAUNCH APP APPIUM    Navigation
    Run Keyword and Ignore Error    enable_multi_windows
    Sleep    20s
    ${elem_find} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['search_button_map']}    20
    Run Keyword If    "${elem_find}" == "False"    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['map_back_button']}    20
    Run Keyword If    "${elem_find}" == "False"    Run Keyword And Ignore Error    CLOSE EPOI LIST
    Run Keyword If    "${elem_find}" == "False"    Run Keyword And Ignore Error    EXIT NAVIGATION
    ${elem_find_reset} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['search_button_map']}    20
    Should Be True    ${elem_find_reset}
    ${car_location_icon} =    Create Dictionary    x=1188    y=945
    APPIUM_TAP_LOCATION    ${car_location_icon}
    ${element_map} =    APPIUM_WAIT_FOR_ELEMENT    ${car_settings['map_locator_IVI']}    10
    Run Keyword If    "${element_map}"=="True"    TAP_ON_ELEMENT_USING_ID    ${car_settings['map_locator_IVI']}    10
    Sleep    5s

SELECT CHARGING STATION ON IVI
    [Documentation]    Search for charging station in IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['search_button_map']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['categories_button_map']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['charging_station_map']}    20
    Sleep    5

ECO TRIP RESET
    [Documentation]    Reset values from EcoDriving
    LAUNCH APP APPIUM    DrivingEco
    TAP_ON_ELEMENT_USING_ID    ${EV_services['new_trip_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['other_data_menu']}    5
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['reset_data_button']}    10
    Run Keyword If    "${elem}" == "True"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${EV_services['reset_data_button']}     5
    ...    AND    TAP_ON_ELEMENT_USING_ID    ${EV_services['confirmation_button']}    5

CHECK DATA AFTER RESET ECO TRIP
    [Documentation]    Check all values from EcoDriving ware restarted
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['curent_trip_menu']}    5
    ${trip_distance_km} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['trip_distance_km']}
    ${average_speed} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['average_speed']}
    ${average_electric_consumption} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['average_speed']}
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['score_menu']}    5
    ${eco_driveing_score} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['eco_driveing_score']}
    ${acceleration} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['acceleration']}
    ${anticipation} =    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['anticipation']}
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['other_data_menu']}    5
    Should Be True    "${trip_distance_km}" == "0.0"    Trip distance was not cleared
    Should Be True    "${average_speed}" == "--.-"    Average speed was not cleared
    Should Be True    "${average_electric_consumption}" == "--.-"    Average electric consumption was not cleared
    Should Be True    "${eco_driveing_score}" == "--"    Eco driving was not cleared
    Should Be True    "${acceleration}" == ""    Acceleration was not cleared
    Should Be True    "${anticipation}" == ""    Anticipation was not cleared

SEARCH HELP SETTINGS ON IVI
    [Arguments]    ${needed_menu}
    [Documentation]    Search Settings and Search the required setting
    ...    == Parameters: ==
    ...     needed_menu: settings menu needed [Note: Name should be as in on_board_ids.yaml]
    TAP_ON_ELEMENT_USING_ID    ${car_settings['settings_menu']}     5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['${needed_menu}']}     5
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['${needed_menu}']}    10
    Should Be Equal    "${elem}"    "True"
    ${element_find_help_center} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['map_help_center']}    10
    Should Be True    ${element_find_help_center}
    ${element_find_version} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['map_version']}    direction=down    scroll_tries=12
    Should Be True    ${element_find_version}

ENTER DESTINATION ADDRESS ON IVI
    [Arguments]    ${dest_address}    ${vehicle_connected}=True
    [Documentation]    Enter the destination address and search EPOI there
    ...    == Parameters: ==
    ...    dest_address: The Required destination address to be searched in IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['search_button_map']}    20
    TAP_ON_ELEMENT_USING_ID    ${car_settings['search_destination']}     20
    ${status}     ${error} =    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_ID    ${car_settings['search_edit']}     20
    Run Keyword If    "${status}" == "FAIL"       TAP_ON_ELEMENT_USING_ID    ${car_settings['search_edit_FR']}     20
    ${status}     ${error} =    Run Keyword And Ignore Error    APPIUM_ENTER_TEXT    ${car_settings['search_edit']}      ${dest_address}
    Run Keyword If    "${status}" == "FAIL"        APPIUM_ENTER_TEXT    ${car_settings['search_edit_FR']}      ${dest_address}
    ${offline_text} =    APPIUM_WAIT_FOR_XPATH     ${car_settings['offline_status']}    10
    Run Keyword If    "${vehicle_connected}" == "False"    Should Be Equal    "${offline_text}"    "True"
    Return From Keyword If    "${vehicle_connected}" == "False"
    APPIUM_TAP_XPATH    //*[@text='${dest_address}' and @class='android.widget.TextView']
    Sleep    5

START JOURNEY ON MAPS
    [Documentation]    Tap on start of journey button on Maps menu
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['journey_start_button']}    20

SELECT EPOI POINT FROM ALERT
    [Arguments]    ${charging_station}
    [Documentation]    Select an charging station from list
    TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[contains(@text, "${charging_station}")]    50
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['add_stop_button']}    20

CHECK REQUIRED EPOI ON IVI
    [Arguments]    ${EPOI_name}
    [Documentation]    Give EPOI name and check if exists
    ...    == Parameters: ==
    ...    EPOI_name: The Required EPOI name to be searched in IVI
    ${elem_text} =    APPIUM_GET_TEXT    ${car_settings['charging_station_title']}
    Should Be Equal    "${elem_text}"    "${EPOI_name}"

SEARCH CHARGING STATIONS ALONG ROUTE
    [Documentation]    Search charging stations along the route
    TAP_ON_ELEMENT_USING_ID    ${car_settings['start_button']}    5
    Sleep    15
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['search_along_route']}    5
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['charging_stations_route']}     5
    Sleep    10

PERFORM REACHABLE ERP ON IVI
    [Documentation]    Plans the route based on SOC
    APPIUM_LAUNCH_APP    ${car_settings['map_menu_ivi_package']}    ${car_settings['map_menu_ivi_activity']}
    Run Keyword and Ignore Error    enable_multi_windows
    Sleep    20
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['charging_station_image']}    35
    Sleep    5
    FOR  ${i}  IN RANGE    2    5
        ${station_locator} =    Catenate    SEPARATOR=  ${car_settings['select_chargingstation']}   [   ${i}   ]
        Log to Console   Charging Point : ${station_locator}
        TAP_ON_ELEMENT_USING_XPATH    ${station_locator}     10
        Sleep    5
        ${soc} =    APPIUM_GET_TEXT_USING_XPATH    ${car_settings['soc_value']}
        ${soc_value} =    Fetch From Left    ${soc}    %
        Log to Console   SOC Value : ${soc_value}
        ${soc_status} =	Set Variable If   ${soc_value} > 0	 ${True}
        Run Keyword If    ${soc_status}    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['start_navigation']}    10
        ...   ELSE    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['map_back_button']}    20
        Exit For Loop If    ${soc_status}==${True}
    END

SELECT COMPATIBILITY OF CHARGING STATIONS
    [Documentation]    Check the compatible EPOI from the list of charging stations
    Sleep    10
    ${find_compatibility} =    APPIUM_WAIT_FOR_XPATH   ${car_settings['compatible_element']}    10
    Run Keyword If    "${find_compatibility}" == "False"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['compatible_element']}    10
    Sleep    20

FETCH CHARGE TYPE EPOI INFORMATION
    [Documentation]    Fetch Charge type Information of all available EPOIs
    ${charge_plug_epois} =    Create Dictionary
    FOR    ${var}    IN RANGE    1    10
        Run Keyword If    ${var}==3    SCROLL TO EXACT ELEMENT    //android.support.v7.widget.RecyclerView/android.widget.FrameLayout[${var}+1]    from_xpath_element=${car_settings['list_view_charging_stations']}    scroll_tries=3
        ...    ELSE IF    ${var}==7    SCROLL TO EXACT ELEMENT     //android.support.v7.widget.RecyclerView/android.widget.FrameLayout[${var}+1]    from_xpath_element=${car_settings['list_view_charging_stations']}    scroll_tries=3
        ${elem_search} =    APPIUM_WAIT_FOR_XPATH    //android.support.v7.widget.RecyclerView/android.widget.FrameLayout[${var}+1]    10
        Exit For Loop If    ${elem_search}==False
        ${charge_types} =    Create List
        ${charge_plug_available_1} =    APPIUM_WAIT_FOR_XPATH    //android.widget.FrameLayout[${var}+1]/android.widget.LinearLayout/android.widget.LinearLayout[1]/android.widget.RelativeLayout[1]/android.widget.TextView    10
        Exit For Loop If    ${charge_plug_available_1}==False
        ${charge_plug_1_value} =     Run Keyword If    ${charge_plug_available_1}==True   APPIUM_GET_TEXT    //android.widget.FrameLayout[${var}+1]/android.widget.LinearLayout/android.widget.LinearLayout[1]/android.widget.RelativeLayout[1]/android.widget.TextView
        Append To List    ${charge_types}    ${charge_plug_1_value}
        ${charge_plug_available_2} =    APPIUM_WAIT_FOR_XPATH    //android.widget.FrameLayout[${var}+1]/android.widget.LinearLayout/android.widget.LinearLayout[1]/android.widget.RelativeLayout[2]/android.widget.TextView    10
        Exit For Loop If    ${charge_plug_available_2}==False
        ${charge_plug_2_value} =     Run Keyword If    ${charge_plug_available_2}==True   APPIUM_GET_TEXT    //android.widget.FrameLayout[${var}+1]/android.widget.LinearLayout/android.widget.LinearLayout[1]/android.widget.RelativeLayout[2]/android.widget.TextView
        Append To List    ${charge_types}    ${charge_plug_2_value}
        ${charge_plug_name} =     APPIUM_GET_TEXT    //android.widget.FrameLayout[${var}+1]/android.widget.LinearLayout/android.widget.FrameLayout/android.widget.LinearLayout[1]/android.widget.TextView
        Set To Dictionary    ${charge_plug_epois}    ${charge_plug_name}    ${charge_types}
        Log To Console    ${charge_plug_epois}
    END
    [Return]     ${charge_plug_epois}

SELECT NORMAL ROUTE ON IVI
    [Documentation]    Search for normal route in IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['settings_button']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['route_options']}    20
    Sleep    5
    ${avoid_motorways} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['avoid_motorways']}    checked
    ${avoid_toll_roads} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['avoid_toll_roads']}    checked
    ${avoid_ferries} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['avoid_ferries']}    checked
    ${avoid_motorways_updated} =    Run Keyword If    "${avoid_motorways}" != "false"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['avoid_motorways']}    20
    ...    AND    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['avoid_motorways']}    checked
    ${avoid_toll_updated} =    Run Keyword If    "${avoid_toll_roads}" != "false"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['avoid_toll_roads']}    20
    ...    AND    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['avoid_toll_roads']}    checked
    ${avoid_ferries_updated} =    Run Keyword If    "${avoid_ferries}" != "false"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['avoid_ferries']}    20
    ...    AND    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['avoid_ferries']}    checked
    Should Be True    "${avoid_motorways}" == "false" or "${avoid_motorways_updated}" == "false"     AvoidMotorways is selected
    Should Be True    "${avoid_toll_roads}" == "false" or "${avoid_toll_updated}" == "false"    Avoidtollroads is selected
    Should Be True    "${avoid_ferries}" == "false" or "${avoid_ferries_updated}" == "false"    Avoidferries is selected
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20

SELECT GUIDANCE AUDIO
    [Arguments]    ${state}
    [Documentation]    Selecting guidance audio ON
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['settings_button']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['guidance_audio']}    20
    Sleep    5
    Run Keyword If    "${state}" == "ON"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['unmute_option']}    20
    ...    ELSE IF    "${state}" == "OFF"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['mute_option']}    20

SELECT FIRST EPOI ON IVI
    [Documentation]    Selecting the first EPOI on IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['ENEL_station']}    20
    Sleep    5
    ${EPOI_name} =    APPIUM_GET_TEXT_BY_ID    ${car_settings['charging_station_title']}
    [Return]    ${EPOI_name}

FETCH AVAILABLE INFORMATION ON EPOI
    [Documentation]    Get all the avaialable Information of the EPOI selected
    @{complete_epoi_address} =    Create List
    ${epoi_available_information} =    Create Dictionary
    ${EPOI_distance_km} =    APPIUM_GET_TEXT    ${car_settings['epoi_station_distance']}
    ${EPOI_open_time} =    APPIUM_GET_TEXT    ${car_settings['epoi_open_hours']}
    ${EPOI_address} =    APPIUM_GET_TEXT    ${car_settings['full_epoi_address']}
    ${EPOI_pincode} =    APPIUM_GET_TEXT    ${car_settings['pincode_epoi']}
    ${EPOI_name} =    APPIUM_GET_TEXT    ${car_settings['epoi_station_name']}
    ${EPOI_phone_number} =    APPIUM_GET_TEXT    ${car_settings['epoi_phone_num']}
    APPIUM_WAIT_FOR_XPATH    ${car_settings['connector_epoi_type']}    direction=down    scroll_tries=12
    ${EPOI_connector_type} =    APPIUM_GET_TEXT    ${car_settings['connector_epoi_type']}
    ${EPOI_current_power} =    APPIUM_GET_TEXT    ${car_settings['epoi_current_max_power']}
    ${EPOI_ETA} =    APPIUM_GET_TEXT    ${car_settings['ETA_epoi']}
    Append To List    ${complete_epoi_address}    ${EPOI_address}    ${EPOI_pincode}
    Set To Dictionary    ${epoi_available_information}    Selected_EPOI_distance_km    ${EPOI_distance_km}
    ...    Selected_EPOI_open_time    ${EPOI_open_time}    Selected_complete_EPOI_address    ${complete_epoi_address}
    ...    Selected_EPOI_name    ${EPOI_name}    Selected_EPOI_connector_type    ${EPOI_connector_type}
    ...    Selected_EPOI_current_power    ${EPOI_current_power}    Selected_EPOI_ETA    ${EPOI_ETA}
    ...    Selected_EPOI_phone_number    ${EPOI_phone_number}
    [Return]    ${epoi_available_information}

SELECT HIGHWAYS ROUTE ON IVI
    [Documentation]    Search for highway route in IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['settings_button']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['route_options']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['avoid_motorways']}    5
    sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['avoid_ferries']}    5
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20
    sleep    5

PERFORM UNREACHABLE ERP ON IVI
    [Documentation]    Plans the route with unreachable destination based on SOC
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'Multiple charges needed')]
    Return from Keyword If    "${result}" == "True"    log to console    Multiple charges needed
    ${soc} =    APPIUM_GET_TEXT_USING_XPATH    ${car_settings['soc_value']}
    ${soc_value} =    Fetch From Left    ${soc}    %
    Log to Console   SOC Value : ${soc_value}
    ${soc_status} =	Set Variable If   ${soc_value} <= 0	 ${True}
    Should Be Equal    "${soc_status}"    "True"
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['add_charging_stop']}    10
    Should Be Equal    "${elem}"    "True"

CHECK EPOI OFFLINE STATUS
    [Documentation]    Check for EPOI offline status
    ${offline_elem} =     APPIUM_WAIT_FOR_XPATH    ${car_settings['offline_status']}    20
    Should Be True    ${offline_elem}
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['map_back_button']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20

ACCEPT ADDING CHARGING STOPS IN IVI
	[Documentation]    Adding the EPOI along the route automatically if chaarging is required
	TAP_ON_ELEMENT_USING_XPATH    ${car_settings['add_charging_stop']}    10
	Sleep    10

SELECT EPOI TO ADD AND ACCEPT ITINERARY
    [Documentation]    Select a random EPOI to accept new itinerary
    ${element_route} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['route_overview']}    10
    Should Be True    ${element_route}
    Sleep    5
    ${element_find} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['random_epoi_in_list']}    10
    Should Be True    ${element_find}
    Sleep    10
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['random_epoi_in_list']}   10
    Sleep    10
    ${EPOI_name} =    APPIUM_GET_TEXT    ${car_settings['epoi_station_name']}
    Log To Console    ${EPOI_name}
    [Return]    ${EPOI_name}

PERFORM REFUSE TO ADD EPOI IN IVI
    [Documentation]     This HLK is used for refusing to add epoi's on the IVI after giving a long destination
    TAP_ON_ELEMENT_USING_ID    ${car_settings['start_button']}    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['continue_button']}    5
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['out_of_battery_notification']}    5
    Should Be Equal    "${elem}"    "True"
    ${notification_element} =    APPIUM_GET_TEXT    ${car_settings['out_of_battery_notification']}
    Should Be Equal    "${notification_element}"    "Out of battery range"
    ${button} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['dismiss_button']}    10
    Run Keyword If    ${button}==True    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['dismiss_button']}    5
    ...    ELSE    Fail    Not able to find the dismiss button
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['exit_button']}    20

CHECKSET FLAG STATE FOR HMI CONFIGURATION
    [Arguments]    ${parameter_title}    ${parameter}    ${value}    ${expected_value}
    [Documentation]    Set on the IVI platform ${parameter} with value ${value}
    ...    == Parameters: ==
    ...    - _parameter_title_: Category of the paramter of the parameter, could be:
    ...    comfort
    ...    - _parameter_: Name of the parameter, could be:
    ...    caram_careg
    ...    - _value_: Depending on the parameter, could be ON/OFF or a numeric value (for setting)
    ...    - _expected_value_: Depending on the parameter, could be the expected word (on getting)
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Set Flag    IVI CMD
    ${value} =    Convert To Upper Case    ${value}
    DIAG READ CONFIG    hmi_config/${parameter_title}/${parameter}
    ${check} =    Evaluate    "${expected_value}" in """${output}"""
    Run Keyword If    "${check}" == "False"    DIAG SET CONFIG    hmi_config/${parameter_title}/${parameter}    ${value}
    ...    ELSE    Set Variable    True
    Should Be True    ${verdict}    Failed to DIAG SET CONFIG

CLOSE EPOI LIST
    [Documentation]    Pressing x button to close EPOI list on IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20
    Sleep    5

RETRIEVE FIRST EPOI ON IVI
    [Documentation]    Retrieving the First EPOI on IVI
    ${first_epoi} =    APPIUM_GET_TEXT_USING_XPATH    ${car_settings['ENEL_station']}    20
    [Return]    ${first_epoi}
    Sleep    5

CHECK EPOI SELECTED IS COMPATIBLE
    [Arguments]    ${needed_EPOI}
    [Documentation]    Check the EPOI selcted is compatible and its the one selected initially
    ...    == Parameters: ==
    ...    - _needed_EPOI_: The EPOI name which is selected from the list
    ${selected_epoi} =    APPIUM_WAIT_FOR_XPATH   ${car_settings['select_added_epoi']}    10
    Should Be Equal    "${selected_epoi}"    "True"
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['select_added_epoi']}    5
    Sleep    10
    CHECK REQUIRED EPOI ON IVI    ${needed_EPOI}
    ${find_compatibility} =    APPIUM_WAIT_FOR_XPATH   ${car_settings['compatible_text']}    10
    Should Be Equal    "${find_compatibility}"    "True"


CHECK FINAL DESTINATION FROM OVERVIEW
    [Arguments]    ${destination}    ${stop_number}
    [Documentation]    Check specific data for end point destination
    ...    == Parameters: ==
    ...    - destination: Name of charging station
    ...    - stop_number: number of stops till the end destinatio
    Sleep    10
    ${elem} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['route_overview_button']}    30
    Run Keyword If    "${elem}" == "False"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['route_overview_button']}    10
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${destination}']    10
    Should Be True    ${result}
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${stop_number}']    10
    Should Be True    ${result}

REMOVE EXISTING CHARGE STATION
    [Arguments]    ${charging_station}
    [Documentation]    Remove the existing charging station from overview menu
    ...    == Parameters: ==
    ...    - destination: Name of charging station
    TAP_ON_ELEMENT_USING_XPATH    //android.widget.TextView[contains(@text, "${charging_station}")]    50
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['remove_stop_point']}    50

EXIT NAVIGATION
    [Documentation]    Close a routing plan on Maps
    ${element_close} =    APPIUM_WAIT_FOR_ELEMENT    ${car_settings['close_button_maps']}    10
    Run Keyword If    "${element_close}"=="True"    TAP_ON_ELEMENT_USING_ID    ${car_settings['close_button_maps']}    5
    ${element} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['exit_button']}    10
    Run Keyword If    "${element}"=="True"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['exit_button']}    5

EXIT NAVIGATION PLAN
    [Documentation]    Close a routing plan on Maps
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20
    TAP_ON_ELEMENT_USING_ID    ${car_settings['close_button_maps']}    5

SELECT EV PAYMENTS METHODS ON IVI
    [Documentation]    Select payment methods for EV Charging on IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['settings_button']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['ev_payments_filter']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['mobilize_charge_pass']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['plugsurfing']}    20
    Sleep    5
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20
    SELECT CHARGING STATION ON IVI
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['filter_button']}    5
    Sleep    5
    ${element} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['none_text']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20
    Run Keyword If    "${element}"=="True"    Run Keywords
    ...    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['settings_button']}    20
    ...    AND    Sleep    5
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['ev_payments_filter']}    20
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['mobilize_charge_pass']}    20
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['plugsurfing']}    20
    ...    AND    Sleep    5
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['cancel_button']}    20

FETCH PAYMENT TYPE EPOI INFORMATION
    [Documentation]    Fetch Charge type Information of all available EPOIs
    ${verdict} =   APPIUM_WAIT_FOR_XPATH    ${car_settings['Payment_widget']}    direction=down    scroll_tries=12
    Run Keyword If    "${verdict}"=="True"    APPIUM_TAP_XPATH    ${car_settings['Payment_widget']}    20
    Sleep    5
    ${EV_payment_epois} =    Create Dictionary
    ${payment_types} =    Create List
    FOR    ${var}    IN RANGE    1    4
        ${payment_type} =    APPIUM_WAIT_FOR_XPATH    //android.support.v7.widget.RecyclerView/android.widget.FrameLayout[${var}]/android.widget.TextView    10
        Exit For Loop If    ${payment_type}==False
        ${payment_type_text} =     Run Keyword If    ${payment_type}==True   APPIUM_GET_TEXT    //android.support.v7.widget.RecyclerView/android.widget.FrameLayout[${var}]/android.widget.TextView
        Append To List    ${payment_types}    ${payment_type_text}
    END
    ${Payments} =    APPIUM_GET_TEXT    ${car_settings['ev_payment_detail']}
    Set To Dictionary    ${EV_payment_epois}    ${Payments}    ${payment_types}
    Log To Console    ${EV_payment_epois}
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['map_back_button']}    20
    [Return]     ${EV_payment_epois}

SELECT EPOI FILTER PLUGS IN IVI
    [Documentation]    Select filters for charging stations
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['filter_button']}    5
    Sleep    5
    ${plug_select} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['compatible_plugs_option']}    selected
    Run Keyword If    "${plug_select}"=="false"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['compatible_plugs_option']}    10

ADD CHARGING STOPS ALONG ROUTE
    [Documentation]    Add charging stops along route
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['add_charging_stop_button']}    5
    Sleep    60

CHECK BATTERY PERCENTAGE AVAILABLE
    [Documentation]    Check the battery percentage available in IVI during trip
    APPIUM_WAIT_FOR_XPATH    ${car_settings['battery_percentage_thirteen']}    10
    Log To Console    ${battery_percentage_available} = True

CLEAR LAST TRIP DATA
    [Documentation]    Clear values of previous trip from EcoDriving
    LAUNCH APP APPIUM    DrivingEco
    TAP_ON_ELEMENT_USING_ID    ${EV_services['new_trip_button']}    5

SELECT ECOMODE
    [Documentation]    == High Level Description: ==
    ...    Activate ECO Mode in IVI
    START INTENT    com.renault.appmenu/.pages.carworld.CarWorldActivity
    ${eco_mode_enabled} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${EV_services['eco_mode']}    checked
    Run Keyword If    "${eco_mode_enabled}".lower()=="false"    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['eco_mode']}   10

VERIFY TRIP RESET BUTTON
    [Documentation]    == High Level Description: ==
    ...    Verifies Reset Button in ECO Mode in IVI
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['savings_menu']}    5
    ${button_presence} =    APPIUM_WAIT_FOR_ELEMENT  ${EV_services['reset_data_button']}  10
    TAP_ON_ELEMENT_USING_XPATH    ${EV_services['curent_trip_menu']}    10

SAVE TRIP
    [Arguments]    ${saving_mode}
    [Documentation]    Saves the trip in EcoMode in IVI
    ...    == Parameters: ==
    ...    - saving_mode: Parameters like Home-Work,Journey,Personal
    TAP_ON_ELEMENT_USING_ID    ${EV_services['save_trip']}    5
    Run Keyword If    "${saving_mode}"=="Home-Work"    TAP_ON_ELEMENT_USING_ID    ${EV_services['save_homeoption']}    5
    ...    ELSE IF    "${saving_mode}" == "Journey"    TAP_ON_ELEMENT_USING_ID    ${EV_services['save_journeyoption']}    5
    ...    ELSE IF    "${saving_mode}" == "Personal"    TAP_ON_ELEMENT_USING_ID    ${EV_services['save_personaloption']}    5
    TAP_ON_ELEMENT_USING_ID    ${EV_services['confirmation_button']}    5
    TAP_ON_ELEMENT_USING_ID    ${EV_services['eco_navigate']}    5

CHANGE DATE AND TIME ON IVI
    [Arguments]    ${time_to_set}
    [Documentation]    Change the time and date on IVI
    ...    == Parameters: ==
    ...    - time_to_set: Should be in format MMDDhhmmYYYY(Eg:011810302022 - set date as 18-01-2022 and time as 10:30:00)
    ADB_SET_ROOT
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell date ${time_to_set}
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER

CHECK CURRENT DATE AND TIME ON IVI
    [Arguments]    ${time_to_check}
    [Documentation]    == High Level Description: ==
    ...    Check if the date and time on the IVI is the one expected
    ...    == Parameters: ==
    ...    - time_to_check: Should be in format MMDDhhmmYYYY(Eg:011810302022 - set date as 18-01-2022 and time as 10:30:00)
    ADB_SET_ROOT
    ${format_date_and_time} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell date +%m%d%H%M%Y
    Should be Equal    ${format_date_and_time}    ${time_to_check}
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER
    [Return]    ${format_date_and_time}

CHECK SAVED MAP LOCATION ON IVI
    [Arguments]    ${destination}
    [Documentation]    This KW is used to check saved map location on sp and ivi

    Sleep    10
    APPIUM_WAIT_FOR_XPATH    ${car_settings['search_button_map']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['search_button_map']}    20
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_saved']}    20
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_starred']}    20
    Sleep    5
    ${gmap_saved} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${destination}')]
    SHOULD BE TRUE    ${gmap_saved}

GET GOOGLE MAIL ADDRESS FROM IVI
    [Documentation]    Get the google mail address using gmap
    TAP_ON_ELEMENT_USING_ID    ${car_settings['gmap_signin_button']}    10
    Sleep    2
    ${ivi_email_address} =    APPIUM_GET_TEXT_BY_ID    ${car_settings['gmap_signin_account']}
    SWIPE BY COORDINATES    900    235    900    236
    [Return]    ${ivi_email_address}

VERIFY NO SAVED LOCATION ON IVI
    [Arguments]    ${destination}
    [Documentation]    Verify no location is saved in ivi
    APPIUM_WAIT_FOR_XPATH    ${car_settings['search_button_map']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['search_button_map']}    20
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_saved']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_saved']}    20
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_starred']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_starred']}    20
    ${gmap_saved} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${destination}')]
    SHOULD NOT BE TRUE    ${gmap_saved}
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_back_button2']}    20
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_back_button2']}    20

MEASURE TIME FOR PROFILE SWITCH
    [Arguments]    ${ivi_user_profile_name}
    [Documentation]    == High Level Description: ==
    ...    Select a user profile from Notification manager
    ...    == Parameters: ==
    ...    - ivi_user_profile_name: profile name of the user
    ...    == Expected Results: ==
    ...    output: Given user profile should be selected
    APPIUM LAUNCH USER MANAGEMENT
    RECORD REQUEST TIMESTAMP    start
    TAP_ON_ELEMENT_USING_XPATH    //*[contains(@text,'${ivi_user_profile_name}')]//preceding-sibling::android.widget.ImageView    30
    RECORD REQUEST TIMESTAMP    end
    CHECK TIME TAKEN FOR MYRENAULT REMOTE REQUEST
    Sleep    15
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER

MAKE PROFILE AS ADMIN
    [Arguments]    ${ivi_user_profile_name}
    [Documentation]    == High Level Description: ==
    ...    Make the given profile as admin
    ...    == Parameters: ==
    ...    - ivi_user_profile_name: profile name of the user
    ${settings_icon} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['settings']}    20
    Run Keyword If    "${settings_icon}" == "False"    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    20
    TAP_ON_ELEMENT_USING_ID    ${User_profile['user_settings_button']}    15
    APPIUM_TAP_XPATH    ${User_profile['manage_profiles']}    20
    APPIUM_TAP_XPATH    //android.widget.TextView[contains(@text,'${ivi_user_profile_name}')]    20
    APPIUM_TAP_XPATH    ${User_profile['make_admin']}    20
    APPIUM_TAP_XPATH    ${User_profile['confirm_admin']}    20

MEASURE TIME FOR CREATING ADMIN PROFILE
    [Arguments]    ${ivi_user_profile_name}
    [Documentation]    == High Level Description: ==
    ...    Measure the time for making a profile as admin profile
    ...    == Parameters: ==
    ...    - ivi_user_profile_name: profile name of the user
    ...    == Expected Results: ==
    ...    output: The profile is changed to admin profile and performance time calculated
    APPIUM LAUNCH USER MANAGEMENT
    RECORD REQUEST TIMESTAMP    start
    MAKE PROFILE AS ADMIN    ${ivi_user_profile_name}
    RECORD REQUEST TIMESTAMP    end
    CHECK TIME TAKEN FOR MYRENAULT REMOTE REQUEST
    Sleep    15
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER

SAVE LOCATION ON GOOGLE MAP IN IVI
    [Documentation]    Save google map location in ivi
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_favorite_button']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_favorite_button']}    10
    Sleep    2s
    ${check_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['save_checkbox']}    checked
    IF    "${check_selected}"=="true"
        TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_back_button']}    10
        APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_close']}    30
        TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_close']}    10
        Return From Keyword
    END
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_starred']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_starred']}    10
    Sleep    2s
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_close']}    30
    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['gmap_close']}    10

TAP ON BLANK SPACE
    [Documentation]   This KW is used to click blank space on ivi after get gmail
    ${car_location_icon} =    Create Dictionary    x=1188    y=945
    APPIUM_TAP_LOCATION    ${car_location_icon}

UNLOCK PROFILE USING PASSWORD
    [Arguments]    ${ivi_user_password}     ${settings_screen}=False
    [Documentation]    == High Level Description: ==
    ...    UNLOCK User Profile using Password
    ...    == Parameters: ==
    ...    - ivi_user_password: password of the user profile
    ...    - settings_screen: password lock appears on 2 screens on settings page and on main page(True if
    ...    unlocking is done on settings screen)
    ...    == Expected Results: ==
    ...    output: Profile should be unlocked with password
    RUN KEYWORD IF   "${settings_screen}" == "False"   Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_password_field']}    30
    ...    AND    APPIUM_ENTER_TEXT    ${User_profile['profile_password_field']}    ${ivi_user_password}
    ...    ELSE IF   "${settings_screen}" == "True"   Run Keywords
    ...    TAP_ON_ELEMENT_USING_ID    ${User_profile['password_entry']}    20
    ...    AND    APPIUM_ENTER_TEXT    ${User_profile['password_entry']}    ${ivi_user_password}
    Sleep    5
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    5

SWITCH GUEST USER
    [Documentation]    Switching to Guest User
    APPIUM LAUNCH USER MANAGEMENT
    Sleep    30
    FOR  ${i}  IN RANGE    0    15
        TAP_ON_ELEMENT_USING_ID    ${User_profile['user_settings_button']}    30
        ${t} =     APPIUM_WAIT_FOR_XPATH    ${User_profile['manage_accounts']}    30
        Exit For Loop If    "${t}" == "True"
    END
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['guest']}    30
    Sleep    30
    UNINSTALL_APPIUM_LIBRARIES
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER
    Sleep  10

UNLOCK PROFILE USING PINCODE
    [Arguments]    ${ivi_user_pincode}    ${settings_screen}=False
    [Documentation]    == High Level Description: ==
    ...    UNLOCK User Profile using PINCODE
    ...    == Parameters: ==
    ...    - ivi_user_pincode: pincode of the user profile
    ...    - settings_screen: pincode lock appears on 2 screens on settings page and on main page(True if
    ...    unlocking is done on settings screen)
    ...    == Expected Results: ==
    ...    output: Profile should be unlocked with pincode
    ENTER PINCODE KEYS    ${ivi_user_pincode}    ${settings_screen}
    RUN KEYWORD IF   "${settings_screen}" == "False"
    ...    TAP_ON_ELEMENT_USING_ID     ${User_profile['pincode_key_enter_button']}    30
    ...    ELSE
    ...    TAP_ON_ELEMENT_USING_ID     ${User_profile['enter_pin_button']}    30

ENTER PINCODE KEYS
    [Arguments]    ${ivi_user_pincode}    ${settings_screen}=False
    [Documentation]    == High Level Description: ==
    ...    Enter pincode keys in a for loop
    ...    - ivi_user_pincode: pincode of the user profile
    ...    - settings_screen: password lock appears on 2 screens on settings page and on main page(True if
    ...    unlocking is done on settings screen)
    @{user_pin_code} =   convert to list  ${ivi_user_pin_code}
    IF    "${settings_screen}" == "False"
        FOR    ${number}    IN    @{user_pin_code}
            TAP_ON_ELEMENT_USING_ID    com.android.systemui:id/key${number}    30
        END
    ELSE
        FOR    ${number}    IN    @{user_pin_code}
            TAP_ON_ELEMENT_USING_ID    com.android.car.settings:id/key${number}    15
        END
    END

UNLOCK PROFILE USING PATTERN
    [Arguments]    ${ivi_user_pattern}     ${settings_screen}=False     ${offset}=50
    [Documentation]    == High Level Description: ==
    ...    UNLOCK User Profile using Pattern
    ...    == Parameters: ==
    ...    - ivi_user_pattern: pattern of the user profile
    ...    - settings_screen: pattern lock appears on 2 screens on settings page and on main page(True if
    ...    unlocking is done on settings screen)
    ...    - offset: Offset represents a approximate distance between 2 dots on pattern screen
    ...    == Expected Results: ==
    ...    output: Profile should be unlocked with pattern
    RUN KEYWORD IF   "${settings_screen}" == "False"    Run Keywords
    ...    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['pattern_entry_screen']}    30
    ...    AND    unlock_pattern    ${User_profile['pattern_entry_screen']}    ${ivi_user_pattern}    ${offset}
    ...    ELSE   unlock_pattern     ${User_profile['set_lock_pattern']}    ${ivi_user_pattern}    ${offset}

VERIFY WRONG PINCODE TEXT
    [Documentation]    == High Level Description: ==
    ...    Verify Wrong Pincode error when wrong pincode is sent
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['wrong_profile_pincode']}    10
    Should Be True    ${result}    Correct pincode is sent

VERIFY WRONG PASSWORD TEXT
    [Documentation]    == High Level Description: ==
    ...    Verify Wrong Password error when wrong password is sent
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['wrong_profile_password']}    10
    Should Be True    ${result}    Correct password is sent

VERIFY WRONG PATTERN TEXT
    [Documentation]    == High Level Description: ==
    ...    Verify Wrong Pattern error when wrong pattern is sent
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['wrong_profile_pattern']}    10
    Should Be True    ${result}    Correct Pattern is sentVERIFY WRONG PATTERN TEXT

CHECK WIDGET SETTINGS ENABLED
    [Documentation]    Check the bottom widget settings
    LAUNCH APP APPIUM    Navigation
    Run Keyword and Ignore Error    enable_multi_windows
    Sleep    10
    ${seat} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['seatbutton']}    20
    Should Be True    ${seat}
    ${climate} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['climatebutton']}    20
    Should Be True    ${climate}
    ${ventilation} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['ventilationbutton']}    20
    Should Be True    ${ventilation}

CHECK MYR AND GOOGLE BUTTON IN GUEST USER
    [Documentation]    Check for MYR , Google Button for the User
    APPIUM LAUNCH USER MANAGEMENT
    ${myr_button} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['myraccount_button']}    10
    Should Not Be True    ${myr_button}
    ${google_button} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['google_account']}    10
    Should Not Be True    ${google_button}

CHECK IVI DATA PRIVACY
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in settings menu and activate the data collection
    ...    Data collection 'ON' means that privacy is disabled and thus data is shared
    ...    == Parameters: ==
    ...    - _state_: ON, OFF
    ...    == Expected Results: ==
    ...    Pass if executed
    [Tags]    Automated    Remote Services Common    IVI CMD
    Sleep    5
    IF    "${ivi_my_feature_id}" == "MyF1"
        LAUNCH APP APPIUM    Privacy
        Sleep    2
        ${text_retrieved} =    APPIUM_GET_TEXT_BY_ID    ${car_settings['data_collection']}    20
        Should Not Be Equal    "${state}"    "${text_retrieved}"
    ELSE
        LAUNCH APP APPIUM    ProfileSettings
        Sleep    2
        ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10
        Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${edit_profile}
        ${result} =    APPIUM_WAIT_FOR_XPATH    ${share_only_data}
        Run Keyword If    "${result}" == "True"    APPIUM_TAP_XPATH    ${share_only_data}
        ...    ELSE    APPIUM_TAP_XPATH    ${data_position_sharing}
        SCROLL TO EXACT ELEMENT    element_id_or_xpath=${share_data_and_position}    direction=down
        ${attri_retrieved} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['refuse_sharing']}    checked
        IF    "${state}".lower() == "on"
            Should Be Equal    "true"    "${attri_retrieved}"
        ELSE
            Should Not Be Equal    "true"    "${attri_retrieved}"
        END
        TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    10
    END

ADD MULTIPLE NEW USER PROFILE
    [Arguments]    ${number_of_users}=4
    [Documentation]    == High Level Description: ==
    ...    Add multiple new user profile
    ...    == Parameters: ==
    ...    - number_of_users: number of user profile to be created
    ...    == Expected Results: ==
    ...    output: add one or more user profile
    FOR    ${number}    IN RANGE    0    ${number_of_users}
        APPIUM LAUNCH USER MANAGEMENT
        ${add_user_icon} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['add_user']}    20
        Run Keyword IF    "${add_user_icon}"=="True"    ADD NEW USER PROFILE
        Run Keyword And Return IF    "${add_user_icon}"=="false"    Sleep    2s
        REMOVE APPIUM DRIVER
        CREATE APPIUM DRIVER
        Sleep    30s
    END

VERIFY MAXIMUM USER PROFILES CREATED
    [Documentation]    == High Level Description: ==
    ...    Verify no add profile button available
    APPIUM LAUNCH USER MANAGEMENT
    ${sec_element} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['add_user']}    20
    Should Not Be True    ${sec_element}

REMOVE MULTIPLE USER PROFILE
    [Arguments]    ${admin_profile}    ${number_of_user}=4
    [Documentation]    == High Level Description: ==
    ...    Remove multiple user profiles
    ...    == Parameters: ==
    ...    - admin_profile: admin user name
    ...    - number_of_users: number of user profile to be removed
    ...    == Expected Results: ==
    ...    output: remove one or more user profile
    SELECT USER PROFILE    ${admin_profile}
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER
    Sleep    30s
    FOR    ${var}    IN RANGE    0    ${number_of_user}
        Run Keyword And Ignore Error    REMOVE USER PROFILE
        Sleep    10
    END

VERIFY CAR SETTINGS ON IVI
    [Documentation]    == High Level Description: ==
    ...    Verifies Car settings Options in IVI
    LAUNCH APP APPIUM    TPMS
    ${settings_option} =    Create List   Electric   Air quality    Driving eco    Driving assistance    Parking assistance    Vehicle
    FOR    ${setting}    IN    @{settings_option}
        ${setting_str} =     REPLACE STRING    ${setting}   ${SPACE}    _
        ${car_setting_button} =    Catenate    SEPARATOR=_     ${setting_str}    settings_button
        ${elmt} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['${car_setting_button}']}   10
        IF    "${elmt}" == "True"
            TAP_ON_ELEMENT_USING_XPATH    ${car_settings['${car_setting_button}']}    15
            Sleep    5s
            ${car_setting_back_button} =    Catenate    SEPARATOR=_     ${setting_str}    settings_nav_back_button
            ${result} =   APPIUM_WAIT_FOR_ELEMENT    ${car_settings['${car_setting_back_button}']}    retries=5
            Run Keyword If    "${result}" == "True"    TAP_ON_ELEMENT_USING_ID    ${car_settings['${car_setting_back_button}']}    20
            Run Keyword If    "${result}" == "False"    LAUNCH APP APPIUM    TPMS
            Sleep    5s
        ELSE
            Log to console    ${setting_str} Menu not found
        END
    END

MANAGE PROFILE IN IVI
   [Documentation]    == High Level Description: ==
    ...     This KW is used to manage profiles on IVI
    APPIUM LAUNCH USER MANAGEMENT
    IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"
        ${settings_icon} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['settings_myf3']}    20
    ELSE
        ${settings_icon} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['settings']}    20
    END
    Run Keyword If    "${settings_icon}" == "False"    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    20
    IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"
        TAP_ON_ELEMENT_USING_XPATH    ${User_profile['settings_myf3']}    10
    ELSE
        TAP_ON_ELEMENT_USING_XPATH    ${User_profile['settings']}    10
    END
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['manage_profiles']}    10
    IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"
        APPIUM_TAP_XPATH    //android.widget.TextView[contains(@text,'Manage other profiles')]    20
    END

PROFILE PERMISSIONS
   [Arguments]    ${profile_name}    ${permission}    ${state}=On
   [Documentation]    == High Level Description: ==
    ...    This KW is to manage profile permissions
    ...    == Parameters: ==
    ...    - profile_name - : profile name which you want to enable or disable permission
    ...    - permission - : permission need to be enabled/disabled
    ...    - state - : the permission is On or Off
    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${profile_name}']    20
    Sleep   15
    ${is_checked} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //*[@text='${permission}']/ancestor::android.widget.RelativeLayout/android.widget.FrameLayout/android.widget.Switch    checked
    Run Keyword If    "${is_checked}" == "false" and "${state}" == "On"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${permission}']/ancestor::android.widget.RelativeLayout/android.widget.FrameLayout/android.widget.Switch    20
    ...    ELSE IF    "${is_checked}" == "true" and "${state}" == "Off"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${permission}']/ancestor::android.widget.RelativeLayout/android.widget.FrameLayout/android.widget.Switch    20
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER

VERIFY ACCOUNT LIMIT REACHED
    [Documentation]    == High Level Description: ==
    ...     Verify account limit reached in ivi
    MANAGE ACCOUNT IN IVI
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['select_myr']}    10
    ${account_limit} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['account_limit_reached']}    10
    Should Be True    ${account_limit}    Failed account limit not reached

SELECT FAST CHARGING OPTION
   [Arguments]    ${state}=True
   [Documentation]    == High Level Description: ==
    ...    This KW is to enable fast charging option in map
    ...    == Parameters: ==
    ...    - state - : the permission is "True" or "False"
    Sleep   5s
    ${fast_charge_selected} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['fast_charging_button']}    selected
    Run Keyword If    "${fast_charge_selected}" == "false" and "${state}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['fast_charging_button']}    20
    ...    ELSE IF    "${fast_charge_selected}" == "true" and "${state}" == "False"    TAP_ON_ELEMENT_USING_XPATH    ${car_settings['fast_charging_button']}    20

FAST AND MEDIUM CHARGING AVAILABILITY
   [Arguments]    ${fast}    ${medium}
   [Documentation]    == High Level Description: ==
    ...    This KW is to check fast and medium charging option in map
    ...    == Parameters: ==
    ...    - fast - : the permission is "True" or "False"
    ...    - medium - : the permission is "True" or "False"
    Sleep   5s
    ${fast_charge} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['epoi_fast']}    20
    Should Be True    ${fast_charge}
    ${medium_charge} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['epoi_medium']}    20
    Run Keyword If    "${fast}" == "True"    Should Be True    ${fast_charge}    20
    ...    ELSE IF    "${fast}" == "False"    Should Not Be True    ${fast_charge}    20
    ...    ELSE IF    "${medium}" == "True"    Should Be True    ${medium_charge}    20
    ...    ELSE IF    "${medium}" == "False"    Should Not Be True    ${medium_charge}    20
    ...    ELSE    Fail    No charging option available

RECORD REQUEST TIMESTAMP
    [Arguments]    ${request}
    [Documentation]    == High Level Description: ==
    ...    Set Current Timestamp
    ...    output: send current time to the function call
     ...    == Parameters: ==
    ...    request: start/end depending on test
    ${event_time1} =     robot.libraries.DateTime.Get Current Date    UTC    result_format=%Y-%m-%dT%H:%M:%SZ    exclude_millis=True
    log to console    ${event_time1}
    Run Keyword If     "${request}" == "start"     set test variable     @{start_time}    ${event_time1}
    ...    ELSE     set test variable    @{end_time}    ${event_time1}

SET ALLIANCE KITCHEN SINK VPA STUB
    [Arguments]    ${property_type}    ${value}
    [Documentation]    To set ${property_type} in VPA STUB to ${value}
    ...    ${property_type}    parameter in Vehicle Stub
    ...    ${value}    value(true/false) of ${property_type} to be set
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    10s
    APPIUM_TAP_XPATH    //*[@content-desc='Open drawer' or @class='android.widget.ImageButton']
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='VPA stub']    from_xpath_element=//*[@resource-id='com.alliance.car.kitchensink:id/plugin_list_drawer']    direction=down    scroll_tries=25
    APPIUM_TAP_XPATH    //*[@text='VPA stub']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Allow']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/sPropertyId']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/sPropertyId']
    APPIUM_TAP_XPATH    //*[@text='${property_type}']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/etSetPropertyValue']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_ENTER_TEXT_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/etSetPropertyValue']    ${value}
    APPIUM_PRESS_KEYCODE    ${KEYCODE_ENTER}
    SLEEP    5
    APPIUM_TAP_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/bSetProperty']

DO IVI IMPORT CONTACTS
    [Documentation]    == High Level Description: ==
    ...     Import contacts on IVI
    CREATE APPIUM DRIVER
    LAUNCH APP APPIUM    Contacts
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['menu']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['settings_contact']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['import']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['file_tipe']}    10
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${Contacts['allow']}    10
    Run Keyword If    "${verdict}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['allow']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['second_menu']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['usb']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['file']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${Contacts['back']}    10
    ${element} =    APPIUM_WAIT_FOR_XPATH    ${Contacts['contacts']}    10
    Should Be True    ${element}    Failed to import contacts on IVI

CHECK IVI PERSONAL SETTINGS
    [Documentation]    == High Level Description: ==
    ...    Check that no user personal settings are present on IVI after factory reset
    ...    Check no ivi wifi network is saved
    ...    Check that there is no new user on users list
    ...    Check google account empty
    ...    Check ivi contacts empty
    ...    Check spotify app uninstalled
    GOTO WI-FI SETTINGS APPIUM    ${ivi_adb_id}
    FOR  ${i}  IN RANGE    1    20
        ${result} =   WAIT ELEMENT BY XPATH    //*[@text='Connected']
        Should Not Be True    ${result}
    END
    ${all_users} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pm list users
    SHOULD NOT CONTAIN    ${all_users}    ${new_user}
    LAUNCH APP APPIUM    Contacts
    ${element} =    APPIUM_WAIT_FOR_XPATH    ${Contacts['contacts']}    10
    Should Not Be True    ${element}
    CHECKSET GAS REGISTRATION    ${gas_login}    ${gas_pswd}
    APPIUM_TAP_XPATH    ${PlayStore['search']}
    ENTER TEXT    ${PlayStore['search_inbox']}    Spotify
    Sleep    3s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    3s
    APPIUM_TAP_XPATH    ${PlayStore['first_app_found']}
    Sleep    3s
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['install_button']}   10
    Should Be True    ${res}

REMOVE ADMIN USER PROFILE
    [Documentation]    == High Level Description: ==
    ...    Remove 'admin profile' profile
    ...    == Expected Results: ==
    ...    The "admin profile" in the profiles tab to be deleted
    APPIUM LAUNCH USER MANAGEMENT
    Sleep    2s
    START INTENT    com.renault.profilesettingscenter/com.renault.profilesettingscenter.ui.view.UserProfileActivity
    Sleep    2s
    TAP_ON_ELEMENT_USING_ID    ${User_profile['user_settings_button']}    15
    APPIUM_TAP_XPATH    ${User_profile['delete_profile']}    20
    APPIUM_TAP_XPATH    ${User_profile['delete_admin']}    20

ADD ADMIN USER PROFILE WITH MYR ACCOUNT
    [Documentation]    == High Level Description: ==
    ...    This KW is to add admin user with myr account
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER    SetupWizardOverlay
    Sleep    20s
    ACCEPT TERMS AND CONDITION    True
    SIGN IN TO MYRENAULT ACCOUNT IN IVI    ${myrenault_username}    ${myrenault_password}
    Sleep    15s

LAUNCH ANDROID AUTO ON IVI
    [Documentation]    == High Level Description: ==
    ...    Open Android Auto on the IVI screen
    Sleep    60s
    CHECKSET FILE PRESENT    bench    ${go_to_phone_img}
    CHECK AND SWITCH DRIVER   ${ivi_driver}
    enable multi windows
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Start' or @text='Start Android Auto']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Start' or @text='Start Android Auto']
    # Workaround because on Access DA we cannot see the Andoid auto pop up and we need to enter on Apps Menu then on Andorid Auto
    IF    "${result}" == "${False}"
        LAUNCH APP APPIUM    AppsMenu
        APPIUM_TAP_XPATH    //*[@text='Android Auto']
    END
    Run Keyword If    "${ivi_my_feature_id}" != "MyF3"     Run Keyword And Ignore Error    APPIUM_TAP_XPATH    //*[@text='OK']    retries=10
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Continue']    retries=10
    IF    "${result}" == "${True}"
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Continue']
    ELSE
        Sleep    60s
        ${verdict}    ${result} =    Run Keyword And Ignore Error    CHECK IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${go_to_phone_img}
        IF    "${verdict}" == "PASS"
            CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${go_to_phone_img}
            Sleep    5s
            CHECK AND SWITCH DRIVER   ${mobile_driver}
            ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Unlock']    retries=5
            Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Unlock']
            Run Keyword If    "${result}" == "${True}"    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
            ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Continue']    retries=5
            Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Continue']
            ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Android Auto']    retries=5
            Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Android Auto']
            ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']    retries=5
            Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Allow']
            CHECK AND SWITCH DRIVER   ${ivi_driver}
            Sleep    5s
            enable multi windows
            ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Continue']    retries=10
            Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Continue']
        END
    END
    Sleep    2s
    CHECKSET FILE PRESENT    bench    ${launch_android_auto}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    3x    60s    CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${launch_android_auto}

ENABLE ANDROID AUTO ON SMARTPHONE
    [Documentation]    == High Level Description: ==
    ...   Enable Android Auto on the smartphone
    LAUNCH APP APPIUM    Settings    smartphone     platform_version=${smartphone_platform_version}
    IF    "${smartphone_platform_version}" == "11"
        ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Apps & notifications']    retries=10    direction=down    scroll_tries=20
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Apps & notifications']
        ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='App info']    retries=10    direction=down    scroll_tries=20
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='App info']
    ELSE
        ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Apps']    retries=10    direction=down    scroll_tries=20
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Apps']
    END
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Android Auto']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Android Auto']
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Turn on' or @text='Enable']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Turn on' or @text='Enable']

DISABLE ANDROID AUTO ON SMARTPHONE
    [Documentation]    == High Level Description: ==
    ...    Disable Android Auto on the smartphone
    LAUNCH APP APPIUM    Settings    smartphone     platform_version=${smartphone_platform_version}
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Apps']    retries=10    direction=down    scroll_tries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Apps']
    IF    "${smartphone_platform_version}" < "11"
        ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Android Auto']    retries=10
    END
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Android Auto']
        ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Disable']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Disable']
    ${result} =  APPIUM_WAIT_FOR_XPATH    //*[@text='Disable app']    retries=10
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Disable app']
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

CHECK MYR MAIL ACCOUNT
    [Arguments]    ${email_id}
    [Documentation]    == High Level Description: ==
    ...     Check the MyRenault email id is present in ivi
    MANAGE ACCOUNT IN IVI
    ${check_myr_acc} =    APPIUM_GET_TEXT_USING_XPATH    ${User_profile['myr_email_account']}    20
    Run Keyword If    "${check_myr_acc}" == "${email_id}"    Log    Valid MYR Account was added
    ...     ELSE    Fail    Not Valid MYR Account was added.

VALIDATE WELCOME PAGE
    [Documentation]    == High Level Description: ==
    ...     This KW is used to validate if the page is in welcome page
    ${verdict} =    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['welcome_begin']}    60
    SHOULD BE TRUE    ${verdict}

SET HMI LANGUAGE ON SETUPWIZARD
    [Documentation]    Set on  IVI the language from SetupWizard
    ${skip button}=    APPIUM_WAIT_FOR_XPATH    ${factory_reset_language_selection}    5
    Run Keyword If    "${skip button}"=="True"    TAP_ON_ELEMENT_USING_XPATH    ${factory_reset_language_selection}    5
    SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='English' or @text='English (United Kingdom)' or @text='English (United States)']    direction=down
    APPIUM_TAP_XPATH    //*[@text='English' or @text='English (United Kingdom)' or @text='English (United States)']     retries=20
    Sleep    5s
    SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='English' or @text='English (United Kingdom)' or @text='English (United States)']    direction=down
    APPIUM_TAP_XPATH    //*[@text='English' or @text='English (United Kingdom)' or @text='English (United States)']    retries=20
    Sleep    5s

PLAYSTORE APPS UPDATE
    [Arguments]    ${gas_login}    ${gas_pswd}
    [Documentation]    Check if Google login is performed and update all apps from PlayStore
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']    retries=10
    Run keyword If    "${res}"== "True"    APPIUM_TAP_XPATH    //*[@text='Allow']
    LAUNCH APP APPIUM    Settings
    ${ret_code} =    START INTENT    -n com.android.vending/com.google.android.finsky.carmainactivity.MainActivity
    Should Be Equal    ${ret_code}    ${0}
    Run Keyword And Continue On Failure    WIFI CONNECTION
    Run Keyword And Ignore Error    LAUNCH APP APPIUM    PlayStore2
    ${result}=   APPIUM_WAIT_FOR_XPATH    //*[@text='Sign in']
    Run Keyword If    "${result}"=="True"    Run Keyword    CHECKSET GAS REGISTRATION    ${gas_login}    ${gas_pswd}
    Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${PlayStore['more_options']}    10
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    //*[@text='My apps' or @text='My Apps']    retries=20
    ENABLE MULTI WINDOWS
    ${is_present}=   APPIUM_WAIT_FOR_XPATH    //*[@text='No updates available']    30
    IF    "${is_present}" == "False"
        ${result} =    Run Keyword And Return Status    CHECK WIFI STATUS    ${ivi_adb_id}    off
        Run Keyword If   "${result}" == "None"    WIFI CONNECTION
        LAUNCH APP APPIUM    PlayStore2
        Run Keyword And Ignore Error    TAP_ON_ELEMENT_USING_XPATH    ${PlayStore['more_options']}    10
        Run Keyword And Ignore Error    APPIUM_TAP_XPATH    //*[@text='My apps' or @text='My Apps']    retries=20
        ENABLE MULTI WINDOWS
        APPIUM_TAP_XPATH    //*[@text='Update all']    retries=20
        Sleep    60
        Wait Until Keyword Succeeds    5x    30s    APPIUM_WAIT_FOR_XPATH    //*[@text='No updates available']    30
        APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
        Sleep    2s
        APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
        Sleep    2s
        Run Keyword If    "${ivi_bench_type}" not in "${bench_type}"    Run Keyword And Ignore Error    CHECKSET WIFI STATUS    ${ivi_adb_id}    off
    END
    GO HOME SCREEN APPIUM

ACCEPT PRIVACY SETTINGS FOR GOOGLE MAPS
    [Documentation]    Turn on location and accept privacy settings for google maps
    LAUNCH APP APPIUM    Navigation
    Run Keyword and Ignore Error    enable_multi_windows
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_settings_button']}    10
    APPIUM_TAP_XPATH    ${car_settings['gmap_settings_button']}    10
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_turn_on_button']}    10
    APPIUM_TAP_XPATH    ${car_settings['gmap_turn_on_button']}    10
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_done_button']}    10
    APPIUM_TAP_XPATH    ${car_settings['gmap_done_button']}    10
    APPIUM_WAIT_FOR_XPATH    ${car_settings['gmap_close_button']}    10
    APPIUM_TAP_XPATH    ${car_settings['gmap_close_button']}    10

CHECKSET GOOGLE ACCOUNT ON IVI
    [Arguments]    ${email_id}    ${password}=None
    [Documentation]    == High Level Description: ==
    ...     This KW is used to add a google account on IVI and check its failing.
    ...    == Parameters: ==
    ...    - email_id - : Username to login in the google account
    ...    - password - : Password to login in the google account

    MANAGE ACCOUNT IN IVI
    ${google} =    Run Keyword And Ignore Error    GET TEXT BY XPATH    ${User_profile['google_account_username']}
    ${exists} =    Evaluate   "${email_id}" in """${google}"""
    Run Keyword If    ${exists}==True    STOP INTENT    com.android.car.settings
    Return From Keyword If    ${exists}
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_account']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['google_account']}    10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['remove_account']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['remove_account']}    10
    ${elemt} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['confirm_remove']}    10
    Run Keyword If    ${elemt}==True    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['confirm_remove']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['add_account']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['select_google']}    10
    LOGIN GOOGLE ACCOUNT IN IVI    ${email_id}    ${password}
    APPIUM_WAIT_FOR_ELEMENT    ${User_profile['gmail_login_success']}    60
    TAP_ON_BUTTON    ${User_profile['gmail_login_success']}    10
    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_account_username']}   60
    ${google} =    GET TEXT BY XPATH    ${User_profile['google_account_username']}
    ${exists} =    Evaluate   "${email_id}" in """${google}"""
    Should Be True    ${exists}
    STOP INTENT    com.android.car.settings

DO EMULATE MALICIOUS ACTIVITY ON IVI
    [Documentation]    	Emulate on IVI Platform a malicious activity
    ...    by entering the wrong PIN for 5 times
    APPIUM LAUNCH USER MANAGEMENT
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['profile_protection']}    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['choose_lock_type']}    10
    Sleep   5s
    LOCK CURRENT PROFILE    pin    ${ivi_user_pin_code}
    DO REBOOT      ${ivi_adb_id}    command line
    Sleep    10
    FOR    ${i}    IN RANGE    6
        OperatingSystem.Run    adb -s ${ivi_adb_id} shell input text ${wrong_pin_password}
        OperatingSystem.Run    adb -s ${ivi_adb_id} shell input keyevent 66
        Sleep    2
    END

RECONFIRM DATA PRIVACY
    [Documentation]    	Confirm data privacy after a new profile is created or remove it
    ENABLE MULTI WINDOWS
    ${data_privacy} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Go to settings']    20
    Run Keyword If    "${data_privacy}"=="True"    Run Keywords    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Go to settings']    20
    ...    AND    Sleep    2
    ...    AND    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Accept all']    20
    ...    AND    Sleep    2
    ...    AND    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}

IGNORE DATA PRIVACY
    [Documentation]    	Remove data privacy pop-up after a new profile is created
    [Arguments]    ${retries}=20
    Log To Console    IGNORE DATA PRIVACY
    ${data_privacy} =    APPIUM_WAIT_FOR_ELEMENT    ${privacy_later_id}    ${retries}
    Run Keyword If    "${data_privacy}"=="True"    PRESS BUTTON BY ID   ${privacy_later_id}

CHECK THE HVAC SETTINGS ON HMI FOR SW200
    [Arguments]    ${profile}
    LAUNCH APP APPIUM    EvMenu
    APPIUM TAP EVSERVICES CHARGE AND CLIMATE
    APPIUM_TAP_XPATH    ${program}
    Sleep    1

    ${element} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['my_programs']}    10
    ${retrieved_text} =    Run Keyword If    '${element}' == "True"    APPIUM_GET_TEXT_USING_XPATH    ${EV_services['my_programs']}
    Run Keyword If    "programs" in """${retrieved_text}.lower()"""    APPIUM_TAP_XPATH    ${EV_services['my_programs']}    30
    Sleep    2

    Run Keyword If    "${profile}" == "one_calendar"    ONE CALENDAR
    ...    ELSE IF    "${profile}" == "two_calendars"    TWO CALENDARS
    ...    ELSE IF    "${profile}" == "two_calendars_from_MyR"    TWO CALENDARS FROM MYR
    ...    ELSE IF    "${profile}" == "not_updated_calendar"    CHECK SCHEDULE NOT SYNCHRONIZED IN HMI
    ...    ELSE    FAIL    Profile "${profile}" doesn't exist

CHECK THE HVAC SETTINGS ON HMI FOR SW400
    [Arguments]    ${profile}
    LAUNCH APP APPIUM    EvMenu
    APPIUM_TAP_XPATH    ${program}
    Sleep    1

    Run Keyword If    "${profile}" == "one_calendar"    ONE CALENDAR
    ...    ELSE IF    "${profile}" == "two_calendars"    TWO CALENDARS
    ...    ELSE IF    "${profile}" == "two_calendars_from_MyR"    TWO CALENDARS FROM MYR
    ...    ELSE IF    "${profile}" == "not_updated_calendar"    CHECK SCHEDULE NOT SYNCHRONIZED IN HMI
    ...    ELSE    FAIL    Profile "${profile}" doesn't exist


CHECK MAPS VERSION AND GOOGLE ASSISTANT VERSION
    [Arguments]    ${Map_Version}=${NONE}   ${GAS_Version}=${NONE}
    [Documentation]    == High Level Description: ==
    ...    Function will get two argument {Map_Version & GA_Version} or none and return the Version of GMAP & GA of IVI on Robot log
    ...    == Parameters: ==
    ...    - Map_Version: Version of Gmap on IVI (Example: 22.10.260001.E)
    ...    - GAS_Version: Version of GA on IVI (Example: 13.0.380.RC04)
    ...    == Expected Results: ==
    ...    output: Maps and Google assistant app version is validated
    LAUNCH APP APPIUM    AppsMenu
    APPIUM_WAIT_FOR_XPATH    ${car_settings['GA_app_name']}    direction=down    scroll_tries=20
    LONG PRESS ELEMENT APPIUM    ${car_settings['GA_app_name']}
    TAP_ON_ELEMENT_USING_ID    ${car_settings['app_information']}    20
    ${GASVersionText} =    APPIUM_GET_TEXT_USING_XPATH    ${car_settings['app_ver_text']}
    APPIUM_TAP_XPATH    ${back_button}
    APPIUM_WAIT_FOR_XPATH    ${car_settings['map_app_name']}    direction=down    scroll_tries=20
    LONG PRESS ELEMENT APPIUM    ${car_settings['map_app_name']}
    TAP_ON_ELEMENT_USING_ID    ${car_settings['app_information']}    20
    ${MAPVersionText} =    APPIUM_GET_TEXT_USING_XPATH    ${car_settings['app_ver_text']}
    APPIUM_TAP_XPATH    ${back_button}
    IF    '${Map_Version}' == '${None}' or '${GAS_Version}' == '${None}'
        Return From Keyword    True
    ELSE IF    '${Map_Version}' in '${MAPVersionText}' and '${GAS_Version}' in '${GASVersionText}'
        Return From Keyword    True
    ELSE
        Return From Keyword    False
    END

GET ADMIN USER NAME
    [Documentation]    == Get admin profile name==
    APPIUM LAUNCH USER MANAGEMENT
    IF    '${ivi_my_feature_id}' == 'MyF1' or '${ivi_my_feature_id}' == 'MyF2'
        ${settings_icon} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['admin_str']}    20
        Run Keyword If    "${settings_icon}" == "False"    TAP_ON_ELEMENT_USING_ID    ${User_profile['profile_back']}    20
    END
    ${admin_name} =    APPIUM_GET_TEXT_USING_XPATH    ${User_profile['admin_profile_name']}
    [Return]    ${admin_name}

GET IVI PART AUTHENTICATION STATUS FOR MyF3
    [Arguments]    ${status}
    [Documentation]    Get part authentification status to either and compare with status
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pa_helper 6 get
    Should Be True    "PASTATE_SUCCESS" in """${output}""" or "PASTATE_UNINITIALIZED" in """${output}"""    part authentification status is empty or not correct
    ${pa_reset_status} =    Set Variable If    "${status}"=="pa_done"    PASTATE_SUCCESS    PASTATE_UNINITIALIZED
    ${pa_check_status_verify} =    Run Keyword And Return Status    Should Be True    "${pa_reset_status}" in """${output}"""    WRONG PA STATUS => ${\n}${output}
    [Return]    ${pa_check_status_verify}

CHECKSET FACTORY MODE
   [Arguments]    ${mode}
   [Documentation]   Change factory mode to ${mode} and it can be set normal/static mode
   IF    "${mode}" not in "${standard_factory_modes}"
       Log    Please provide right factory mode normal/static1
       Fail
   END
   ${mode_value} =    Set Variable If  "${mode}" == "normal"    0    1
   ${factory_mode_output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell getprop ro.boot.factorymode
   Return From Keyword If    "${mode_value}" in "${factory_mode_output}"
   IF    "${mode}" != "static1"
       OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb Configuration set display_config/display/touch_and_screen_configuration:1
       OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb WriteDID DEF0 00
   END
   ${mode_type} =    Set Variable If  "${mode}" != "static1"    NORMAL    STATIC1
   OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb setBootMode ${mode_type}
   DO REBOOT    ${target_id}    command line
   WAIT FOR ADB DEVICE    120

GET NOTIFICATION TEXT AND ENTER
    [Arguments]    ${Searchtext}    ${accept_terms}="True"
    [Documentation]    == Get admin profile name==
    ${physical_screen_size} =    GET PHYSICAL SCREEN SIZE    ${ivi_adb_id}
    @{width} =    SPLIT STRING    ${physical_screen_size}    x
    ${temp} =    Get From List    ${width}    0
    ${temp1} =    Get From List    ${width}    1
    ${xvalue} =    Convert To Integer    ${temp}
    ${yvalue} =    Convert To Integer    ${temp1}
    ${xtap} =    Evaluate    ${xvalue}/2
    ${ytap} =    Evaluate    ${yvalue}/2
    ${yext} =    Evaluate    ${ytap}+200
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    expand
    Should Be True    ${verdict}
    Sleep    5s
    FOR    ${i}    IN RANGE    0    10
        Sleep    1s
        ${term} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${Searchtext}']    retries=10    direction=down    scroll_tries=5
        Sleep    3s
        SWIPE BY COORDINATES    ${xtap}    ${yext}    ${xtap}    ${ytap}    500
        Sleep    3s
        Run Keyword If     "${term}"=="True"    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${Searchtext}']    30
        Exit For Loop If    "${term}" == "True"
        ${clearbtn} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Clear all']    10
        Exit For Loop If    "${clearbtn}" == "True"
    END
    Sleep    5
    IF    "${Searchtext}" == "View terms and data settings" and "${accept_terms}" == "True"
        TAP_ON_ELEMENT_USING_ID    ${User_profile['google_terms_accept']}    30
        ${next_btn} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['next_button']}   10
        Run Keyword If    "${next_btn}" == "True"    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['next_button']}    30
    END

SET UP GOOGLE ACCOUNT IN SUW
    [Arguments]    ${email_id}    ${password}
    [Documentation]    == High Level Description: ==
    ...     This KW is used to set google account in set up wizard page
    APPIUM_WAIT_FOR_XPATH    ${User_profile['suw_gbutton']}    direction=down    scroll_tries=12    from_xpath_element=//*[@text="Activate the data plan"]
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['suw_gbutton']}    20
    APPIUM_WAIT_FOR_XPATH    ${User_profile['google_sign_in']}    20
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['google_sign_in']}    20
    Sleep   30
    APPIUM_WAIT_FOR_XPATH    ${User_profile['edit_google_mail']}    20
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['edit_google_mail']}    ${email_id}
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['gmap_next']}    20
    Sleep    30
    APPIUM_WAIT_FOR_XPATH    ${User_profile['edit_google_password']}    20
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['edit_google_password']}    ${password}
    Sleep    2
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['gmap_next']}    20
    Sleep    7
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['gmap_next']}    20
    Sleep    7
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['gmap_next']}    20
    Sleep    7
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['suw_agree']}    20
    Sleep    10
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['skip_element']}    20
    Sleep    40
    ${fin_btn} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['finished_for_now_button']}   20
    Run Keyword If    "${fin_btn}" == "True"    APPIUM_TAP_XPATH    ${User_profile['finished_for_now_button']}    retries=20
    Sleep    10

DO HMI SETTINGS FOR GRANULAR PRIVACY
    [Documentation]    Create new profile with name and set granular privacy settings
    ADD NEW USER PROFILE
    ${ed_btn} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['later_custom_sharing']}    20
    Run Keyword If    "${ed_btn}" == "True"    APPIUM_TAP_XPATH    ${car_settings['later_custom_sharing']}

SET CUSTOM GRANULAR DATA PRIVACY MOBILE APP AND CS
    [Arguments]    ${data_remotes}=${None}    ${find_car}=${None}    ${services_data_location}=${None}
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and activate the custom data collection
    ...    == Parameters: ==
    ...    - _state_: on, off
    ...    == Expected Results: ==
    ...    Pass if executed
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10    down    20    5
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${edit_profile}
    APPIUM_TAP_XPATH    ${car_settings['data_custom_sharing']}
    GET STATE CUSTOM GRANULAR PRIVACY MOBILE APP AND CS
    IF    "${find_car}".lower() == "on" and "${ret_find_car}".lower() == "false" or "${find_car}".lower() == "off" and "${ret_find_car}".lower() == "true"    APPIUM_TAP_XPATH    ${car_settings['switch_data_find_my_car']}
    IF    "${data_remotes}".lower() == "on" and "${ret_remote_access}".lower() == "false" or "${data_remotes}".lower() == "off" and "${ret_remote_access}".lower() == "true"    APPIUM_TAP_XPATH    ${car_settings['switch_data_remotes']}
    IF    "${services_data_location}".lower() == "on" and "${ret_connected_services}".lower() == "false" or "${services_data_location}".lower() == "off" and "${ret_connected_services}".lower() == "true"    APPIUM_TAP_XPATH    ${car_settings['switch_connected_services']}
    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}
    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}

SET CUSTOM GRANULAR DATA PRIVACY ANALYTICS
    [Arguments]    ${analitics_renault}=${None}    ${analitics_partners}=${None}
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and activate the custom data collection
    ...    == Parameters: ==
    ...    - _state_: on, off
    ...    == Expected Results: ==
    ...    Pass if executed
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10    down    20    5
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${edit_profile}
    APPIUM_TAP_XPATH    ${car_settings['data_custom_sharing']}
    GET STATE CUSTOM GRANULAR PRIVACY ANALYTICS
    IF    "${analitics_renault}".lower() == "on" and "${ret_analitics_renault}".lower() == "false" or "${analitics_renault}".lower() == "off" and "${ret_analitics_renault}".lower() == "true"    APPIUM_TAP_XPATH    ${car_settings['switch_analytics_renault']}
    IF    "${analitics_partners}".lower() == "on" and "${ret_analitics_partners}".lower() == "false" or "${analitics_partners}".lower() == "off" and "${ret_analitics_partners}".lower() == "true"    APPIUM_TAP_XPATH    ${car_settings['switch_analytics_partners']}
    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}
    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}

GET STATE CUSTOM GRANULAR PRIVACY MOBILE APP AND CS
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and get the custom data collection for mobile data and connected services
    ...    == Expected Results: ==
    ...    Pass if state retuned
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['connected_services_tab']}    10    down    30    5
    @{Activation_Status} =    Create List
    @{states} =    APPIUM_GET_ELEMENTS_BY_CLASS    android.widget.Switch
    ${length} =    Get Length    ${states}
    ${length} =    Evaluate    ${length} + 3
    FOR    ${i}    IN RANGE    2    ${length}
        ${text_retrieved} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //android.widget.FrameLayout/android.view.ViewGroup/androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.Switch    checked
        Append To List    ${Activation_Status}    ${text_retrieved}
    END
    ${ret_remote_access} =     Get From List    ${Activation_Status}    0
    ${ret_find_car} =     Get From List    ${Activation_Status}    1
    ${ret_connected_services} =     Get From List    ${Activation_Status}    3
    Set Test Variable    ${ret_find_car}
    Set Test Variable    ${ret_remote_access}
    Set Test Variable    ${ret_connected_services}


GET STATE CUSTOM GRANULAR PRIVACY ANALYTICS
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and get the custom data collection for analytics
    ...    == Expected Results: ==
    ...    Pass if state retuned
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['analytics_tab']}    10    down    300    5
    @{Activation_Status} =    Create List
    @{states} =    APPIUM_GET_ELEMENTS_BY_CLASS    android.widget.Switch
    ${length} =    Get Length    ${states}
    ${length} =    Evaluate    ${length} + 3
    FOR    ${i}    IN RANGE    2    ${length}
        ${text_retrieved} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //android.widget.FrameLayout/android.view.ViewGroup/androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[${i}]/android.widget.Switch    checked
        Append To List    ${Activation_Status}    ${text_retrieved}
    END
    ${ret_analitics_renault} =     Get From List   ${Activation_Status}    2
    ${ret_analitics_partners} =     Get From List    ${Activation_Status}    3
    Set Test Variable    ${ret_analitics_renault}
    Set Test Variable    ${ret_analitics_partners}

CHECK CUSTOM GRANULAR PRIVACY
    [Arguments]    ${data_remotes}=${None}    ${find_car}=${None}    ${services_data_location}=${None}    ${analitics_renault}=${None}    ${analitics_partners}=${None}
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and activate the custom data collection
    ...    == Parameters: ==
    ...    - _state_: on, off
    ...    == Expected Results: ==
    ...    Pass if state is as expected
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${edit_profile}    10    down    20    5
    Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH    ${edit_profile}
    APPIUM_TAP_XPATH    ${car_settings['data_custom_sharing']}
    GET STATE CUSTOM GRANULAR PRIVACY MOBILE APP AND CS
    GET STATE CUSTOM GRANULAR PRIVACY ANALYTICS
    IF    "${find_car}" != "${None}"    Should Be Equal As Strings    ${find_car}    ${ret_find_car}
    IF    "${data_remotes}" != "${None}"    Should Be Equal As Strings    ${data_remotes}    ${ret_remote_access}
    IF    "${services_data_location}" != "${None}"    Should Be Equal As Strings    ${services_data_location}    ${ret_connected_services}
    IF    "${analitics_renault}" != "${None}"    Should Be Equal As Strings    ${analitics_renault}    ${ret_analitics_renault}
    IF    "${analitics_partners}" != "${None}"    Should Be Equal As Strings    ${analitics_partners}    ${ret_analitics_partners}
    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}
    APPIUM_TAP_XPATH    ${car_settings['back_privacy_settings']}

SWITCH IVI PROFILE
    [Arguments]    ${profile_to_switch}
    [Documentation]    == High Level Description: ==
    ...    Through IVI HMI, go in profile menu and activate the custom data collection
    ...    == Parameters: ==
    ...    - _state_: on, off
    ...    == Expected Results: ==
    ...    Pass if state is as expected
    LAUNCH APP APPIUM    ProfileSettings
    Sleep    2
    APPIUM_TAP_XPATH    ${profile_to_switch}
    Sleep    60
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER

CHECKSET IVI MYRNAULT ACCOUNT PAIRING
  [Arguments]    ${myr_username}    ${myr_password}
   [Documentation]    == High Level Description: ==
   ...    Through IVI HMI, go in myr account pairing menu and pair the vehicle with a MYR account if it's not already
   ...    == Parameters: ==
   ...    - _myr_username_: username of the MYR account created
   ...    - _myr_password_: password of the MYR account created
   ...    == Expected Results: ==
   ...    Pass if vehicle it's paired
   APPIUM LAUNCH USER MANAGEMENT
   APPIUM_TAP_XPATH    ${User_profile['myr_profile_dom']}
   ${verdict} =    APPIUM_WAIT_FOR_XPATH    ${User_profile['myr_account']}    20
   IF    ${verdict}==False
       DO IVI ADD MYRENAULT ACCOUNT    ${myr_username}    ${myr_password}
   ELSE
       Log    Vehicle already paired with MYR account
   END
