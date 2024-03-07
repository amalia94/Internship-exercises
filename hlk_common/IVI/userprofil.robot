#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     user profil - keywords library
Library           rfw_services.ivi.UserProfilLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Resource          app_management.robot
Variables         ${CURDIR}/../../hlk_common/unsorted/on_board_ids.yaml

*** Variables ***
${target}         ${None}

*** Keywords ***
SET ADD GOOGLE ACCOUNT
    [Arguments]    ${target}    ${login}    ${pwd}
    add_google_account    ${login}    ${pwd}

SET REMOVE GOOGLE ACCOUNT
    [Arguments]    ${target}
    remove_google_account

CHECKSET UNINSTALL APP FROM PLAYSTORE
    [Arguments]    ${app}
    Log To Console    Uninstalls an app: ${app} from the Playstore
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    PlayStore2
    FIND_APPLICATION_IN_GOOGLESTORE    ${app_package}    ${app_activity}    ${app}
    APPIUM_TAP_XPATH    ${PlayStore['first_app_found']}
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Install']    10
    Run Keyword If    "${res}" == "True"    log to console    ${app} need to be installed
    Run Keyword If    "${res}" != "True"    SET UNINSTALL APP FROM PLAYSTORE    ${app}
    SET CLOSE APP    ivi    PlayStore

SET UNINSTALL APP FROM PLAYSTORE
    [Arguments]    ${app}
    TAP BY XPATH    //*[@text='Uninstall']
    SLEEP    5
    TAP BY XPATH    //*[@text='Uninstall']
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Install']    30
    Should Be True    ${res}    Not able to Uninstall the ${app}
    APPIUM_TAP_XPATH    //*[@resource-id='com.android.vending:id/car_ui_toolbar_nav_icon']
    APPIUM_TAP_XPATH    //*[@resource-id='com.android.vending:id/car_ui_toolbar_nav_icon']

CHECKSET INSTALL APP FROM PLAYSTORE
    [Arguments]    ${app}    ${background_install}=False
    Log To Console    Installs an app: ${app} on ${target} from the Playstore
    ${app_package}    ${app_activity} =    GET PACKAGE AND ACTIVITY NAME FROM APP    PlayStore2
    FIND_APPLICATION_IN_GOOGLESTORE    ${app_package}    ${app_activity}    ${app}
    APPIUM_TAP_XPATH    ${PlayStore['first_app_found']}
    Sleep    3s
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['install_button']}   10
    Run Keyword And Return If    "${res}" == "True" and "${background_install}" == "True"    APPIUM_TAP_XPATH    ${PlayStore['install_button']}
    Run Keyword If    "${res}" == "False"    log to console    App is already installed
    Run Keyword If    "${res}" == "True"    SET INSTALL APP FROM PLAYSTORE    ${app}
    SET CLOSE APP    ivi    PlayStore

SET INSTALL APP FROM PLAYSTORE
    [Arguments]    ${app}
    APPIUM_TAP_XPATH    ${PlayStore['install_button']}
    SLEEP    40
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${PlayStore['uninstall_button']}    60
    Should Be True    ${res}    Not able to install the ${app}
    APPIUM_TAP_XPATH    ${PlayStore['nav_icon']}
    APPIUM_TAP_XPATH    ${PlayStore['nav_icon_container']}

CHECKSET PLAYSTORE LOGIN
    [Arguments]    ${g_login}    ${g_pwd}
    Log To Console    Launching Playstore and signin
    ${comment}  ${verdict}=    Run Keyword And Ignore Error    LAUNCH APP APPIUM    PlayStore
    Sleep    10s
    Run Keyword If    "${verdict}" != "True"    LAUNCH APP APPIUM    PlayStore2
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Sign in']    20
    Run Keyword If    "${res}" == "False"    log to console    Sigin in is already done
    ...    ELSE    SET PLAYSTORE LOGIN    ${g_login}    ${g_pwd}

SET PLAYSTORE LOGIN
    [Arguments]    ${g_login}    ${g_pwd}
    TAP BY XPATH    ${User_profile['play_store_sign_in']}
    Sleep    5s
    APPIUM_TAP_XPATH    ${User_profile['play_store_car_sign_in']}
    Sleep    5s
    APPIUM_TAP_XPATH    ${User_profile['play_store_id']}
    Sleep    5s
    APPIUM_TAP_XPATH    ${User_profile['play_store_g_login']}
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['play_store_g_login']}    ${g_login}
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    APPIUM_TAP_XPATH    ${User_profile['play_store_pwd']}
    APPIUM_ENTER_TEXT_XPATH    ${User_profile['play_store_g_pwd']}    ${g_pwd}
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    50s
    APPIUM_TAP_XPATH    ${User_profile['done_button']}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${PlayStore['search']}
    Run Keyword If    "${result}" == "True"    log to console    Sigin in is done

DO INSTALL RADIOLINE APP
    [Arguments]    ${gas_login}    ${gas_pswd}
    [Documentation]    Install the RadioLine application
    ...    == Parameters: ==
    ...    - gas_login: login user
    ...    - gas_pswd: login password
    CHECKSET PLAYSTORE LOGIN       ${gas_login}    ${gas_pswd}
    SLEEP    5
    CHECKSET INSTALL APP FROM PLAYSTORE    Radioline

DO SEARCH A STATION IN RADIOLINE
    [Documentation]    Checks if inside RadioLine application in Local Stations tab the list of stations is loaded
    SET LAUNCH APP    ivi    RadioLine
    Sleep    60
    ${res} =    APPIUM_WAIT_FOR_ELEMENT    ${MusicPlayer['radio_container']}    60
    Run keyword if    ${res} == True    Run keywords    APPIUM_TAP_ELEMENTID    ${MusicPlayer['radio_container']}
    ...     AND    APPIUM_TAP_XPATH    //*[@text='Radioline']

    APPIUM_TAP_XPATH    //*[@text='Stations']    60
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='BBC Radio 1']    60
    Should Be True    ${res}

DO LOGIN PLAYER APP
    [Arguments]    ${spotify_login}    ${spotify_pwd}    ${player}=Spotify
    LAUNCH APP APPIUM    PlayStore2
    APPIUM_TAP_XPATH    ${PlayStore['search']}
    ENTER TEXT    ${PlayStore['search_inbox']}    ${player}
    Sleep    3s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    3s
    APPIUM_TAP_XPATH    ${PlayStore['first_app_found']}
    Sleep    3s
    TAP_ON_ELEMENT_USING_XPATH   ${PlayStore['open_app']}  10
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Log in']    10
    Run Keyword And Return If    "${res}" == "False"    log to console    Singin is already done
    TAP BY XPATH    //*[@text='Log in']
    Sleep    2s
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@resource-id='com.spotify.music:id/error_text']    10
    Run Keyword And Return If    "${res}" == "True"    log to console    Spotify is offline
    APPIUM_TAP_XPATH    //*[@text='LOG IN USING PASSWORD']
    Sleep    3s
    APPIUM_TAP_XPATH    //*[@resource-id='com.spotify.music:id/login_username']
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell input text ${spotify_login}
    APPIUM_TAP_XPATH    //*[@resource-id='com.spotify.music:id/login_password']
    Sleep    2s
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell input text ${spotify_pwd}
    APPIUM_TAP_XPATH    //*[@text='LOG IN']
    Sleep    20
    ${res} =    APPIUM_WAIT_FOR_XPATH    //*[@text='Home']    10
    Run Keyword And Return If    "${res}" == "True"    log to console    Signed in perfectly

DO AUDIO PLAYER
    [Arguments]    ${player}    ${song}
    Sleep    5s
    START INTENT    -n com.android.car.media/com.android.car.media.MediaActivity
    Sleep    3s
    ${res} =    APPIUM_WAIT_FOR_ELEMENT    ${MusicPlayer['radio_container']}    10
    Run keyword if    ${res} == True    Run keywords    APPIUM_TAP_ELEMENTID    ${MusicPlayer['radio_container']}
    ...     AND    APPIUM_TAP_XPATH    //*[@text='${player}']
    Run keyword if    ${res} != True    Run keywords    APPIUM_TAP_XPATH    ${MusicPlayer['switch_app']}
    ...    AND    APPIUM_TAP_XPATH    //*[@text='${player}']
    Sleep    2s
    TAP BY XPATH    //*[@content-desc='Search']
    Sleep    2s
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell input text ${song}
    Sleep    2s
    ${text_plug_type} =    APPIUM_GET_TEXT    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[1]/android.widget.TextView[1]
    TAP BY XPATH    //androidx.recyclerview.widget.RecyclerView/android.view.ViewGroup[1]/android.widget.TextView[1]

CHECK APP
    [Arguments]    ${player}    ${state}
    ${status} =    Set Variable If    "${state}" == "online"    Home    "${state}" == "offline"    There was a connection problem. Please try again.
    ...    ELSE    Log To Console    Invalid data for status:${status}
    Sleep    1s
    DO LOGIN PLAYER APP    ${spotify_login}    ${spotify_pwd}    ${player}
    Sleep    3s
    ${check} =    APPIUM_GET_TEXT    //android.view.ViewGroup/android.widget.FrameLayout/android.widget.LinearLayout/android.widget.TextView[1]
    Should Be Equal    ${check}    ${status}

VIEW GOOGLE TERMS AND SETTINGS
    [Documentation]    == High Level Description: ==
    ...    View and Accept Google terms and Services
    APPIUM_WAIT_FOR_ELEMENT    com.renault.setupwizardoverlay:id/text_google_intro_title    3
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['accept_google_services']}    55

CLICK FINISH SETTING UP USER PROFILE
    [Documentation]    == High Level Description: ==
    ...    Finish Setting Profile
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    expand
    Should Be True    ${verdict}
    Sleep    5s
    TAP_ON_ELEMENT_USING_XPATH     ${User_profile['finish_setting_profile']}    60

VIEW PRIVACY INFO ON WELCOME SCREEN
    [Documentation]    == High Level Description: ==
    ...    View Privacy information
    TAP_ON_ELEMENT_USING_ID     ${User_profile['privacy_info_icon']}    60
    APPIUM_WAIT_FOR_XPATH    ${User_profile['privacy_terms_title']}    10
    TAP_ON_ELEMENT_USING_ID     ${User_profile['navigate_back_from_privacy_page']}    60

CHANGE DATA COLLECTION SETTINGS ON WELCOME SCREEN
    [Documentation]    == High Level Description: ==
    ...    Change data collection status on welcome screen
    APPIUM_WAIT_FOR_ELEMENT     ${User_profile['welcome_user_title']}    10
    TAP_ON_ELEMENT_USING_ID     ${User_profile['welcome_data_collection_switch']}    5
    TAP_ON_ELEMENT_USING_ID     ${User_profile['welcome_user_settings_ok_button']}    5

CHECK MY RENAULT ACCOUNT NOTIFICATION IS NOT DISPLAYED
    [Documentation]    == High Level Description: ==
    ...    Check there are no myrenault notifications in Notification Manager
    APPIUM_SCROLL_NOTIFICATION_BAR     620    20    620    250
    @{myrenault_notification} =    APPIUM_GET_ELEMENTS_BY_XPATH    ${User_profile['no_myrenault_account_notification']}
    Length Should Be    ${myrenault_notification}    0

VERIFY GOOGLE TERMS SCREEN CONTENT
    [Documentation]    == High Level Description: ==
    ...    Verify screen content and Accept Google terms and Services
    TAP_ON_ELEMENT_USING_XPATH     ${User_profile['view_terms_and_data_settings']}    60
    ${ele1} =    APPIUM_GET_TEXT    ${User_profile['location_data']}    10
    Should Contain    ${ele1}    Let apps use your vehicle
    ${ele2} =    APPIUM_GET_TEXT    ${User_profile['diagnostic_data']}    10
    Should Contain    ${ele2}    Send usage and diagnostic data
    ${ele3} =    APPIUM_GET_TEXT    ${User_profile['auto_update']}    10
    Should Contain    ${ele3}    Auto-install updates and apps
    ${ele4} =    APPIUM_GET_TEXT    ${User_profile['auto_download']}    10
    Should Contain    ${ele4}    Auto-download maps
    TAP_ON_ELEMENT_USING_XPATH    ${User_profile['accept_google_services']}    55

VERIFY SETUP GOOGLE ASSISTANT
    [Documentation]    == High Level Description: ==
    ...    Verify screen content in customise your profile page
    ${ele1} =    APPIUM_GET_TEXT    ${User_profile['google_assistant']}    10
    Should Contain    ${ele1}    Set up Google Assistant and apps

VERIFY SELECTED USER ON WELCOME SCREEN
    [Documentation]    == High Level Description: ==
    ...    Verify the Correct user info is displayed on welcome screen
    [Arguments]    ${ivi_user_profile_name}
    START INTENT    com.renault.profilesettingscenter/com.renault.profilesettingscenter.ui.view.WelcomeActivity
    ${selected_profile} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    //*[@text='${ivi_user_profile_name}']    selected
    Should Be True    "${selected_profile}" == "true"     The user profile selected is not correct

CHANGE LOCK TYPE PIN TO PATTERN
    [Arguments]    ${ivi_user_pincode}    ${ivi_user_pattern}
    [Documentation]    == High Level Description: ==
    ...    Change a lock type from PIN to PATTERN
    ...    == Parameters: ==
    ...    - ivi_user_pin_code: A 4 digit pin code which needs to be assigned to the user(ex: 1234)
    ...    - ivi_user_pattern: A pattern in number format(Eg: 12369)
    ...    == Expected Results: ==
    ...    output: Pin code assignment to the user should be success
    SELECT SECURITY LOCK TYPE OPTION
    TAP_ON_ELEMENT_USING_ID    ${User_profile['password_entry']}    30
    sleep    2
    UNLOCK PROFILE USING PINCODE    ${ivi_user_pincode}    True
    SETUP_PATTERN_FOR_USER    ${ivi_user_pattern}    False

CHANGE LOCK TYPE PASSWORD TO PATTERN
    [Arguments]    ${ivi_user_password}    ${ivi_user_pattern}
    [Documentation]    == High Level Description: ==
    ...    Change a lock type from PIN to PATTERN
    ...    == Parameters: ==
    ...    - ivi_user_password: A password for the profile
    ...    - ivi_user_pattern: A pattern in number format(Eg: 12369)
    ...    == Expected Results: ==
    ...    output: Pin code assignment to the user should be success
    SELECT SECURITY LOCK TYPE OPTION
    TAP_ON_ELEMENT_USING_ID    ${User_profile['password_entry']}    30
    UNLOCK PROFILE USING PASSWORD    ${ivi_user_password}    True
    SETUP_PATTERN_FOR_USER    ${ivi_user_pattern}    False

CHANGE LOCK TYPE PATTERN TO PASSWORD
    [Arguments]    ${ivi_user_pattern}    ${ivi_user_password}
    [Documentation]    == High Level Description: ==
    ...    Change a lock type from PIN to PATTERN
    ...    == Parameters: ==
    ...    - ivi_user_password: A password for the profile
    ...    - ivi_user_pattern: A pattern in number format(Eg: 12369)
    ...    == Expected Results: ==
    ...    output: Pin code assignment to the user should be success
    SELECT SECURITY LOCK TYPE OPTION
    UNLOCK PROFILE USING PATTERN    ${ivi_user_pattern}    True
    SETUP_PASSWORD_FOR_USER    ${ivi_user_password}    False

CHANGE LOCK TYPE PIN TO PASSWORD
    [Arguments]    ${ivi_user_pin_code}    ${ivi_user_password}
    [Documentation]    == High Level Description: ==
    ...    Change a lock type from PIN to PATTERN
    ...    == Parameters: ==
    ...    - ivi_user_pin_code: A 4 digit pin code which needs to be assigned to the user(ex: 1234)
    ...    - ivi_user_pattern: A pattern in number format(Eg: 12369)
    ...    == Expected Results: ==
    ...    output: Pin code assignment to the user should be success
    SELECT SECURITY LOCK TYPE OPTION
    TAP_ON_ELEMENT_USING_ID    ${User_profile['password_entry']}    30
    sleep    2
    UNLOCK PROFILE USING PINCODE    ${ivi_user_pincode}    True
    SETUP_PASSWORD_FOR_USER    ${ivi_user_password}    False

CHANGE LOCK TYPE PATTERN TO PIN
    [Arguments]    ${ivi_user_pattern}    ${ivi_user_pin_code}
    [Documentation]    == High Level Description: ==
    ...    Change a lock type from PATTERN to PIN
    ...    == Parameters: ==
    ...    - ivi_user_pattern: A pattern in number format(Eg: 12369)
    ...    - ivi_user_pin_code: A 4 digit pin code which needs to be assigned to the user(ex: 1111)
    ...    == Expected Results: ==
    ...    output: Pattern assignment to the user should be success
    SELECT SECURITY LOCK TYPE OPTION
    UNLOCK PROFILE USING PATTERN    ${ivi_user_pattern}    True
    SETUP_PINCODE_FOR_USER    ${ivi_user_pin_code}    False

CHANGE LOCK TYPE PASSWORD TO PIN
    [Arguments]    ${ivi_user_password}    ${ivi_user_pincode}
    [Documentation]    == High Level Description: ==
    ...    Change a lock type from PIN to PATTERN
    ...    == Parameters: ==
    ...    - ivi_user_pincode: A 4 digit pin code which needs to be assigned to the user(ex: 1234)
    ...    - ivi_user_password: A password for the profile
    ...    == Expected Results: ==
    ...    output: Pin code assignment to the user should be success
    SELECT SECURITY LOCK TYPE OPTION
    UNLOCK PROFILE USING PASSWORD    ${ivi_user_password}    True
    SETUP_PINCODE_FOR_USER    ${ivi_user_pincode}    False

