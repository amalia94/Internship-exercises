#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Video library
Library           rfw_services.ivi.VideoLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ImageLib    device=${ivi_adb_id}

*** Variables ***
&{target}         host=bench    dut=ivi
${destination_path}    tc_vid_screenshot_taken
${screenshot_path_temp}    sdcard/Pictures/
${screenshot_taken}    screenshot_taken.png
${image_display_time}    3.5
${video_package_name}    com.renault.videoplayer

*** Keywords ***
DO LAUNCH VIDEO FILE
    [Arguments]    ${target_id}    ${video_file_name}    ${app}=${EMPTY}
    [Documentation]    Launch the given video on target using the specified video app
    ...    ${target_id} the dedicated DUT
    ...    ${app} name of video app
    ...    ${video_file_name} name of video file
    Log To Console    Launching ${app} application and start playing ${video_file_name} video file
    RUN KEYWORD IF  "${app}"=="video_player"    START INTENT    -a android.intent.action.VIEW -d file:///${video_file_name} -t video/mp4
    ...    ELSE    LAUNCH VIDEO    ${video_file_name}    ${app}
    Sleep    1.5
    ${output} =    PS PACKAGE    ${video_package_name}
    Run Keyword If    "${output.stdout}" == "b''"    Fail    No video player is running with package name ${video_package_name}

CHECK DISPLAY COMPARE
    [Arguments]    ${target_id}    ${reference_image}
    [Documentation]    Do a screenshot and compare it with a reference image.
    Log To Console    Do screenshot and compare it with ${reference_image} image
    Sleep    ${image_display_time}
    TAKE SCREENSHOT    ${screenshot_path_temp}    ${reference_image}    ${destination_path}
    EXTRACT PIXEL COLOR    ${destination_path}    ${reference_image}

CHECK VIDEO ORIENTATION
    [Arguments]    ${target_id}    ${orientation}
    [Documentation]    Take a screenshot of the IVI and analyse pixels of the picture.
    Log To Console    Take a screenshot of the IVI and analyse pixels of the picture.
    Sleep    3
    TAKE SCREENSHOT    ${screenshot_path_temp}    ${screenshot_taken}    ${destination_path}
    Sleep    1
    EXTRACT PIXEL COLOR    ${destination_path}    ${screenshot_taken}

DO CLOSE VIDEO PLAY
    [Arguments]    ${target_id}    &{app}
    [Documentation]    Ensure video playing is stopped and then close the app (by a force-stop)
    DO VIDEO PLAYER ACTION    ${target_id}    stop
    DO CLOSE APP    ivi    VideoPlayer

DO VIDEO PLAYER ACTION
    [Arguments]    ${target_id}    ${action}
    [Documentation]    Ensure video is stopped
    Log To Console    Stop playing video file
    ${value} =    STOP VIDEO    ${action}
    Log To Console    Value ${value}
    Run Keyword If    ${value}    Log To Console    Video file stopped
    ...    ELSE    Log To Console    Video file already stopped.
