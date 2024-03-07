#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Library to support FM radio functionnality
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Variables         ../unsorted/on_board_ids.yaml
Variables         ${CURDIR}/KeyCodes.yaml

*** Variables ***
${platform_name}      Android
${android_version}    10
&{radio}                    appPackage_ivi=com.renault.radio    activityName_ivi=.view.RadioActivity
${AM}                       //*[@text='AM']
${FM}                       //*[@text='FM']
${DAB}                      //*[@text='DAB']
${band_type}                //*[@resource-id='android:id/text1']
${previous_button}          //*[@resource-id='com.renault.radio:id/btn_skip_previous']
${next_button}              //*[@resource-id='com.renault.radio:id/btn_skip_next']
${control_bar}              //*[@resource-id='com.renault.radio:id/minimized_control_bar_layout']
${control_bar_myf3}          //*[@resource-id='com.renault.car.media:id/minimized_control_bar']
${previous_button_MYF3_accessda}    //*[@resource-id='com.renault.car.media:id/skip_prev']
${next_button_MYF3_accessda}        //*[@resource-id='com.renault.car.media:id/skip_next']
${control_bar_MYF3_accessda}        //*[@resource-id='com.renault.car.media:id/minimized_control_bar_layout']
${select_freq}              //*[@resource-id='com.renault.radio:id/tv_frequency' or @resource-id='com.renault.radio:id/frequency']
${new_freq}                 //*[@resource-id='com.renault.radio:id/textinput_placeholder']
${app_switch_container}     //*[@resource-id='com.renault.radio:id/app_switch_container']
${app_icon}                 //*[@text='Radio' or @text='Radio P3']
${favorite_channel}         //*[@resource-id='com.renault.radio:id/playback_favorite']
${favorite_button_myf3}    //*[@resource-id='com.renault.car.media:id/browse_item_favorite_star']
${Favourites}               //*[@text='Favourites' or @text='Favorites']
${presets}                  //*[@text='Presets']
${radio_icon}               //*[@resource-id='com.renault.radio:id/nav_icon' or @resource-id='com.renault.car.media:id/car_ui_toolbar_nav_icon']
${radio_icon_MYF3_accessda}         //*[@resource-id='com.renault.car.media:id/car_ui_toolbar_nav_icon']
${exit}                     //*[@resource-id='com.renault.radio:id/exit_button']
${title}                    //*[@resource-id='com.renault.radio:id/tv_title']
${test_freq}                99.9
${channel_button}           //*[@resource-id='com.renault.radio:id/minimized_control_bar_title']
${switch_channel}           //*[@resource-id='com.renault.radio:id/btn_skip_next']
${list_tab}                 //*[@resource-id='com.renault.radio:id/car_ui_toolbar_tab_item_text']
${minimized_player}         //*[@resource-id=com.renault.radio:id/minimized_player']

*** Keywords ***
SET_RADIO_APP_BAND_APPIUM
    [Arguments]    ${target_id}    ${radio_band}
    [Documentation]    Select the perticular ${radio_band}
    ...    ${target_id} the target either ivi or host pc
    ...    ${radio_band}    radio band to be slected AM/FM/DAB
    SET_SOURCE_TO_RADIO_APPIUM
    IF    "${ivi_my_feature_id}" == "MyF2"
        SET_RADIO_APP_BAND_APPIUM_A10    ${radio_band}
    ELSE
        SET_RADIO_APP_BAND_APPIUM_A12    ${radio_band}
    END

SET_RADIO_APP_BAND_APPIUM_A10
    [Arguments]    ${radio_band}
    APPIUM_TAP_XPATH    ${band_type}
    Sleep    5
    ${res} =    Run Keyword If    '${radio_band}'=='FM'    APPIUM_WAIT_FOR_XPATH    ${FM}
    Run Keyword If    '${radio_band}'=='FM' and '${res}' == 'True'    TAP BY XPATH    ${FM}
    ${res} =    Run Keyword If    '${radio_band}'=='AM'    APPIUM_WAIT_FOR_XPATH    ${AM}
    Run Keyword If    '${radio_band}'=='AM' and '${res}' == 'True'    TAP BY XPATH    ${AM}
    ${res} =    Run Keyword If    '${radio_band}'=='DAB'    APPIUM_WAIT_FOR_XPATH    ${DAB}
    Run Keyword If    '${radio_band}'=='DAB' and '${res}' == 'True'    TAP BY XPATH    ${DAB}

SET_RADIO_APP_BAND_APPIUM_A12
    [Arguments]    ${radio_band}
    APPIUM_TAP_XPATH    //*[@content-desc='Settings']
    APPIUM_TAP_XPATH    //*[@text='${radio_band}']
    ${coord}    ${center}    ${af_verdict} =    FIND IMAGE ON SCREEN APPIUM    af_enabled.png    90
    ${coord}    ${center}    ${region_verdict} =    FIND IMAGE ON SCREEN APPIUM    region_enabled.png    90
    Run Keyword If    "${af_verdict}"=="False"    APPIUM_TAP_XPATH    //*[@text='AF']
    Run Keyword If    "${region_verdict}"=="False"    APPIUM_TAP_XPATH    //*[@text='Region']
    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}

SET_RADIO_APP_MANUAL_FREQUENCY_APPIUM
    [Arguments]    ${frequency}
    [Documentation]    Select the radio channel by entering manually
    ...    ${frequency} radio channel frequency to enter
    IF    "${ivi_my_feature_id}" == "MyF1"
        SET_RADIO_APP_MANUAL_FREQUENCY_APPIUM_MYF1    ${frequency}
    ELSE
        SET_RADIO_APP_MANUAL_FREQUENCY_APPIUM_MYF2    ${frequency}
    END

SET_SOURCE_TO_RADIO_APPIUM
    [Arguments]    ${set_freq}=False    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    Select the source to play radio and if ${set_freq}=True will select a specific frequency
    LAUNCH APP APPIUM    MediaSource
    Sleep    5s
    ${result} =    APPIUM_WAIT_FOR_XPATH    ${app_icon}
    Run Keyword If    "${result}"=="False"    APPIUM_TAP_XPATH    //*[@content-desc='Switch apps']
    APPIUM_TAP_XPATH    ${app_icon}
    RUN KEYWORD IF    '${set_freq}'=='True'    TAP_ON_ELEMENT_USING_XPATH    //*[@text='List']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    RUN KEYWORD IF    '${set_freq}'=='True'    TAP_ON_ELEMENT_USING_XPATH    //*[@text='DigiFM' or @text='PROFM' or @text='MAGICFM']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    RUN KEYWORD AND IGNORE ERROR    TAP BY XPATH    ${exit}

SET_RADIO_APP_AUTO_FREQUENCY_APPIUM
    [Arguments]    ${action}
    [Documentation]    Changes the radio channel by slecting previous and next button
    ...    ${action}    action to be performed forward/backward
    SLEEP    3
    ${switch_apps} =    APPIUM_WAIT_FOR_XPATH    ${swtich_app_xpath}
    Run Keyword If    "${switch_apps}"=="True"    APPIUM_TAP_XPATH    ${swtich_app_xpath}    20
    APPIUM_TAP_XPATH    //*[@text='Radio']    20
    IF    "${platform_version}" == "10"
        ${Check_Radio} =    APPIUM_WAIT_FOR_XPATH    ${control_bar}
        Run Keyword If    "${Check_Radio}"=="True"    APPIUM_TAP_XPATH    ${control_bar}
    END
    Sleep    3s
    IF    "${platform_version}" == "10"
        RUN KEYWORD IF    '${action}'=='forward'    APPIUM_TAP_XPATH     ${next_button}
        RUN KEYWORD IF    '${action}'=='backward'    APPIUM_TAP_XPATH     ${previous_button}
    ELSE
        RUN KEYWORD IF    '${action}'=='forward'    APPIUM_TAP_XPATH     ${next_button_MYF3_accessda}
        RUN KEYWORD IF    '${action}'=='backward'    APPIUM_TAP_XPATH     ${previous_button_MYF3_accessda}
    END

SET_RADIO_APP_FREQUENCY_APPIUM
    [Arguments]    ${fm_freq1}    ${fm_freq2}    ${fm_freq_name1}    ${fm_freq_name2}    ${TC_folder}=${EMPTY}
    [Documentation]    Select the radio channel by slecting it from presets
    ...    ${fm_freq1}  radio channel frequency to enter
    ...    ${fm_freq2}  radio channel frequency to enter
    ...    ${fm_freq_name1}  radio channel name
    ...    ${fm_freq_name2}  radio channel name
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${presets}
    RUN KEYWORD IF    '${result}' == 'True'     TAP BY XPATH    ${presets}
    ...    ELSE    TAP BY XPATH    ${Favourites}
    FOR    ${frequency}    IN    ${fm_freq1}    ${fm_freq2}
        ${freq} =  set variable    ${frequency} MHz
        ${output} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${freq}']
        run keyword if    '${output}' == 'False'    ADD_FAVORITE_CHANNEL_APPIUM    ${frequency}
        Sleep    5s
    END
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${title}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${res}
    ...    ELSE    Should Be True    ${res}
    ${freq1} =  set variable    ${fm_freq1} MHz
    Sleep    10s
    ${res_freq_name1} =   RUN KEYWORD IF    '${fm_freq_name1}' != 'None'    APPIUM_WAIT_FOR_XPATH    //*[@text='${fm_freq_name1}']
    ${res_freq_name2} =   RUN KEYWORD IF    '${fm_freq_name2}' != 'None'    APPIUM_WAIT_FOR_XPATH    //*[@text='${fm_freq_name2}']
    RUN KEYWORD IF    '${fm_freq_name1}' != 'None' and '${res_freq_name1}' == 'True'    TAP BY XPATH    //*[@text='${fm_freq_name1}']
    ...    ELSE IF    '${fm_freq_name2}' != 'None' and '${res_freq_name2}' == 'True'    TAP BY XPATH    //*[@text='${fm_freq_name2}']
    ...    ELSE    TAP BY XPATH    //*[@text='${freq1}']

ADD_FAVORITE_CHANNEL_APPIUM
    [Arguments]    ${frequency}
    [Documentation]    To add faviorite channel by entering it
    ...    ${frequency} radio channel frequency to enter
    SHOULD NOT BE EQUAL    ${frequency}    None    please send a vaild frequency.
    APPIUM_TAP_XPATH    ${control_bar}
    Sleep    3s
    APPIUM_TAP_XPATH    ${select_freq}
    Sleep    3s
    APPIUM_TAP_XPATH    ${new_freq}
    Sleep    2s
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell input text ${frequency}
    Sleep    3s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    3s
    APPIUM_TAP_XPATH   ${favorite_channel}
    APPIUM_TAP_XPATH    ${radio_icon}

DO REMOVE FAVORITE CHANNEL APPIUM
    [Arguments]    ${target_id}    ${radio_band}    @{frequency_list}
    [Documentation]    Remove favorite channel from favorite list
    Log To Console    Remove favorite channel
    LAUNCH APP APPIUM    Radio
    SET_RADIO_APP_BAND_APPIUM    ${target_id}    ${radio_band}
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${presets}
    RUN KEYWORD IF    '${result}' == 'True'     TAP BY XPATH    ${presets}
    ...    ELSE    TAP BY XPATH    ${Favourites}
    FOR    ${val}    IN RANGE    2    4
        ${list_val} =    GET FROM LIST    ${frequency_list}    ${val}
        ${list_val} =    set variable    ${list_val} MHz
        Remove From List    ${frequency_list}    ${val}
        INSERT INTO LIST    ${frequency_list}    ${val}    ${list_val}
    END
    Log To Console    ${frequency_list}
    FOR    ${frequency}    IN   @{frequency_list}
        ${output} =    APPIUM_WAIT_FOR_XPATH    //*[@text='${frequency}']
        run keyword if    '${output}' == 'True'    REMOVE FAVORITE CHANNEL APPIUM    ${target_id}    ${frequency}
    END
    SET_RADIO_APP_MANUAL_FREQUENCY_APPIUM    ${test_freq}

REMOVE FAVORITE CHANNEL APPIUM
    [Arguments]    ${target_id}    ${frequency}    ${fm_freq_name1}=None    ${fm_freq_name2}=None    ${TC_folder}=${EMPTY}
    [Documentation]    Remove favorite channel from favorite list
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${title}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${res}
    ...    ELSE    Should Be True    ${res}
    RUN KEYWORD IF    '${fm_freq_name1}' != 'None'     TAP BY XPATH    //*[@text='${fm_freq_name1}']
    ...    ELSE IF    '${fm_freq_name2}' != 'None'     TAP BY XPATH    //*[@text='${fm_freq_name2}']
    ...    ELSE    TAP BY XPATH    //*[@text='${frequency}']
    TAP BY XPATH    ${control_bar}
    TAP BY XPATH    ${favorite_channel}

CHECK RADIO PERSISTENCE
    [Arguments]    ${channel_1}    ${channel_2}
    [Documentation]    Check persistence of the radio
    ${result} =    run keyword if    "${ivi_my_feature_id}" != "MyF3"    LAUNCH APP APPIUM     Radio
    ${result} =    run keyword if    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM     MediaSource
    Run Keyword If    "${result}" == "False"    Log    CHECK RADIO PERSISTENCE fail (Appium App Radio)    WARN
    Sleep    3
    ${result} =    TAP BY XPATH    ${Favourites}
    Run Keyword If    "${result}" == "False"    Log    CHECK RADIO PERSISTENCE fail (Favourites)    WARN
    Sleep    3
    ${res} =    WAIT ELEMENT BY XPATH    //*[@text='${channel_1}']    retries=10
    ${result} =    Run Keyword If    "${res}" == "False"    WAIT ELEMENT BY XPATH    //*[@text='${channel_2}']    retries=10
    Run Keyword If    "${result}" == "False"    Log    CHECK RADIO PERSISTENCE fail (Channel 1 & 2)    WARN

SWITCH TO THE NEXT FAVORITE CHANNEL
    [Arguments]    ${fm_name1}    ${fm_name2}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
    [Documentation]    Swhitch to the second favorite channel
    ${result} =    run keyword if    "${ivi_my_feature_id}" != "MyF3"    LAUNCH APP APPIUM     Radio
    ${result} =    run keyword if    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM     MediaSource
    Run Keyword If    "${result}" == "False"    Log    SWITCH TO THE NEXT FAVORITE CHANNEL (Appium App Radio) fail    WARN
    ${res} =    TAP BY XPATH    ${Favourites}
    Run Keyword If    "${res}" == "False"    Log    SWITCH TO THE NEXT FAVORITE CHANNEL (Favourites) fail    WARN
    ${result} =    WAIT ELEMENT BY XPATH    //*[@text='${fm_name1}']    retries=10
    ${resultat} =    Run Keyword If    "${result}" == "True"     Run Keywords
    ...    run keyword if    "${ivi_my_feature_id}" != "MyF3"    APPIUM_TAP_XPATH    ${channel_button}
    ...    AND    run keyword if    "${ivi_my_feature_id}" == "MyF3"   APPIUM_TAP_XPATH    ${control_bar}
    ...    AND    run keyword if    "${ivi_my_feature_id}" == "MyF3"   APPIUM_TAP_XPATH    ${next_button_MYF3_accessda}
    ...    AND    run keyword if    "${ivi_my_feature_id}" != "MyF3"   APPIUM_TAP_XPATH    ${next_button}
    ...    AND    WAIT ELEMENT BY XPATH    //*[@text='${fm_name2}']    retries=10
    ...    AND    APPIUM_TAP_XPATH    ${radio_icon}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    ${resultat} =    Run Keyword If    "${result}" == "False"     Run Keywords
    ...    run keyword if    "${ivi_my_feature_id}" != "MyF3"   APPIUM_TAP_XPATH    ${channel_button}
    ...    AND    run keyword if    "${ivi_my_feature_id}" == "MyF3"  APPIUM_TAP_XPATH    ${control_bar}
    ...    AND    run keyword if    "${ivi_my_feature_id}" != "MyF3"   APPIUM_TAP_XPATH    ${next_button}
    ...    AND    run keyword if    "${ivi_my_feature_id}" == "MyF3"   APPIUM_TAP_XPATH    ${next_button_MYF3_accessda}
    ...    AND    WAIT ELEMENT BY XPATH    //*[@text='${fm_name1}']    retries=10
    ...    AND    APPIUM_TAP_XPATH    ${radio_icon}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Run Keyword If    "${resultat}" == "False"    Log    SWITCH TO THE NEXT FAVORITE CHANNEL fail    WARN

SELECT NEW CHANNELS AND ADD TO FAVORITE
    [Documentation]    Add new radio channel and after that add to favorite
    Sleep    5s
    TAP BY XPATH    ${Favourites}
    Sleep    5s
    IF      "${ivi_my_feature_id}" != "MyF3"
            APPIUM_TAP_XPATH    ${list_tab}
            APPIUM_TAP_XPATH    ${control_bar}
            APPIUM_TAP_XPATH    ${next_button}
            Wait Until Keyword Succeeds    1m    10s    APPIUM_TAP_XPATH    ${favorite_channel}
            Sleep    3s
            APPIUM_TAP_XPATH    ${next_button}
            Wait Until Keyword Succeeds    1m    10s    APPIUM_TAP_XPATH    ${favorite_channel}
            Sleep    5s
            APPIUM_TAP_XPATH    ${radio_icon}
            APPIUM_TAP_XPATH    ${Favourites}
            Sleep    5s
            ${fm_freq_name1} =    APPIUM_GET_TEXT    ${channel_button}
            Sleep    5s
            APPIUM_TAP_XPATH    ${channel_button}
            Sleep    3s
            APPIUM_TAP_XPATH    ${next_button}
            Sleep    3s
            APPIUM_TAP_XPATH    ${radio_icon}
            ${fm_freq_name2}=    APPIUM_GET_TEXT    ${channel_button}
    ELSE
            TAP_ON_ELEMENT_USING_XPATH    //*[@text='List']    10
            TAP_ON_ELEMENT_USING_XPATH    ${control_bar_myf3}    10
            TAP_ON_ELEMENT_USING_XPATH    ${Radio['favourite_button_myf3']}    10
            Sleep    3s
            APPIUM_TAP_XPATH    ${radio_icon}
            TAP_ON_ELEMENT_USING_XPATH    ${next_button_MYF3_accessda}    10
            TAP_ON_ELEMENT_USING_XPATH    ${control_bar_myf3}    10
            TAP_ON_ELEMENT_USING_XPATH    ${Radio['favourite_button_myf3']}    10
            Sleep    5s
            APPIUM_TAP_XPATH    ${radio_icon}
            APPIUM_TAP_XPATH    ${Favourites}
            Sleep    5s
            TAP_ON_ELEMENT_USING_XPATH    ${car_settings['image_player']}    10
            Sleep    5s
            APPIUM_TAP_XPATH    ${control_bar}
            Sleep    3s
            ${fm_freq_name1}=     APPIUM_GET_TEXT_USING_XPATH    //*[@resource-id='com.renault.car.media:id/title']
            APPIUM_TAP_XPATH    ${next_button_MYF3_accessda}
            Sleep    3s
            APPIUM_TAP_XPATH    ${radio_icon}
            ${fm_freq_name2}=     APPIUM_GET_TEXT_USING_XPATH    //*[@resource-id='com.renault.car.media:id/title']
    END
    Set Global Variable    ${fm_freq_name1}
    Set Global Variable    ${fm_freq_name2}

CHANGE VOLUME RANGE FOR RADIO
    [Arguments]    ${volume_range}
    [Documentation]    Change volume of the FM band
    LAUNCH APP APPIUM    Radio
    Sleep    3s
    TAP_ON_ELEMENT_USING_ID    ${Radio['control_bar']}    10
    Sleep    3s
    TAP_ON_ELEMENT_USING_ID    ${Radio['audio_settings']}    10
    Sleep    2s
    TAP BY XPATH    ${Radio['sound_tab']}
    Sleep    2s
    ${find_seekbar} =    APPIUM_WAIT_FOR_ELEMENT    ${Radio['seekbar']}     10
    Run Keyword If    "${find_seekbar}" == "False"    TAP BY XPATH    ${Radio['volume_range_tab']}
    Sleep    2s
    TAP_ON_ELEMENT_USING_ID    ${Radio['seekbar']}    10
    Sleep    2s
    APPIUM_ENTER_TEXT    ${Radio['seekbar']}   ${volume_range}
    Sleep    2s
    SET CLOSE APP    ivi    Radio

SET_RADIO_APP_DAB_FREQUENCY_APPIUM
    [Arguments]    ${frequency}= None    ${frequency_name}=None
    [Documentation]    Select the radio channel
    APPIUM_TAP_XPATH    //*[@text='List']
    ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='${frequency}' or @text='${frequency_name}']    direction=down    scroll_tries=12
    Should Be True    ${result}    Not able to find ${frequency} or ${frequency_name}
    APPIUM_TAP_XPATH    //*[@text='${frequency}' or @text='${frequency_name}']

GO RADIO MENU ON IVI
    [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}    ${platform_version}=10
    [Documentation]    Go to the radio app on sources menu
    RUN KEYWORD IF    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM    MediaSource2
    ...    ELSE    LAUNCH APP APPIUM    MediaSource
    ${res} =    WAIT ELEMENT BY XPATH    ${app_icon}    retries=5
    Should Be True    ${res}
    TAP_ON_ELEMENT_USING_XPATH    ${app_icon}    5   path_to_save=${path_to_save}    screenshot_name=${screenshot_name}

SET_RADIO_APP_MANUAL_FREQUENCY_APPIUM_MYF1
    [Arguments]    ${frequency}
    [Documentation]    Select the radio channel by entering manually on myf1 menu
    ...    ${frequency} radio channel frequency to enter
    APPIUM_TAP_XPATH    ${control_bar}
    APPIUM_TAP_XPATH    ${select_freq}
    Sleep    3s
    ${elem_status} =    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${new_freq}    clickable
    Run Keyword if      "${elem_status}" == "true"
    ...    APPIUM_ENTER_TEXT    ${new_freq}    ${frequency}
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    RUN KEYWORD AND IGNORE ERROR    APPIUM_TAP_XPATH    ${radio_icon}

SET_RADIO_APP_MANUAL_FREQUENCY_APPIUM_MYF2
    [Arguments]    ${frequency}
    [Documentation]    Select the radio channel by entering manually on myf2 menu
    ...    ${frequency} radio channel frequency to enter
    APPIUM_TAP_XPATH    ${channel_button}
    APPIUM_TAP_XPATH    ${select_freq}
    Sleep    5s
    ${frequency_length} =    Get Length    ${frequency}
    FOR    ${index}    IN RANGE    ${0}    ${frequency_length}
        ${end_index} =    Evaluate    ${index}+${1}
        ${digit} =    Get Substring    ${frequency}    ${index}    ${end_index}
        Continue For Loop If    "${digit}"=="."
        APPIUM_PRESS_KEYCODE   ${KEYCODE_${digit}}
        Sleep    2s
    END
    Sleep    5s
    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
    Sleep    5s
    RUN KEYWORD AND IGNORE ERROR    APPIUM_TAP_XPATH    ${radio_icon}

LAUNCH RADIO AND PLAY MUSIC
     [Arguments]    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}
     [Documentation]    Go to the radio and play music
     ${result}=    Run Keyword And Return Status     GO RADIO MENU ON IVI    platform_version=${platform_version}
     Sleep    10
     Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" == "aivi2_r_accessda"  APPIUM_TAP_XPATH    ${control_bar_MYF3_accessda}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
     Run Keyword If    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" != "aivi2_r_accessda"  APPIUM_TAP_XPATH    ${control_bar_myf3}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
     IF    "${ivi_my_feature_id}" == "MyF3"
        TAP BY XPATH    ${next_button_MYF3_accessda}
        Sleep    3
        APPIUM_TAP_XPATH    ${radio_icon_MYF3_accessda}
     ELSE
        APPIUM_TAP_XPATH    ${control_bar}    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        TAP BY XPATH    ${next_button}
        Sleep    3
        APPIUM_TAP_XPATH    ${radio_icon}
     END

