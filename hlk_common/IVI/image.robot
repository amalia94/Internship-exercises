#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Image related keywords library
Library           rfw_services.ivi.ImageLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           String

*** Variables ***
${target_id}      ${None}
&{target}         host=bench    dut=ivi
${dut_path}       storage/emulated/10/Pictures/
${host_path}      ./
${download_url}    matrix/artifacts/images/
${screenshot_path_temp}    sdcard/
${delete_screenshot}    *.png
${screenshot}     screenshot.png
${enable_fullscreen_mode}    settings put global policy_control immersive.full=*
${disable_fullscreen_mode}    settings put global policy_control immersive.off=*
${image_rtn_val}    False

*** Keywords ***
DO DISPLAY IMAGE
    [Arguments]    ${target_id}    ${image_name}    ${photo_player}=${EMPTY}
    [Documentation]    To display the file: ${image_name} on target_id: ${target_id} and check it is correctly displayed
    # ENABLE FULLSCREEN MODE
    ${image} =    Fetch From Right    ${image_name}    /
    ${format} =   Fetch From Right    ${image_name}    .
    run keyword if    "${photo_player}"== "photo_player"    START INTENT    -a android.intent.action.VIEW -t image/${format} -d file:///${dut_path}${image} -p com.renault.photoplayer
    ...    ELSE    DISPLAY IMAGE    ${dut_path}    ${image}
    Sleep    2

CHECK TEXT ON IMAGE DISPLAYED
    [Arguments]    ${target_id}    ${text_to_find}    ${status}    ${exit_on_failure}=True
    [Documentation]    Check image is displayed on the target by searching for specific text in the image
    TAKE SCREENSHOT    ${screenshot_path_temp}    ${screenshot}    ${host_path}
    Sleep    2
    ${result} =    SEARCH TEXT IN IMAGE    ${host_path}    ${screenshot}    ${text_to_find}
    Run Keyword If    "${status}" == "present" and ${exit_on_failure} == True    Should Be True    ${result}    Image was not displayed
    Run Keyword If    "${status}" == "absent" and ${exit_on_failure} == True   Should Not Be True    ${result}    Image was displayed
    return from keyword if    ${exit_on_failure} == False   ${result}

SET DISPLAY IMAGE
    [Arguments]    ${target_id}    ${image_name}    ${photo_player}=${EMPTY}
    [Documentation]    To display the file: ${image_name} on target_id: ${target_id}
    Log To Console    To display the file: ${image_name} on target_id: ${target_id}
    ENABLE FULLSCREEN MODE
    ${image} =    Fetch From Right    ${image_name}    /
    ${format} =   Fetch From Right    ${image_name}    .
    run keyword if    "${photo_player}"== "photo_player"    START INTENT    -a android.intent.action.VIEW -t image/${format} -d file:///${dut_path}${image} -p com.renault.photoplayer
    ...    ELSE    DISPLAY IMAGE    ${dut_path}    ${image}
    DO WAIT    2000

SET IMMERSIVE MODE
    [Arguments]    ${mode}
    Run Keyword If  "${mode}" == "full"    ENABLE FULLSCREEN MODE
    Run Keyword If  "${mode}" == "off"    DISABLE FULLSCREEN MODE

CHECK IMAGE DISPLAYED ON SCREEN
    [Arguments]    ${target_id}    ${ref_image}    ${status_check}=True    ${loop_folder}=None    ${screenshot_name}=None
    [Documentation]    To check if the image: ${ref_image} is present on the current screeen on target_id: ${target_id}
    ...    ${loop_folder} will copy the screenshot into the specified location, arg left unset then it won't copy the screenshot anywhere
    ...    ${screenshot_name} will rename the screenshot with the provided argument value, no arg value provided then existing image file will be overwritten
    ${status}    ${res_download} =    DOWNLOAD FILE FROM ARTIFACTORY   ${download_url}${ref_image}    ${CURDIR}
    Should Be True    ${status}
    TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
    ${status}    ${start_pt}    ${end_pt} =    FIND IMAGE ON SCREENSHOT    ${ref_image}    ${CURDIR}/screen_shot_image.png
    Run Keyword If    "${status}" == "False"      Run Keywords    SET FILE COPY    ivi    bench    /sdcard/screen_shot_image.png    ${CURDIR}/Image_FAIL.png
    ...    AND    Run Keyword If    "${loop_folder}" != "None"    Copy Files    ${CURDIR}/Image_FAIL.png    ${loop_folder}
    ...    AND    Run Keyword If    "${screenshot_name}" != "None" and "${loop_folder}" != "None"    OperatingSystem.Move File   ${loop_folder}/Image_FAIL.png    ${loop_folder}/${screenshot_name}.png
    Run Keyword If    "${status_check}"=="True"    Should Be True    ${status}
    [Return]    ${status}    ${start_pt}    ${end_pt}
 
CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN
    [Arguments]    ${ivi_adb_id}    ${ref_image}    ${loop_folder}=${CURDIR}    ${img_name}=tap_${ref_image}_img_fail
    [Documentation]    Check and tap on the current image, if ${ref_image} does not exists on the screenshot it will be saved on ${loop_folder} path
    CHECKSET FILE PRESENT    bench    ${ref_image}
    ${status}    ${start_pt}    ${end_pt} =    CHECK IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${ref_image}    True    ${loop_folder}    ${img_name}
    Should Be True    ${status}    Image is not found on screen.
    ${x1} =    Get From List    ${start_pt}    0
    ${x1} =    Convert To Integer    ${x1}
    ${y1} =    Get From List    ${start_pt}    1
    ${y1} =    Convert To Integer    ${y1}
    ${x2} =    Get From List    ${end_pt}    0
    ${x2} =    Convert To Integer    ${x2}
    ${y2} =    Get From List    ${end_pt}    1
    ${y2} =    Convert To Integer    ${y2}
    ${x} =    Evaluate    (${x1} + ${x2}) // 2
    ${y} =    Evaluate    (${y1} + ${y2}) // 2
    ${tap_location} =    Create Dictionary    x=${x}    y=${y}
    APPIUM_TAP_LOCATION    ${tap_location}

TAP IF IMAGE DISPLAYED ON SCREEN
    [Arguments]    ${ref_image}
    Log To Console    Tap on ${ref_image} displayed on screen
    ${coord}    ${center}    ${verdict} =    FIND IMAGE ON SCREEN APPIUM    ${ref_image}
    Return From Keyword If    "${verdict}" == "${False}"    ${ref_image} not found on screen so tapping is not required
    ${x} =    Set Variable    ${center}[x]
    ${y} =    Set Variable    ${center}[y]
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell input tap ${x} ${y}

CHECK HOME SCREEN
    [Documentation]    To check that the home screen is displayed  
    ${status} =    APPIUM_WAIT_FOR_XPATH   //*[@text='Google Assistant']
    [Return]    ${status}
    Should Be True    ${status} 

CHECK HVAC STATUS
    [Arguments]    ${target_id}    ${ref_image}
    [Documentation]    To check the A/C status
    TAKE SCREENSHOT    /sdcard    screen_shot_image.png    ${CURDIR}
    ${status}    ${res_download} =    DOWNLOAD FILE FROM ARTIFACTORY   ${download_url}${ref_image}    ${CURDIR}
    Should Be True    ${status}
    ${status} =     rfw_services.ivi.AppiumLib.Check Element Color By Ref Image    ${res_download}    3    8    90    90
    Should Be True    ${status}

TAP IMAGE DISPLAYED ON SCREEN
    [Arguments]    ${ref_image}    ${threshold}=80
    [Documentation]    Tap on ${ref_image} displayed on screen
    Log To Console    Tap on ${ref_image} displayed on screen
    ${img_loc}    ${verdict} =    GET IMAGE LOCATION ON SCREEN    ${ref_image}    ${threshold}
    Should Be True    ${verdict}
    TAP BY LOCATION    ${img_loc}

GET IMAGE LOCATION ON SCREEN
    [Arguments]    ${ref_image}    ${threshold}=80
    [Documentation]    Get ${ref_image} location on screen
    Log To Console    Get ${ref_image} location on screen
    ${coord}    ${center}    ${verdict} =    FIND IMAGE ON SCREEN APPIUM    ${ref_image}    ${threshold}
    ${x} =    Set Variable    ${center}[x]
    ${y} =    Set Variable    ${center}[y]
    ${img_loc} =    Create Dictionary    x=${x}    y=${y}
    [Return]    ${img_loc}    ${verdict}

TAP TEXT ON SCREEN
    [Arguments]    ${text}
    [Documentation]    Tap text: ${text} using image comparison
    Log To Console    Tap text: ${text} using image comparison
    ${str_len} =    Get Length    ${text}
    FOR   ${i}    IN RANGE    0   ${str_len}
        ${i_plus_1} =    Evaluate    ${i} + ${1}
        ${char} =    Get Substring    ${text}    ${i}    ${i_plus_1}
        ${img_file_name} =    Set Variable If    "${SPACE}" in "${char}"    char_space.png    char_${char}.png
        CHECKSET FILE PRESENT    bench    ${img_file_name}
        TAP IMAGE DISPLAYED ON SCREEN    ${img_file_name}    95
        SET DELETE FILE    bench    ${img_file_name}
    END

SET VARIABLE DAMPING MODES
    [Arguments]    ${mode}    ${ref_image}    ${image_to_validate}    ${threshold}=80
    [Documentation]    Set Variable Damping mode on mex screen in alliance kitchensink App.
    ...    ${mode}    Image of the type of mode to set
    ...    ${ref_image}    image to find on ${ivi_adb_id}
    ...    ${image_to_validate}    image to validate on ${ivi_adb_id}
    ...    ${threshold}    threshold percentage
    CHECKSET FILE PRESENT    bench    ${ref_image}
    CHECKSET FILE PRESENT    bench    ${image_to_validate}
    CHECKSET FILE PRESENT    bench    ${mode}
    ${coord}    ${center}    ${verdict} =    FIND IMAGE ON SCREEN APPIUM    ${ref_image}    ${threshold}
    Should Be True    ${verdict}
    ${x_loc} =    Convert To Integer    ${coord}[2]
    ${y_loc} =    Convert To Integer    ${coord}[3]
    ${variable_damping} =    Create Dictionary    x=${x_loc}   y=${y_loc}
    TAP BY LOCATION    ${variable_damping}
    Sleep    5s
    CHECK AND TAP ON IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${mode}
    CHECK IMAGE DISPLAYED ON SCREEN    ${ivi_adb_id}    ${image_to_validate}
    SET DELETE FILE    bench    ${ref_image}
    SET DELETE FILE    bench    ${image_to_validate}
    SET DELETE FILE    bench    ${mode}
