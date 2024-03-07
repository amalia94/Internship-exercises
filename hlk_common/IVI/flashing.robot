#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Flashing related keywords library
Library           rfw_services.ivi.WaitForAdbDevice
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           rfw_services.ivi.FileSystemLib    device=${ivi_adb_id}
Library           String
Library           OperatingSystem

*** Variables ***
&{target}                host=bench    dut=ivi

*** Keywords ***
LAUNCH SW RECOVERY UPGRADE
    [Arguments]    ${target_id}
    [Documentation]    Launch the SW recovery upgrade over USB.
    ...    ${target_id}    the target on which the SW RECOVERY UPGRADE has to be performed
    Log To Console    Launching USB SW Recovery Upgrade...
    ${output} =     OperatingSystem.Run    adb -s ${ivi_adb_id} shell service call recovery 2 s16 --usb_update_package=Update.zip
    Should Contain    ${output}    Parcel(00000000 00000001    msg=command to launch sw recovery failed with message:${output}
    ${output} =     OperatingSystem.Run    adb -s ${ivi_adb_id} shell service call power 22 i32 0 s16 'recovery-update' i32 1

VERIFY DEVICE STATE AFTER SW RECOVERY UPGRADE
    [Arguments]    ${target_id}    ${timeout}
    [Documentation]    Verify that the USB SW upgrade has successfully updated on ${target_id}
    ...    ${target_id}    The target on which the SW RECOVERY UPGRADE has to be verified
    ...    ${timeout}      The timeout duration for the verification of SW RECOVERY UPGRADE
    Log To Console    Verifying device has not booted to recovery mode....
    Log    Waiting for 120000 ms for the device to get into expected state    console=True
    DO WAIT    ${120000}
    ${timeout_ms} =    Evaluate    ${timeout} * ${1000}
    ${itr_timeout_ms} =    Set Variable    ${30000}
    ${itrs} =    Evaluate    ${timeout_ms} / ${itr_timeout_ms}
    FOR    ${itr}    IN RANGE    ${itrs}
        SET ROOT
        ${output_1} =    GET PROP    ro.serialno
        # Exit For Loop If   "recovery" not in "${output_1}" and "\tdevice" in "${output_1}"
        ${devices_list} =    Set Variable    ${output_1.replace("List of devices attached", "").replace("\n", "").replace("\r", "")}
        # ${contains} =    Evaluate    "device" in "${devices_list.replace("\n", "").replace("\r", "")}"
        Exit For Loop If   "recovery" not in "${devices_list}" and "\tdevice" in "${devices_list}"
        Log    Waiting for ${itr_timeout_ms} ms for the device to get into expected state    console=True
        DO WAIT    ${itr_timeout_ms}
    END
    Run Keyword If    "recovery" in "${devices_list}"    Run Keywords    Log    The device is in recovery mode which is not the expected state. Pulling /tmp/upgrade.log and /tmp/recovery.log for debug and rebooting to normal mode....    level=ERROR
    ...    AND   PULL    /tmp/upgrade.log    /tmp/recovery.log
    ...    AND   DO REBOOT    ${target_id}    command line
    ...    AND   WAIT FOR ADB DEVICE    120
    ...    AND   CHECK IVI BOOT COMPLETED    booted    120
    Should Not Be True    "recovery" in "${devices_list}"    Software upgrade failed, device was in recovery mode following upgrade procedure

CHECK USB SW UPGRADE VERDICT
    [Arguments]    ${target_id}    @{fw_to_check}
    [Documentation]    Parses upgrade.log to verify if each of FW in list_of_fw_to_check has been successfully updated
    ...    ${target_id}      The target on which the USB SW UPGRADE VERDICT has to be checked
    ...    @{fw_to_check}    The firmewares to be verified if they are upgraded or not using the log
    ...    ${stick_cutter}   Tests that use this HLK must define stick_cutter variable
    Log    fw_to_check: @{fw_to_check}    console=True
    Log    Checking SW Upgrade verdict...    console=True
    ${upgrade_contents}    ${recovery_contents} =    Run Keyword If    '${usb_selector_type}' in "'${stick_cutter_type}'"    GET USB UPDATE LOGS
    ...    ELSE    DO ADB GET UPDATE LOGS

    Run Keyword If    "main_os" in ${fw_to_check}    Should Match Regexp    ${recovery_contents}    Firmware Update .* SUCCESS
    Run Keyword If    "micom" in ${fw_to_check}    Should Contain    ${upgrade_contents}    micom_upgrade_complete
    Run Keyword If    "dsp" in ${fw_to_check}    Should Contain    ${upgrade_contents}    finish updating DSP firmware
    Run Keyword If    "Ethernet" in ${fw_to_check}    Should Contain    ${upgrade_contents}    Ethernet Firmware Upgrade Finish
    Run Keyword If    "gnss" in ${fw_to_check}    Should Contain    ${upgrade_contents}    GNSS Firmware Upgrade Finish

CHECK MAIN OS VERSION
    [Arguments]    ${target_id}    ${main_os_version}
    [Documentation]    Compare the ${main_os_version} with the main_os version of the ${target_id}
    ...    ${target_id}    The target on which the main_os version has to be checked
    ${fw_ver}    ${error} =    GET PROP    ro.build.version.incremental
    Should Contain    ${fw_ver}    ${main_os_version}    Failed to perform FOTA Recovery upgrade

COPY FLASH FILE TO GREYSTICK
    [Documentation]    Copy the recovery flash file to the greystick
    Log To Console    COPY FLASH FILE TO GREYSTICK
    File Should Exist    ${artifacts_path}/Update.zip    File ${artifacts_path}/Update.zip is not found
    Run Keyword If    '${usb_selector_type}' in "'${stick_cutter_type}'"    COPY TO USB AND PLUG TO VEHICLE    ${artifacts_path}
    ...    ELSE    DO ADB FLASH FILE COPY TO GREYSTICK

DO ADB FLASH FILE COPY TO GREYSTICK
    [Documentation]    Copy the recovery flash file to the greystick and perform MD5 Compare
    ...    All tests that use this keyword should define variables ${stick_cutter} and ${artifacts_path}
    Log To Console    DO ADB FLASH FILE COPY TO GREYSTICK and perform MD5 Compare
    SET USB STATUS     ${stick_cutter}    plugged
    ${usb_stick_id} =    Run Keyword If    "${usb_stick_id}" == "${None}"    IDENTIFY CURRENT USB VOLUME    ${ivi_adb_id}    ${stick_cutter}
    ...    ELSE    Set Variable     ${usb_stick_id}
    DO ADB GREYSTICK CLEAR     ${usb_stick_id}
    ${output}    ${error} =    PUSH    ${artifacts_path}/Update.zip    /mnt/runtime/full/emulated/10/Download     timeout=${1200}
    Should Contain    ${error}    b''    Error pushing Update file onto IVI
    ${output}    ${error} =    CREATE FOLDER    /storage/${usb_stick_id}/USB_UPDATE
    Should Not Contain    ${output}    No such file or directory    Error creating folder on USB stick
    ${output}    ${error} =    MOVE FILE    /mnt/runtime/full/emulated/10/Download    Update.zip    /storage/${usb_stick_id}/USB_UPDATE
    Should Not Contain    ${output}    No such file or directory    Error moving Update file from IVI to USB stick
    Should Contain    ${output}    b''    Error moving Update file from IVI to USB stick
    SET MD5 COMPARE      bench     ivi            ${artifacts_path}/Update.zip    storage/${usb_stick_id}/USB_UPDATE/Update.zip
    Log    Update.zip has been copied to: storage/${usb_stick_id}/USB_UPDATE ${\n}, checksum is a match with host file...   console=True

DO ADB GREYSTICK CLEAR
    [Arguments]    ${usb_key_name}
    [Documentation]    DO ADB GREYSTICK CLEAR
    ...    All tests that use this keyword should define variables ${stick_cutter}

    Log To Console    DO ADB GREYSTICK CLEAR
    SET USB STATUS     ${stick_cutter}    plugged
    ${usb_key_name} =    Run Keyword If    "${usb_key_name}" == "${None}"    IDENTIFY CURRENT USB VOLUME    ${ivi_adb_id}    ${stick_cutter}
    ...    ELSE    Set Variable     ${usb_key_name}

    SET DELETE FILE    ${target}[dut]    /storage/${usb_key_name}/USB_UPDATE
    SET DELETE FILE    ${target}[dut]    /storage/${usb_key_name}/upgrade.log

DO ADB GET UPDATE LOGS
    SET USB STATUS     ${stick_cutter}    plugged
    ${usb_stick_id} =    Run Keyword If    "${usb_stick_id}" == "${None}"    IDENTIFY CURRENT USB VOLUME    ${ivi_adb_id}    ${stick_cutter}
    ...    ELSE    Set Variable     ${usb_stick_id}

    ${output}    ${error} =    PULL    /storage/${usb_stick_id}/upgrade.log    /tmp/${usb_stick_id}/upgrade.log
    Should Contain    ${output}    bytes in    msg=upgrade log could not be retrieved from flash drive    values=False
    ${upgrade_contents} =    Get File    upgrade.log
    ${output}    ${error} =    PULL    /storage/${usb_stick_id}/recovery.log    /tmp/${usb_stick_id}/recovery.log
    Should Contain    ${output}    bytes in    msg=upgrade log could not be retrieved from flash drive    values=False
    ${recovery_contents} =    Get File    recovery.log
    [Return]    ${upgrade_contents}    ${recovery_contents}


COPY TO USB AND PLUG TO VEHICLE
    [Documentation]  Copy usb update content and plug key to vehicle
  ...  | *Keyword*                       | *Path*                          |
  ...  | COPY TO USB AND PLUG TO VEHICLE | Path on the PC with usb content |
  [Arguments]  ${path}
  COPY TO USB KEY  ${path}
  ${path_to_key} =  Join Path  ${key_default_path}  ${usb_stick_id}

  PLUG USB KEY TO VEHICLE
  SLEEP  30s

CLEAR USB KEY
  [Documentation]  Remove all the content from the USB key
  ...  | *Keyword*     |
  ...  | CLEAR USB KEY |
  ${path_to_key} =  JOIN PATH  ${key_default_path}  ${usb_stick_id}

  DIRECTORY SHOULD EXIST  ${path_to_key}
  @{files}=  LIST FILES IN DIRECTORY  ${path_to_key}
  @{directories}=  LIST DIRECTORIES IN DIRECTORY  ${path_to_key}
  @{file_paths}=  JOIN PATHS  ${path_to_key}  @{files}
  @{directory_paths}=  JOIN PATHS  ${path_to_key}  @{directories}
  LOG TO CONSOLE  Clean Up USB KEY...
  REMOVE FILES  @{file_paths}
  FOR  ${directory}  IN  @{directory_paths}
    REMOVE DIRECTORY  ${directory}  recursive=True
  END

GET MD5
  [Documentation]  Calculate the MD5 signature for the desired file
  ...  | *Keyword*              | *File*                      |
  ...  | GET MD5 | Path to the file to compute |
  [Arguments]  ${file}
  ${output}=  RUN  md5sum '${file}'
  @{elts}=  SPLIT STRING  ${output}  ${SPACE}
  ${output}=  GET FROM LIST  ${elts}  0
  RETURN FROM KEYWORD  ${output}

COMPARE DIRECTORIES
  [Documentation]  Check that content of `dir1` is present on `dir2`
  ...  | *Keyword*           | *Dir1*        | *Dir2*        |
  ...  | COMPARE DIRECTORIES | /path/to/dir1 | /path/to/dir2 |
  ${path_to_key}=  JOIN PATH  ${key_default_path}  ${usb_stick_id}

  [Arguments]  ${dir1}  ${dir2}
  @{files}=  LIST FILES IN DIRECTORY  ${dir1}
  FOR  ${file}  IN  @{files}
    ${path1}=  JOIN PATH  ${dir1}  ${file}
    ${path2}=  JOIN PATH  ${dir2}  ${file}
    FILE SHOULD EXIST  ${path2}
    ${md5_1}=  GET MD5  ${path1}
    ${md5_2}=  GET MD5  ${path2}
    SHOULD BE EQUAL  ${md5_1}  ${md5_2}
  END

COPY TO USB KEY
  [Documentation]  Copy the content of `local_path` to the USB key.
  ...  | *Keyword*              | *Local Path*                    |
  ...  | COPY UPDATE TO USB KEY | Path on the PC with usb content |
  [Arguments]  ${local_path}
  PLUG USB KEY TO PC
  ${path_to_key}=  JOIN PATH  ${key_default_path}  ${usb_stick_id}

  MOUNT USB DISK  ${path_to_key}
  SLEEP  10s
  WAIT UNTIL KEYWORD SUCCEEDS  10s  3s  DIRECTORY SHOULD EXIST  ${path_to_key}
  CLEAR USB KEY
  @{files}=  LIST FILES IN DIRECTORY  ${local_path}
  @{directories}=  LIST DIRECTORIES IN DIRECTORY  ${local_path}
  @{file_paths}=  JOIN PATHS  ${local_path}  @{files}
  @{directory_paths}=  JOIN PATHS  ${local_path}  @{directories}
  LOG TO CONSOLE  Copy update content to the USB key...
  ${path_to_usb_update}=  Join Path  ${path_to_key}  USB_UPDATE
  ${result}  ${output}=  RUN AND RETURN RC AND OUTPUT  mkdir ${path_to_usb_update}
  SHOULD BE EQUAL AS INTEGERS  ${result}  0  ${output}
  FOR  ${file}  IN  @{file_paths}
    OperatingSystem.COPY FILE  ${file}  ${path_to_usb_update}
  END
  RUN  sync
  COMPARE DIRECTORIES  ${local_path}  ${path_to_usb_update}
  Log    Update.zip has been copied directly to USB stick
  UNMOUNT USB DISK

MOUNT USB DISK
  [Documentation]  mount usb disk.
  ...  | *Keyword*      | *Path*               |
  ...  | MOUNT USB DISK |  path to usb key     |
  [Arguments]  ${path_disk}

  ${usb_key_link}=  SEARCH USB KEY LINK
  ${exit}=  RUN KEYWORD AND RETURN STATUS  Directory Should Exist  ${path_disk}
  ${result}  ${output}=  RUN KEYWORD IF  ${exit}==False  RUN AND RETURN RC AND OUTPUT  mkdir -p ${path_disk} && mount ${usb_key_link} ${path_disk}
  ...                    ELSE  RUN AND RETURN RC AND OUTPUT  mount ${usb_key_link} ${path_disk}
  SHOULD BE EQUAL AS INTEGERS  ${result}  0  ${output}
  #${mount_res}  ${mount_output}=  RUN AND RETURN RC AND OUTPUT  df -h
  #SHOULD BE EQUAL AS INTEGERS  ${mount_res}  0  ${mount_output}
  #SHOULD CONTAIN  ${mount_output}  ${usb_key_link}

UNMOUNT USB DISK
    [Documentation]  Unmount USB disk.
  ...  | *Keyword*      | *Path*               |
  ...  | UNMOUNT USB DISK |  path to usb key     |
  ${usb_key_link}=  SEARCH USB KEY LINK
  ${result}  ${output}=  RUN AND RETURN RC AND OUTPUT  umount ${usb_key_link} -v
  SHOULD BE EQUAL AS INTEGERS  ${result}  0  ${output}

SEARCH USB KEY LINK
  [Documentation]  Get USB key name.
  ...  | *Keyword*           | *Path*            |
  ...  | SEARCH USB KEY LINK |  path to usb key  |
  # [Arguments]  ${path_disk}
  SLEEP  15s
  ${dev_output}=  OperatingSystem.Run  ls -l /dev/disk/by-id/usb*
  SHOULD NOT CONTAIN  ${dev_output}  No such file or directory
  @{dev_result}=  Split To Lines  ${dev_output}
  ${usb_device_info}=  Get From List  ${dev_result}  -1
  @{split_res_dev}=  Split String  ${usb_device_info}  separator=/
  ${usb_name}=  Get From List  ${split_res_dev}  -1
  ${usb_key_link}=  Join Path  /dev  ${usb_name}
  RETURN FROM KEYWORD  ${usb_key_link}

PLUG USB KEY TO PC
  [Documentation]  Plug the USB key to the PC
  ...  | *Keyword*          |
  ...  | PLUG USB KEY TO PC |
  ${host_pc_cutter_line}=    Run Keyword If     ${dut_cutter_line} == 0     Set Variable    1
  ...    ELSE     Set Variable    0
  ${result}  ${output}=  RUN AND RETURN RC AND OUTPUT  clewarecontrol -d ${stick_cutter} -as ${host_pc_cutter_line} 1
  SHOULD BE EQUAL AS INTEGERS  ${result}  0  ${output}

PLUG USB KEY TO VEHICLE
  [Documentation]  Plug the USB key to the Vehicle
  ...  | *Keyword*               |
  ...  | PLUG USB KEY TO VEHICLE |
  ${result}  ${output}=  RUN AND RETURN RC AND OUTPUT  clewarecontrol -d ${stick_cutter} -as ${dut_cutter_line} 1
  SHOULD BE EQUAL AS INTEGERS  ${result}  0  ${output}
  SLEEP  30s

GET USB UPDATE LOGS
  [Documentation]  Get usbrecovery and upgrade log file from USB key.
  ...  | *Keyword*          | *Path*            |
  ...  | GET USB UPDATE LOG |  /DISK/   |
  # [Arguments]  ${name_file}=recovery.log
  # ${date}=  GET DATETIME
  PLUG USB KEY TO PC
  ${key_path}=  Join Path  ${key_default_path}  ${usb_stick_id}

  MOUNT USB DISK  ${key_path}
  ${name_log_folder}=  CATENATE  SEPARATOR=_  usb  update
  ${local_directory}=  JOIN PATH  ${OUTPUT DIR}  ${name_log_folder}
  OperatingSystem.CREATE DIRECTORY  ${local_directory}

  ${recovery_file}=  JOIN PATH  ${key_path}  recovery.log
  SHOULD EXIST  ${recovery_file}
  LOG TO CONSOLE  Getting ${recovery_file} log ...
  OperatingSystem.COPY FILE  ${recovery_file}  ${local_directory}
  # LOG TO CONSOLE  Got Log ...
  # LOG  <a href="./${name_log_folder}/${name_file}">${name_file}</a>  HTML
  ${recovery_contents}=  Operatingsystem.Get File  ${recovery_file}

  ${upgrade_file}=  JOIN PATH  ${key_path}  upgrade.log
  SHOULD EXIST  ${upgrade_file}
  LOG TO CONSOLE  Getting ${upgrade_file} log ...
  OperatingSystem.COPY FILE  ${upgrade_file}  ${local_directory}
  # LOG TO CONSOLE  Got Log ...
  # LOG  <a href="./${name_log_folder}/${name_file}">${name_file}</a>  HTML
  ${upgrade_contents}=  Operatingsystem.Get File  ${upgrade_file}
  UNMOUNT USB DISK
  RETURN FROM KEYWORD  ${upgrade_contents}    ${recovery_contents}
