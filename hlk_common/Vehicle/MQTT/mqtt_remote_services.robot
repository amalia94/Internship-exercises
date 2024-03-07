#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Resource          ${CURDIR}/../../Tools/bench_config.robot
Library           rfw_services.cirrus.CirrusLib    @{cirrus_config_data}
Library           Collections
Library           String
Variables         ../../unsorted/mqtt_data.yaml
Variables         ../../unsorted/vnext_protocol_gateway.yaml

*** Variables ***
@{cirrus_config_data}    APIM    EVENT_HUB    MQTT_HEADER    MQTT_DATA
${tstart}    None

*** Keywords ***
CHECK VNEXT TO IVC MESSAGE RLU
    [Arguments]    ${message_name}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVC.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Lock/Unlock    VNEXT MQTT
    ${message_type} =    Set Variable    ${RLU_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RLU_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    Run Keyword If    "${instance.lower()}"=="kmr"    RECORD VNEXT DATE & TIME    tstart
    ${params} =    Run Keyword If    "${instance.lower()}"=="kmr"    Set To Dictionary    ${RLU_req['${message_name}']['params']}    timestamp=${tstart}
    ...    ELSE    Copy Dictionary    ${RLU_req['${message_name}']['params']}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    ${extract_CommandId_RLU} =    Fetch From Right    ${comment}    :
    Set Test Variable    ${CommandId_RLU}    ${extract_CommandId_RLU}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE RLU with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE RLU with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE RLU
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Lock/Unlock    VNEXT MQTT
    Log     CHECK UPLINK
    ${message_type} =    Set Variable    ${RLU_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RLU_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${RLU_resp['${message_name}']['params']}
   Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE RLU with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE RES
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Engine Start    VNEXT MQTT
    ${message_type} =    Set Variable    ${RES_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RES_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    Run Keyword If    "${instance.lower()}"=="kmr"    RECORD VNEXT DATE & TIME    tstart
    ${params} =    Run Keyword If    "${instance.lower()}"=="kmr"    Set To Dictionary    ${RES_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}
    ...    ${RES_req['${message_name}']['params']}
    ${extract_CommandId_RES} =    Fetch From Right    ${comment}    :
    Set Test Variable    ${CommandId_RES}    ${extract_CommandId_RES}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE RES with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE RES
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Engine Start    IVC MQTT
    Log     CHECK UPLINK
    ${message_type} =    Set Variable    ${RES_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RES_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${RES_resp['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE RES with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE UCD
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVC.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    Pass if message content is as expected
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Connected Services    VNEXT MQTT
    Return From Keyword if    "${message_name}" == "doors_status_request" or "${message_name}" == "res_status request" or "${message_name}" == "RemoteUploadRequest"
    ${message_type} =    Set Variable    ${UCD_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${UCD_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    Run Keyword If    "${instance.lower()}"=="kmr"    RECORD VNEXT DATE & TIME    tstart
    ${params} =    Run Keyword If    "${instance.lower()}"=="kmr"    Set To Dictionary    ${UCD_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}
    ...    ${UCD_req['${message_name}']['params']}
    ${extract_CommandId_UCD} =    Fetch From Right    ${comment}    :
    Set Test Variable    ${CommandId_UCD}    ${extract_CommandId_UCD}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE UCD with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE UCD
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Connected Services    IVC MQTT
    ${message_type} =    Set Variable    ${UCD_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${UCD_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${params} =    Copy Dictionary    ${UCD_resp['${message_name}']['params']}
    IF    "${instance.lower()}" == "kmr"
        RECORD VNEXT DATE & TIME    tstart
        ${params} =    Set To Dictionary    ${params}   timestamp=${tstart}
    END
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE UCD with comment: ${comment}
    IF    "${message_name}" == "configuration_read_request_response"
        ${response} =    Fetch From Right    ${comment}   "cfgresd": "
        Log   Fetched Configuration Response is: ${response}
        Should Not Be Empty    ${response}    UCD config is Empty
    END

CHECK VNEXT TO IVC MESSAGE RHL
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVC.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    VNEXT MQTT
    ${message_type} =    Set Variable    ${RHL_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RHL_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    Run Keyword If    "${instance.lower()}"=="kmr"    RECORD VNEXT DATE & TIME    tstart
    ${params} =    Run Keyword If    "${instance.lower()}"=="kmr"    Set To Dictionary    ${RHL_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}
    ...    ${RHL_req['${message_name}']['params']}
    ${extract_CommandId_RHL} =    Fetch From Right    ${comment}    :
    Set Test Variable    ${CommandId_RHL}    ${extract_CommandId_RHL}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE RHL with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE RHL
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    IVC MQTT
    Log     CHECK UPLINK
    ${message_type} =    Set Variable    ${RHL_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RHL_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${RHL_resp['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE RHL with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE REDI
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by VNEXT to IVC
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Diagnostic on Demand
    ${message_type} =    Set Variable    ${REDI_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${REDI_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${REDI_req['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE REDI with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE REDI
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Diagnostic on Demand
    ${message_type} =    Set Variable    ${REDI_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${REDI_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${REDI_resp['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE REDI with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE SRP
    [Arguments]    ${message_name}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVC.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT MQTT
    ${message_type} =    Set Variable    ${SRP_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${SRP_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    RECORD VNEXT DATE & TIME    tstart
    ${params} =    Run Keyword If    "${message_name}" == "init_pin_code"
    ...    Create Dictionary    srpi=${username}    srpv=${srp_verifier}    srpsa=${srp_client_salt}    timestamp=${tstart}
    ...    ELSE IF    "${message_name}" == "init_pin_code"    Create Dictionary    srpi=${username}    srpv=${srp_verifier}
    ...    srpsa=${srp_client_salt}
    ...    ELSE IF    "${message_name}" == "salt_request"    Create Dictionary    srpi=${username}    srpa=${srp_value_A}
    ...    ELSE    Copy Dictionary    ${SRP_req['${message_name}']['params']}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    ${extract_CommandId_SRP} =    Fetch From Right    ${comment}    :
    Set Test Variable    ${SRP_CommandId}    ${extract_CommandId_SRP}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE SRP with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE SRP with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE SRP
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages send by IVC to VNEXT.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    IVC MQTT
    Log    Keyword disabled for now due to: https://jira.dt.renault.com/browse/CCSEXT-28864
    Return From Keyword
    ${message_type} =    Set Variable    ${SRP_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${SRP_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Notification
    ${params} =    Run Keyword If    "${message_name}" == "salt_request_status"
    ...    Create Dictionary    srpb=${srp_value_B}    srps=${srp_server_salt}    srpls=OK
    ...    ELSE    Copy Dictionary    ${SRP_resp['${message_name}']['params']}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE SRP with comment: ${comment}

CHECK VNEXT TO IVI MESSAGE PUSH MESSAGE
    [Arguments]    ${message_name}    ${requester}=vNext
    [Documentation]    == High Level Description: ==
    ...    Check if a MQTT messages is sent by Vnext to the IVC
    ...    with a given content defined in the_message_name}
    ...    == Parameters: ==
    ...    - _message_name_: name of a message containing a defined message
    ...    - _requester_: the instance form where the request in coming
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Push Messages    VNEXT MQTT
    ${message_type} =    Set Variable    ${PM_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${PM_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    &{dict_param} =    Run Keyword If    "${requester.lower()}"=="kmr"    Create Dictionary    pmt1=${kmr_otp_code}
    ${verdict}    ${comment} =    Run Keyword If    "${requester.lower()}"=="kmr"    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${dict_param}
    ...     ELSE     CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${PM_req['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVI MESSAGE PUSH MESSAGE with comment: ${comment}

CHECK VNEXT TO IVI MESSAGE PUSH MESSAGE MYR
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check if a MQTT messages is sent by Vnext to the IVI
    ...    with a given content defined in the_message_name}
    ...    == Parameters: ==
    ...    - _message_name_: name of a message containing a defined message
    ...    - _requester_: the instance form where the request in coming
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Push Messages    VNEXT MQTT

    ${message_type} =    Set Variable    ${PM_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${PM_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${params} =    Set To Dictionary    ${PM_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVI MESSAGE PUSH MESSAGE with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE MYCARFINDER
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check if Vnext sends MQTT message to IVC
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    My Car Finder Service    VNEXT MQTT
    ${message_type} =    Set Variable    ${UCD_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${UCD_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}
    ...    ${target_id}    ${direction}    ${UCD_req['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE MYCARFINDER with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE MYCARFINDER
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check if IVC sends MQTT message to Vnext.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    Pass if message content is as expected
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    My Car Finder Service    VNEXT MQTT
    ${message_type} =    Set Variable    ${UCD_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${UCD_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${UCD_resp['${message_name}']['params']}
    Should Be True    ${verdict}    Failed to CHECK IVC TO VNEXT MESSAGE MYCARFINDER with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE CIPHER KEY
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check a mqtt messages content send by IVC to VNEXT by MQTT
    ...    == Parameters: ==
    ...    - _message_name_: name of a message
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Vehicule Activation Service    VNEXT MQTT
    ${message_type} =    Set Variable    ${Notifications['CIPHER_KEY']['MessageType']}
    ${target_id} =    Set Variable    ${Notifications['CIPHER_KEY']['TargetId']}
    ${direction} =    Set Variable    Notification
    ${params} =    Set To Dictionary    ${Notifications['CIPHER_KEY']['params']['${message_name}']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}
    ...    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE CIPHER KEY with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE CIPHER KEY
    [Arguments]    ${message_name}    ${negative_TC}=${False}
    [Documentation]    == High Level Description: ==
    ...    Check a mqtt messages content send by Vnext to IVC, by MQTT
    ...    == Parameters: ==
    ...    - _message_name_: name of a message
    ...    - _negative_TC_: used for implementation of negative test cases
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Vehicule Activation Service    VNEXT MQTT
    ${message_type} =    Set Variable    ${CIPHER_KEY_REQ['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${CIPHER_KEY_REQ['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${cipher_params} =    Create Dictionary    ck=${key}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}
    ...    ${target_id}    ${direction}    ${cipher_params}
    Run Keyword if    ${negative_TC} == ${False}
    ...    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE CIPHER KEY with comment ${comment}
    ...    ELSE    Should Not Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE CIPHER KEY, didn't expect any notification, comment: ${comment}

CHECK VNEXT TO IVC MESSAGE BCI
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check the MQTT message content sent by Vnext to IVC with a charge block/unblock request.
    ...    == Parameters: ==
    ...    _message_name_: name of a message corresponding to different content to check.
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Battery Charge Inhibitor    VNEXT APIM
    ${message_type} =    Set Variable    ${BCI_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${BCI_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    Run Keyword If    "${tstart}" != "None"    Set To Dictionary    ${BCI_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}
    ...    ${BCI_req['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE BCI with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE BCI
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check the MQTT message content sent by IVC to VNEXT with a charge block/unblock request.
    ...    == Parameters: ==
    ...    _message_name_: name of a message corresponding to different content to check.
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Battery Charge Inhibitor    VNEXT MQTT
    ${message_type} =    Set Variable    ${BCI_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${BCI_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${BCI_resp['${message_name}']['params']}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE BCI with comment: ${comment}

CHECK IVI TO VNEXT MESSAGE
    [Arguments]    ${message_name}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if IVI sends MQTT message to Vnext
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    - _status_: status of the message
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Service subscription management    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${SA_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${SA_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Notification
    ${params} =    Set To Dictionary    ${SA_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Run Keyword If    "${status}" == "activated"    Should Be True    ${verdict}
    ...    ELSE    Should Be Equal    "${verdict}"    "False"

CHECK VNEXT TO IVC MESSAGE RHOO
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVC with a new remote start HVAC request.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    RHOO    VNEXT MQTT
    ${message_type} =    Set Variable    ${RHOO_req['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RHOO_req['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${params} =    Set To Dictionary    ${RHOO_req['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    ${extract_CommandId_RHOO} =    Fetch From Right    ${comment}    :
    Set Test Variable    ${CommandId_RHOO}    ${extract_CommandId_RHOO}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE RHOO with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE RHOO
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by IVC to Vnext with an acknowledgement of the remote synchronization request.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check.
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    RHOO    VNEXT MQTT
    ${message_type} =    Set Variable    ${RHOO_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RHOO_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${params} =    Set To Dictionary    ${RHOO_resp['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE RHOO with comment: ${comment}

CHECK VNEXT TO IVC MESSAGE RCAC
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVC.
    ...    == Parameters: ==
    ...    - _message_name_: ScheduleSynchro
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote synchronization    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${Remote_synchro['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${Remote_synchro['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${params} =    Set To Dictionary    ${Remote_synchro['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVC MESSAGE RCAC with comment: ${comment}

CHECK IVC TO VNEXT MESSAGE RCAC
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Check if the IVC sends the proper MQTT message content to Vnext
    ...    == Parameters: ==
    ...    - _message_name_: ScheduleSynchro_ACK
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Remote synchronization    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${Remote_synchro['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${Remote_synchro['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Uplink
    ${params} =    Set To Dictionary    ${Remote_synchro['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE RCAC with comment: ${comment}

CHECK VNEXT TO IVI MESSAGE RHVS
    [Arguments]    ${message_name}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVI with a new remote synchronization request.
    ...    == Parameters: ==
    ...    _message_name_: name of a message corresponding to a specific content that should be checked.
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RHVS    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${RHVS_synchro['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RHVS_synchro['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${params} =    Set To Dictionary    ${RHVS_synchro['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVI MESSAGE RHVS with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVI MESSAGE RHVS with comment: ${comment}

CHECK VNEXT TO IVI MESSAGE RCSS
    [Arguments]    ${message_name}    ${data_profile}=${None}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by Vnext to IVI with a new remote synchronization request.
    ...    == Parameters: ==
    ...    _message_name_: name of a message corresponding to different contents to be checked.
    ...    _data_profile_: represents an optional parameter which contains all the schedule attributes sent with the sync_response message, in case it is needed.
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${RCSS_synchro['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RCSS_synchro['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Downlink
    ${create_dict} =    Run Keyword If    ${RCSS_synchro['${message_name}']['params']}==${None}    Create Dictionary    timestamp=${tstart}
    ...    ELSE    Set To Dictionary    ${RCSS_synchro['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${create_dict}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVI MESSAGE RCSS with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK VNEXT TO IVI MESSAGE RCSS with comment: ${comment}

CHECK IVI TO VNEXT MESSAGE RCSS
    [Arguments]    ${message_name}    ${data_profile}=${None}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by IVI to Vnext with an acknowledgement of the remote synchronization request.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check
    ...    - _data_profile_: represents an optional parameter containing the data profile that shall be checked
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RCSS    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${RCSS_synchro['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RCSS_synchro['${message_name}']['TargetId']}
    ${direction}=    Set Variable If    "${message_name}" == "sync_request" or "${message_name}" == "final_sync_ack" or "${message_name}" == "sync_request_schedule_one_calendar" or "${message_name}" == "sync_request_always"     Notification    Uplink
    ${params} =    Set To Dictionary    ${RCSS_synchro['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE RCSS with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE RCSS with comment: ${comment}
    [Return]    ${verdict}    ${comment}

CHECK IVI TO VNEXT MESSAGE RHVS
    [Arguments]    ${message_name}    ${TC_folder}=${EMPTY}    ${expected_status}=success
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by IVI to Vnext with an acknowledgement of the remote synchronization request.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to a specific content that should be checked
    ...    - _TC_folder_: The folder where the TC present
    ...    - _expected_status_: success/failed based on the expected result(success if ack received, failed if ack not received)
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RHVS    VNEXT MQTT
    ${message_type} =    Set Variable    ${RHVS_synchro['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${RHVS_synchro['${message_name}']['TargetId']}
    ${direction}=    Set Variable If    "${message_name}" == "sync_request_two_calendars" or "${message_name}" == "final_sync_ack"     Notification    Uplink
    ${params} =    Set To Dictionary    ${RHVS_synchro['${message_name}']['params']}    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Return From Keyword If    "${expected_status}" == "failed" and "Timeout reached" in '''${comment}'''
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE RHVS with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE RHVS with comment: ${comment}
    [Return]    ${verdict}    ${comment}

CHECK IVC TO VNEXT MESSAGE VA
    [Arguments]    ${message_name}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by IVC to Vnext.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check.
    ...    == Expected Results: ==
    ...    output: passed if MQTT for certificateInstalled is found
    ...    fails otherwise
    [Tags]    Automated    Part enrollment success    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    GET IVC TIME    tstart
    ${message_type} =    Set Variable    ${VA_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${VA_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Notification
    ${params} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run Keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE VA with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE VA with comment: ${comment}

CHECK IVI TO VNEXT MESSAGE VA
    [Arguments]    ${message_name}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by IVI to Vnext with an acknowledgement of the remote synchronization request.
    ...    == Parameters: ==
    ...    - _message_name_: name of a message corresponding to different content to check.
    ...    == Expected Results: ==
    ...    output: pass if MQTT for certificateInstalled is found
    ...    else otherwise
    [Tags]    Automated    Part enrollment success    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${VA_resp['${message_name}']['MessageType']}
    ${target_id} =    Set Variable    ${VA_resp['${message_name}']['TargetId']}
    ${direction} =    Set Variable    Notification
    ${params} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    ${direction}    ${params}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run Keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE VA with comment: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE VA with comment: ${comment}

CHECK MESSAGE DATA COLLECTION TO VNEXT
    [Arguments]    ${device}    ${Notification}=True
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content send by IVC/IVI to Vnext.
    ...    == Parameters: ==
    ...    - _device_: it can be IVI or IVC
    ...    == Expected Results: ==
    ...    output: passed if MQTT message is found
    ...    fails otherwise
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${target_id} =    Set Variable If    "${device}".lower() == "ivc"    IVCDataCollection    IVIDataCollection
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    RemoteNotification     ${target_id}    Notification    ${time}
    Run Keyword If    "${Notification}" == "True"    Should Be True    ${verdict}    Fail to CHECK MQTT MESSAGE with comment: ${comment}
    Run Keyword If    "${Notification}" == "False"    Should Not Be True    ${verdict}    CHECK MQTT MESSAGE is Success with comment: ${comment}
    Return From Keyword If    "${Notification}" == "False"
    ${extract_dict_from_right} =    Fetch From Right    ${comment}    A compatible message
    ${extract_dict_from_left} =    Fetch From Left    ${extract_dict_from_right}    found inside for CommandId:None
    ${convert_to_dict} =    Convert To Dictionary    ${extract_dict_from_left}
    Set Test Variable    ${id}    ${convert_to_dict['lognm']}
    ${convert_id_to_dict} =    Convert To Dictionary    ${id}
    Set Test Variable    ${seq_no}    ${convert_id_to_dict['message']['sequence']}
    Set Test Variable    ${session_id}    ${convert_id_to_dict['session_uuid']}
    Should Be True    ${verdict}    Fail to CHECK IVC TO VNEXT MESSAGE DATA COLLECION with comment: ${comment}

SUBSCRIBE PGW MESSAGES
   [Arguments]    ${session}    ${message_type}    ${target_id}    ${direction}    ${delay}
   [Documentation]        == High Level Description: ==
    ...     Function used to subscribe protocol gw appropriate notifications matching given
    ...        criteria (notification_type, message_type)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${comment} =    SUBSCRIBE PROTOCOLGATEWAY MESSAGES    ${session}    ${message_type}    ${target_id}    ${direction}    ${delay}
    Should Be True    ${verdict}    ${comment}

UNSUBSCRIBE PGW MESSAGES
   [Arguments]    ${session}
   [Documentation]        == High Level Description: ==
    ...     Function used to unsubscribe protocol gw appropriate session
    ...        criteria (notification_type, message_type)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${comment} =    UNSUBSCRIBE PROTOCOLGATEWAY MESSAGES    ${session}
    Should Be True    ${verdict}    ${comment}

WAIT FOR PGW MESSAGES
    [Arguments]    ${session}    ${duration}    ${time_start}    ${time_stop}
    [Documentation]        == High Level Description: ==
    ...     Wait for mqtt event published messages for a session
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if notification containing below field is published
    ${verdict}    ${comment}    ${response_pgw} =    WAIT FOR PROTOCOLGATEWAY MESSAGES    ${session}    ${duration}    ${time_start}    ${time_stop}
    Should Be True    ${verdict}    ${comment}
    Set Test Variable     ${response_pgw}

CHECK MESSAGE DATA COLLECTION TO VNEXT FOR IVC CRASH
    [Arguments]    ${session}    ${duration}    ${time_start_crash}    ${time_stop_crash}
    [Documentation]    == High Level Description: ==
    ...    Check MQTT messages content for IVC ApplicationCrash send by IVC to Vnext.
    ...    == Parameters: ==
    ...    - _device_: it can be IVC
    ...    == Expected Results: ==
    ...    output: passed if MQTT message is found
    ...    fails otherwise
    WAIT FOR PGW MESSAGES    ${session}    ${duration}    ${time_start_crash}    ${time_stop_crash}
    ${response_pgw} =    Convert to String       ${response_pgw}
    ${contains}=  Evaluate   "ApplicationCrash" in """${response_pgw}"""
    Should Be True    ${contains}    Fail to CHECK IVC TO VNEXT MESSAGE DATA COLLECION with comment: Not retrieved Protocolgateway Msgs for ApplicationCrash
    ${extract_dict_from_crash} =    Fetch From Right    ${response_pgw}    ApplicationCrash
    ${extract_session_id_from_left} =    Fetch From Left    ${extract_dict_from_crash}    logns
    ${split_session_id} =    Split String     ${extract_session_id_from_left}    :
    ${start_index} =    Set Variable    ${split_session_id[-1].find('\"') + 1}
    ${end_index} =    Set Variable    ${split_session_id[-1].find('\"') + 37}
    ${extracted_session_id} =    Get Substring   ${split_session_id[-1]}   ${start_index}   ${end_index}
    ${session_id} =    Set Variable    ${extracted_session_id}
    Set Test Variable     ${session_id}
    ${extract_seq_no_from_left} =    Fetch From Left    ${extract_dict_from_crash}    schema
    ${split_seq_no} =    Split String     ${extract_seq_no_from_left}    :
    ${split_seq_no_from_left} =    Fetch From Left    ${split_seq_no}[-1]    }
    ${seq_no} =    Set Variable    ${split_seq_no_from_left}
    Set Test Variable     ${seq_no}


CHECK VNEXT MQTT NOTIFICATION ANTIFLOODING
    [Documentation]        == High Level Description: ==
    ...     Check if notification as a result of the CGWViolation_antiflooding.
    ...    == Parameters: ==
    ...    _state_: value
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    RemoteNotification     CGWViolation    Notification    ${time}
    Should Be True    ${verdict}    Fail to CHECK VNEXT MQTT NOTIFICATION ANTIFLOODING with comment: ${comment}

CHECK VNEXT MQTT NOTIFICATION RDIAGLOG
    [Documentation]   Kw used to check Rdiaglog notification.
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    RemoteNotification     RDIAGLog    Notification    ${time}
    Should Be True    ${verdict}    Fail to CHECK VNEXT MQTT NOTIFICATION RDIAGLOG with comment: ${comment}
    ${extract_rdiagid} =    Fetch From Right    ${comment}    rdiagUploadId:
    ${extract_rdiagid} =    Fetch From Left    ${extract_rdiagid}    ,
    Set Test Variable    ${rdiagUploadId}    ${extract_rdiagid}

CHECK IVI TO VNEXT MESSAGE FACTORY RESET
    [Documentation]    == High Level Description: ==
    ...    == Expected Results: ==
    ...    output: pass if MQTT for certificateInstalled is found
    [Tags]    Automated    VNEXT MQTT
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${message_type} =    Set Variable    ${Factory_reset['reset']['MessageType']}
    ${target_id} =    Set Variable    ${Factory_reset['reset']['TargetId']}
    ${params} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    ${message_type}    ${target_id}    Notification    ${params}
    Should Be True    ${verdict}    Fail to CHECK IVI TO VNEXT MESSAGE FACTORY RESET with comment: ${comment}

CHECK VNEXT MQTT NOTIFICATION IVCVIOLATION
    [Arguments]    ${Notification}=True
    [Documentation]        == High Level Description: ==
    ...     Check if notification as a result of the IVCVIOLATION.
    ...    == Parameters: ==
    ...    _notification_: value
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    RemoteNotification    IVC2SOCsecuritylog    Notification    ${time}
    Run Keyword If    "${Notification}" == "True"    Should Be True    ${verdict}    Fail to CHECK VNEXT MQTT NOTIFICATION IVCVIOLATION with comment: ${comment}
    Run Keyword If    "${Notification}" == "False"    Should Not Be True    ${verdict}    CHECK VNEXT MQTT NOTIFICATION IVCVIOLATION is success with comment: ${comment}

CHECK VNEXT REMOTE DIAGNOSIS NOTIFICATION ODB
    [Arguments]    ${obfcm}
    [Documentation]        == High Level Description: ==
    ...     Check that Vnext publishes a OBFCM Regulatory notification containing the data retrieved by the [IVC Platform]
    ...    == Parameters: ==
    ...    _obfcm_: target id of the notification
    ...    == Expected Results: ==
    ...    output: passed if MQTT message is found
    ...    fails otherwise
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${target_id} =     Run Keyword If   "${obfcm}".lower() == "obfcm_regulatory"    Set Variable    OBDRegulatory
    ...    ELSE IF    "${obfcm}".lower() == "obfcm_alliance"    Set Variable    OBDAlliance
    ...    ELSE    Fail    Target ${obfcm} is not valid
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    RemoteNotification     ${target_id}    Notification    ${time}
    Should Be True    ${verdict}    Fail to CHECK VNEXT REMOTE DIAGNOSIS NOTIFICATION ODB with comment: ${comment}

CHECK VNEXT PROTOCOL GATEWAY
    [Arguments]    ${notification}
    [Documentation]        == High Level Description: ==
    ...     Check that On VNext Protocol Gateway the desired notification should be received
    ...    == Parameters: ==
    ...    _notification_: key of the notification that should be received
    ...    == Expected Results: ==
    ...    output: passed if MQTT message is found
    ...    fails otherwise
    Run Keyword If    "${tstart}" == "None"    Fail    Please record the timestamp of your simulation
    ${message_type} =    Set Variable    ${Protocol_Notification['${notification}']['MessageType']}
    ${target_id} =    Set Variable    ${Protocol_Notification['${notification}']['TargetId']}
    ${data} =    Run Keyword If    ${Protocol_Notification['${notification}']['params']}==${None}    Fail    Data params are mandatory
    ...    ELSE    Set To Dictionary    ${Protocol_Notification['${notification}']['params']}
    ${mqtt_data} =    BuiltIn.Create Dictionary    message_type=${message_type}    target_id=${target_id}    data_params=${data}
    ${verdict}    ${comment}    ${response} =  CIRRUS GET PGW MESSAGE    IVC    ${mqtt_data}    ${tstart}    mes_type=0
    Should Be True    ${verdict}    Fail to CHECK VNEXT PROTOCOL GATEWAY with comment: ${comment}

CHECK VNEXT PROTOCOL GATEWAY FOR SERVICES
    [Arguments]    ${profile}
    [Documentation]    Check that On VNext Protocol Gateway the desired notification should be received
    IF    "${profile}" == "eva_periodic_trigger_data"
        FOR   ${i}    IN RANGE    1    9
            Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    eva_periodic_trigger_data_${i}
        END
    ELSE IF    "${profile}" == "eva_003_single_trigger_data"
        FOR   ${i}    IN RANGE    1    14
            Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    eva_003_single_trigger_data_${i}
        END
    ELSE IF    "${profile}" == "eva_002_single_trigger_data"
        FOR   ${i}    IN RANGE    1    5
            Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    eva_002_single_trigger_data_${i}
        END
    ELSE IF    "${profile}" == "emulate_ubam_data_periodic_trigger"
        FOR   ${i}    IN RANGE    1    3
            Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    emulate_ubam_data_periodic_trigger_${i}
        END
    ELSE IF    "${profile}" == "coma_001_trigger"
        FOR   ${i}    IN RANGE    1    5
             Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    coma_001_trigger_${i}
        END
    ELSE IF    "${profile}" == "phyd_data"
        FOR   ${i}    IN RANGE    1    3
             Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    phyd_data_${i}
        END
    ELSE IF    "${profile}" == "ubam_data_single_trigger"
        FOR   ${i}    IN RANGE    1    3
             Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    ubam_data_single_trigger_${i}
        END
    ELSE IF    "${profile}" == "dabr_data_periodic_trigger"
        FOR    ${i}    IN RANGE    1    4
            Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    dabr_data_periodic_trigger_${i}
        END
    ELSE IF    "${profile}" == "dabr_single_trigger_data"
        FOR   ${i}    IN RANGE    1    9
             Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    dabr_single_trigger_${i}
        END
   ELSE IF    "${profile}" == "bumi_data"
        FOR   ${i}    IN RANGE    1    3
             Run Keyword And Continue On Failure    CHECK VNEXT PROTOCOL GATEWAY    bumi_data_${i}
        END
    END

CHECK VNEXT MQTT NOTIFICATION IVI SECURITY LOGS
    [Documentation]        == High Level Description: ==
    ...     Check if notification as a result of the IVISsecuritylog.
    ...    == Parameters: ==
    ...    _state_: value
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${verdict}    ${comment} =    CHECK MQTT MESSAGE    RemoteNotification     Securitylog    Notification    ${time}
    Should Be True    ${verdict}    Fail to CHECK VNEXT MQTT NOTIFICATION IVI SECURITY LOGS with comment: ${comment}

CHECK VNEXT MQTT NOTIFICATION IVI ANTIFLOODING
    [Documentation]        == High Level Description: ==
    ...     Check if notification as a result of the IVI violation. External connection attempt
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if notification containing below field is published in admin portal
    ...    no more than 32 times since recorded timestamp
    ${time} =    Create Dictionary    timestamp=${tstart}
    ${nb_notif}=    Get length    ${response_pgw}
    IF    ${nb_notif}<=${32}
        Log    Number of notifications received ${nb_notif}: ${response_pgw}
    ELSE
        Fail    Number of notifications exceeded the limit:${nb_notif}
    END
