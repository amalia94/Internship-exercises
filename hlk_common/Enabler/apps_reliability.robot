#
#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     DAY_OF_USE reliability - keywords library
Library           rfw_services.ivi.WaitForAdbDevice
Library           BuiltIn
Library           DateTime
Library           Process
Variables         ../../IVI2/RELIABILITY/MMI_MultimediaState.yaml

*** Variables ***
@{selected_path}    CHECK THE RADIO AND DESTINATION    SET RADIO CHANNEL AND SET THE VOLUME DOWN    CHECK THE MAIN APPS AND SET THE VOLUME UP    INITIATE CALL
@{transition_list}    CHECK THE RADIO AND DESTINATION    SET RADIO CHANNEL AND SET THE VOLUME DOWN    CHECK THE MAIN APPS AND SET THE VOLUME UP    INITIATE CALL

*** Keywords ***
CCS2 BOOT
    [Documentation]    == High Level Description: ==
    ...    Check the ivi and ivc are on
        SEND VEHICLE WAKEUP COMMAND
        CHECK IVI BOOT COMPLETED    booted    120
        CHECK IVC BOOT COMPLETED

CHECK THE RADIO AND DESTINATION
    [Arguments]    ${phone_number}    ${stick_cutter}
    [Documentation]    == High Level Description: ==
    ...    check the persistence of radio/maps apps
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    Sleep   10
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** CHECK THE DESTINATION ****
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_THE_DESTINATION
    ${status} =    CHECK THE DESTINATION    ${loop_folder}    screenshot_CHECK_THE_DESTINATION_failed
    Run Keyword If    "${status}" == "False"     Log    CHECK THE DESTINATION failed    WARN
    Sleep   3
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** CHECK RADIO PERSISTENCE ****
    Run Keyword and Ignore Error    CUT USB LINE    ${stick_cutter}    double    1
    Sleep    1
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_RADIO_PERSISTENCE
    ${status} =    CHECK RADIO PERSISTENCE    ${fm_freq_name1}    ${fm_freq_name2}
    Run Keyword If    "${status}" == "False"     Log    CHECK RADIO PERSISTENCE failed    WARN
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_AND_CHANGE_THE_VOLUME_UP
    ${status}    ${value} =    Run Keyword And Ignore Error    CHECK AND CHANGE THE VOLUME    up    loud_speaker    present    ${new_volume}    ${relaycard_present}
    Run Keyword If    "${status}" == "FAIL"     Log    CHECK SOUND failed    WARN
    Sleep    1
    Run Keyword and Ignore Error    CONNECT USB LINE    ${stick_cutter}    double    1

SET RADIO CHANNEL AND SET THE VOLUME DOWN
     [Arguments]    ${phone_number}    ${stick_cutter}
     [Documentation]    == High Level Description: ==
     ...    set functionality  for radio
        CHECK AND SWITCH DRIVER    ${ivi_driver}
        Sleep   10
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** SWITCH TO THE NEXT FAVORITE CHANNEL ****
        INJECT LOGCAT MESSAGE    ccar    START_SWITCH_TO_THE_NEXT_FAVORITE_CHANNEL
        ${status} =    SWITCH TO THE NEXT FAVORITE CHANNEL    ${fm_freq_name1}    ${fm_freq_name2}
        Run Keyword If    "${status}" == "False"     Log    SWITCH TO THE NEXT FAVORITE CHANNEL failed    WARN
        INJECT LOGCAT MESSAGE    ccar    START_CHECK_AND_CHANGE_THE_VOLUME_UP
        ${status}    ${value} =    Run Keyword And Ignore Error    CHECK AND CHANGE THE VOLUME    up    loud_speaker    present    ${new_volume}    ${relaycard_present}
        Run Keyword If    "${status}" == "FAIL"     Log    CHECK SOUND failed    WARN
        Sleep    5
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** CHECK RADIO PERSISTENCE ****
        Run Keyword and Ignore Error    CUT USB LINE    ${stick_cutter}    double    1
        Sleep    1
        INJECT LOGCAT MESSAGE    ccar    START_CHECK_RADIO_PERSISTENCE
        ${status} =    CHECK RADIO PERSISTENCE    ${fm_freq_name1}    ${fm_freq_name2}
        Sleep    1
        Run Keyword and Ignore Error    CONNECT USB LINE    ${stick_cutter}    double    1
        Run Keyword If    "${status}" == "False"     Log    CHECK RADIO PERSISTENCE failed    WARN
        INJECT LOGCAT MESSAGE    ccar    START_CHECK_AND_CHANGE_THE_VOLUME_UP
        ${status}    ${value} =    Run Keyword And Ignore Error    CHECK AND CHANGE THE VOLUME    up    loud_speaker    present    ${new_volume}    ${relaycard_present}
        Run Keyword If    "${status}" == "FAIL"     Log    CHECK SOUND failed    WARN
        Sleep    3
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** SEND VEHICLE VOLUME DOWN ****
        INJECT LOGCAT MESSAGE    ccar    START_CHANGE_THE_VOLUME_DOWN
        ${volume_before} =    audio.GET SOUND VALUE
        ${volume_before}=    Set Variable If    ${volume_before} == 0    0.1    ${volume_before}
        SEND VEHICLE VOLUME BY SWRC    down
        ${volume_after} =    audio.GET SOUND VALUE
        ${delta} =    Evaluate    ${volume_after} - ${volume_before}
        Run Keyword And Continue On Failure    Should Be True    ${delta} < 0    Volume is not correctly set down
        Run Keyword If    ${delta} > 0    Log    ERROR VOLUME DOWN    WARN
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** IVI : Check volume icon image on screen ****
        INJECT LOGCAT MESSAGE    ccar    END_CHANGE_THE_VOLUME_DOWN
        ${status}     ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN   ${ivi_adb_id}    ${android_volume_img}
        Run Keyword If    "${status}" == "False"     SET FILE COPY    ivi    bench    /sdcard/screen_shot_image.png    ${CURDIR}/Image_VOL_DOWN_FAIL_${current_tc_name}_loop_${loop_number}.png
        Run Keyword If    "${status}" == "False"     Log    CHECK IMAGE (Volume down) DISPLAYED ON SCREEN failed - Added screenshot ${CURDIR}/Image_VOL_DOWN_FAIL_${current_tc_name}_loop_${loop_number}.png    WARN
        Sleep    3


INITIATE CALL
    [Arguments]    ${phone_number}    ${stick_cutter}
    [Documentation]    == High Level Description: ==
    ...    initiate and end a call
        CHECK AND SWITCH DRIVER    ${ivi_driver}
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** DO PHONE CALL to ${phone_number} ****
        Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    LAUNCH APP APPIUM    PhoneBook
        INJECT LOGCAT MESSAGE    ccar    START_TO_INITIATE_THE_CALL
        DO CALL    ${smartphone_adb_id}    ${phone_number}
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** CHECK CALL IS IN PROGRESS ****
        INJECT LOGCAT MESSAGE    ccar    START_CHECK_CALL_IN_PROGRESS
        ${status}    ${value} =    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5m    100ms    CHECK CALL IS IN PROGRESS
        Run Keyword If    "${status}" == "FAIL"     Log    CHECK CALL failed : call is not in progress    WARN
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** Checking call audio ****
        INJECT LOGCAT MESSAGE    ccar    START_CHECK_AND_CHANGE_THE_VOLUME_UP
        ${status}    ${value} =    Run Keyword And Ignore Error    CHECK AND CHANGE THE VOLUME    up    loud_speaker    present    ${new_volume}    ${relaycard_present}
        Run Keyword If    "${status}" == "FAIL"     Log    CHECK CALL SOUND failed    WARN
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** IVI : Check call icon image on screen ****
        ${status}     ${start_pt}    ${end_pt} =    Run Keyword If    "${ivi_my_feature_id}" != "MyF3"    CHECK IMAGE DISPLAYED ON SCREEN   ${ivi_adb_id}    ${android_call_img}
        ${status}     ${start_pt}    ${end_pt} =    Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    CHECK IMAGE DISPLAYED ON SCREEN   ${ivi_adb_id}    ${android_call_myf3_img}
        Run Keyword If    "${status}" == "False"     SET FILE COPY    ivi    bench    /sdcard/screen_shot_image.png    ${CURDIR}/Image_CALL_FAIL_${current_tc_name}_loop_${loop_number}.png
        Run Keyword If    "${status}" == "False"     Log    CHECK IMAGE (Call icon) DISPLAYED ON SCREEN failed - Added screenshot ${CURDIR}/Image_CALL_FAIL_${current_tc_name}_loop_${loop_number}.png    WARN
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** End call ****
        INJECT LOGCAT MESSAGE    ccar    START_END_CALL_BETWEEN_PHONES
        END CALL BETWEEN PHONES
        Sleep   3

CHECK THE MAIN APPS AND SET THE VOLUME UP
    [Arguments]    ${phone_number}    ${stick_cutter}
    [Documentation]    == High Level Description: ==
    ...    check the persistence of radio/maps apps and set the volume up
    CHECK AND SWITCH DRIVER    ${ivi_driver}
    Sleep   10
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** CHECK THE DESTINATION ****
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_THE_DESTINATION
    ${status} =    CHECK THE DESTINATION     ${loop_folder}    screenshot_CHECK_THE_DESTINATION_failed
    Run Keyword If    "${status}" == "False"     Log    CHECK THE DESTINATION failed    WARN
    Sleep    3
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** CHECK RADIO PERSISTENCE ****
    Run Keyword and Ignore Error    CUT USB LINE    ${stick_cutter}    double    1
    Sleep    1
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_RADIO_PERSISTENCE
    ${status} =    CHECK RADIO PERSISTENCE    ${fm_freq_name1}    ${fm_freq_name2}
    Sleep    1
    Run Keyword and Ignore Error    CONNECT USB LINE    ${stick_cutter}    double    1
    Run Keyword If    "${status}" == "False"     Log    CHECK RADIO PERSISTENCE failed    WARN
    INJECT LOGCAT MESSAGE    ccar    START_CHECK_AND_CHANGE_THE_VOLUME_UP
    ${status}    ${value} =    Run Keyword And Ignore Error    CHECK AND CHANGE THE VOLUME    up    loud_speaker    present    ${new_volume}    ${relaycard_present}
    Run Keyword If    "${status}" == "FAIL"     Log    CHECK SOUND failed    WARN
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** SEND VEHICLE VOLUME UP ****
    INJECT LOGCAT MESSAGE    ccar    START_SEND_VEHICLE_VOLUME_UP
    ${volume_before} =    audio.GET SOUND VALUE
    ${volume_before}=    Set Variable If    ${volume_before} == 40    39.9    ${volume_before}
    SEND VEHICLE VOLUME BY SWRC    up
    ${volume_after} =    audio.GET SOUND VALUE
    ${delta} =    Evaluate    ${volume_after} - ${volume_before}
    Run Keyword And Continue On Failure    Should Be True    ${delta} > 0    Volume is not correctly set up
    Run Keyword If    ${delta} < 0    Log    ERROR VOLUME UP    WARN
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    **** IVI : Check volume icon image on screen ****
    ${status}     ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN   ${ivi_adb_id}    ${android_volume_img}
    Run Keyword If    "${status}" == "False"     SET FILE COPY    ivi    bench    /sdcard/screen_shot_image.png    ${CURDIR}/Image_VOL_UP_FAIL_${current_tc_name}_loop_${loop_number}.png
    Run Keyword If    "${status}" == "False"     Log    CHECK IMAGE (Volume up) DISPLAYED ON SCREEN failed - Added screenshot ${CURDIR}/Image_VOL_UP_FAIL_${current_tc_name}_loop_${loop_number}.png    WARN
    INJECT LOGCAT MESSAGE    ccar    END_SEND_VEHICLE_VOLUME_UP
    Sleep    3

SELECT RANDOM TPID
    [Documentation]    == High Level Description: ==
    ...    Get a random tp name
    ...    == Expected Results: ==
    ...    Tpid name
   ${tech_prod_names} =     Get Dictionary Keys    ${tech_prods}
   ${random_tpid} =     Evaluate    random.choice(${tech_prod_names})
   [Return]    ${random_tpid}

   

