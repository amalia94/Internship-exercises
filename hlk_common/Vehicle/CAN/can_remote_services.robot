#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           rfw_services.canakin.CanakinLib    @{canakin_config_data}
Resource          ${CURDIR}/../../Tools/bench_config.robot
Library           rfw_libraries.toolbox.Artifactory
Library           rfw_libraries.toolbox.CometLib.CometLib
Library           rfw_libraries.toolbox.SimulateTriggerLib    ${canakin_config_data}    ${cirrus_config_data}
Library           String
Variables         ${CURDIR}/../../unsorted/CAN_frames.yaml
Resource          ${CURDIR}/../../power_supply.robot

*** Variables ***
@{canakin_config_data}    MSRS    GTT    UDS_DID    UDS_ROUTINE
@{cirrus_config_data}    APIM    EVENT_HUB    MQTT_HEADER    MQTT_DATA
${console_logs}    yes
${bus}            can0
${bus_m}          can1
${door_status_frame}    BCM_A110
${door_status_frame_fd}    BCM_A13SC_FD
${door_open}      2
${door_closed}    1
${hood_closed}    2
${lock}           ${0}
${start}          ${0}
${stop}           ${1}
${all_doors}      ${0}
${driver_door}    ${1}
${tailgate}       ${2}
${na}             ${0}
${style_1}        ${1}
${style_2}        ${2}
${horn_light}     ${0}
${horn_only}      ${1}
${light_only}     ${2}
${remote_request_timeout}    180
&{remote_order_ids}    RLU=${0}    RES=${3}    RHL=${6}    RPC_EV=${7}    BCI=${12}    CHECK_ICARD_PRESENCE=${14}
${block}          0
${unblock}        1
${ready_to_sleep}    2
${can_flag}    False
${consecutive_frames_counter}    ${0}
${offset}    6
${hood_open}      1
${unlock}         ${1}
${check}          ${0}
${style_3}        ${3}
${flasher}        ${3}
${seek_timeout}    15
${ivc_can_only}    False

*** Keywords ***
CONFIGURE CAN FOR BATTERY VOLTAGE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/GEE/Battery/Voltage    ${value}
    should_be_true    ${verdict}    Fail to Set Signal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/GEE/Battery/Voltage
    should_be_true    ${verdict}    Fail to Start Write Canakin: ${comment}

CONFIGURE CAN FOR OUTSIDE LOCK STATE
    [Arguments]    ${status}
    ${lock_state} =    Set Variable If    "${status}" == "False"    0    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Door/OutsideLockedState    ${lock_state}
    should_be_true    ${verdict}    Fail to Set SIgnal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Door/OutsideLockedState
    should_be_true    ${verdict}    Fail to Start Write Canakin Fail to CONFIGURE CAN FOR OUTSIDE LOCK STATE: ${comment}

CONFIGURE CAN FOR DELIVERY MODE
    [Arguments]    ${status}
    ${delivery_mode} =    Set Variable If    "${status}" == "Customer_mode"    0
    ...    "${status}" == "delivery_mode_1"    1    "${status}" == "delivery_mode_2"    2
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/DeliveryMode    ${delivery_mode}
    should_be_true    ${verdict}    Fail to Set Signal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/DeliveryMode
    should_be_true    ${verdict}    Fail to Start Write Canakin Fail to CONFIGURE CAN FOR DELIVERY MODE: ${comment}

CONFIGURE CAN FOR RES STATE
    [Arguments]    ${status}
    ${res_status} =    Set Variable If    "${status}" == "Start"    12    "${status}" == "Stop"    6    "${status}" == "DoubleStart"
    ...    12
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/RES    ${res_status}
    should_be_true    ${verdict}    Fail to Set Signal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/RES
    should_be_true    ${verdict}    Fail to Start Write canakin Fail to CONFIGURE CAN FOR RES STATE: ${comment}

CONFIGURE CAN FOR RES STATUS
    [Arguments]    ${ltdc}    ${phone_error}=NoError    ${failure_type}=NoFailure
    ${res_ltdc} =    Set Variable If    "${ltdc}" == "Start"    599    "${ltdc}" == "Stop"    000    "${ltdc}" == "DoubleStart"
    ...    1199    "${ltdc}" == "GetStatus"    500
    ${res_phone_error} =    Set Variable If    "${phone_error}" == "NoError"    0    "${phone_error}" == "RESNotActivated"    1    "${phone_error}" == "DurationError"
    ...    2    "${phone_error}" == "TCUAuthError"    3
    ${res_fail_type} =    Set Variable If    "${failure_type}" == "NoFailure"    0    "${failure_type}" == "CarNotSecured"    1    "${failure_type}" == "DoorOpen"
    ...    2    "${failure_type}" == "HazardLampActivated"    3    "${failure_type}" == "VehicleMoving"    4    "${failure_type}" == "EngineProblem"
    ...    5    "${failure_type}" == "GearboxEngaged"    6    "${failure_type}" == "OtherState"    7

    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/RES/LeftTimeDuringThisCycle    ${res_ltdc}
    should_be_true    ${verdict}    Fail to Set Signal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/RES/LeftTimeDuringThisCycle
    should_be_true    ${verdict}    Fail to Start Write: ${comment}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/RES/SmartPhoneError    ${res_phone_error}
    should_be_true    ${verdict}    Fail to Set Signal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/RES/SmartPhoneError
    should_be_true    ${verdict}    Fail to Start Write Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/RES/FailureType    ${res_fail_type}
    should_be_true    ${verdict}    Fail to Set Signal Canakin: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/RES/FailureType
    should_be_true    ${verdict}    Fail to Start Write Fail to CONFIGURE CAN FOR RES STATUS: ${comment}

### NEW KEYWORDS ###
SEND VEHICLE WAKEUP COMMAND
    [Arguments]    ${type}=wake_up
    ${type_value} =    Set Variable If    "${type}" == "sleep"    0    "${type}" == "wake_up"    3
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/SleepManagement/WakeUpSleepCommand    ${type_value}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/SleepManagement/WakeUpSleepCommand
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE WAKEUP COMMAND: ${comment}

SEND VEHICLE WAKEUP_TYPE COMMAND
    [Arguments]    ${type}
    ${wakeup_type_value} =    Set Variable If    "${type}" == "Full Wake-Up Mode"    0    "${type}" == "Selective Wake-Up Mode 1"    1
    ...    "${type}" == "Selective Wake-Up Mode 2"    2    "${type}" == "Selective Wake-Up Mode 3"    3
    ...    "${type}" == "Selective Wake-Up Mode 4"    4    "${type}" == "Selective Wake-Up Mode 5"    5
    ...    "${type}" == "Selective Wake-Up Mode 6"    6    "${type}" == "Unavailable"    7
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/SleepManagement/WakeUpType    ${wakeup_type_value}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/SleepManagement/WakeUpType
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE WAKEUP_TYPE COMMAND: ${comment}

SEND VEHICLE STATE COMMAND
    [Arguments]    ${state}
    ${vehicle_state_value} =    Set Variable If    "${state}" == "Sleeping"    0    "${state}" == "CutoffPending"    2
    ...    "${state}" == "AutoACC - BatTempoLevel"    3    "${state}" == "IgnitionLevel"    5
    ...    "${state}" == "StartingInProgress"    6    "${state}" == "PowertrainRunning"    7
    ...    "${state}" == "AutoStart"    8    "${state}" == "EngineSystemStop"    9
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/VehicleStates    ${vehicle_state_value}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/VehicleStates
    should_be_true    ${verdict}    Fail to Canakin Start Write: ${comment}
    SET APC ACC WITH VEHICLESTATES    ${vehicle_state_value}
    Set Suite Variable    ${vehicle_states_can_signal}    ${vehicle_state_value}

SEND VEHICLE CUSTOMER PRESENCE COMMAND
    [Arguments]    ${state}
    ${customer_pres} =    Set Variable If    "${state}" == "False"    0    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/CustomerPresence    ${customer_pres}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/CustomerPresence
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE CUSTOMER PRESENCE COMMAND: ${comment}

SEND VEHICLE LOCK_STATUS COMMAND
    [Arguments]    ${status}
    ${lock_state} =    Set Variable If    "${status}" == "unlocked"    0    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Door/OutsideLockedState    ${lock_state}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Door/OutsideLockedState
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE LOCK_STATUS COMMAND: ${comment}

SEND VEHICLE DOORS_STATUS COMMAND
    [Arguments]    ${doors}    ${state}
    ${door_status} =    Set Variable If    "${state}" == "closed"    ${door_closed}    ${door_open}
    ${hood_status} =    Set Variable If    "${state}" == "closed"    ${hood_closed}    ${hood_open}
    &{doors_signals} =    Run Keyword If    "${doors}" == "AllDoors"    Create Dictionary    Vehicle/Received/Status/Door/Driver=${door_status}    Vehicle/Received/Status/Door/Passenger=${door_status}    Vehicle/Received/Status/Door/RearRight=${door_status}
    ...    Vehicle/Received/Status/Door/RearLeft=${door_status}
    ...    ELSE IF    "${doors}" == "DriverDoorOnly"    Create Dictionary    Vehicle/Received/Status/Door/Driver=${door_status}
    ${door_frame} =    Set Variable If    "HSevo" in "'${EE_architecture}'"    ${door_status_frame_fd}    ${door_status_frame}
    ${verdict}    ${comment} =    Canakin Set Frame    ${door_frame}    ${doors_signals}
    should_be_true    ${verdict}    Fail to Canakin Set Frame: ${comment}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Door/TailGate    ${door_status}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Door/EngineHood    ${hood_status}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=${door_frame}
    should_be_true    ${verdict}    Fail to Canakin Start Write: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Door/EngineHood
    should_be_true    ${verdict}    Fail to Canakin Start Write: Fail to SEND VEHICLE DOORS_STATUS COMMAND : ${comment}

PREPARE VEHICLE STUB FOR REMOTE ORDER
    [Arguments]    ${remote_order}    ${action}=Check    ${option1}=${EMPTY}    ${option2}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Prepare a vehicle stub which answer to any IVC remote order by a ACK answer
    ...    == Parameters: ==
    ...    - _remote_order_: rlu, rhl, res
    ...    - _action_:
    ...    - _option1_:
    ...    - _option2_:
    ...    == Expected Results: ==
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Services Common    CAN
    ${verdict} =    Canakin Unsubscribe Can TCU Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can TCU Remote Order
    Canakin Subscribe Can TCU Remote Order Request
    # Convert remote order naming to match the ones from CanSecureFrames Class
    ${remote_order} =    Set Variable If
    ...    "${remote_order}" == "CHECKICARDPRESENCE"    CHECK_ICARD_PRESENCE
    ...    "${remote_order}" == "rhoo"    RPC_EV
    ...    "${remote_order}" == "remote_blocking_EV_charge"    BCI
    ...    ${remote_order}
    Set Suite Variable     ${remote_order}
    # Set ECU to send back the Ack
    ${ack_ecu} =    Set Variable If    "${remote_order}" == "CHECK_ICARD_PRESENCE"    HFM    BCM
    Set Suite Variable     ${ack_ecu}
    # Set Action expected
    ${order_action} =    Set Variable If
    ...    "${action}" == "Start"    ${start}
    ...    "${action}" == "Stop"    ${stop}
    ...    "${action}" == "Lock"    ${lock}
    ...    "${action}" == "Unlock"    ${unlock}
    ...    "${action}" == "Check"    ${check}
    ...    "${action}" == "DoubleStart"    ${doubleStart}
    ...    "${action}" == "block"    ${block}
    ...    "${action}" == "unblock"    ${unblock}
    # Create dict containing expected values to be compared with received ones
    ${expected_reqs} =    Create Dictionary    remote_order=${remote_order_ids}[${remote_order}]    action=${order_action}
    # Set RHL specific options
    Run Keyword If    "${remote_order}" == "RHL"    SET RHL OPTIONS    ${option1}    ${option2}    ${expected_reqs}
    # Set RLU specific option
    Run Keyword If    "${remote_order}" == "RLU"    SET RLU OPTION    ${option1}    ${expected_reqs}
    Set Suite Variable     ${expected_reqs}

PREPARE VEHICLE STUB FOR REMOTE ORDER JWT
    [Arguments]    ${remote_order}    ${action}=Check    ${option1}=${EMPTY}    ${option2}=${EMPTY}
    [Tags]    Manual    Remote Services Common    CAN
    ${verdict} =    Canakin Unsubscribe Can SGW Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can TCU Remote Order
    Canakin Subscribe Can SGW Remote Order Request
    # Convert remote order naming to match the ones from CanSecureFrames Class
    ${remote_order} =    Set Variable If
    ...    "${remote_order}" == "CHECKICARDPRESENCE"    CHECK_ICARD_PRESENCE
    ...    "${remote_order}" == "rhoo"    RPC_EV
    ...    "${remote_order}" == "remote_blocking_EV_charge"    BCI
    ...    ${remote_order}
    Set Suite Variable     ${remote_order}
    # Set ECU to send back the Ack
    ${ack_ecu} =    Set Variable If    "${remote_order}" == "CHECK_ICARD_PRESENCE"    HFM    BCM
    Set Suite Variable     ${ack_ecu}
    # Set Action expected
    ${order_action} =    Set Variable If
    ...    "${action}" == "Start"    ${start}
    ...    "${action}" == "Stop"    ${stop}
    ...    "${action}" == "Lock"    ${lock}
    ...    "${action}" == "Unlock"    ${unlock}
    ...    "${action}" == "Check"    ${check}
    ...    "${action}" == "DoubleStart"    ${doubleStart}
    ...    "${action}" == "block"    ${block}
    ...    "${action}" == "unblock"    ${unblock}
    # Create dict containing expected values to be compared with received ones
    ${expected_reqs} =    Create Dictionary    remote_order=${remote_order_ids}[${remote_order}]    action=${order_action}
    # Set RHL specific options
    Run Keyword If    "${remote_order}" == "RHL"    SET RHL OPTIONS    ${option1}    ${option2}    ${expected_reqs}
    # Set RLU specific option
    Run Keyword If    "${remote_order}" == "RLU"    SET RLU OPTION    ${option1}    ${expected_reqs}
    Set Suite Variable     ${expected_reqs}

SET RHL OPTIONS
    [Arguments]    ${option1}    ${option2}    ${expected_reqs}
    [Documentation]    Internal KW to set RHL ${option1} and ${option2} into ${expected_reqs} dict
    ${opt1} =    Set Variable if    "${option1}" == "NA"    ${na}    "${option1}" == "Style1"
    ...    ${style_1}    "${option1}" == "Style2"    ${style_2}    "${option1}" == "Style3"    ${style_3}
    ${opt2} =    Set Variable if    "${option2}" == "HornLight"    ${horn_light}    "${option2}" == "HornOnly"
    ...    ${horn_only}    "${option2}" == "LightOnly"    ${light_only}    "${option2}" == "Flasher"    ${flasher}
    Set To Dictionary    ${expected_reqs}    option_1=${opt1}
    Set To Dictionary    ${expected_reqs}    option_2=${opt2}

SET RLU OPTION
    [Arguments]   ${option}    ${expected_reqs}
    [Documentation]    Internal KW to set RLU ${option} into ${expected_reqs} dict
    ${opt} =    Set Variable if    "${option}" == "AllDoors"    ${all_doors}    "${option}" == "DriverDoorOnly"
    ...    ${driver_door}    "${option}" == "Tailgate"    ${tailgate}
    Set To Dictionary    ${expected_reqs}    option=${opt}

CHECK VEHICLE RECEIVE REMOTE ORDER
    ${verdict}    ${req_values} =    Canakin Wait For Can TCU Remote Order Request    ${remote_order}    ${120}
    Should be True    ${verdict}
    Dictionary Should Contain Sub Dictionary    ${req_values}    ${expected_reqs}    No Match
    Should be equal    ${expected_reqs['remote_order']}    ${req_values['remote_order']}    Remote Order decoded ${req_values['remote_order']} is not the expected one
    Should be equal    ${expected_reqs['action']}    ${req_values['action']}    Action decoded ${req_values['action']} is not the expected one
    # RHL option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option1']}    ${req_values['option1']}    Option1 decoded ${req_values['option1']} is not the expected one
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option2']}    ${req_values['option2']}    Option2 decoded ${req_values['option2']} is not the expected one
    # RLU option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RLU"    Should be equal    ${expected_reqs['option']}    ${req_values['option']}    Option1 decoded ${req_values['option']} is not the expected one
    # Preparing the ack with anti replay counter and sequence number
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + 1
    ${seq_num} =    Convert To Integer    ${req_values['sequence_number']}
    ${order} =    Convert To Integer    ${req_values['remote_order']}
    ${verdict}    ${comment} =    Canakin Send Can Remote Order Technical Ack    ${ack_ecu}    ${res_counter}    ${order}    ${seq_num}
    should_be_true    ${verdict}    Fail to CHECK VEHICLE RECEIVE REMOTE ORDER: ${comment}
    ${verdict} =    Canakin Unsubscribe Can TCU Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can TCU Remote Order

CHECK SGW REMOTE ORDER
    [Arguments]    ${can_bus}=can0    ${anti_replay_add_value}=1
    ${verdict}    ${req_values} =    Canakin Wait For Can SGW Remote Order Request    ${remote_order}    ${120}
    Should be True    ${verdict}
    Dictionary Should Contain Sub Dictionary    ${req_values}    ${expected_reqs}    No Match
    Should be equal    ${expected_reqs['remote_order']}    ${req_values['remote_order']}    Remote Order decoded ${req_values['remote_order']} is not the expected one
    Should be equal    ${expected_reqs['action']}    ${req_values['action']}    Action decoded ${req_values['action']} is not the expected one
    # RHL option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option1']}    ${req_values['option1']}    Option1 decoded ${req_values['option1']} is not the expected one
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option2']}    ${req_values['option2']}    Option2 decoded ${req_values['option2']} is not the expected one
    # RLU option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RLU"    Should be equal    ${expected_reqs['option']}    ${req_values['option']}    Option1 decoded ${req_values['option']} is not the expected one
    # Preparing the ack with anti replay counter and sequence number
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + ${anti_replay_add_value}
    ${seq_num} =    Convert To Integer    ${req_values['sequence_number']}
    ${order} =    Convert To Integer    ${req_values['remote_order']}
    ${verdict}    ${comment} =    Canakin Send Can Remote Order Technical Ack    ${ack_ecu}    ${res_counter}    ${order}    ${seq_num}   bus=${can_bus}
    should_be_true    ${verdict}    Fail to CHECK VEHICLE RECEIVE REMOTE ORDER: ${comment}
    ${verdict} =    Canakin Unsubscribe Can SGW Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can SGW Remote Order
    Set Test Variable    ${res_counter}

SEND VEHICLE CHARGE STATUS
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    SEND CAN message about Vehicle/Received/Charge/Status signal
    ...    == Parameters: ==
    ...    - _value_: charge_in_progress, ended_charge,
    [Tags]    Automated    VEHICLE    CAN
    Log to console    SEND VEHICLE CHARGE STATUS ${value}
     ${charge_value} =    Set Variable If    "${value}" == "no_charge"    0    "${value}" == "waiting_a_planned_charge"    1
    ...    "${value}" == "ended_charge"    2    "${value}" == "charge_in_progress"    3
    ...    "${value}" == "charge_failure"    4    "${value}" == "waiting_for_current_charge"    5
    ...    "${value}" == "energy_flap_opened"    6    "${value}" == "stopped_charge_SOC_not_full"    7
    ...    "${value}" == "charging_is_continue_with_full_SOC"    8
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Charge/Status    ${charge_value}
    Should Be True    ${verdict}    Failed to set VEHICLE CHARGE STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Charge/Status
    Should Be True    ${verdict}    Failed to send VEHICLE CHARGE STATUS

SEND VEHICLE POWER RELAY STATUS
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    SEND CAN message about Vehicle/Received/EV/PowerRelayStatus signal
    ...    == Parameters: ==
    ...    _state_: Precharge, Closed, Opened, Transitory state, Risol Relay P Check, Risol Relay N Check
    ${vehicle_state_value} =    Set Variable If    "${state}" == "Precharge"    0    "${state}" == "Closed"   1
    ...    "${state}" == "Opened"    2    "${state}" == "Transitory state"    3
    ...    "${state}" == "Risol Relay P Check"    4    "${state}" == "Risol Relay N Check"    5
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/PowerRelayStatus    ${vehicle_state_value}
    Should Be True    ${verdict}    Fail to Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/PowerRelayStatus
    Should Be True    ${verdict}    Fail to Canakin Start Write: ${comment}

CONFIGURE VEHICLE STUB PROFILE
    [Arguments]    ${profile_name}
    Log to console    CONFIGURE VEHICLE STUB PROFILE ${profile_name}
    Run Keyword If    "${profile_name}" == "keep_ivc_and_ivi_on"    CONFIGURE TO KEEP IVC AND IVI ON
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_ignition_level"    CONFIGURE TO KEEP IVC AND IVI ON IGNITION LEVEL
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_door_open_unlocked_state_customer_not_present"    CONFIGURE ENGINE OFF DOOR OPEN UNLOCKED STATE CUSTOMER NOT PRESENT
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_door_unlocked_customer_not_present"    CONFIGURE ENGINE OFF DOOR UNLOCKED CUSTOMER NOT PRESENT
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_customer_not_present"    CONFIGURE ENGINE OFF CUSTOMER NOT PRESENT
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_customer_not_present_ivc_wakeup"    CONFIGURE ENGINE OFF CUSTOMER NOT PRESENT IVC WAKEUP
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_customer_present_ivc_wakeup"    CONFIGURE ENGINE OFF IVC WAKEUP CUSTOMER PRESENCE
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_res_not_progress_no_customer"    CONFIGURE ENGINE OFF RES NOT PROGRESS NO CUSTOMER
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_door_locked_customer_not_present"    CONFIGURE ENGINE OFF DOOR LOCKED CUSTOMER NOT PRESENT
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_on_res_in_progress_no_customer"    CONFIGURE ENGINE ON RES IN PROGRESS NO CUSTOMER
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_door_unlocked_customer_present"    CONFIGURE ENGINE OFF DOOR UNLOCKED CUSTOMER PRESENT
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_customer_present_start_button_not_pressed"    CONFIGURE ENGINE OFF CUSTOMER PRESENT START BUTTON NOT PRESSED
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_on_46%_battery"    CONFIGURE TO KEEP IVC AND IVI ON SET BATTERY LEVEL 46
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_on_plug_connected_46%_battery_500_min_remaining_time"    CONFIGURE TO KEEP IVC AND IVI ON BATTERY LEVEL 46 REMAINING TIME 500
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_on_no_charge_500km_autonomy"    CONFIGURE TO KEEP IVC AND IVI ON NO CHARGE 500KM AUTONOMY
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_on_vehicle_running_battery_level=46"    CONFIGURE TO KEEP IVC AND IVI ON RUNNING BATTERY LEVEL 46
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_on_engine_off_customer_not_present"    CONFIGURE TO KEEP IVC AND IVI ON ENGINE OFF CUSTOMER NOT PRESENT
    ...    ELSE IF    "${profile_name}" == "vehicle_stub_emulate_we_stop_the_car"    CONFIGURE WE STOP THE CAR
    ...    ELSE IF    "${profile_name}" == "rchs_start_context_data"    CONFIGURE RCHS START DATA CONTEXT
    ...    ELSE IF    "${profile_name}" == "rchs_stop_context_data"    CONFIGURE RCHS STOP DATA CONTEXT
    ...    ELSE IF    "${profile_name}" == "only_keep_ivc_on"    Run keywords    KEEP IVC ON    AND    Set Suite Variable     ${ivc_can_only}    True
    ...    ELSE IF    "${profile_name}" == "keep_ivc_on_hvac_settings"    KEEP IVC ON HVAC SETTINGS
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_presoak_not_progress_no_customer_25deg_temp"    VEHICLE OFF PRESOAK NOT PROGRESS NO CUSTOMER 25 DEG
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_presoak_not_progress_customer_inside_25deg_temp"    VEHICLE OFF PRESOAK NOT PROGRESS CUSTOMER INSIDE 25 DEG
    ...    ELSE IF    "${profile_name}" == "vehicle_engine_off_presoak_in_progress_no_customer_25deg_temp"    VEHICLE OFF PRESOAK IN PROGRESS NO CUSTOMER 25 DEG
    ...    ELSE IF    "${profile_name}" == "only_keep_ivc_on_vehicle_running"    CONFIGURE TO KEEP IVC ON VEHICLE RUNNING
    ...    ELSE IF    "${profile_name}" == "keep_ivc_and_ivi_on_vehicle_running"    CONFIGURE TO KEEP IVC AND IVI ON VEHICLE RUNNING
    ...    ELSE IF    "${profile_name}" == "power_relay_blms_data" or "${profile_name}" == "periodic_blms_data" or "${profile_name}" == "blms_default_values" or "${profile_name}" == "blms_new_values"    CONFIGURE BLMS DATA    "${profile_name}"
    ...    ELSE IF    "${profile_name}" == "vher_start_data"    CONFIGURE VEHICLE HEALTH START DATA
    ...    ELSE IF    "${profile_name}" == "vher_stop_data"    CONFIGURE VEHICLE HEALTH STOP DATA
    ...    ELSE IF    "${profile_name}" == "notification_charge_start"    CONFIGURE VEHICLE NOTIFICATION CHARGE START
    ...    ELSE IF    "${profile_name}" == "notification_charge_stop"    CONFIGURE VEHICLE NOTIFICATION CHARGE STOP
    ...    ELSE IF    "${profile_name}" == "engine_off_customer_leave"    CONFIGURE ENGINE OFF CUSTOMER LEAVE
    ...    ELSE IF    "${profile_name}" == "engine_on_customer_presence"    CONFIGURE ENGINE ON CUSTOMER PRESENCE
    ...    ELSE IF    "${profile_name}" == "trip_data"    CONFIGURE TRIP DATA
    ...    ELSE IF    "${profile_name}" == "rchs_parameters"    CONFIGURE RCHS PARAMETERS
    ...    ELSE IF    "${profile_name}" == "eva_001_single_trigger_data"    CONFIGURE EVA_001 PARAMETERS
    ...    ELSE IF    "${profile_name}" == "eva_003_single_trigger_data"    CONFIGURE EVA 003 SINGLE TRIGGER DATA
    ...    ELSE IF    "${profile_name}" == "eva_003_single_trigger_new_data"    CONFIGURE EVA 003 SINGLE TRIGGER NEW DATA
    ...    ELSE IF    "${profile_name}" == "eva_periodic_trigger_data"    CONFIGURE EVA PERIODIC TRIGGER DATA
    ...    ELSE IF    "${profile_name}" == "emulate_ubam_data_periodic_trigger"    CONFIGURE UBAM DATA TRIGGER
    ...    ELSE IF    "${profile_name}" == "emulate_ubam_data_single_trigger"    CONFIGURE UBAM DATA SINGLE TRIGGER
    ...    ELSE IF    "${profile_name}" == "emulate_coma_all_data"    CONFIGURE COMA ALL DATA
    ...    ELSE IF    "${profile_name}" == "phyd_all_data"    CONFIGURE PHYD ALL DATA
    ...    ELSE IF    "${profile_name}" == "eva_002_single_trigger_data"    CONFIGURE EVA_002 PARAMETERS
    ...    ELSE IF    "${profile_name}" == "eva_context_trigger_data"    CONFIGURE EVA_005 CONTEXT PARAMETERS
    ...    ELSE IF    "${profile_name}" == "dabr_data_periodic_trigger"    CONFIGURE DABR PERIODIC TRIGGER
    ...    ELSE IF    "${profile_name}" == "dabr_data_single_trigger"    CONFIGURE DABR DATA SINGLE TRIGGER
    ...    ELSE    Fail    No implementation for profile ${profile_name}

SIMULATE THE TRIGGER
    [Arguments]    ${profile_name}
    [Documentation]    Used to simulate different trigger profiles given as input parameter
    Run Keyword If    "${profile_name}" == "power_relay_open"    SIMULATE POWER RELAY OPEN TRIGGER
    ...    ELSE IF    "${profile_name}" == "start_of_journey"    SIMULATE START OF JOURNEY TRIGGER
    ...    ELSE IF    "${profile_name}" == "end_of_journey"    SIMULATE END OF JOURNEY TRIGGER
    ...    ELSE IF    "${profile_name}" == "end_of_mission"    SIMULATE END OF MISSION TRIGGER
    ...    ELSE IF    "${profile_name}" == "start_of_mission"    SIMULATE START OF MISSION TRIGGER
    ...    ELSE   Log To Console    No implementation for profile ${profile_name}

CONFIGURE TO KEEP IVC AND IVI ON NO CHARGE 500KM AUTONOMY
    CONFIGURE TO KEEP IVC AND IVI ON
    SEND VEHICLE CHARGE STATUS    no_charge
    SET VEHICLE AUTONOMY DISPLAY    1F4h

CONFIGURE TO KEEP IVC AND IVI ON RUNNING BATTERY LEVEL 46
    [Documentation]    Configuration to keep the IVC and IVI on and battery level at 46%
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    On
    SEND VEHICLE STATE COMMAND    PowertrainRunning
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    CONFIGURE CAN FOR BATTERY VOLTAGE    1Eh
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SEND VEHICLE WELCOME SEQUENCE    done
    SET EXTERNAL TEMPERATURE    22
    SET BATTERY ENERGY LEVEL    46

CONFIGURE TO KEEP IVC AND IVI ON SET BATTERY LEVEL 46
    [Documentation]    Configuration to keep the IVC and IVI on and battery level at 46%
    CONFIGURE TO KEEP IVC AND IVI ON
    SET BATTERY ENERGY LEVEL    46

CONFIGURE TO KEEP IVC AND IVI ON ENGINE OFF CUSTOMER NOT PRESENT
    [Documentation]    Configuration to keep the IVC and IVI on and engine off
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    CONFIGURE CAN FOR BATTERY VOLTAGE    4Eh
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SET EXTERNAL TEMPERATURE    E1h
    SEND VEHICLE WELCOME SEQUENCE    done
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0

CONFIGURE TO KEEP IVC AND IVI ON BATTERY LEVEL 46 REMAINING TIME 500
    [Documentation]    Configuration to keep the IVC and IVI on, plug connected, battery level at 46% and 500 min remaining time
    Run Keyword if    "${console_logs}" == "yes"     Log to console    CONFIGURE TO KEEP IVC AND IVI ON BATTERY LEVEL 46 REMAINING TIME 500
    CONFIGURE TO KEEP IVC AND IVI ON
    SET PLUG CONNECTED    1
    SET BATTERY ENERGY LEVEL    46
    SET REMAINING TIME    500

CONFIGURE VEHICLE HEALTH START DATA
    [Documentation]  Configuration vehicle health start data
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    Off
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    SEND DISTANCE TOTALIZER    400
    SEND CRASH DETECTION OUT OF ORDER    1
    SEND VEHICLE BRAKE STATUS COMMAND    failure
    SEND VEHICLE MILLAMMP REQUEST STATUS COMMAND    1
    SEND VEHICLE BRAKE FLUID LEVEL STATUS COMMAND    2
    SEND VEHICLE ABS MALFUNCTION COMMAND    1
    SEND VEHICLE OIL PRESSURE WARNING STATUS COMMAND    1
    SEND WHEEL STATE    FrontLeft    1
    SEND WHEEL STATE    FrontRight    1
    SEND WHEEL STATE    RearLeft    1
    SEND WHEEL STATE    RearRight    1
    SEND STATUS FUEL CONSUMPTION    8000
    SEND VEHICLE SPEED DISPLAYED IN KMH    0
    SEND AUTONOMY DISTANCE    500

CONFIGURE VEHICLE HEALTH STOP DATA
    [Documentation]  Configuration vehicle health stop data
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    Off
    SEND VEHICLE STATE COMMAND    PowertrainRunning
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    SEND DISTANCE TOTALIZER    405
    SEND CRASH DETECTION OUT OF ORDER    1
    SEND VEHICLE BRAKE STATUS COMMAND    failure
    SEND VEHICLE MILLAMMP REQUEST STATUS COMMAND    1
    SEND VEHICLE BRAKE FLUID LEVEL STATUS COMMAND    2
    SEND VEHICLE ABS MALFUNCTION COMMAND    1
    SEND VEHICLE OIL PRESSURE WARNING STATUS COMMAND    1
    SEND WHEEL STATE    FrontLeft    1
    SEND WHEEL STATE    FrontRight    1
    SEND WHEEL STATE    RearLeft    1
    SEND WHEEL STATE    RearRight    1
    SEND STATUS FUEL CONSUMPTION    20400
    SEND VEHICLE SPEED DISPLAYED IN KMH    0
    SEND AUTONOMY DISTANCE    500

CONFIGURE WE STOP THE CAR
    [Documentation]    Configuration we stop the car
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    Off
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    CONFIGURE CAN FOR BATTERY VOLTAGE    1Eh
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SEND VEHICLE WELCOME SEQUENCE    done
    SET EXTERNAL TEMPERATURE    70

CONFIGURE TO KEEP IVC AND IVI ON
    [Documentation]    Configuration to keep the IVC and IVI on
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE WAKEUP COMMAND
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SET VEHICLE EEM STATIC POWER LIMIT    0
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    SEND VEHICLE WELCOME SEQUENCE    unavailable
    SEND VEHICLE SPEED VALUE    0
    SEND VEHICLE BRAKE PARKING STATUS COMMAND    2
    CONFIGURE CAN FOR BATTERY VOLTAGE    7h
    SET EXTERNAL TEMPERATURE    16h
    SET CABINE TEMPERATURE    1Ah
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SET BATTERY ENERGY LEVEL    48
    SEND VEHICLE STATE COMMAND    IgnitionLevel

CONFIGURE TO KEEP IVC AND IVI ON IGNITION LEVEL
    [Documentation]    Configuration to keep the IVC and IVI on at ignition level
    CONFIGURE TO KEEP IVC AND IVI ON
    SEND VEHICLE STATE COMMAND    IgnitionLevel
    SET PROBABLE CUSTOMER FEEDBACK NEED    1
    SET USER SOC    0xE7
    SET VEHICLE SPEED    0
    SET WARNING LIGHTS STATUS    0
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    SEND VEHICLE WELCOME SEQUENCE    not_started

CONFIGURE ENGINE OFF DOOR UNLOCKED CUSTOMER NOT PRESENT
    [Documentation]    Configuration for vehicle engine off, door unlocked, customer not present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False

CONFIGURE ENGINE OFF DOOR OPEN UNLOCKED STATE CUSTOMER NOT PRESENT
    [Documentation]    Configuration for vehicle engine off, door opened and unlocked, customer not present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    open
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False

CONFIGURE ENGINE OFF RES NO CUSTOMER IVC WAKEUP
    [Documentation]    Configuration for vehicle engine off, customer not present, IVC wakeup
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    CONFIGURE CAN FOR RES STATUS    Stop
    CONFIGURE CAN FOR RES STATE    Stop
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False

CONFIGURE ENGINE OFF IVC WAKEUP CUSTOMER PRESENCE
    [Documentation]    Configuration for vehicle engine off, customer present, IVC wakeup
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True

CONFIGURE ENGINE OFF RES NOT PROGRESS NO CUSTOMER
    [Documentation]    Configuration for vehicle engine off, RES not progress, customer not present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    locked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    CONFIGURE CAN FOR RES STATUS    Stop
    CONFIGURE CAN FOR RES STATE    Stop

CONFIGURE ENGINE ON RES IN PROGRESS NO CUSTOMER
    [Documentation]    Configuration for vehicle engine on, RES in progress, customer not present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    locked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    CONFIGURE CAN FOR RES STATUS    GetStatus    NoError    NoFailure
    CONFIGURE CAN FOR RES STATE    Start

CONFIGURE ENGINE OFF CUSTOMER PRESENT START BUTTON NOT PRESSED
    [Documentation]  Configuration for vehicle engine off, customer present, start not pressed
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    DO PRESS START VEHICLE BUTTON DURING    0
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel

CONFIGURE RCHS START DATA CONTEXT
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    On
    SEND VEHICLE STATE COMMAND    PowertrainRunning
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    CONFIGURE CAN FOR BATTERY VOLTAGE    1Eh
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SEND VEHICLE WELCOME SEQUENCE    done

CONFIGURE RCHS STOP DATA CONTEXT
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    Off
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    CONFIGURE CAN FOR BATTERY VOLTAGE    1Eh
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SEND VEHICLE WELCOME SEQUENCE    done

KEEP IVC ON
    [Documentation]    Configuration to keep the IVC on
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel

VEHICLE OFF PRESOAK IN PROGRESS NO CUSTOMER 25 DEG
    [Documentation]    The Vehicle engine is OFF, presoak is in progress.
    ...    The customer is not present inside the vehicle and the temperature inside is 25.
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    locked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    SEND VEHICLE PRESOAK VALUE    presoak_in_progress
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    SET CABINE TEMPERATURE    25

VEHICLE OFF PRESOAK NOT PROGRESS NO CUSTOMER 25 DEG
    [Documentation]    The Vehicle engine is OFF, NO presoak request is in progress.
    ...    The customer is not present inside the vehicle and the temperature inside is 25.
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    locked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    SEND VEHICLE PRESOAK VALUE    no_presoak_in_progress
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    SET CABINE TEMPERATURE    25

VEHICLE OFF PRESOAK NOT PROGRESS CUSTOMER INSIDE 25 DEG
    [Documentation]    The Vehicle engine is OFF, NO presoak request is in progress.
    ...    The customer is inside the vehicle and the temperature inside is 25.
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    locked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    SEND VEHICLE PRESOAK VALUE    no_presoak_in_progress
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    SET CABINE TEMPERATURE    25
    SEND VEHICLE RES COMMAND    Stop    Stop    NoError    NoFailure

KEEP IVC ON HVAC SETTINGS
    [Documentation]    The Vehicle engine is OFF. The customer is not present inside the vehicle.
    ...    The BCM send wake up request to IVC and emulates the HVAC settings parameters
    SEND VEHICLE CUSTOMER PRESENCE COMMAND   False
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE SWITCH POSITION COMMAND    Off
    SET CABINE TEMPERATURE    26
    SET EXTERNAL TEMPERATURE    25
    SEND VEHICLE HVAC STATE    presoak_in_progress

SEND VEHICLE RES COMMAND
    [Arguments]    ${StatusRES}    ${StatusRESLeftTimeDuringThisCycle}    ${StatusRESSmartPhoneError}    ${StatusRESFailureType}
    CONFIGURE CAN FOR RES STATE    ${StatusRES}
    CONFIGURE CAN FOR RES STATUS    ${StatusRESLeftTimeDuringThisCycle}    ${StatusRESSmartPhoneError}    ${StatusRESFailureType}

SEND VEHICLE SWITCH OFF SES DISTURBERS
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    SwitchOffSESDisturbers    ${value}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=SwitchOffSESDisturbers
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE SWITCH OFF SES DISTURBERS: ${comment}

SEND VEHICLE WELCOME SEQUENCE
    [Arguments]    ${value}
    ${welcome_value} =    Set Variable If    "${value}" == "unavailable"    0    "${value}" == "not_started"    1
    ...    "${value}" == "in_progress"    2    "${value}" == "done"    3
    ${verdict}    ${comment} =    Canakin Set Signal    WelcomeSequenceStatus    ${welcome_value}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=WelcomeSequenceStatus
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE WELCOME SEQUENCE: ${comment}

DO BCM STANDBY
    [Arguments]    ${wait_duration}=120
    [Documentation]    Put on STAND BY the IVC
    [Tags]    Manual    VEHICLE    CAN

    FOR    ${index}    IN RANGE    30
        Canakin Seek Signal    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep    ${ready_to_sleep}    ${seek_timeout}
        ${seek_not_fail}    ${comment} =    Canakin Get Seek Signal Result    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep
        Exit For Loop IF    '${seek_not_fail}'=='True' or 'ivi2' in "'${bench_type}'"
        Sleep    1
    END
    Run Keyword If     '${seek_not_fail}'=='True'    SEND VEHICLE WAKEUP COMMAND    sleep
    Run Keyword If     '${seek_not_fail}'=='True' or 'ivi2' in "'${bench_type}'"    Canakin Stop Write    elements=All
    Log    Wait ${wait_duration} seconds after BCM standby    console=${console_logs}
    Sleep    ${wait_duration}

DO PRESS START VEHICLE BUTTON DURING
    [Arguments]    ${duration}
    [Documentation]    == High Level Description: ==
    ...    Send a CAN signal periodically to store the new pin code value set
    ...    == Parameters: ==
    ...    - _duration_: an int followed by string "sec" representing the duration expected for the retry strategy
    [Tags]    Automated    VEHICLE    CAN
    ${time_value} =    Strip String    ${duration}    mode=right
    ${signal_name} =    Set Variable    ${CAN_FRAMES['${EE_architecture}']["PushtoStartButton"]["signal_name"]}
    Run Keyword If    "${signal_name}" == "${None}"    Fail    Frame was not found in architecture: ${EE_architecture}
    ${signal_value_on} =    Set Variable    ${CAN_FRAMES['${EE_architecture}']["PushtoStartButton"]["On"]}
    ${signal_value_off} =    Set Variable    ${CAN_FRAMES['${EE_architecture}']["PushtoStartButton"]["Off"]}
    ${verdict}    ${comment} =    Repeat Keyword    ${time_value}    PRESS VEHICLE BUTTON    ${signal_name}    ${signal_value_on}    ${signal_value_off}

PRESS VEHICLE BUTTON
    [Arguments]    ${signal_name}    ${signal_value_on}    ${signal_value_off}
    [Documentation]    Emulating over CAN bus the action of pushing the start button ON&OFF
    @{signal_values} =    Create List
    Append To List    ${signal_values}    ${signal_value_on}    ${signal_value_off}
    ${size} =    Get Length    ${signal_values}
    FOR    ${index}    IN RANGE    ${size}
        ${verdict}    ${comment} =    Canakin Set Signal     ${signal_name}    ${signal_values[${index}]}
        Should Be True    ${verdict}    Fail to Set Signal: ${comment}
        ${verdict}    ${comment} =    Canakin Start Write    elements=${signal_name}
        Should Be True    ${verdict}    Fail to Canakin Start Write: ${comment}
    END

CONFIGURE ENGINE OFF DOOR UNLOCKED CUSTOMER PRESENT
    [Documentation]    Configuration for vehicle engine off, door unlocked, customer present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True

SEND VEHICLE IKEY_PRESENCE COMMAND
    [Arguments]    ${status}
    [Documentation]    Send CAN message about the status of the Ikey (IKey/Received/Badge/DetectionStatus) signal only one time
    Log To Console    SEND VEHICLE IKEY_PRESENCE COMMAND: send CAN about the status:${status} of the Ikey
    ${signal_value} =    Set variable if    "${status}".lower() == "no information"    0    "${status}".lower() == "inside"    1
    ...    "${status}".lower() == "outside"    2    "${status}".lower() == "not used"    3
    ${verdict}    ${comment} =    Canakin Set Signal    IKey/Received/Badge/DetectionStatus    ${signal_value}
    should_be_true    ${verdict}
    ${verdict}    ${comment} =    Canakin Start Write    elements=IKey/Received/Badge/DetectionStatus
    should_be_true    ${verdict}

SEND VEHICLE CHARGE BLOCK MODE
    [Arguments]    ${state}
    ${block_state} =    Set Variable If    "${state}" == "block"    1    "${state}" == "unblock"    0
    ${verdict}    ${comment} =    Canakin Set Signal    ChargeProhibitionByRentalDisplay    ${block_state}
    should_be_true    ${verdict}    Failed to set VEHICLE CHARGE BLOCK MODE to state ${state}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ChargeProhibitionByRentalDisplay
    should_be_true    ${verdict}    Failed to send VEHICLE CHARGE BLOCK MODE

SET BATTERY ENERGY LEVEL
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    HVBatteryEnergyLevel    ${value}
    should_be_true    ${verdict}    Failed to set BATTERY ENERGY LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBatteryEnergyLevel
    should_be_true    ${verdict}    Failed to send BATTERY ENERGY LEVEL

SET EXTERNAL TEMPERATURE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    ExternalTemperature    ${value}
    should_be_true    ${verdict}    Failed to set EXTERNAL TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ExternalTemperature
    should_be_true    ${verdict}    Failed to send EXTERNAL TEMPERATURE

SET PLUG CONNECTED
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    ChargingPlugConnected_v2    ${value}
    should_be_true    ${verdict}    Failed to set PLUG CONNECTED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ChargingPlugConnected_v2
    should_be_true    ${verdict}    Failed to send PLUG CONNECTED

SET REMAINING TIME
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/Charge/RemainingTime    ${value}
    should_be_true    ${verdict}    Failed to set REMAINING TIME to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/Charge/RemainingTime
    should_be_true    ${verdict}    Failed to send REMAINING TIME

SEND DISTANCE TOTALIZER
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    DistanceTotalizer    ${value}
    should_be_true    ${verdict}    Failed to set DISTANCE TOTALIZER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=DistanceTotalizer
    should_be_true    ${verdict}    Failed to send DISTANCE TOTALIZER

SEND AVAILABLE ENERGY
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/AvailableEnergy    ${value}
    should_be_true    ${verdict}    Failed to set AVAILABLE ENERGY to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/AvailableEnergy
    should_be_true    ${verdict}    Failed to send AVAILABLE ENERGY

SEND VEHICLE SPEED DISPLAYED IN KMH
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Speed/Displayed/Valueinkmh    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE SPEED DISPLAYED IN KMH to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Speed/Displayed/Valueinkmh
    Should Be True    ${verdict}    Failed to SEND VEHICLE SPEED DISPLAYED IN KMH

SEND VEHICLE SPEED VALUE
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Speed/Value   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE SPEED VALUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Speed/Value
    Should Be True    ${verdict}    Failed to SEND VEHICLE SPEED VALUE

EMULATE SCOMO SETUP
    [Documentation]   Sends periodical frames to emulate scomo setup
    SEND VEHICLE SPEED VALUE    0
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE BRAKE PARKING STATUS COMMAND    2

SEND VEHICLE CHARGE AVAILABILITY
    [Arguments]    ${value}
    ${charge_value} =    Set Variable If    "${value}" == "charge_available"    1    "${value}" == "charge_not_available"    0
    ${verdict}    ${comment} =    Canakin Set Signal    ChargeAvailable    ${charge_value}
    should_be_true    ${verdict}    Failed to set VEHICLE CHARGE AVAILABILITY to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ChargeAvailable
    should_be_true    ${verdict}    Failed to send VEHICLE CHARGE AVAILABILITY

SET VEHICLE AUTONOMY DISPLAY
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    VehicleAutonomyZEVdisplay     ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE AUTONOMY DISPLAY to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=VehicleAutonomyZEVdisplay
    should_be_true    ${verdict}    Failed to send VEHICLE AUTONOMY DISPLAY

SEND VEHICLE PRESOAK VALUE
    [Arguments]    ${value}
    ${presoak_value} =    Set Variable If    "${value}" == "presoak_forbidden"    0    "${value}" == "no_presoak_in_progress"    1
    ...    "${value}" == "presoak_in_progress"    2    "${value}" == "unavailable"    3
    ${verdict}    ${comment} =    Canakin Set Signal    HEVC_PresoakActivationStatus    ${presoak_value}
    should_be_true    ${verdict}    Failed to set VEHICLE PRESOAK VALUE to value ${presoak_value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HEVC_PresoakActivationStatus
    should_be_true    ${verdict}    Failed to send VEHICLE PRESOAK VALUE

SET CABINE TEMPERATURE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/HVAC/Temperature/CabinCurrentValue     ${value}
    should_be_true    ${verdict}    Failed to set CABIN TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/HVAC/Temperature/CabinCurrentValue
    should_be_true    ${verdict}    Failed to send CABIN TEMPERATURE

SET USER SOC
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    UserSOC    ${value}
    Should Be True    ${verdict}    Failed to set UserSOC to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=UserSOC
    Should Be True    ${verdict}    Failed to send UserSOC

SET VEHICLE SPEED
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    VehicleSpeed    ${value}
    Should Be True    ${verdict}    Failed to set VehicleSpeed to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=VehicleSpeed
    Should Be True    ${verdict}    Failed to send VehicleSpeed

SET WARNING LIGHTS STATUS
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    WarningLightsStatus    ${value}
    Should Be True    ${verdict}    Failed to set WarningLightsStatus to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=WarningLightsStatus
    Should Be True    ${verdict}    Failed to send WarningLightsStatus

SET PROBABLE CUSTOMER FEEDBACK NEED
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    ProbableCustomerFeedBackNeed    ${value}
    Should Be True    ${verdict}    Failed to set PROBABLE CUSTOMER FEEDBACK NEED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ProbableCustomerFeedBackNeed
    Should Be True    ${verdict}    Failed to send PROBABLE CUSTOMER FEEDBACK NEED

CONFIGURE ENGINE OFF CUSTOMER NOT PRESENT
    [Documentation]    Configuration for vehicle engine off, customer not present
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CONFIGURE ENGINE OFF CUSTOMER NOT PRESENT: send CAN signal every 100ms
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False

SEND VEHICLE MILLAMMP REQUEST STATUS COMMAND
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/MILLamp/Request     ${value}
    should_be_true    ${verdict}    Failed to set MILLAMP STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/MILLamp/Request
    should_be_true    ${verdict}    Failed to send MILLAMP STATUS

SEND VEHICLE BRAKE FLUID LEVEL STATUS COMMAND
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Brake/LowFluidLevel     ${value}
    should_be_true    ${verdict}    Failed to set BRAKE FLUID LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Brake/LowFluidLevel
    should_be_true    ${verdict}    Failed to send BRAKE FLUID LEVEL

SEND VEHICLE ABS MALFUNCTION COMMAND
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/ABS/Malfunction     ${value}
    should_be_true    ${verdict}    Failed to set ABS MALFUNCTION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/ABS/Malfunction
    should_be_true    ${verdict}    Failed to send ABS MALFUNCTION

SEND VEHICLE OIL PRESSURE WARNING STATUS COMMAND
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/OilPressureWarning    ${value}
    should_be_true    ${verdict}    Failed to set OIL PRESSURE WARNING to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/OilPressureWarning
    should_be_true    ${verdict}    Failed to send OIL PRESSURE WARNING

SEND CRASH DETECTION OUT OF ORDER
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Crash/DetectionOutOfOrder    ${value}
    should_be_true    ${verdict}    Failed to set CRASH DETECTION OUT OF ORDER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Crash/DetectionOutOfOrder
    should_be_true    ${verdict}    Failed to set CRASH DETECTION OUT OF ORDER

SEND STATUS FUEL CONSUMPTION
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Fuel/Consumption    ${value}
    should_be_true    ${verdict}    Failed to set STATUS FUEL CONSUMPTION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Fuel/Consumption
    should_be_true    ${verdict}    Failed to set STATUS FUEL CONSUMPTION

DO SEND VEHICLE LOCK STATUS COMMAND
    [Arguments]    ${status}
    [Documentation]    SEND CAN message about Vehicle/Received/Status/Door/OutsideLockedState signal every 100ms
    Log To Console    SEND CAN message about Vehicle/Received/Status/Door/OutsideLockedState with 0 or 1 depending upon status: ${status}
    ${lock_state} =    Set Variable If    "${status}" == "unlocked"    0    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Door/OutsideLockedState    ${lock_state}
    should_be_true    ${verdict}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Door/OutsideLockedState
    should_be_true    ${verdict}

CONFIGURE ENGINE OFF DOOR LOCKED CUSTOMER NOT PRESENT
    [Documentation]    Configuration for vehicle engine off, door locked, customer not present
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    Configuration for vehicle engine off, door locked, customer not present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    SEND VEHICLE LOCK_STATUS COMMAND    locked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False

WAIT FOR IVC WAKEUP REQUEST DURING
    [Arguments]    ${timeout}    ${TC_folder}=${EMPTY}
    [Documentation]    Check that the IVC send a TCU_Wakeup signal (Vehicle/Sent/SleepManagement/WakeUpRequest) within the timeout
    IF    "${EE_architecture}" == "C1A-HS"
        ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    Vehicle/Sent/SleepManagement/WakeUpRequest    83C0h    ${timeout}
    ELSE IF    "HSevo" in "'${EE_architecture}'"
        ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    CGW_WakeUpFrame_extd    83C0h    ${timeout}
    END
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to Seek Signal with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to Seek Signal with comment: ${comment}

    IF    "${EE_architecture}" == "C1A-HS"
        ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}     Vehicle/Sent/SleepManagement/WakeUpRequest
    ELSE IF    "HSevo" in "'${EE_architecture}'"
        ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}    CGW_WakeUpFrame_extd
    END
    Set Suite Variable     ${can_flag}    ${verdict}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to Get Seek Signal with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to Get Seek Signal with comment: ${comment}

CONFIGURE TO KEEP IVC AND IVI ON VEHICLE RUNNING
    [Documentation]    Configuration to keep the IVC and IVI on and vehicle running
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    On
    SEND VEHICLE STATE COMMAND    PowertrainRunning
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    CONFIGURE CAN FOR BATTERY VOLTAGE    1Eh
    SEND VEHICLE SWITCH OFF SES DISTURBERS    0
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SEND VEHICLE WELCOME SEQUENCE    done

SEND DISTANCE TO EMPTY TANK
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Fuel/Consumption/DistanceToEmptyTank    ${value}
    Should Be True    ${verdict}    Failed to set SEND DISTANCE TO EMPTY TANK to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Fuel/Consumption/DistanceToEmptyTank
    Should Be True    ${verdict}    Failed to send SEND DISTANCE TO EMPTY TANK

SEND RECOVERY TOTAL LAST TRIP
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/Recovery/Total/LastTrip    ${value}
    Should Be True    ${verdict}    Failed to set SEND RECOVERY TOTAL LAST TRIP to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/Recovery/Total/LastTrip

SEND DISTANCE TRIP UNIT
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Distance/TripUnit    ${value}
    Should Be True    ${verdict}    Failed to set SEND DISTANCE TRIP UNIT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Distance/TripUnit
    Should Be True    ${verdict}    Failed to send SEND DISTANCE TRIP UNIT

SEND MAINTENANCE FIXED RANGE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Maintenance/FixedRange    ${value}
    Should Be True    ${verdict}    Failed to set SEND MAINTENANCE FIXED RANGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Maintenance/FixedRange
    Should Be True    ${verdict}    Failed to send SEND MAINTENANCE FIXED RANGE

SEND OIL STATUS LEVEL
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/OilLevel    ${value}
    Should Be True    ${verdict}    Failed to set SEND OIL STATUS LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/OilLevel
    Should Be True    ${verdict}    Failed to send SEND OIL STATUS LEVEL

SEND AUTONOMY DISTANCE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/SCR/Distance/Autonomy    ${value}
    Should Be True    ${verdict}    Failed to set SEND AUTONOMY DISTANCE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/SCR/Distance/Autonomy
    Should Be True    ${verdict}    Failed to send SEND AUTONOMY DISTANCE

SEND UREA LEVEL
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/SCR/UreaLevel    ${value}
    Should Be True    ${verdict}    Failed to set SEND UREA LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/SCR/UreaLevel
    Should Be True    ${verdict}    Failed to send SEND UREA LEVEL

SEND WHEEL PRESSURE
    [Arguments]    ${wheel}    ${value}
    ${wheel_pressure} =    Set Variable If    "${wheel}" == "FrontLeft"    ${value}    "${wheel}" == "FrontRight"    ${value}    "${wheel}" == "RearRight"    ${value}    "${wheel}" == "RearLeft"    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/Pressure/${wheel}    ${value}
    Should Be True    ${verdict}    Failed to set SEND WHEEL PRESSURE to value ${value}
    ${wheel_pressure} =    Set Variable If    "${wheel}" == "FrontLeft"    ${value}    "${wheel}" == "FrontRight"    ${value}    "${wheel}" == "RearRight"    ${value}    "${wheel}" == "RearLeft"    ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/Pressure/${wheel}
    Should Be True    ${verdict}    Failed to send SEND WHEEL PRESSURE

SEND WHEEL STATE
    [Arguments]    ${wheel}    ${value}
    ${wheel_state} =    Set Variable If    "${wheel}" == "FrontLeft"    ${value}    "${wheel}" == "FrontRight"    ${value}    "${wheel}" == "RearRight"    ${value}    "${wheel}" == "RearLeft"    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/State/${wheel}    ${value}
    Should Be True    ${verdict}    Failed to set SEND WHEEL PRESSURE to value ${value}
    ${wheel_state} =    Set Variable If    "${wheel}" == "FrontLeft"    ${value}    "${wheel}" == "FrontRight"    ${value}    "${wheel}" == "RearRight"    ${value}    "${wheel}" == "RearLeft"    ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/State/${wheel}
    Should Be True    ${verdict}    Failed to send SEND WHEEL PRESSURE

SEND GLOBAL VEHICLE WARNING STATE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/GlobalVehicleWarningState    ${value}
    Should Be True    ${verdict}    Failed to set SEND GLOBAL VEHICLE WARNING STATE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/GlobalVehicleWarningState
    Should Be True    ${verdict}    Failed to send SEND GLOBAL VEHICLE WARNING STATE

CONFIGURE TO KEEP IVC ON VEHICLE RUNNING
    [Documentation]    Configuration to keep the IVC on vehicle running
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CONFIGURE TO KEEP IVC ON VEHICLE RUNNING
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE SWITCH POSITION COMMAND    On

SEND VEHICLE BRAKE STATUS COMMAND
    [Arguments]    ${state}
    [Documentation]    SEND CAN message about  brake status of the vehicle signal.
    ${vehicle_brake_state_value} =    Set Variable If    "${state}" == "no_failure"    0    "${state}" == "failure"    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/Braking/FailureStatus    ${vehicle_brake_state_value}
    should_be_true    ${verdict}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/Braking/FailureStatus
    should_be_true    ${verdict}

CHECK VEHICLE REFUSE TO SLEEP SIGNAL
    [Arguments]    ${ivc_wakeup_timeout}
    [Documentation]    Check the IVC send a CAN signal TCU_refuse_to_sleep signals to the  BCM stub
    #The REFUSE_TO_SLEEP signal can be either at meaning value refuse to sleep (1) or ready to sleep (2) values
    Log To Console    CHECK VEHICLE REFUSE TO SLEEP SIGNAL: send CAN signal every 100ms
    #Check for refuse to sleep meaning
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep    1    ${ivc_wakeup_timeout}
    ${refuse_verdict}    ${comment} =    CANAKIN GET SEEK SIGNAL RESULT    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep
    Log To Console    refuse_verdict:${refuse_verdict}
    #Check for ready to sleep signal
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep    2    ${ivc_wakeup_timeout}
    ${ready_verdict}    ${comment} =    CANAKIN GET SEEK SIGNAL RESULT    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep
    Log To Console    ready_verdict:${ready_verdict}
    #final_verdict = OR between 2 intermediate verdicts
    ${final_verdict}    Set Variable    ${ready_verdict} or ${refuse_verdict}
    Log To Console    final_verdict:${final_verdict}
    #Stop reading CAN signals
    ${verdict}    ${comment} =    CANAKIN STOP READ    ${bus}
    Should Be True    ${final_verdict}   Failed to set CHECK VEHICLE REFUSE TO SLEEP SIGNAL to state {expected_state}

SIMULATE POWER RELAY OPEN TRIGGER
    [Documentation]    Simulating triggering conditions for the Trg_PowerRelayOpen_BLMS
    SEND VEHICLE STATE COMMAND    IgnitionLevel
    SEND VEHICLE CHARGE AVAILABILITY    charge_not_available
    SEND VEHICLE POWER RELAY STATUS    Opened

SIMULATE START OF JOURNEY TRIGGER
    [Documentation]    Simulating triggering conditions for the Trg_StartOfJourney
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    PowertrainRunning

SIMULATE END OF JOURNEY TRIGGER
    [Documentation]    Simulating triggering conditions for the Trg_EndOfJourney
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel

SIMULATE END OF MISSION TRIGGER
    [Documentation]    Simulating triggering conditions for the Trg_EndOfMission
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    CutoffPending

CONFIGURE BLMS DATA
    [Arguments]    ${profile_name}
    [Documentation]    Simulating signals related to the Battery Usage Monitoring service
    ${key} =   Set Variable    ${bumi_profiles[${profile_name}]}
    ${size} =    Get Length    ${key}
    FOR    ${index}    IN RANGE    ${size}
        ${verdict}    ${comment} =    Canakin Set Signal     ${key[${index}]["signal_name"]}    ${key[${index}]["signal_value"]}
        Should Be True    ${verdict}    Fail to Set Signal: ${comment}
        ${verdict}    ${comment} =    Canakin Start Write    elements=${key[${index}]["signal_name"]}
        Should Be True    ${verdict}    Fail to Canakin Start Write: ${comment}
    END

LAUNCH INITIAL SEQUENCE
    [Arguments]    ${sequence}
    [Documentation]    Based on the architecture, send the specific signals for periodic messages - platform shall be provided as a parameter of the TC
    ${verdict}    ${comment} =    Canakin Play Scenario    ${sequence}
    Should Contain    ${verdict}    OK
    Run Keyword If    "${sequence}" == "only_keep_ivc_on"    Set Suite Variable     ${ivc_can_only}    True
    SET APC ACC WITH SCENARIO    ${sequence}

LOAD CAN SCENARIOS

    IF    $trinity_bench
        Log To Console    Using Trinity configured CANAKIN GRPC server
    ELSE
        # TODO: Add configuration API calls
        FAIL    Configuration of CANAKIN GRPC server has not been implemented for non Trinity setups
    END

    ${verdict}    ${comment} =    Canakin Load Scenario   ${CURDIR}/vehicle_sequence.json
    Should Be True    ${verdict}

SEND VEHICLE HVAC STATE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    The [BCM Stub] / VEHICLE sends periodic CAN frames to the [IVC Platform] with the state of the HVAC.
    ...    == Parameters: ==
    ...    _value_: presoak_in_progress, presoak_forbidden, ..
    ...    == Expected Results: ==
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    VEHICLE    CAN
     ${presoak_value} =    Set Variable If    "${value}" == "presoak_forbidden"    0    "${value}" == "no_presoak_in_progress"    1
    ...    "${value}" == "presoak_in_progress"    2    "${value}" == "unavailable"    3
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/HVAC/Presoak/ActivationStatus    ${presoak_value}
    Should Be True    ${verdict}    Failed to set SET VEHICLE HVAC STATE to value ${presoak_value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/HVAC/Presoak/ActivationStatus
    Should Be True    ${verdict}    Failed to SET VEHICLE HVAC STATE

QUIT CAN TOOL
    [Documentation]    Ask Canakin to exit gracefully
    IF    $trinity_bench
#        Canakin Clear Listeners
         Log to console    QUIT CAN TOOL called
         IF    "${EE_architecture}" == "C1A-HS"
            ${verdict} =    Canakin Unsubscribe Can TCU Remote Order Request
            Should Be True    ${verdict}
        ELSE IF    "HSevo" in "'${EE_architecture}'"
            ${verdict} =    Canakin Unsubscribe Can SGW Remote Order Request
            Should Be True    ${verdict}
        END
    ELSE
        ${verdict}    ${comment} =    Canakin Reset Config
        Should Be True    ${verdict}    Quit can tool Error message: ${comment}
    END

STOP CAN
    [Documentation]     Stops ALL can frames on can0 bus
    ${verdict}    ${comment} =    Canakin Stop Write    elements=all
    Should Be True    ${verdict}    Stop Write error message: ${comment}
    IF    not $trinity_bench
        ${verdict}    ${comment} =    Canakin Stop Read    ${bus}
        Should Be True    ${verdict}    Stop Read error message: ${comment}
        ${verdict}    ${comment} =    Canakin Reset Config
        Should Be True    ${verdict}    Reset Config error message: ${comment}
    END

CONFIGURE VEHICLE NOTIFICATION CHARGE START
    [Documentation]    The [BCM Stub] sends periodic CAN frames to the [IVC Platform]
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CONFIGURE VEHICLE NOTIFICATION CHARGE START
    SEND VEHICLE CHARGE ALERT    1
    SEND VEHICLE CHARGE AVAILABILITY    charge_not_available
    SET PLUG CONNECTED    1
    SEND VEHICLE CHARGE STATUS    waiting_a_planned_charge
    SET BATTERY ENERGY LEVEL    48

CONFIGURE VEHICLE NOTIFICATION CHARGE STOP
    [Documentation]    The [BCM Stub] sends periodic CAN frames to the [IVC Platform]
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CONFIGURE VEHICLE NOTIFICATION CHARGE STOP
    SEND VEHICLE CHARGE ALERT    1
    SEND VEHICLE CHARGE AVAILABILITY    charge_available
    SEND VEHICLE CHARGE STATUS    charge_in_progress
    SET PLUG CONNECTED    2
    SET BATTERY ENERGY LEVEL    48

SEND VEHICLE CHARGE ALERT
    [Documentation]    The [BCM Stub] sends periodic CAN frames to the [IVC Platform]
    Log To Console    SEND VEHICLE CHARGE ALERT
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Charge/Alert     ${value}
    Should Be True    ${verdict}    Failed to set VEHICLE CHARGE ALERT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Charge/Alert
    Should Be True    ${verdict}    Failed to send VEHICLE CHARGE ALERT

SET ONBOARD PRESOAK PROGRAM STATUS
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    Send CAN message about presoak signal.
    ...    == Parameters: ==
    ...    - _state_: no_programmed, one_time_only, every_two_hours
    ...    == Expected Results: ==
    ...    Pass if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    VEHICLE    CAN
    ${pay_load} =    Set Variable If    "${state}" == "no_programmed"    00    "${state}" == "one_time_only"    40
    ...    "${state}" == "every_two_hours"    80
    ${verdict}    ${comment} =    Run Keyword If    "${EE_architecture}" == "T4VS_EV"
    ...    Canakin Write Hex    ${bus}    4E3    1    1    ${pay_load}    1000    600000
    Run Keyword If    "${EE_architecture}" == "T4VS_EV"
    ...    Should Be True    ${verdict}    Failed to SET ONBOARD PRESOAK PROGRAM STATUS
    Return From Keyword If    "${EE_architecture}" == "T4VS_EV"
    ${onboard_value} =    Set Variable If    "${state}" == "no_programmed"    0    "${state}" == "one_time_only"    1
    ...    "${state}" == "every_two_hours"    2
    ${verdict}    ${comment} =    Canakin Set Signal    RESPreSoak_ProgStatus    ${onboard_value}
    Should Be True    ${verdict}    Failed to set ONBOARD PRESOAK PROGRAM STATUS to value ${onboard_value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=RESPreSoak_ProgStatus
    Should Be True    ${verdict}    Failed to SET ONBOARD PRESOAK PROGRAM STATUS

CHECK VEHICLE REFUSE TO SLEEP COMMAND
    [Arguments]    ${expected_state}
    [Documentation]    == High Level Description: ==
    ...     Check the IVC send a refuse_to_sleep CAN signal to the  BCM stub.
    ...    == Parameters: ==
    ...    - _expected_state_: true (for tcu_refuse_to_sleep), false (for tcu_ready_to_sleep).
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    VEHICLE    CAN
    ${command_value} =   Set Variable If    "${expected_state}".lower() == "true"    1    "${expected_state}".lower() == "false"    2
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep    ${command_value}    ${remote_request_timeout}
    Should Be True    ${verdict}    Fail to CHECK VEHICLE REFUSE TO SLEEP COMMAND: with ${comment}
    ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}    Vehicle/Sent/SleepManagement/RefuseToSleep
    Should Be True    ${verdict}    Fail to CHECK VEHICLE REFUSE TO SLEEP COMMAND: with ${comment}

SET PROGRAMMED CHARGE STATUS
    [Arguments]    ${mode}
    [Documentation]    == High Level Description: ==
    ...    The [BCM Stub] sends periodic CAN frames to the [IVI Platform] with the programmed charge status mode.
    ...    == Parameters: ==
    ...    _mode_: always, delayed, scheduled
    ...    == Expected Results: ==
    ...    PASS if executed
    [Tags]    Automated    VEHICLE    CAN
    ${programmed_charge_status} =    Set Variable If    "${mode}" == "always"    0    "${mode}" == "delayed"    1    "${mode}" == "scheduled"    2
    ${verdict}    ${comment} =    Canakin Set Signal    ProgrammedChargeStatus    ${programmed_charge_status}
    Should Be True    ${verdict}    Failed to SET PROGRAMMED CHARGE STATUS to value ${programmed_charge_status}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ProgrammedChargeStatus
    Should Be True    ${verdict}    Failed to SET PROGRAMMED CHARGE STATUS with ${comment}

CHECK VEHICLE RECEIVES RCSS DATA
    [Arguments]    ${data}
    [Documentation]    == High Level Description: ==
    ...    Checks if {data} is sent from the IVI Platform to the BCM Stub properly
    ...    == Parameters: ==
    ...    _data_ : always, delayed, ...
    ...    == Expected Results: ==
    ...    Pass if remote order content is as expected
    [Tags]    Automated    VEHICLE    CAN
    ${key} =   Set Variable    ${calendars_can_frames['${data}']}
    ${size} =    Get Length    ${key}
    FOR    ${index}    IN RANGE    ${size}
        ${verdict}    ${comment} =    Run Keyword If    "${data}" == "schedule_one_calendar"    SEARCH AND RETRIEVE SIGNAL    ${key[${index}]["signal_name"]}
        ...    ${key[${index}]["signal_value"]}
        ...    ELSE IF    "${data}" == "delayed"    SEARCH AND RETRIEVE SIGNAL    ${key[${index}]["signal_name"]}    ${delay_value}
        Should Be True    ${verdict}    Failed to CHECK VEHICLE RECEIVES RCSS DATA ${key[${index}]["signal_name"]} with ${comment}
    END

CHECK THE NUMBER OF CONSECUTIVE FRAMES SENT
    [Arguments]    ${byte_value}    ${position}    ${expected_value}
    [Documentation]    == High Level Description: ==
    ...    Checks how many times a signal is transmitted with a certain value
    ...    == Parameters: ==
    ...    _byte_value_: the current byte value sent on the CAN bus for the expected frame
    ...    _position_: represents the signals's bit position inside the byte
    ...    _expected_value_: represents the expected value for the signal
    ...    == Expected Results: ==
    ...    Pass/Failed
    [Tags]    Automated    VEHICLE    CAN
    ${result} =    Convert To Binary    ${byte_value}    base=16    length=8
    @{characters} =    Split String To Characters    ${result}
    ${bit_position} =    Evaluate    7 - ${position}
    Run Keyword If    '${characters}[${bit_position}]' == '${expected_value}'    Set Suite Variable     ${consecutive_frames_counter}    ${consecutive_frames_counter + 1}

CHECK FRAMES ORDER RECEIVED
    [Arguments]    ${signal_name}    ${first_value}    ${second_frame_id}    ${second_value}
    [Documentation]    == High Level Description: ==
    ...    Checks in file if given signals are found with the defined values
    ...    == Parameters: ==
    ...    - _signal_name_: signal name checked
    ...    - _first_value_: expected byte value for the first frame checked
    ...    - _second_frame_id_: id for the second frame to be checked
    ...    - _second_value_: expected byte value for the second frame checked
    ...    == Expected Results: ==
    ...    Pass/Fail
    [Tags]    Automated    VEHICLE    CAN
    ${File} =    Get File    ${file_path}
    ${index}    ${frame_id}    ${no_expected_frames} =    Run Keyword If    "${signal_name}" == "ChargeDelayedRequest" or "${signal_name}" == "ChargeAlwaysRequest" or "${signal_name}" == "ChargeCalAllChange_MMI" or "${signal_name}" == "PreSoakCalAllChange_MMI"
    ...     Set Variable    ${calendars_can_frames['${signal_name}'][0]["byte_position"]}    ${calendars_can_frames['${signal_name}'][0]["frame_id"]}    ${calendars_can_frames['${signal_name}'][0]["expected_frames"]}
    ...    ELSE    Fail    Wrong signal name provided
    ${byte_position} =    Evaluate    ${index} + ${offset}
    ${list_of_flags} =    Create List
    @{list} =    Split To Lines    ${File}
    FOR    ${line}    IN    @{list}
        @{list_of_line_elements} =    Split String    ${line}
        ${BCM_signal_byte_sent} =    Set Variable If    "${frame_id}" in "${line}"    ${list_of_line_elements[${byte_position}]}
        Run Keyword If    "${frame_id}" in "${line}"    CHECK THE NUMBER OF CONSECUTIVE FRAMES SENT    ${BCM_signal_byte_sent}    ${calendars_can_frames['${signal_name}'][0]["bit_position"]}    ${calendars_can_frames['${signal_name}'][0]["signal_value"]}
        Run Keyword If    "${frame_id}" in "${line}" and "${first_value}" == "${BCM_signal_byte_sent}"    Append To List    ${list_of_flags}    1
        ...    ELSE    Append To List    ${list_of_flags}    0
        ${second_value_position} =    Run Keyword If    "1" in "${list_of_flags}" and "${FRAME_IDS['${second_frame_id}']['${EE_architecture}']['frame_id']}" in "${line}"
        ...    Set Variable    ${list_of_line_elements[6]}
        Run Keyword If    "1" in "${list_of_flags}" and "${FRAME_IDS['${second_frame_id}']['${EE_architecture}']['frame_id']}" in "${line}" and ${consecutive_frames_counter} == 1
        ...    Should Be Equal    ${second_value}    ${second_value_position}
        ${result} =    Set Variable if    "1" in "${list_of_flags}" and "${FRAME_IDS['${second_frame_id}']['${EE_architecture}']['frame_id']}" in "${line}"    ${TRUE}    ${FALSE}
        Exit For Loop IF    ${result} == ${TRUE} and "${consecutive_frames_counter}" >= "${no_expected_frames}"
    END
    Should be true    "${consecutive_frames_counter}" >= "${no_expected_frames}"    Failed because IVI is expected to send to the BCM at least: ${no_expected_frames} consecutive frames but were found: ${consecutive_frames_counter}
    Should be true    ${result}    FAILED because given signals have values different than expected

CHECK VEHICLE RECEIVES RHVS DATA
    [Arguments]    ${data}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...     Checks if {data} is sent from the IVI Platform to the BCM Stub
    ...    == Parameters: ==
    ...    - _data_: different CAN messages sent by the [IVI Platform]
    ...    == Expected Results: ==
    ...    Pass if IVI Platform manages to send {data} correctly to the BCM Stub
    [Tags]    Automated    VEHICLE    CAN

    ${key} =   Set Variable    ${calendars_can_frames['${data}']}
    ${size} =    Get Length    ${key}
    FOR    ${index}    IN RANGE    ${size}
        ${verdict}    ${comment} =        SEARCH AND RETRIEVE SIGNAL    ${key[${index}]["signal_name"]}    ${key[${index}]["signal_value"]}
        Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to Get Seek Signal Result for ${key[${index}]["signal_name"]} with ${comment}
        ...    ELSE    Should Be True    ${verdict}    Fail to Get Seek Signal Result for ${key[${index}]["signal_name"]} with ${comment}
    END

CHECK SIGNAL VALUE
    [Arguments]    ${signal_name}    ${signal_value}
    [Documentation]    == High Level Description: ==
    ...    Checks if a certain signal is transmitted with a certain value on the CAN bus
    ...    == Parameters: ==
    ...    _signal_name_: functional name/signal name to be monitored
    ...    _signal_value_: expected value to be checked
    ...    == Expected Results: ==
    ...    Pass/Failed
    ${verdict}    ${comment} =    SEARCH AND RETRIEVE SIGNAL    ${signal_name}    ${signal_value}
    Should Be True    ${verdict}    Failed to Seek Signal Canakin for CHECK SIGNAL VALUE with ${comment}

SEARCH AND RETRIEVE SIGNAL
    [Arguments]    ${signal_name}    ${signal_value}
    [Documentation]    == High Level Description: ==
    ...    Retrieves the signal value from bus when it is transmitted
    ...    == Parameters: ==
    ...    _signal_name_: functional name/signal name to be monitored
    ...    _signal_value_: expected value to be transmitted
    ...    == Expected Results: ==
    ...    Pass/Fail
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    ${signal_name}    ${signal_value}    ${remote_request_timeout}
    Should Be True    ${verdict}    Fail to Seek Signal Canakin for ${signal_name} with ${comment}
    ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}     ${signal_name}
    [Return]    ${verdict}    ${comment}

START RECORD
    [Documentation]    == High Level Description: ==
    ...    Starts the can frames recording in a specific file
    ...    == Parameters: ==
    ...    - _None_
    ...    == Expected Results: ==
    ...    Pass/Fail
    Run Keyword and Ignore Error    Remove Directory    ${EXECDIR}/slcan_record    recursive=True
    @{buses} =    Create list    ${bus}
    ${verdict}    ${comment} =    Canakin Start Record    ${buses}   ${EXECDIR}/slcan_record    0
    ${extract_path} =    Fetch From Right    ${comment}    into${SPACE}file${SPACE}
    Set Suite Variable     ${file_path}    ${extract_path}

STOP RECORD
    [Arguments]    ${wait_duration}
    [Documentation]    == High Level Description: ==
    ...    Stops the can frames recording
    ...    == Parameters: ==
    ...    - _wait_duration_: waiting time in order to have enough data recorded in the candump file
    ...    == Expected Results: ==
    ...    Pass/Fail
    Sleep    ${wait_duration}
    ${verdict}    ${comment} =    Canakin Stop Record

CONFIGURE ENGINE OFF CUSTOMER NOT PRESENT IVC WAKEUP
    [Documentation]    Configuration for vehicle engine off, customer not present, ivc wakeup
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CONFIGURE ENGINE OFF CUSTOMER NOT PRESENT IVC WAKEUP: send CAN signal every 100ms
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    CONFIGURE CAN FOR OUTSIDE LOCK STATE    False

CONFIGURE ENGINE OFF CUSTOMER LEAVE
    [Documentation]    Configuration for vehicle engine off and customer leave
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    Off
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    False

CONFIGURE ENGINE ON CUSTOMER PRESENCE
    [Documentation]    Configuration for vehicle engine on and customer is present
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE SWITCH POSITION COMMAND    On
    SEND VEHICLE STATE COMMAND    PowertrainRunning
    SEND VEHICLE LOCK_STATUS COMMAND    unlocked
    SEND VEHICLE CUSTOMER PRESENCE COMMAND    True

SEND VEHICLE SWITCH POSITION COMMAND
    [Arguments]    ${state}
    ${mode} =    Set Variable If    "${state}" == "Off"    0    "${state}" == "On"    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Ignition/SwitchPosition    ${mode}
    should_be_true    ${verdict}    Fail to Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Ignition/SwitchPosition
    should_be_true    ${verdict}    Fail to Start Write Canakin Fail to SEND VEHICLE SWITCH POSITION COMMAND: ${comment}

START SEARCH SIGNAL
    [Arguments]    ${data}
    [Documentation]    == High Level Description: ==
    ...     Search signal on can when no vnext request it's triggering it
    ...    == Parameters: ==
    ...    - _data_: profile name
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    VEHICLE    CAN
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    ${calendars_can_frames["${data}"][0]["signal_name"]}
    ...    ${calendars_can_frames['${data}'][0]["signal_value"]}    ${remote_request_timeout}
    [Return]    ${verdict}    ${comment}

RETRIEVE SIGNAL
    [Arguments]    ${data}
    [Documentation]    == High Level Description: ==
    ...     Retrieve signal value from can when no vnext request it's triggering the action
    ...    == Parameters: ==
    ...    - _data_: profile name
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    VEHICLE    CAN
    ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}     ${calendars_can_frames['${data}'][0]["signal_name"]}
    [Return]    ${verdict}    ${comment}

SEND VEHICLE DRIVER MASSAGE INTENSITY STATE
    [Arguments]    ${bus}    ${signal_name}    ${signal_value}
    [Documentation]    Send a CAN message and ensure it changed the state of a UI element
    ...    ${bus}: can bus ID
    ...    ${signal_name}: can signal name
    ...    ${signal_value}: can signal value
    SEND CAN MESSAGE    ${bus}    ${signal_name}    ${signal_value}

CHECK ADASIS CAN MESSAGE
    [Documentation]    Check ADASIS wifi message received in host_pc
    Log To Console    Check ADASIS wifi message received in host_pc
    ${verdict}    ${comment} =    CANAKIN SEEK SIGNAL    ${bus}    OSPDataType    META-DATA    100    ${True}
    ${signal_res_verdict}    ${comment} =    CANAKIN GET SEEK SIGNAL RESULT    ${bus}    OSPDataType
    Should Be True    ${signal_res_verdict}    Short range ADASIS Wi-Fi message has not been received in host_pc: ${comment}

CHECK VEHICLE DATE VALUE
    [Arguments]    ${bus}    ${signal_name}    ${signal_value}
    [Documentation]    Verify that the IVI sent to ECUs the date as actual value
    ...    ${bus}: CAN bus ID
    ...    ${signal_name}: CAN signal name
    ...    ${signal_value}: CAN signal value
    ${verdict}    ${comment} =    CANAKIN SEEK SIGNAL    ${bus}    ${signal_name}    ${signal_value}    ${timeout}
    Should Be True    ${verdict}    Error message: ${comment}
    ${verdict}    ${comment} =    CANAKIN GET SEEK SIGNAL RESULT    ${bus}    ${signal_name}
    Should Be True    ${verdict}    Error message: ${comment}

STOP CAN WRITING
    [Documentation]     Stops the writing of all can frames on can0 bus
    ${verdict}    ${comment} =    Canakin Stop Write    elements=all
    Should Be True    ${verdict}    Stop Write error message: ${comment}
    ${verdict}    ${comment} =    Canakin Reset All Signals
    Should Be True    ${verdict}    Reset All Signals error message: ${comment}

CHECK SEAT DRIVER MASSAGE INTENSITY
    [Arguments]    ${property_name}    ${intensity_val}
    [Documentation]    To verify the driver massage intensity state on IVI
    ...    ${property_name}: property name of the seat massage intensity
    ...    ${intensity_val}: massage intensity value to be checked
    SLEEP    ${timeout}
    ${status}    ${value} =    CHECK DRIVER SEAT MASSAGE INTENSITY VALUE    ${property_name}
    should be equal    ${intensity_val}    ${value}

CHECK HMI DRIVER MASSAGE INTENSITY STATE
    [Arguments]    ${expected_intensity_value}
    [Documentation]    Verify the the driver massage intesity state in kithchen sink App
    ...    ${expected_intensity_value}: Expected massage intensity value
    HMI DRIVER MASSAGE INTENSITY STATE    ${expected_intensity_value}

CAN ACTIVATION & START DEVICE
    [Documentation]     This KW is used to start a testcase (init & Send can frame)
    LOAD CAN SCENARIOS
    SEND CAN FRAME    ${startup_sequence}

CAN ACTIVATION & START DEVICE WITH ARGUMENTS
    [Arguments]     ${EE_architecture}
    [Documentation]     This KW is used to start a testcase (init & Send can frame)
    LOAD CAN SCENARIOS
    SEND CAN FRAME    ${startup_sequence}

SEND CAN FRAME
    [Arguments]     ${file_to_send}
    [Documentation]    starts sending the sequence contained on can

    ${verdict}    ${comment} =    Canakin Play Scenario    ${file_to_send}
    Should Contain    ${verdict}    OK
    SET APC ACC WITH SCENARIO    ${file_to_send}

SEND AND CHECK CAN FRAME
    [Arguments]     ${file_to_send}    ${signal_name}     ${can_bus}    ${state}    ${timeout}
    [Documentation]     Starts sending the sequence contained on can and
    ...    checks the value of a signal on a given bus
    ...    ${file_to_send}: the file to send on CAN bus
    ...    ${signal_name}: Signal name to look for
    ...    ${can_bus}: can bus
    ...    ${state}: expected state (eg:MMI-ON)
    ...    ${timeout}: timeout (int)
    Run Keyword if    "${console_logs}" == "yes"     Log to Console    Sending ${file_to_send}
    SEND CAN FRAME    ${file_to_send}
    Sleep     1
    VERIFY CAN FRAME VALUE    ${signal_name}    ${can_bus}    ${state}    ${timeout}

CAN DEACTIVATION & STOP DEVICE
    [Documentation]     This KW is used to stop a testcase (Send final can frame & quit canakin)
    SEND CAN FRAME    ${final_can_sequence}
    STOP CAN WRITING
    Sleep    50
    QUIT CAN TOOL

ACTIVATE DTC
    [Documentation]    This KW will set GADE_v2 to 1 to activate AutoACC DTCs
    ${verdict}    ${comment} =    Canakin Set Signal    GADE_v2    0x02
    should_be_true    ${verdict}    Fail to Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=GADE_v2
    should_be_true    ${verdict}    Fail to Start Write Canakin Fail to CONFIGURE CAN to activate AutoACC DTCs: ${comment}

DEACTIVATE DTC
    [Documentation]    This KW will set GADE_v2 to 0 to deactivate AutoACC DTCs
    ${verdict}    ${comment} =    Canakin Set Signal    GADE_v2    0x00
    should_be_true    ${verdict}    Fail to Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=GADE_v2
    should_be_true    ${verdict}    Fail to Start Write Canakin Fail to CONFIGURE CAN to deactivate AutoACC DTCs: ${comment}

START CAN MESSAGE
    [Arguments]    ${bus}    ${signal_name}    ${signal_value}
    [Documentation]    Send a CAN message in loop ensure it changed the state of a UI element
    ${verdict}    ${comment} =    Canakin Set Signal    ${signal_name}    ${signal_value}
    Should Be True    ${verdict}    Failed to set signal ${signal_name} with the value=${signal_value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=${signal_name}
    Should Be True    ${verdict}    Failed to send the can frame which contains the signal ${signal_name}
    IF    'VehicleStates' in '${signal_name}'
        SET APC ACC WITH VEHICLESTATES    ${signal_value}
        Set Suite Variable     ${vehicle_states_can_signal}    ${signal_value}
    END

CHECK VEHICLE SIGNAL
    [Arguments]    ${signal_name}    ${meaning_expected_value}    ${TC_folder}=${EMPTY}    ${timeout}=100
    [Documentation]    Check on Vehicle CAN Network if the Frame that contains ${signal_name} signal is present and
    ...    value is equal to meaning value ${meaning_expected_value}
    ...    ${signal_name}: Name of signal
    ...    ${meaning_expected_value}: Expected meaning value of the signal
    ${verdict}    ${comment} =    CANAKIN START READ    ${bus}
    Log To Console    Check on Vehicle CAN Network if the Frame that contains ${signal_name} signal is present and value is equal to meaning value ${meaning_expected_value}
    ${verdict}    ${comment} =    CANAKIN SEEK SIGNAL    ${bus}    ${signal_name}    ${meaning_expected_value}    ${timeout}    ${True}
    ${signal_res_verdict}    ${signal_res_comment} =    CANAKIN GET SEEK SIGNAL RESULT    ${bus}    ${signal_name}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${signal_res_verdict}    ${signal_res_comment}
    ...    ELSE    Should Be True    ${signal_res_verdict}    ${signal_res_comment}

SEND VEHICLE CLIMBLOWERLEVELDISPLAY SIGNAL
    [Arguments]    ${meaning}
    [Documentation]    Send can message in loop about 'ClimBlowerLevelDisplay' $meaning} value
    Log To Console    Send can message in loop about 'ClimBlowerLevelDisplay' ${meaning} value
    START CAN MESSAGE    ${bus}    ClimBlowerLevelDisplay    ${meaning}

SEND VEHICLE CPDISPLAYAVAILABILITY SIGNAL
    [Arguments]    ${display_value}
    [Documentation]    Send can message in periodically 'CPdisplayAvailability' ${display_value}
    ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CPdisplayAvailability    ${display_value}
    Should Be True    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CPdisplayAvailability
    Should Be True    ${verdict}    Fail to Start Write: ${comment}
    DO WAIT    5000

SEND VEHICLE IVI ONOFF TRANSITION SEQUENCE
    [Arguments]     ${onoff_transition_number}
    [Documentation]    Starts sending the sequence contained on can
    SEND CAN FRAME    ${onoff_transition_number}

SEND CAN MESSAGE
    [Arguments]    ${bus}    ${signal_name}    ${signal_value}
    [Documentation]    Send a CAN message and ensure it changed the state of a UI element
    ${verdict}    ${comment} =    Canakin Set Signal    ${signal_name}    ${signal_value}
    Should Be True    ${verdict}    Failed to set signal ${signal_name} with the value=${signal_value}
    ${verdict}    ${comment} =    Canakin Write    msg_name=${signal_name}
    Should Be True    ${verdict}    Failed to send the can frame which contains the signal ${signal_name}

STOP CAN MESSAGE
    [Arguments]    ${signal_name}
    [Documentation]    Stop writing a specific CAN message
    ${verdict}    ${comment} =    Canakin Stop Write    elements=${signal_name}
    Should Be True    ${verdict}    Stop Write error message: ${comment}

SEND CRASH ORDER
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Crash/CrashOrder    ${value}
    should_be_true    ${verdict}    Failed to set CRASH ORDER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Crash/CrashOrder
    should_be_true    ${verdict}    Failed to set CRASH ORDER

SEND CRASH DETECTED
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Crash/Detected    ${value}
    should_be_true    ${verdict}    Failed to set CRASH ORDER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Crash/Detected
    should_be_true    ${verdict}    Failed to set CRASH ORDER

CHECK CENTRAL DISPLAY ACTIVATION
    [Arguments]    ${value}=activation
    [Documentation]    Check the display activation / deactivation signal on a central display
    ...    (used to check the display is not frozen/black)
    # check display activation / deactivation on canM bus
    Run Keyword If    "${value}" == "activation"    VERIFY CAN FRAME VALUE    DisplayActivation    ${bus_m}    1    30
    ...    ELSE IF    "${value}" == "DO_NOT_CHECK"    VERIFY CAN FRAME VALUE    DisplayActivation    ${bus_m}    DO_NOT_CHECK    30
    ...    ELSE    VERIFY CAN FRAME VALUE    DisplayActivation    ${bus_m}    0    30

DO SEND ICARDPRESENCE DURING
    [Arguments]    ${duration}    ${signal}
    [Documentation]    == High Level Description: ==
    ...    Send a CAN signal periodically to set IkeyCardPresence
    ...    == Parameters: ==
    ...    - _duration_: an int followed by string "sec" representing the duration expected for the retry strategy
    ...    - _signal_: signal to be sent on CAN bus
    ${time_value} =    Strip String    ${duration}    mode=right
    Repeat Keyword    ${time_value}    SEND VEHICLE IKEY_PRESENCE COMMAND    ${signal}

SEND VEHICLE VOLUME
    [Arguments]    ${volume_status}    ${CP_present}=False
    [Documentation]    Increase / decrease the volume, only if not using CentralPanel as this KW is in conflict with CP frames
    ...    ${volume_status}   up / down
    ...    ${CP_present}    True / False. A CentralPanel is connected to the bench
    IF    "${CP_present}" == "False"
        Log To Console    SEND VEHICLE VOLUME on IVI volume_status: ${volume_status}
        ${button} =    Set Variable If    "${volume_status}" == "up"    Button 2 pressed    Button 3 pressed
        ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CPdisplayAvailability    CentralPanel ready to display
        Should Be True    ${verdict}    Fail Set Signal: ${comment}
        ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CentralPanelMMSwitch    All Button released / Not available
        Should Be True    ${verdict}    Fail Set Signal: ${comment}
        ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CentralPanelMMSwitch    ${button}
        Should Be True    ${verdict}    Fail Set Signal: ${comment}
        DO WAIT    500
        ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CentralPanelMMSwitch    All Button released / Not available
        Should Be True    ${verdict}    Fail Set Signal: ${comment}
    ELSE    
        Log To Console    SEND VEHICLE VOLUME KW is not compatible with a CentralPanel. Please use SWRC instead.
    END

SIMULATE START OF MISSION TRIGGER
    [Documentation]    Simulating triggering conditions for the Trg_StartOfMission
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Full Wake-Up Mode
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel

GET CANDUMP FILE NAME
    [Arguments]    ${slcan_type}=slcan0
    [Documentation]    Retrieves the exact file name
    ${file_name} =    Set Variable If    "${slcan_type}" == "slcan0"    ${candump_name_slcan0}    ${candump_name_slcan1}
    [Return]    ${file_name}

CLEAR CANDUMP FILE CONTENTS
    [Arguments]    ${slcan_type}=slcan0
    [Documentation]    Clears the contents of the candump file so that the thread started can add only the
    ...    current iteration data
    rfw_libraries.tools.ziplogfile.ZIPLog.clear_candump_file_contents    ${slcan_type}

SEND AIR QUALITY OUTSIDE SIGNALS
    [Documentation]    To send periodic frames of air quality external signals
    @{display_values} =    Create List    5    10    15    5    10   15    5    10    15    5    10
    FOR    ${display_value}    IN    @{display_values}
        SEND AIRQUALITY OUTSIDE SIGNAL    ${display_value}
        DO WAIT    5000
    END

SEND AIR QUALITY INCOMING SIGNALS
    [Documentation]    To send periodic frames of air quality incoming signals
    @{display_values} =    Create List    5    10    15    5    10   15    5    10    15    5    10
    FOR    ${display_value}    IN    @{display_values}
        SEND AIRQUALITY INCOMING SIGNAL    ${display_value}
        DO WAIT    5000
    END

SEND AIRQUALITY INCOMING SIGNAL
    [Arguments]    ${display_value}
    ${verdict}    ${comment} =    Canakin Set Signal    ClimCabinParticleConcDisplay    ${display_value}
    Should Be True    ${verdict}    Failed to SET ClimCabinParticleConcDisplay
    ${verdict}    ${comment} =    Canakin Start Write    elements=ClimCabinParticleConcDisplay
    Should Be True    ${verdict}    Failed to ClimCabinParticleConcDisplay with ${comment}

SEND AIRQUALITY OUTSIDE SIGNAL
    [Arguments]    ${display_value}
    ${verdict}    ${comment} =    Canakin Set Signal    ClimExternParticleConcDisplay    ${display_value}
    Should Be True    ${verdict}    Failed to SET ClimExternParticleConcDisplay
    ${verdict}    ${comment} =    Canakin Start Write    elements=ClimExternParticleConcDisplay
    Should Be True    ${verdict}    Failed to ClimExternParticleConcDisplay with ${comment}

CONFIGURE TRIP DATA
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CONFIGURE TRIP DATA
    CONFIGURE CAN FOR DELIVERY MODE    Customer_mode
    SEND DISTANCE TOTALIZER    100
    SET BATTERY SOC ENERGY LEVEL    69
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    open
    SEND WINDOWS POSITION    RearRight    2
    SEND WINDOWS POSITION    FrontLeft    3
    SEND WINDOWS POSITION    FrontRight    2
    SEND WINDOWS POSITION    RearLeft    3
    SEND VEHICLE BRAKE PARKING STATUS COMMAND    2
    SEND GEAR BOX AUTO LEVER POSITION    2
    SET BATTERY SOC 14V ENERGY LEVEL    69
    SET SUNROOF POSITION    3
    CONFIGURE CAN FOR OUTSIDE LOCK STATE    True

SEND VEHICLE BRAKE PARKING STATUS COMMAND
    [Arguments]    ${value}
    Log To Console    SEND VEHICLE BRAKE PARKING STATUS COMMAND
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Brake/Parking    ${value}
    Should Be True    ${verdict}    Failed to set BRAKE PARKING STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Brake/Parking
    Should Be True    ${verdict}    Failed to send BRAKE PARKING STATUS

SEND WINDOWS POSITION
    [Arguments]    ${window}    ${value}
    Log To Console    SEND WINDOWS POSITION
    ${window_position} =    Set Variable If    "${window}" == "FrontLeft"    ${value}    "${window}" == "FrontRight"    ${value}    "${window}" == "RearRight"    ${value}    "${window}" == "RearLeft"    ${value}    "${window}" == "Sunroof"    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Windows/${window}/Position    ${value}
    Should Be True    ${verdict}    Failed to set SEND WINDOWS POSITION to value ${value}
    ${window_position} =    Set Variable If    "${window}" == "FrontLeft"    ${value}    "${window}" == "FrontRight"    ${value}    "${window}" == "RearRight"    ${value}    "${window}" == "RearLeft"    ${value}    "${window}" == "Sunroof"    ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Windows/${window}/Position
    Should Be True    ${verdict}    Failed to send SEND WINDOWS POSITION

SET SUNROOF POSITION
    [Arguments]    ${value}
    Log To Console    SET SUNROOF POSITION
    ${verdict}    ${comment} =    Canakin Set Signal    SRU_Position    ${value}
    Should Be True    ${verdict}    Failed to set SUNROOF POSITION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=SRU_Position
    Should Be True    ${verdict}    Failed to send SET SUNROOF POSITION

SEND GEAR BOX AUTO LEVER POSITION
    [Arguments]    ${value}
    Log To Console    SEND GEAR BOX AUTO LEVER POSITION
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/GearBox/Auto/LeverPosition    ${value}
    Should Be True    ${verdict}    Failed to set GEAR BOX AUTO LEVER POSITION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/GearBox/Auto/LeverPosition
    Should Be True    ${verdict}    Failed to send GEAR BOX AUTO LEVER POSITION

SET BATTERY SOC ENERGY LEVEL
    [Arguments]    ${value}
    Log To Console    SET BATTERY SOC ENERGY LEVEL
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/HVBattery/Status/BatterySOC    ${value}
    Should Be True    ${verdict}    Failed to set BATTERY SOC ENERGY LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/HVBattery/Status/BatterySOC
    Should Be True    ${verdict}    Failed to send SOC BATTERY ENERGY LEVEL

SET BATTERY SOC 14V ENERGY LEVEL
    [Arguments]    ${value}
    Log To Console    SET BATTERY SOC 14V ENERGY LEVEL
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/EEM/SOCBattery14V    ${value}
    Should Be True    ${verdict}    Failed to set BATTERY SOC 14V ENERGY LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/EEM/SOCBattery14V
    Should Be True    ${verdict}    Failed to send SOC 14V BATTERY ENERGY LEVEL

SIMULATE A 14DAYS PERIODIC WAKEUP FOR BATTERYCHECK
    [Documentation]    Stimulate 14 days periodic wakeup on ivc
    SEND VEHICLE WAKEUP COMMAND
    SEND VEHICLE WAKEUP_TYPE COMMAND    Selective Wake-Up Mode 1
    CONFIGURE CAN FOR DELIVERY MODE    delivery_mode_1
    SEND DISTANCE TOTALIZER    100

SEND TPMS CAN SIGNALS
    [Documentation]    To send TPMS CAN SIGNALS
    SEND CAN MESSAGE    ${bus}    TPW_Status     0b01
    DO WAIT    2000
    SEND CAN MESSAGE    ${bus}    TPMS_AutoLocStatus    0b00
    DO WAIT    2000
    SEND CAN MESSAGE    ${bus}    WheelStateFL    0b100
    DO WAIT    2000
    SEND CAN MESSAGE    ${bus}    WheelStateFR    0b100
    DO WAIT    2000
    SEND CAN MESSAGE    ${bus}    WheelStateRL    0b100
    DO WAIT    2000
    SEND CAN MESSAGE    ${bus}    WheelStateRR    0b100
    DO WAIT    2000

SEND UNIT SYNCHRONIZATION DISPLAY SIGNALS
    [Documentation]    To send unit synchronization display signals
    START CAN MESSAGE    ${bus}    TripDistance     0b00
    START CAN MESSAGE    ${bus}    TripUnitDistance     0
    START CAN MESSAGE    ${bus}    TripAverageSpeed     20
    START CAN MESSAGE    ${bus}    TripDistance     409

SEND MINIMUM CHARGING SIGNAL
    SEND CAN MESSAGE    ${bus}    HVB_MaxCapacity_HEVC_v2    52
    DO WAIT    2000
    SEND AVAILABLE ENERGY HEVC    26

SEND AVAILABLE ENERGY HEVC
    [Arguments]    ${value}
    [Documentation]    Simulating signals related to the AvailableEnergy_HEVC service
    ${verdict}    ${comment} =    Canakin Set Signal    AvailableEnergy_HEVC    ${value}
    Should Be True    ${verdict}    Failed to SET AvailableEnergy_HEVC
    ${verdict}    ${comment} =    Canakin Start Write    elements=AvailableEnergy_HEVC
    Should Be True    ${verdict}    Failed to send AvailableEnergy_HEVC with ${comment}

SEND VEHICLE STANDBY CAN MESSAGE
    [Documentation]    Send can-m signals for device stand-by
    Log To Console    Send can-m signals for device stand-by
    ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CPdisplayAvailability    CentralPanel ready to display
    Should Be True    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CPdisplayAvailability
    Should Be True    ${verdict}    Fail to Start Write: ${comment}

    ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CentralPanelMMSwitch    Button 1 pressed
    Should Be True    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CentralPanelMMSwitch
    Should Be True    ${verdict}    Fail to Start Write: ${comment}
    DO WAIT    1000

    ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CentralPanelMMSwitch    All Button released / Not available
    Should Be True    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CentralPanelMMSwitch
    Should Be True    ${verdict}    Fail to Start Write: ${comment}
    DO WAIT    1000
    ${verdict}    ${comment} =    CANAKIN SET SIGNAL    CPdisplayAvailability    CentralPanel not ready to display / Not available
    Should Be True    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CPdisplayAvailability
    Should Be True    ${verdict}    Fail to Start Write: ${comment}

SET VEHICLE DISTANCE WARNING
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/SCR/Distance/FinalWarning    ${value}
    should_be_true    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/SCR/Distance/FinalWarning
    should_be_true    ${verdict}    Fail to Start Write bus Fail CONFIGURE CAN FOR ENGINE: ${comment}

SEND FUEL LOW LEVEL
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Fuel/LowLevel    ${value}
    should_be_true    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Fuel/LowLevel
    should_be_true    ${verdict}    Fail to Start Write bus Fail CONFIGURE CAN FOR ENGINE: ${comment}

SEND BADGE BATTERY LEVEL
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    IKey/Received/Badge/LowBatteryAlert    ${value}
    should_be_true    ${verdict}    Fail Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=IKey/Received/Badge/LowBatteryAlert
    should_be_true    ${verdict}    Fail to Start Write bus Fail CONFIGURE CAN FOR ENGINE: ${comment}

SEND VEHICLE ENGINE FAILURE LEVEL1
    [Documentation]    send vehicle engine level 1
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/Failure/Level1    ${value}
    Should Be True    ${verdict}    Failed to send vehicle engine level 1 to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/Failure/Level1
    Should Be True    ${verdict}    Fail to Start Write bus Fail CONFIGURE CAN FOR ENGINE: ${comment}

SET PASSENGER AIR BAG INHIBITION
    [Documentation]    Simulate passenger air bag inhibition
    [Arguments]    ${value}
    Log To Console    SET PASSENGER AIR BAG INHIBITION
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Crash/Airbag/PassengerInhibition    ${value}
    Should Be True    ${verdict}    Failed to set Passenger air bag inhibition to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Crash/Airbag/PassengerInhibition
    Should Be True    ${verdict}    Failed to send Passenger air bag inhibition

SET WHEEL FRONT LEFT STATE
    [Documentation]    Simulate front left wheel state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/State/FrontLeft    ${value}
    Should Be True    ${verdict}    Failed to set Front Left Wheel State to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/State/FrontLeft
    Should Be True    ${verdict}    Failed to send Front Left Wheel State

SET WHEEL FRONT RIGHT STATE
    [Documentation]    Simulate front right wheel state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/State/FrontRight    ${value}
    Should Be True    ${verdict}    Failed to set Front Right Wheel State to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/State/FrontRight
    Should Be True    ${verdict}    Failed to send Front Right Wheel State

SET WHEEL REAR RIGHT STATE
    [Documentation]    Simulate rear right wheel state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/State/RearRight    ${value}
    Should Be True    ${verdict}    Failed to set Rear Right Wheel State to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/State/RearRight
    Should Be True    ${verdict}    Failed to send Rear Right Wheel State

SET WHEEL REAR LEFT STATE
    [Documentation]    Simulate rear left wheel state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/State/RearLeft   ${value}
    Should Be True    ${verdict}    Failed to set Rear Right Wheel State to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/State/RearLeft
    Should Be True    ${verdict}    Failed to send Rear left Wheel State

SET ABS MALFUNCTION
    [Documentation]    Simulate ABS Malfunction state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/ABS/Malfunction    ${value}
    Should Be True    ${verdict}    Failed to set ABS Malfunction to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/ABS/Malfunction
    Should Be True    ${verdict}    Failed to send ABS Malfunction

SET AFU FAILURE
    [Documentation]    Simulate AFU Failure state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/AFU/Failure    ${value}
    Should Be True    ${verdict}    Failed to set ABS Malfunction to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/AFU/Failure
    Should Be True    ${verdict}    Failed to send ABS Malfunction

SET VDC STATE DISPLAY REQUEST
    [Documentation]    Simulate VDC status
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/VDC/Status    ${value}
    Should Be True    ${verdict}    Failed to set VDC State Display Request ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/VDC/Status
    Should Be True    ${verdict}    Failed to send VDC State Display Request

SEND VEHICLE STEERING STATUS
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Steering/Status    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE STEERING STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Steering/Status
    Should Be True    ${verdict}    Failed to SEND VEHICLE STEERING STATUS

SEND VEHICLE ASR MALFUNCTION COMMAND
    [Documentation]    Simulate Vehicle ASR_Malfunction state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/ASR/Malfunction     ${value}
    should_be_true    ${verdict}    Failed to set ASR MALFUNCTION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/ASR/Malfunction
    should_be_true    ${verdict}    Failed to send ASR MALFUNCTION

SEND VEHICLE AYC MALFUNCTION COMMAND
    [Documentation]    Simulate Vehicle AYC_Malfunction state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/AYC/Malfunction     ${value}
    should_be_true    ${verdict}    Failed to set AYC MALFUNCTION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/AYC/Malfunction
    should_be_true    ${verdict}    Failed to send AYC MALFUNCTION

SEND ENGINE FAILURE LEVEL2
    [Documentation]    Simulate Vehicle Engine Failure Level2 state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/Failure/Level2    ${value}
    should_be_true    ${verdict}    Failed to check ENGINE FAILURE LEVEL2 to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/Failure/Level2
    should_be_true    ${verdict}    Failed to check ENGINE FAILURE LEVEL 2

SEND DIESEL FILTER WATER DETECTION
    [Documentation]    Simulate Diesel Filter Water Detection state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Fuel/DieselFilterWaterDetection    ${value}
    should_be_true    ${verdict}    Failed to set DIESEL FILTER WATER DETECTION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Fuel/DieselFilterWaterDetection
    should_be_true    ${verdict}    Failed to set DIESEL FILTER WATER DETECTION

SEND EV REMAINING CHARGE STATUS
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/Charge/RemainingTime     ${value}
    should_be_true    ${verdict}    Failed to send EV REMAINING CHARGE STATUS ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/Charge/RemainingTime
    should_be_true    ${verdict}    Failed to send EV REMAINING CHARGE STATUS

SEND FUEL DISPLAYED LEVEL
    [Documentation]    Simulate Fuel Displayed Level status
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Fuel/FuelGaugeIndicator    ${value}
    Should Be True    ${verdict}    Failed to set Fuel displayed level ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Fuel/FuelGaugeIndicator
    Should Be True    ${verdict}    Failed to send Fuel Displayed Level Request

SEND LOWBATTERY VOLTAGE
    [Documentation]    Simulate Vehicle LowBattery Voltage
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/EEM/LowBatteryVoltage     ${value}
    should_be_true    ${verdict}    Failed to set LOWBATTERY VOLTAGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/EEM/LowBatteryVoltage
    should_be_true    ${verdict}    Failed to send LOWBATTERY VOLTAGE

SEND ESC_LONGITUDINAL CORRECTED
    [Documentation]    Simulate Vehicle ESC_Longitudinal Corrected state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/Acceleration/LongitudinalCorrected     ${value}
    should_be_true    ${verdict}    Failed to set ESC_LONGITUDINAL CORRECTED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/Acceleration/LongitudinalCorrected
    should_be_true    ${verdict}    Failed to send ESC_LONGITUDINAL CORRECTED

SEND ESC_TRANSVERSAL CORRECTED
    [Documentation]    Simulate Vehicle ESC_Transversal Corrected state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/Acceleration/TransversalCorrected     ${value}
    should_be_true    ${verdict}    Failed to set ESC_TRANSVERSAL CORRECTED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/Acceleration/TransversalCorrected
    should_be_true    ${verdict}    Failed to send ESC_TRANSVERSAL CORRECTED

SET EXTERNAL TEMPERATURE VALUE
    [Documentation]    Set External Temperature Value
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/ExternalTemp/Value     ${value}
    should_be_true    ${verdict}    Failed to set EXTERNAL TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/ExternalTemp/Value
    should_be_true    ${verdict}    Failed to send EXTERNAL TEMPERATURE

SEND OVERHAUL TIMEBEFORE
    [Documentation]    Simulate Vehicle OverHaul Timebefore state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Maintenance/Overhaul/TimeBefore     ${value}
    should_be_true    ${verdict}    Failed to set OVERHAUL TIMEBEFORE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Maintenance/Overhaul/TimeBefore
    should_be_true    ${verdict}    Failed to send OVERHAUL TIMEBEFORE

SET ENGINE COOLANT TEMP
    [Documentation]    Simulate Engine Coolant temp state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/CoolantTemp     ${value}
    should_be_true    ${verdict}    Failed to set ENGINE COOLANT TEMP to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/CoolantTemp
    should_be_true    ${verdict}    Failed to send ENGINE COOLANT TEMP

SET WATER TEMP WARNING
    [Documentation]    Simulate Water Temperature Warning state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/WaterTempWarging     ${value}
    should_be_true    ${verdict}    Failed to set WATER TEMP WARNING to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/WaterTempWarging
    should_be_true    ${verdict}    Failed to send WATER TEMP WARNING

SEND CONSUMPTION LAST TRIP
    [Documentation]    Simulate Vehicle Lasttrip Consumption state
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/Consumption/LastTrip    ${value}
    Should Be True    ${verdict}    Failed to set SEND CONSUMPTION TOTAL LAST TRIP to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/Consumption/LastTrip
    should_be_true    ${verdict}    Failed to send SEND CONSUMPTION TOTAL LAST TRIP

DO EMULATE ALL CAN DATA FOR CHARGING STATUS
    [Arguments]    ${state}
    [Documentation]    Emulate can data for charging status for argument ${state} True/False
    Run Keyword If    "${state}"=="True"    Run Keywords    SET VEHICLE AUTONOMY DISPLAY    C9h
    ...    AND    SET PLUG CONNECTED    1
    ...    AND    Sleep    5
    ...    AND    SEND VEHICLE CHARGE AVAILABILITY    charge_available
    ...    AND    SEND EV REMAINING CHARGE STATUS    20
    ...    AND    SEND DISTANCE TRIP UNIT    0
    ...    AND    SET VEHICLE AUTONOMY DISPLAY    201
    ...    AND    SEND VEHICLE CHARGE STATUS    charge_in_progress
    ...    AND    CONFIGURE CAN FOR BATTERY VOLTAGE    64h
    ...    AND    SET BATTERY ENERGY LEVEL    70
    ...    ELSE IF    "${state}"=="False"    Run Keywords    SEND VEHICLE CHARGE STATUS    no_charge
    ...    AND    SEND DISTANCE TRIP UNIT    0
    ...    AND    SET BATTERY ENERGY LEVEL    48
    ...    AND    SEND EV REMAINING CHARGE STATUS    70
    ...    AND    SET VEHICLE AUTONOMY DISPLAY    10
    ...    AND    SET PLUG CONNECTED    2
    ...    AND    SEND VEHICLE CHARGE AVAILABILITY    charge_available
    ...    AND    SEND VEHICLE CHARGE STATUS    charge_in_progress
    ...    AND    Sleep    10
    ...    AND    SEND VEHICLE CHARGE AVAILABILITY    charge_not_available
    ...    AND    SEND VEHICLE CHARGE STATUS    ended_charge
    ...    AND    Sleep    60

SEND CHARGING POWER BLMS
    [Arguments]    ${value}
    [Documentation]    Simulating signals related to the ChargingPower_BLMS service
    ${verdict}    ${comment} =    Canakin Set Signal    ChargingPower_BLMS    ${value}
    Should Be True    ${verdict}    Failed to SET ChargingPower_BLMS
    ${verdict}    ${comment} =    Canakin Start Write    elements=ChargingPower_BLMS
    Should Be True    ${verdict}    Failed to send ChargingPower_BLMS with ${comment}

SEND HVBATTERY TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    Simulating signals related to the HVbatteryTemperature service
    ${verdict}    ${comment} =    Canakin Set Signal    HVbatteryTemperature    ${value}
    Should Be True    ${verdict}    Failed to SET HVbatteryTemperature
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVbatteryTemperature
    Should Be True    ${verdict}    Failed to send HVbatteryTemperature with ${comment}

CHECK EHORIZON IVI CAN FRAME
    [Documentation]    == High Level Description: ==
    ...    Check that for the IVI CAN frames not all signals values are set to 0
    ...    == Parameters: ==
    ...    - _None_
    ...    == Expected Results: ==
    ...    Pass/Fail
    ${bus} =    Set Variable If    '${sweet400_bench_type}' in "'${bench_type}'"    can3    slcan0
    ${not_expected_string} =    Set variable   00 00 00 00 00 00 00 00
    Run Process    candump ${bus} > ${EXECDIR}/can.log    shell=True    timeout=${20}
    ${rc}    ${output} =    Run and Return RC and Output    grep -e 51E ${EXECDIR}/can.log
    should_not_contain    ${output}   ${not_expected_string}    Frame 51E has all signals set to 0
    Run Keyword and Ignore Error    Remove File    ${EXECDIR}/can.log

SET ENGINE RPM
    [Documentation]    Simulate Vehicle Engine RPM
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/RPM   ${value}
    Should Be True    ${verdict}    Failed to set Vehicle Engine RPM ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/RPM
    should_be_true    ${verdict}    Failed to send Vehicle Engine RPM

SEND VEHICLE ABS INREGULATION COMMAND
    [Documentation]    Simulate Vehicle ABS InRegulation Command
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/ABS/InRegulation   ${value}
    Should Be True    ${verdict}    Failed to set ABS Inregulation to ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/ABS/InRegulation
    should_be_true    ${verdict}    Failed to set ABS Inregulation

SEND VEHICLE AYC INREGULATION COMMAND
    [Documentation]    Simulate Vehicle AYC InRegulation Command
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/AYC/InRegulation   ${value}
    Should Be True    ${verdict}    Failed to set AYC Inregulation to ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/AYC/InRegulation
    should_be_true    ${verdict}    Failed to set AYC Inregulation

SET HVBATTERY LOWALERT STATUS
    [Documentation]    Simulate Vehicle HVBattery LowAlert Status
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EV/HVBattery/LowAlert   ${value}
    Should Be True    ${verdict}    Failed to set HVBattery LowAlert ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EV/HVBattery/LowAlert
    should_be_true    ${verdict}    Failed to set HVBattery LowAlert

SET SEATBELT DRIVER STATUS
    [Documentation]    Simulate Vehicle AYC InRegulation Command
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/SeatBelt/Driver   ${value}
    Should Be True    ${verdict}    Failed to set Seatbelt Driver Status ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/SeatBelt/Driver
    should_be_true    ${verdict}    Failed to set Seatbelt Driver Status

CONFIGURE CONTEXT DATA
    SEND VEHICLE SPEED DISPLAYED IN KMH     0
    SET VEHICLE SPEED    60
    SET ENGINE RPM    1000
    SEND VEHICLE SPEED DISPLAYED IN KMH     409
    SEND VEHICLE ABS INREGULATION COMMAND    1
    SEND GLOBAL VEHICLE WARNING STATE     1
    SEND VEHICLE AYC INREGULATION COMMAND     1
    SEND CRASH ORDER     2
    SET HVBATTERY LOWALERT STATUS     1
    SET SEATBELT DRIVER STATUS     2
    SEND GLOBAL VEHICLE WARNING STATE     3
    SEND STATUS FUEL CONSUMPTION    16000

DO EMULATE CAN DATA FOR MYRENAULT APP
    [Documentation]    == High Level Description: ==
    ...     This keyword is used to emulate the following conditions via CAN interface.
    SIMULATE THE TRIGGER    start_of_journey
    SEND DISTANCE TOTALIZER    1000
    SIMULATE THE TRIGGER    end_of_journey
    SET BATTERY ENERGY LEVEL    48
    SEND DISTANCE TRIP UNIT    0
    SET VEHICLE AUTONOMY DISPLAY    500
    SET PLUG CONNECTED    1
    SEND VEHICLE CHARGE STATUS    ended_charge
    Sleep    1

SEND HV_MAX_CAPACITY_VOLTAGE
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    HVB_MaxCapacity_HEVC_v2     ${value}
    should_be_true    ${verdict}    Failed to set HV Maximum Capacity Voltage to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVB_MaxCapacity_HEVC_v2
    should_be_true    ${verdict}    Failed to send HV Maximum Capacity Voltage

SET HEV AUTONOMY DISPLAY
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    VehicleAutonomyHEVdisplay     ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE AUTONOMY DISPLAY to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=VehicleAutonomyHEVdisplay
    should_be_true    ${verdict}    Failed to send VEHICLE AUTONOMY DISPLAY

SET HEV BATTERY SOC
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    HVBatHealth_BLMS     ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BATTERY SOC to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBatHealth_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BATTERY SOC

SET LOW BATTERY VOLTAGE DISPLAY
    [Arguments]    ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    LowBatteryVoltageDisplay    ${value}
    Should Be True    ${verdict}    Failed to SET LOW BATTERY VOLTAGE DISPLAY CAN SIGNAL ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=LowBatteryVoltageDisplay
    Should Be True    ${verdict}    Failed to SET LOW BATTERY VOLTAGE DISPLAY CAN SIGNAL

VERIFY CAN FRAME VALUE
    [Arguments]     ${signal_name}     ${bus}    ${signal_meaning}    ${timeout}
    Return From Keyword If    '${signal_meaning}' == 'DO_NOT_CHECK'
    ${status}    ${signals_dict} =    Canakin Wait For Signal    ${signal_name}    ${signal_meaning}    ${timeout}    bus=${bus}
    Run Keyword And Continue On Failure    Should Be Equal    '${status}'    'OK'    ${signals_dict}
    [Return]    ${status}

SEND VEHICLE ENGINE HOOD
    [Documentation]    Simulate Vehicle Engine Hood state
    [Arguments]    ${status}
    ${engine_hood} =    Set Variable If    "${status}" == "closed"    2    "${status}" == "opened"    1
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Door/EngineHood    ${engine_hood}
    should_be_true    ${verdict}    Fail to Canakin Set Signal: ${comment}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Door/EngineHood
    should_be_true    ${verdict}    Fail to Canakin Start Write Fail to SEND VEHICLE ENGINE HOOD: ${comment}

CANAKIN LOAD RECORDED FILE
    [Arguments]    ${file_type}    ${file_location}
    [Documentation]    == High Level Description: ==
    ...    Load recorded CAN frames sequence file saved from Vector or other SW
    ...    == Parameters: ==
    ...    - _file_type_: 0,1(0-asc, 1-blf)
    ...    - _file_location_: location of file
    ...    == Expected Results: ==
    ...    PASS if executed
    ${verdict}    ${comment} =    Canakin Load Record    ${file_type}   ${file_location}
    Should be True    ${verdict}    Failed to load file

CANAKIN LAUNCH RECORDED FILE
    [Arguments]    ${log_channel}    ${bus}
    [Documentation]    == High Level Description: ==
    ...    Play recorded CAN frames files saved from Vector or other SW
    ...    == Parameters: ==
    ...    - _log_channel_: 1
    ...    - _bus_: location of file
    ...    == Expected Results: ==
    ...    PASS if executed
    ${can_channel} =    Create Dictionary     ${log_channel}=${bus}
    ${verdict}    ${comment} =    Canakin Launch Play Record    ${can_channel}
    Should be True    ${verdict}    Failed to Play BLF record

CANAKIN WAIT PLAY RECORDED FILE
    [Documentation]    == High Level Description: ==
    ...    Wait until recorded CAN frames file is complete
    ${verdict}    ${comment} =    Canakin Wait Play Record
    Should be True    ${verdict}    Failed to Continue to Play BLF record

SIMULATE RECORDED CAN FRAMES SEQUENCE FILE
    [Arguments]    ${file_type}    ${log_channel}    ${file_location}
    CANAKIN LOAD RECORDED FILE    ${file_type}    ${file_location}
    CANAKIN LAUNCH RECORDED FILE    ${log_channel}    can0
    CANAKIN WAIT PLAY RECORDED FILE

CONFIGURE RCHS PARAMETERS
    [Documentation]    == High Level Description: ==
    ...    Send the desired remote charging status data to vnext
    SET BATTERY ENERGY LEVEL    40
    SEND VEHICLE CHARGE STATUS    no_charge
    SET PLUG CONNECTED    1
    SEND DISTANCE TRIP UNIT    0
    SEND EV REMAINING CHARGE STATUS    3
    SET VEHICLE AUTONOMY DISPLAY    200

CHECK IVC FOTA STATUS
    [Arguments]    ${status}=enabled    ${timeout}=30
    [Documentation]    Check that signal  FOTA/Sent/IVC_Status for [IVC Platform] FOTA status is NOT equal to 1F within the timeout
    ${signal_value} =     Set Variable If    "${status}".lower() == "enabled"    1Fh    "${status}".lower() == "scomo_update"    9h
    ${verdict}    ${comment} =    CANAKIN SEEK SIGNAL    ${bus}    FOTA/Sent/IVC_Status    ${signal_value}    ${timeout}
    Should Be True     ${verdict}    Fail CANAKIN SEEK SIGNAL
    ${signal_verdict}    ${signal_comment} =    CANAKIN GET SEEK SIGNAL RESULT    ${bus}    FOTA/Sent/IVC_Status
    Should Not Be True    ${signal_verdict}    ${signal_comment}

SEND VEHICLE FLEET ASSET INFORMATION
    [Documentation]    == High Level Description: ==
    ...    Send data related to fleet asset information
    SEND DISTANCE TOTALIZER    123
    SEND DISTANCE TO EMPTY TANK    234
    SEND FUEL DISPLAYED LEVEL    12
    SEND OIL STATUS LEVEL    1
    SEND OVERHAUL TIMEBEFORE    255
    SEND MAINTENANCE FIXED RANGE    250
    SEND VEHICLE SPEED DISPLAYED IN KMH    0

RESET BUDGETS
    [Arguments]
    [Documentation]    Reset Budgets to initial values
    SIMULATE THE TRIGGER    start_of_journey
    DO WAIT    10000
    SIMULATE THE TRIGGER    end_of_journey
    DO WAIT    10000

SEND SECURITY SIGNALS STATUS COMMAND
    [Arguments]    ${frame}    ${value}
    [Documentation]    SEND CAN message about security status of the vehicle signal.
    ${verdict}    ${comment} =    Canakin Set Signal    ${frame}    ${value}
    should_be_true    ${verdict}
    ${verdict}    ${comment} =    Canakin Start Write    elements=${frame}
    should_be_true    ${verdict}

DO SEND SECURITY SIGNALS
    [Documentation]    SEND CAN message about security status of the vehicle signal.
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security1    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security2    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security3    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security4    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security5    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security6    1
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security8    0
    FOR   ${i}    IN RANGE    1    17
         ${value_hex} =    CONVERT TO HEX    ${i}
        SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security7    ${value_hex}h
    END

DO SEND CGW VIOLATION SIGNALS
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security1    1
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security2    2
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security3    2
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security4    1
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security5    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security6    1
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security7    0
    SEND SECURITY SIGNALS STATUS COMMAND    Vehicle/Received/CGW/Security8    1

SEND VEHICLE CHARGE INSTANTANOUS POWER
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/DID/Charge/InstantaneousPower
    ${verdict}    ${comment} =    Canakin Set Signal    ChargingPower_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set CHARGE INSTANTANOUS POWER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ChargingPower_BLMS
    should_be_true    ${verdict}    Failed to send CHARGE INSTANTANOUS POWER

INCREMENT BATTERY LEVEL
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    increment the charge from 1 to 100 with 1% increment every 2 secs
    FOR    ${value}    IN RANGE    1    101
        ${value_st} =    CONVERT TO STRING    ${value}
        SET BATTERY ENERGY LEVEL    ${value_st}
        Sleep    2
    END

SEND VEHICLE DID CELLTENSION
    [Arguments]    ${frame}    ${value}
    [Documentation]    SEND CAN message about celltension status of the vehicle signal.
    ${verdict}    ${comment} =    Canakin Set Signal    HVBattery/DID/Historical/CellTension[${frame}]    ${value}
    should_be_true    ${verdict}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBattery/DID/Historical/CellTension[${frame}]
    should_be_true    ${verdict}

CONFIGURE EVA_001 PARAMETERS
    [Documentation]    SEND CAN message about CELLTENSION status of the vehicle signal.
    FOR   ${i}    IN RANGE    1    97
        SEND VEHICLE DID CELLTENSION    ${i}    3
    END

SEND VEHICLE BLMS HV NETWORK VOLTAGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/HVNetworkVoltage
    ${verdict}    ${comment} =    Canakin Set Signal    BMS_HVNetworkVoltage_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HV NETWORK VOLTAGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=BMS_HVNetworkVoltage_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HV NETWORK VOLTAGE

SEND VEHICLE CHARGE SPOT POWER LEVEL
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/ChargeSpotPowerLevel
    ${verdict}    ${comment} =    Canakin Set Signal    ChargeSpotPowerLevel    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE CHARGE SPOT POWER LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ChargeSpotPowerLevel
    should_be_true    ${verdict}    Failed to send VEHICLE CHARGE SPOT POWER LEVEL

SEND VEHICLE BLMS COMBO PRESENT VOLTAGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/PresentVoltage
    ${verdict}    ${comment} =    Canakin Set Signal    Combo_EVSEPresentVoltage    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO PRESENT VOLTAGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Combo_EVSEPresentVoltage
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO PRESENT VOLTAGE

SEND VEHICLE BLMS COMBO MAXIMUM VOLTAGE LIMIT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/MaximumVoltageLimit
    ${verdict}    ${comment} =    Canakin Set Signal    Combo_EVSEMaximumVoltageLimit    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO MAXIMUM VOLTAGE LIMIT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Combo_EVSEMaximumVoltageLimit
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO MAXIMUM VOLTAGE LIMIT

SEND VEHICLE BLMS COMBO MINIMUM VOLTAGE LIMIT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/MinimumVoltageLimit
    ${verdict}    ${comment} =    Canakin Set Signal    Combo_EVSEMinimumVoltageLimit    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO MINIMUM VOLTAGE LIMIT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Combo_EVSEMinimumVoltageLimit
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO MINIMUM VOLTAGE LIMIT

SEND VEHICLE CPLC COMMUNICATION STATUS
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/CPLC/CommunicationStatus
    ${verdict}    ${comment} =    Canakin Set Signal    CPLC_CommunicationStatus    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE CPLC COMMUNICATION STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CPLC_CommunicationStatus
    should_be_true    ${verdict}    Failed to send VEHICLE CPLC COMMUNICATION STATUS

SEND VEHICLE BLMS COMBO TARGET CURRENT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/TargetCurrent
    ${verdict}    ${comment} =    Canakin Set Signal    DCcharge_EVTargetCurrent    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO TARGET CURRENT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=DCcharge_EVTargetCurrent
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO TARGET CURRENT

SEND VEHICLE BLMS EM INVERTER VOLTAGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/InverterVoltage
    ${verdict}    ${comment} =    Canakin Set Signal    ME_InverterHVNetworkVoltage_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM INVERTER VOLTAGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_InverterHVNetworkVoltage_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM INVERTER VOLTAGE

SEND VEHICLE DCDC NETWORK VOLTAGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/DCDC/NetworkVoltage
    ${verdict}    ${comment} =    Canakin Set Signal    DCDCHVNetworkVoltage_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE DCDC NETWORK VOLTAGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=DCDCHVNetworkVoltage_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE DCDC NETWORK VOLTAGE

SEND VEHICLE PHEV BLMS HSG INVERTER CURRENT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/InverterCurrent
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_InverterCurrent_BLMS_v2    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE PHEV BLMS HSG INVERTER CURRENT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_InverterCurrent_BLMS_v2
    should_be_true    ${verdict}    Failed to send VEHICLE PHEV BLMS HSG INVERTER CURRENT

SEND VEHICLE EV BLMS EM INVERTER CURRENT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/InverterCurrent
    ${verdict}    ${comment} =    Canakin Set Signal    ME_InverterCurrent_BLMS_v2    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EV BLMS EM INVERTER CURRENT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_InverterCurrent_BLMS_v2
    should_be_true    ${verdict}    Failed to send VEHICLE EV BLMS EM INVERTER CURRENT

SEND VEHICLE EV BLMS RE TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/RE/Torque
    ${verdict}    ${comment} =    Canakin Set Signal    RE_ElecMachineTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EV BLMS RE TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=RE_ElecMachineTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE EV BLMS RE TORQUE

SEND VEHICLE BLMS TORQUE REQUEST
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/BLMS/TorqueRequest
    ${verdict}    ${comment} =    Canakin Set Signal    ME_TorqueRequest_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS TORQUE REQUEST to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_TorqueRequest_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS TORQUE REQUEST

SEND VEHICLE BLMS EM ELEC TORQUE ESTIMATION
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/ElecTorqueEstimation
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecTorqueEstimation_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM ELEC TORQUE ESTIMATION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecTorqueEstimation_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM ELEC TORQUE ESTIMATION

SEND VEHICLE BLMS SAFETY MAX TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/BLMS/SafetyMaxTorque
    ${verdict}    ${comment} =    Canakin Set Signal    ME_SafetyMaxTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS SAFETY MAX TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_SafetyMaxTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS SAFETY MAX TORQUE

SEND VEHICLE BLMS SAFETY MIN TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/BLMS/SafetyMinTorque
    ${verdict}    ${comment} =    Canakin Set Signal    ME_SafetyMinTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS SAFETY MIN TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_SafetyMinTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS SAFETY MIN TORQUE

SEND VEHICLE BLMS EM ELEC MAX GENERATOR TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/ElecMaxGeneratorTorque
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecMachineMaxGenTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM ELEC MAX GENERATOR TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecMachineMaxGenTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM ELEC MAX GENERATOR TORQUE

SEND VEHICLE BLMS EM ELEC MAX MOTOR TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/ElecMaxMotorTorque
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecMaxMotorTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM ELEC MAX MOTOR TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecMaxMotorTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM ELEC MAX MOTOR TORQUE

SEND VEHICLE BLMS HSG TORQUE REQUEST
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/TorqueRequest
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_TorqueRequest_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG TORQUE REQUEST to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_TorqueRequest_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG TORQUE REQUEST

SEND VEHICLE BLMS HSG ELEC TORQUE ESTIMATION
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/ElecTorqueEstimation
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecTorqueEstimation_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG ELEC TORQUE ESTIMATION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecTorqueEstimation_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG ELEC TORQUE ESTIMATION

SEND VEHICLE INVERTER BLMS SAFETY MAX TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Inverter/BLMS/SafetyMaxTorque
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_SafetyMaxTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE INVERTER BLMS SAFETY MAX TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_SafetyMaxTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE INVERTER BLMS SAFETY MAX TORQUE

SEND VEHICLE INVERTER BLMS SAFETY MIN TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Inverter/BLMS/SafetyMinTorque
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_SafetyMinTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE INVERTER BLMS SAFETY MIN TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_SafetyMinTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE INVERTER BLMS SAFETY MIN TORQUE

SEND VEHICLE BLMS HSG ELEC MAX MOTOR TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/ElecMaxMotorTorque
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecMaxMotorTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG ELEC MAX MOTOR TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecMaxMotorTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG ELEC MAX MOTOR TORQUE

SEND VEHICLE EV EDR EM SPEED
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/EDR/EM/Speed
    ${verdict}    ${comment} =    Canakin Set Signal    ElecMachineSpeed_EDR    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EV EDR EM SPEED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ElecMachineSpeed_EDR
    should_be_true    ${verdict}    Failed to send VEHICLE EV EDR EM SPEED

SEND VEHICLE BLMS EM INVERTER TEMP DEG
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/InverterTempDeg
    ${verdict}    ${comment} =    Canakin Set Signal    ME_InverterTempDeg_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM INVERTER TEMP DEG to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_InverterTempDeg_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM INVERTER TEMP DEG

SEND VEHICLE BLMS EM ELC MACHINE TEMP DEG
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/ElecMachineTempDeg
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecMachineTempDeg_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM ELC MACHINE TEMP DEG to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecMachineTempDeg_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM ELC MACHINE TEMP DEG

SEND VEHICLE BLMS PEB WATER TEMP
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/PEBWaterTemp
    ${verdict}    ${comment} =    Canakin Set Signal    PEBWaterTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS PEB WATER TEMP to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=PEBWaterTemp_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS PEB WATER TEMP

SEND VEHICLE INVERTER EMISSION TRADING SHEME COOLANT FLOW
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Inverter/EmissionTradingScheme/CoolantFlow
    ${verdict}    ${comment} =    Canakin Set Signal    ETSCoolantFlow_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE INVERTER EMISSION TRADING SHEME COOLANT FLOW to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ETSCoolantFlow_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE INVERTER EMISSION TRADING SHEME COOLANT FLOW

SEND VEHICLE BLMS EM INVERTER FAULT TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/InverterFaultType
    ${verdict}    ${comment} =    Canakin Set Signal    ME_InverterFaultType    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS EM INVERTER FAULT TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_InverterFaultType
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS EM INVERTER FAULT TYPE

SEND VEHICLE FAILURE DISPLAY ELECTRICAL SYSTEM
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/FailureDisplay/ElectricalSystem
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecSysFailureDisplay_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE FAILURE DISPLAY ELECTRICAL SYSTEM to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecSysFailureDisplay_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE FAILURE DISPLAY ELECTRICAL SYSTEM

SEND VEHICLE FAILURE DISPLAY ELECTRICAL MOTOR
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/FailureDisplay/ElectricalMotor
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecMotorFailureDisplay_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE FAILURE DISPLAY ELECTRICAL MOTOR to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecMotorFailureDisplay_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE FAILURE DISPLAY ELECTRICAL MOTOR

SEND VEHICLE BLMS HSG ELEC MACHINE SPEED
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/ElecMachineSpeed
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecMachineSpeed_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG ELEC MACHINE SPEED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecMachineSpeed_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG ELEC MACHINE SPEED

SEND VEHICLE BLMS HSG ELEC MACHINE TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/ElecMachineTemperature
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecMachineTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG ELEC MACHINE TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecMachineTemp_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG ELEC MACHINE TEMPERATURE

SEND VEHICLE BLMS HSG INVERTER TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/InverterTemperature
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_InverterTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG INVERTER TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_InverterTemp_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG INVERTER TEMPERATURE

SEND VEHICLE ELECTRICAL MACHINE INVERTER FAULTY TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Inverter/FaultType
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_InverterFault_Type_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE INVERTER FAULTY TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_InverterFault_Type_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE ELECTRICAL MACHINE INVERTER FAULTY TYPE

SEND VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL SYSTEM
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Inverter/FailureDisplay/ElectricalSystem
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecSysFailureDisplay_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL SYSTEM to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecSysFailureDisplay_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL SYSTEM

SEND VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL MOTOR
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Inverter/FailureDisplay/ElectricalMotor
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecMotorFailureDisplay_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL MOTOR to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecMotorFailureDisplay_EVA
    should_be_true    ${verdict}    Failed to send VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL MOTOR

SEND VEHICLE HVB TEMPERATURE MAX
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/DID/Status/Temperature/Max
    ${verdict}    ${comment} =    Canakin Set Signal    HVBatteryTempMax_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE HVB TEMPERATURE MAX to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBatteryTempMax_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE HVB TEMPERATURE MAX

SEND VEHICLE HVB TEMPERATURE MIN
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/DID/Status/Temperature/Min
    ${verdict}    ${comment} =    Canakin Set Signal    HVBatteryTempMin_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE HVB TEMPERATURE MIN to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBatteryTempMin_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE HVB TEMPERATURE MIN

SEND VEHICLE BLMS INSTANT CURRENT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/InstantCurrent
    ${verdict}    ${comment} =    Canakin Set Signal    HVbatInstantCurrent_BLMS_v2    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS INSTANT CURRENT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVbatInstantCurrent_BLMS_v2
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS INSTANT CURRENT

SEND VEHICLE MAX AC CURRENT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/CHG/MaxACCurrent
    ${verdict}    ${comment} =    Canakin Set Signal    CHGMaxACCurrent_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE MAX AC CURRENT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CHGMaxACCurrent_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE MAX AC CURRENT

SEND VEHICLE BLMS MASTER FAULT TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/MasterFaultType
    ${verdict}    ${comment} =    Canakin Set Signal    BMS_FaultType_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS MASTER FAULT TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=BMS_FaultType_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS MASTER FAULT TYPE

SEND VEHICLE BLMS HSG ELEC MAX GEN TORQUE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/PHEV/BLMS/HSG/ElecMaxGenTorque
    ${verdict}    ${comment} =    Canakin Set Signal    HSG_ElecMaxGenTorque_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS HSG ELEC MAX GEN TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HSG_ElecMaxGenTorque_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS HSG ELEC MAX GEN TORQUE

CONFIGURE EVA PERIODIC TRIGGER DATA
    [Documentation]    Emulate on the CAN bus Battery State of Health periodically
    SEND HVBATTERY TEMPERATURE    20
    SEND VEHICLE HVB TEMPERATURE MAX    50
    SEND VEHICLE HVB TEMPERATURE MIN   10
    SEND VEHICLE BLMS INSTANT CURRENT    500
    SEND VEHICLE BLMS HV NETWORK VOLTAGE    100
    SEND VEHICLE MAX AC CURRENT    10
    SEND VEHICLE CHARGE SPOT POWER LEVEL    70.2
    SEND VEHICLE BLMS COMBO PRESENT VOLTAGE    200
    SEND VEHICLE CHARGE INSTANTANOUS POWER   100
    SEND VEHICLE BLMS COMBO MAXIMUM VOLTAGE LIMIT    700
    SEND VEHICLE BLMS COMBO MINIMUM VOLTAGE LIMIT    200
    SEND VEHICLE CPLC COMMUNICATION STATUS    1
    SET REMAINING TIME   600
    SEND VEHICLE BLMS COMBO TARGET CURRENT    300
    SEND VEHICLE BLMS EM INVERTER VOLTAGE    200
    SEND VEHICLE DCDC NETWORK VOLTAGE    120
    SEND VEHICLE PHEV BLMS HSG INVERTER CURRENT    250
    SEND VEHICLE EV BLMS EM INVERTER CURRENT    100
    SEND VEHICLE EV BLMS RE TORQUE    200
    SEND VEHICLE BLMS TORQUE REQUEST    60
    SEND VEHICLE BLMS EM ELEC TORQUE ESTIMATION    70
    SEND VEHICLE BLMS SAFETY MAX TORQUE    100
    SEND VEHICLE BLMS SAFETY MIN TORQUE    -20
    SEND VEHICLE BLMS EM ELEC MAX GENERATOR TORQUE    50
    SEND VEHICLE BLMS EM ELEC MAX MOTOR TORQUE    100
    SEND VEHICLE BLMS HSG TORQUE REQUEST    90
    SEND VEHICLE BLMS HSG ELEC TORQUE ESTIMATION    80
    SEND VEHICLE INVERTER BLMS SAFETY MAX TORQUE    450
    SEND VEHICLE INVERTER BLMS SAFETY MIN TORQUE    -30
    SEND VEHICLE BLMS HSG ELEC MAX GEN TORQUE    50
    SEND VEHICLE BLMS HSG ELEC MAX MOTOR TORQUE   200
    SEND VEHICLE EV EDR EM SPEED   5000
    SEND VEHICLE BLMS EM INVERTER TEMP DEG    100
    SEND VEHICLE BLMS EM ELC MACHINE TEMP DEG    60
    SEND VEHICLE BLMS PEB WATER TEMP    110
    SEND VEHICLE INVERTER EMISSION TRADING SHEME COOLANT FLOW    5
    SEND VEHICLE BLMS EM INVERTER FAULT TYPE    1
    SEND VEHICLE FAILURE DISPLAY ELECTRICAL SYSTEM    1
    SEND VEHICLE FAILURE DISPLAY ELECTRICAL MOTOR    1
    SEND VEHICLE BLMS HSG ELEC MACHINE SPEED    6000
    SEND VEHICLE BLMS HSG ELEC MACHINE TEMPERATURE    30
    SEND VEHICLE BLMS HSG INVERTER TEMPERATURE    80
    SEND VEHICLE ELECTRICAL MACHINE INVERTER FAULTY TYPE    1
    SEND VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL SYSTEM    1
    SEND VEHICLE INVERTER FAILURE DISPLAY ELECTRICAL MOTOR    1

SEND VEHICLE BLMS CPLC FAULT TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/CPLC/FaultType
    ${verdict}    ${comment} =    Canakin Set Signal    CPLC_FaultType    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS CPLC FAULT TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CPLC_FaultType
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS CPLC FAULT TYPE

SEND VEHICLE BLMS COMBO READY
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/Ready
    ${verdict}    ${comment} =    Canakin Set Signal    Combo_EVReady    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO READY to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Combo_EVReady
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO READY

SEND VEHICLE BLMS COMBO CHARGE HLC REQUEST
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/chargeHLCRequest
    ${verdict}    ${comment} =    Canakin Set Signal    Combo_EVchargeHLCRequest    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO CHARGE HLC REQUEST to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Combo_EVchargeHLCRequest
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO CHARGE HLC REQUEST

SEND VEHICLE BLMS COMBO ERROR CODE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/ErrorCode
    ${verdict}    ${comment} =    Canakin Set Signal    Combo_EVErrorCode    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO ERROR CODE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Combo_EVErrorCode
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO ERROR CODE

SEND VEHICLE BLMS COMBO REQUESTED ENERGY TRANSFER MODE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/Combo/RequestedEnergyTransferMode
    ${verdict}    ${comment} =    Canakin Set Signal    CPLC_RequestedEnergyTransferMode    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS COMBO ERROR CODE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CPLC_RequestedEnergyTransferMode
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS COMBO ERROR CODE

SEND VEHICLE EV CHARGE HV CHARGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/Charge/HVCharge
    ${verdict}    ${comment} =    Canakin Set Signal    HVchargerStatus    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EV CHARGE HV CHARGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVchargerStatus
    should_be_true    ${verdict}    Failed to send VEHICLE EV CHARGE HV CHARGE

SEND VEHICLE EV BLMS OPERATING TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/OperatingType
    ${verdict}    ${comment} =    Canakin Set Signal    OperatingTypeStatus_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EV BLMS OPERATING TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=OperatingTypeStatus_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE EV BLMS OPERATING TYPE

SEND VEHICLE HV BATTERY START OF CHARGE TRIGGER
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/HVBattery/StartOfChargeTrigger
    ${verdict}    ${comment} =    Canakin Set Signal    HVBatStartOfChargeTrigger    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE HV BATTERY START OF CHARGE TRIGGER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBatStartOfChargeTrigger
    should_be_true    ${verdict}    Failed to send VEHICLE HV BATTERY START OF CHARGE TRIGGER

CONFIGURE EVA 003 SINGLE TRIGGER DATA
    [Documentation]    Emulate on the CAN bus Battery State of Health periodically
    SEND VEHICLE CHARGE BLOCK MODE    block
    SEND VEHICLE CHARGE STATUS    waiting_a_planned_charge
    SEND VEHICLE BLMS CPLC FAULT TYPE    0
    SEND VEHICLE BLMS COMBO READY    1
    SEND VEHICLE BLMS COMBO CHARGE HLC REQUEST    1
    SEND VEHICLE BLMS COMBO ERROR CODE    1
    SEND VEHICLE BLMS COMBO REQUESTED ENERGY TRANSFER MODE    1
    SET PROGRAMMED CHARGE STATUS    delayed
    SEND VEHICLE EV CHARGE HV CHARGE    1
    SEND VEHICLE EV BLMS OPERATING TYPE    0
    SEND VEHICLE CHARGE ALERT    1
    SET PLUG CONNECTED    1
    SEND VEHICLE HV BATTERY START OF CHARGE TRIGGER    1

CONFIGURE EVA 003 SINGLE TRIGGER NEW DATA
    [Documentation]    Emulate on the CAN bus Battery State of Health periodically
    SEND VEHICLE CHARGE BLOCK MODE    unblock
    SEND VEHICLE CHARGE STATUS    ended_charge
    SEND VEHICLE BLMS CPLC FAULT TYPE    1
    SEND VEHICLE BLMS COMBO READY    0
    SEND VEHICLE BLMS COMBO CHARGE HLC REQUEST    2
    SEND VEHICLE BLMS COMBO ERROR CODE    2
    SEND VEHICLE BLMS COMBO REQUESTED ENERGY TRANSFER MODE    2
    SET PROGRAMMED CHARGE STATUS    always
    SEND VEHICLE EV CHARGE HV CHARGE    0
    SEND VEHICLE EV BLMS OPERATING TYPE    1
    SEND VEHICLE CHARGE ALERT    3
    SET PLUG CONNECTED    2
    SEND VEHICLE HV BATTERY START OF CHARGE TRIGGER    0

SEND VEHICLE BRAKE PRESSURE
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Brake/Pressure   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE BRAKE PRESSURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Brake/Pressure
    Should Be True    ${verdict}    Failed to SEND VEHICLE BRAKE PRESSURE

SEND VEHICLE MEAN EFFECTIVE TORQUE
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/MeanEffectiveTorque   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE MEAN EFFECTIVE TORQUE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/MeanEffectiveTorque
    Should Be True    ${verdict}    Failed to SEND VEHICLE MEAN EFFECTIVE TORQUE

SEND VEHICLE BREAKING PEDAL INFORMATION
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/Braking/PedalInformation   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE BREAKING PEDAL INFORMATION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/Braking/PedalInformation
    Should Be True    ${verdict}    Failed to SEND VEHICLE BREAKING PEDAL INFORMATION

SEND VEHICLE YAW RATE CORRECTED
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/YawRate/Corrected   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE YAW RATE CORRECTED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/YawRate/Corrected
    Should Be True    ${verdict}    Failed to SEND VEHICLE YAW RATE CORRECTED

SEND VEHICLE WHEEL SPEED REARLEFT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Speed/WheelSpeed/RearLeft   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL SPEED REARLEFT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Speed/WheelSpeed/RearLeft
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL SPEED REARLEFT

SEND VEHICLE WHEEL SPEED REARRIGHT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Speed/WheelSpeed/RearRight   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL SPEED REARRIGHT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Speed/WheelSpeed/RearRight
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL SPEED REARRIGHT

SEND VEHICLE WHEEL SPEED FRONTLEFT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal   Vehicle/Received/Speed/WheelSpeed/FrontLeft    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL SPEED FRONTLEFT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Speed/WheelSpeed/FrontLeft
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL SPEED FRONTLEFT

SEND VEHICLE WHEEL SPEED FRONTRIGHT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Speed/WheelSpeed/FrontRight   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL SPEED FRONTRIGHT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Speed/WheelSpeed/FrontRight
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL SPEED FRONTRIGHT

SEND VEHICLE ATMOPRESSURE
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Pressure/AtmoPressure   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE ATMOPRESSURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Pressure/AtmoPressure
    Should Be True    ${verdict}    Failed to SEND VEHICLE ATMOPRESSURE

SEND VEHICLE STEERING ANGLE
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Steering/Angle   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE STEERING ANGLE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Steering/Angle
    Should Be True    ${verdict}    Failed to SEND VEHICLE STEERING ANGLE

SEND VEHICLE WHEEL PRESSURE FRONTLEFT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/Wheel/Pressure/FrontLeft   ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL PRESSURE FRONTLEFT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/Pressure/FrontLeft
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL PRESSURE FRONTLEFT

SEND VEHICLE WHEEL PRESSURE FRONTRIGHT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal   Vehicle/Received/Status/Wheel/Pressure/FrontRight    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL PRESSURE FRONTRIGHT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/Pressure/FrontRight
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL PRESSURE FRONTRIGHT

SEND VEHICLE WHEEL PRESSURE REARRIGHT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal   Vehicle/Received/Status/Wheel/Pressure/RearRight    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL PRESSURE REARRIGHT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/Pressure/RearRight
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL PRESSURE REARRIGHT

SEND VEHICLE WHEEL PRESSURE REARLEFT
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal   Vehicle/Received/Status/Wheel/Pressure/RearLeft    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE WHEEL PRESSURE REARLEFT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/Wheel/Pressure/RearLeft
    Should Be True    ${verdict}    Failed to SEND VEHICLE WHEEL PRESSURE REARLEFT

SEND VEHICLE GEARBOX MINIMUM TRAVEL
    [Arguments]     ${value}
    ${verdict}    ${comment} =    Canakin Set Signal   Vehicle/Received/GearBox/ClutchSwitch/MinimumTravel    ${value}
    Should Be True    ${verdict}    Failed to SET VEHICLE GEARBOX MINIMUM TRAVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/GearBox/ClutchSwitch/MinimumTravel
    Should Be True    ${verdict}    Failed to SEND VEHICLE GEARBOX MINIMUM TRAVEL

CONFIGURE UBAM DATA TRIGGER
    SEND VEHICLE BRAKE PRESSURE    70
    SEND VEHICLE SPEED VALUE    150
    SET ENGINE RPM    3000
    SET EXTERNAL TEMPERATURE VALUE    25
    SEND ESC_TRANSVERSAL CORRECTED    1
    SEND VEHICLE MEAN EFFECTIVE TORQUE    700
    SEND VEHICLE BREAKING PEDAL INFORMATION    2
    SEND ESC_LONGITUDINAL CORRECTED    1
    SEND VEHICLE YAW RATE CORRECTED    35
    SEND VEHICLE WHEEL SPEED REARLEFT    120.000000096
    SEND VEHICLE WHEEL SPEED REARRIGHT    120.000000096
    SEND VEHICLE WHEEL SPEED FRONTLEFT    120.000000096
    SEND VEHICLE WHEEL SPEED FRONTRIGHT    120.000000096
    SEND VEHICLE ATMOPRESSURE    75
    SEND VEHICLE STEERING ANGLE    180
    SEND VEHICLE WHEEL PRESSURE FRONTLEFT    4500
    SEND VEHICLE WHEEL PRESSURE FRONTRIGHT    4500
    SEND VEHICLE WHEEL PRESSURE REARRIGHT    4500
    SEND VEHICLE WHEEL PRESSURE REARLEFT     4500
    SEND VEHICLE GEARBOX MINIMUM TRAVEL    2

CONFIGURE COMA ALL DATA
    [Documentation]    Emulate on CAN bus COMA signals
    SEND MAINTENANCE FIXED RANGE    250
    SEND VEHICLE DRAINING TIME BEFORE    120
    SEND OIL STATUS LEVEL    1
    SEND GLOBAL VEHICLE WARNING STATE    0
    SEND OVERHAUL TIMEBEFORE    255
    SEND VEHICLE MAINTENANCE OVERHAUL MILAGE MINIMUM    250
    SEND VEHICLE MAINTENANCE OVERHAUL ALERT MINIMUM    0
    SEND DISTANCE TOTALIZER    123
    SEND DISTANCE TRIP UNIT    0
    SEND LOWBATTERY VOLTAGE    2
    SEND VEHICLE CRASH AIRBAG MALFUNCTION    0
    SET PASSENGER AIR BAG INHIBITION    1
    SEND VEHICLE BRAKE STATUS COMMAND    no_failure
    SEND VEHICLE ABS MALFUNCTION COMMAND    0
    SEND VEHICLE ASR MALFUNCTION COMMAND    0
    SET AFU FAILURE    0
    SET VDC STATE DISPLAY REQUEST    0
    SET VEHICLE ESC EDB STATE DISPLAY    0
    SEND VEHICLE OIL PRESSURE WARNING STATUS COMMAND    0
    SET WATER TEMP WARNING    0
    SEND VEHICLE ENGINE FAILURE LEVEL1    0
    SEND ENGINE FAILURE LEVEL2    0
    SEND UREA LEVEL    0
    SET VEHICLE STATUS SCR WARNING DISTANCE    0
    SET VEHICLE DISTANCE WARNING    0
    SEND VEHICLE MILLAMMP REQUEST STATUS COMMAND    1
    SEND FUEL LOW LEVEL    1
    SEND DIESEL FILTER WATER DETECTION    0
    SEND BADGE BATTERY LEVEL    0
    SET WHEEL FRONT LEFT STATE    2
    SET WHEEL FRONT RIGHT STATE    2
    SET WHEEL REAR LEFT STATE    2
    SET WHEEL REAR RIGHT STATE    2
    SET VEHICLE HEV DISPLAY CHARGE FAILURE    0
    SET VEHICLE MAINTENANCE PARTICULATE FILTER FAILURE WARINING    1
    SEND VEHICLE AYC MALFUNCTION COMMAND    0
    SEND VEHICLE BRAKE FLUID LEVEL STATUS COMMAND    1
    SEND CRASH DETECTION OUT OF ORDER    0
    SET VEHICLE CHG ALERT SPOT CHARGE    3
    SET ENGINE COOLANT TEMP    30

SEND VEHICLE DRAINING TIME BEFORE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Maintenance/Draining/TimeBefore
    ${verdict}    ${comment} =    Canakin Set Signal    TimeBeforeDraining    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE DRAINING TIME BEFORE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=TimeBeforeDraining
    should_be_true    ${verdict}    Failed to send VEHICLE DRAINING TIME BEFORE

SEND VEHICLE MAINTENANCE OVERHAUL MILAGE MINIMUM
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Maintenance/Overhaul/MilageMinimum
    ${verdict}    ${comment} =    Canakin Set Signal    MilageMinBeforeOverhaul    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE MAINTENANCE OVERHAUL MILAGE MINIMUM to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=MilageMinBeforeOverhaul
    should_be_true    ${verdict}    Failed to send VEHICLE MAINTENANCE OVERHAUL MILAGE MINIMUM

SEND VEHICLE MAINTENANCE OVERHAUL ALERT MINIMUM
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Maintenance/Overhaul/AlertMinimum
    ${verdict}    ${comment} =    Canakin Set Signal    AlertMinBeforeOverhaul    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE MAINTENANCE OVERHAUL ALERT MINIMUM to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=AlertMinBeforeOverhaul
    should_be_true    ${verdict}    Failed to send VEHICLE MAINTENANCE OVERHAUL ALERT MINIMUM

SEND VEHICLE CRASH AIRBAG MALFUNCTION
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Crash/Airbag/Malfunction
    ${verdict}    ${comment} =    Canakin Set Signal    AIRBAGMalfunction    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE CRASH AIRBAG MALFUNCTION to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=AIRBAGMalfunction
    should_be_true    ${verdict}    Failed to send VEHICLE CRASH AIRBAG MALFUNCTION

SET VEHICLE ESC EDB STATE DISPLAY
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ESC/EBD/StateDisplay
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/ESC/EBD/StateDisplay    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ESC EDB STATE DISPLAY to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/ESC/EBD/StateDisplay
    should_be_true    ${verdict}    Failed to set VEHICLE ESC EDB STATE DISPLAY

SET VEHICLE STATUS SCR WARNING DISTANCE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Status/SCR/Warning/Distance
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Status/SCR/Warning/Distance   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE STATUS SCR WARNING DISTANCE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Status/SCR/Warning/Distance
    should_be_true    ${verdict}    Failed to set VEHICLE STATUS SCR WARNING DISTANCE

SET VEHICLE HEV DISPLAY CHARGE FAILURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/HEV/Display/ChargeFailure
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/HEV/Display/ChargeFailure   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE HEV DISPLAY CHARGE FAILURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/HEV/Display/ChargeFailure
    should_be_true    ${verdict}    Failed to set VEHICLE HEV DISPLAY CHARGE FAILURE

SET VEHICLE MAINTENANCE PARTICULATE FILTER FAILURE WARINING
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Maintenance/ParticulateFilter/FailureWarning
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Maintenance/ParticulateFilter/FailureWarning   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE MAINTENANCE PARTICULATE FILTER FAILURE WARINING to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Maintenance/ParticulateFilter/FailureWarning
    should_be_true    ${verdict}    Failed to set VEHICLE MAINTENANCE PARTICULATE FILTER FAILURE WARINING

SET VEHICLE CHG ALERT SPOT CHARGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/CHGalert/SpotCharge
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/CHGalert/SpotCharge   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE CHG ALERT SPOT CHARGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/CHGalert/SpotCharge
    should_be_true    ${verdict}    Failed to set VEHICLE CHG ALERT SPOT CHARGE

CHECK CAN MESSAGE
    [Arguments]       ${message_id}     ${occurrences}
    [Documentation]    Using CandumpMonitor for determining if CAN message with ${message_id} and with the number of times it occurs ${occurrences} is being received on ${bus}
    ${verdict}    ${comment} =    SET CANDUMP CONFIG
    Should be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    START CANDUMP MONITOR
    Should be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    SET CANDUMP TRIGGER    message=${message_id}    occurrences=${occurrences}
    Should be True    ${verdict}    ${comment}
    START ANALYZING CAN DATA
    ${verdict}    ${comment} =    STOP CANDUMP MONITOR
    Should be True    ${verdict}    ${comment}
    STOP ANALYZING CAN DATA

CONFIGURE PHYD ALL DATA
    SEND DISTANCE TOTALIZER    123
    SEND VEHICLE SPEED VALUE    100
    SEND ESC_LONGITUDINAL CORRECTED   2
    SEND ESC_TRANSVERSAL CORRECTED    1
    SEND VEHICLE BRAKE PRESSURE    3

SET VEHICLE ENGINE OIL DRAINING RANGE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Engine/OilDrainingRange
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Engine/OilDrainingRange   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ENGINE OIL DRAINING RANGE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Engine/OilDrainingRange
    should_be_true    ${verdict}    Failed to set VEHICLE ENGINE OIL DRAINING RANGE

SET VEHICLE AIR FILTER CLOGGING STATUS
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EVA/Air/Filter/Clogging/Status
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EVA/Air/Filter/Clogging/Status  ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE AIR FILTER CLOGGING STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EVA/Air/Filter/Clogging/Status
    should_be_true    ${verdict}    Failed to set VEHICLE AIR FILTER CLOGGING STATUS

SET VEHICLE AIR FILTER CLOGGING DATA RELIAB
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EVA/Air/Filter/Clogging/Data/Reliab
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/EVA/Air/Filter/Clogging/Data/Reliab     ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE AIR FILTER CLOGGING DATA RELIAB to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/EVA/Air/Filter/Clogging/Data/Reliab
    should_be_true    ${verdict}    Failed to set VEHICLE AIR FILTER CLOGGING DATA RELIAB

SET VEHICLE EEM STOP AUTO FORBIDDEN
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/GEE/EEM/StopAutoForbidden
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/GEE/EEM/StopAutoForbidden   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EEM STOP AUTO FORBIDDEN to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/GEE/EEM/StopAutoForbidden
    should_be_true    ${verdict}    Failed to set VEHICLE EEM STOP AUTO FORBIDDEN

SET VEHICLE EEM STATIC POWER LIMIT
    [Arguments]    ${value}=0
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/GEE/EEM/StaticPowerLimitationRequest
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/GEE/EEM/StaticPowerLimitationRequest   ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EEM STATIC POWER LIMIT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/GEE/EEM/StaticPowerLimitationRequest
    should_be_true    ${verdict}    Failed to set VEHICLE EEM STATIC POWER LIMIT

CONFIGURE UBAM DATA SINGLE TRIGGER
    SEND DISTANCE TOTALIZER    123
    SET VEHICLE ENGINE OIL DRAINING RANGE    80
    SET VEHICLE AIR FILTER CLOGGING STATUS    60
    SET VEHICLE AIR FILTER CLOGGING DATA RELIAB    55
    SET BATTERY SOC 14V ENERGY LEVEL    75
    SET VEHICLE EEM STOP AUTO FORBIDDEN    0
    SEND VEHICLE STATE COMMAND    PowertrainRunning

SEND VEHICLE CHARGE TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/HVBattery/ChargeType
    ${verdict}    ${comment} =    Canakin Set Signal    HVbatteryChargeType_v2    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE CHARGE TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVbatteryChargeType_v2
    should_be_true    ${verdict}    Failed to send VEHICLE CHARGE TYPE

SEND VEHICLE BLMS SLAVE FAULT TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/SlaveFaultType
    ${verdict}    ${comment} =    Canakin Set Signal    BMS2_FaultType_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE BLMS SLAVE FAULT TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=BMS2_FaultType_BLMS
    should_be_true    ${verdict}    Failed to send VEHICLE BLMS SLAVE FAULT TYPE


SEND BATTERY HIGHEST CELL VOLTAGE PROBE ID
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/Status/CellVoltage/HighestCellVoltageProbeID
    ${verdict}    ${comment} =    Canakin Set Signal    BMS_CellHighestVoltageID_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BATTERY HIGHEST CELL VOLTAGE PROBE ID to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=BMS_CellHighestVoltageID_BLMS
    should_be_true    ${verdict}    Failed to send BATTERY HIGHEST CELL VOLTAGE PROBE ID

SEND BATTERY LOWEST CELL VOLTAGE PROBE ID
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/Status/CellVoltage/LowestCellVoltageProbeID
    ${verdict}    ${comment} =    Canakin Set Signal    BMS_CellLowestVoltageID_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BATTERY LOWEST CELL VOLTAGE PROBE ID to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=BMS_CellLowestVoltageID_BLMS
    should_be_true    ${verdict}    Failed to send BATTERY LOWEST CELL VOLTAGE PROBE ID

SEND CELL VOLTAGE MAX
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/DID/Status/CellVoltage/Max
    ${verdict}    ${comment} =    Canakin Set Signal    CellHighestVoltage_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set CELL VOLTAGE MAX to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CellHighestVoltage_BLMS
    should_be_true    ${verdict}    Failed to send CELL VOLTAGE MAX

SEND CELL VOLTAGE MIN
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/DID/Status/CellVoltage/Min
    ${verdict}    ${comment} =    Canakin Set Signal    CellLowestVoltage_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set CELL VOLTAGE MIN to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CellLowestVoltage_BLMS
    should_be_true    ${verdict}    Failed to send CELL VOLTAGE MIN

SEND HV ISOLATION IMPEDANCE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/HVIsolationImpedance
    ${verdict}    ${comment} =    Canakin Set Signal    HVIsolationImpedance_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set HV ISOLATION IMPEDANCE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVIsolationImpedance_BLMS
    should_be_true    ${verdict}    Failed to send HV ISOLATION IMPEDANCE

SEND BLMS NUMBER OF PHASES USED
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumberOfPhasesUsed
    ${verdict}    ${comment} =    Canakin Set Signal    NumberOfPhasesUsed_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER OF PHASES USED to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumberOfPhasesUsed_BLMS
    should_be_true    ${verdict}    Failed to send BLMS NUMBER OF PHASES USED

SEND BLMS ACC CHARGE INLET TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/ACChargeInletTemperature
    ${verdict}    ${comment} =    Canakin Set Signal    ACchargeInletTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS ACC CHARGE INLET TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ACchargeInletTemp_BLMS
    should_be_true    ${verdict}    Failed to send BLMS ACC CHARGE INLET TEMPERATURE

SEND BLMS DC CHARGE INLET TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/DC/ChargeInletTemperature
    ${verdict}    ${comment} =    Canakin Set Signal    DCchargeInletTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS DC CHARGE INLET TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=DCchargeInletTemp_BLMS
    should_be_true    ${verdict}    Failed to send BLMS DC CHARGE INLET TEMPERATURE

SEND BLMS CHG TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/CHG/Temperature
    ${verdict}    ${comment} =    Canakin Set Signal    CHGTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS CHG TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CHGTemp_BLMS
    should_be_true    ${verdict}    Failed to send BLMS CHG TEMPERATURE

SEND BLMS CHG WATER TEMPERATURE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/CHG/WaterTemperature
    ${verdict}    ${comment} =    Canakin Set Signal    CHGWaterTemp_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS CHG WATER TEMPERATURE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CHGWaterTemp_BLMS
    should_be_true    ${verdict}    Failed to send BLMS CHG WATER TEMPERATURE

SEND BLMS CHG AVAILABLE CHARGING POWER
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/CHG/AvailableChargingPower
    ${verdict}    ${comment} =    Canakin Set Signal    CHGAvailableChargingPower_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS CHG AVAILABLE CHARGING POWER to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=CHGAvailableChargingPower_BLMS
    should_be_true    ${verdict}    Failed to send BLMS CHG AVAILABLE CHARGING POWER

SEND BLMS NUMBER AC CHARGE STARTS
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumACchargeStarts
    ${verdict}    ${comment} =    Canakin Set Signal    NumACchargeStarts_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER AC CHARGE STARTS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumACchargeStarts_BLMS
    should_be_true    ${verdict}    Failed to send BLMS NUMBER AC CHARGE STARTS

SEND BLMS NUMBER AC SMART CHARGING
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumACsmartcharging
    ${verdict}    ${comment} =    Canakin Set Signal    NumACsmartcharging_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER AC SMART CHARGING to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumACsmartcharging_BLMS
    should_be_true    ${verdict}    Failed to send BLMS NUMBER AC SMART CHARGING

SEND BLMS NUMBER AC SMART CHARGING BREAK
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumACsmartchargingBreak
    ${verdict}    ${comment} =    Canakin Set Signal    NumACsmartchargingBreak_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER AC SMART CHARGING BREAK to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumACsmartchargingBreak_BLMS
    should_be_true    ${verdict}    Failed to send BLMS NUMBER AC SMART CHARGING BREAK

SEND BLMS NUMBER DC CHARGE RELAY OPENING
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumDCChargeRelayOpening
    ${verdict}    ${comment} =    Canakin Set Signal    NumDCchargRelayOpening_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER DC CHARGE RELAY OPENING to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumDCchargRelayOpening_BLMS
    should_be_true    ${verdict}    Failed to send BLMS NUMBER DC CHARGE RELAY OPENING

SEND BLMS NUMBER DC CHARGE RELAY OPENING WITH CURRENT
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumDCChargeRelayOpeningWithCurrent
    ${verdict}    ${comment} =    Canakin Set Signal    NumDCchargRelayOpenWithCurr_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER DC CHARGE RELAY OPENING WITH CURRENT to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumDCchargRelayOpenWithCurr_BLMS
    should_be_true    ${verdict}    Failed to send BLMS NUMBER DC CHARGE RELAY OPENING WITH CURRENT

SEND RESISTIVE STATE OF HEALTH
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to HVBattery/Status/SOH/ResistiveStateOfHealth
    ${verdict}    ${comment} =    Canakin Set Signal    HVBatResistiveStateOfHealth_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set RESISTIVE STATE OF HEALTH to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=HVBatResistiveStateOfHealth_BLMS
    should_be_true    ${verdict}    Failed to send RESISTIVE STATE OF HEALTH

SEND BLMS NUMBER HV BATTERY RELAYS OPENING
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/NumHVbattRelaysOpening
    ${verdict}    ${comment} =    Canakin Set Signal    NumHVbattRelaysOpening_BLMS    ${value}
    should_be_true    ${verdict}    Failed to set BLMS NUMBER HV BATTERY RELAYS OPENING to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=NumHVbattRelaysOpening_BLMS
    should_be_true    ${verdict}    Failed to set BLMS NUMBER HV BATTERY RELAYS OPENING

SEND FUEL DISPLAY LEVEL
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Fuel/DisplayedLevel
    ${verdict}    ${comment} =    Canakin Set Signal    FuelLevelDisplayed    ${value}
    should_be_true    ${verdict}    Failed to set FUEL DISPLAY LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=FuelLevelDisplayed
    should_be_true    ${verdict}    Failed to set FUEL DISPLAY LEVEL

CONFIGURE EVA_002 PARAMETERS
    SEND VEHICLE MAX AC CURRENT    15
    SEND VEHICLE CHARGE TYPE    1
    SET HEV BATTERY SOC    20
    SEND HVBATTERY TEMPERATURE    30
    SEND VEHICLE HVB TEMPERATURE MAX    35
    SEND VEHICLE HVB TEMPERATURE MIN    10
    SET EXTERNAL TEMPERATURE VALUE    25
    SET BATTERY ENERGY LEVEL    5
    SET USER SOC    40
    SEND VEHICLE BLMS SLAVE FAULT TYPE    1
    SEND VEHICLE BLMS MASTER FAULT TYPE    1
    SEND AVAILABLE ENERGY    50
    SEND VEHICLE BLMS INSTANT CURRENT    500
    SEND BATTERY HIGHEST CELL VOLTAGE PROBE ID    200
    SEND BATTERY LOWEST CELL VOLTAGE PROBE ID    110
    SEND CELL VOLTAGE MAX    4
    SEND CELL VOLTAGE MIN    2
    SEND HV ISOLATION IMPEDANCE    1000
    SEND BLMS NUMBER OF PHASES USED    1
    SET VEHICLE AUTONOMY DISPLAY    2
    SEND DISTANCE TOTALIZER    123
    SEND BLMS ACC CHARGE INLET TEMPERATURE    25
    SEND BLMS DC CHARGE INLET TEMPERATURE    30
    SEND BLMS CHG TEMPERATURE    40
    SEND BLMS CHG WATER TEMPERATURE    45
    SEND BLMS CHG AVAILABLE CHARGING POWER    20
    SEND BLMS NUMBER AC CHARGE STARTS    5000
    SEND BLMS NUMBER AC SMART CHARGING    6000
    SEND BLMS NUMBER AC SMART CHARGING BREAK    6000
    SEND BLMS NUMBER DC CHARGE RELAY OPENING    8000
    SEND BLMS NUMBER DC CHARGE RELAY OPENING WITH CURRENT    8000
    SEND RESISTIVE STATE OF HEALTH    100
    SEND DISTANCE TRIP UNIT    0
    SEND BLMS NUMBER HV BATTERY RELAYS OPENING    1000
    SEND VEHICLE POWER RELAY STATUS    Closed

SEND VEHICLE EV BLMS EM INVERTER FAULT TYPE
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/EV/BLMS/EM/InverterFaultType
    ${verdict}    ${comment} =    Canakin Set Signal    ME_InverterFaultType    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE EV BLMS EM INVERTER FAULT TYPE to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_InverterFaultType
    should_be_true    ${verdict}    Failed to set VEHICLE EV BLMS EM INVERTER FAULT TYPE

SEND VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL SYSTEM
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/FailureDisplay/ElectricalSystem
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecSysFailureDisplay_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL SYSTEM to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecSysFailureDisplay_EVA
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL SYSTEM

SEND VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL MOTOR
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/FailureDisplay/ElectricalMotor
    ${verdict}    ${comment} =    Canakin Set Signal    ME_ElecMotorFailureDisplay_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL MOTOR to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_ElecMotorFailureDisplay_EVA
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL MOTOR

SEND VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION REQUEST
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/DeactivationRequest
    ${verdict}    ${comment} =    Canakin Set Signal    ME_DeactivationRequest_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION REQUEST to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_DeactivationRequest_EVA
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION REQUEST

SEND VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION STATUS
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/ElectricalMachine/Main/DeactivationStatus
    ${verdict}    ${comment} =    Canakin Set Signal    ME_DeactivationStatus_EVA    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION STATUS to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=ME_DeactivationStatus_EVA
    should_be_true    ${verdict}    Failed to set VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION STATUS

CONFIGURE EVA_005 CONTEXT PARAMETERS
    SEND VEHICLE EV BLMS EM INVERTER FAULT TYPE    1
    SEND VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL SYSTEM    1
    SEND VEHICLE ELECTRICAL MACHINE MAIN FAILURE DISPLAY ELECTRICAL MOTOR    1
    SEND VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION REQUEST    0
    SEND VEHICLE ELECTRICAL MACHINE MAIN DEACTIVATION STATUS    1
    SEND DISTANCE TOTALIZER    123
    SEND AVAILABLE ENERGY    50

CONFIGURE DABR PERIODIC TRIGGER
    SEND VEHICLE SPEED VALUE    100
    SET ENGINE RPM    3500
    SEND VEHICLE MEAN EFFECTIVE TORQUE    200
    SEND VEHICLE BRAKE PRESSURE    3
    SEND ESC_LONGITUDINAL CORRECTED    1
    SEND ESC_TRANSVERSAL CORRECTED    1
    SEND DISTANCE TOTALIZER    123
    SEND VEHICLE FUEL DISPLAY LEVEL    30
    SET CABINE TEMPERATURE    20
    SET EXTERNAL TEMPERATURE VALUE    21
    SEND VEHICLE WHEEL PRESSURE FRONTLEFT    90
    SEND VEHICLE WHEEL PRESSURE FRONTRIGHT    90
    SEND VEHICLE WHEEL PRESSURE REARRIGHT    90
    SEND VEHICLE WHEEL PRESSURE REARLEFT    90
    SET REMAINING TIME    60
    SEND VEHICLE BLMS INSTANT CURRENT    200
    SET BATTERY ENERGY LEVEL    40

SEND VEHICLE FUEL DISPLAY LEVEL
    [Arguments]    ${value}
    [Documentation]    == High Level Description: ==
    ...    Send data related to Vehicle/Received/Fuel/DisplayedLevel
    ${verdict}    ${comment} =    Canakin Set Signal    Vehicle/Received/Fuel/DisplayedLevel    ${value}
    should_be_true    ${verdict}    Failed to set VEHICLE FUEL DISPLAY LEVEL to value ${value}
    ${verdict}    ${comment} =    Canakin Start Write    elements=Vehicle/Received/Fuel/DisplayedLevel
    should_be_true    ${verdict}    Failed to set VEHICLE FUEL DISPLAY LEVEL

CONFIGURE DABR DATA SINGLE TRIGGER
    SEND VEHICLE CHARGE STATUS    no_charge
    SEND DISTANCE TOTALIZER    123
    SET HEV BATTERY SOC    23
    SEND FUEL DISPLAY LEVEL    30
    SEND VEHICLE STATE COMMAND    AutoACC - BatTempoLevel
    SET CABINE TEMPERATURE    20
    SET EXTERNAL TEMPERATURE VALUE    21
    SEND VEHICLE MAINTENANCE OVERHAUL MILAGE MINIMUM    250
    SEND VEHICLE DOORS_STATUS COMMAND    AllDoors    closed
    CONFIGURE CAN FOR OUTSIDE LOCK STATE    False
    SEND VEHICLE WHEEL PRESSURE FRONTLEFT    90
    SEND VEHICLE WHEEL PRESSURE FRONTRIGHT    90
    SEND VEHICLE WHEEL PRESSURE REARRIGHT    90
    SEND VEHICLE WHEEL PRESSURE REARLEFT     90
    SET WHEEL FRONT RIGHT STATE    0
    SET WHEEL FRONT LEFT STATE    0
    SET WHEEL REAR RIGHT STATE    0
    SET WHEEL REAR LEFT STATE    0
    SEND FUEL LOW LEVEL    0
    SEND VEHICLE OIL PRESSURE WARNING STATUS COMMAND    1
    SET WATER TEMP WARNING    0
    SEND GLOBAL VEHICLE WARNING STATE    0
    SEND LOWBATTERY VOLTAGE    3
    SEND CRASH DETECTED    1
    SET REMAINING TIME   60
    SEND VEHICLE EV BLMS OPERATING TYPE    0
    SET HVBATTERY LOWALERT STATUS    1
    SET BATTERY ENERGY LEVEL    40

CONFIGURE BATTERY RCHS DATA
    [Arguments]    ${battery_value}=46      ${autonomy_display}=23    ${charge_type}=charge_in_progress     ${remaining_time}=70    ${distance_trip_0}=False
    [Documentation]    Configuration to simulate rchs data
    Run Keyword if    "${console_logs}" == "yes"     Log to console    CONFIGURE BATTERY RCHS DATA
    SET PLUG CONNECTED    1
    SET VEHICLE AUTONOMY DISPLAY    ${autonomy_display}
    SET BATTERY ENERGY LEVEL    ${battery_value}
    IF    'True' in "${distance_trip_0}"
        SEND DISTANCE TRIP UNIT    0
    END
    SET REMAINING TIME    ${remaining_time}
    SEND VEHICLE CHARGE STATUS    ${charge_type}

CONFIGURE BATTERY RCHS ALL DATA
    [Documentation]    Configuration to simulate all rchs data
    CONFIGURE BATTERY RCHS DATA
    SEND HVBATTERY TEMPERATURE    20
    SEND CHARGING POWER BLMS     100

SET APC ACC WITH SCENARIO
    [Arguments]     ${scenario}=None
    ${signal_value} =    GET VEHICLE STATES FROM SCENARIO    ${scenario}
    Set Suite Variable     ${vehicle_states_can_signal}    ${signal_value}
    IF    '${sweet400_bench_type}' not in "'${bench_type}'"
        Return From Keyword
    END
    SET APC ACC WITH VEHICLESTATES    ${signal_value}

GET VEHICLE STATES FROM SCENARIO
    [Arguments]     ${scenario}=None
    ${json} =    Evaluate    json.load(open("${CURDIR}/vehicle_sequence.json", "r"))    json
    ${int_value} =    Set Variable    ${None}
    FOR    ${index}    IN    @{json}
        IF    "${scenario}" == "${index}"
            ${signals} =    Get From Dictionary     ${json}    ${index}
        END
    END
    FOR    ${signal}    IN    @{signals}
        IF    "StatusVehicleStates" in "${signal}" or "Vehicle/Received/Status/VehicleStates" in "${signal}"
            ${value} =    Get From Dictionary     ${signals}    ${signal}
            ${value} =     Remove String    ${value}    b
            ${int_value} =    Convert To Integer    ${value}    2
        END
    END
    [Return]    ${int_value}

SET APC ACC WITH VEHICLESTATES
    [Arguments]    ${vehiclestates_signal_value}
    IF    '${sweet400_bench_type}' not in "'${bench_type}'" or '${vehiclestates_signal_value}' == '${None}'
        Return From Keyword
    END
    Log    SET APC and ACC WITH VEHICLESTATES with ${vehiclestates_signal_value}    console=${console_logs}
    IF    '${vehiclestates_signal_value}' >= '5' # = IGNITION
        SET APC STATUS    on
    ELSE
        SET APC STATUS    off
    END
    IF    '${vehiclestates_signal_value}' >= '2' # = CUTOFFPENDING
        SET ACC STATUS    on
    ELSE
        SET ACC STATUS    off
    END

SIMULATE TRIGGER FROM COMET
    [Arguments]    ${trigger}    ${ucd_version}    ${service_tpid}     ${ccs_arch}
    [Documentation]    == High Level Description: ==
    ...    trigger : Trigger need to simulated
    ...    ucd_version  :  UCD version in IVC
    ...    service_tpid  :  On which service , the signal need to simulated taken from COMET
    @{result} =  Split String    ${trigger}    /
    ${verdict}    ${comment} =  RETRIEVE AND SIMULATE TRIGGER    ${result}[-1]    ${ucd_version}    ${service_tpid}     ${ccs_arch}
    Should Be True    ${verdict}

REQUEST ANTIREPLAY SYNCRO SGW
    [Arguments]    ${can_bus}=can0    ${anti_replay_add_value}=1
    [Documentation]    Send tech ACK for remote order and send antireply sincro request for the next one
    ${verdict}    ${req_values} =    Canakin Wait For Can SGW Remote Order Request    ${remote_order}    ${120}
    Should be True    ${verdict}
    Dictionary Should Contain Sub Dictionary    ${req_values}    ${expected_reqs}    No Match
    Should be equal    ${expected_reqs['remote_order']}    ${req_values['remote_order']}    Remote Order decoded ${req_values['remote_order']} is not the expected one
    Should be equal    ${expected_reqs['action']}    ${req_values['action']}    Action decoded ${req_values['action']} is not the expected one
    # RHL option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option1']}    ${req_values['option1']}    Option1 decoded ${req_values['option1']} is not the expected one
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option2']}    ${req_values['option2']}    Option2 decoded ${req_values['option2']} is not the expected one
    # RLU option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RLU"    Should be equal    ${expected_reqs['option']}    ${req_values['option']}    Option1 decoded ${req_values['option']} is not the expected one
    # Preparing the ack with anti replay counter and sequence number
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + ${anti_replay_add_value}
    ${seq_num} =    Convert To Integer    ${req_values['sequence_number']}
    ${order} =    Convert To Integer    ${req_values['remote_order']}
    ${verdict}    ${comment} =    Canakin Send Can Remote Order Technical Ack    ${ack_ecu}    ${res_counter}    ${order}    ${seq_num}   bus=${can_bus}
    should_be_true    ${verdict}    Fail to CHECK VEHICLE RECEIVE REMOTE ORDER: ${comment}
    # Preparing the ack with anti replay counter +10 reguest
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + 10
    ${verdict}    ${comment} =     Canakin Send Can Antireplay Synchro Request    ${ack_ecu}    ${res_counter}    bus=${can_bus}
    Should be True    ${verdict}    ${comment}
    Sleep    15
    ${verdict} =    Canakin Unsubscribe Can SGW Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can SGW Remote Order

REQUEST ANTIREPLAY SYNCRO IVC
    [Arguments]    ${can_bus}=can0    ${anti_replay_add_value}=1
    [Documentation]    Send tech ACK for remote order and send antireply sincro request for the next one
    ${verdict}    ${req_values} =    Canakin Wait For Can TCU Remote Order Request    ${remote_order}    ${120}
    Should be True    ${verdict}
    Dictionary Should Contain Sub Dictionary    ${req_values}    ${expected_reqs}    No Match
    Should be equal    ${expected_reqs['remote_order']}    ${req_values['remote_order']}    Remote Order decoded ${req_values['remote_order']} is not the expected one
    Should be equal    ${expected_reqs['action']}    ${req_values['action']}    Action decoded ${req_values['action']} is not the expected one
    # RHL option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option1']}    ${req_values['option1']}    Option1 decoded ${req_values['option1']} is not the expected one
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option2']}    ${req_values['option2']}    Option2 decoded ${req_values['option2']} is not the expected one
    # RLU option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RLU"    Should be equal    ${expected_reqs['option']}    ${req_values['option']}    Option1 decoded ${req_values['option']} is not the expected one
    # Preparing the ack with anti replay counter and sequence number
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + ${anti_replay_add_value}
    ${seq_num} =    Convert To Integer    ${req_values['sequence_number']}
    ${order} =    Convert To Integer    ${req_values['remote_order']}
    ${verdict}    ${comment} =    Canakin Send Can Remote Order Technical Ack    ${ack_ecu}    ${res_counter}    ${order}    ${seq_num}   bus=${can_bus}
    should_be_true    ${verdict}    Fail to CHECK VEHICLE RECEIVE REMOTE ORDER: ${comment}
    # Preparing the ack with anti replay counter +10 reguest
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + 10
    ${verdict}    ${comment} =     Canakin Send Can Antireplay Synchro Request    ${ack_ecu}    ${res_counter}    bus=${can_bus}
    Should be True    ${verdict}    ${comment}
    Sleep    15
    ${verdict} =    Canakin Unsubscribe Can TCU Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can SGW Remote Order

CHECK IVC REMOTE ORDER
    [Arguments]    ${can_bus}=can0    ${anti_replay_add_value}=1
    ${verdict}    ${req_values} =    Canakin Wait For Can TCU Remote Order Request    ${remote_order}    ${120}
    Should be True    ${verdict}
    Dictionary Should Contain Sub Dictionary    ${req_values}    ${expected_reqs}    No Match
    Should be equal    ${expected_reqs['remote_order']}    ${req_values['remote_order']}    Remote Order decoded ${req_values['remote_order']} is not the expected one
    Should be equal    ${expected_reqs['action']}    ${req_values['action']}    Action decoded ${req_values['action']} is not the expected one
    # RHL option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option1']}    ${req_values['option1']}    Option1 decoded ${req_values['option1']} is not the expected one
    Run Keyword If    ${expected_reqs['remote_order']} == "RHL"    Should be equal    ${expected_reqs['option2']}    ${req_values['option2']}    Option2 decoded ${req_values['option2']} is not the expected one
    # RLU option check
    Run Keyword If    ${expected_reqs['remote_order']} == "RLU"    Should be equal    ${expected_reqs['option']}    ${req_values['option']}    Option1 decoded ${req_values['option']} is not the expected one
    # Preparing the ack with anti replay counter and sequence number
    ${req_counter} =    Convert To Integer    ${req_values['anti_replay_counter']}
    ${res_counter} =    Evaluate    ${req_counter} + ${anti_replay_add_value}
    ${seq_num} =    Convert To Integer    ${req_values['sequence_number']}
    ${order} =    Convert To Integer    ${req_values['remote_order']}
    ${verdict}    ${comment} =    Canakin Send Can Remote Order Technical Ack    ${ack_ecu}    ${res_counter}    ${order}    ${seq_num}   bus=${can_bus}
    should_be_true    ${verdict}    Fail to CHECK VEHICLE RECEIVE REMOTE ORDER: ${comment}
    ${verdict} =    Canakin Unsubscribe Can TCU Remote Order Request
    should_be_true    ${verdict}    Fail to Unsubscribe Can TCU Remote Order

SEND CAN SEQUENCE TO STOP VEHICLE
    [Arguments]    ${wait_before_go_to_sleep}=10
    Log     Send Sleep CAN Sequences    console=${console_logs}
    ${verdict}    ${comment} =    Canakin Play Scenario    stop_engine
    Should Contain    ${verdict}    OK
    ${verdict}    ${comment} =    Canakin Play Scenario    lock_door_step1
    Should Contain    ${verdict}    OK
    Sleep    5
    ${verdict}    ${comment} =    Canakin Play Scenario    lock_door_step2
    Should Contain    ${verdict}    OK
    Sleep    ${wait_before_go_to_sleep}
    ${verdict}    ${comment} =    Canakin Play Scenario    go_to_sleep_step1
    Should Contain    ${verdict}    OK
    Sleep    5
    ${verdict}    ${comment} =    Canakin Play Scenario    go_to_sleep_step2
    Should Contain    ${verdict}    OK

CONFIGURE VEHICLE CRASH
    [Arguments]    ${crash_order}    ${crash_detected}    ${crash_out_order}
    [Documentation]    Configuration to simulate data related to crash detection
    Run Keyword if    "${console_logs}" == "yes"     Log to console    CONFIGURE VEHICLE CRASH
    SEND CRASH ORDER   ${crash_order}
    SEND CRASH DETECTED    ${crash_detected}
    SEND CRASH DETECTION OUT OF ORDER    ${crash_out_order}

CHECK ECALL MUTE ORDER
    [Arguments]    ${expected_value}    ${timeout}=${300}
    [Documentation]    == High Level Description: ==
    ...     Check the IVC sent ecall mute order CAN signal to the  BCM stub.
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    [Tags]    Automated    VEHICLE    CAN
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    Multimedia/Sent/MuteRadioOrder    ${expected_value}    ${timeout}
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}    Multimedia/Sent/MuteRadioOrder
    Should Be True    ${verdict}    ${comment}

CHECK ECALL STATUS DISPLAY
    [Arguments]    ${expected_value}    ${timeout}=${600}
    [Documentation]    == High Level Description: ==
    ...     Check the IVC sent ecall status display CAN signal to the  BCM stub.
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    [Tags]    Automated    VEHICLE    CAN
    ${verdict}    ${comment} =    Canakin Seek Signal    ${bus}    Vehicle/Sent/eCall/StatusDisplay    ${expected_value}    ${timeout}
    Should Be True    ${verdict}    ${comment}
    ${verdict}    ${comment} =    Canakin Get Seek Signal Result    ${bus}    Vehicle/Sent/eCall/StatusDisplay
    Should Be True    ${verdict}    ${comment}

SEND CAN MESSAGE WITH BUS
    [Arguments]    ${bus}    ${signal_name}    ${signal_value}
    [Documentation]    Send a CAN message and ensure it changed the state of a UI element
    ${verdict}    ${comment} =    Canakin Set Signal    ${signal_name}    ${signal_value}
    Should Be True    ${verdict}    Failed to set signal ${signal_name} with the value=${signal_value}
    ${verdict}    ${comment} =    Canakin Write    msg_name=${signal_name}    bus=${bus}
    Should Be True    ${verdict}    Failed to send the can frame which contains the signal ${signal_name}
