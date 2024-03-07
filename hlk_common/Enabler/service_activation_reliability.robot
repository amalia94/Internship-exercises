#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     SA_reliability - keywords library

Library           Collections
Library           String
Library           DateTime
Library           Process

Variables         ../unsorted/tech_prod_ids.yaml
*** Variables ***
&{states}    STON=00:00:30    STON_STDRX=00:00:30     STON_STOFFDATA=00:00:45    OFF_STATE_ECS_BOOT=00:02:00   OFF_STATE_COLD_BOOT=00:02:00    STDRX_STON_ECS=00:00:45    STOFFDATA_STON_ECS=00:00:30
@{service_operation}    reactivate    deactivate    activate
${OFF_STATE_TO_MMI_OFF_STATE_transition_a}    OFF_STATE_TO_MMI_OFF_STATE_transition_a
${MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c}    MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c
${CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g}    CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g
${MMI_ON_TO_MMI_OFF_STATE_transition_d}    MMI_ON_TO_MMI_OFF_STATE_transition_d
${MMI_OFF_STATE_TO_OFF_STATE_transition_b}    MMI_OFF_STATE_TO_OFF_STATE_transition_b
${MMI_ON_Full_TO_MMI_ON_Partial_transition_q}    MMI_ON_Full_TO_MMI_ON_Partial_transition_q
${MMI_ON_Partial_TO_MMI_ON_Full_transition_p}    MMI_ON_Partial_TO_MMI_ON_Full_transition_p
${gtt_file}    gtt_reference.yaml
${msrs_file}    C1A-HS.json
${SMS_str}    Received OnSMSReceived event
@{in_progress_list}    ReactivationInProgress    ActivationInProgress    DeactivationInProgress
@{status_list}        @{in_progress_list}    ${EMPTY}
@{status_list_2}    ActivationFailed    Activated   Deactivated   DeactivationFailed    ReacectivationFailed
@{failed_list}    ActivationFailed     DeactivationFailed    ReacectivationFailed
@{expected_list}    Activated    Deactivated
${final_can_sequence}    Stop_vehicle_sequence_customer_needed
${ivc_log_path}    /mnt/mmc/logs/logs.txt

*** Keywords ***
SETUP_SUBTESTCASE
    [Documentation]    == High Level Description: ==
    ...    Seta a random tpid and vnext variable for it and do the setup for random transition.
    ${tpid_name}    ${tpid_code} =    SELECT RANDOM TPID    ${service_list}
    Set Test Variable    ${tpid_code}
    Set Test Variable    ${tpid_name}
    SET VNEXT VARS FOR TPID    ${tpid_name}
    Run Keyword And Ignore Error    RETRY MECHANISM FOR READING SA STATUS    ${tpid_name}    Activated    True
    ${last_status_verdict} =     Run keyword and return status    Should Contain    ${status_list}    ${current_status}
    Return from keyword if    ${last_status_verdict} == ${TRUE}   Service status blocked ${current_status}    ${FALSE}    ${tpid_name}    ${tpid_code}
    SELECT STATE AND RUN TRANSITION    yes    ${tansition_list}
    [Return]    ${current_status}    ${TRUE}    ${tpid_name}    ${tpid_code}

TEARDOWN_SUBTESTCASE
    [Documentation]    == High Level Description: ==
    ...    Put the device in ston and check SMS received/send and status of the service is activcated/deactivated.
    ...    If in progress press check for updates.
    STON
    CLOSE SSH SESSION
    SET IVI IP TABLES FOR IVC SSH CONNECTION
    CHECK IVC MQTT CONNECTION STATUS
    CHECKSET IVI INVENTORY
    Run Keyword And Ignore Error    RETRY MECHANISM FOR READING SA STATUS    ${tpid_name}    Activated    True
    ${last_status_verdict} =     Run keyword and return status    Should Contain    ${failed_list}    ${current_status}
    Run keyword if     ${last_status_verdict} == ${FALSE}     CHECK SMS RECEIVED
    ...    ELSE     SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/    ${loop_folder}
#    check service status on ivc (p2)
    ${return} =    Run Keyword And Return Status    List Should Contain Value    ${in_progress_list}    ${current_status}
    Run Keyword If    ${return} == ${TRUE}    Run Keywords     CREATE APPIUM DRIVER
    ...    AND    CHECK FOR UPDATE    DeactivationInProgress
    ...    AND    SAVE SCREENSHOT    ${loop_folder}/    screenshot_${TEST NAME}.png
    ...    AND    REMOVE APPIUM DRIVER
    ...    AND    Run Keyword And Ignore Error    RETRY MECHANISM FOR READING SA STATUS    ${tpid_name}    Activated    True
    List Should Contain Value    ${expected_list}    ${current_status}

SELECT RANDOM TPID
    [Arguments]    ${service_list}
    [Documentation]    == High Level Description: ==
    ...    Get a random tp name
    ...    == Expected Results: ==
    ...    Tpid name    Tpid code
   ${tech_prod_names} =     Get Dictionary Keys    ${tech_prods}
   ${service_list} =    Run Keyword If    "${service_list}" == "${EMPTY}"    Set Variable    ${EMPTY}
    ...    ELSE    Split String    ${service_list}    ,
   ${tpid_name} =     Run Keyword If    "${service_list}" == "${EMPTY}"    Evaluate    random.choice(${tech_prod_names})
   ...    ELSE    Set variable    ${service_list}
   ${tpid_name} =    Set variable if     "${service_list}"!= "${EMPTY}"    ${tpid_name}[0]    ${tpid_name}
   ${tpid_code} =    Set Variable    ${tech_prods}[${tpidname}]
   [Return]    ${tpid_name}    ${tpid_code}

SELECT RANDOM OPERATION
    [Arguments]    ${last_status}
    [Documentation]    == High Level Description: ==
    ...    Get a random fota operation based on last status.
    ...    == Expected Results: ==
    ...    Random fota operation.
    ${service_operation} =    Run keyword if    "${current_status}" == "Activated"    Get Slice From List     ${service_operation}    end=2
    ...    ELSE IF    "${current_status}" == "DeactivationFailed"    Get From List    ${service_operation}    1
    ...    ELSE    Get From List    ${service_operation}    2
    ${random_service_operation} =    Run keyword if    "${current_status}" == "Activated"    Evaluate    random.choice(${service_operation})
    ...    ELSE    Set variable    ${service_operation}
    ${request} =     Run Keyword if    "${random_service_operation}" == "activate"    Set variable    ${activate_request}
    ...    ELSE IF    "${random_service_operation}" == "deactivate"    Set variable    ${deactivate_request}
    ...    ELSE IF    "${random_service_operation}" == "reactivate"    Set variable    ${reactivate_request}
    [Return]    ${request}

SELECT STATE AND RUN TRANSITION
    [Arguments]    ${setup}=no    ${tansition_list}=${EMPTY}    ${request}=None
    [Documentation]    == High Level Description: ==
    ...   Based on random fota operation run transition and random trigger fota operation.
    ${states_list} =     Get Dictionary Keys    ${states}
    ${tansition_list} =    Run Keyword If    "${tansition_list}" == "${EMPTY}"    Set Variable    ${EMPTY}
    ...    ELSE    Split String    ${tansition_list}    ,
    ${random_state} =    Run Keyword If     "${setup}" == "yes" and "${tansition_list}" == "${EMPTY}"     Evaluate    random.choice(${states_list})
    ...   ELSE IF    "${setup}" == "yes" and "${tansition_list}" != "${EMPTY}"    Evaluate    random.choice(${tansition_list})
    ...   ELSE    Set variable    ${random_state}
    ${time_for_state}    ${random_trigger_fota} =     Run Keyword if    "${setup}" == "no"    SET RANDOM TIME FOR FOTA ITERATION   ${random_state}
    ...    ELSE    Set Variable    setup no time needed    setup no time needed
    ${args} =    Create List     ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}
    Run Keyword if    "${setup}" == "no"    DELETE DLT LOGS
    Run keyword if    "${setup}" == "yes"     Set test variable    ${random_state}
    Run keyword if    "${random_state}" == "STON"    STON    @{args}
    Run keyword if    "${random_state}" == "STOFF"    STOFF    @{args}
    Run keyword if    "${random_state}" == "STON_STDRX"    STON_STDRX    @{args}
    Run keyword if    "${random_state}" == "STON_STOFFDATA"    STON_STOFFDATA    @{args}
    Run keyword if    "${random_state}" == "OFF_STATE_ECS_BOOT"    OFF_STATE_ECS_BOOT    @{args}
    Run keyword if    "${random_state}" == "OFF_STATE_COLD_BOOT"    OFF_STATE_COLD_BOOT    @{args}
    Run keyword if    "${random_state}" == "STDRX_STON_ECS"   STDRX_STON_ECS    @{args}
    Run keyword if    "${random_state}" == "STOFFDATA_STON_ECS"   STOFFDATA_STON_ECS    @{args}

SET VNEXT VARS FOR TPID
    [Arguments]    ${tpid}    ${ivc_check}=None
    [Documentation]    == High Level Description: ==
    ...    Set desired variables based on random tpid
    set test variable    @{check_activated}    ${tpid}    Activated    300    False
    set test variable    @{check_deactivated}    ${tpid}    Deactivated    300    False
    set test variable    @{check_activated_ivc}    Activation    60    ${ivc_check}
    set test variable    @{check_deactivated_ivc}    Deactivation    60    ${ivc_check}
    set test variable    @{activate_request}    Activate    ${tpid}
    set test variable    @{deactivate_request}    Deactivate    ${tpid}
    set test variable    @{reactivate_request}    Reactivate    ${tpid}
    set test variable    @{activation_in_progress}    ${tpid}    ActivationInProgress
    set test variable    @{deactivation_in_progress}    ${tpid}    DeactivationInProgress
    set test variable    @{vnext_response}    service_activation    Success

STON
    [Arguments]     ${time_for_state}=none    ${random_trigger_fota}=none    ${request}=none    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Put device in ston+
    Run keyword if    "${setup}" == "no"    Run Keywords    CONFIGURE VEHICLE STUB PROFILE    keep_ivc_and_ivi_on
    ...    AND    Run keyword if    "${request}" != "none"    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}
    ...    AND    CHECK IVI BOOT COMPLETED    booted    120
    ...    AND    SET IVI IP TABLES FOR IVC SSH CONNECTION
    ...    AND    CHECK IVC BOOT COMPLETED

STOFF
    [Arguments]     ${time_for_state}    ${random_trigger_fota}    ${request}   ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Put device in stoff
    Run keyword if    "${setup}" == "no"    Run Keywords    SEND CAN FRAME    ${final_can_sequence}
    ...    AND    STOP CAN WRITING
    ...    AND    Sleep    120

STON_STDRX
    [Arguments]     ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Do transition from ston to stdrx.
    Run Keyword if    "${setup}" == "yes"    CHECKSET IVC STDRX CONFIGURATION
    Run Keyword If    "${setup}" == "no"     Run Keywords    DO BCM STANDBY    0
    ...    AND    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}


STON_STOFFDATA
    [Arguments]     ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Do transition from ston to stoff data.
    Run Keyword if    "${setup}" == "yes"   CHECKSET IVC STDRX CONFIGURATION
    Run Keyword If    "${setup}" == "no"    Run Keywords    DO BCM STANDBY    0
    ...    AND    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}

OFF_STATE_ECS_BOOT
    [Arguments]     ${time_for_state}   ${random_trigger_fota}    ${request}    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Do transition from off state to ecs boot
    Run keyword if    "${setup}" == "no"    Run Keywords    SEND CAN FRAME    ${MMI_ON_TO_MMI_OFF_STATE_transition_d}
    ...    AND    SEND CAN FRAME    ${MMI_OFF_STATE_TO_OFF_STATE_transition_b}
    ...    AND    Sleep    60
    ...    AND    SEND CAN FRAME    ${OFF_STATE_TO_MMI_OFF_STATE_transition_a}
    ...    AND    SEND CAN FRAME    ${MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c}
    ...    AND    SEND CAN FRAME    ${CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g}
    ...    AND    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}

OFF_STATE_COLD_BOOT
    [Arguments]     ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Do transition from offstate to cold boot.
    Run keyword if    "${setup}" == "no"    Run Keywords    STOFF    ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}
    ...    AND    DO POWER OFF BATTERY
    ...    AND    Sleep    2
    ...    AND    DO POWER ON BATTERY
    ...    AND    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}

STDRX_STON_ECS
    [Arguments]     ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Do transition from stdrx to stonecs.
    Run Keyword if    "${setup}" == "yes"    CHECKSET IVC STDRX CONFIGURATION
    Run keyword if    "${setup}" == "no"     Run Keywords    DO BCM STANDBY    180
    ...    AND    SEND CAN FRAME    ${OFF_STATE_TO_MMI_OFF_STATE_transition_a}
    ...    AND    SEND CAN FRAME    ${MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c}
    ...    AND    SEND CAN FRAME    ${CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g}
    ...    AND    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}

STOFFDATA_STON_ECS
    [Arguments]     ${time_for_state}    ${random_trigger_fota}    ${request}    ${setup}=no
    [Documentation]    == High Level Description: ==
    ...    Do transition from stoffdata to ston ecs boot.
    Run Keyword if    "${setup}" == "yes"    CHECKSET IVC STDRX CONFIGURATION
    Run keyword if    "${setup}" == "no"     Run Keywords    DO BCM STANDBY    180
    ...    AND    SEND CAN FRAME    ${OFF_STATE_TO_MMI_OFF_STATE_transition_a}
    ...    AND    SEND CAN FRAME    ${MMI_OFF_STATE_TO_CHECK_WELCOME_transition_c}
    ...    AND    SEND CAN FRAME    ${CHECK_WELCOME_TO_MMI_ON_Full_User_Hmi_transition_g}
    ...    AND    RUN FOTA OPERATION    ${time_for_state}    ${random_trigger_fota}    ${request}

SET RANDOM TIME FOR FOTA ITERATION
    [Arguments]    ${random_state}
    [Documentation]    == High Level Description: ==
    ...    Set randon time for fota operation
    ${time_for_state} =    Set Variable    ${states}[${random_state}]
    ${time_for_state_float} =    DateTime.convert time    ${time_for_state}
    ${time_for_state_int} =    Convert To Integer    ${time_for_state_float}
    ${random_trigger_fota} =    Evaluate    random.randint(0, ${time_for_state_int})
    ${diference_add} =  Set variable     ${random_trigger_fota}
    Set test variable     ${diference_add}
    [Return]    ${time_for_state}    ${random_trigger_fota}

RUN FOTA OPERATION
    [Arguments]    ${time_for_state}    ${random_trigger_fota}    ${request}
    [Documentation]    == High Level Description: ==
    ...    Run fota operation at random time in predefined timestamp.
    ${already_executed} =   Set Variable    ${FALSE}
    FOR    ${infinite_loops}    IN RANGE    ${1}    ${infinite_loops}
        ${start_time} =    Get Time

        ${time_for_state_float} =    DateTime.convert time    ${time_for_state}
        ${time_for_state_int} =    Convert To Integer    ${time_for_state_float}

        Run Keyword If    ${time_for_state_int} == ${random_trigger_fota} or (${already_executed} == ${FALSE} and ${time_for_state_int} < ${8})
        ...    Run Keywords    SEND VNEXT REQUEST SERVICE ACTIVATION    @{request}
        ...    AND    CHECK VNEXT REQUEST RESPONSE    @{vnext_response}
        ${already_executed} =    Set Variable If    ${time_for_state_int} == ${random_trigger_fota}    ${TRUE}    ${already_executed}

        Sleep   1
        ${end_time} =    Get Time
        ${iteration_time} =    DateTime.Subtract Date From Date    ${end_time}    ${start_time}    result_format=timedelta
        ${time_for_state} =    DateTime.Subtract Time From Time    ${time_for_state}    ${iteration_time}
        Exit For Loop If    ${time_for_state} <= 0
    END

SELECT RANDOM TRANSITION
    [Documentation]    == High Level Description: ==
    ...    Select random transition and time.
    ${states_list} =     Get Dictionary Keys    ${states}
    ${random_state} =    Run Keyword If     "${setup}" == "yes" and "${tansition_list}" == "${EMPTY}"     Evaluate    random.choice(${states_list})
    ...   ELSE IF    "${setup}" == "yes" and "${tansition_list}" != "${EMPTY}"    Evaluate    random.choice(${tansition_list})
    ...   ELSE    Set variable    ${random_state}
    ${time_for_state}    ${random_trigger_fota} =     Run Keyword if    "${setup}" == "no"    SET RANDOM TIME FOR FOTA ITERATION   ${random_state}

CHECK SMS RECEIVED
    [Arguments]    ${TC_folder}=${EMPTY}    ${request_type}="None"
    [Documentation]    == High Level Description: ==
    ...    Check if vnext sms is sent and if the ivc recieved the sms.
    ${verdict}    ${comment} =     WAIT SMS
    ${status} =    Run Keyword And Return Status    should be true    ${verdict}
    Run Keyword If    "${status}" == "False"    Log    WAIT SMS verdict is ${verdict} with comment "${comment}"    WARN
    SET DLT TRIGGER     ${SMS_str}
    START ANALYZING DLT DATA
    ${loop_folder} =    Set variable    debug_logs/${current_tc_name}/loop_${var}/${request_type}
    Create Directory    ${loop_folder}
    SYSTEM GET FILE FROM DEVICE    /mnt/mmc/logs/    ${loop_folder}
    LOAD DLT DIRECTORY    ${loop_folder}/logs

    ${v}    ${v_error} =   rfw_libraries.logmon.DltMonitor.WAIT FOR DLT TRIGGER    ${SMS_str}
    ${status} =    Run Keyword And Return Status        Should Be True    ${v}

    ${verdict}        ${comment} =    STOP ANALYZING DLT DATA
    DELETE DLT LOGS
    Should be True    ${verdict}      ${comment}

    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run Keyword And Continue On Failure    Should Be True    ${v}
    ...    ELSE    Should Be True    ${v}

WAIT SMS
    [Documentation]    == High Level Description: ==
    ...    Wait for the sms  to be recieved on vnext.
    ...    == Expected Results: ==
    ...    Bool, str
    ${check_timeout} =    Set variable     00:05:00
    FOR    ${infinite_loops}   IN RANGE    ${1}    ${infinite_loops}
        ${start_time} =    Get Time

        ${sent_date}    ${tstart} =    DO GET LAST SMS    OMA-DMSms    no
        ${diference_date} =    robot.libraries.DateTime.Subtract Date From Date    ${tstart}    ${sent_date}    exclude_millis=yes
        ${diference_date} =    Evaluate    ${diference_date}-${diference_add}
        ${verdict}    ${comment}=    Run Keyword If   ${diference_date} < ${480.0}    Set Variable    True    Time diference is smaller than 5min
        ...    ELSE   Set Variable    False    Time diference is bigger than 5min.
        Exit For Loop If    "${verdict}" == "${TRUE}"
        Sleep   5

        ${end_time} =    Get Time
        ${iteration_time} =    DateTime.Subtract Date From Date    ${end_time}    ${start_time}    result_format=timedelta
        ${check_timeout} =     DateTime.Subtract Time From Time    ${check_timeout}    ${iteration_time}
        Exit For Loop If    ${check_timeout} < 0
    END
    [Return]     ${verdict}    ${comment}
