#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
# MR!109 Trig Staging Pipeline Smoke using Audio HLK lib
*** Settings ***
Documentation     Audio test keywords
Library           rfw_services.ivi.AudiomediaLib    device=${ivi_adb_id}
Library           rfw_services.asound.AudioAsoundLib    channel=${channel}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           String
Resource          appium_hlks.robot
Variables         KeyCodes.yaml

*** Variables ***
${repo_audio}        matrix/artifacts/audio/
${channel}           1
${ivi_adb_id}        ${None}
${item_icon}         //*[@resource-id='com.android.car.media:id/car_ui_toolbar_menu_item_icon']
${app_switch_container}     //*[@resource-id='com.renault.radio:id/app_switch_container']
${nav_icon}          //*[@resource-id='com.android.car.media:id/car_ui_toolbar_nav_icon']
${usb}               //*[@text='USB']
${usb_key}           //*[@text='USB KEY']
${range}             40
${swtich_app_xpath}    //*[@text='source' or @text='SOURCE' or @content-desc='Switch apps']
${allow}             //*[@text='Allow']

*** Keywords ***
CHECK SOUND
    [Arguments]    ${sound_channel}    ${status}    ${volume_level}=40
    [Documentation]    Check if the sound is present/not present in dut id lineout
    ...    CHECK SOUND present
    ...    CHECK SOUND not_present
    Log To Console    Check if the sound is ${status}
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell media volume --stream 3 --set ${volume_level}
    Run Keyword If    "${status}"=="present"    Log To Console    Check if sound is present
    ${status} =    Set Variable If    "${status}" == "present"    ${True}    ${False}
    ${sound_status} =    wait_until_keyword_succeeds    3x    5s    CHECK LOUD SPEAKER     ${status}
    Run Keyword If    "${status}" == "True"    SOUND PRESENT    ${sound_status}
    ...       ELSE    SOUND NOT PRESENT    ${sound_status}

DO AUDIO PLAYER ACTION
    [Arguments]    ${target_id}    ${action}
    [Documentation]    Push ${action} button on ${target_id}
    Log To Console    DO AUDIO PLAYER ACTION ${action}
    Run Keyword If    "${action}"=="start"    APPIUM_PRESS_KEYCODE    ${KEYCODE_MEDIA_PLAY}
    ...    ELSE IF    "${action}"=="pause"    APPIUM_PRESS_KEYCODE    ${KEYCODE_MEDIA_PAUSE}
    ...    ELSE IF    "${action}"=="stop"    APPIUM_PRESS_KEYCODE    ${KEYCODE_MEDIA_STOP}
    ...    ELSE IF    "${action}"=="next"    APPIUM_PRESS_KEYCODE    ${KEYCODE_MEDIA_NEXT}

SOUND PRESENT
    [Arguments]    ${verdict}    ${TC_folder}=${EMPTY}
    [Documentation]    SOUND PRESENT True
    ...    SOUND PRESENT False
    ...    Check the verdict returned is True
    Should Be True    ${verdict}

SOUND NOT PRESENT
    [Arguments]    ${verdict}
    [Documentation]    SOUND NOT PRESENT True
    ...    SOUND NOT PRESENT False
    ...    Check the verdict returned is not True
    Should Not Be True    ${verdict}

DO LAUNCH AUDIO FILE
    [Arguments]    ${dut_id}    ${file_name}    ${path_to_save}=${OUTPUT_DIR}    ${screenshot_name}=${TEST NAME}    ${tap_play_button}=False
    CHECKSET USB STATUS     ${stick_cutter}    plugged
    Sleep    5s
    Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    LAUNCH APP APPIUM    MediaSource
    Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM    MediaSource2
    SLEEP    2s
    Run Keyword and Ignore Error    enable_multi_windows
    IF    "${platform_version}" == "10"
        ${switch_apps} =    APPIUM_WAIT_FOR_XPATH    ${swtich_app_xpath}
        Run Keyword If    "${switch_apps}"=="True"    APPIUM_TAP_XPATH    ${swtich_app_xpath}
    ELSE
        ${switch_apps} =    APPIUM_WAIT_FOR_XPATH    ${car_settings['source_icon']}
        Run Keyword If    "${switch_apps}"=="True"    APPIUM_TAP_XPATH    ${car_settings['source_icon']}
    END
    Sleep    5s
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${usb}    retries=10
    Run Keyword If    "${res}" == "True"     APPIUM_TAP_XPATH    ${usb}
    Sleep    5s
    Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    IF    "${ivi_my_feature_id}" == "MyF3" and "${ivi_platform_type}" != "aivi2_r_accessda"
        LAUNCH APP APPIUM    MediaSource2
        ${res} =    APPIUM_WAIT_FOR_XPATH    ${allow}    retries=10
        Run keyword If    "${res}"== "True"    APPIUM_TAP_XPATH    ${allow}
        ${result} =    APPIUM_WAIT_FOR_XPATH    ${usb}    retries=10
        Run Keyword If    "${result}" == "True"     APPIUM_TAP_XPATH    ${usb}
        Sleep    3s
    ELSE

        Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
        ${res} =    APPIUM_WAIT_FOR_XPATH    ${usb_key}    retries=10
        Run Keyword If    "${res}" == "False"    APPIUM_PRESS_KEYCODE   ${KEYCODE_BACK}
    END
    TAP_ON_ELEMENT_USING_XPATH    ${usb_key}    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}     
    Run Keyword and Ignore Error    TAP_ON_ELEMENT_USING_XPATH    //*[@text='Allow']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    Sleep    5
    IF    "${platform_version}" == "10"
        ${op_strip} =    Strip String    ${file_name}    characters=.mp3   
        APPIUM_TAP_XPATH    //android.widget.TextView[@text='${op_strip}']    10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    ELSE
        APPIUM_TAP_XPATH    ${car_settings['image_player']}     10    path_to_save=${path_to_save}    screenshot_name=${screenshot_name}
    END    
    
GO BACK TO MUSIC APP
    [Documentation]    To go back to ivi music app
    ${res} =    APPIUM_WAIT_FOR_XPATH    ${nav_icon}    retries=10
    Run Keyword If    "${res}"=="True"    TAP BY XPATH    ${nav_icon}

DO PAUSE AUDIO FILE
    [Arguments]    ${dut_id}
    [Documentation]    Pause the playing audio on native music player
    ...    DO PAUSE AUDIO FILE ivi
    APPIUM_PRESS_KEYCODE    ${KEYCODE_MEDIA_PAUSE}

CHECK AUDIO PLAYBACK STATUS
    [Arguments]    ${target_id}    ${status}
    [Documentation]    Check the audio playback status
    ...    ${target_id}   the target to be tested
    ...    ${status}    the current playback status (ongoing/paused)
    ${output} =    AUDIO PLAYBACK STATUS
    Run Keyword If    """${output}""" == "b''"    Fail    No music player is running
    Run Keyword If    "${status}" == "ongoing"    Should Be True    "state(5)" in """${output}"""    Audio is not ongoing
    Run Keyword If    "${status}" == "paused"    Should Be True    "state(6)" in """${output}"""    Audio is not paused

CHECK SOUND STATUS
    [Arguments]    ${target_id}    ${media_type}    ${present_status}
    [Documentation]    Check audio is present by checking media player sound status based on the media_type
    Sleep    1
    ${scan_audio} =    AUDIO SOUND STATUS
    ${scan_audio} =    Catenate    ${scan_audio}
    ${scan_audio} =     Fetch from Right    ${scan_audio}    stack entries
    ${scan_audio} =     Fetch from Left    ${scan_audio}    Notify on duck
    ${audio_present_music} =    Evaluate    "CONTENT_TYPE_MUSIC" in """${scan_audio}"""
    ${audio_present_movie} =    Evaluate    "CONTENT_TYPE_MOVIE" in """${scan_audio}"""
    ${audio_present_sonification} =    Evaluate    "CONTENT_TYPE_SONIFICATION" in """${scan_audio}"""
    ${audio_present_speech} =    Evaluate    "CONTENT_TYPE_SPEECH" in """${scan_audio}"""
    ${audio_present_unknown} =    Evaluate    "CONTENT_TYPE_UNKNOWN" in """${scan_audio}"""
    Should Be True    "${present_status}" == "present" or "${present_status}" == "not_present"    ${present_status} is not a supported value for argument: present_status
    Run Keyword If    "${present_status}" == "present" and "${media_type}" == "music"    Should Be True    ${audio_present_music}    Audio music expected but not present
    ...    ELSE IF    "${media_type}" == "music"    Should Not Be True    ${audio_present_music}    Audio music unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "movie"    Should Be True    ${audio_present_movie}    Audio movie expected but not present
    ...    ELSE IF    "${media_type}" == "movie"    Should Not Be True    ${audio_present_movie}    Audio movie unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "sonification"    Should Be True    ${audio_present_sonification}    Audio sonification expected but not present
    ...    ELSE IF    "${media_type}" == "sonification"    Should Not Be True    ${audio_present_sonification}    Audio sonification unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "speech"    Should Be True    ${audio_present_speech}    Audio speech expected but not present
    ...    ELSE IF    "${media_type}" == "speech"    Should Not Be True    ${audio_present_speech}    Audio speech unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "unknown"    Should Be True    ${audio_present_unknown}    Audio unknown expected but not present
    ...    ELSE IF    "${media_type}" == "unknown"    Should Not Be True    ${audio_present_unknown}    Audio unknown unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "radio"    Should Be True    ${audio_present_music}    Audio radio expected but not present
    ...    ELSE IF    "${media_type}" == "radio"    Should Not Be True    ${audio_present_music}    Audio radio unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "music"    Should Be True    ${audio_present_music}    Audio music expected but not present
    ...    ELSE IF    "${media_type}" == "music"    Should Not Be True    ${audio_present_music}    Audio music unexpected but present
    ...    ELSE IF    "${present_status}" == "present" and "${media_type}" == "alarm"    Should Be True    ${audio_present_sonification}    Audio sonification expected but not present
    ...    ELSE IF    "${media_type}" == "alarm"    Should Not Be True    ${audio_present_sonification}    Audio sonification unexpected but present
    ...    ELSE    Log    Invalid request in CHECK SOUND STATUS : Status = ${present_status} and Media = ${media_type}    WARN

SET DEFAULT VOLUME
    [Arguments]    ${target_id}    ${percentage}
    [Documentation]    Set the default volume specified
    ...    ${target_id}   the target_id on which the volume has to be set
    ...    ${percentage}    the volume percentage
    Log To Console    SET DEFAULT VOLUME on target_id: ${target_id} to ${percentage}%
    ${volume} =    Evaluate    (${range} * ${percentage}) / 100
    ${volume} =    Convert To Integer    ${volume}
    ${output} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell media volume --stream 3 --set ${volume}
    Should Contain    ${output}    will set volume to index=${volume}
    ${new_volume} =    GET SOUND VALUE
    Should Be True   ${volume} == ${new_volume}   Unexpected volume

GET SOUND VALUE
    [Documentation]    Get the current media volume on IVI
    Log To Console    GET SOUND VALUE on IVI
    ${volume} =    GET MEDIA VOLUME
    [Return]    ${volume}

GET AFFUTE SOUND VALUE
    [Documentation]    Get the current media volume on affute setup
    Log To Console    GET SOUND VALUE on affute setup
    MAKE SOUND AQUISITION
    ${sound_verdict} =    CALCULATE SOUND VERDICT
    ${loud_sound} =    Evaluate    ${sound_verdict} > 25
    Should Be True    ${loud_sound}
    [Return]    ${sound_verdict}

STOP AND DELETE AUDIO FILE
    [Arguments]    ${dut_id}    ${file_name}
    [Documentation]    To perform stop audio file and delete it and to disconnect usb line
    GO BACK TO MUSIC APP
    DO PAUSE AUDIO FILE    ${dut_id}
    ${usb_stick_id} =    Run Keyword If    "${usb_stick_id}" == "${None}"    IDENTIFY CURRENT USB VOLUME    ${dut_id}    ${stick_cutter}
    ...    ELSE    Set Variable     ${usb_stick_id}
    CHECKSET DELETE FILE    ivi    /storage/${usb_stick_id}/${file_name}
    CHECKSET USB STATUS    ${stick_cutter}    unplugged
    GO HOME SCREEN APPIUM

SET AUDIO SOURCE ON IVI APPIUM
    [Arguments]    ${source}
    [Documentation]    Sets the audio source to ${source} on IVI
    LAUNCH APP APPIUM    MediaSource
    IF    "${ivi_my_feature_id}" == "MyF3"
        APPIUM_TAP_XPATH    ${swtich_app_xpath}    20
    END
    ${src_xpath} =    Set Variable If    "Bluetooth" in "${source}"    //*[@text='Bluetooth Audio' or @text='Bluetooth audio']    //*[@text='${source}']
    APPIUM_TAP_XPATH    ${src_xpath}

VPA PLAY AUDIO FILE
    [Arguments]    ${text}
    [Documentation]    Do voice synthesis based on text and play this generated audio from host pc to ivi
    say_text_to_file     "${text}"    ${text}.wav
    PLAY FILE ON SOUND CARD    ./${text}.wav
