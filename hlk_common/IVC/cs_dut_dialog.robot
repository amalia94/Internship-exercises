#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Resource          ${CURDIR}/../Tools/bench_config.robot
Resource          ${CURDIR}/../Vehicle/CAN/can_remote_services.robot

*** Keywords ***
CHECKSET POWER
    [Arguments]    ${target_id}    ${mode}
    [Documentation]    == High Level Description: ==
    ...    Check DUT state
    ...    ${target_id} the dedicated DUT
    ...    ${mode} the expected mode (on/off)
    ...    Check that the _target_id_ is already set in the expected status _status_,
    ...    if not the _target_id_ is set to the _status_ requested
    ...    == Parameters: ==
    ...    - target_id: name of target_id
    ...    - status: on / off
    ...    == Expected Results: ==
    ...    output: passed if the target_id is set on the expected status
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | Check that the _target_id_ is already set in the expected status _status_, if not the _target_id_ is set to the _status_ requested | Accepted by TD | 2.5 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | Check that the _target_id_ is already set in the expected status _status_, if not the _target_id_ is set to the _status_ requested | Accepted by TD | 2.5 |
    [Tags]    Automated    Power
    Run Keyword If    "${mode}" == "on"    CHECKSET POWER ON    ${target_id}
    Run Keyword If    "${mode}" == "off"    CHECKSET POWER OFF    ${target_id}

CHECKSET POWER ON
    [Arguments]    ${target_id}
    LOAD TEST CASE CONFIGURATION
    LOAD CAN SCENARIOS

CHECKSET POWER OFF
    [Arguments]    ${target_id}
    UNLOAD BENCH CONFIGURATION
    SEND VEHICLE WAKEUP COMMAND    sleep
    Sleep    5
    STOP CAN WRITING
    QUIT CAN TOOL
    Sleep    100
