#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           Process
Library           String
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           XML
Library           rfw_services.ivi.SystemLib           device=${ivi_adb_id}
Library           rfw_services.ivi.WaitForAdbDevice
Library           rfw_services.ivi.DiagnosticLib    device=${ivi_adb_id}
Library           rfw_services.ivi.ServiceLib    device=${ivi_adb_id}

Resource          ../Vehicle/CAN/can_remote_services.robot
Resource          Connectivity/wifi.robot
Resource          Connectivity/gps.robot
Resource          filesystem.robot
Resource          appium_hlks.robot
Resource          image.robot
Resource          userprofil.robot

Variables         ${CURDIR}/KeyCodes.yaml

*** Variables ***
${more_button}            //*[@text='MORE' or @text='More']
${bluetooth_button}       //*[@text='Bluetooth']
${system_item}            //*[@text='System']
${reset_options_item}     //*[@text='Reset options']
${factory_reset_item}     //*[@text='Erase all data (factory reset)' or @text='Restore factory settings']
${reset_vehicle_item}    //*[@text='RESET VEHICLE' or @text='Reset vehicle' or @text='Reset' or @text='Erase all data']
${erase_everything}    //*[@text='ERASE EVERYTHING' or @text='Erase everything' or @text='Erase data']
${max_time_after_reboot}    60.0
${app_to_launch}    com.android.car.settings/.Settings
${back_desktop}    com.android.car.overview/.StreamOverviewActivity
${reboot_type}    command line
${pin_password_value}    5346
${console_logs}    yes
@{admin_profile_list}    Driver    Conducteur    Chauff\\xc3\\xb8r    Admin
${update_menu}    //android.widget.TextView[@text='Update']
${check_for_update_button}    //*[@text='Check for update']
${VehicleSettings_Check_Update}    Check for update
${VehicleSettings_Update_Ongoing}   Update ongoing
${VehicleSettings_back_button}    com.renault.vehiclesettings:id/toolbar_nav
${Vehicle_no_update}   //*[@text='No update available for your vehicle']

${REDBEND_SWMS_SELECT_FILE}    /fota/packages/test_server
${REDBEND_SWMC_DIRECTORY}     /data/data/com.redbend.client/files
${REDBEND_SWMC_REGISTRY}     /data/data/com.redbend.client/files/reg.conf
@{TEMPORARY_FILES}   /fota/MP.bin  /fota/meta.xml  /fota/aum_context.json  /fota/installation_order.txt  /fota/inventory_info.json  /fota/parsed_menu.json

&{STATE_CHECK_FOR_UPDATE}    SMM\\DM_SESSION/__state__=SESSION_inProgress
&{STATE_WAIT_FOR_DOWNLOAD}   SMM\\SCOMO_DL\\RB_DP/__state__=SCOMO_DL_waitConfirm
&{STATE_DOWNLOADING}         SMM\\SCOMO_DL\\RB_DP/__state__=SCOMO_DL_downloading
&{STATE_WAIT_FOR_INSTALL}    SMM\\SCOMO_SWM_INS\\RB_DP/__state__=SCOMO_INS_waitForConfirmation  SMM\\SCOMO_SWM_INS\\RB_DP/DMA_VAR_INS_PHASE=1
&{STATE_INSTALLING}          SMM\\SCOMO_SWM_INS\\RB_DP/__state__=SCOMO_INS_waitForResults       SMM\\SCOMO_SWM_INS\\RB_DP/DMA_VAR_INS_PHASE=1
&{STATE_WAIT_FOR_ACTIVATE}   SMM\\SCOMO_SWM_INS\\RB_DP/__state__=SCOMO_INS_waitForConfirmation  SMM\\SCOMO_SWM_INS\\RB_DP/DMA_VAR_INS_PHASE=2
&{STATE_ACTIVATING}          SMM\\SCOMO_SWM_INS\\RB_DP/__state__=SCOMO_INS_waitForResults       SMM\\SCOMO_SWM_INS\\RB_DP/DMA_VAR_INS_PHASE=2
&{STATE_DP_GENERATION}       SMM\\SCOMO_TRIGGER/DMA_VAR_DP_IN_PROCESSING=1
&{STATE_IDLE}                SMM\\DM_SESSION/__state__=SESSION_idle

&{FOTA_STATE_CRITERIA}  check_for_update=${STATE_CHECK_FOR_UPDATE}
...                     wait_for_download=${STATE_WAIT_FOR_DOWNLOAD}
...                     downloading=${STATE_DOWNLOADING}
...                     wait_for_install=${STATE_WAIT_FOR_INSTALL}
...                     installing=${STATE_INSTALLING}
...                     wait_for_activate=${STATE_WAIT_FOR_ACTIVATE}
...                     activating=${STATE_ACTIVATING}
...                     generating_dp=${STATE_DP_GENERATION}
...                     idle=${STATE_IDLE}

&{fota_bearer_state}  WIFI_AND_IVC_WIFI_PREFERED=0
...                   IVC_ONLY=1
...                   WIFI_ONLY=2
...                   NA=3

${DEFAULT_FOTA_BEARER}    IVC_ONLY
${fota_bearer}    ${DEFAULT_FOTA_BEARER}


*** Keywords ***
CHECK IVI BOOT COMPLETED
    [Arguments]    ${state}    ${timeout}=30    ${TC_folder}=${EMPTY}
    [Documentation]    Checks that the device under test is booted to a specific state
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}CHECK IVI BOOT COMPLETED${\n}
    ${result} =    RUN KEYWORD IF    "${ivi_adb_id}"=="${None}"    WAIT FOR ADB DEVICE    ${timeout}
    ...    ELSE    WAIT FOR ADB DEVICE    ${ivi_adb_id}    ${timeout}     

    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${result}    No adb device was detected within the timeout window
    ...    ELSE    Should Be True    ${result}    No adb device was detected within the timeout window
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    An adb device has been detected!
    WAIT BOARD BOOTED    1    ${timeout}    ${ivi_adb_id}
    ${user_interface_proccess_status}=    IS USER INTERFACE RUNNING    ${state}    ${timeout}
    ${ivi_build_type} =    GET IVI BUILD TYPE
    Run Keyword If    "${ivi_build_type}" == "userdebug"    SET ROOT
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${user_interface_proccess_status}    Device under test is not ${state}
    ...    ELSE    Should Be True    ${user_interface_proccess_status}    Device under test is not ${state}
    ${ivi_platform_type} =    GET DEVICE HARDWARE
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    IVI BOOT COMPLETED
    [return]    ${user_interface_proccess_status}

CHECK IVI CONNECTED
    [Arguments]    ${timeout}=60
    [Documentation]    Checks that the device under test is disconnected from ADB point of view
    ${result}=    WAIT FOR ADB DEVICE    ${ivi_adb_id}    ${timeout}
    Should Be True    ${result}    No adb device was detected within the timeout window
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    An adb device has been detected!

CHECK IVI DISCONNECTED
    [Arguments]    ${timeout}=60
    [Documentation]    Checks that the device under test is disconnected from ADB point of view
    SET IMMERSIVE MODE    off
    ${result}=    WAIT FOR ADB DEVICE TO DISCONNECT    ${timeout}
    Should Be True    ${result}    Device under test is not discconnected after the timeout ${timeout}
    # SWL-35842: Futur implementation to check IVI is sending sequence (via CAN-M)
    # Wait Until Keyword Succeeds    ${timeout}    1s    CHECK FRAME VALUE    ${frame_id}    ${canbus}    ${state}

CHECK STATE EXPECTED
    [Arguments]    ${state}    ${timeout_adb}    ${dut_id}    ${TC_folder}=${EMPTY}
    [Documentation]     KW created to group CHECK IVI BOOT COMPLETED & WAIT FOR ADB DEVICE TO DISCONNECT
    ...    ${state}: state expected (online or offline)
    ...    ${timeout_adb}: timeout allowed to the device to be online/offline
    ...    ${dut_id}: adb id of the device
    # cases of single and multi env
    ${timeout_adb_converted} =    Convert To Integer     ${timeout_adb}
    ${result}    Set Variable
    ${result} =    Run Keyword If     "${state}" == "online" and "${dut_id}" == "${none}"    CHECK IVI BOOT COMPLETED    booted    ${timeout_adb_converted}
    ...         ELSE IF     "${state}" == "offline" and "${dut_id}" == "${none}"    WAIT FOR ADB DEVICE TO DISCONNECT    ${timeout_adb_converted}
    ...         ELSE IF     "${state}" == "online" and "${dut_id}" != "${none}"    CHECK STATE ADB DEVICE ID    ${state}    ${timeout_adb_converted}    ${dut_id}
    ...         ELSE IF     "${state}" == "offline" and "${dut_id}" != "${none}"    CHECK STATE ADB DEVICE ID    ${state}    ${timeout_adb_converted}    ${dut_id}
    ...         ELSE        Log    Wrong value
     Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${result}    Wrong adb device state:${result}
    ...    ELSE    Should Be True    ${result}    Wrong adb device state:${result}

GET IVI INFO
    ${adb_id} =    GET IVI ADB ID
    Run Keyword If    "${ivi_adb_id}" != "${None}" and "${ivi_adb_id}" != "${empty}"    Should Be True    "${ivi_adb_id}" == "${adb_id}"    IVI ADB ID [${ivi_adb_id}] from parameter is not aligned with target IVI ADB ID [${adb_id}]!!
    Set Suite Variable    ${ivi_adb_id}    ${adb_id}

    ${ivi_platform_type} =    GET DEVICE HARDWARE
    Set Suite Variable    ${ivi_platform_type}
    Set Tags     [IVI] Platform Type : ${ivi_platform_type}

    ${ivi_build_id} =    GET IVI BUILD ID
    Set Tags     [IVI] Build ID : ${ivi_build_id}
    Set Suite Variable    ${ivi_build_id}

    ${ivi_build_type} =    GET IVI BUILD TYPE
    Set Tags     [IVI] Build Type : ${ivi_build_type}
    Set Suite Variable    ${ivi_build_type}

    ${board_type} =    GET IVI BOARD TYPE
    Set Tags     [IVI] Board Type : ${board_type}
    Set Suite Variable    ${board_type}

WAIT BOARD BOOTED
    [Arguments]    ${interval}    ${duration}    ${target_id}=None
    [Documentation]    Will check every ${interval} seconds, during ${duration} seconds, that the ${target_id} can be correctly enumerated for engineering operations
    ${count_limit} =    Evaluate    int(${duration}/${interval})
    ${counter} =    Set Variable    0
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Checking IVI target ${target_id} is alive every ${interval}s...
    FOR    ${counter}    IN RANGE    ${count_limit}+1
        ${result} =    IS DEVICE BOOTED    on    ${target_id}
        Run Keyword If    ${result} == True    Run Keyword if    "${console_logs}" == "yes"     Log To Console    IVI is alive (after ${counter}s)
        Run Keyword If    ${result} == True or ${counter} == ${count_limit}+1   Exit For Loop
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    IVI adb device not yet detected. Retrying in ${interval}s.
        Sleep    ${interval}
    END
    Should Be True    ${result}    Target device is not booted after ${duration}s!
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    IVI adb target ${target_id} is alive. Success.

GET IVI BUILD ID
    [Documentation]    get build id of the IVI
    ${result_build} =  Set Variable   ${EMPTY}
    ${stdout}    ${stderr} =    GET PROP    ro.vendor.build.fingerprint
    Should be empty    ${stderr}
    # AOSP & AIVI2 cases
    ${status1} =    Evaluate    "aivi2" in """${stdout}"""
    ${status2} =    Evaluate    "aosp" in """${stdout}"""
    IF  ${status1} or ${status2}
        ${build_split_dash} =    Split String     ${stdout}    /
        Log To Console   ${build_split_dash}
        ${ret_build_split} =    Split String     ${build_split_dash}[4]    :
            # case of AOSP
            IF  ${status2}
                ${result_build} =  Set Variable   "AOSP_${ret_build_split}[0]"
            ELSE
                ${result_build} =  Set Variable   ${ret_build_split}[0]
            END
    END
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    IVI build ID : ${result_build}
    [Return]    ${result_build}

DO REBOOT AND CHECK BOOT UI
    [Documentation]    Will do a reboot of IVI by command "adb reboot" & in logcat check for the presence of
    ...    "boot_progress_enable_screen" by using cmd line
    DO REBOOT AND CHECK BOOT COMPLETED PASSRATE    ${ivi_adb_id}    0    1
    CHECK IVI BOOT COMPLETED    booted    120
    WAIT FOR LOGCAT TRIGGER    message=boot_progress_enable_screen
    STOP ANALYZING LOGCAT DATA
    Run Keyword If    '${ivi_hmi_action}' == 'True'    Run Keywords    REMOVE APPIUM DRIVER
    ...    AND    CREATE APPIUM DRIVER


DO REBOOT AND CHECK BOOT COMPLETED PASSRATE
    [Arguments]    ${ivi_adb_id}    ${flag}    ${loops}
    [Documentation]    Do a number of reboots and calculate the pass rate
    ...    ${ivi_adb_id} the dedicated DUT
    ...    ${flag} time in seconds to wait between loops
    ...    ${loops} number of reboots
    SET LOGCAT TRIGGER    message=boot_progress_enable_screen
    START ANALYZING LOGCAT DATA
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}Expecting to reboot ${loops} time(s)
    FOR    ${var}    IN RANGE    1    ${loops} + 1
        SET REBOOT    ${ivi_adb_id}    ${reboot_type}
        Sleep    ${flag}
    END
    Log    Boot completed passrate is ${var} on ${loops}    level=HTML

DO FACTORY RESET APPIUM
    [Arguments]    ${dut_id}
    GO HOME AND CLEAR SETTINGS APP    ${dut_id}
    LAUNCH APP APPIUM    Settings
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${system_item}    direction=down    scroll_tries=12
    Should Be True    ${result}
    APPIUM_TAP_XPATH    ${system_item}    30
    APPIUM_TAP_XPATH    ${reset_options_item}    30
    APPIUM_TAP_XPATH    ${factory_reset_item}    30
    APPIUM_TAP_XPATH    ${reset_vehicle_item}    30
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${reset_vehicle_item}
    Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    ${reset_vehicle_item}    30
    ${result} =   APPIUM_WAIT_FOR_XPATH    ${erase_everything}
    Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    ${erase_everything}
    ${dut_discon}=    WAIT FOR ADB DEVICE TO DISCONNECT    10
    IF    "${dut_discon}"=="False"
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Enter your password']
        Run Keyword If    "${result}"=="True"    Run keywords    APPIUM_ENTER_TEXT_XPATH    //*[@text='Enter your password']    ${pin_password_value}
        ...    AND    sleep    3s
        ...    AND    APPIUM_PRESS_KEYCODE   ${KEYCODE_ENTER}
        ${result} =   APPIUM_WAIT_FOR_XPATH    //*[@text='Enter your PIN']
        Run Keyword If    "${result}"=="True"    SET SETUP WIZARD PIN    ${pin_password_value}
        ${result} =   APPIUM_WAIT_FOR_XPATH    ${erase_everything}
        Run Keyword If    "${result}"=="True"    APPIUM_TAP_XPATH    ${erase_everything}
        ${dut_discon}=    WAIT FOR ADB DEVICE TO DISCONNECT
        Should Be True    ${dut_discon}
    END
    CHECK IVI BOOT COMPLETED    booted    120
    [Return]    ${result}

SET REBOOT
    [Arguments]    ${target_id}    ${reboot_type}    ${loops}=1
    [Documentation]    Reboot target and check the operation was successful
    ...    ${target_id} either the bench or DUT
    ...    ${reboot_type} how to reboot the target (command line, reset button or HMI)
    ...    ${loops} number of reboots (default is 1)
    FOR    ${var}    IN RANGE    1    ${loops} + 1
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    ${\n}Triggering reboot ${var} of ${loops}...
        ${is_booted} =    Run Keyword if    "${reboot_type}" == "command line"    rfw_services.ivi.SystemLib.REBOOT    max_wait_time=${max_time_after_reboot}
        Run Keyword if    "${reboot_type}" == "reset button"    Log    "reset button" reboot type is not implemented yet    level=HTML
        Run Keyword if    "${reboot_type}" == "HMI"    Log    "HMI" reboot type is not implemented yet    level=HTML
        Run Keyword if    ${is_booted} == False    Exit For Loop
    END
    ${reboots} =    Set Variable If    ${is_booted} == True    ${var}    ${var - 1}
    Log    ${reboots} successful reboot(s) on ${loops}    level=HTML
    Run Keyword if    ${is_booted} == False    Fail    Reboot failed

DO REBOOT
    [Arguments]    ${target_id}    ${reboot_type}     ${max_wait_time}=30.0    ${poll_interval}=2    ${min_reboot_start_time}=20
    [Documentation]    Send reboot command to a target
    ...    ${target_id} either the bench or DUT
    ...    ${reboot_type} how to reboot the target (command line, reset button or HMI)
    # Retrieve keyword's default returned values
    # REBOOT
    #
    # Override keyword's default parameters + retrieve returned value
    # REBOOT
    #
    # Default keyword usage
    Run Keyword if    "${reboot_type}" == "command line"    rfw_services.ivi.SystemLib.REBOOT     ${max_wait_time}    ${poll_interval}    ${min_reboot_start_time}
    Run Keyword if    "${reboot_type}" == "reset button"    Log    "reset button" reboot type is not implemented yet    level=HTML
    Run Keyword if    "${reboot_type}" == "HMI"    Log    "HMI" reboot type is not implemented yet    level=HTML

SET SWITCH ACCOUNT
    [Arguments]    ${account}    ${status}    ${target_id}
    [Documentation]    To switch the user account: ${account} to state: ${status} on ${target_id}
    ...    ${account}: Name of account to check like Driver or Guest
    ...    ${status}: Status in which the account is to be checked and set. active or inactive
    ...    ${target_id}: name of target_id like ivi
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Switching the user account: ${account} to state: ${status} on ${target_id}
    ${active_account} =    Set Variable If
    ...    "${status}" == "active" and "${ivi_platform_type}" == "aivi2_full"    ${account}
    ...    "${status}" == "active" and "${ivi_platform_type}" == "aivi2_r_full_dom"    ${account}
    ...    "${status}" == "active" and "${ivi_platform_type}" == "aivi2_core" and "${account}" == "Conducteur"    Chauff\\xc3\\xb8r
    ...    "${status}" == "active" and "${ivi_platform_type}" == "aivi2_core" and "${account}" != "Conducteur"    ${account}
    ...    "${status}" == "active" and "${ivi_platform_type}" == "aivi2_r_accessda" and "${account}" == "Conducteur"    Conducteur
    ...    "${status}" == "active" and "${ivi_platform_type}" == "aivi2_r_accessda" and "${account}" != "Conducteur"    ${account}
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_full" and "${account}" == "Conducteur"    Guest
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_full" and "${account}" == "Guest"    Conducteur
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_core" and "${account}" == "Conducteur"    Guest
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_core" and "${account}" == "Guest"    Chauff\\xc3\\xb8r
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_core" and "${account}" != "Guest"  and "${account}" != "Conducteur"   Guest
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_r_accessda" and "${account}" == "Conducteur"    Guest
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_r_accessda" and "${account}" == "Guest"    Chauff\\xc3\\xb8r
    ...    "${status}" == "inactive" and "${ivi_platform_type}" == "aivi2_r_accessda" and "${account}" != "Guest"  and "${account}" != "Conducteur"   Guest
    ${all_users} =    OperatingSystem.Run    adb -s ${target_id} shell pm list users
    ${all_users} =    Split String    ${all_users}    separator=\n
    ${all_users} =    Set Variable    ${all_users}[2:]
    Log List    ${all_users}
    FOR    ${user}    IN    @{all_users}
        Continue For Loop If    "Driver" not in "${user}"
        ${active_account} =    Set Variable If    "${active_account}" in "Conducteur Chauff\\xc3\\xb8r"    Driver    ${active_account}
        Exit For Loop
    END
    ${active_account} =    Set Variable If    "Driver" in "${all_users}" and "${active_account}" in "Conducteur Chauff\\xc3\\xb8r"    Driver    ${active_account}
    ${current_user_name} =    GET CURRENT USER NAME
    Return From Keyword If    "${current_user_name}"=="${active_account}"
    ${user_id} =    GET USER ID BY NAME    ${active_account}
    SWITCH TO USER    ${user_id}
    DO WAIT     20000
    ${current_user_name} =    GET CURRENT USER NAME
    Should Be Equal    ${current_user_name}    ${active_account}    Failed to switch ${account} to ${status} on ${target_id}

SET IVI BOOT MODE
    [Arguments]    ${ivi_mode}
    [Documentation]    Set IVI2 boot mode (quick or normal) for the next boot. This keyword is meant to be used when there is no CAN activity and the IVI2 is powered off
    ...    ${ivi_mode}: The IVI2 boot mode.(EX: "quick"(ecs) or "normal"(cold) boot)
    ${mode} =    Set Variable If    "${ivi_mode}" == 'quick'    e    c
    ${script_path} =    Set Variable    ${CURDIR}/PnP/src/Manual_ON_OFF_scripts
    Start Process    bash  ${script_path}/AVI-on.bash  slcan0  1   alias=proc_wake_up
    WAIT FOR ADB DEVICE    ${ivi_adb_id}    timeout=60 
    Start Process    bash  ${script_path}/AVI-on.bash  slcan0  ${mode}    alias=proc_ivi_mode
    Wait For Process    proc_ivi_mode    timeout=2m    on_timeout=kill
    Terminate Process    proc_wake_up
    Terminate Process    proc_ivi_mode
    ${res_wake_up}=    Get Process Result    proc_wake_up
    Should Be Equal    "${res_wake_up.rc}"    "0"    ${res_wake_up.stderr}
    ${res_ivi_mode}=    Get Process Result    proc_ivi_mode
    Should Be Equal    "${res_ivi_mode.rc}"    "0"    ${res_ivi_mode.stderr}
    Sleep    1m

CHECK IVI BOOT MODE
    [Arguments]    ${ivi_mode}
    [Documentation]    Check IVI boot mode
    ...    ${ivi_mode}: The IVI2 boot mode.(EX: "quick"(ecs) or "normal"(cold) boot)
    ${boot_reason}    ${error} =    GET PROP    vendor.alliance.boot.reason
    @{boot_reason} =     Split String    ${boot_reason}    ,
    @{boot_reason} =     Split String    ${boot_reason}[-1]    ]
    ${verdict} =     Evaluate    '${boot_reason}[0]' == '${ivi_mode}'
    [Return]    ${verdict}    ${boot_reason}[0]

SWITCH IVI TO ADMIN USER
    ${all_users} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pm list users
    ${all_users} =    Split String    ${all_users}    separator=\n
    ${all_users} =    Set Variable    ${all_users}[2:]
    Log List    ${all_users}
    FOR    ${user}    IN    @{all_users}
        #Continue For Loop If    'Driver' not in '${user}' or 'Conducteur' not in '${user}' or 'Chauff\\xc3\\xb8r' not in '${user}'
        ${user_id} =    Split String    ${user}    {
        ${user_id} =    Split String    ${user_id}[1]    }
        ${user_id} =    Split String    ${user_id}[0]    :
        Run Keyword If    "${user_id}[1]" in @{admin_profile_list}       Run keywords       SWITCH TO USER    ${user_id}[0]
        ...    AND     DO WAIT    15000
        Exit For loop if    "${user_id}[1]" in @{admin_profile_list}
    END

CHECK SYNCH TIME
    [Documentation]  Check Time synchronization IVI - System Time.
    ...  | *Keyword*   |
    ...  | CHECK SYNCH TIME |
    ${pc_time}=  GET CURRENT DATE  time_zone=local  result_format=%Y-%m-%d %H:%M:%S
    ${ivi_time}=  GET TIME
    ${late}=  SUBTRACT DATE FROM DATE  ${pc_time}  ${ivi_time}
    RETURN FROM KEYWORD IF  ${late} < 86400
    FAIL  Synchronization failed

OPEN OR CLOSE THE NOTIFICATION BAR
    [Arguments]    ${notification_bar}=collapse
    [Documentation]  Open and close notification bar.
    ...    notification_bar: collapse/expand
    ...    collapse: close the notification bar
    ...    expand: open the notification bar
    ${verdict} =    EXPAND OR COLLAPSE STATUSBAR    ${notification_bar}
    Should Be True    ${verdict}
    SLEEP  3s

CONNECT TO WIFI
    [Documentation]  Connect IVI to WiFi.
    ...  | *Keyword*        |
    ...  | CONNECT TO WIFI  |
    ${conn_status} =  RUN KEYWORD AND RETURN STATUS  IS WIFI CONNECTED
    RETURN FROM KEYWORD IF  ${conn_status}==True
    ENABLE WIFI
    SLEEP  10s
    ${conn_status}=  RUN KEYWORD AND RETURN STATUS  IS WIFI CONNECTED
    RETURN FROM KEYWORD IF  ${conn_status}==True
    OPEN OR CLOSE THE NOTIFICATION BAR
    START INTENT    -a android.settings.WIRELESS_SETTINGS
    ${conn_status} =  RUN KEYWORD AND RETURN STATUS  IS WIFI CONNECTED
    RETURN FROM KEYWORD IF  ${conn_status}==True
    CHECK WIFI NETWORK APPIUM    ${ivi_adb_id}    ${wifi_ssid}    present
    DO WIFI CONNECT APPIUM    ${ivi_adb_id}    ${wifi_ssid}    ${wifi_pwd}
    SLEEP  10s
    ${conn_status} =  RUN KEYWORD AND RETURN STATUS  IS WIFI CONNECTED
    RETURN FROM KEYWORD IF  ${conn_status}==True
    WAIT UNTIL KEYWORD SUCCEEDS  15s  2s  IS WIFI CONNECTED

DECODE
    [Documentation]  Decode byte array to simple string.
    ...  | *Keyword* | *Data*               |
    ...  | DECODE    | b'my encoded string' |
    [Arguments]  ${data}
    RETURN FROM KEYWORD IF  ${data} == None  ''
    ${data}=  GET SUBSTRING  ${data}  2  -1
    ${data}=  REPLACE STRING  ${data}  \\n  ${\n}
    RETURN FROM KEYWORD  ${data}

DELETE DIRECTORY CONTENT
    [Documentation]  Delete directory content from `directory_path` in the IVI.
    ...  | *Keyword*                | *Directory Path* |
    ...  | DELETE DIRECTORY CONTENT | /ivi/path/       |
    [Arguments]  ${directory_path}
    ${exists}=  RUN KEYWORD AND RETURN STATUS  IS PATH EXISTS  ${directory_path}
    RETURN FROM KEYWORD IF  ${exists}==False
    DELETE FOLDER OR FILE    ${directory_path}/*
    @{result}=  LISTING CONTENTS    ${directory_path}
    SHOULD BE EMPTY  ${result}

DELETE FILE
    [Documentation]  Delete file `file_path` from the IVI.
    ...  | *Keyword*   | *File Path*                  |
    ...  | DELETE FILE | /ivi/path/file_to_delete.txt |
    [Arguments]  ${file_path}
    ${exists}=  RUN KEYWORD AND RETURN STATUS  IS PATH EXISTS  ${file_path}
    RETURN FROM KEYWORD IF  ${exists}==False
    DELETE FOLDER OR FILE    ${file_path}
    ${exist}=  RUN KEYWORD AND RETURN STATUS  IS PATH EXISTS  ${file_path}
    RETURN FROM KEYWORD IF  ${exist}==False
    FAIL  Fail to delete file ${file_path}

GPS CHECK
    [Documentation]  Check GPS Syncro.
    ...  | *Keyword*   |
    ...  | GPS CHECK |
    ${result}=    SET GPS STATUS    ${target_id}    ${status}   
    SHOULD BE TRUE  ${result}
    WAIT UNTIL KEYWORD SUCCEEDS  2min  10s  CHECK SYNCH TIME

GET ACTIVE BANK
    [Documentation]  Return the current active software bank as a string.
    ...  | *Keyword*       |
    ...  | GET ACTIVE BANK |
    ${value}=  GET PROPERTY  ro.boot.slot_suffix
    ${value}=  REMOVE STRING  ${value}  _
    RETURN FROM KEYWORD  ${value}

GET BUILD FINGERPRINT
    [Documentation]  Return the software fingerprint.
    ...  | *Keyword*             |
    ...  | GET BUILD FINGERPRINT |
    ${value}=  GET PROPERTY  ro.build.fingerprint
    RETURN FROM KEYWORD  ${value}

GET FOTA BEARER
    [Documentation]  Return the current value of fota_bearer parameter.
    ...  | *Keyword*       |
    ...  | GET FOTA BEARER |
    ${value_bin}=  ADB DIAG READ BINARY DID  2000
    ${fota_bearer_bin}=  GET SUBSTRING  ${value_bin}  83  85
    ${fota_bearer_bin}=  CONVERT TO BINARY  ${fota_bearer_bin}  base=2  length=8
    ${fota_bearer_int}=  CONVERT TO INTEGER  ${fota_bearer_bin}  base=2
    FOR  ${state}  IN  @{fota_bearer_state}
        ${state_int}=  GET FROM DICTIONARY  ${fota_bearer_state}  ${state}
        EXIT FOR LOOP IF  '${state_int}'=='${fota_bearer_int}'
    END
    RETURN FROM KEYWORD  ${state}

GET SOFTWARE VERSION
    [Documentation]  Return the software version.
    ...  | *Keyword*            |
    ...  | GET SOFTWARE VERSION |
    ${value}=  GET PROPERTY  ro.build.version.incremental
    RETURN FROM KEYWORD  ${value}

GET PROPERTY
    [Documentation]  Return the value of the desired android property `propname`.
    ...  | *Keyword*    | *Prop Name*      |
    ...  | GET PROPERTY | ro.property.fake |
    [Arguments]  ${propname}
    @{result}=  GET PROP  ${propname}
    ${value}=  GET FROM LIST  ${result}  0
    RETURN FROM KEYWORD  ${value}

GET UPDATE STATE
    [Documentation]  Return the current update state.
    ...  | *Keyword*        |
    ...  | GET UPDATE STATE |
    ${registry}=  JOIN PATH  ${REDBEND_SWMC_DIRECTORY}  reg.conf
    ${client_file}=   GET FILE FROM IVI  ${registry}  ${TEMP_DIR}
    ${content}=  OperatingSystem.GET FILE  ${client_file}
    @{lines}=  SPLIT TO LINES  ${content}
    &{params}=  CREATE DICTIONARY
    FOR  ${line}  IN  @{lines}
        ${key}  ${value}=  SPLIT STRING  ${line}  =  1
        SET TO DICTIONARY  ${params}  ${key}  ${value}
    END

    FOR  ${state}  IN  @{FOTA_STATE_CRITERIA}
        &{criteria}=  GET FROM DICTIONARY  ${FOTA_STATE_CRITERIA}  ${state}
        ${contains}=  RUN KEYWORD AND RETURN STATUS  DICTIONARY SHOULD CONTAIN SUB DICTIONARY  ${params}  ${criteria}
        EXIT FOR LOOP IF  '${contains}'=='True'
    END
    LOG  Fota State is ${state}  console=True
    RETURN FROM KEYWORD  ${state}

GET VERSION
    [Documentation]  Return fingerprint, software version and active bank.
    ...  | *Keyword* |
    ...  | GET VERSION   |
    ${fingerprint}=  GET BUILD FINGERPRINT
    ${activebanc}=  GET ACTIVE BANK
    ${version}=  GET SOFTWARE VERSION

GET FILE FROM IVI
    [Documentation]  Get file `src_file` from the IVI and store it on the host PC in `dest_path`. Return PC complete file path.
    ...  | *Keyword* | *Src File*            | *Dest Path*          |
    ...  | GET FILE FROM IVI  | /ivi/path/my_file.txt | /pc/path             |
    [Arguments]  ${src_file}  ${dest_path}
    IS PATH EXISTS  ${src_file}
    ${result}=  PULL    ${src_file}    ${dest_path}
    ${path}  ${file_name}=  SPLIT PATH  ${src_file}
    ${file_path}=  JOIN PATH  ${dest_path}  ${file_name}
    FILE SHOULD EXIST  ${file_path}
    RETURN FROM KEYWORD  ${file_path}

SKIP WIZARD
    [Documentation]  Skip the setup wizard
    ...  | *Keyword*             |
    ...  | SKIP WIZARD |
    SET PROP    ro.setupwizard.mode    DISABLED
    SEND COMMAND  killall com.renault.setupwizardoverlay

HARD RESET
    [Documentation]  Perform a diag hard reset
    ...  | *Keyword*  |
    ...  | HARD RESET |
    ${response}=  DIAG EMULATOR HARDRESET
    ${response}=  GET FROM LIST  ${response}  0
    SHOULD CONTAIN  ${response}  Success
    SLEEP  10s
    WAIT BOOT

IS AVAILABLE
    [Documentation]  Check if device adb interface is available.
    ...  | *Keyword*    |
    ...  | IS AVAILABLE |
    [Arguments]    ${timeout}=60
    ${response}=  OperatingSystem.RUN  adb -s ${ivi_adb_id} devices
    SHOULD CONTAIN  ${response}  ${ivi_adb_id}

IS BOOTED
    [Documentation]  Fail if the IVI is not started.
    ...  | *Keyword* |
    ...  | IS BOOTED |
    ${value}=  GET PROPERTY  dev.bootcomplete
    SHOULD BE EQUAL  ${value}  1

IS PATH EXISTS
    [Documentation]  Check if the path `path` exists on the IVI filesystem
    ...  | *Keyword*      | *Path*               |
    ...  | IS PATH EXISTS | /my/path/to/file.txt |
    ...  | IS PATH EXISTS | /my/directory/path   |
    [Arguments]  ${path}
    @{result}=  LISTING CONTENTS    ${path}
    ${response}=  CATENATE  SEPARATOR=${SPACE}  @{result}
    ${exists}=  RUN KEYWORD AND RETURN STATUS  SHOULD NOT CONTAIN  ${response}  No such file or directory
    RETURN FROM KEYWORD IF  ${exists}==True
    FAIL  ${path} does not exist

IS UPDATE STATE
    [Documentation]  Fail if the update state is not the expected `state`.
    ...  | *Keyword*       | *State*     |
    ...  | IS UPDATE STATE | downloading |
    [Arguments]  ${state}
    ${update_state}=  GET UPDATE STATE
    SHOULD BE EQUAL  ${update_state}  ${state}

SEND COMMAND
    [Documentation]  Send shell command on device adb interface. Returns list of lines with concatenation of stdout and stderr.
    ...  | *Keyword*    | *Command*  | *block status* |
    ...  | SEND COMMAND | ls         |  Default: True   |
    [Arguments]  ${command}  ${block_status}=True
    WAIT UNTIL KEYWORD SUCCEEDS  1min  10s  IS AVAILABLE
    ADB_SET_ROOT
    ${RC}  ${output}=    OperatingSystem.Run And Return Rc And Output    adb -s ${ivi_adb_id} shell ${command}
    ${result}=  CATENATE  SEPARATOR=${\n}  ${output}  ${RC}
    @{result}=  SPLIT TO LINES  ${result}
    RETURN FROM KEYWORD  ${result}

PRESS BUTTON
    [Documentation]  Press 'button' on screen.
    ...  | *Keyword*    | *Button*         |
    ...  | PRESS BUTTON | OK               |
    ...  | PRESS BUTTON | Check for update |
    [Arguments]  ${button}  ${retry}=20
    TAP_ON_ELEMENT_USING_XPATH    //*[@text='${button}']   ${retry}

CLEAR FOTA CLIENT FILES
    [Documentation]  Delete all fota client files.
    ...  | *Keyword*               |
    ...  | CLEAR FOTA CLIENT FILES |
    SEND COMMAND  killall update_engine
    SEND COMMAND  killall update_engine
    FOR  ${file}  IN  @{TEMPORARY_FILES}
        DELETE FILE  ${file}
    END
    DELETE DIRECTORY CONTENT  /fota/inventory
    DELETE DIRECTORY CONTENT  /fota/packages
    DELETE FOLDER OR FILE   /fota/tmpdir.*
    DELETE FOLDER OR FILE   /fota/parsed*
    DELETE DIRECTORY CONTENT  ${REDBEND_SWMC_DIRECTORY}

WAIT FOTA READY
    [Documentation]  Wait for fota application to be ready for new update
    ...  | *Keyword*       |
    ...  | WAIT FOTA READY |
    START FOTA APPLICATION
    FOR  ${try}  IN RANGE  21
        ${result}=    APPIUM_GET_ATTRIBUTE_BY_XPATH    ${check_for_update_button}    enabled
        EXIT FOR LOOP IF  '${result}'.lower()=='true'
    END

RESET DIAG ROUTINE
    [Documentation]  Diag routine to reset fota client
    ...  | *Keyword*          |
    ...  | RESET DIAG ROUTINE |
    ${exist}=  RUN KEYWORD AND RETURN STATUS  IS PATH EXISTS  ${REDBEND_SWMS_SELECT_FILE}
    ${result}=  DIAG START CONTROL ROUTINE    02A4
    ${result}=  GET SLICE FROM LIST  ${result}  end=-1
    ${result}=  GET FROM LIST  ${result}  0
    SHOULD NOT CONTAIN  ${result}  7f 31  Negative response from Routine 02A4
    LOG  Routine 02A4 in progress  console=True
    SLEEP  20s
    ${result}=  DIAG GET CONTROL ROUTINE RESULT    02A4
    ${result}=  GET SLICE FROM LIST  ${result}  end=-1
    ${result}=  GET FROM LIST  ${result}  0
    ${result}=  REPLACE STRING  ${result}  ${SPACE}  ${EMPTY}
    SHOULD CONTAIN  ${result}  710302a420
    LOG  Routine 02A4 completed  console=True
    @{file_lst}=  LISTING CONTENTS  /fota/package/
    SHOULD BE EMPTY  ${file_lst}
    IF  ${exist} == True
       rfw_services.ivi.FileSystemLib.Create File    ${REDBEND_SWMS_SELECT_FILE}
       SEND COMMAND  sync
    END
    HARD RESET

SET FOTA BEARER
    [Documentation]  Update the value of fota_bearer parameter.
    ...  | *Keyword*              | state   |
    ...  | SET FOTA BEARER       | ENABLE_US  |
    [Arguments]  ${bearer}
    ${actual_bearer}=  GET FOTA BEARER
    RETURN FROM KEYWORD IF  '${actual_bearer}'=='${bearer}'
    ${fota_bearer_int}=  GET FROM DICTIONARY  ${fota_bearer_state}  ${bearer}
    ${fota_bearer_bin}=  CONVERT TO BINARY  ${fota_bearer_int}  base=10  length=2
    ${value_bin}=  ADB DIAG READ BINARY DID  2000
    ${length_bin}=  GET LENGTH  ${value_bin}
    ${length_hex}=  EVALUATE  ${length_bin}/4
    ${value_begin}=  GET SUBSTRING  ${value_bin}  0  83
    ${value_end}=  GET SUBSTRING  ${value_bin}  85  ${length_bin}
    ${value_bin}=  CATENATE  SEPARATOR=  ${value_begin}  ${fota_bearer_bin}  ${value_end}
    ${value_hex}=  CONVERT TO HEX  ${value_bin}  base=2  length=${length_hex}
    DIAG WRITE DID  2000  ${value_hex}
    ${new_bearer}=  GET FOTA BEARER
    SHOULD BE EQUAL  ${bearer}  ${new_bearer}
    HARD RESET

START FOTA APPLICATION
    [Documentation]  Start the FOTA application
    ...  | *Keyword*              |
    ...  | START FOTA APPLICATION |
    Run Keyword And Ignore Error    REMOVE APPIUM DRIVER
    CREATE APPIUM DRIVER    VehicleSettings
    TAP_ON_ELEMENT_USING_XPATH    ${update_menu}    10

ADB DIAG READ BINARY DID
    [Documentation]  Return binary value of 0x2000 SYS_INFO.
    ...  | *Keyword*                      | DID_ID |
    ...  | ADB DIAG READ BINARY DID       | did_id   |
    [Arguments]  ${did_id}
    ${value_hex}=  DIAG READ DID  ${did_id}
    ${value_hex}=  REMOVE STRING  ${value_hex}  '
    ${length_hex}=  GET LENGTH  ${value_hex}
    ${length_bin}=  EVALUATE  ${length_hex}*4
    ${value_bin}=  CONVERT TO BINARY  ${value_hex}  base=16  length=${length_bin}
    RETURN FROM KEYWORD  ${value_bin}

WAIT BOOT
    [Documentation]  Wait end of IVI boot sequence. Max waiting time can be configured using the `timeout` argument.
    ...  | *Keyword* | *Timeout* |
    ...  | WAIT BOOT |           |
    ...  | WAIT BOOT | 60s       |
    ...  | WAIT BOOT | 5mins     |
    [Arguments]  ${timeout}=2min
    WAIT UNTIL KEYWORD SUCCEEDS  ${timeout}  10s  IS BOOTED
    GET VERSION
    IF  '${fota_bearer}'=='${EMPTY}'
       ${fota_bearer}=  SET VARIABLE  ${DEFAULT_FOTA_BEARER}
    END
    ${bearer}=  GET FOTA BEARER
    IF  '${bearer}'!='${fota_bearer}'
       SET FOTA BEARER  ${fota_bearer}
    END
    SKIP WIZARD
    WAIT FILESYSTEM READY
    WAIT UNTIL KEYWORD SUCCEEDS  5min  30s  GPS CHECK
    WAIT UNTIL KEYWORD SUCCEEDS  5min  30s  WIFI CHECK
    LOG  IVI powered on  console=True

WAIT UPDATE STATE
    [Documentation]  Wait desired update `state`. If the desired state is not reached after `timeout`, the keyword will fail.
    ...  | *Keyword*         | *State* | *Timeout* |
    ...  | WAIT UPDATE STATE | idle    |           |
    ...  | WAIT UPDATE STATE | idle    | 30min     |
    [Arguments]  ${state}  ${timeout}=2min
    WAIT UNTIL KEYWORD SUCCEEDS  ${timeout}  3s  IS UPDATE STATE  ${state}

WIFI CHECK
    [Documentation]  Enable WIFI and connect to desired SSID if required according to FOTA bearer.
    ...  | *Keyword*   |
    ...  | WIFI CHECK  |
    ${bearer}=  GET FOTA BEARER
    ${wifi_required}=  RUN KEYWORD AND RETURN STATUS  SHOULD CONTAIN  ${bearer}  WIFI
    RETURN FROM KEYWORD IF  ${wifi_required}==False
    ${conn_status}=  RUN KEYWORD AND RETURN STATUS  IS WIFI CONNECTED
    RETURN FROM KEYWORD IF  ${conn_status}==True
    CONNECT TO WIFI

IS WIFI ON
    [Documentation]  get WIFI connection status (enabled/disabled).
    ...  | *Keyword*   |
    ...  | IS WIFI ON  |
    CHECKSET WIFI STATUS    ${ivi_adb_id}     on
    
IS WIFI CONNECTED
    [Documentation]  get WIFI connection state (Connected/Disconneted).
    ...  | *Keyword*   |
    ...  | IS WIFI CONNECTED  |
    IS WIFI ON
    ${status}=    GET WIFI NETWORK STATUS
    SHOULD CONTAIN  ${status}    CONNECTED
   
    
ENABLE WIFI
    [Documentation]  switch on WIFI
    ...  | *Keyword*   |
    ...  | ENABLE WIFI |
    ${state}=  RUN KEYWORD AND RETURN STATUS  IS WIFI ON
    RETURN FROM KEYWORD IF  ${state}==True
    CHECKSET WIFI STATUS    ${ivi_adb_id}     on

WAIT FILESYSTEM READY
    [Documentation]  check if file system is ready for testing. Call adb reboot if not
    ...  | *Keyword*              |
    ...  | WAIT FILESYSTEM READY |
    FOR  ${i}  IN RANGE  3
        SLEEP  10s
        ${ready}=  RUN KEYWORD AND RETURN STATUS  IS PATH EXISTS  ${DATA_DIRECTORY}
        RETURN FROM KEYWORD IF  ${ready}==True
    END
    LOG  File system not ready after boot  WARN
    DO REBOOT AND CHECK BOOT UI

GET UPDATE BUTTON
    [Documentation]  Return the available button name. If none is available, return empty string
    ...  | *Keyword*         |
    ...  | GET UPDATE BUTTON |
    @{buttons}=  CREATE LIST  ${VehicleSettings_Check_Update}  ${VehicleSettings_Update_Ongoing}
    FOR  ${button}  IN  @{buttons}
        APPIUM_WAIT_FOR_XPATH    //*[@text='${button}']   30
        ${enabled}=  APPIUM_GET_ATTRIBUTE_BY_XPATH    //*[@text='${button}']    enabled
        IF  '${enabled}'.lower()=='true'
           RETURN FROM KEYWORD  ${button}
        END
    END
    RETURN FROM KEYWORD  ${EMPTY}

WAIT FOR DOWNLOAD STATE
    [Documentation]  Wait for download consent step
    [Arguments]  ${state}
    FOR    ${index}    IN RANGE    30
        ${update_state}=  GET UPDATE STATE
        Exit For Loop If  "${update_state}" == "${state}"
        Run Keyword And Ignore Error    APPIUM_WAIT_FOR_XPATH    //*[@text='${Vehicle_no_update}']   30
        TAP_ON_ELEMENT_USING_ID    ${VehicleSettings_back_button}    10
        TAP_ON_ELEMENT_USING_XPATH    ${check_for_update_button}    10
        Sleep   10
    END

GET IVI MY FEATURE ID
    [Documentation]    Get ivi_my_feature_id from the ivi_build_id
    ${ivi_build_id} =    GET IVI BUILD ID
    @{build_id_list} =    Split String    ${ivi_build_id}    .
    ${build_series} =    Get From List    ${build_id_list}    1
    ${ivi_my_feature_id} =  Set Variable If
    ...  "${build_series}"=="08"  MyF1
    ...  "${build_series}"=="11"  MyF2
    ...  "${build_series}">="12"  MyF3
    ...  Final else!
    [Return]    ${ivi_my_feature_id}

GET PLATFORM VERSION
    [Documentation]    Get android_version from the hlk Get ivi_my_feature_id
    ${ivi_my_feature_id} =    GET IVI MY FEATURE ID
    ${platform_version} =  Set Variable  12
    ${platform_version} =  Set Variable If
    ...  "${ivi_my_feature_id}"=="MyF1"  10
    ...  "${ivi_my_feature_id}"=="MyF2"  10
    ...  "${ivi_my_feature_id}"=="MyF3"  12
    ...  Final else!
    [Return]    ${platform_version}

CHECK HVAC CLIM ELEMENT PRESENT
    [Arguments]    ${did_byte_position}    ${did_bit_position}    ${did_value}    ${signal_name}    ${signal_value}    ${clim_image}
    [Documentation]    Check the HVAC Element present on IVI based on input provided.
    CHECKSET FILE PRESENT    bench    ${clim_image}
    ${read_payload} =    DOIP READ CONFIG    ${ivi_platform_type}    HMI    ${session}
    DOIP UPDATE CONFIG    ${ivi_platform_type}    2004    ${read_payload}    ${did_byte_position}    ${did_bit_position}    ${did_value}    ${session}
    DOIP HARD RESET ECU AND WAIT BOOT    ${ivi_platform_type}    ${session}
    SEND CAN MESSAGE    ${bus}    ${signal_name}     ${signal_value}
    DO WAIT    5000
    CHECK IMAGE DISPLAYED ON SCREEN    ${target_id}    ${clim_image}
    SET DELETE FILE    bench    ${clim_image}

COMPARE IVI & VNEXT TIME
    [Arguments]    ${max_seconds_interval}=${120}
    [Documentation]    Compare the IVI and vNext time
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    COMPARE IVI & VNEXT TIME
    ${vnext_time_stamp} =    RECORD VNEXT DATE & TIME    t0
    ${ivi_date_and_time} =    CHECK IVI DATE AND TIME
    ${timedelta} =    Evaluate    datetime.datetime.fromisoformat($ivi_date_and_time) - datetime.datetime.fromisoformat($vnext_time_stamp)    modules=datetime
    ${verdict} =    Evaluate    $timedelta.total_seconds() <= int($max_seconds_interval)
    Should Be True    ${verdict}    IVI & vNext have different timestamps

SET FOTA PERIODIC CHECK
    [Documentation]  Update the period of fota periodic check
    ...  | *Keyword*                      | *period*   |
    ...  | SET FOTA PERIODIC CHECK        |    1h      |
    [Arguments]    ${period}
    ${actual_period}=  GET FOTA PERIODIC CHECK
    ${actual_period}=  CONVERT TIME  ${actual_period}
    ${period_second}=  CONVERT TIME  ${period}
    RETURN FROM KEYWORD IF    '${actual_period}'=='${period_second}'
    ${extract_period}=  RUN KEYWORD IF  0 < ${period_second} < 86400  EVALUATE  240+${period_second}/3600
    ...   ELSE    EVALUATE    ${period_second}/86400
    ${period_hex}=  CONVERT TO HEX  ${extract_period}
    ${period_bin}=  CONVERT TO BINARY  ${period_hex}  base=16  length=8
    ${value_bin}=  ivi.ADB DIAG READ BINARY DID  2000
    ${length_bin}=  GET LENGTH  ${value_bin}
    ${length_hex}=  EVALUATE  ${length_bin}/4
    ${value_begin}=  GET SUBSTRING  ${value_bin}  0  8
    ${value_end}=  GET SUBSTRING  ${value_bin}  16  ${length_bin}
    ${value_bin}=  CATENATE  SEPARATOR=  ${value_begin}  ${period_bin}  ${value_end}
    ${value_hex}=  CONVERT TO HEX  ${value_bin}  base=2  length=${length_hex}
    DIAG WRITE DID  2000  ${value_hex}
    ${new_period}=  GET FOTA PERIODIC CHECK
    ${new_period}=  CONVERT TIME  ${new_period}
    SHOULD BE EQUAL    ${period_second}    ${new_period}
    HARD RESET

GET FOTA PERIODIC CHECK
    [Documentation]  Return the current binary value of fota periodic check period.
    ...  | *Result*   | *Keyword* |
    ...  | ${period}= | GET FOTA PERIODIC CHECK |
    ${value_bin}=  ADB DIAG READ BINARY DID  2000
    ${period_bin}=  GET SUBSTRING    ${value_bin}  8  16
    ${period_bin}=  CONVERT TO BINARY    ${period_bin}  base=2  length=8
    ${period_int}=  CONVERT TO INTEGER    ${period_bin}  base=2
    ${period_seconds}=  RUN KEYWORD IF    ${period_int} > 240  EVALUATE  (${period_int}-240)*3600
    ...    ELSE    EVALUATE    ${period_int}*86400
    ${period}=  CONVERT TIME    ${period_seconds}  verbose
    RETURN FROM KEYWORD    ${period}

CHECK IVI TYPE
    [Arguments]    ${expected_type}    ${ivi_serial_number}
    [Documentation]  Check the IVI type as FULL_NAV or CORE_DA
    Run Keyword If    "${expected_type}" == "FULL_NAV"    Should Contain    ${ivi_serial_number}    FULL
    ...    ELSE If    "${expected_type}" == "CORE_DA"    Should Contain    ${ivi_serial_number}    CORE

CHECKSET COUNTRY
    [Arguments]    ${country}
    [Documentation]    Check and set the countrycode to: ${country}
    Log To Console    Check and set the countrycode to: ${country}
    ${stdout}    ${stderr} =    GET PROP    persist.sys.countrycode
    Should Be Empty    ${stderr}
    ${status} =    Evaluate    "${country}" in """${stdout}"""
    Return From Keyword If    "${status}" == "${True}"
    CHECKSET GPS    ${ivi_adb_id}    off
    SET PROP    persist.sys.countrycode     ${country}
    ${stdout}    ${stderr} =    GET PROP    persist.sys.countrycode
    Should Be Empty    ${stderr}
    Should Contain    ${stdout}    ${country}
    CHECKSET GPS    ${ivi_adb_id}    on

CHECK IVI MQTT CONNECTION STATUS
    [Arguments]    ${status}=success    ${mqtt_retries}=16    ${sleep_between_retries}=5
    [Documentation]    on ivi platform, check if ivi is connected to MQTT
    ...    currently, the command used is adb -s ${ivi_adb_id} shell netstat -n | grep -E '^tcp .*:8883[ ]+ESTABLISHED$'
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK IVI MQTT CONNECTION STATUS start
    FOR    ${i}    IN RANGE    ${mqtt_retries}
        ${verdict} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell netstat -n | grep -E '^tcp .*:8883[ ]+ESTABLISHED$'
        Run Keyword if    "${status}" == "success"    EXIT FOR LOOP IF  "${verdict}" != ""
        Run Keyword if    "${status}" == "disabled"   EXIT FOR LOOP IF  "${verdict}" == ""
        Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK IVI MQTT CONNECTION STATUS retrying in 5 seconds
        Sleep    ${sleep_between_retries}
    END
    ${total_retries} =    Evaluate    ${mqtt_retries} - 1
    Run Keyword If    "${i}"=="${total_retries}"    Fail    CHECK IVI MQTT CONNECTION STATUS failed after many tries

GET IVI TIME
    [Documentation]    To get time of ivi in HH:MM:SS format
    ${dict_months}    create dictionary    Jan=1    Feb=2    Mar=3    Apr=4    May=5    Jun=6    Jul=7    Aug=8    Sep=9    Oct=10    Nov=11    Dec=12
    # get IVI date and time
    ${raw_output} =    SEND ADB COMMAND    date
    ${output} =    Convert To String    ${raw_output}
    # extract month
    ${month_lit} =    Get Regexp Matches    ${output}    [A-Za-z]{3}
    ${month_lit} =    Set Variable    ${month_lit}[1]
    # extract date and time from raw adb command output
    ${res} =    Get Regexp Matches    ${output}    [0-9]{1,2} [0-9]+:[0-9]+:[0-9]+ [A-Z]+ [0-9]{4}
    # process the result to make it usable and iterable
    ${res} =    Convert to String    ${res}
    ${res} =    Remove String    ${res}    [    ]    '
    ${res} =    Split String    ${res}
    # replace month like Feb, Mar, Apr with 2, 3 or 4
    ${month_num} =    Set Variable    ${dict_months.${month_lit}}
    # create the date_time string with only relevant information from raw_output
    ${date_time} =    Set Variable    ${month_num} ${res}[0] ${res}[1] ${res}[3]
    # convert to Date object    
    ${date_time} =    DateTime.Convert Date    ${date_time}    date_format=%m %d %H:%M:%S %Y 
    [Return]    ${date_time}

CHECKSET USER ACCOUNT
    [Arguments]    ${user_name}    ${status}
    [Documentation]  Check user account ${user_name} is in expected state: ${status} and set if not in the expected ${status}
    ${current_user_name}    ${current_user_id} =    ADB_AM_GET_CURRENT_USER_NAME
    ${current_user_name} =    Set Variable If    "${current_user_name}"=="Driver" or "${current_user_name}"=="Conducteur"    Driver    ${current_user_name}
    Return From Keyword If    "${current_user_name}"=="${user_name}" and "${status}"=="active"
    ${all_users} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pm list users
    ${user_present}=    LIST IN STRING    ${user_name}    ${all_users}
    IF    "${status}"=="active"
        IF    "${user_present}"=="False" and "${user_name}"!="Driver" and "${user_name}"!="Conducteur"
            CREATE NEW USER    ${user_name}    ${ivi_adb_id}
        END
        ADB_AM_SWITCH_USER    ${user_name}
    ELSE
         IF    "${user_name}"=="Driver" or "${user_name}"=="Conducteur"
              IF    "${current_user_name}"=="Driver" or "Conducteur"
              ${all_users} =    OperatingSystem.Run    adb -s ${ivi_adb_id} shell pm list users
              ${all_users} =    Split String    ${all_users}    separator=\n
              ${all_users} =    Set Variable    ${all_users}[2:]
              Log List    ${all_users}
              FOR    ${user}    IN    @{all_users}
                  ${user} =    Strip String    ${user}    characters=running
                  ${user} =    Strip String    ${user}
                  ${user} =    Split String    ${user}    :
                  Log List    ${user}
                  ${user} =    Split String    ${user}[1] 
                  ${user} =    Evaluate    "".join(${user})
                  IF    "${user}"=="Conducteur" or "${user}"=="Driver"  
                      CONTINUE 
                  ELSE IF    "${user}"!="Conducteur" or "${user}"!="Driver" 
                      ADB_AM_SWITCH_USER    ${user}
                      BREAK
                  ELSE
                      CREATE NEW USER    New_user    ${ivi_adb_id}
                      ADB_AM_SWITCH_USER    New_user                     
                  END
              END             
              END                 
        ELSE
            ${driver_present} =    LIST IN STRING    Driver    ${all_users}
            ${swtich_to_user} =    Set Variable If    "${driver_present}"=="True"    Driver    Conducteur
            ADB_AM_SWITCH_USER    ${swtich_to_user}
        END
    END
    ${current_user_name}    ${current_user_id} =    ADB_AM_GET_CURRENT_USER_NAME
    ${current_user_name} =    Set Variable If    "${current_user_name}"=="Driver" or "${current_user_name}"=="Conducteur"    Driver    ${current_user_name}
    ${user_name} =    Set Variable If    "${user_name}"=="Driver" or "${user_name}"=="Conducteur"    Driver    ${user_name}
    IF    "${status}"=="active"
        Should Be Equal    ${current_user_name}    ${user_name}
    ELSE
        Should Not Be Equal    ${current_user_name}    ${user_name}
    END
