#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     scdard keywords library
Library           rfw_services.ivi.SDCardLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}

*** Variables ***

&{target}         host=bench    dut=ivi
${sd_status}      present
${test_folder}    TestFolder
${ivi_path}       /storage

*** Keywords ***
CHECK SDCARD STATUS
    [Arguments]    ${dut_id}    ${status}
    [Documentation]    Check SD card status on a dedicated DUT
    ...    ${dut_id} the dedicated DUT
    ...    ${status} expected status (either present or not_present)
    SET ROOT
    ${is_present}    ${sd_partition}    ${sd_label} =    IS SDCARD DETECTED
    Set Test Variable    ${sd_label}
    Set Test Variable    ${sd_path}    ${ivi_path}/${sd_partition}
    Set Test Variable    ${sd_test_folder_path}    ${sd_path}/${test_folder}
    ${is_sd2_test} =    Run Keyword And Return Status    Should Contain    ${test_name}    SDCARD_002
    Run Keyword If    "${is_sd2_test}" == "True"    Set Test Variable    @{sd_test_files_to_check}    ${sd_test_folder_path}/${audio_test_file}    ${sd_test_folder_path}/${video_test_file}    ${sd_test_folder_path}/${pic_test_file}
    Run Keyword If    "${status}" == "present"    Should Be True    ${is_present}    SD card not present on DUT
    Run Keyword If    "${status}" == "not_present"    Should Not Be True    ${is_present}    SD card present on DUT
