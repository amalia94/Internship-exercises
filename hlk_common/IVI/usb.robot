#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     System test utility
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.USBStorageLib    device=${ivi_adb_id}
Library           rfw_services.ivi.DiagnosticLib    device=${ivi_adb_id}
Library           rfw_services.ivi.LogsLib    device=${ivi_adb_id}
Library           rfw_services.usb_cutter.UsbCutter
Library           String
Library           Collections
Library           OperatingSystem
Resource          ${CURDIR}/appium_hlks.robot

*** Variables ***
${ivi_adb_id}         ${None}
${mode}               on
${duid}               ${None}
${connectivity}       //*[@text='Connectivity']
${off_button}         //*[@text='OFF']
${on_button}          //*[@text='ON']
${key_default_path}   /media/renault
${download_url}       matrix/artifacts/audio/
${usb_selector_sub_type}    Multi2x
${documentui}    //*[@resource-id='com.android.documentsui:id/action_icon_area']

*** Keywords ***

CHECK FILE PRESENT ON USB
    [Arguments]    ${file}    ${status}
    [Documentation]    Indicate if ${file} is found on the storage(s) plugged
    ${is_present} =    CHECK FILE ON USB    ${file}
    Run Keyword If    "${status}"=="present"    Should Be True    ${is_present[0]}    File: '${file}' is not present on USB drive
    Run Keyword If    "${status}"=="absent"    Should Not Be True    ${is_present[0]}    File: '${file}' is present on USB drive

CHECK FLASH DRIVE STATUS
    [Arguments]    ${memory_device}    ${status}
    [Documentation]    Checks if the flash memory is present or not in regard of the DUT
    ...    ${memory_device} name of the memory device
    ...    ${status} present/not present
    Log To Console    Checks if the flash memory: ${memory_device} is ${status}
    ${memory_device_id} =    Set Variable If    "${memory_device}"=="usb"    ${usb_stick_id}
    ${user_name}    ${user_id} =    ADB_AM_GET_CURRENT_USER_NAME
    FOR    ${i}    IN RANGE    0    5
        Sleep    5s
        ${output} =  Run Keyword If     "${platform_version}" == "10"    OperatingSystem.Run    adb shell ls /storage/
        ...    ELSE    OperatingSystem.Run    adb shell ls /mnt/pass_through/${user_id}/
        ${memory_device_found} =    Run Keyword And Return Status    Should Contain    ${output}    ${memory_device_id}
        Exit For Loop If    "${memory_device_found}" == "${True}"
    END
    Run Keyword If    "${status}" == "present"    Should Contain    ${output}    ${memory_device_id}
    Run Keyword Unless    "${status}" == "present"    Should Not Contain    ${output}    ${memory_device_id}

IDENTIFY CURRENT USB VOLUME
    [Arguments]    ${target_id}    ${usb_cutter_id}
    [Documentation]    Returns the duid of the USB flash drive connected to the specified usb cutter
    Run Keyword If    "${usb_cutter_id}"=="${None}"    FAIL    A valid usb_cutter_id must be provided but is abent
    CHECKSET USB STATUS    ${usb_cutter_id}    unplugged
    ${volumes_attached_before_connect} =    GET STORAGE VOLUMES
    CHECKSET USB STATUS    ${usb_cutter_id}    plugged
    ${usb_volume_found}    IS USB DETECTED
    Should Be True    ${usb_volume_found}    No flash drive found
    ${volumes_attached_after_connect} =    GET STORAGE VOLUMES
    ${duid} =    GET CURRENT DUID    ${volumes_attached_before_connect}    ${volumes_attached_after_connect}
    Should Be True    ${duid}[0]    Failed to get duid value attached to usb cutter: ${usb_cutter_id}
    [Return]    ${duid}[1]

CHECKSET PREPARE USB DRIVE
    [Arguments]    ${file}    ${OPT_volume_name}
    [Documentation]    To prepare  the usb device using PC host by pushing a file into the volume, and optionnally
    ...    defining a volume name, and formatting the volume into a certain format system (NTFS, FAT32...)
    ...    ${file} file which need be download.
    ...    ${OPT_volume_name}: name of usb volume
    SET USB STATUS    ${stick_cutter}    plugged
    ${file_name} =    Fetch From Right    ${file}    /
    ${is_present} =    CHECK FILE ON USB    ${file_name}
    ${is_downloaded}    ${file} =    Run Keyword If    "${is_present}[0]" == "False"    DOWNLOAD FILE FROM ARTIFACTORY    ${download_url}${file_name}
    Run Keyword If    "${is_present}[0]" == "False"    Should Be True    ${is_downloaded}    File not downloaded
    ${downloaded_file} =    Set Variable If    "${is_downloaded}" == "True"    ${bench_path}/${file_name}
    Run Keyword if    "${is_present}[0]" == "False"    SET FILE COPY    bench    usb    ${downloaded_file}    ${file}
    ${file_check} =    Run Keyword If    "${is_present}[0]" == "False"    CHECK FILE ON USB    ${file_name}
    Run Keyword If    "${is_present}[0]" == "False"    should be true    ${file_check}[0]    ${file}is not present in target.

SET USB STATUS
    [Arguments]    ${target_id}    ${connection_status}    ${device_plugged}=${None}    ${connection_target}=ivi    ${after_ivi_boot}=True
    [Documentation]    Set the USB Status of ${target_id} to ${connection_status}
    ...    ${device_plugged} can be usb_stick or a smartphone. smartphone can be connected using USB Multi 2 or USB Multi 2x
    ...    ${connection_target} the target where the smartphone should be connected. This is considered only in case of USB Multi 2x
    Log To Console    Set the USB Status of ${target_id} to ${connection_status}
    ${cutter_type} =    Run Keyword If    "${device_plugged}" == "smartphone"    Set Variable If    '${usb_selector_type}' in "'${smartphone_cutter_type}'"    double    simple
    ...    ELSE    Set Variable If    '${usb_selector_type}' in "'${stick_cutter_type}'"    double    simple
    IF    "${cutter_type}"=="double"
        ${cutter_sub_type} =    Run Keyword If    "${device_plugged}" == "smartphone"    Set Variable If    '${usb_selector_sub_type}' in "'${smartphone_cutter_sub_type}'"    Multi2x    Multi2
        ...    ELSE    Set Variable If    '${usb_selector_sub_type}' in "'${stick_cutter_sub_type}'"    Multi2x    Multi2
    END
    Run Keyword If    "${cutter_type}"=="simple"    CUTTER TYPE WITH SIMPLE    ${target_id}    ${connection_status}
    ...    ELSE IF    "${cutter_type}"=="double"    CUTTER TYPE WITH DOUBLE    ${target_id}    ${connection_status}    ${cutter_sub_type}    ${connection_target}    ${after_ivi_boot}

CHECKSET USB STATUS
    [Arguments]    ${target_id}    ${connection_status}    ${device_plugged}=${None}    ${connection_target}=ivi    ${after_ivi_boot}=True
    [Documentation]    Check and Set if needed the USB Status of ${target_id} to ${connection_status}
    IF    "${device_plugged}" == "smartphone"
        Log    "CHECK for smartphone is not yet implemented, SET USB STATUS will be used."
        SET USB STATUS     ${target_id}    ${connection_status}    ${device_plugged}    ${connection_target}    ${after_ivi_boot}
    ELSE   
        IF    "${connection_target}" == "ivi"
            ${usb_detected} =    IS USB DETECTED
            ${usb_detected} =    Set Variable     ${usb_detected}[0]
            ${usb_detected} =    Set Variable    Flase 
            Log to console     ${usb_detected} forced to flase until MATRIX-74960 is integrated
            Log    "${usb_detected} forced to flase until MATRIX-74960 is integrated"
        ELSE IF    "${connection_target}" == "hostpc"
            ${usb_system_output}=    OperatingSystem.Run    sudo blkid
            ${usb_detected} =     run keyword and return status    Should Contain    ${usb_system_output}    ${usb_stick_id}
        END  
        ${check_result} =    Run Keyword If   "${connection_status}" == "plugged" and "${usb_detected}"=="True"    Set Variable     True
            ...    ELSE IF    "${connection_status}" == "unplugged" and "${usb_detected}"=="False"    Set Variable    True
            ...    ELSE    Set Variable    False   
        Run Keyword If    "${check_result}"=="False"    SET USB STATUS     ${target_id}    ${connection_status}    ${device_plugged}    ${connection_target}    ${after_ivi_boot}
    END

CUTTER TYPE WITH SIMPLE
    [Arguments]    ${target_id}    ${connection_status}
    [Documentation]    Cutter type with simple mode
    IF    "${connection_status}" == "plugged"
        ${output} =    CONNECT USB LINE    ${target_id}    cutter_type=simple    port_number=0
        ${set_to_off} =    Evaluate    "set to Off" in """${output}"""
        Should Be True    ${set_to_off}    USB cutter plug FAILed - Check wih 'sudo udevadm trigger'
    ELSE
        ${output} =    CUT USB LINE    ${target_id}    cutter_type=simple    port_number=0
        ${set_to_on} =    Evaluate    "set to On" in """${output}"""
        Should Be True    ${set_to_on}    USB cutter unplug FAILed - Check wih 'sudo udevadm trigger'
    END

CUTTER TYPE WITH DOUBLE
    [Arguments]    ${target_id}    ${connection_status}    ${cutter_sub_type}    ${connection_target}    ${after_ivi_boot}
    [Documentation]    Cutter type with double mode
    IF     "${cutter_sub_type}"=="Multi2x"
        ${switch_num} =    Set Variable If    "${connection_target}"=="ivi"    1
        ...    "${connection_target}"=="hostpc"    0
        IF    "${connection_status}" == "plugged"
            ${output} =    CONNECT USB LINE    ${target_id}    cutter_type=double    port_number=${switch_num}
            ${set_to_on} =    Evaluate    "set to On" in """${output}"""
            Should Be True    ${set_to_on}    USB selector plug FAILed - Check wih 'sudo udevadm trigger'
        ELSE
            ${usb_stick_blkid} =    GET USB STICK BLOCK
            Run Keyword If    "${usb_stick_blkid}" != "${None}"    Run Process    sudo eject --force ${usb_stick_blkid}    shell=True
            Sleep    10s
            ${usb_system_output}=    OperatingSystem.Run    sudo blkid
            Should Not Contain    ${usb_system_output}    ${usb_stick_id}    Usb_stick is detected after sucessful ejection on host_pc
            #Actions to do perform safe ejection in case usb-stick is connected to IVI - Start
            ${driver_output} =    Run Keyword If    """${ivi_driver}""" == "None" and "${ivi_hmi_action}"=="False" and "${after_ivi_boot}"=="True"    CREATE APPIUM DRIVER
            IF    "${after_ivi_boot}"=="True"
                CLEAR PACKAGE    com.android.documentsui
                LAUNCH APP APPIUM    Files
                ${result} =   APPIUM_WAIT_FOR_XPATH    ${documentui}
                Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    ${documentui}
                LAUNCH APP APPIUM    Navigation
                CLEAR PACKAGE    com.android.documentsui
                Run Keyword If    """${driver_output}""" != "None" and "${ivi_hmi_action}"=="False"    REMOVE APPIUM DRIVER    ${ivi_capabilities}
            END
            #Actions to do perform safe ejection in case usb-stick is connected to IVI - End
            ${output} =    CUT USB LINE    ${target_id}    cutter_type=double    port_number=0
            ${set_to_off} =    Evaluate    "set to Off" in """${output}"""
            Should Be True    ${set_to_off}    USB selector unplug FAILed - Check wih 'sudo udevadm trigger'
            ${output} =    CUT USB LINE    ${target_id}    cutter_type=double    port_number=1
            ${set_to_off} =    Evaluate    "set to Off" in """${output}"""
            Should Be True    ${set_to_off}    USB selector unplug FAILed - Check wih 'sudo udevadm trigger'
        END
    ELSE IF    "${cutter_sub_type}"=="Multi2"
        # Multi2 does not support complete disconnection
        IF    "${connection_status}" == "plugged"
            # Connect to IVI
            ${output} =    CONNECT USB LINE    ${target_id}    cutter_type=double    port_number=0
            ${set_to_on} =    Evaluate    "set to On" in """${output}"""
            Should Be True    ${set_to_on}    USB selector plug FAILed - Check wih 'sudo udevadm trigger'
        ELSE
            # Connect to hostpc
            ${output} =    CUT USB LINE    ${target_id}    cutter_type=double    port_number=0
            ${set_to_off} =    Evaluate    "set to Off" in """${output}"""
            Should Be True    ${set_to_off}    USB selector unplug FAILed - Check wih 'sudo udevadm trigger'
        END
    END

CHECK LOG FILE PRESENT ON USB
    [Documentation]    To check logcat log file present on USB
    ${user_id} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell am get-current-user
    SET ROOT
    IF    "${ivi_my_feature_id}" == "MyF3"
        ${op} =    LISTING CONTENTS    mnt/pass_through/${user_id}/${usb_stick_id}/logfiles_aivi2/alliance_log
    ELSE
        ${op} =    LISTING CONTENTS    storage/${usb_stick_id}/logfiles_aivi2/alliance_log
    END
    Should Not Contain    ${op}    No such file or directory    ignore_case=True
    ${op_strip} =    Strip String    ${op}[0]    characters=b'
    @{log_files} =  Split String    ${op_strip}    ${SPACE}
    ${log_file_name} =    Collections.Get From List    ${log_files}    0
#    To be replaced with get_date from LoggerRealtime.py once it is exposed
    ${op} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell date
    ${op_strip} =    Strip String    ${op}    characters=\\n'
    @{year_date_time} =  Split String    ${op_strip}
    ${date} =    Collections.Get From List    ${year_date_time}    2
    ${year} =    Collections.Get From List    ${year_date_time}    5
    ${hour_min_sec} =    Collections.Get From List    ${year_date_time}    3
    ${hour} =    Get substring    ${hour_min_sec}    0    2
    Should Contain    ${log_file_name}    ${year}
    IF    "${ivi_my_feature_id}" == "MyF3"
        ${pull_log_file} =    OperatingSystem.Run   adb pull /mnt/pass_through/${user_id}/${usb_stick_id}/logfiles_aivi2/alliance_log/${log_file_name}
    ELSE
        ${pull_log_file} =    OperatingSystem.Run   adb pull storage/${usb_stick_id}/logfiles_aivi2/alliance_log/${log_file_name}
    END
    OperatingSystem.Run    cd ${log_file_name}
    ${file} =      OperatingSystem.Run    ls | grep "2023"| tail -1
    ${file_strip} =    Strip String    ${file}    characters=.zip'
    ${unzip_file} =    OperatingSystem.Run    7z x ${file} -aoa -pABCDEFGH
    ${grep_marker} =    OperatingSystem.Run    cat ${file_strip} | grep "marker" | wc -l
    Should Be True     '${grep_marker}'!=' 0'

CHECK LOG FILE SIZE ON USB
    [Documentation]    To verify logcat log files size is not zero
    SET ROOT
    IF    "${ivi_my_feature_id}" == "MyF3"
        ${user_id} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell am get-current-user
        ${op} =    LISTING CONTENTS    /mnt/pass_through/${user_id}/${usb_stick_id}/logfiles_aivi2/alliance_log
    ELSE
        ${op} =    LISTING CONTENTS    storage/${usb_stick_id}/logfiles_aivi2/alliance_log
    END
    ${op_strip} =    Strip String    ${op}[0]    characters=b'
    ${log_size} =  Get substring    ${op_strip}    0    8
    ${size} =    Remove String    ${log_size}    total
    Should Be True     '${size}'!=' 0'
    Log to console    USB logcat log folder size is not zero and size is ${log_size}KB

ACTIVATE USB LOGGING SYSTEM
    [Documentation]    To enable logcat log capturing on USB stick
    SET ROOT
    ${result} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb Configuration set usb_encryption_config/logandtraces/activateencryptiononusbstick:"\\'ABCDEFGH\\'"
    DO REBOOT    ${target_id}    command line
    CHECK IVI BOOT COMPLETED    booted    120
    SET ROOT
    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER    Settings
#    ALLIANCE CAR LOG SERVICE

CHECKSET AUDIO FILE PRESENT ON USB A10
    [Arguments]    ${file_name}
    [Documentation]    To verify audio file presence on usb for A10
    ...    ${file_name} name of the file to check
    CHECKSET FILE PRESENT    ivi    /storage/${usb_stick_id}/${file_name}

CHECKSET AUDIO FILE PRESENT ON USB A12
    [Arguments]    ${file_name}    
    [Documentation]    To verify audio file presence on usb for A12
    ...    ${file_name} name of the file to check
    ${user_id} =   OperatingSystem.Run    adb -s ${ivi_adb_id} shell am get-current-user
    CHECKSET FILE PRESENT    ivi    /mnt/androidwritable/${user_id}/${usb_stick_id}/${file_name}

CHECKSET AUDIO FILE PRESENT ON USB
    [Arguments]    ${dut_id}    ${file_name}     
    [Documentation]    To verify audio file presence on usb
    ...    ${dut_id} the dedicated DUT
    ...    ${file_name} name of the file to check
    CHECKSET USB STATUS    ${stick_cutter}    plugged
    Sleep    5
    ${usb_stick_id} =    Run Keyword If    "${usb_stick_id}" == "${None}"    IDENTIFY CURRENT USB VOLUME    ${dut_id}    ${stick_cutter}
    ...    ELSE    Set Variable     ${usb_stick_id}
    IF    "${platform_version}" == "10"
        CHECKSET AUDIO FILE PRESENT ON USB A10    ${file_name}
    ELSE
        CHECKSET AUDIO FILE PRESENT ON USB A12    ${file_name}
    END

CHECK SMARTPHONE STATUS
    [Arguments]    ${dut_id}    ${status}
    [Documentation]    To verify if the smartphone and the hostpc are connected or disconnected
    ...    ${dut_id} smartphone_adb_id
    ...    ${status} connected or disconnected
    Log To Console    To verify if the smartphone: ${dut_id} and hostpc are ${status}
    ${result} =    WAIT FOR ADB DEVICE    device=${dut_id}    timeout=30
    Run Keyword If    "${status}"=="connected"    Should Be True    ${result}
    Run Keyword If    "${status}"=="disconnected"    Should Not Be True    ${result}

GET USB STICK BLOCK
    [Documentation]    To get the usb-stick block id
    Log To Console    To get the usb-stick block id
    ${usb_system_output}=    OperatingSystem.Run    sudo blkid
    Log To Console    ${usb_system_output}
    @{usb_system_split_output} =    Split String    ${usb_system_output}    \n
    ${usb_system_len}=    Get Length    ${usb_system_split_output}
    ${usb_stick_blkid} =    Set Variable    ${None}
    FOR    ${value}    IN RANGE    0    ${usb_system_len}
        ${value}=    Convert To String    ${usb_system_split_output}[${value}]
        ${value} =    Replace String    ${value}   "    ${EMPTY}
        @{string_split}=    Run Keyword If    "${usb_stick_id}" in "${value}"    Split string    ${value}    :
        Continue For Loop If    "${usb_stick_id}" not in "${value}"
        ${usb_stick_blkid} =    Set Variable    ${string_split}[0]
    END
    [Return]    ${usb_stick_blkid}

MOUNT USB STICK TO DOCKER
    [Arguments]    ${usb_stick_blkid}
    [Documentation]    To mount the susb stick to the docker
    ...    ${usb_stick_blkid} blkid of the usb-stick to be mounted
    OperatingSystem.Run    mkdir /mnt/usb
    OperatingSystem.Run    sudo mount ${usb_stick_blkid} /mnt/usb
    ${ls_usb_stick}=    OperatingSystem.Run    ls /mnt/usb
    Should Not Contain    ${ls_usb_stick}    No such file or directory    msg=Failed to mount usb-stick to the docker
    Should Not Be Empty    ${ls_usb_stick}    msg=Failed to mount usb-stick to the docker
