#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     HMI keywords library
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.UserProfilLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ServiceLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ReliabilityCommonLib    device=${ivi_adb_id}
Library           rfw_libraries.text_to_speech.TextToSpeech
Library           Collections
Library           String
Library           DateTime
Resource          ${CURDIR}/appium_hlks.robot
Resource          ${CURDIR}/image.robot
Variables         ${CURDIR}/KeyCodes.yaml
Variables         ${CURDIR}/hmi_info_ivi_android_10.yaml
Variables         ${CURDIR}/hmi_info_ivi_android_12.yaml
Variables         ${CURDIR}/app_info_ivi_android_10.yaml
Variables         ${CURDIR}/app_info_ivi_android_12.yaml
Variables         ${CURDIR}/../unsorted/on_board_ids.yaml

*** Variables ***
${console_logs}    yes
${app_to_launch}    com.android.car.settings/.Settings
${search_app}     Search
${virtual_keyboard_id}    layout_results
${apps}           Apps & notifications
${see_all_apps}    See all 33 apps
${search_apps_dialog}    Search settings
${download_url}    loire/sharing/vehicle_configs/
${hdmi_value}    00000000000000000000000000000000000000000000000000000000100000000000000000000000
${session}       extended
${language_selection_icon}    //*[@resource-id='android:id/icon']
${english}    //*[@text='English' or @text='English (United Kingdom)' or @text='English (United States)']
${begin}    //*[@text='Begin']
${activate}    //*[@text='Activate']
${ok_button}    //*[@text='OK' or @text='Pair']
${accept}    //*[@text='Accept' or @text='Confirm' or @text='ACCEPT']
${share}    //*[@text='Share' or @text='Accept and benefit from services' or @text='Share data and position' or @text='Share data + geolocalisation']
${dont_share}    //*[@text='Refuse' or @text='Refuse sharing']
${more_button}            //*[@text='MORE' or @text='More']
${network1_button}    //*[@text='Network and internet']
${network2_button}    //*[@text='Network & internet']
${wifi_button}    //*[@text='Wi‑Fi']
${off_button}    //*[@resource-id='com.android.car.settings:id/master_switch']
${back_button}    //*[@resource-id='com.android.car.settings:id/car_ui_toolbar_nav_icon']
${connect_bluetooth}    //*[@text='Connect phone with Bluetooth']
${refresh}    //*[@text='Refresh']
${done_for_now}    //*[@text='Done for now' or @text='Done']
${not_connected_MyR}    //*[@text='Your vehicle is not connected to MY Renault.']
${finished_for_now}    //*[@text='Finished for now' or @text='Done for now' or @text='Done']
${google_signin_button}    //*[@text='Set up Google Assistant and apps']
${sign_in_on_car_scree_button}    //*[@text='Sign in on car screen']
${profile_lock}    //*[@text='Profile lock']
${lock_option}    //*[@text='Lock options']
${page_down}    //*[@resource-id='com.google.android.car.setupwizard:id/page_down']
${password_button}    //*[@text='Password']
${continue}    //*[@text='Continue']
${confirm}    //*[@text='Confirm']
${security}    //*[@text='Profile protection']
${choose_lock_button}    //*[@text='Choose a lock type']
${password_entry}    //*[@resource-id='com.android.car.settings:id/password_entry' or  @resource-id='com.google.android.car.setupwizard:id/password_entry']
${primary_toolbar_button}    //*[@resource-id='com.google.android.car.setupwizard:id/primary_toolbar_button' or @resource-id='com.android.car.settings:id/key_enter']
${none_button}    //*[@text='None']
${remove}    //*[@text='REMOVE' or @text='Remove']
${enter_gmail_button}    //*[@resource-id='identifierId']
${enter_gmail_pass_button}    //*[@class='android.widget.EditText']
${next}    //*[@text='Next']
${turn_on}    //*[@text='Turn on']
${back}    //*[@resource-id='com.google.android.car.setupwizard:id/back_button']
${notification}        //*[@text='Profile setup isn’t finished' or @text='Profile setup isn’t done']
${battery_settings}    //*[@text='Battery Settings']
${battery}    //*[@text='Battery']
${outside}     //*[@resource-id='com.renault.cabincontrol:id/outsideAirQualityValueTextView']
${incoming}    //*[@resource-id='com.renault.cabincontrol:id/insideAirQualityValueTextView']
${trip}          //*[@text='Trip']
${trip_value}    //*[@text='409.0 Km|20.0 Km/h'or @text='409.0' or @text='409.0 Km | 20.0 Km/h'or @text='409.0Km|20.0Km/h'or @text='409.0Km | 20.0Km/h' ]
${skip}    //*[@text='Skip']
${wifi_onoff_button}    //*[@resource-id='com.android.car.settings:id/car_ui_toolbar_menu_item_switch']
${Bluetooth_devices}      //*[@text='Connected devices']
${conn_pref}              //*[@text='Connection preferences']
${add_user}    //*[@resource-id='com.renault.profilesettingscenter:id/image_add_user' or @resource-id='com.renault.car.settings:id/add_user_image']
${edit_profile}    //*[@text='Edit profile']
${Name}   //*[@text='Name']
${new}    //*[@resource-id='com.renault.profilesettingscenter:id/text_input_edit_text_user_edit_name' or @resource-id='com.renault.car.settings:id/text_input_edit_text_user_edit_name']
${ok}    ok.png
${enter}    ENTER.png
${Profile_protection}    //*[@text='Profile protection' or @text='Security']
${Choose_a_lock_type}    //*[@text='Choose a lock type']   
${pass}    com.android.car.settings:id/password_entry
${Continue}    //*[@text='Continue']
${Confirm}    //*[@text='Confirm']
${enter_key}    //*[@resource-id='com.android.car.settings:id/key_enter]
${econav_on_button}    //*[@resource-id='com.alliance.car.kitchensink:id/switch_econav' and @checked='true']
${econav_off_button}    //*[@resource-id='com.alliance.car.kitchensink:id/switch_econav' and @checked='false']
${econav_on_off}    //*[@resource-id='com.alliance.car.kitchensink:id/switch_econav']
${English UK}    //*[@text='English (United Kingdom)']
${new_user}    //*[@text='User1'] 
${Settings_profil}    Settings_profil.png
${accept_all}         //*[@text='Accept all']
${current_volume}    //*[@text='Volume']/..//*[@resource-id='android:id/summary' or @resource-id='com.renault.driveassist:id/seekbar_value']
${volume_scroll_bar}    //*[@resource-id='com.renault.driveassist:id/seekbar' or @resource-id='com.renault.car.driveassist:id/seekbar']
@{objects_names_in_image}    avatar

*** Keywords ***
CHECK HMI CONTENTS
    [Arguments]    ${searchtext}
    [Documentation]    CHECK HMI CONTENTS
    ...    checks if ${searchtext} is present on the screen
    Log To Console    Checks if ${searchtext} is present on the screen
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${searchtext}']
    ${result_1} =   Run Keyword If    "${result}" == "${False}"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${searchtext}']    direction=down    scroll_tries=10
    Run Keyword If    "${result}" == "${False}"    Should Be True    ${result_1}
    ...    ELSE    Should Be True    ${result}

DO HMI OPEN APPS LIST
    [Arguments]    ${target_id}
    [Documentation]    DO HMI OPEN APPS LIST
    ...    arguments ${target_id}
    ...    opens settings and tap on ${apps}
    LAUNCH APP APPIUM    Settings
    ${res} =    SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='Apps and notifications']    direction=down
    Should Be True    ${res}
    TAP BY XPATH    //*[@text='Apps and notifications']
    APPIUM_TAP_XPATH    //*[@text='Show all apps']

SET OPEN SETTINGS
    [Arguments]    ${target_id}
    [Documentation]    Open settings UI of ${target_id} and check that it is correctly displayed
    ${ret_code} =        LAUNCH APP APPIUM    Settings
    Should Be True     ${ret_code}    Failed to launch 'Settings' menu
    ${status} =    APPIUM_WAIT_FOR_XPATH   //*[@text='Settings']
    Should Be True    ${status}    status_launch_settings' dialog not present

CHECK VIRTUAL KEYBOARD
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check virtual keyboard status
    ${dumpsys_window} =     CHECK VIRTUAL KEYBOARD STATUS
    Run Keyword If    "${status}" == "present"    Should Be True    ${dumpsys_window}    Virtual Keyboard wanted but not found
    Run Keyword If    "${status}" == "not_present"    Should Not Be True    ${dumpsys_window}    Virtual Keyboard unwanted but found

DO HMI TAP ACTION APPIUM
    [Arguments]    ${msg}    ${type}
    APPIUM_TAP_XPATH    //*[@${type}='${msg}']

GET TEXT AND CHECK APPIUM
    [Arguments]    ${type}    ${msg}    ${output}
    [Documentation]    To get Text by using Xpath and check output
    ...    ${type}      Type of element id ex: text, resource-id, content-desc etc..
    ...    ${msg}       name of the element id
    ...    ${output}    text to check on ${ivi_adb_id}
    ${result} =    APPIUM_GET_TEXT_USING_XPATH   //*[@${type}='${msg}']
    Should Contain    ${result}    ${output}    ${output} not present in current screen of ${ivi_adb_id}

CHECKSET TIME AUTO UPDATE
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check and set the Automatic Date and Time
    ...    ${target_id}: name of target_id
    ...    ${status}: Status of the feature, on/off
    ${status_auto} =    CHECK AUTO TIME STATUS    ${status}
    Run Keyword If    "${status_auto}"=="True"    Log To Console    Auto_date_time is already in ${status}
    Run Keyword If    "${status_auto}"=="False"    TIME AUTO UPDATE    ${status}
    ${result} =    CHECK AUTO TIME STATUS    ${status}
    Should Be True    ${result}    Failed to enable Auto Time settings

BYPASS WIZARD PAGE
    [Arguments]    ${target_id}
    [Documentation]    To remove the wizard menu displayed after the 1st boot
    ...    ${target_id}: name of target_id
    BYPASS WIZARD MENU

SET ALLIANCE KITCHEN SINK CONNECTIVITY
    [Arguments]    ${dut_id}    ${connectivity_type}
    [Documentation]    To set the connectivty in alliance kitchen sink
    ...    ${dut_id} name of dut-id
    ...    ${connectivity_type}    connectivity type in alliance kitchen sink
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    10s
    APPIUM_TAP_XPATH    //*[@content-desc='AllianceKitchenSink' or @content-desc='Open drawer']
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='CONNECTIVITY']    direction=down    scroll_tries=25
    APPIUM_TAP_XPATH    //*[@text='CONNECTIVITY']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/spinner_actions']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/spinner_actions']
    APPIUM_TAP_XPATH    //*[@text='${connectivity_type}()']

CHECK ALLIANCE KITCHEN SINK CONNECTIVITY
    [Arguments]    ${dut_id}    ${connectivity_type}    ${status}
    [Documentation]    To check the connectivty in alliance kitchen sink
    ...    ${dut_id} name of dut-id
    ...    ${connectivity_type}    connectivity type in alliance kitchen sink
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${connectivity_type}() is ${status} ']    retries=20
    Run Keyword If    "${result}" == "${True}"        DO HMI TAP ACTION APPIUM    Clear    text

SET ALLIANCE KITCHEN SINK DATA PRIVACY
    [Arguments]    ${target_id}    ${privacy_mode}
    [Documentation]    To set the data privacy mode on IVI
    ...    ${target_id}    device under test ivi2
    ...    ${privacy_mode}    data privacy mode in alliance kitchen sink
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    10s
    APPIUM_TAP_XPATH    //*[@content-desc='Open drawer']
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='DataPrivacy']    direction=down    scroll_tries=25
    APPIUM_TAP_XPATH    //*[@text='DataPrivacy']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Privacy Mode = ${privacy_mode}']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Privacy Mode = ${privacy_mode}']

DO HMI LANGUAGE SELECTION APPIUM
    [Arguments]    ${target_id}    ${language}
    Log To Console    Change language to ${language} on target_id: ${target_id}
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    LAUNCH APP APPIUM    Settings
    ${ret_code} =    START INTENT    -a android.settings.LOCALE_SETTINGS
    Should Be Equal    ${ret_code}    ${0}
    SLEEP    8
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${language}']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"    ${language} is not found.
    APPIUM_TAP_XPATH    //*[@text='${language}']
    Return From Keyword If    "${language}" != "English"
    ${result} =   APPIUM_WAIT_FOR_XPATH     //*[@text='English (United Kingdom)']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"       
    APPIUM_TAP_XPATH    //*[@text='English (United Kingdom)']   

CREATE NEW USER TO LAUNCH SETUP WIZARD
    [Arguments]    ${new_user}    ${target_id}
    [Documentation]    Create and switch to new_user: ${new_user} on target_id: ${target_id}
    Log To Console    Creating and switching to new_user: ${new_user} on target_id: ${target_id}
    ${output}    ${error} =    rfw_services.ivi.UserProfilLib.create_user    ${new_user}
    Should Contain    ${output}    Success: created user id
    ${user_id} =    Get Sub String     ${output}    27   -3
    DO WAIT    5000
    SET GRANT ADMIN PERMISSION APPIUM    ${target_id}    ${new_user}    ${True}
    REMOVE APPIUM DRIVER
    ${output}    ${error} =    rfw_services.ivi.UserProfilLib.switch_to_user    ${user_id}
    Sleep    50    reason=Waiting for 50s for the user account to be switched and the SUW screen to be displayed
    CREATE APPIUM DRIVER    SetupWizard

CREATE NEW USER AND LAUNCH SETUP WIZARD
    [Arguments]    ${new_user}    ${target_id}    ${data_sharing}    ${after_factory_reset}    ${after_flashed_IVI}=False
    [Documentation]    This user creation is a workaround to resolve CCSEXT-90971.
    IF    "${after_flashed_IVI}" == "False"
        LAUNCH APP APPIUM    ProfileSettings
        DO WAIT    5000
        APPIUM_TAP_XPATH    ${add_user}    retries=20
        APPIUM_TAP_XPATH    ${ok_button}    retries=20
        DO WAIT    8000
    END
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER    SetupWizardOverlay
    RECONFIRM DATA PRIVACY
    IF    "${ivi_my_feature_id}" == "MyF3"
       SET SETUP WIZARD A12    ${data_sharing}    ${after_factory_reset}
    ELSE
        SET SETUP WIZARD A10    ${data_sharing}    ${after_factory_reset}
    END
    Sleep    2
    APPIUM_TAP_XPATH    ${finished_for_now}
    GO HOME SCREEN APPIUM
    LAUNCH APP APPIUM    ProfileSettings
    ${edit_profile_present} =   APPIUM_WAIT_FOR_XPATH    ${edit_profile}    retries=20
    Run Keyword If    "${edit_profile_present}"=="True"    APPIUM_TAP_XPATH    ${edit_profile}
    APPIUM_TAP_XPATH    ${Name}    retries=20
    APPIUM_TAP_XPATH    ${new}
    APPIUM_ENTER_TEXT_XPATH    ${new}    ${new_user}
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${img_name}    ${CURDIR}
    Should Be True    ${verdict}    Failed to download '${download_url_image}${img_name}' from artifactory
    TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}
    GO HOME SCREEN APPIUM

SET SETUP WIZARD A10
    [Arguments]    ${data_sharing}=ON    ${after_factory_reset}=False
    [Documentation]    Perform setup wizard process on the newly created user
    ...    ${data_sharing}: ON / OFF. ON for sharing and OFF for not sharing
    Sleep    15
    CREATE APPIUM DRIVER    SetupWizard
    IF    "${after_factory_reset}" == "True"
        APPIUM_TAP_XPATH    ${language_selection_icon}
        Sleep    5
        SCROLL TO EXACT ELEMENT    element_id_or_xpath=${english}    direction=down
        APPIUM_TAP_XPATH    ${english}    retries=20
        Sleep    5
        SCROLL TO EXACT ELEMENT    element_id_or_xpath=${english}    direction=down
        APPIUM_TAP_XPATH    ${english}    retries=20
        Sleep    5
    END
    APPIUM_TAP_XPATH    ${begin}    retries=20
    Sleep    5
    ${suw_first_screen} =   APPIUM_WAIT_FOR_XPATH    ${begin}
    Should Not Be True    ${suw_first_screen}    Failure due to bug: CCSEXT-90971
    ${tap_activate} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Activate the connectivity of your vehicle' or @text='Activate']    retries=20
    Run Keyword If    "${tap_activate}" == "${True}"    APPIUM_TAP_XPATH    ${activate}    retries=20
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${ok_button}    retries=20
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${skip}
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${skip}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${activate}    retries=20
    Run Keyword If    "${result}" == "${True}"    Run Keywords    APPIUM_TAP_XPATH    ${activate}    retries=20
    ...    AND    Sleep    2
    ...    AND    APPIUM_TAP_XPATH    ${ok_button}    retries=20
    ${share_status} =    Set Variable If    "${data_sharing}"=="ON"    ${share}    ${dont_share}
    ${result} =    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${share_status}    direction=down
    Should Be True    ${result}    Element with xpath: ${share_status} not found
    APPIUM_TAP_XPATH    ${share_status}
    ${result} =    SCROLL TO EXACT ELEMENT    element_id_or_xpath=${accept}    direction=down
    Should Be True    ${result}    Element with xpath: ${accept} not found
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${accept}
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${accept}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${activate}
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${activate}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${skip}
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${skip}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${next}
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    ${next}
    Return From Keyword If    "${ivi_platform_type}" != "aivi2_full"
    APPIUM_TAP_XPATH    ${accept}    retries=20
    ${tap_next} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Enhance the ride with apps' or @text='Next']
    Run Keyword If    "${tap_next}"=="True"    APPIUM_TAP_XPATH    ${next}    retries=20
    Sleep    3

DO SKIP SETUP WIZARD
    [Arguments]    ${dut_id}    ${data_sharing}=ON    ${after_factory_reset}=False
    [Documentation]    To skip the wizard menu displayed after Factory reset
    ...    ${dut_id}: name of target_id
    REMOVE APPIUM DRIVER
    IF    "${ivi_my_feature_id}" == "MyF3"
       SET SETUP WIZARD A12    ${data_sharing}    ${after_factory_reset}
    ELSE
        SET SETUP WIZARD A10    ${data_sharing}    ${after_factory_reset}
    END
    Sleep    2
    APPIUM_TAP_XPATH    ${finished_for_now}

SET_IVI_SECURITY_LOCK_SETUP
    [Arguments]    ${password}    ${lock_options}
    [Documentation]    To set security lock in setup wizard screen.
    ...    ${lock_options}: Lock option to select either PIN or Password
    ...    ${password}: Password to enter
    LAUNCH APP APPIUM    ProfileSettings
    APPIUM_TAP_XPATH    ${Edit_profile}    retries=20
    APPIUM_TAP_XPATH    ${Profile_protection}    retries=20
    APPIUM_TAP_XPATH    ${Choose_a_lock_type}    retries=20
    APPIUM_TAP_XPATH    ${lock_options}    retries=20
    APPIUM_ENTER_TEXT    ${pass}    ${password}
    APPIUM_TAP_XPATH    ${Continue}    retries=20
    APPIUM_ENTER_TEXT    ${pass}    ${password}
    APPIUM_TAP_XPATH    ${Confirm}    retries=20

SET SETUP WIZARD PIN
    [Arguments]    ${pin_password_value}
    [Documentation]    To set security lock pin in IVI.
    ...    ${pin_password_value}: Password to enter
    APPIUM_TAP_XPATH    ${password_entry}

    ${value}=    Convert To list    ${pin_password_value}
    FOR  ${pin}   IN    @{value}
        SLEEP    2
        APPIUM_TAP_XPATH    //*[@text='${pin}']
    END
    APPIUM_TAP_XPATH    ${primary_toolbar_button}

SET SETUP WIZARD PASSWORD
    [Arguments]    ${pin_password_value}
    [Documentation]    To set security lock password in IVI.
    ...    ${pin_password_value}: Password to enter
    APPIUM_ENTER_TEXT_XPATH    ${password_entry}    ${pin_password_value}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${continue}
    RUN KEYWORD IF    '${result}' == 'True'     APPIUM_TAP_XPATH    ${continue}
    ...    ELSE    APPIUM_TAP_XPATH    ${confirm}

CHECK IVI SECURITY LOCK
    [Arguments]    ${dut_id}    ${option}
    [Documentation]    To remove security lock in IVI.
    ...    ${target_id}: name of target_id
    ...    ${option}: Enable/Disable of security lock
    START INTENT    ${app_to_launch}
    APPIUM_TAP_XPATH    ${more_button}

    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${security}    direction=down
    APPIUM_TAP_XPATH    ${security}

    APPIUM_TAP_XPATH    ${choose_lock_button}

    ${output} =   APPIUM_WAIT_FOR_XPATH    ${password_entry}
    Run keyword if    "${option}" == "Enable"    should be true    ${output}
    ...    ELSE IF    "${option}" == "Disable"    should not be true    ${output}
    ...    ELSE    Log To Console    please enter valid input(Enable/Disable)

DO REMOVE IVI SECURITY LOCK
    [Arguments]    ${dut_id}    ${lock_options}    ${pin_password_value}
    [Documentation]    To remove security lock in IVI.
    ...    ${target_id}: name of target_id
    ...    ${lock_options}: Lock option to select either PIN or Password
    ...    ${pin_password_value}: Password to enter
    sleep     20
    START INTENT    ${app_to_launch}

    SLEEP    5
    APPIUM_TAP_XPATH    ${more_button}

    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=${security}    direction=down
    APPIUM_TAP_XPATH    ${security}

    APPIUM_TAP_XPATH    ${choose_lock_button}
    SLEEP    2
    APPIUM_TAP_XPATH    ${password_entry}
    SLEEP    2
    Run Keyword If    "${lock_options}"=="PIN"    SET SETUP WIZARD PIN    ${pin_password_value}
    ...    ELSE    APPIUM_ENTER_TEXT_XPATH    ${password_entry}    ${pin_password_value}
    Sleep    3s
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${enter}    ${CURDIR}
    Should be true    ${verdict}    Failed to download '${download_url_image}${enter}' from artifactory
    TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${ok}    ${CURDIR}
    Should be true    ${verdict}    Failed to download '${download_url_image}${ok}' from artifactory
    TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}
    SLEEP    5
    APPIUM_TAP_XPATH    ${none_button}

    APPIUM_TAP_XPATH    ${remove}

    CHECK IVI SECURITY LOCK    ${dut_id}    Disable

DO IVI SETUP WIZARD PROCESS
    [Arguments]    ${dut_id}    ${Password}    ${lock_options}     ${ssid}    ${ssid_password}
    [Documentation]    Connect to bluetooth and set security lock in wizard screen.
    ...    ${dut_id}: name of target_id
    ...    ${lock_options}: Lock option to select either PIN or Password
    ...    ${pin_password_value}: Password to enter
    ...    ${ssid}: The SSID/Name of the AP/Hotspot to be connected
    ...    ${ssid_password}: The password for the AP/Hotspot

    SET_IVI_SECURITY_LOCK_SETUP    ${Password}    ${lock_options}    
    APPIUM_PRESS_KEYCODE   ${KEYCODE_HOME}
    Sleep    5
    DO WIFI CONNECT APPIUM    ${dut_id}    ${ssid}    ${ssid_password}
    CHECKSET GAS REGISTRATION    ${gas_login}    ${gas_pswd}
    Sleep    5

INITIAL HMI SETUP
    [Documentation]    Verify that the initial set up has been made
    APPIUM_TAP_XPATH    ${finished_for_now}    retries=20
    Sleep    2

CREATE NEW USER
    [Arguments]    ${new_user}    ${target_id}
    [Documentation]    Create and switch to new_user: ${new_user} on target_id: ${target_id}
    Log To Console    Creating and switching to new_user: ${new_user} on target_id: ${target_id}
    ${output}    ${error} =    rfw_services.ivi.UserProfilLib.create_user    ${new_user}
    Should Contain    ${output}    Success: created user id
    ${user_id} =    Get Sub String     ${output}    27   -3
    DO WAIT    5000
    ${output}    ${error} =    rfw_services.ivi.UserProfilLib.switch_to_user    ${user_id}
    DO WAIT    5000
    REMOVE APPIUM DRIVER    ${ivi_capabilities}
    DO WAIT    5000
    CREATE APPIUM DRIVER
    APPIUM_PRESS_KEYCODE   ${KEYCODE_HOME}
    DO WAIT    10000
    RECONFIRM DATA PRIVACY
    DO WAIT    10000

SET GRANT ADMIN PERMISSION APPIUM
    [Arguments]    ${target_id}    ${new_user}    ${status}
    [Documentation]    Grant admin permission to User: ${new_user} with status: ${status} on target_id: ${target_id}
    Log To Console    Granting admin permission to User: ${new_user} with status: ${status} on target_id: ${target_id}
    DO WAIT    10000
    DO CLOSE APP    ivi    ProfileSettings
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER    ProfileSettings
    DO WAIT    10000
    FOR    ${index}    IN RANGE    0    3
        ${app_status} =    LAUNCH APP APPIUM    ProfileSettings
        Exit For Loop If    "${app_status}" == "True"
        DO REBOOT    ${target_id}    command line
        WAIT FOR ADB DEVICE    120
        CHECK IVI BOOT COMPLETED    booted    120
        DO CLOSE APP    ivi    ProfileSettings
        DO WAIT    5000
        Run Keyword If    "${index}" == "2"    Should Be True    ${app_status}    Failed to launch 'Profile User Settings'
    END
    DO WAIT    10000
    IF    "${platform_version}" == "10"
        SET GRANT ADMIN PERMISSION APPIUM A10    ${new_user}
    ELSE
        SET GRANT ADMIN PERMISSION APPIUM A12    ${new_user}
    END
    ENABLE MULTI WINDOWS
    ${final_option} =    Set Variable If    "${status}"=="${True}"    //*[@text='YES, MAKE ADMIN' or @text='Yes, make admin']    //*[@text='Cancel' or @text='CANCEL' or @text='cancel']
    APPIUM_TAP_XPATH    ${final_option} 
    DO CLOSE APP    ivi    ProfileSettings

SET GRANT ADMIN PERMISSION APPIUM A12
    [Arguments]    ${new_user}
    [Documentation]    Grant admin permission to User on A12
    ${verdict}    ${result_download} =    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url_image}${Settings_profil}    ${CURDIR}
    Should be true    ${verdict}    Failed to download '${download_url_image}${Settings_profil}' from artifactory
    TAP IF IMAGE DISPLAYED ON SCREEN    ${result_download}
    APPIUM_TAP_XPATH    //*[@text='Manage profiles']
    APPIUM_TAP_XPATH    //*[@text='Manage other profiles']
    APPIUM_TAP_XPATH    //*[@text='${new_user}']    retries=20
    APPIUM_TAP_XPATH    //*[@text='Make admin']

SET GRANT ADMIN PERMISSION APPIUM A10
    [Arguments]    ${new_user}
    [Documentation]    Grant admin permission to User on A10
    APPIUM_TAP_XPATH    //*[@resource-id='com.renault.profilesettingscenter:id/toolbar_menu_icon']
    APPIUM_TAP_XPATH    //*[@text='Manage profiles']
    APPIUM_TAP_XPATH    //*[@text='${new_user}']
    APPIUM_TAP_XPATH    //*[@text='Make admin']

SET DELETE USER
    [Arguments]    ${target_id}    ${new_user}    ${user_id}=${None}
    [Documentation]    Delete the user: ${new_user} on target_id: ${target_id}
    Log To Console    Delete the user: ${new_user} on target_id: ${target_id}
    ${user_id} =    Run Keyword If    "${user_id}"=="${None}"    rfw_services.ivi.UserProfilLib.get_user_id_by_name    ${new_user}
    ...    ELSE    Set Variable    ${user_id}
    ${output}    ${error} =    rfw_services.ivi.UserProfilLib.delete user    ${user_id}
    Should Contain    ${output}    Success: removed user
    Log    User: ${new_user} successfully deleted on target: ${target_id}    console=${True}

SET DELETE ALL USER
    [Arguments]    ${target_id}
    [Documentation]    Delete all user expect Conducteur , Guest , Admin or Chauff\\xc3\\xb8r'
    ${all_users} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pm list users
    ${all_users} =    Split String    ${all_users}    separator=\n
    ${all_users} =    Set Variable    ${all_users}[2:]
    Log List    ${all_users}
    FOR    ${user_name}    IN    @{all_users}
        ${user_name} =    Strip String    ${user_name}    characters=running
        ${user_name} =    Strip String    ${user_name}
        Continue For Loop If    'Driver' in '${user_name}' or 'Admin' in '${user_name}' or 'Conducteur' in '${user_name}' or 'Guest' in '${user_name}' or 'Chauff\\xc3\\xb8r' in '${user_name}'
        ${user_name} =    Split String    ${user_name}    :
        Log List    ${user_name}
        ${user_id} =    Split String    ${user_name}[0]    {
        SET DELETE USER    ${ivi_adb_id}    ${user_name}[1]    ${user_id}[1]
    END

DO SETUP WIZARD WIFI CONNECTION APPIUM
    [Arguments]    ${dut_id}    ${ssid}    ${ssid_password}
    [Documentation]    To connect with hotspot from setup wizard screen
    ...    ${target_id}: name of target_id
    ...    ${ssid}: The SSID/Name of the AP/Hotspot to be connected
    ...    ${ssid_password}: The password for the AP/Hotspot
    START INTENT    ${app_to_launch}
    APPIUM_TAP_XPATH    ${more_button}
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${network1_button}    retries=20
    Run Keyword And Ignore Error    APPIUM_TAP_XPATH    ${network2_button}    retries=20
    APPIUM_TAP_XPATH    ${off_button}
    APPIUM_TAP_XPATH    ${wifi_button}
    Sleep    5
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${ssid}']
    Run Keyword If    '${result}' == 'False'    APPIUM_TAP_XPATH    ${wifi_onoff_button}
    APPIUM_TAP_XPATH    //*[@text='${ssid}']
    APPIUM_TAP_XPATH    //*[@text='${ssid}']
    Sleep    2
    OperatingSystem.Run    adb -s ${dut_id} shell input text ${ssid_password}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Ok']
    ${result_forget} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Forget' or @text='FORGET']
    Run Keyword If    '${result}' == 'False'    Should Be True    ${result_forget}
    Run Keyword If    '${result}' == 'True'    APPIUM_TAP_XPATH    //*[@text='Ok']
    Sleep    2
    FOR  ${var}    IN RANGE    4
        sleep    3
        APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    END

DO SETUP WIZARD GOOGLE SIGN APPIUM
    [Arguments]    ${dut_id}
    [Documentation]    Signin to google account in setup wizard screen.
    ...    ${dut_id}: name of target_id
    START INTENT    com.android.vending
    APPIUM_TAP_XPATH    //*[@text='Sign in']        retries=20
    APPIUM_TAP_XPATH    ${sign_in_on_car_scree_button}    retries=20
    Sleep    2
    APPIUM_ENTER_TEXT_XPATH    ${enter_gmail_button}    ${gas_login}
    APPIUM_TAP_XPATH    ${next}    retries=20
    Sleep    2
    APPIUM_ENTER_TEXT_XPATH    ${enter_gmail_pass_button}    ${gas_pswd}
    APPIUM_TAP_XPATH    ${next}    retries=20
    APPIUM_TAP_XPATH    ${done_for_now}    retries=20
    ${sign_in_success} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Stay Informed']    retries=20
    Run Keyword And Return If    "${sign_in_success}" == "True"    Log To Console    Signin successful: ${gas_login}
    APPIUM_TAP_XPATH    ${accept}    retries=20
    ${sign_in_success} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Stay Informed']    retries=20
    Should Be True    ${sign_in_success}
    Log To Console    Signin successful: ${gas_login}

DO IVI SETUP WIZARD DATA SHARING APPIUM
    [Arguments]    ${data_sharing}
    [Documentation]    Perform IVI Setup Wizard for Data sharing
    ...    ${data_sharing}: ON / OFF. ON for sharing and OFF for not sharing
    Log To Console    DO IVI SETUP WIZARD DATA SHARING. Data Sharing: ${data_sharing}
    IF    "${ivi_my_feature_id}" == "MyF3"
       SET SETUP WIZARD A12    ${data_sharing}
    ELSE
        SET SETUP WIZARD A10    ${data_sharing}
    END
    APPIUM_TAP_XPATH    ${finished_for_now}

CHECK BATTERY LEVEL APPIUM
    [Arguments]    ${dut_id}    ${battery_percentage}
    LAUNCH APP APPIUM    EvMenu
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${battery}
    RUN KEYWORD IF    '${result}' == 'True'     APPIUM_TAP_XPATH    ${battery}
    ...    ELSE    APPIUM_TAP_XPATH    ${battery_settings}
    APPIUM_TAP_XPATH     ${battery_percentage}

CHECK_DEFERRED_NOTIFICATION
    [Documentation]    To Check in notification panel for the deferred notification
    Sleep    5s
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    expand
    Should Be True    ${verdict}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${notification}
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}

CHECK HMI NOTIFICATION
    [Arguments]    ${target_id}    ${notif_type}    ${notif_status}    ${notif_value}    ${app_already_open}=False
    [Documentation]    Check CHECK HMI NOTIFICATION VALUE ${notif_value} and status ${notif_status} on ${target_id}
    Log To Console    Check CHECK HMI NOTIFICATION VALUE ${notif_value} and status ${notif_status} on ${target_id}
    ${prop_name} =    Set Variable If     "${notif_type}"=="CNF_HMI_COMFORT_SeatHeatingVentilation"    HVAC_AUTO_SEAT_HEATING_VENTILATION
    ${status} =    Run Keyword If    "${app_already_open}"=="False"    LAUNCH APP APPIUM    AllianceKitchensink
    ${status} =    Run Keyword If    "${app_already_open}"=="True"    TAP BY XPATH    //*[@text='Get Property Value']
    ${status} =    Run Keyword If    "${app_already_open}"=="True"    GET TEXT    tvPropStatus
    ${value} =    Run Keyword If    "${app_already_open}"=="True"    GET TEXT    tvPropValue
    Run Keyword If    "${app_already_open}"=="True"    Should Be Equal    ${status}    ${notif_status}
    Run Keyword If    "${app_already_open}"=="True"    Should Be Equal    ${value}    ${notif_value}
    Return From Keyword If    "${app_already_open}"=="True"
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@class='android.widget.ImageButton']
    Sleep    3s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='Property']    direction=down    scroll_tries=10
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Property']
    APPIUM_TAP_XPATH    //*[@resource-id='android:id/text1']
    Sleep    2s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${prop_name}']    direction=down    from_xpath_element=//*[@resource-id='android:id/text1']    scroll_tries=50
    Should Be True    ${result}
    TAP BY XPATH    //*[@text='${prop_name}']
    APPIUM_TAP_XPATH    //*[@text='Get Property Value']
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/tvPropStatus']
    Should Be True    ${res}
    ${status} =    GET TEXT    tvPropStatus
    ${value} =    GET TEXT    tvPropValue
    Should Be Equal    ${status}    ${notif_status}
    Should Be Equal    ${value}    ${notif_value}

CHECKSET ENABLE AIR PURIFIER
    [Arguments]    ${dut_id}    ${status}
    [Documentation]    To enable/disable air purifier on ivi
    ...    ${dut_id} name of dut-id
    ...    ${status} enable/disable
    LAUNCH APP APPIUM    AirPurifier
    Sleep    2s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='To optimize the cycle, keep the windows closed']
    Run Keyword If    "${result}" == "True" and "${status}" == "enable"    log to console    air purifier is already enabled
    Run Keyword If    "${result}" == "False" and "${status}" == "enable"   SET ENABLE AIR PURIFIER
    Run Keyword If    "${result}" == "False" and "${status}" == "disable"    log to console    air purifier is already disabled
    Run Keyword If    "${result}" == "True" and "${status}" == "disable"   SET ENABLE AIR PURIFIER

SET ENABLE AIR PURIFIER
    APPIUM_TAP_XPATH    //*[@text='Air purifier']

CHECK AIRQUALITY WIDGET VALUE
    [Arguments]    ${dut_id}    ${ref_image}
    [Documentation]    To check if the image: ${ref_image} is present on the current screeen on ivi
    CHECK IMAGE DISPLAYED ON SCREEN    ${dut_id}    ${ref_image}

CHECK CABIN LEVEL VALUE
    [Arguments]    ${dut_id}    ${value_type}
    [Documentation]    To check displayed value for instant cabinlevel
    Sleep    3s
    ${text_id} =    Set Variable If    '${value_type}' == 'outside'    com.renault.cabincontrol:id/outsideAirQualityValueTextView
    ...    com.renault.cabincontrol:id/insideAirQualityValueTextView
    ${cabin_value} =    APPIUM_GET_TEXT_BY_ID    ${text_id}
    Should Be Equal    "${cabin_value}"    "<15"

LAUNCH TIRE PRESSURE APP
    [Arguments]    ${dut_id}
    [Documentation]    To launch tyre pressure on ivi
    ...    ${dut_id} name of dut-id
    LAUNCH APP APPIUM    TPMS
    Sleep    2s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Vehicle']    direction=down    scroll_tries=12
    Should Be True    ${result}    Not able to find Vehicle app
    APPIUM_TAP_XPATH    //*[@text='Vehicle']
    APPIUM_TAP_XPATH    //*[@text='Tyre pressure']

CHECK PUNCTURE WARNING DISPLAY
    [Documentation]    To check puncture warning display on ivi
    Sleep    2s
    TAKE SCREENSHOT    sdcard/    tyre.png    ./
    Sleep    2
    ${result} =    SEARCH TEXT IN IMAGE    ./    tyre.png    Reset
    Should Be True    ${result}

SCREEN RESOLUTION OF IVI
    [Arguments]    ${size}    ${dut_id}=${ivi_adb_id}    ${screen_dimension}=${None}
    [Documentation]   To Decrease & Increase Screen resolution of ivi
    ...    ${size} minimize/maximize
    RUN KEYWORD IF    "${size}"=="minimize"    OperatingSystem.Run    adb -s ${dut_id} shell wm size 1920x1342
    RUN KEYWORD IF    "${size}"=="maximize"    OperatingSystem.Run    adb -s ${dut_id} shell wm size ${screen_dimension}

GET PHYSICAL SCREEN SIZE
    [Arguments]    ${dut_id}
    ${adb_output} =    OperatingSystem.Run    adb -s ${dut_id} shell wm size
    ${first_line_output} =    Get Line    ${adb_output}    0
    ${pshysical_size} =    Get Substring    ${first_line_output}    15    24
    [Return]    ${pshysical_size}

DO VEHICLE STANDBY
    [Arguments]    ${dut_id}
    [Documentation]   Tap Stand-by in pop-up to take the device ${dut_id} to stand-by mode
    Log To Console    Tap Stand-by in pop-up to take the device ${dut_id} to stand-by mode
    ${status}    ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN    ${dut_id}    stand-by.png
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

CHECK CURRENT TRIP VALUE
    [Arguments]    ${dut_id}
    [Documentation]    To check current trip value on ivi
    ...    ${dut_id} name of dut-id
    IF    "${platform_version}" == "10"
        LAUNCH APP APPIUM    DrivingEco
    ELSE
        LAUNCH APP APPIUM    MyDriving
    END
    Sleep    2s
    IF    "${platform_version}" == "12"
        ${status}    ${res_download} =    DOWNLOAD FILE FROM ARTIFACTORY   ${download_url}${ref_image}    ${CURDIR}
        Should Be True    ${status}
        ${img_loc}    ${verdict} =    GET IMAGE LOCATION ON SCREEN    ${res_download}    15
    ELSE    
        APPIUM_TAP_XPATH    ${trip}
        ${verdict} =   APPIUM_WAIT_FOR_XPATH    ${trip_value}
    END  
    Should Be True    "${verdict}" == "True"    trip value cannot be found on driving eco app  

DO CLOSE DRIVING ECO APP
    [Arguments]    ${dut_id}
    [Documentation]    To close driving eco app on ivi
    ...    ${dut_id} name of dut-id
    IF    "${platform_version}" == "12"
        SET CLOSE APP    ivi    MyDriving
    ELSE
        SET CLOSE APP    ivi    DrivingEco
    END    

CLOSE TYRE PRESSURE APP
    [Arguments]    ${dut_id}
    [Documentation]    To close tyre pressure on ivi
    ...    ${dut_id} name of dut-id
    SET CLOSE APP    ivi    TPMS

LAUNCH VEHICLE ACCESS APP
    [Arguments]    ${dut_id}
    [Documentation]    To launch vehicle access app on ivi
    ...    ${dut_id} name of dut-id
    LAUNCH APP APPIUM    TPMS
    Sleep    2s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Vehicle']    direction=down    scroll_tries=12
    Should Be True    ${result}    Not able to find Vehicle app
    APPIUM_TAP_XPATH    //*[@text='Vehicle']
    APPIUM_TAP_XPATH    //*[@text='Outside']
    APPIUM_TAP_XPATH    //*[@text='Access']
    APPIUM_TAP_XPATH    //*[@text='access and start by phone' or @text='Access and start by phone']
    Sleep    2s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='ON']
    Should Be True    "${result}" == "True"    ON button cannot be found on car settings screen
    APPIUM_TAP_XPATH    //*[@text='access and start by phone' or @text='Access and start by phone']

REMOVE POPUP
    [Arguments]    ${text}
    [Documentation]    Disable popup on IVI
    ${result}=    APPIUM_WAIT_FOR_XPATH    //*[@text='${text}']
    Run Keyword If    ${result} == ${TRUE}    tap_by_xpath    //*[@text='${text}']
    ...   ELSE    Log To Console    No text ${text} is found in IVI

SET SEAT MASSAGE INTENSITY
    [Documentation]    To set the seat massage intensity on IVI
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    10s
    APPIUM_TAP_XPATH    //*[@content-desc='AllianceKitchenSink' or @content-desc='Open drawer']
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    xpath=//*[@text='Seat']    //*[@content-desc='AllianceKitchenSink' or @content-desc='Open drawer']    direction=down    scroll_tries=50
    APPIUM_TAP_XPATH    //*[@text='Seat']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/list_api_set']
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='setSeatMassageIntensity']    direction=down    scroll_tries=25
    APPIUM_TAP_XPATH    //*[@text='setSeatMassageIntensity']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@text='TEST']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/spReq']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@text='SEAT_MASSAGE_INTENSITY_2']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@text='TEST']

CHECK HMI SEAT DRIVER MASSAGE INTENSITY
    [Arguments]    ${massage_intensity}
    [Documentation]    To check driver massage intensity on ivi
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/result_listener']    retries=20
    Should Be True    "${result}" == "True"    No result found
    Sleep    5s
    ${r_text} =   APPIUM_GET_TEXT    //*[@resource-id='com.alliance.car.kitchensink:id/result_listener']
    Should Contain    ${r_text}    ${massage_intensity}

CHECK HMI TIME FORMAT
    [Arguments]    ${time_format}
    [Documentation]    Checks the time format if it is set to: ${time_format}
    LAUNCH APP APPIUM    Settings
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${Time_format['date_time_format']}    direction=down    scroll_tries=12   from_xpath_element=//*[@text="Sound"]   
    Should Be True    "${result}" == "True"    ${Time_format['date_time_format']} is not found.
    APPIUM_TAP_XPATH    ${Time_format['date_time_format']}
    ${result} =   APPIUM_WAIT_FOR_XPATH   //*[@text="13:00"]    retries=20
    IF   "${time_format}" == "12"
        Run Keyword If    "${result}" == "${False}"    Log    Time format is already set to 12 HRS
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH   ${Time_format['format_24_12']}    
    ELSE
        Run Keyword If    "${result}" == "${True}"    Log    Time format is already set to 24 HRS
        Run Keyword If    "${result}" == "${False}"    APPIUM_TAP_XPATH    ${Time_format['format_24_12']}
    END
    RUN COMMAND AND CHECK RESULT    settings get system time_12_24       ${time_format}
    CLEAR PACKAGE    com.android.car.settings

ACCEPT IVI SPCX ANDROID AUTO REQUEST
    [Documentation]    Accept the SPCX request on IVI from Android Auto
    Log To Console    Accept the SPCX request on IVI from Android Auto
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    FOR    ${index}    IN RANGE    10
        SET USB STATUS    ${smartphone_cutter}    plugged    smartphone    ivi
        Sleep    5s
        # Image path in artifcatory: matrix/artifacts/pnp/Start.png
        TAP IF IMAGE DISPLAYED ON SCREEN    Start.png
        Sleep    5s
        # Image path in artifcatory: matrix/artifacts/pnp/Continue.png
        TAP IF IMAGE DISPLAYED ON SCREEN    Continue.png
        TAP IF IMAGE DISPLAYED ON SCREEN    Continue_MyF3.png
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Upload contact names to Google?']    retries=20
        Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Allow']
        Sleep    5s    Waiting for 5s for AndroidAuto app to complete the projection
        ${curr_win} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys | grep "Recent \#0"
        Exit For Loop If    "com.google.android.embedded.projection" in "${curr_win}"
        SET USB STATUS    ${smartphone_cutter}    unplugged    smartphone
        Sleep    5s
    END
    Should Contain    ${curr_win}    com.google.android.embedded.projection

ACCEPT IVI SPCX APPLE CARPLAY REQUEST
    [Documentation]    Accept the SPCX request on IVI from Apple CarPlay
    Log To Console    Accept the SPCX request on IVI from Apple CarPlay
    ENABLE_MULTI_WINDOWS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Yes']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Yes']
    Sleep    10s    Waiting for 10s for Apple Carplay app to launch
    ${curr_win} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys | grep "Recent \#0"
    Should Contain    ${curr_win}    com.alliance.car.carplaysvc

REJECT IVI SPCX ANDROID AUTO REQUEST
    [Documentation]    Reject the SPCX request on IVI from Android Auto
    Log To Console    Reject the SPCX request on IVI from Android Auto
    ENABLE_MULTI_WINDOWS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Not now']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Not now']

REJECT IVI SPCX APPLE CARPLAY REQUEST
    [Documentation]    Reject the SPCX request on IVI from Apple CarPlay
    Log To Console    Reject the SPCX request on IVI from Apple CarPlay
    ENABLE_MULTI_WINDOWS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Remember my choice for this device']    retries=20
    Return From Keyword If    "${result}" == "False"
    # By default Remember is always checked, unchecking this option by tapping on it once.
    APPIUM_TAP_XPATH    //*[@text='Remember my choice for this device']
    APPIUM_TAP_XPATH    //*[@text='No']

CHECKSET IVI MEX MODE
    [Arguments]    ${mode}
    [Documentation]    Check and set to mex mode ${mode}
    ...    ${mode} name of mex mode
    LAUNCH APP APPIUM    TPMS
    Sleep    3s
    IF    "${ivi_my_feature_id}" == "MyF3"
        ${mode_id} =    Set Variable If    "${mode}" == "eco"    ECO
        ...    "${mode}" == "sport"    SPORT
        ...    "${mode}" == "mysense"    MY SENSE
        ...    "${mode}" == "comfort"  MUD
        ${button_id} =    Set Variable If    "${mode}" == "eco"    com.renault.car.launcher:id/mex_button_1
        ...    "${mode}" == "sport"    com.renault.car.launcher:id/mex_button_4
        ...    "${mode}" == "mysense"    com.renault.car.launcher:id/mex_button_3
        ...    "${mode}" == "comfort"  com.renault.car.launcher:id/mex_button_2
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.renault.car.launcher:id/mex_mode_text_view${mode_id} or   @resource-id='${button_id}' and @checked= 'true']
        Return From Keyword If    "${result}" == "True"
        APPIUM_TAP_XPATH    //*[@resource-id='com.renault.car.launcher:id/mex_mode_text_view${mode_id}'or @resource-id='${button_id}']
    ELSE
        ${mode_id} =    Set Variable If    "${mode}" == "eco"    Eco
        ...    "${mode}" == "sport"    Sport
        ...    "${mode}" == "perso"    Vitamin
        ...    "${mode}" == "comfort"  MySense
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.renault.appmenu:id/mex${mode_id}' and @checked= 'true']
        Return From Keyword If    "${result}" == "True"
        APPIUM_TAP_XPATH    //*[@resource-id='com.renault.appmenu:id/mex${mode_id}']
    END


CHECK HMI ECONAV ENABLER CONTENTS
    [Documentation]    Check Eco_nav enabler
    LAUNCH APP APPIUM    TPMS
    APPIUM_TAP_XPATH    //*[@text='Electric']
    APPIUM_TAP_XPATH    //*[@text='Settings']
    CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ivi    predictive_hydrid.png
    CHECKSET FILE PRESENT    bench     ev_city_enable.png
    ${status}    ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN    ivi    ev_city_enable.png    False
    Run Keyword If    "${status}" == "False"    CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ivi    ev_city_enable.png

CHECK HMI ECONAV SAVINGS CONTENTS
    [Documentation]    Check Eco_nav savings mode
    LAUNCH APP APPIUM    TPMS
    APPIUM_TAP_XPATH    //*[@text='Driving eco']
    APPIUM_TAP_XPATH    //*[@text='Savings']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Electric : fuel saving']
    Should Be True    ${result}

SET ANDROID AUTO PERMISSION
    [Arguments]    ${permission_type}
    [Documentation]    Set Android Auto Permission to ${permission_type} on ivi
    Log To Console    Set Android Auto Permission to ${permission_type} on ivi
    IF    "${permission_type}" == "pair"
        SET USB STATUS    ${smartphone_cutter}    unplugged
        LAUNCH APP APPIUM    AppsMenu
        APPIUM_TAP_XPATH    //*[@text='Android Auto']
        APPIUM_TAP_XPATH    //*[@text='Pair']
    ELSE IF    "${permission_type}" == "enable"
        SET USB STATUS    ${smartphone_cutter}    plugged
        ACCEPT IVI SPCX ANDROID AUTO REQUEST
    END

CHECK HMI TIRE PRESSURE
    [Arguments]    ${button}    ${mode}
    [Documentation]    Check the Reset Button on Tire Pressure application is enabled/disabled on IVI
    Log To Console    Check the Reset Button on Tire Pressure application is ${mode} on IVI
    ${status} =    Set Variable If    "${mode}" == "enabled"    true
    ...    "${mode}" == "disabled"    false
    ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${button}' and @enabled='${status}']    direction=down    scroll_tries=12
    Should Be True    ${result}    ${button} button or ${mode} not found.

CHECK ALLIANCE KITCHEN SINK VPA STUB PROPERTY
    [Arguments]    ${property_type}    ${value}
    [Documentation]    To set the seat massage intensity on IVI
    ...    ${property_type}    parameter in Vehicle Stub
    ...    ${value}    value of ${property_type}
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
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/bGetProperty']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@resource-id='com.alliance.car.kitchensink:id/bGetProperty']
    ${r_text} =   APPIUM_GET_TEXT    //*[@resource-id='com.alliance.car.kitchensink:id/tvPropertyValue']
    Should Contain    ${r_text}    Value: ${value}

SET HMI TIMEZONE
    [Arguments]    ${target_id}    ${timezone}
    [Documentation]    Change timezone to ${timezone} on target_id: ${target_id}
    ...    ${target_id}    device under test ivi2
    ...    ${timezone}    timezone of country
    ${verdict} =    LAUNCH APP APPIUM    Settings
    Run Keyword If    ${verdict} == False    LAUNCH APP APPIUM    Settings
    APPIUM_TAP_XPATH    //*[@text='Date & time' or @text='Date and time']    retries=20
    APPIUM_TAP_XPATH    //*[@text='Select country time zone']    retries=20
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${timezone}']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"    ${timezone} is not found.
    APPIUM_TAP_XPATH    //*[@text='${timezone}']

CHECK HMI TIMEZONE
    [Arguments]    ${target_id}    ${timezone_country}    ${gmt_offset}
    [Documentation]    Check timezone of ${timezone_country} and ${gmt_offset} on target_id: ${target_id}
    ...    ${target_id}    device under test ivi2
    ...    ${timezone_country}    timezone of country selected
    ...    ${gms_offset}    GMS OFFSET Value of Timezone
    ${verdict} =    LAUNCH APP APPIUM    Settings
    Run Keyword If    ${verdict} == False    LAUNCH APP APPIUM    Settings
    APPIUM_TAP_XPATH    //*[@text='Date & time' or @text='Date and time']    retries=20
    APPIUM_TAP_XPATH    //*[@text='Select time zone']    retries=20
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${timezone_country}']
    Should Be True    "${result}" == "True"    ${timezone_country} is not correct.
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${gmt_offset}']
    Should Be True    "${result}" == "True"    ${gmt_offset} is not correct.vaild

LOAD NEAREST CHARGING STATION DESTINATION
    [Documentation]    Search and confirm the nereast petrol/charging station address on IVI
    ${output} =    GET SCREEN RESOLUTION
    ${x_axis} =    Set variable if   """1920""" == """${output}[height]"""   150    100
    Set Test Variable    ${x_axis}
    ${location} =    Create Dictionary    x=${x_axis}    y=280
    APPIUM_TAP_LOCATION    ${location}
    Sleep    5
    ${location} =    Create Dictionary    x=${x_axis}    y=800
    APPIUM_TAP_LOCATION    ${location}
    Sleep    5
    ${location} =    Create Dictionary    x=${x_axis}    y=1100
    APPIUM_TAP_LOCATION    ${location}
    ${location} =    Create Dictionary    x=${x_axis}    y=1000
    APPIUM_TAP_LOCATION    ${location}
    Sleep    5

UNLOAD DESTINATION FROM MAPS
    [Documentation]    Cancel current destination on maps
    ${location} =    Run Keyword If    "${x_axis}" == "150"    Create Dictionary    x=${x_axis}    y=1100
    ...              Else If    "${x_axis}" == "100"    Create Dictionary    x=${x_axis}    y=1000
    ...              Else       "${None}"
    Return from Keyword If    "${location}" == "${None}"
    APPIUM_TAP_LOCATION     ${location}
    Sleep    5

SET IVI SPCX REQUEST
    [Arguments]    ${appl_name}    ${req_type}
    [Documentation]    Accept / Reject the SPCX request on IVI from Apple CarPlay for iPhone / Android Auto for Android Phone
    ...    ${appl_name}    Apple CarPlay for iPhone / Android Auto for Android Phone
    ...    ${req_type}    accept or reject
    Run Keyword If    "${appl_name}" == "Android Auto" and "${req_type}" == "accept"    ACCEPT IVI SPCX ANDROID AUTO REQUEST
    Run Keyword If    "${appl_name}" == "Android Auto" and "${req_type}" == "reject"    REJECT IVI SPCX ANDROID AUTO REQUEST
    Run Keyword If    "${appl_name}" == "Apple CarPlay" and "${req_type}" == "accept"    ACCEPT IVI SPCX APPLE CARPLAY REQUEST
    Run Keyword If    "${appl_name}" == "Apple CarPlay" and "${req_type}" == "reject"    REJECT IVI SPCX APPLE CARPLAY REQUEST

CHECK HMI LANGUAGE
    [Arguments]    ${language}
    [Documentation]    Check language on ivi
    Log To Console    Check the language to ${language}
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    collapse
    Should Be True    ${verdict}
    LAUNCH APP APPIUM    Settings
    ${result} =   APPIUM_WAIT_FOR_XPATH     ${User_profile['system']}    direction=down    scroll_tries=12
    Should Be True    ${result}
    APPIUM_TAP_XPATH     ${User_profile['system']}
    APPIUM_TAP_XPATH    ${User_profile['languages_and_input']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${language}')]
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2s
    APPIUM_PRESS_KEYCODE    ${KEYCODE_BACK}
    Sleep    2s
    Should Be True    ${result}    Language different then expected

CHECKSET CAR SETTINGS FOR MEX
    [Arguments]    ${mex_setting}
    [Documentation]    Checkset mex settings
    LAUNCH APP APPIUM    AllianceKitchenSink
    Sleep    5s
    APPIUM_TAP_XPATH    ${mex['drawer']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='MEX']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"    is not found.
    APPIUM_TAP_XPATH    //*[@text='MEX']
    APPIUM_TAP_XPATH    ${mex['user_setting']}
    IF    "${mex_setting}" == "Off"
        LONG PRESS ELEMENT APPIUM    ${mex['menu_on_off']}
    ELSE
        IF    "${mex_setting}" == "On"
            ${location} =    Create Dictionary    x=155    y=1095
            Sleep    5s
            APPIUM_TAP_LOCATION    ${location}
        END
    END

CHECKSET CAR SETTINGS FOR ADAS
    [Arguments]    ${departure_setting}    ${alert_setting}
    [Documentation]    Checkset adas settings
    LAUNCH APP APPIUM    DriverAssistance
    Sleep    3s
    APPIUM_TAP_XPATH    ${adas['lane_keeping_sistem']}
    ${checked} =    APPIUM_GET_TEXT    ${adas['button_lane_departure_warning']}    10
    ${checked_box} =    Convert To Lower Case    ${checked}
    Run Keyword If    "${checked_box}" == "off"    APPIUM_TAP_XPATH    ${adas['lane_departure_warning']}
    APPIUM_TAP_XPATH    ${adas['departure_anticipation']}
    APPIUM_TAP_XPATH    ${adas['${departure_setting}']}
    APPIUM_TAP_XPATH    ${adas['alert_vibration']}
    APPIUM_TAP_XPATH    ${adas['${alert_setting}']}
    APPIUM_TAP_XPATH    ${adas['back']}

CHECK DEFAULT CAR SETTINGS
    [Arguments]    ${frequency}    ${mex_setting}    ${departure_setting}    ${alert_setting}
    [Documentation]    Check settings related to radio, mex and adas
    LAUNCH APP APPIUM    Radio
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${frequency}')]
    SHOULD BE TRUE    ${result}    Frequency value different then expected
    LAUNCH APP APPIUM    AllianceKitchenSink
    Sleep    5s
    APPIUM_TAP_XPATH    ${mex['drawer']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='MEX']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"    is not found.
    APPIUM_TAP_XPATH    //*[@text='MEX']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${mex_setting}')]
    SHOULD BE TRUE    ${result}    Mex setting different then expected
    LAUNCH APP APPIUM    DriverAssistance
    Sleep    3s
    APPIUM_TAP_XPATH    ${adas['lane_keeping_sistem']}
    ${checked} =    APPIUM_GET_TEXT    ${adas['button_lane_departure_warning']}    10
    ${checked_box} =    Convert To Lower Case    ${checked}
    Run Keyword If    "${checked_box}" == "off"    APPIUM_TAP_XPATH    ${adas['lane_departure_warning']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${departure_setting}')]
    SHOULD BE TRUE    ${result}    Departure setting different then expected
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[contains(@text,'${alert_setting}')]
    SHOULD BE TRUE    ${result}    Alert setting different then expected
    APPIUM_TAP_XPATH    ${adas['back']}

STORE DEFAULT CAR SETTINGS
    [Documentation]    Store settings related to radio, mex and adas
    LAUNCH APP APPIUM    Radio
    Sleep    3s
    ${frequency} =   APPIUM_GET_TEXT_USING_XPATH    ${mex['current_state_radio']}
    LAUNCH APP APPIUM    AllianceKitchenSink
    Sleep    5s
    APPIUM_TAP_XPATH    ${mex['drawer']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='MEX']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"    is not found.
    APPIUM_TAP_XPATH    //*[@text='MEX']
    ${mex_setting} =   APPIUM_GET_TEXT_USING_XPATH    ${mex['current_state_mex']}
    LAUNCH APP APPIUM    DriverAssistance
    Sleep    3s
    APPIUM_TAP_XPATH    ${adas['lane_keeping_sistem']}
    ${checked} =    APPIUM_GET_TEXT    ${adas['button_lane_departure_warning']}    10
    ${checked_box} =    Convert To Lower Case    ${checked}
    Run Keyword If    "${checked_box}" == "off"    APPIUM_TAP_XPATH    ${adas['lane_departure_warning']}
    ${departure_setting} =   APPIUM_GET_TEXT_USING_XPATH    ${adas['departure_value']}
    ${alert_setting} =   APPIUM_GET_TEXT_USING_XPATH    ${adas['alert_value']}
    APPIUM_TAP_XPATH    ${adas['back']}
    should not be empty    ${frequency}
    should not be empty    ${mex_setting}
    should not be empty    ${departure_setting}
    should not be empty    ${alert_setting}
    [Return]    ${frequency}    ${mex_setting}    ${departure_setting}    ${alert_setting}

CHECK AUTO TIME STATUS
    [Documentation]    Check if Automatic Date & Time update is enabled
    [Arguments]    ${status}
    ${stdout} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings get global auto_time
    ${status_on}   Run Keyword And Return Status  Should Contain    ${status}  on
    ${status_off}   Run Keyword And Return Status  Should Contain    ${status}  off
    ${time_on}   Run Keyword And Return Status  Should Contain    ${stdout}  1
    ${time_off}   Run Keyword And Return Status  Should Contain    ${stdout}  0
    ${verdict} =  Set Variable   False
    IF  ${status_on}
        IF  ${time_on}
            log  "Auto time date is on"
            ${verdict} =  Set Variable   True
        ELSE
            log  "Auto time date is off, should be made to on"
            ${verdict} =  Set Variable   False
        END
    END

    IF  ${status_off}
        IF  ${time_off}
            log  "Auto time date is off"
            ${verdict} =  Set Variable   True
        ELSE
            log  "Auto time date is on, should be made to off"
            ${verdict} =  Set Variable   False
        END
    END
    [return]    ${verdict}

TIME AUTO UPDATE
    [Documentation]    Update the Automatic Date & Time to corresponing status
    [Arguments]    ${status}
    ${verdict} =  Set Variable   False
    START INTENT        android.settings.DATE_SETTINGS
    ${stdout} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings get global auto_time
    ${status_on}   Run Keyword And Return Status  Should Contain    ${status}  on
    ${status_off}   Run Keyword And Return Status  Should Contain    ${status}  off
    IF  ${status_on}
           OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put global auto_time 1
           ${stdout} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings get global auto_time
           ${result_on}   Run Keyword And Return Status  Should Contain    ${stdout}  1
            IF  ${result_on}
                ${verdict} =  Set Variable   True
            ELSE
                ${verdict} =  Set Variable   False
            END
    END
    IF  ${status_off}
            OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put global auto_time 0
            ${stdout} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings get global auto_time
            ${result_off}   Run Keyword And Return Status  Should Contain    ${stdout}  0
            IF  ${result_off}
                ${verdict} =  Set Variable   True
            ELSE
                ${verdict} =  Set Variable   False
            END
    END
    [return]    ${verdict}

TIME UPDATE
    [Documentation]    Update the Time
    [Arguments]    ${time}    ${time_format}
    ${verdict} =  Set Variable   False
    ${format_pm}   Run Keyword And Return Status  Should Contain    ${time_format}  pm
    ${format_24}   Run Keyword And Return Status  Should Contain    ${time_format}  24
    ${mode} =    CHECK AUTO TIME STATUS     on
    IF  ${mode}
        ${verdict} =    Set Variable   False      Time auto mode is on could not set time
    ELSE
        START INTENT    android.settings.DATE_SETTINGS
        # Get the current date and time
        ${date} =	 Get Current Date
        # Split the date
        ${result_split_espace} =    Split String     ${date}    ${SPACE}
        ${date} =   Split String     ${result_split_espace}[0]    -
        ${year} =   set variable  ${date}[0]
        ${month} =  set variable  ${date}[1]
        ${day} =    set variable  ${date}[2]
            # Get the time
        IF  ${time} == None
            ${time} =   Split String     ${result_split_espace}[1]    :
            ${hour} =    Set Variable    ${time}[0]
            ${min} =    Set Variable    ${time}[1]
        ELSE
            ${time} =    Split String     ${time}    h
            ${hour} =    Set Variable    ${time}[0]
            ${min} =    Set Variable     ${time}[1]
        END
        IF  ${format_pm}
            ${Hour} =   set variable   ${ ${hour} + 12}
            OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put system time_12_24 12
        ELSE IF  ${format_24}
            OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put system time_12_24 24
        ELSE
            OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put system time_12_24 12
        END
        ${stdout}  ${stderr} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell date ${month}${day}${Hour}${min}${year}
        ${verdict} =  Run Keyword If    ${stderr} == b''   Set Variable   True
        ...    ELSE   Set Variable    False
    END
    [return]      ${verdict}

SET IVI DATE
    [Arguments]    ${time}    ${year_offset}=0
    [Documentation]    The date on IVI is set to current date and then increment
    Run Keyword If    '${year_offset}'=='0'    TIME UPDATE    ${time}    24h
    ...    ELSE    SET YEAR ON IVI    ${time}    24h    ${year_offset}

BYPASS WIZARD MENU
    [Documentation]    Check if the wizard menu is displayed. If yes, disable it
    ${verdict} =  Set Variable   False
    ${verdict} =   PS PACKAGE    com.google.android.car.setupwizard    STARTED
    IF  ${verdict}
        SET PROP    ro.setupwizard.mode    DISABLED
        KILL PROCESS    com.google.android.car.setupwizard
        KILL PROCESS    com.renault.setupwizardoverlay
        ${verdict} =  Set Variable   True
    ELSE
        ${verdict} =  Set Variable   False
    END
    [return]    ${verdict}

CHECK DATE FORMAT
    [Documentation]    Check on the device if the Updated Time is equal to the expected time
    [Arguments]    ${date_format}
    ${verdict} =  Set Variable   False
    ${stdout} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cat /data/user_de/0/com.alliance.car/shared_prefs/alliance.car.clock_preferences.xml
    ${result}   Run Keyword And Return Status  Should Contain    ${stdout}    ${date_format}
    IF  ${result}
        ${verdict} =  Set Variable   True
    ELSE
        ${verdict} =  Set Variable   False
    END
    [return]   ${verdict}

SET YEAR ON IVI
    [Documentation]    Set the current Year on the IVI
    [Arguments]    ${time}    ${time_format}    ${year_offset}=0
    ${verdict} =  Set Variable   False
    ${format_pm}   Run Keyword And Return Status  Should Contain    ${time_format}  pm
    ${format_24}   Run Keyword And Return Status  Should Contain    ${time_format}  24
    START INTENT    android.settings.DATE_SETTINGS
    # Get the current date and time
    ${date} =	 Get Current Date
    # Split the date
    ${result_split_espace} =    Split String     ${date}    ${SPACE}
    ${date} =   Split String     ${result_split_espace}[0]    -
    ${year} =   set variable   ${date}[0]
    ${year} =   set variable   ${ ${year} + ${year_offset}}
    ${month} =  set variable  ${date}[1]
    ${day} =    set variable  ${date}[2]
    # Get the time
    IF  ${time} == None
        ${time} =   Split String     ${result_split_espace}[1]    :
        ${hour} =    Set Variable    ${time}[0]
        ${min} =    Set Variable    ${time}[1]
    ELSE
        ${time} =    Split String     ${time}    h
        ${hour} =    Set Variable     ${time}[0]
        ${min} =    Set Variable     ${time}[1]
    END
    IF  ${format_pm}
        ${Hour} =   set variable   ${ ${hour} + 12}
        OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put system time_12_24 12
    ELSE IF  ${format_24}
        OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put system time_12_24 24
    ELSE
        OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put system time_12_24 12
    END
    ${stdout}  ${stderr} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell date ${month}${day}${Hour}${min}${year}
    ${verdict} =  Run Keyword If    ${stderr} == b''   Set Variable   True
    ...    ELSE   Set Variable    False
    [return]      ${verdict}

CHECK HMI VEHICLE SAVING MODE
    [Documentation]    Check saving mode in driving eco app
    [Arguments]    ${saving_mode}
    LAUNCH APP APPIUM    TPMS
    DO HMI TAP ACTION APPIUM    Driving eco    text
    DO HMI TAP ACTION APPIUM    Savings    text
    APPIUM_WAIT_FOR_XPATH    //*[@text='${saving_mode}']

CHECK ANDROIDAUTO REPLICATION ON IVI
    [Documentation]    To verify the AA screen replication on IVI
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    ENABLE_MULTI_WINDOWS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Allow']
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${AndroidAuto['start_aa']}    retries=20
    IF    "${result}" == "${True}"
        APPIUM_TAP_XPATH    ${AndroidAuto['start_aa']}
    ELSE
        LAUNCH APP APPIUM    AppsMenu
        ${result} =   APPIUM_WAIT_FOR_XPATH    ${AndroidAuto['android_auto']}    direction=up    scroll_tries=20
        Should Be True    ${result}
        APPIUM_TAP_XPATH    ${AndroidAuto['android_auto']}
    END
    ACCEPT IVI SPCX ANDROID AUTO REQUEST

CHECK EV BATTERY PERCENTAGE
    [Arguments]    ${ev_battery_percentage}
    [Documentation]    Checks the EV Battery Settings if the Battery percentage is ${ev_battery_percentage}
    Log To Console    Checks the EV Battery Settings if the Battery percentage is ${ev_battery_percentage}
    LAUNCH APP APPIUM    EvSettings
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${battery}
    RUN KEYWORD IF    '${result}' == 'True'     APPIUM_TAP_XPATH    ${battery}
    ...    ELSE    APPIUM_TAP_XPATH    ${battery_settings}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${ev_battery_percentage}']
    Should Be True    ${result}

SET ANDROID AUTO OVER WIFI
    [Arguments]    ${dut_id}    ${status}
    [Documentation]    Set Android Auto over WiFi on smartphone: ${dut_id} to ${status}
    Log To Console    Set Android Auto over WiFi on smartphone: ${dut_id} to ${status}
    ${bool_status} =    Set Variable If    "${status}" == "enable"    ${True}    ${False}
    LAUNCH APPIUM APP ON SMARTPHONE    Settings
    APPIUM_TAP_XPATH    ${Bluetooth_devices}
    APPIUM_TAP_XPATH    ${conn_pref}
    APPIUM_TAP_XPATH    ${AndroidAuto['android_auto']}
    APPIUM_TAP_XPATH    ${AndroidAuto['more_options']}
    APPIUM_TAP_XPATH    ${AndroidAuto['developer_settings']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${AndroidAuto['wireless_aa']}    direction=up    scroll_tries=20
    Should Be True    ${result}
    ${result} =    FIND IMAGE ON SCREEN APPIUM    wireless_aa_disabled.png     99
    ${verdict} =    Get From List    ${result}    2
    Run Keyword If    "${bool_status}" == "${verdict}"    APPIUM_TAP_XPATH        ${AndroidAuto['wireless_aa']}
    Sleep    2s
    APPIUM_PRESS_KEYCODE    ${KEYCODE_HOME}

CHECK ANDROIDAUTO REPLICATION ON IVI OVER WIFI
    [Documentation]    To verify the AA screen replication on IVI over WiFi
    SET USB STATUS    ${smartphone_cutter}    plugged    smartphone    hostpc
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    ENABLE_MULTI_WINDOWS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow']
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Allow']
    Sleep    10s
    TAP IF IMAGE DISPLAYED ON SCREEN    Start.png
    Sleep    5s
    TAP IF IMAGE DISPLAYED ON SCREEN    Continue.png
    TAP IF IMAGE DISPLAYED ON SCREEN    Continue_MyF3.png
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Upload contact names to Google?']    retries=20
    Run Keyword If    "${result}" == "${True}"    APPIUM_TAP_XPATH    //*[@text='Allow']
    ${result} =    FIND IMAGE ON SCREEN APPIUM    Android_Auto_home_screen.png     90
    ${verdict} =    Get From List    ${result}    2
    Should Be True    ${verdict}    AndroidAuto Replication over WiFi failed.

SET NEW USER TOGGLE BUTTON
    [Arguments]    ${target_id}    ${new_user}   
    [Documentation]    Revoke profile creating permission to User
    Log To Console    Revoke profile creating permission to User
    DO WAIT    5000
    DO CLOSE APP    ivi    ProfileSettings
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER    ProfileSettings
    LAUNCH APP APPIUM    ProfileSettings
    DO WAIT    5000
    APPIUM_TAP_XPATH    //*[@resource-id='com.renault.profilesettingscenter:id/toolbar_menu_icon']
    APPIUM_TAP_XPATH    //*[@text='Manage profiles']
    APPIUM_TAP_XPATH    //*[@text='${new_user}']
    APPIUM_TAP_XPATH    //*[@text='Create new users']
    DO CLOSE APP    ivi    ProfileSettings

CHECK HMI AUTODIMMINGSTATE
    [Arguments]    ${button}    ${value}
    [Documentation]    Check the AutoDimmingState Button on Magic Cockpit application is ON/OFF on IVI
    Log To Console    Check the AutoDimmingState Button on Magic Cockpit application is ${button} or ${value} on IVI
    IF    "${platform_version}" == "10"
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${button}' and @resource-id='com.renault.vehiclesettings:id/switchWidget']
    ELSE
        ${result} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='android:id/switch_widget' and @checked='${value}']
    END
    Should Be True    ${result}    ${button} or ${value} not found.

CHECK GAS APP VERSION
    [Documentation]    Checks gas app version
    ${stdout_versioncode} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys package com.google.android.apps.maps | grep versionCode
    ${stdout_versionname} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell dumpsys package com.google.android.apps.maps | grep versionName
    [return]    ${stdout_versioncode}    ${stdout_versionname}

CHECK LANE KEEPING SYSTEM FEATURE SOUND ALERT
    [Arguments]    ${sound_alert_value}
    [Documentation]    Check if the SOUND ALERT value is set to ${sound_alert_value} in the LANE KEEPING SYSTEM
    Log To Console    Check if the SOUND ALERT value is set to ${sound_alert_value} in the LANE KEEPING SYSTEM
    LAUNCH APP APPIUM    TPMS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Driving assistance']    direction=down    scroll_tries=3
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Driving assistance']
    APPIUM_TAP_XPATH    //*[@text='Lane keeping system']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Volume']    direction=down    scroll_tries=3
    Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    //*[@text='Sound alert']
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${current_volume}    direction=down    scroll_tries=3
    Should Be True    ${result}
    ${sa_value_read} =   APPIUM_GET_TEXT_USING_XPATH    ${current_volume}
    ${sound_alert_value} =    Set Variable If    "${sound_alert_value}"=="default"    3    ${sound_alert_value}
    Should Be Equal    ${sa_value_read}    ${sound_alert_value}    Sound Alert expected value ${sound_alert_value}, but actual value is ${sa_value_read}

SET LANE KEEPING SYSTEM FEATURE SOUND ALERT
    [Arguments]    ${sound_alert_value}
    [Documentation]    Set the SOUND ALERT value to ${sound_alert_value} which is present in the LANE KEEPING SYSTEM
    Log To Console    Set the SOUND ALERT value to ${sound_alert_value} which is present in the LANE KEEPING SYSTEM
    LAUNCH APP APPIUM    TPMS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Driving assistance']    direction=down    scroll_tries=3
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Driving assistance']
    APPIUM_TAP_XPATH    //*[@text='Lane keeping system']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Sound alert']    direction=down    scroll_tries=3
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Sound alert']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Volume']    direction=down    scroll_tries=3
    Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    //*[@text='Sound alert']
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${volume_scroll_bar}    direction=down    scroll_tries=3
    Should Be True    ${result}
    IF    "${platform_version}" == "10"
        SET LANE KEEPING SYSTEM FEATURE SOUND ALERT A10    ${sound_alert_value}
    ELSE
        SET LANE KEEPING SYSTEM FEATURE SOUND ALERT A12    ${sound_alert_value}
    END
 
SET LANE KEEPING SYSTEM FEATURE SOUND ALERT A10
    [Arguments]    ${sound_alert_value}
    [Documentation]    Set the SOUND ALERT value to ${sound_alert_value} which is present in the LANE KEEPING SYSTEM For A10
    ${location} =    GET ELEMENT LOCATION BY XPATH    ${volume_scroll_bar}                                                             
    ${x_min} =    Get From Dictionary    ${location}    x
    ${y} =    Get From Dictionary    ${location}    y
    ${x} =    Run Keyword If    "${sound_alert_value}" == "1"    Evaluate   (${x_min})
    ...    ELSE IF    "${sound_alert_value}" == "2"    Evaluate   (${x_min}+100)
    ...    ELSE IF    "${sound_alert_value}" == "3"    Evaluate   (${x_min}+200)
    ...    ELSE IF    "${sound_alert_value}" == "4"    Evaluate   (${x_min}+300)
    ...    ELSE IF    "${sound_alert_value}" == "5"    Evaluate   (${x_min}+400)
    ...    ELSE    Fail    Invalid value for sound_alert_value: ${sound_alert_value}. Valid value is between 1 and 5.
    ${tap_location} =    Create Dictionary    x=${x}    y=${y}
    APPIUM_TAP_LOCATION    ${tap_location}
    Sleep    2s

SET LANE KEEPING SYSTEM FEATURE SOUND ALERT A12
    [Arguments]    ${sound_alert_value}
    [Documentation]    Set the SOUND ALERT value to ${sound_alert_value} which is present in the LANE KEEPING SYSTEM For A12
    ${location} =    GET ELEMENT LOCATION BY XPATH    ${volume_scroll_bar}                                                             
    ${x_min} =    Get From Dictionary    ${location}    x
    ${y} =    Get From Dictionary    ${location}    y
    ${x} =    Run Keyword If    "${sound_alert_value}" == "1"    Evaluate   (${x_min})
    ...    ELSE IF    "${sound_alert_value}" == "2"    Evaluate   (${x_min}+200)
    ...    ELSE IF    "${sound_alert_value}" == "3"    Evaluate   (${x_min}+400)
    ...    ELSE IF    "${sound_alert_value}" == "4"    Evaluate   (${x_min}+600)
    ...    ELSE IF    "${sound_alert_value}" == "5"    Evaluate   (${x_min}+800)
    ...    ELSE    Fail    Invalid value for sound_alert_value: ${sound_alert_value}. Valid value is between 1 and 5.
    ${tap_location} =    Create Dictionary    x=${x}    y=${y}
    APPIUM_TAP_LOCATION    ${tap_location}
    Sleep    2s

CHECKSET HMI LANE DEPARTURE WARNING
    [Arguments]    ${status}
    [Documentation]    Checkset "Lane departure warning" to: ${status}
    ...    ${status}   on / off
    Log To Console    Checkset "Lane departure warning" to: ${status}
    ${status} =    Convert To Upper Case    ${status}
    LAUNCH APP APPIUM    TPMS
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Driving assistance']    direction=down    scroll_tries=3
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Driving assistance']
    APPIUM_TAP_XPATH    //*[@text='Lane keeping system']
    IF    "${platform_version}" == "10"
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${status}']/..//*[@text='Lane departure warning']
        Run Keyword And Return If    "${result}"=="True"    Log To Console    Lane departure warning is already set to ${status}
        APPIUM_TAP_XPATH    //*[@text='Lane departure warning']
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${status}']/..//*[@text='Lane departure warning']
    ELSE
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@checked='true' and @index='0']
        Should Be True    ${result}
        ${result1} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Lane departure warning']
        Should Be True    ${result1}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Sound alert']    direction=down    scroll_tries=3
        Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    //*[@text='Lane departure warning']
        Log To Console    Lane departure warning is already set to ${status}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@checked='true' and @index='0']
        Should Be True    ${result}
        ${result1} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Lane departure warning']
        Should Be True    ${result1}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Sound alert']    direction=down    scroll_tries=3  
    END
    Should Be True    ${result}    Lane departure warning is not set to ${status}
    Log To Console    Lane departure warning is successfully set to ${status}

CHECK HMI ENERGY FLOW
    [Arguments]    ${direction1}    ${direction2}
    [Documentation]    Check the HMI Energy Flow from ${direction1} to ${direction2}
    Log To Console    Check the HMI Energy Flow from ${direction1} to ${direction2}
    LAUNCH APP APPIUM    TPMS
    APPIUM_TAP_XPATH    //*[@text='Electric']
    ${energy_flow_direction} =    Set Variable If    "${direction1}"=="Battery" and "${direction2}"=="Motor"    BatteryToElectricEngine
    ...    "${direction1}"=="Battery" and "${direction2}"=="Accessory"    ElectricEngineToFrontWheels
    IF    "${ivi_my_feature_id}" == "MyF3" 
       ${energy_flow_direction_xpath} =    Set Variable    //*[@resource-id='com.renault.car.evservices:id/energyFlow${energy_flow_direction}']
    ELSE
        ${energy_flow_direction_xpath} =    Set Variable    //*[@resource-id='com.renault.evservices:id/energyFlow${energy_flow_direction}']
    END
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${energy_flow_direction_xpath}
    Should Be True    ${result}     Energy Flow direction is not ${direction1} to ${direction2}

SET GOOGLE VOICE RECOGNITION
    [Arguments]    ${target_id}    ${status}     ${select_using_image}=True
    [Documentation]    Set Google Voice Recognition to ${status} on or off on ${target_id}
    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    LAUNCH APP APPIUM    Settings
    Sleep    5
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Google']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"
    APPIUM_TAP_XPATH    //*[@text='Google']
    APPIUM_TAP_XPATH    //*[@text='Google Assistant']
    IF    ${select_using_image}==True
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Use this phrase to access your Assistant by voice']
        Should Be True    "${result}" == "True"
        ${result} =    FIND IMAGE ON SCREEN APPIUM    voice_recog.png     95
        ${verdict} =    Get From List    ${result}    2
        ${vr_status} =    Evaluate    ("${verdict}"=="True" and "${status}"=="on") or ("${verdict}"=="False" and "${status}"=="off")
        Run Keyword If    "${vr_status}"=="False"    APPIUM_TAP_XPATH    //*[@text='Use this phrase to access your Assistant by voice']
        Sleep    15
    ELSE IF    ${select_using_image}==False
        ${gas_btn} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['google_assistant_switch']}    checked
        Run Keyword If    "${gas_btn}"=="false" and "${status}"=="on"    APPIUM_TAP_XPATH    ${car_settings['google_assistant_switch']}    10
        Run Keyword If    "${gas_btn}"=="true" and "${status}"=="off"    APPIUM_TAP_XPATH    ${car_settings['google_assistant_switch']}    10
    END

GET HMI_INFO DETAILS FROM HMI NAME
    [Arguments]    ${hmi_name}    ${device_type}=ivi    ${platform_version}=${platform_version}
    [Documentation]    Read required hmi info based hmi_name
    ${tap_action} =    Catenate    SEPARATOR=    hmi_info_    ${device_type}    _android_    ${platform_version}    ['${hmi_name}']    ['tap_action']
    ${search_action} =    Catenate    SEPARATOR=    hmi_info_    ${device_type}    _android_    ${platform_version}    ['${hmi_name}']    ['search_action']
    ${image_to_validate} =    Catenate    SEPARATOR=    hmi_info_    ${device_type}    _android_    ${platform_version}    ['${hmi_name}']    ['image_to_validate']
    [Return]    ${${tap_action}}    ${${search_action}}    ${${image_to_validate}}

CHECK HMI CONTENT IN LOOP
    [Arguments]    ${intent_name}    ${hmi_name}
    [Documentation]    Check text/button in hmi through loop from home page.
    ${tap_action}    ${search_action}    ${image_to_validate} =    GET HMI_INFO DETAILS FROM HMI NAME    ${hmi_name}
    ${count} =    Get length    ${tap_action}
    LAUNCH APP APPIUM    ${intent_name}
    DO WAIT    5000
    FOR    ${index}    IN RANGE   0    ${count}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${tap_action}[${index}]']    direction=down    scroll_tries=12
        Should Be True    "${result}" == "True"    ${tap_action}[${index}] is not found.
        APPIUM_TAP_XPATH    //*[@text='${tap_action}[${index}]']
    END
    ${search_id} =    Set Variable    ${EMPTY}
    ${search} =    Set Variable    ${EMPTY}
    FOR    ${key}    IN    @{search_action.keys()}
        ${search_id} =    Catenate    SEPARATOR=    @    ${key}    =    '    ${search_action}[${key}]    '    ${SPACE}    and    ${SPACE}
        ${search} =    Catenate    SEPARATOR=    ${search}    ${search_id}
    END
    ${search} =    Split String From Right    ${search}    ${SPACE}and${SPACE}    max_split=1
    ${search} =    Catenate    SEPARATOR=    //*[    ${search}[0]    ]
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${search}    retries=20    direction=down    scroll_tries=12
    Should Be True    ${result}
    Run Keyword If    "${image_to_validate}[${0}]" != "None"    Run Keywords        CHECKSET FILE PRESENT    bench    ${image_to_validate}[${0}]
    ...    AND    Sleep    5s
    ...    AND     CHECK IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${image_to_validate}[${0}]
    ...    AND     SET DELETE FILE    bench    ${image_to_validate}[${0}]
    DO KILL APP    ivi    ${intent_name}

SET GOOGLE VOICE RECOGNITION ALLOW PERSONAL RESULTS
    [Arguments]    ${target_id}    ${status}    ${select_using_image}=True
    [Documentation]    Set Google Voice Recognition allow personal results to status: enable or disable on ${target_id}
    Log To Console        Set Google Voice Recognition allow personal results to status: ${status} on ${target_id}
    GO HOME AND CLEAR SETTINGS APP    ${target_id}
    LAUNCH APP APPIUM    Settings
    Sleep    5s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Google']    direction=down    scroll_tries=12
    Should Be True    "${result}" == "True"
    APPIUM_TAP_XPATH    //*[@text='Google']
    APPIUM_TAP_XPATH    //*[@text='Google Assistant']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Allow personal results in this car']
    Should Be True    "${result}" == "True"    To enable Personal results you need to connect to WiFi and login to Google
    IF    ${select_using_image}==True
        ${result} =    FIND IMAGE ON SCREEN APPIUM    allow_personal_results.png     98
        ${verdict} =    Get From List    ${result}    2
        ${pr_status} =    Evaluate    ("${verdict}"=="True" and "${status}"=="enable") or ("${verdict}"=="False" and "${status}"=="disable")
        Return From Keyword If    "${pr_status}"=="True"
        APPIUM_TAP_XPATH    //*[@text='Allow personal results in this car']
    ELSE IF    ${select_using_image}==False
        ${gas_btn} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${car_settings['google_result_switch']}    checked
        Run Keyword If    "${gas_btn}"=="false" and "${status}"=="enable"    APPIUM_TAP_XPATH    ${car_settings['google_result_switch']}    10
        Run Keyword If    "${gas_btn}"=="true" and "${status}"=="disable"    APPIUM_TAP_XPATH    ${car_settings['google_result_switch']}    10
        Return From Keyword If    "${gas_btn}"=="true" and "${status}"=="enable"
    END
    Sleep    3s
    Return From Keyword If    "${status}"=="disable"
    APPIUM_TAP_XPATH    //*[@text='Next']    retries=20
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@password='true']    retries=10
    Should Be True    "${result}" == "True"
    APPIUM_ENTER_TEXT_XPATH    //*[@password='true']    ${gas_pswd}
    APPIUM_TAP_XPATH    //*[@text='Next']    retries=5
    Sleep    3s

DO IVI DISABLE PROGRAM
    [Documentation]     Disable all programs from the PROGRAM menu.
    Log To Console	Disable all programs from the PROGRAM menu.    
    APPIUM_TAP_XPATH	//*[@text='Charge & Climate']
    APPIUM_TAP_XPATH	//*[@text='Program']
    APPIUM_TAP_XPATH	//android.widget.Button[@resource-id='com.renault.evservices:id/weeklyProgramMyPrograms']
    FOR    ${i}    IN RANGE    1    10
        ${verdict} =    APPIUM_WAIT_FOR_XPATH   //*[@text='ON']     10
        Run Keyword If    "${verdict}" == "True"    APPIUM_TAP_XPATH   //*[@text='ON']
	...    ELSE    Exit For Loop
    END

SET GOOGLE VOICE RECOGNITION RESPONSE
    [Arguments]    ${command}    ${sleep_needed}=True
    [Documentation]    Set Google Voice Recognition command: Ok Google ${command}
    Log To Console        Set Google Voice Recognition command: Ok Google ${command}
    ${tts_file_name} =    Set Variable If
    ...    "${command}"=="Change multi sense mode to Eco"    I_want_Eco_Mode.wav
    ...    "${command}"=="Change multi sense mode to Sport"    I_want_Sport_Mode.wav
    ...    "${command}"=="Change multi sense mode to Perso"    I_want_Personal_Mode.wav
    ...    "${command}"=="Change multi sense mode to Comfort"    I_want_Comfort_Mode.wav
    ...    "${command}"=="What is the battery level of my car"    Battery_level_of_my_Car.wav
    ...    "${command}"=="Navigate To Marathahalli"    Navigate_To_Marathahalli.wav
    ...    "${command}"=="Navigate To Whitefield"    Navigate_To_Whitefield.wav
    ...    "${command}"=="Distance to destination Chennai"    how_far_is_chennai.wav
    ...    "${command}"=="Navigate To Delhi"    Navigate_To_Delhi.wav
    ...    "${command}"=="Let me know when the battery level is at 48%"    alert_battery_level_48.wav
    ...    "${command}"=="Most economical route to Chennai"    most_economical_route_to_Chennai.wav
    ...    "${command}"=="Valet Parking"    valet_parking.wav
    ...    "${command}"=="Take a Note"    take_a_note.wav
    ...    "${command}"=="Display my calendar"    display_my_calendar.wav
    ...    "${command}"=="Rain tomorrow"    will_it_rain_tomorrow.wav
    ...    "${command}"=="Black ice tomorrow"    black_ice_tomorrow.wav
    ...    "${command}"=="5 hot news today"    five_hot_news_today.wav
    ...    "${command}"=="What can you do"    what_can_you_do.wav
    ...    "${command}"=="Go to the home"    go_to_the_home.wav
    ...    "${command}"=="Go to the street"    go_to_the_number_street_location.wav
    ...    "${command}"=="Go to KFC Brussels"    go_to_restaurant_brussels.wav
    ...    "${command}"=="Go to POI KFC"    go_to_a_poi_name_restaurant.wav
    ...    "${command}"=="Look for a pharmacy near to a restaurant"    look_for_a_pharmacy_near_to_a_restaurant.wav
    ...    "${command}"=="Play Lover from Taylor Swift on Spotify"    play_an_album_from_an_artist_on_spotify.wav
    ...    "${command}"=="Weather week Paris"    weather_in_paris.wav
    ...    "${command}"=="Weather tomorrow"    weather_for_tomorrow.wav
    ...    "${command}"=="Stop the sound"    stop_the_sound.wav
    ...    "${command}"=="Next track"    next_track.wav
    ...    "${command}"=="Previous track"    previous_track.wav
    ...    "${command}"=="Next radio station"    next_radio_station.wav
    ...    "${command}"=="Previous radio station"    previous_radio_statiom.wav
    ...    "${command}"=="Set the volume at level 80"  set_the_volume_at_80.wav
    ...    "${command}"=="Play radio romania actualitati"    play_radio_romania_actualitati.wav
    ...    "${command}"=="Find Gas station"    find_gas_station.wav
    ...    "${command}"=="Time remaining"    Time_remaining.wav
    ...    "${command}"=="Traffic info"    traffic_info.wav
    ...    "${command}"=="Show all traffic"    Show_all_traffic.wav
    ...    "${command}"=="restaurant_place"    restaurant_place.wav
    ...    "${command}"=="fuel_station"    go_to_fuelstation.wav
    ...    "${command}"=="Play Radio on 106.7 fm"    play_106.7_on_fm.wav
    ...    "${command}"=="Play Radio"    play_radio.wav
    ...    "${command}"=="Play a song on spotify"    play_a_song_on_spotify.wav
    PLAY FILE ON SOUND CARD    ok_google.wav
    PLAY FILE ON SOUND CARD    ${tts_file_name}
    Return From Keyword If    ${sleep_needed}==False
    Sleep    10s

SET DATE FORMAT
    [Arguments]    ${date_format}
    [Documentation]    Set the date format to ${date_format}
    Log To Console    Set the date format to ${date_format}
    LAUNCH APP APPIUM    Settings
    Sleep    5s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Date & time' or @text='Date and time']    direction=down    scroll_tries=12
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Date & time' or @text='Date and time']
    APPIUM_TAP_XPATH    //*[@text='Date format' or @text='Date Format']
    APPIUM_TAP_XPATH    //*[@text='${date_format}']
    GO HOME AND CLEAR SETTINGS APP    ${ivi_adb_id}

LAUNCH ALLIANCE KITCHEN APP AND SELECT OPTION
    [Arguments]    ${option}    ${verify}
    [Documentation]    Launch alliance kitchen sink app and select required option.
    ...    ${option}    app to select inside alliance kitchen sink app
    ...    ${verify}    any button or text to verify app opened or not
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@content-desc='AllianceKitchenSink' or @content-desc='Open drawer']
    Sleep    5s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${option}']    direction=down    scroll_tries=25
    Should Be True    "${result}" == "True"    ${option} is not found.
    APPIUM_TAP_XPATH    //*[@text='${option}']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${verify}' or @resource-id='${verify}']    direction=down    scroll_tries=20
    Should Be True    "${result}" == "True"    ${option} is not Open.

SET TIME FORMAT
    [Arguments]    ${time_format}
    [Documentation]    Set the time format to ${time_format}
    ...    ${timeformat}    12h/24h
    LAUNCH APP APPIUM    Settings
    Sleep    5s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Date & time' or @text='Date and time']    direction=down    scroll_tries=12
    Should Be True    ${result}
    APPIUM_TAP_XPATH    //*[@text='Date & time' or @text='Date and time']
    APPIUM_TAP_XPATH    //*[@text='Time format']
    APPIUM_TAP_XPATH    //*[@text='${time_format}']
    APPIUM_TAP_XPATH    ${back_button}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${time_format}']    direction=down    scroll_tries=12
    Should Be True    ${result}    Time format not set to ${time_format}.
    GO HOME AND CLEAR SETTINGS APP    ${ivi_adb_id}

SET KITCHEN SINK PROPERTY TEST
    [Arguments]    ${property_type}    ${value}
    [Documentation]    To set ${property_type} for PROPERTY TEST to ${value}
    ...    ${property_type}    parameter in Vehicle Stub
    ...    ${value}    value(true/false) of ${property_type} to be set
    LAUNCH APP APPIUM    KitchenSink
    Sleep    10s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='HIDE KITCHENSINK MENU']    retries=10
    Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    //*[@text='SHOW KITCHENSINK MENU']
    APPIUM_TAP_XPATH    //*[@text='PROPERTY TEST']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@resource-id='com.google.android.car.kitchensink:id/sPropertyId']
    ${element_found} =   APPIUM_WAIT_FOR_XPATH    xpath=//*[@text='${property_type}']    direction=down    scroll_tries=25
    Run Keyword If    "${element_found}" == "True"   APPIUM_TAP_XPATH    //*[@text='${property_type}']
    APPIUM_TAP_XPATH    //*[@resource-id='com.google.android.car.kitchensink:id/etSetPropertyValue']
    FOR    ${var}    IN RANGE   0  5
       APPIUM_PRESS_KEYCODE    ${KEYCODE_DELETE}
    END
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.google.android.car.kitchensink:id/etSetPropertyValue']    retries=20
    Run Keyword If    "${result}" == "True"    APPIUM_ENTER_TEXT    com.google.android.car.kitchensink:id/etSetPropertyValue   ${value}
    APPIUM_TAP_XPATH    //*[@text='SET']
    SLEEP    5s
    APPIUM_TAP_XPATH    //*[@text='GET']
    ${var} =    APPIUM_GET_TEXT    //*[@resource-id='com.google.android.car.kitchensink:id/tvGetPropertyValue']
    Should Contain    ${var}    value=${value}

CHECKSET ALLIANCE KITCHEN SINK ECONAV
    [Arguments]    ${status}
    [Documentation]    check and set econav button to required state(on/off)
    ...    ${status}    on/off
    ${econav_button} =    Set Variable If    "${status}".lower() == "on"    ${econav_on_button}
    ...    "${status}".lower() == "off"    ${econav_off_button}
    should not be Equal    ${status}    ${None}    Invalid status: ${status}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${econav_button}
    Return From Keyword If    "${result}" == "True"    Econav is already set to: ${status}
    APPIUM_TAP_XPATH    ${econav_on_off}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${econav_button}
    Should Be True    "${result}" == "True"    Failed to set Econav to: ${status}

CHECK KITCHEN SINK PROPERTY TEST 
    [Arguments]    ${property_type}    ${status}
    [Documentation]    To check ${property_type} for PROPERTY TEST to ${status}
    ...    ${property_type}    parameter in Property Test
    ...    ${status}    value of ${property_type} to check
    LAUNCH APP APPIUM    KitchenSink
    Sleep    5s
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='HIDE KITCHENSINK MENU']    retries=10
    Run Keyword If    "${result}" == "False"    APPIUM_TAP_XPATH    //*[@text='SHOW KITCHENSINK MENU']
    APPIUM_TAP_XPATH    //*[@text='PROPERTY TEST']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@resource-id='com.google.android.car.kitchensink:id/sPropertyId']
    ${element_found} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='${property_type}']    from_xpath_element=//*[@resource-id='android:id/text1']    direction=down    scroll_tries=100
    Should Be True    ${element_found}    Failed to Find the property type
    APPIUM_TAP_XPATH    //*[@text='${property_type}']
    Sleep    5s
    APPIUM_TAP_XPATH    //*[@text='GET']
    ${var} =    APPIUM_GET_TEXT    //*[@resource-id='com.google.android.car.kitchensink:id/tvGetPropertyValue']
    Should Contain    ${var}    ${status}

CHECK PROPERTY VALUE ENERGY CONSUMPTION
    [Arguments]    ${property}    ${value}
    [Documentation]    To Check the Property: ${property} is corresponding to value: ${value}
    ...    ${property}    property in energy consumption
    ...    ${value}    value of ${property} to check
    Log To Console    To Check the Property: ${property} is corresponding to value: ${value}
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    10s
    APPIUM_TAP_XPATH    //*[@content-desc='AllianceKitchenSink' or @content-desc='Open drawer']
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='Energy Consumption']    direction=down    scroll_tries=25
    Should Be True    ${result}    Failed to find Energy Consumption
    APPIUM_TAP_XPATH    //*[@text='Energy Consumption']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${property}']    direction=down    scroll_tries=20
    Should be true    ${result}    Failed to Find the property: ${property}
    APPIUM_TAP_XPATH    //*[@text='${property}']
    ${var} =    APPIUM_GET_TEXT    //*[@resource-id='com.alliance.car.kitchensink:id/txt_auxiliaries_consumption']
    Should Contain    ${var}    ${value}

SET LAUNCH SUW
    [Arguments]    ${target_id}
    [Documentation]    Set Launch SetupWizard on ${target_id}
    ...    ${target_id}: target_id of dut
    Log To Console    Set Launch SetupWizard on ${target_id}
    ADB_SET_ROOT
    ${user_name} =    GET CURRENT USER NAME
    ${user_id} =    GET USER ID BY NAME    ${user_name}
    OperatingSystem.Run    adb -s ${target_id} shell am kill --user ${user_id} com.google.android.car.setupwizard
    OperatingSystem.Run    adb -s ${target_id} shell am force-stop com.google.android.car.setupwizard
    OperatingSystem.Run    adb -s ${target_id} shell pm clear --user ${user_id} com.google.android.car.setupwizard
    OperatingSystem.Run    adb -s ${target_id} shell settings put global device_provisioned 0
    OperatingSystem.Run    adb -s ${target_id} shell settings put global policy_control null
    OperatingSystem.Run    adb -s ${target_id} shell settings --user ${user_id} put secure android.car.ENABLE_INITIAL_NOTICE_SCREEN_TO_USER 1
    OperatingSystem.Run    adb -s ${target_id} shell settings --user ${user_id} put secure user_setup_complete 0
    OperatingSystem.Run    adb -s ${target_id} shell pm enable --user ${user_id} com.google.android.car.setupwizard/.CarSetupWizardActivity
    OperatingSystem.Run    adb -s ${target_id} shell am start --user ${user_id} -n com.google.android.car.setupwizard/.CarSetupWizardActivity

SET SETUP WIZARD A12
    [Arguments]    ${data_sharing}=ON    ${after_factory_reset}=False
    [Documentation]    Perform setup wizard process on the newly created user
    ...    ${data_sharing}: ON / OFF. ON for sharing and OFF for not sharing
    Sleep    15
    CREATE APPIUM DRIVER    SetupWizardOverlay
    IF    "${after_factory_reset}" == "True"
        APPIUM_TAP_XPATH    ${language_selection_icon}
        Sleep    5
        SCROLL TO EXACT ELEMENT    element_id_or_xpath=${english}    direction=down
        APPIUM_TAP_XPATH    ${english}    retries=20
        Sleep    5
        SCROLL TO EXACT ELEMENT    element_id_or_xpath=${english}    direction=down
        APPIUM_TAP_XPATH    ${english}    retries=20
        Sleep    5
    END
    APPIUM_TAP_XPATH    ${begin}    retries=20
    Sleep    5
    ${suw_first_screen} =   APPIUM_WAIT_FOR_XPATH    ${begin}
    Should Not Be True    ${suw_first_screen}    Failure due to bug: CCSEXT-90971
    ${confirm_present} =   APPIUM_WAIT_FOR_XPATH    ${confirm}
    Run Keyword If    "${confirm_present}" == "${True}"    APPIUM_TAP_XPATH    ${confirm}
    APPIUM_TAP_XPATH    ${accept_all}    retries=20
    APPIUM_TAP_XPATH    ${accept}    retries=20
    ${skip_present} =   APPIUM_WAIT_FOR_XPATH    ${skip}
    Run Keyword If    "${skip_present}" == "${True}"    APPIUM_TAP_XPATH    ${skip}
    ${next_present} =   APPIUM_WAIT_FOR_XPATH    ${next}
    Run Keyword If    "${next_present}" == "${True}"    APPIUM_TAP_XPATH    ${next}
    APPIUM_TAP_XPATH    ${accept}    retries=20
    Sleep    3

CHECKSET TRUSTED CLOCK REQUIRED
    [Arguments]    ${status}
    [Documentation]    Check and set the Trusted Clock Required State
    Log To Console    Setting Trusted Clock Required state: ${status}
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Trusted Clock Required']
    ${result_1} =   Run Keyword If    "${result}" == "${False}"    SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='Trusted Clock Required']    direction=down    scroll_tries=10
    Run Keyword If    "${result}" == "${False}"    Should Be True    ${result_1}
    ...    ELSE    Should Be True    ${result}
    ${isToggleEnabled} =      Set Variable If    "${result_1} " == "${True}" or "${result} " == "${True}"   OFF    ON
    Run Keyword If    "${isToggleEnabled}" == "OFF" and "${status}" == "on"    APPIUM_TAP_XPATH    //*[@text='Trusted Clock Required']
    Run Keyword If    "${isToggleEnabled}" == "ON" and "${status}" == "off"    Log to Console    Trusted Clock Required is already disabled
    ...    ELSE   Log to Console    Unable to Check and set the Trusted Clock Required State of the DUT.

CHECKSET ACCUMULATED GARAGE MODE TIME
    [Arguments]    ${time} 
    [Documentation]    check and set the ACCUMULATED GARAGE MODE TIME
    ${output_check} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings get global ""GARAGE_STORE_TIME""
    Run Keyword And Return If    "${output_check}" == "${time}"    Log to Console    CHECK ACCUMULATED GARAGE MODE TIME already set to ${time}
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings put global ""GARAGE_STORE_TIME"" ${time}
    ${output_set} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell settings get global ""GARAGE_STORE_TIME""
    Should Be True    "${output_set}" == "${time}"

SET ENABLER VOICE RECOGNITION COMMAND   
	[Arguments]    ${config_name}=demo_avatar    ${objects_names_in_image}=@{objects_names_in_image}    ${image_name}=avatar.png    ${audio_file}=hey_reno    ${message1}=onAnimatedDialogStarted animationId    ${message2}=animatedDialogStepCompleted
    [Documentation]    play ${audio_file} and detect the avatar by image and check it by turkey object detection and by logcat
    OBJECT DETECTION SETUP    ${config_name} 
    SET LOGCAT TRIGGER    ${message1}
    SET LOGCAT TRIGGER    ${message2}
    START ANALYZING LOGCAT DATA
    VPA PLAY AUDIO FILE    ${audio_file}
    CHECK SOUND    loud_speaker    present  #Take the place of CHECK BEEP SOUND     ${sound_channel}    ${status_on}: will be done by Matrix:MATRIX-72166 
    DETECT OBJECT BY IMAGE    ${objects_names_in_image}    ${image_name}
    WAIT FOR LOGCAT TRIGGER    ${message1}    timeout=${10}
    WAIT FOR LOGCAT TRIGGER    ${message2}    timeout=${10}

DO LIST ALLIANCE CAR SERVICE SERVICES
    [Arguments]    ${load_services}
    [Documentation]    To get the list of alliance_car_service services
    RUN COMMAND AND CHECK RESULT    "cmd alliance_car_service list-services"    ${load_services}

DO IVI ENABLE CHARGE PROGRAMS    
    [Documentation]     Enable EV Charge Programs from PROGRAM menu.    
    Log To Console    Enable EV Charge Programs from PROGRAM menu.    
    APPIUM_TAP_XPATH    //*[@text='Programs' or @text='Programmes']    
    APPIUM_TAP_XPATH    //*[@text='My programs']    
    Sleep    10s    
    FOR    ${index}    IN RANGE    1    3       
        ${status} =    APPIUM_WAIT_FOR_XPATH    ${EV_services['program_status']}       
        Exit For Loop If    "${status}"=="False"        
        APPIUM_TAP_XPATH    ${EV_services['program_status']}    
    END

READ CONFIGURATION PARAMETER
    [Arguments]    ${parameter_path}
    [Documentation]    To read configuration parameter value
    ...    ${parameter_path}    configuration parameter path value
    ADB_SET_ROOT
    Sleep    1    reason=Switching to adb root...
    ${output}    ${error} =    SEND ADB COMMAND    cmd DiagAdb Configuration get ${parameter_path}
    ${output} =    Convert To String    ${output}
    ${string_output} =    Remove String    ${output}    b'
    ${string_output} =    Remove String    ${string_output}    '
    ${string_output} =    Strip String    ${string_output}    mode=right    characters=\\n
    @{string_list} =    Split String    ${string_output}    \\n
    [Return]    ${string_list}[-1]

CHECK POWER REGISTER VALUE 
    [Arguments]    ${value}
    [Documentation]    To check Derating register ${value}
    ...    ${value}    value of Drating register to check
    LAUNCH APP APPIUM    AllianceKitchensink
    Sleep    10s
    APPIUM_TAP_XPATH   ${AllianceKitchenSink['alliance_ks_App']}
    Sleep    5s
    ${result} =   SCROLL TO EXACT ELEMENT    element_id_or_xpath=//*[@text='Power']    direction=down    scroll_tries=25
    APPIUM_TAP_XPATH    //*[@text='Power']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='DERATING UNREGISTER']    retries=20
    Run Keyword If    "${result}" == "${False}"    APPIUM_TAP_XPATH    ${AllianceKitchenSink['derating_register']}
    ${result} =   APPIUM_GET_TEXT    ${AllianceKitchenSink['derating_value']}
    Should Contain    ${result}    ${value}    ${value} not present in current screen of ${ivi_adb_id}

SET EDIT IVI SMART CHARGING
    [Arguments]    ${required_vehicle_ready_time}    ${offpeak_hours_start}    ${offpeak_min_start}    ${offpeak_hours_end}    ${offpeak_min_end}
    [Documentation]    edit ivi smart charning off_peak_hours for Program1
    LAUNCH APP APPIUM    EvMenu
    APPIUM_TAP_XPATH    ${Peak_Hours['programmes']}
    APPIUM_TAP_XPATH    ${Peak_Hours['my_programs']}
    APPIUM_TAP_XPATH    ${Peak_Hours['program1']}
    SET TIME FOR READY AT    ${required_vehicle_ready_time}
    APPIUM_TAP_XPATH    ${Peak_Hours['save']}
    APPIUM_TAP_XPATH    ${Peak_Hours['charge_settings']}
    APPIUM_TAP_XPATH    ${Peak_Hours['time_setting']}
    SET HOUR    ${offpeak_hours_start}    ${offpeak_hours_end}
    SET MINUTE    ${offpeak_min_start}    ${offpeak_min_end}
    APPIUM_TAP_XPATH    ${Peak_Hours['save']}
    APPIUM_TAP_XPATH    ${Peak_Hours['save']}

SET TIME FOR VEHICLE READY AT
    [Arguments]    ${required_vehicle_ready_time}
    [Documentation]    Setting Readytime
    FOR    ${i}    IN RANGE    1    24
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH    ${Peak_Hours['start_vehicle_ready_time']}
        ${coordinates} =    APPIUM_GET_XPATH_LOCATION     ${Peak_Hours['start_vehicle_ready_time_scroll']}
        ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
        ${y2} =    Evaluate    ${y1} + 60
        IF    "${retrieved_text}" != "${required_vehicle_ready_time}"
            swipe_by_coordinates    ${x1}    ${y1}    ${x1}    ${y2}    2000
        ELSE
            Log To Console    Start hour time is set
            BREAK
        END
    END

SET HOUR
    [Arguments]    ${offpeak_hours_start}    ${offpeak_hours_end}
    [Documentation]    Setting hour time
    FOR    ${i}    IN RANGE    1    24
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH     ${Peak_Hours['start_hour']}
        ${coordinates} =    APPIUM_GET_XPATH_LOCATION    ${Peak_Hours['start_hour_scroll']}
        ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
        ${y2} =    Evaluate    ${y1} + 60
        IF    "${retrieved_text}" != "${Offpeak_hours_start}"
            swipe_by_coordinates    ${x1}    ${y1}    ${x1}    ${y2}    2000
        ELSE
            Log To Console    Start hour time is set
            BREAK
        END
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH     ${Peak_Hours['end_hour']}
        ${coordinates} =    APPIUM_GET_XPATH_LOCATION    ${Peak_Hours['end_hour_scroll']}
        ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
        ${y2} =    Evaluate    ${y1} + 60
        IF    "${retrieved_text}" != "${offpeak_hours_end}"
            swipe_by_coordinates    ${x1}    ${y1}    ${x1}    ${y2}    2000
        ELSE
            Log To Console    End hour time is set
            BREAK
        END
    END

SET MINUTE
    [Arguments]    ${offpeak_min_start}    ${offpeak_min_end}
    [Documentation]    Setting minute time
    FOR    ${i}    IN RANGE    1    60
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH     ${Peak_Hours['start_min']}
        ${coordinates} =    APPIUM_GET_XPATH_LOCATION    ${Peak_Hours['start_min_scroll']}
        ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
        ${y2} =    Evaluate    ${y1} + 60
        IF    "${retrieved_text}" != "${offpeak_min_start}"
            swipe_by_coordinates    ${x1}    ${y1}    ${x1}    ${y2}    2000
         ELSE
            Log To Console    Start minute time is set
            BREAK
        END
        ${retrieved_text} =    APPIUM_GET_TEXT_USING_XPATH     ${Peak_Hours['end_min']}
        ${coordinates} =    APPIUM_GET_XPATH_LOCATION    ${Peak_Hours['end_min_scroll']}
        ${x1}    ${y1} =    Get Dictionary Values    ${coordinates}
        ${y2} =    Evaluate    ${y1} + 60
        IF    "${retrieved_text}" != "${offpeak_min_end}"
            swipe_by_coordinates    ${x1}    ${y1}    ${x1}    ${y2}    2000
        ELSE
            Log To Console    End minute time is set
            BREAK
        END
    END
