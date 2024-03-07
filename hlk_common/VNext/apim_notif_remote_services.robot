#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Resource          ${CURDIR}/../Tools/bench_config.robot
Library           rfw_services.cirrus.CirrusLib    @{cirrus_config_data}
Library           Collections
Library           String
Library           robot.libraries.DateTime
Library           OperatingSystem
Variables         ../unsorted/PM_profiles.yaml
Variables         ../unsorted/PT_profiles.yaml
Variables         ../unsorted/tech_prod_ids.yaml
Variables         ../unsorted/VHER_profiles.yaml
Resource          ../Tools/tools.robot
Variables         ../unsorted/car_data_platform.yaml
Variables         ../unsorted/digital_back_bone.yaml

*** Variables ***
@{cirrus_config_data}    APIM    EVENT_HUB    MQTT_HEADER    MQTT_DATA
${console_logs}    yes
${wrong_pin}      8889
${apim_info}      apim_info.yaml
${event_hub_info}    event_hub_info.yaml
${event_hub_timeout}    ${120}
${client_secret}    ${None}
&{empty_dict}
@{empty_list}
&{refresh_car_position_notification_ivc}    LocationSourceValue=0     LocationValidityValue=0
&{refresh_car_position_notification_ivi}    LocationSourceValue=1     LocationValidityValue=0
&{techprodactivation}    Source=ACMS    VehicleCountry=FR    CustomerEmail=automation.matrix@renault.com    IVIConfiguration=${null}    IVCConfiguration=${null}
${cmd_generate_srp}    SRPC -g
@{vnext_certif}    apim.p12    password
&{StandardAdmin_param}    UserId=${user_id}    ResourceType=Vin    ResourceValue=${vehicle_id}
${vnext_vehicle_id}    9f108049-6b33-4870-ae39-36d817feb0ee
${mqtt_header_info}    protocol_gw_app_header.yaml
${mqtt_data_info}    protocol_gw_app_data.yaml
${vnext_pfx_file_sit-emea}    apim.p12
${vnext_pfx_file_stg-emea}    ${CURDIR}/awazu10.p12
${vnext_pfx_pwd_sit-emea}    password
${vnext_pfx_pwd_stg-emea}    Pa55azu10
${vnext_certif_pfx_pwd}    password
${vnext_admin_crt}    RenaultAdm.crt
${vnext_admin_key}    RenaultAdm.key
${vnext_admin_pfx_file}    awazu40.p12
${vnext_admin_pfx_pwd}    9hh52JYtQX
${vnext_pfx_testingtool_sit-emea}    testingtools-client2-SIT.pfx
${vnext_pfx_testingtool_stg-emea}    testingtools-client2-STG.pfx
${vnext_testingtool_pwd_sit-emea}    iS9hLdTYuF8v
${vnext_testingtool_pwd_stg-emea}    rG7MebmTTx2V
${tstart}    None
${event_id}   IRN-71028
${TC_folder}    ${none}

*** Keywords ***
SEND VNEXT REQUEST RLU
    [Arguments]    ${action}    ${rlu_option}    ${rlu_option1}    ${srp_proof}=${NONE}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RLU request with the parameter needed
    ...    (defined in AIA document for RLU)
    ...    == Parameters: ==
    ...    - _action_: Lock, Unlock
    ...    - _RLU_option_: AllDoors, Tailgate, DriverDoorOnly
    ...    - _RLU_option1_: NA, OutSide, InSide
    ...    - _srp_proof_: Calculated SRP PROOF value if one is required (optional parameter)
    ...    == Expected Results: ==
    ...    PASS if Executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Lock/Unlock    VNEXT APIM
    ${rlu_args} =    Create Dictionary    RLUAction=${action}    RLU_Option=${rlu_option}    RLU_Option1=${rlu_option1}
    Run Keyword If    "${srp_proof}"    Set To Dictionary    ${rlu_args}    SRP_PROOF=${srp_proof}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    RemoteLockUnlockCommand    RLU    ${rlu_args}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RLU: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RLU: ${comment}

SEND VNEXT REQUEST RHL
    [Arguments]    ${action}    ${rhl_option}    ${rhl_option2}    ${rhl_option3}    ${srp_proof}=${NONE}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RHL request with the parameter needed
    ...    (defined in AIA document for RHL)
    ...    == Parameters: ==
    ...    - _action_: start, Stop
    ...    - _RHL_Options_: list with the following options
    ...    - _RHL_Option_: HornLight, HornOnly, LightOnly
    ...    - _RHL_Option2_: Style1, Style2, Style3 (Optionnal)
    ...    - _RHL_Option3_:  15, 30, 45, 60, 75, 90 (Optionnal)
    ...    - _srp_proof_: Calculated SRP PROOF value if one is required (optional parameter)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    VNEXT APIM
    ${rhl_args} =    Create Dictionary    RHLAction=${action}    RHL_Option=${rhl_option}
    Run Keyword If    "${rhl_option2}"!="NA"    Set To Dictionary    ${rhl_args}    RHL_Option2    ${rhl_option2}
    Run Keyword If    "${rhl_option3}"!="NA"    Set To Dictionary    ${rhl_args}    RHL_Option3    ${{int($rhl_option3)}}
    Run Keyword If    "${srp_proof}"    Set To Dictionary    ${rhl_args}    SRP_PROOF=${srp_proof}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    RemoteHornLightsCommand    RHL    ${rhl_args}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RHL: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RHL: ${comment}

SEND VNEXT REQUEST RES
    [Arguments]    ${action}    ${srp_proof}=${NONE}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RES request
    ...    with the parameter needed (defined in AIA document for RES)
    ...    == Parameters: ==
    ...    - _action_: Start, Stop, DoubleStart, GetStatus
    ...    - _srp_proof_: Calculated SRP PROOF value if one is required (optional parameter)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Engine Start    VNEXT APIM
    ${res_command} =    Run Keyword If    "${action}"=="GetStatus"    Create Dictionary    command=RemoteEngineStartGetStatus    target=RESGetStatus
    ...    ELSE    Create Dictionary    command=RemoteEngineStartCommand    target=RES
    ${res_args} =    Run Keyword If    "${action}"=="GetStatus"    Create Dictionary    DataGroups=RemoteEngineState
    ...    ELSE    Create Dictionary    RESAction=${action}
    Run Keyword If    "${srp_proof}"    Set To Dictionary    ${res_args}    SRP_PROOF=${srp_proof}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    ${res_command}[command]    ${res_command}[target]    ${res_args}
    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RES: ${comment}

SEND VNEXT REQUEST SERVICE ACTIVATION
    [Arguments]    ${action}    @{service_name}    ${set_log_level_none}=False
    [Documentation]    == High Level Description: ==
    ...    Send to Vnext Apim a request for a services activation request.
    ...    == Parameters: ==
    ...    - _service_name_: service name corresponding to a technical product ID
    ...    - _action_: activate, deactivate, reactivate, initiate
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Service subscription management    VNEXT APIM
    Run Keyword    RECORD VNEXT DATE & TIME    tstart
    @{list_of_services}=    Create List
    ${currentDate} =    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%dT%H:%M:%SZ    exclude_millis=True
    ${endDate} =    robot.libraries.DateTime.Add Time To Date    ${currentDate}    30 days
    ${convertEndDate} =    robot.libraries.DateTime.Convert Date    ${endDate}    result_format=%Y-%m-%dT%H:%M:%SZ
    @{vin}=    Create List
    Append To List    ${vin}    ${vehicle_id}
    FOR    ${item}    IN    @{service_name}
       ${tech_prod_id} =    Run Keyword If    "${item}".lower() in ${tech_prods}
       ...    Set Variable    ${tech_prods["${item}".lower()]}
       ...    ELSE    Fail    No implementation for service_name ${item}
       ${commandId} =    Get Command ID    ${action}
       ${prod_id_dict_}=    Create Dictionary
       ${prod_id_dict_}=    Copy Dictionary    ${techprodactivation}
       Set To Dictionary    ${prod_id_dict_}    TechProdId    ${{int(${tech_prod_id})}}    Vins    ${vin}
       ...    Action    ${action}    EndDate    ${convertEndDate}    CommandId    ${commandId}
       Append To List    ${list_of_services}    ${prod_id_dict_}
       ${SA_arg} =    Create Dictionary    TechProdActions=${list_of_services}
    END
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    list of services: "${list_of_services}"
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    SA_arg: ${SA_arg}
    ${previous_log_level} =    Run keyword if    "${set_log_level_none}" == "True"    Set Log Level    NONE
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    ServiceActivationCommand    SA    ${SA_arg}
    Run keyword if    "${set_log_level_none}" == "True"    Set Log Level    ${previous_log_level}
    Should Be True    ${verdict}    Failed to send VNext apim request

CHECK VNEXT REQUEST RESPONSE
    [Arguments]    ${services}    ${expected_status}    ${resp_attr}=${empty_dict}    ${ret_attr}=${empty_list}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP ACK answer from a request.
    ...    == Parameters: ==
    ...    - _services_: rlu, res, rhl, …
    ...    - _expected status_: success, fail, …
    ...    - _resp attr_: Expected response attributes and values
    ...    - _ret attr_: Attributes to extract from response
    ...    == Expected Results: ==
    ...    Pass if_expected status} is the one received in response
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    VNEXT APIM
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT REQUEST RESPONSE service : ${services}, expected status : ${expected_status}
    ${args} =    Run Keyword If    "${services}" == "rlu"    Create List    RemoteLockUnlockCommand    RLU
    ...    ELSE IF    "${services}" == "rhl"    Create List    RemoteHornLightsCommand    RHL
    ...    ELSE IF    "${services}" == "srp"    Create List    SRPRequestSalt    SRPRequestSalt
    ...    ELSE IF    "${services}" == "jwt"    Create List    JWT    JWTConfig
    ...    ELSE IF    "${services}" == "e2e"    Create List    DestinationSendToCar    E2E
    ...    ELSE IF    "${services}" == "res"    Create List    RemoteEngineStartCommand    RES
    ...    ELSE IF    "${services}" == "resGetStatus"    Create List    RemoteEngineStartGetStatus    RESGetStatus
    ...    ELSE IF    "${services}" == "service_activation"    Create List    ServiceActivationCommand    SA
    ...    ELSE IF    "${services}" == "srp_init"    Create List    SRPInitialize    SRPInitialize
    ...    ELSE IF    "${services}" == "srp_delete"    Create List    SRP_Delete    SRP_Delete
    ...    ELSE IF    "${services}" == "MyCarFinder"    Create List    RefreshCarPositionFromIVC    RCP
    ...    ELSE IF    "${services}" == "push_message"    Create List    PUSH_MESSAGE    PM
    ...    ELSE IF    "${services}" == "bci"    Create List    BatteryChargeInhibitorCommand    BCI
    ...    ELSE IF    "${services}" == "rhoo"    Create List    RHOO    START/STOP PRESOAK
    ...    ELSE IF    "${services}" == "rhvs"    Create List    Remote_HVAC_scheduling    RHVS
    ...    ELSE IF    "${services}" == "RVLS_LockStatusCheckOndemand"    Create List    RemoteLockUnlockCommand    RVLS_LockStatusCheckOndemand
    ...    ELSE IF    "${services}" == "RVLS_LockStatusCheck"    Create List    RemoteLockUnlockCommand    RVLS_LockStatusCheck
    ...    ELSE IF    "${services}" == "RVLS_LockStatusCheckOndemandWithWakeup"    Create List    RemoteLockUnlockCommand    RVLS_LockStatusCheckOndemandWithWakeup
    ...    ELSE IF    "${services}" == "rcss"    Create List    RemoteChargingStartAndStop    EVC
    ...    ELSE IF    "${services}" == "rcc"    Create List    RemoteChargingStartAndStop    RemoteChargingStart
    ...    ELSE IF    "${services}" == "rcss_deactivate"    Create List    RemoteChargingStartAndStop    EVCD
    ...    ELSE IF    "${services}" == "remote_diagnostic"    Create List    RemoteDiagnosticOnDemand    REDI
    ${expected_status} =    Convert To Title Case    ${expected_status}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    @{args}    ${expected_status}    ${resp_attr}    ${ret_attr}
    Should Be True    ${verdict}    Fail to CHECK VNEXT REQUEST RESPONSE: ${comment}
    # TODO : To asses whether the commandId can be pushed from the testcases side using ${ret_attr} and read it's return into ${response} ({"extracted_response_data_key": ret_params_dict}
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    [Return]    ${verdict}    ${response}

CHECK VNEXT NOTIFICATION RLU ACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success or Error=ErrorCode
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Lock/Unlock    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RLU ACK
    IF  "success" in $status.lower()
        ${rlu_status} =   Create Dictionary    RLUStatus=${0}
    ELSE
        ${rlu_status} =   Create Dictionary    RLUStatus=${1}    RLUErrorCode=${{int($status.split("=")[1])}}
    END
    IF  "kmr" in $instance
        Set To Dictionary    ${rlu_status}    CommandId=${CommandId_RLU}
    ELSE
        Set To Dictionary    ${rlu_status}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    CommandResponse    RLUCommandStatus    ${event_hub_timeout}    ${rlu_status}
    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION RLU ACK: ${comment}

CHECK VNEXT NOTIFICATION RLU RESULT
# TODO: Remove ${doors} if it is not used, otherwise update keyword to take it into account
    [Arguments]    ${operation_result}    ${lock_status}    ${doors}=${empty_dict}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _operationResult_: Success or Fail, Timeout
    ...    - _Lock_status_: Lock, Unlock
    ...    - _doors_: Dict of door name and expected value. You can add many doors status
    ...    by adding the exact doors name and expected value.
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Lock/Unlock    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RLU RESULT
    ${rlu_result} =   Create Dictionary
    ...    OperationResult=${{'Success' if $operation_result.lower() == 'success' else 'Failed'}}
    ...    StatusDoorOutsideLockedState=${{"0" if $lock_status.lower() == 'unlock' else "1"}}
    IF  "kmr" in $instance
        Set to Dictionary    ${rlu_result}    CommandId=${CommandId_RLU}
    ELSE
        Set to Dictionary    ${rlu_result}    CommandId=${Apim_CommandId}
    END
    ${verdict_resp}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    CommandResponse    RLUCommandResult    ${event_hub_timeout}    ${rlu_result}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict_resp}    Fail to CHECK VNEXT NOTIFICATION RLU RESULT: ${comment}
    ...    ELSE    Should Be True    ${verdict_resp}    Fail to CHECK VNEXT NOTIFICATION RLU RESULT: ${comment}

    [Return]    ${verdict_resp}   ${comment}

RETRY MECHANISM FOR READING SA STATUS
    [Arguments]    ${service_name}    ${status}   ${set_log_level_none}=False

    ${tech_prod_id} =    Run Keyword If    "${service_name}".lower() in ${tech_prods}
    ...    Set Variable    ${tech_prods["${service_name}".lower()]}
    ...    ELSE   Fail    No implementation for service_name ${service_name}
    @{tech_ids} =    Create List    ${{int('${tech_prod_id}')}}
    &{sa_args} =    Create Dictionary    VIN=${vehicle_id}    TechProdIds=${tech_ids}
    ${previous_log_level} =    Run keyword if    "${set_log_level_none}" == "True"    Set Log Level    NONE
    ${verdict}    ${last_status} =    SEND VNEXT APIM REQUEST SERVICE STATUS CHECK    ServiceActivationStatus    SA    ${sa_args}
    Run keyword if    "${set_log_level_none}" == "True"    Set Log Level    ${previous_log_level}
    Should Be True    ${verdict}    Fail to SEND VNEXT APIM REQUEST SERVICE STATUS CHECK: ${last_status}
    ${remove_status} =    Fetch From Right    ${last_status}    APIM: Response received:\n
    ${dict_requst_status} =    Convert To Dictionary    ${remove_status}
    ${status_service} =    Set Variable    ${dict_requst_status['TechnicalProducts'][0]['StatusHistory']}
    ${size_message} =    Get Length    ${status_service}
    ${current_status} =    Set Variable If    ${size_message} == 0    0    ${dict_requst_status['TechnicalProducts'][0]['StatusHistory'][0]['Status']}
    Set Suite Variable    ${current_status}
    ${args} =    Create List    ServiceActivationStatus    SA
    ${status_dict}=    Create Dictionary    LastServiceStatus=${status}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    @{args}    Success    ${status_dict}
    ${converted_date} =    Set Variable If    ${size_message} == 0    0    ${dict_requst_status['TechnicalProducts'][0]['StatusHistory'][0]['StatusDate']}
    ${convertedStatusDate} =    Run Keyword If    ${size_message} != 0
    ...    robot.libraries.DateTime.Convert Date    ${converted_date}    result_format=%Y-%m-%d %H:%M:%S     exclude_millis=yes    date_format=%Y-%m-%dT%H:%M:%SZ
    Run Keyword If    "${current_status}" == "DeactivationFailed" or "${current_status}" == "ActivationFailed" or "${current_status}" == "ReactivationFailed"    Run Keywords
    ...    Return from keyword
    ...    ELSE    Should be True    "${tstart}" <= "${convertedStatusDate}" and "${current_status}" == "${status}"
    # Work around to press check for update buton due to some SA issues
    # Run Keyword If    "${status}" == "ActivationInProgress" or "${status}" == "DeactivationInProgress"    CHECK FOR UPDATE    ${status}
    [Return]    ${verdict}    ${comment}    ${response}

CHECK VNEXT NOTIFICATION SERVICE ACTIVATION
    [Arguments]    ${service_name}    ${status}    ${timeout}=${None}    ${set_log_level_none}=False
    [Documentation]    == High Level Description: ==
    ...    Check if Vnext sends a notification with success status
    ...    of a service activation request.
    ...    == Parameters: ==
    ...    - _service_name_: name of the service
    ...    - _status_: ActivationInProgress, DeactivationInProgress, Activation Failed,
    ...    Deactivation Failed, Activated, Deactivated
    ...    - _timeout_: timeout value in case activation/deactivation of the service takes more time
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Service subscription management    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION SERVICE ACTIVATION
    Run Keyword If    "${tstart}" == "None"    RECORD VNEXT DATE & TIME    tstart
    ${activation_timeout} =    Set Variable If    "${TC_folder}"=="RELIABILITY"    30m    15m
    ${deactivation_timeout} =    Set Variable If    "${TC_folder}"=="RELIABILITY"    30m    10m
    ${timeout_value} =    Run Keyword If    "${status}" == "Deactivated" and "${timeout}" != "${None}"    Set Variable    ${timeout}
    ...    ELSE IF    "${status}" == "Activated" and "${timeout}" != "${None}"    Set Variable    ${timeout}
    ...    ELSE IF    "${status}" == "Deactivated"   Set Variable    ${deactivation_timeout}
    ...    ELSE IF    "${status}" == "Activated"   Set Variable    ${activation_timeout}
    ...    ELSE IF    "${status}" == "ActivationInProgress" or "${status}" == "DeactivationInProgress" or "${status}" == "ReactivationInProgress"   Set Variable    10s

    ${retry_value} =    Run Keyword If    "${status}" == "ActivationInProgress" or "${status}" == "DeactivationInProgress" or "${status}" == "ReactivationInProgress"
    ...    Set Variable    1s
    ...    ELSE    Set Variable    15s

    Wait Until Keyword Succeeds    ${timeout_value}    ${retry_value}    CHECK VNEXT SERVICE ACTIVATION STATUS    ${service_name}    ${status}

CHECKSET VNEXT SERVICE ACTIVATION STATUS FOR
    [Arguments]    ${service_name}    ${status}    ${timeout}=${None}    ${set_log_level_none}=False   ${force}=False
    [Documentation]    == High Level Description: ==
    ...    Check if a given service is activated/deactivated. When the service activation status
    ...    is not as expected, activate or deactivate it.
    ...    == Parameters: ==
    ...    - _service_name_: name of the services. for information only. (eg, MyCarFinder, RLU, ...)
    ...    - _status_: Activated, Deactivated
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Service subscription management    VNEXT APIM
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECKSET VNEXT SERVICE ACTIVATION STATUS FOR service ${service_name} in state ${status}
    RECORD VNEXT DATE & TIME    tstart
    ${verdict}    ${comment}=    CHECK VNEXT SERVICE ACTIVATION STATUS    ${service_name}    ${status}    True
    IF    "${verdict}"=="True"
        Return from keyword
    ELSE IF    "Value is different than expected" not in """${comment}"""
            Should be true    ${verdict}    ${comment}
    END
    ${timeout_value} =    Run Keyword If    "${status}" == "Deactivated" and "${timeout}" != "${None}"   Set Variable    ${timeout}
    ...    ELSE IF    "${status}" == "Activated" and "${timeout}" != "${None}"    Set Variable    ${timeout}
    ...    ELSE IF    "${status}" == "Deactivated"   Set Variable    15m
    ...    ELSE IF    "${status}" == "Activated"   Set Variable    10m
    ...    ELSE IF    "${status}" == "ActivationInProgress" or "${status}" == "DeactivationInProgress"   Set Variable    10s

    ${retry_value} =    Run Keyword If    "${status}" == "ActivationInProgress" or "${status}" == "DeactivationInProgress"
    ...    Set Variable    1s
    ...    ELSE    Set Variable    15s

    ${action} =    Set Variable if    "${status}".lower() == "deactivated"    deactivate    activate

    SEND VNEXT REQUEST SERVICE ACTIVATION     ${action}    ${service_name}
    Wait Until Keyword Succeeds    ${timeout_value}    ${retry_value}    CHECK VNEXT SERVICE ACTIVATION STATUS    ${service_name}    ${status}

CHECK VNEXT NOTIFICATION RHL ACK
    [Arguments]    ${status}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success or Error=ErrorCode
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RHL ACK
    IF  "Success" in $status
        ${event_hub_rhl_params} =   Create Dictionary    RHLStatus=${0}
    ELSE
        ${event_hub_rhl_params} =   Create Dictionary    RHLStatus=${1}    RHLErrorCode=${{int($status.split("=")[1])}}
    END
    IF  "kmr" in $instance
        Set to Dictionary    ${event_hub_rhl_params}    CommandId=${CommandId_RHL}
    ELSE
        Set to Dictionary    ${event_hub_rhl_params}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    CommandResponse    RHLCommandAcknowledgement    ${event_hub_timeout}    ${event_hub_rhl_params}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION RHL ACK: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION RHL ACK: ${comment}

CHECK VNEXT NOTIFICATION RES ACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success or Error=ErrorCode
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Engine Start    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RES ACK
    IF  "success" in $status.lower()
        ${event_hub_res_params} =   Create Dictionary    RESStatus=${0}
    ELSE
        ${event_hub_res_params} =   Create Dictionary    RESStatus=${1}    RESErrorCode=${{int($status.split("=")[1])}}
    END
    IF  "kmr" in $instance
        Set to Dictionary    ${event_hub_res_params}    CommandId=${CommandId_RES}
    ELSE
        Set to Dictionary    ${event_hub_res_params}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    CommandResponse    RESCommandStatus    ${event_hub_timeout}    ${event_hub_res_params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION RES ACK: ${comment}

CHECK VNEXT NOTIFICATION RES RESULT
    [Arguments]    ${operation_result}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _operation_result_: Success, Fail, Timeout
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Engine Start    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RES RESULT
    ${cmd_result} =    Set Variable if    "${operation_result}".lower() == "success"    Success    Failed
    ${event_hub_res_params} =    Create Dictionary    OperationResult=${cmd_result}    CommandId=${Apim_CommandId}
    ${verdict}    ${comment}    ${response_dict} =    Run Keyword If    "${instance}" != "kmr"    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RESCommandResult    ${event_hub_timeout}    ${event_hub_res_params}
    ...    ELSE    Create List    True    KW not implemented for the moment    ${empty_dict}
    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION RES RESULT: ${comment}
    Run Keyword If    "${instance}" == "kmr"    Log    CHECK VNEXT NOTIFICATION RES RESULT is disabled when request is made using KMR (Issue: SWL-31061)    WARN

CHECK VNEXT NOTIFICATION RES GET STATUS
    [Arguments]    ${status}    ${StatusRES}    ${StatusRESLeftTimeDuringThisCycle}    ${StatusRESSmartPhoneError}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: OK, Timeout
    ...    - _StatusRES:value_: value can be an int between 0 and 15
    ...    - _StatusRESLeftTimeDuringThisCycle: value can be an int between 0 and 1200
    ...    - _StatusRESSmartPhoneError: value can be an int between 0 and 3
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Remote Engine Start    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RES GET STATUS
    ${event_hub_res_params} =    Create Dictionary    StatusRES=${StatusRES}    StatusRESLeftTimeDuringThisCycle=${StatusRESLeftTimeDuringThisCycle}    CommandId=${Apim_CommandId}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RCDData    ${event_hub_timeout}    ${event_hub_res_params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION RES GET STATUS: ${comment}

CHECKSET VALID SALT
    [Arguments]    ${srp_username}    ${password}
    [Documentation]    == High Level Description: ==
    ...    Check if a salt request has been done since 20 minutes, else, do it.
    ...    == Parameters: ==
    ...    - _srp_username_
    ...    - _password_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)
    # TODO implement 20 minutes check
    srp.DO SRP INIT    ${srp_username}    ${password}
    srp.DO SRP GENERATE A & a
    &{srp_req_salt_params} =    Create Dictionary    SRPLoginSRP_I=${srp_username}    SRPLoginSRP_A=${srp_value_A}
    ${verdict}    ${comment} =   SEND VNEXT APIM REQUEST    SRPRequestSalt    SRPRequestSalt    ${srp_req_salt_params}
    Should Be True    ${verdict}    Fail to SEND VNEXT APIM REQUEST: ${comment}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    SRPRequestSalt    SRPRequestSalt    Success    ${empty_dict}
    Should Be True    ${verdict}    Fail to CHECK VNEXT APIM RESPONSE: ${comment}
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    ${srp_status} =    Create Dictionary    SRP_LoginStatus=OK    CommandId=${Apim_CommandId}
    @{ret_params_list} =    Create List    SRPLoginSRP_s    SRPLoginSRP_B
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    SRPSaltRequest    ${event_hub_timeout}    ${srp_status}    ret_params_list=${ret_params_list}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB NOTIF CHECKSET VALID SALT: ${comment}
    Set Test Variable    ${srp_server_salt}    ${response_dict.get("SRPLoginSRP_s")}
    Set Test Variable    ${srp_value_B}    ${response_dict.get("SRPLoginSRP_B")}

SEND VNEXT REQUEST SRP SALT
    [Arguments]    ${srp_username}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a SRP Salt request
    ...    with the parameter needed (defined in AIA document for SRP)
    ...    == Parameters: ==
    ...    - _srp_username_: username parameter
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT APIM
    &{srp_req_salt_params} =    Create Dictionary    SRPLoginSRP_I=${srp_username}    SRPLoginSRP_A=${srp_value_A}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    SRPRequestSalt    SRPRequestSalt    ${srp_req_salt_params}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Failed to SEND VNEXT APIM REQUEST : SEND VNEXT REQUEST SRP SALT: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Failed to SEND VNEXT APIM REQUEST : SEND VNEXT REQUEST SRP SALT: ${comment}

CHECK VNEXT NOTIFICATION SRP SALT
    [Arguments]    ${status}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success, Fail
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION SRP SALT
    ${cmd_result} =    Set Variable if    "${status}".lower() == "success"    OK    KO
    ${srp_status} =    Create Dictionary    SRP_LoginStatus=${cmd_result}
    @{ret_params_list} =    Create List    SRPLoginSRP_s    SRPLoginSRP_B
    IF  "${instance}" == "kmr"
        Set To Dictionary    ${srp_status}    CommandId=${SRP_CommandId}
    ELSE
        Set To Dictionary    ${srp_status}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    SRPSaltRequest    ${event_hub_timeout}    ${srp_status}    ret_params_list=${ret_params_list}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION SRP SALT: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION SRP SALT: ${comment}
    Set Test Variable    ${srp_server_salt}    ${response_dict.get("SRPLoginSRP_s")}
    Set Test Variable    ${srp_value_B}    ${response_dict.get("SRPLoginSRP_B")}

SEND VNEXT REQUEST MYCARFINDER
    [Arguments]    ${location}
    [Documentation]    == High Level Description: ==
    ...    Send Vnext request for My Car Finder Service
    ...    == Parameters: ==
    ...    - _location_: LastKnownPositionFromVnext, RefreshCarPositionFromIVC
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    My Car Finder Service    VNEXT APIM
    ${apim_req_arg} =    Create Dictionary    DataGroups=Position
    ${verdict}    ${comment} =    Run Keyword If    "${location}" == "LastknownPositionFromVnext"    SEND VNEXT APIM REQUEST    LastKnownCarPosition    LKCP    ${apim_req_arg}
    ...    ELSE IF    "${location}" == "refreshCarPositionFromIVC"   SEND VNEXT APIM REQUEST    RefreshCarPositionFromIVC    RCP    ${apim_req_arg}
    Should Be True    ${verdict}    Failed to send VNext apim request : SEND VNEXT REQUEST MYCARFINDER: ${comment}
    [Return]    ${comment}

CHECK VNEXT RESPONSE MYCARFINDER VALID LOCATION
    [Arguments]    ${data_profile}    ${start_timestamp}=${EMPTY}    ${stop_timestamp}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    This keyword implementation refreshes car position or gets the last known location with a
    ...    check of the Longitude and Latitude as dynamic parametrs. If the wrong profile was set verdict will be
    ...    always false
    ...    Check if Vnext sends a good data (according with {data_profile})
    ...    upon a My Car Finder request with a status = success
    ...    == Parameters: ==
    ...    - _data_profile_: name of a profile containing some repository label
    ...    -_start_timestamp_: the start timestamp value
    ...    -_stop_timestamp_: the stop timestamp value
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    My Car Finder Service    VNEXT APIM
    ${args} =    Create List    LastKnownCarPosition    LKCP
    ${params}    Create Dictionary    LocationLatitude=dynamic    LocationLongitude=dynamic
    ${items}    Get Dictionary Items    ${params}
    FOR    ${key}    ${value}    IN    @{items}
        ${expected_values} =    Run Keyword If    "${data_profile}"=="stop_the_car_data"
        ...    Create Dictionary    ${key}field=${key}    ${key}value=${value}    Timestamp${key}=${tstart}
        ...    ELSE    Create Dictionary    ${key}field=${key}    ${key}value=${value}
        ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM DYNAMIC ROBOT PARAMETERS RESPONSE    @{args}    Success    ${expected_values}
        Should Be True    ${verdict}    Failed to check CHECK VNEXT RESPONSE MYCARFINDER VALID LOCATION with comment: ${comment}
        ${expected_values} =    Run Keyword If    "${data_profile}"=="stop_the_car_data"
        ...    Create Dictionary    ${key}field=${key}    ${key}value=${value}    Timestamp${key}=${tstop}
        ${verdict}    ${comment}    ${response} =    Run Keyword If    "${data_profile}"=="stop_the_car_data"
        ...    CHECK VNEXT APIM DYNAMIC ROBOT PARAMETERS RESPONSE    @{args}    Success    ${expected_values}
        Run Keyword If    "${data_profile}"=="stop_the_car_data" and "Wrong timestamp received" in "${comment}"
        ...    Should Be Equal    "${verdict}"    "False"    Failed to check CHECK VNEXT RESPONSE MYCARFINDER VALID LOCATION with comment: ${comment}
        ...    ELSE IF    "${data_profile}"=="stop_the_car_data"
        ...    Should Be True    ${verdict}    Failed to check CHECK VNEXT RESPONSE MYCARFINDER VALID LOCATION with comment: ${comment}
    END

CHECK VNEXT NOTIFICATION MYCARFINDER
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if Vnext sends a notification with success status of My Car Finder request.
    ...    == Parameters: ==
    ...    - _status_: Success, Fail
    ...    == Expected Results: ==
    ...    Pass if vnext notification content is as expected
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    My Car Finder Service    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION MYCARFINDER
    ${cmd_result} =    Set Variable if    "${status}" == "Success"    OK    Timeout
    IF  "${instance}" == "kmr"
        ${refresh_car_position_notification_ivc} =    Create Dictionary    Status=${cmd_result}
        ${refresh_car_position_notification_ivi} =    Create Dictionary    Status=${cmd_result}
    ELSE
        ${refresh_car_position_notification_ivc} =    Create Dictionary    Status=${cmd_result}    CommandId=${Apim_CommandId}
        ${refresh_car_position_notification_ivi} =    Create Dictionary    Status=${cmd_result}    CommandId=${Apim_CommandId}
    END
    ${verdict_ivc}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RCDData    ${event_hub_timeout}    ${refresh_car_position_notification_ivc}
    Return From Keyword If    "${verdict_ivc}" == "True"
    ${verdict_ivi}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RCDData    ${event_hub_timeout}    ${refresh_car_position_notification_ivi}
    Should Be True    ${verdict_ivi}    Failed to receive Vnext Notification : VNEXT NOTIFICATION MYCARFINDER: ${comment}

SEND VNEXT REQUEST SRP INIT PIN CODE
    [Arguments]    ${srp_username}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a SRP init pin code request
    ...    with the parameter needed (defined in AIA document for SRP)
    ...    == Parameters: ==
    ...    - _srp_username_: user id parameter
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT APIM
    ${srp_init_attributes} =    Create Dictionary    SRPVerifier=${srp_verifier}    SRPLoginSRP_I=${srp_username}    SRPLoginSRP_Salt=${srp_client_salt}
    ${verdict}    ${comment} =   SEND VNEXT APIM REQUEST    SRPInitialize    SRPInitialize    ${srp_init_attributes}
    Should Be True    ${verdict}    Failed to send VNEXT REQUEST SRP INIT PIN CODE: ${comment}

CHECK VNEXT NOTIFICATION SRP INIT PIN CODE ACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success, Fail
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION SRP INIT PIN CODE ACK
    ${event_SRP_INIT_params} =    Run Keyword If    "${status}" == "Success"    Create Dictionary    SRPPINCODEStatus=OK
    ...    ELSE    Create Dictionary    SRPPINCODEStatus=KO
    IF  "kmr" in $instance
        Set to Dictionary    ${event_SRP_INIT_params}    CommandId=${SRP_CommandId}
    ELSE
        Set to Dictionary    ${event_SRP_INIT_params}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    Notification    PINCodeAcknowledgement    ${event_hub_timeout}    ${event_SRP_INIT_params}
    Should Be True    ${verdict}    Failed to receive VNEXT NOTIFICATION SRP INIT PIN CODE ACK: ${comment}

CHECK VNEXT NOTIFICATION SRP INIT PIN CODE STATUS
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success, Fail
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION SRP INIT PIN CODE STATUS
    IF  "kmr" in $instance
        ${event_SRP_INIT_params} =    Run Keyword If    "${status}" == "Success"    Create Dictionary    SRPPINCODEStatus=OK    CommandId=${SRP_CommandId}
    ...    ELSE    Create Dictionary    SRPPINCODEStatus=KO    CommandId=${SRP_CommandId}
    ELSE
        ${event_SRP_INIT_params} =    Run Keyword If    "${status}" == "Success"    Create Dictionary    SRPPINCODEStatus=OK    CommandId=${Apim_CommandId}
    ...    ELSE    Create Dictionary    SRPPINCODEStatus=KO    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    PINCodeStatus    ${60}    ${event_SRP_INIT_params}
    Should Be True    ${verdict}    Failed to receive VNEXT NOTIFICATION SRP INIT PIN CODE STATUS: ${comment}

SEND VNEXT REQUEST SRP CLEAR PIN CODE
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a SRP clear pin code request
    ...    with the parameter needed (defined in AIA document for SRP)
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT APIM
    ${apim_req_arg} =    Create Dictionary    SRPClear=SRPClear
    ${verdict}    ${comment} =   SEND VNEXT APIM REQUEST    SRP_Delete    SRP_Delete    ${apim_req_arg}
    Should Be True    ${verdict}    Failed to send VNEXT REQUEST SRP CLEAR PIN CODE: ${comment}

CHECK VNEXT NOTIFICATION SRP CLEAR PIN CODE STATUS
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Parameters: ==
    ...    - _status_: Success, Fail
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION SRP CLEAR PIN CODE STATUS
    IF    "${status}" == "Success"
        ${event_SRP_delete} =    Create Dictionary    Status=OK    CommandId=${Apim_CommandId}
    ELSE
        ${event_SRP_delete} =    Create Dictionary    Status=KO    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    PINCodeDeletion    ${event_hub_timeout}    ${event_SRP_delete}
    Should Be True    ${verdict}    Failed to receive VNEXT NOTIFICATION SRP CLEAR PIN CODE STATUS: ${comment}

SEND VNEXT REQUEST PUSH MESSAGE
    [Arguments]    ${message_name}
    [Documentation]    == High Level Description: ==
    ...    Send a push message request to Vnext using the APIM
    ...    == Parameters: ==
    ...    - _message_name_: name of a message containing a specific message and configuration
    ...    == Expected Results: ==
    ...    Pass if the command is executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Push Messages    VNEXT APIM
    ${messageId} =    Get Command ID    PM_Suggestion
    ${Vehicle}=    Create Dictionary
    Set To Dictionary    ${Vehicle}    Vin    ${vehicle_id}
    @{VehicleAndUser}=    Create List
    Append To List    ${VehicleAndUser}    ${Vehicle}
    ${pm_params} =    Set To Dictionary    ${PM_profiles['${message_name}']}    VehicleAndUser    ${VehicleAndUser}
    ...    MessageIdentifier    ${messageId}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    PUSH_MESSAGE    PM    ${pm_params}
    Should Be True    ${verdict}    Failed to send VNext apim request : SEND VNEXT REQUEST PUSH MESSAGE: ${comment}

SEND VNEXT REMOTE CHARGING STATUS REQUEST
    [Documentation]    == High Level Description: ==
    ...    Send an API to Vnext to retrieve the remote charging data set.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    PASS if Executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE |  |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE |  |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Charging Status    VNEXT APIM
    ${charging_args} =    Create Dictionary    Type=LastKnown    ServiceId=RCHS    DatasetName=uid362
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    VehicleDataStatus    VehicleData    ${charging_args}
    Should Be True    ${verdict}    Failed to send VNext REMOTE CHARGING STATUS REQUEST: ${comment}

CHECK VNEXT CHARGING INHIBITOR NOTIFICATION
    [Arguments]    ${status}
    [Documentation]        == High Level Description: ==
    ...    Check if VNEXT publishes a notification regarding the BCI status.
    ...    == Parameters: ==
    ...    _status_: success/failed
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
    ${cmd_result} =    Set Variable if    "${status}" == "block_status_success"    ${1}    ${2}
    ${charge_inhib_notification} =    Create Dictionary    Status=${cmd_result}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    BCICommandStatus    ${event_hub_timeout}    ${charge_inhib_notification}
    Should Be True    ${verdict}    Failed inside CHECK VNEXT CHARGING INHIBITOR NOTIFICATION, Failed to receive Vnext Notification: ${comment}

CHECK VNEXT NOTIFICATION REQUEST RESULT
    [Arguments]    ${status}    ${service}    ${dataset}    ${time}
    [Documentation]    == High Level Description: ==
    ...    Check all data or context of a dataset are present
    ...    == Parameters: ==
    ...    _status_: Success, fail
    ...    _service_: Name of a service. Could be: 'djor', 'vher', 'rvsc', or any new remote dashboard
    ...    _dataset_: Name of a dataset (list of data). Could be: 'djh', 'vhr', 'rvscdata', or any new dataset
    ...    _time_: time in second
    ...    == Expected Results: ==
    ...    Pass if all expected data are present
    ${req_result_notification} =    Run Keyword If    "${dataset}" == "VHERV3UCDR"    Create Dictionary
    ...    ESCABSMalfunction=${1}     ESCBrakingFailureStatus=${1}    StatusDistanceTotalizer=${405}    OilPressureWarning=${1}
    ...    StatusWheelStateFrontRight=${1}    StatusWheelStateRearLeft=${1}    StatusWheelStateRearRight=${1}
    ...    StatusWheelStateFrontLeft=${1}    StatusBrakeLowFluidLevel=${2}     SCRDistanceAutonomy=${1}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION REQUEST RESULT
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    GetDataReturn    ${event_hub_timeout}    ${req_result_notification}
    Should Be True    ${verdict}    Failed to CHECK VNEXT NOTIFICATION REQUEST RESULT: ${comment}

CHECK EVENT HUB CHARGING INHIBITOR NOTIFICATION
    [Arguments]    ${status}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the UCD_Snapshot sent by the IVC.
    ...    == Parameters: ==
    ...    _status_: success/failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Battery Charge Inhibitor    AZURE EVENT HUB
    ${charge_inhib_notif_status} =    Run Keyword If    "${status}" == "blocked_status"    Create Dictionary    ChargeProhibitionByRental=${1}    Timestamp=${tstart}
    ...    ELSE    Create Dictionary    ChargeProhibitionByRental=${0}    Timestamp=${tstart}
    ${time} =    Create List    TimeStamp
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    BCInhibitorChange    ${event_hub_timeout}    ${charge_inhib_notif_status}    ${time}
    Should Be True    ${verdict}    Failed inside CHECK EVENT HUB CHARGING INHIBITOR NOTIFICATION Failed to receive Vnext Notification: ${comment}

CHECK VNEXT REMOTE CHARGING STATUS
    [Arguments]    ${expected_status}    ${charging_status_expected_value}    ${battery_energy_level_expected_value}
    ...    ${charge_plug_expected_status}    ${charge_remaining_time}         ${autonomy_display_expected_value}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP answer from a request. Check that {charging_status_expected_value} {battery_energy_level_expected_value}
    ...    {charge_plug_expected_status} {charge_remaining_time} have the expected values and the timestamp for the
    ...    response is close to the expected {time_stamp} +/- 10 seconds.
    ...    == Parameters: ==
    ...    _expected_status_: success, fail
    ...    _charging_status_expected_value_: 2, 3
    ...    _battery_energy_level_expected_value_: 45, 46, 48, etc
    ...    _charge_plug_expected_status_: 0, 1, 2
    ...    _charge_plug_expected_status_: 0, 1, 2
    ...    _charge_remaining_time_: a decimal value expressed in minutes
    ...    _autonomy_display_expected_value_: 100, 200
    ...    _time_stamp_: TimeStamp response +/- 10sec
    ...    == Expected Results: ==
    ...    PASS if all the parameters have values as expected;
    [Tags]    Automated    Remote Charging Status    VNEXT APIM
    ${args} =    Create List    VehicleDataStatus    VehicleData
    ${resp_attr_charging_status} =    Create Dictionary    Value=${${charging_status_expected_value}}    RepositoryLabel=ChargeStatus
    ...    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charging_status}
    Should Be True    ${verdict}    Failed to get VNext REMOTE CHARGING STATUS
    ${resp_attr_battery_energy_level} =    Create Dictionary    Value=${${battery_energy_level_expected_value}}    RepositoryLabel=EVHVBatteryEnergyLevel
    ...   Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_battery_energy_level}
    Should Be True    ${verdict}    Failed to get VNext REMOTE BATTERY ENERGY LEVEL STATUS
    ${resp_attr_charge_plug} =    Create Dictionary    Value=${${charge_plug_expected_status}}    RepositoryLabel=EVChargePlugConnected
    ...   Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_plug}
    Should Be True    ${verdict}    Failed to get VNext REMOTE CHARGE PLUG STATUS
    ${resp_attr_charge_remaining_time} =    Create Dictionary    Value=${${charge_remaining_time}}    RepositoryLabel=EVChargeRemainingTime
    ...   Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_remaining_time}
    Should Be True    ${verdict}    Failed to get VNext CHARGE REMAINING TIME STATUS
    ${resp_attr_autonomy_display} =    Create Dictionary    Value=${${autonomy_display_expected_value}}    RepositoryLabel=ZEVAutonomyDisplay
    ...   Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_autonomy_display}
    Should Be True    ${verdict}    Failed to get VNext AUTONOMY DISPLAY

RECORD VNEXT DATE & TIME
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Record the Vnext date and time.
    ...    == Parameters: ==
    ...    _attribute_name_: attribute name to save the date & time value
    ...    == Expected Results: ==
    ...    Passed when command executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    RECORD VNEXT DATE & TIME    VNEXT APIM
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    RECORD VNEXT DATE & TIME
    ${request_attr} =    Create Dictionary    PageNumber=${1}    PageSize=${50}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    GetVnextTime    VnextTime    ${request_attr}
    Should Be True    ${verdict}    Failed to send RECORD VNEXT DATE & TIME
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE TIMESTAMP    GetVnextTime    VnextTime    Success    ${empty_dict}    ${empty_list}
    Should Be True    ${verdict}    Failed to GET RECORD VNEXT DATE & TIME response
    ${time} =    Run Keyword If    'Time' in ${response}    Set Variable    ${response['Time']}
    ...    ELSE    Fail    Time not found in response ${response}
    ${remove_millis} =    Fetch From Left    ${time}    .
    ${convertedDate} =    robot.libraries.DateTime.Convert Date    ${remove_millis}    result_format=%Y-%m-%d %H:%M:%S     exclude_millis=yes    date_format=%Y-%m-%dT%H:%M:%S
    Run Keyword If    '${expected_status}'=='tstart'    Set Global Variable    ${tstart}    ${convertedDate}
    ...    ELSE    Set Global Variable    ${tstop}    ${convertedDate}
    [Return]    ${convertedDate}
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    RECORD VNEXT DATE & TIME end with success. Converted date : ${convertedDate}
    Sleep    2

SEND VNEXT REQUEST REMOTE CAR DASHBOARD
    [Arguments]    ${service}    ${dataset}    ${type}
    [Documentation]    == High Level Description: ==
    ...    Send a remote Car dashboard request for different dash board
    ...    == Parameters: ==
    ...    _service_: Name of a service. Could be: 'djor', 'vher', 'rvsc', or any new remote dashboard
    ...    _dataset_: Name of a dataset (list of data). Could be: 'djh', 'vhr', 'rvscdata', or any new dataset
    ...    _type_: Describe how the data shall be retrieved.
    ...    Could be: LastKnown, OnDemandWithoutWakeup, OnDemandWithWakeup, context
    ...    == Expected Results: ==
    ...    Passed when command executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    REQUEST REMOTE CAR DASHBOARD    VNEXT APIM
    ${context_name} =    Set Variable if    '${service}'=="RCHS"    Trip    All
    ${context_dict} =    Run Keyword If    '${type}'=="context"    Create Dictionary    ContextName=${context_name}
    ...    ELSE IF    '${type}'=="LastKnown" and '${service}' == "BUMI"    Create Dictionary    ContextName=${context_name}
    ...    ELSE    Create Dictionary    Type=${type}
    Set To Dictionary    ${context_dict}    ServiceId    ${service}    DatasetName    ${dataset}
    Run Keyword If    '${service}' == 'CDUI' or ('${service}' == 'FASI' and '${type}' == 'LastKnown')    Set To Dictionary    ${context_dict}    Type    ${type}
    ${verdict}    ${comment} =    Run Keyword If    '${type}'=="context"    SEND VNEXT APIM REQUEST    DATACONTEXT    Context    ${context_dict}
    ...    ELSE    SEND VNEXT APIM REQUEST    VehicleDataStatus    VehicleData    ${context_dict}
    Should Be True    ${verdict}    Failed to send REQUEST REMOTE CAR DASHBOARD

CHECK VNEXT DASHBOARD REQUEST RESPONSE
    [Arguments]    ${status}    ${service}    ${dataset}    ${data_type}    ${profile_name}
    [Documentation]    == High Level Description: ==
    ...    Check all data or context of a dataset are present between the "time_stamp_start" and the "time_stamp_stop"
    ...    == Parameters: ==
    ...    _status_: Success, fail
    ...    _service_: Name of a service. Could be: 'djor', 'vher', 'rvsc', or any new remote dashboard
    ...    _dataset_: Name of a dataset (list of data). Could be: 'djh', 'vhr', 'rvscdata', or any new dataset
    ...    _data_type_: could be 'data' or 'context'
    ...    _timestamp_start_: time in second
    ...    _timestamp_stop_: time in second
    ...    == Expected Results: ==
    ...    Pass if all expected data are present between the two time stamp
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    CHECK DASHBOARD REQUEST RESPONSE    VNEXT APIM
    ${args} =    Run Keyword If    '${data_type}'=="context"    Create List    DATACONTEXT    Context
    ...    ELSE    Create List    VehicleDataStatus    VehicleData
    FOR    ${item}    IN    @{PARAMS["${profile_name}"].keys()}
        ${resp_attr} =    Run Keyword If     ${PARAMS["${profile_name}"]["${item}"]}!=${None}
        ...    Create Dictionary    RepositoryLabel=${item}    Value=${PARAMS["${profile_name}"]["${item}"]}    TimeStart=${tstart}    TimeStop=${tstop}
        ...    ELSE    Create Dictionary    RepositoryLabel=${item}    TimeStart=${tstart}    TimeStop=${tstop}
        ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM DATACONTEXT RESPONSE    @{args}    ${status}    ${resp_attr}    ${empty_list}
        Run Keyword If    "not_updated" in "${profile_name}" and "${comment}"=="No response received"
        ...    Should Be True    ${verdict}    Failed to find the key inside the response
        ...    ELSE IF    "not_updated" in "${profile_name}"    Should Be Equal    "${verdict}"    "False"    Failed when checking the timestamp
        ...    ELSE    Should Be True    ${verdict}    Failed to CHECK VNEXT DASHBOARD REQUEST RESPONSE
    END

CHECK VNEXT SENT SMSWAKEUP TO IVC
    [Documentation]    == High Level Description: ==
    ...    Check on Vnext that Vnext send a SMS wakeup message
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    Pass if the message was sent by Vnext
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automatic    Remote Services Common    VNEXT APIM
    ${verdict}    ${comment} =    DO GET LAST SMS    WakeUpSms
    Should Be True    ${verdict}    ${comment}

DO GET LAST SMS
    [Arguments]    ${type}    ${check_timestamp}=yes
    [Documentation]    == High Level Description: ==
    ...    Check on Vnext that the last sent Sms of specific type
    ...    == Parameters: ==
    ...    _type_: OMA-DMSms, WakeUpSms
    ...    == Expected Results: ==
    ...    Returns last SMS sent by VNEXT of specific type
    [Tags]    Automated    Remote Services Common    VNEXT APIM
    Sleep    15
    ${args} =    Create List    VehicleAdmin    Sms
    ${status} =    Set Variable    Success
    ${StandardAdmin_param} =    Create Dictionary    UserId=${user_id}    ResourceType=Vin    ResourceValue=${vehicle_id}
    SEND VNEXT APIM REQUEST   @{args}   ${StandardAdmin_param}
    Run Keyword If    "${tstart}" == "None" or "${check_timestamp}" == "no"    RECORD VNEXT DATE & TIME    tstart

    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    @{args}    ${status}    ${empty_dict}
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    ${all_sms} =    Create Dictionary
    ${sms_dates} =    Create List
    ${data} =    Convert To Dictionary   ${response['result']}
    FOR    ${sms}   IN    @{data}
        Set To Dictionary    ${all_sms}    ${sms['DateEnqueued']}    ${sms}
        Append To List    ${sms_dates}    ${sms['DateEnqueued']}
    END
    Sort List    ${sms_dates}
    ${last_sms_date} =    Get From List    ${sms_dates}    -1
    ${last_sms} =    Get From Dictionary    ${all_sms}    ${last_sms_date}
    Return From Keyword If    "${last_sms['Type']}" != "${type}" or "${last_sms['SmsSentStatus']}" != "Sent"    False     Failed to GET LAST SMS
    ${remove_millis} =    Fetch From Left    ${last_sms['DateSent']}    .
    ${sent_date} =    robot.libraries.DateTime.Convert Date    ${remove_millis}    result_format=%Y-%m-%d %H:%M:%S     exclude_millis=yes    date_format=%Y-%m-%dT%H:%M:%S
    Return from keyword if     "${check_timestamp}" == "no"    ${sent_date}    ${tstart}
    ${sent_date} =    robot.libraries.DateTime.Add Time To Date    ${sent_date}    1m    result_format=%Y-%m-%d %H:%M:%S     exclude_millis=yes    date_format=%Y-%m-%d %H:%M:%S
    ${verdict}    ${comment}=    Run Keyword If   "${sent_date}" > "${tstart}"    Set Variable    True    SMS FOUND ${sent_date} match ${tstart}
    ...    ELSE   Set Variable    False    Timestamp of the SMS ${sent_date} does not match tstart ${tstart}
    [Return]    ${verdict}    ${comment}

CHECK VNEXT RHOO NOTIFICATION
    [Documentation]    == High Level Description: ==
    ...    Checks if VNEXT publishes a final notification with the {status} of the remote HVAC request.
    ...    == Parameters: ==
    ...    - _status_: success, failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    RHOO    VNEXT EVENTHUB
    [Arguments]    ${status}     ${error_code}=${None}
    ${cmd_result} =    Set Variable If    "${status}".lower() == "hvac_on_success"    ${0}
    ...    "${status}".lower() == "hvac_off_success"    ${1}
    ${error_result} =    Run Keyword If    "${status}".lower() == "fail"    Fetch From Right    ${error_code}    error_code=
    ${rhoo_status} =    Run Keyword If    "${status}".lower() == "hvac_on_success" or "${status}".lower() == "hvac_off_success"    Create Dictionary    Status=${cmd_result}
    ...    ELSE    Create Dictionary    ErrorCode=${error_result}
    IF  "kmr" in $instance
        Set To Dictionary    ${rhoo_status}    CommandId=${CommandId_RHOO}
    ELSE
        Set To Dictionary    ${rhoo_status}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RPSCommandStatus    ${event_hub_timeout}    ${rhoo_status}
    Should Be True    ${verdict}    Failed to CHECK VNEXT RHOO NOTIFICATION: ${comment}

CHECK VNEXT NOTIFICATION RHOO RESULT
    [Arguments]    ${status}    ${HVACTemp}
    [Documentation]    == High Level Description: ==
    ...    Checks if VNEXT publishes a final notification with the {status} of the remote HVAC result.
    ...    == Parameters: ==
    ...    - _status_: success, failed
    ...    - _HVACTemp_: represents the current temperature value inside the vehicle
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    RHOO    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RHOO RESULT
    ${cmd_result} =    Set Variable if    "${status}".lower() == "success"    Success    Failed
    IF  "kmr" in $instance
        ${rhoo_result} =    Create Dictionary    OperationResult=${cmd_result}    HVACTemperatureCabinCurrentValue=${HVACTemp}    CommandId=${CommandId_RHOO}
    ELSE
        ${rhoo_result} =    Create Dictionary    OperationResult=${cmd_result}    HVACTemperatureCabinCurrentValue=${HVACTemp}    CommandId=${Apim_CommandId}
    END
    ${verdict_resp}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    PresoakStatusNotification    ${event_hub_timeout}    ${rhoo_result}
    Should Be True    ${verdict_resp}    Failed to CHECK VNEXT NOTIFICATION RHOO RESULT: ${comment}

CHECK VNEXT HAS A LAST KNOWN LOCATION
    [Documentation]    == High Level Description: ==
    ...    Check in Vnext that the last known car location is present
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    My Car Finder Service    VNEXT APIM
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT HAS A LAST KNOWN LOCATION (not implemented)
    Log    CHECK VNEXT HAS A LAST KNOWN LOCATION is not implemented    WARN

CHECK VNEXT SERVICE ACTIVATION STATUS
    [Arguments]    ${service_name}    ${status}    ${SA_State}=False
    [Documentation]  Check if a given  service is activated or deactivated
    IF    "${service_name}".lower() in ${tech_prods}
        ${tech_prod_id} =    Set Variable    ${tech_prods["${service_name}".lower()]}
    ELSE
        Fail    No implementation for service_name ${service_name}
    END
    @{tech_ids} =    Create List    ${{int('${tech_prod_id}')}}
    &{sa_args} =    Create Dictionary    VIN=${vehicle_id}    TechProdIds=${tech_ids}
    ${verdict}    ${last_status} =    SEND VNEXT APIM REQUEST SERVICE STATUS CHECK    ServiceActivationStatus    SA    ${sa_args}
    Should Be True    ${verdict}    Fail to SEND VNEXT APIM REQUEST SERVICE STATUS CHECK: ${last_status}
    ${args} =    Create List    ServiceActivationStatus    SA
    ${status_dict}=    Create Dictionary    LastServiceStatus=${status}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    @{args}    Success    ${status_dict}
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    IF    ${SA_State} == True
        Run Keyword and Warn on failure    Should Be True    ${verdict}    ${comment}
    ELSE
        Should Be True    ${verdict}    ${comment}
    END
    [Return]    ${verdict}    ${comment}

SEND VNEXT REQUEST RVLS
    [Arguments]    ${rvls_req}
    [Documentation]    Send a remote vehicle lock status
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    SEND VNEXT REQUEST RVLS
    ${cmd_result} =    Set Variable If    "${rvls_req}" == "rvls_request_on_demand_without_wakeup"    RVLS_LockStatusCheckOndemand
    ...    "${rvls_req}" == "rvls_request_lastknown"    RVLS_LockStatusCheck
    ...    "${rvls_req}" == "rvls_request_on_demand_with_wakeup"    RVLS_LockStatusCheckOndemandWithWakeup
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    RemoteLockUnlockCommand    ${cmd_result}    ${empty_dict}
    Should Be True    ${verdict}

CHECK VNEXT NOTIFICATION RVLS ACK
    [Arguments]    ${StatusDoorOutsideLockedState}
    [Documentation]    Check Vnext for last known 'remote vehicle lock status'
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RVLS ACK
    ${cmd_result} =    Set Variable if    "${StatusDoorOutsideLockedState}" == "Lock"    ${1}    ${0}
    IF  "kmr" in $instance
        ${rvls_status} =    Create Dictionary    MessageType=VehicleLockStatus    StatusDoorOutsideLockedState=${cmd_result}
    ELSE
        ${rvls_status} =    Create Dictionary    MessageType=VehicleLockStatus    StatusDoorOutsideLockedState=${cmd_result}    CommandId=${Apim_CommandId}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    VehicleLockStatus    ${event_hub_timeout}    ${rvls_status}
    Should Be True    ${verdict}    ${comment}

CHECK ALL SERVICES ACTIVATED
    @{tech_prod_ids}=    Create List
    ${args}=    Create Dictionary    Vin=${vehicle_id}    TechProdIds=${tech_prod_ids}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    ServiceActivationStatus   SA    ${args}
    [Return]    ${verdict}


#*****FROM CCS1

SEND VNEXT REQUEST PRESOAK SCHEDULE
    [Arguments]    ${presoak_calendar_profile}
    [Documentation]        == High Level Description: ==
    ...    Send to Vnext a remote request with a specific {presoak_profile_calendar} schedule
    ...    == Parameters: ==
    ...    _presoak_profile_calendar_: a profile with specific calendar entries
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    Pass if Vnext request is sent successfully
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote HVAC scheduling    VNEXT APIM
    ${calendar_list} =    Create List    ${Calendar["${presoak_calendar_profile}"]}
    ${calendar_dict} =    Create Dictionary    Calendar=${Calendar["${presoak_calendar_profile}"]}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    Remote_HVAC_scheduling    RHVS    ${calendar_dict}
    Should Be True    ${verdict}    Failed to send to Vnext a remote request with a specific {presoak_profile_calendar} schedule

CHECK VNEXT PRESOAK SETTINGS NOTIFICATION
    [Arguments]    ${message_type}    ${status}    ${ret_param}=${None}
    [Documentation]    == High Level Description: ==
    ...    Check if VNEXT publishes a notification regarding the RHVS synchronization status.
    ...    == Parameters: ==
    ...    - _status_: success/failed
    ...    - _message_type_: represents the type of the message. It can be: EVPreconditioningAcknowledgement or EVPreconditioningSynchro:
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Manual    Remote HVAC scheduling    VNEXT EVENTHUB
    ${presoak_result} =    Set Variable if    "${status}".lower() == "success"    OK    TIMEOUT
    IF  "kmr" in $instance
        ${presoak_dict} =    Create Dictionary    Status=${presoak_result}
    ELSE
        ${presoak_dict} =    Create Dictionary    Status=${presoak_result}    CommandId=${Apim_CommandId}
    END
    ${notif_type} =    Set Variable If    "${message_type}" == "EVPreconditioningAcknowledgement"    CommandResponse
    ...    Notification
    ${verdict_resp}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    ${notif_type}    ${message_type}    ${event_hub_timeout}    ${presoak_dict}    ${ret_param}
    Set Test Variable    ${response}    ${response_dict}
    ${verdict_resp} =   Run Keyword If    '${status}'=='failed' and '${comment}' == 'Timeout reached before expected event hub data was received'   Set Variable  True
    ...    ELSE IF  "${status}".lower()=='success' and ${verdict_resp}==True   Set Variable  True
    ...    ELSE     Set Variable    False
    Should Be True    ${verdict_resp}    Failed to CHECK VNEXT PRESOAK SETTINGS NOTIFICATION: ${comment}

SEND VNEXT CHARGE REQUEST
    [Arguments]    ${charge_type}
    [Documentation]        == High Level Description: ==
    ...    From [External System Simulator] send to VNEXT a {charge_type} request
    ...    == Parameters: ==
    ...    _charge_type_: always, scheduled, delayed, status
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote charging start & stop   VNEXT APIM
    ${target_id} =    Set Variable If    "${charge_type}" == "schedule_five_calendars_deactivated"    EVCD    EVC
    ${rcss_args} =    Run Keyword If    "${charge_type}" == "always"    Create Dictionary    ChargingMode=${charge_type}
    ...    ELSE IF    "${charge_type}" == "delayed"    Create Dictionary    ChargingMode=${charge_type}    Delay=${14}
    ...    ELSE IF    "${charge_type}" == "schedule_one_calendar_activated"    Create Dictionary    ChargingMode=scheduled    Calendar=${Calendar["${charge_type}"]}
    ...    ELSE IF    "${charge_type}" == "schedule_five_calendars_activated"    Create Dictionary    ChargingMode=scheduled    Calendar=${Calendar["${charge_type}"]}
    ...    ELSE IF    "${charge_type}" == "schedule_five_calendars_deactivated"    Create Dictionary    chargingMode=scheduled    Calendar=${Calendar["${charge_type}"]}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    RemoteChargingStartAndStop    ${target_id}    ${rcss_args}
    Should Be True    ${verdict}    Failed inside SEND VNEXT CHARGE REQUEST, the request failed to send: ${comment}

CHECK VNEXT CHARGING SYNC NOTIFICATION
    [Arguments]    ${message_type}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if VNEXT published a notification regarding the charging synchronization status
    ...    == Parameters: ==
    ...    - _status_ : success/failed
    ...    -_message_type_: represents the type of the message. It can be: RemoteChargingChangeSettings or EVChargeSynchro
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote charging start & stop    VNEXT EVENTHUB
    ${charge_result} =    Set Variable if    "${status}".lower() == "success"    OK    TIMEOUT
    IF  "kmr" in $instance
        ${charge_status} =    Create Dictionary    Status=${charge_result}
    ELSE
        ${charge_status} =    Create Dictionary    Status=${charge_result}    CommandId=${Apim_CommandId}
    END
    ${rcss_message} =    Set Variable if    "${message_type}" == "RemoteChargingChangeSettings"    CommandResponse
    ...    "${message_type}" == "EVChargeSynchro"    Notification
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    ${rcss_message}    ${message_type}    ${event_hub_timeout}    ${charge_status}
    Run Keyword If    "${status}".lower() == "success"    Should Be True    ${verdict}    Failed inside CHECK VNEXT CHARGING SYNC NOTIFICATION, the request failed to send: ${comment}
        ...    ELSE IF    "${status}" in "${comment}"    Should Be Equal    "${verdict}"    ${False}    Comment:${comment}
        ...    ELSE    Should Be Equal    ${verdict}    ${False}    Comment:${comment}

CHECK VNEXT COMMAND STATUS FOR PUSH MESSAGE
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext command status for push message services
    ...    == Parameters: ==
    ...    - _expected_status_: null, pending, success, fail, timeout
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Push Messages    VNEXT APIM
    Log    CHECK VNEXT COMMAND STATUS FOR PUSH MESSAGE is not implemented    WARN

CHECK REDBEND FOTA CAMPAIGN
    [Arguments]    ${status}    ${profil_name}
    [Documentation]    == High Level Description: ==
    ...    Check a redbend fota campaign status & profil name.
    ...    == Parameters: ==
    ...    - _status_: Pending, Success, Running, Fail
    ...    - _profil_name_: name of a campaign profile
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Service subscription management    REDBEND
    Log    CHECK REDBEND FOTA CAMPAIGN is not implemented    WARN

CHECK REDBEND NO FOTA CAMPAIGN IN PROGRESS
    [Documentation]    == High Level Description: ==
    ...    Check that no FOTA Campaign is on going
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Service subscription management    REDBEND
    Log    CHECK REDBEND NO FOTA CAMPAIGN IN PROGRESS is not implemented    WARN

CHECK VNEXT LAST KNOWN SNAPSHOT DATA
    [Arguments]    ${status}    ${profile_name}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP response of a "VNEXT REQUEST REMOTE CAR DASHBOARD".
    ...    Check that returned data is valid and uploaded at a proper timestamp.
    ...    == Parameters: ==
    ...    _status_: Success, fail
    ...    _profile_name_: {[RepositoryLabel1:Value1,]} represents a dictionary that could support multiple input values based on the needs
    ...    == Expected Results: ==
    ...    Pass if all expected data is present between the two time stamp.
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Last Known FASI    VNEXT APIM
    ${args} =    Create List    VehicleDataStatus    VehicleData
    FOR    ${item}    IN    @{PARAMS["${profile_name}"].keys()}
        ${resp_attr} =    Run Keyword If     ${PARAMS["${profile_name}"]["${item}"]}!=${None}
        ...    Create Dictionary    RepositoryLabel=${item}    Value=${PARAMS["${profile_name}"]["${item}"]}    Timestamp=${tstart}
        ...    ELSE    Create Dictionary    RepositoryLabel=${item}    Timestamp=${tstart}
        ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${status}    ${resp_attr}
        Run Keyword If    "not_updated" in "${profile_name}" and "${comment}"=="No response received"
        ...    Should Be True    ${verdict}    Failed to find the key inside the response
        ...    ELSE IF    "not_updated" in "${profile_name}"    Should Be Equal    "${verdict}"    "False"    Failed when checking the timestamp
        ...    ELSE    Should Be True    ${verdict}    Failed to get VNEXT LAST KNOWN SNAPSHOT DATA
    END

CHECK VNEXT NOTIFICATION NTCS RESULT
    [Arguments]    ${ChargeStatus}    ${expected_status}=success
    [Documentation]    == High Level Description: ==
    ...    Check that [Vnext] publishes a notification on the Event Hub for the charging start/stop service
    ...    == Parameters: ==
    ...    _ChargeStatus_: represents the state for the charging status signal (ex.: start, stop)
    ...    == Expected Results: ==
    ...    Pass if the expected data is present in the Event Hub at the expected timestamp
    [Tags]    Automated    Charging start/stop    AZURE EVENT HUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION NTCS RESULT
    ${cmd_result} =    Set Variable if    "${ChargeStatus}" == "start"    ${3}    ${2}
    ${ntcs_result} =    Run Keyword If    "${expected_status}".lower() == "success"    Create Dictionary    ChargeStatus=${cmd_result}    EVHVBatteryEnergyLevel=${48}    TimeStamp=${tstart}
    ...    ELSE    Create Dictionary    ChargeStatus=${cmd_result}    EVHVBatteryEnergyLevel=${48}
    ${time} =    Run Keyword If    "${expected_status}".lower() == "success"    Create List    TimeStamp
    ...    ELSE    Create List
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    CDChargeStatusNotification    ${event_hub_timeout}    ${ntcs_result}    ${time}
    Run Keyword If    "${expected_status}".lower() == "success"    Should Be True    ${verdict}    Failed to check VNEXT NOTIFICATION NTCS RESULT with comment: ${comment}
    ...    ELSE IF    "${expected_status}" in "${comment}"    Should Be Equal    "${verdict}"    ${False}    Comment:${comment}
    ...    ELSE    Should Be Equal    ${verdict}    ${False}    Comment:${comment}

CHECK VNEXT NOTIFICATION NRHT RESULT
    [Arguments]    ${presoak_activation_status}
    [Documentation]    == High Level Description: ==
    ...    Check that [Vnext] publishes a notification on the Event Hub for the remote HVAC On&Off service
    ...    == Parameters: ==
    ...    _presoak_activation_status_: represents the state for the presoak activation status signal
    ...    == Expected Results: ==
    ...    Pass if the expected data is present in the Event Hub at the expected timestamp
    [Tags]    Automated    Remote HVAC On/Off    AZURE EVENT HUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION NRHT RESULT
    ${cmd_result} =    Set Variable if    "${presoak_activation_status}" == "presoak_activation_status"    ${2}    ${1}
    ${nrht_result} =    Create Dictionary    PresoakActivationStatus=${cmd_result}    TimeStamp=${tstart}
    ${time} =    Create List    TimeStamp
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    PresoakStatusNotification    ${event_hub_timeout}    ${nrht_result}    ${time}
    Should Be True    ${verdict}    Failed to check VNEXT NOTIFICATION NRHT RESULT with comment: ${comment}

SEND VNEXT REQUEST FOR UCD ORDER TO IVC
    [Documentation]    == High Level Description: ==
    ...    Send a Vnext request to trig a UCD order to IVC
    ...    with the parameter needed
    ...    == Parameters: ==
    ...    - ResourceType
    ...    - ResourceValue
    ...    - UserId
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    UCD ORDER    VNEXT APIM
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    VehicleConnectivityAdmin    SendUCDCommand    ${StandardAdmin_param}
    Should Be True    ${verdict}    Failed to send VNext Send UCD APIM request with comment : ${comment}

SEND VNEXT REQUEST FOR CHECKING UCD ORDER RESULT
    [Documentation]    == High Level Description: ==
    ...    Send a Vnext request in order to request Vnext to check a previous UCD ORDER REQUEST result
    ...    == Parameters: ==
    ...    _attribute_name_: attribute name to save the attribute value
    ...    == Expected Results: ==
    ...    Passed when command executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    SEND VNEXT REQUEST FOR CHECKING UCD ORDER RESULT    VNEXT APIM
    ${StandardAdmin_param} =    Create Dictionary    ResourceType=Vin    ResourceValue=${vehicle_id}    CommandId=${Apim_CommandId}    UserId=${user_id}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   VehicleConnectivityAdmin    UCDCommandStatus    ${StandardAdmin_param}
    ${state_dict} =    Create Dictionary    State=Success
    ${verdict}    ${comment}    ${response} =   CHECK VNEXT APIM RESPONSE   VehicleConnectivityAdmin    UCDCommandStatus    Success    ${state_dict}
    Should Be True    ${verdict}    ${comment}:${response}
    [Return]    ${response['State']}

RECORD ATTRIBUTE
    [Arguments]    ${attribute_name}
    [Documentation]    == High Level Description: ==
    ...    Record an attribute.
    ...    == Parameters: ==
    ...    _attribute_name_: attribute name to save the attribute value
    ...    == Expected Results: ==
    ...    Passed when command executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    RECORD ATTRIBUTE    VNEXT APIM
    # simulate a timeout for the vnext response
    FOR    ${var}    IN RANGE    1    185
        ${verdict}    ${comment}    ${response} =   CHECK VNEXT APIM RESPONSE   VehicleConnectivityAdmin    SendUCDCommand    Success
        Should Be True    ${verdict}    ${comment}
        ${command_id} =    Run Keyword If    '${attribute_name}' in ${response}     Run keyword and return status     Set Variable    ${response['${attribute_name}']}
        IF    'CommandId' in $response
            Set Variable    ${Apim_CommandId}    ${response['CommandId']}
        END
        Exit For Loop IF    "${command_id}" == "True"
        Sleep    5
    END
    # fail if timeout reached
    Run Keyword If    "${Apim_CommandId}" == "None"    Fail    CommandId not found in response ${response}

CHECK VNEXT NOTIFICATION HVAC SETTINGS
    [Arguments]    ${message_type}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if VNEXT publishes a notification with the HVAC settings parameter
    ...    == Parameters: ==
    ...    - _status_: success/failed
    ...    - _message_type_: represents the type of the message. It can be: RCDData
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote climate control    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION HVAC SETTINGS
    ${rcci_result} =    Set Variable If    "${status}".lower() == "success"    OK    TIMEOUT
    IF  "kmr" in $instance
        ${rcci_dict} =    Create Dictionary    Status=${rcci_result}    ExternalTempValue=${25}    HVACTemperatureCabinCurrentValue=${26}    Timestamp=${tstart}
    ELSE
        ${rcci_dict} =    Create Dictionary    Status=${rcci_result}    ExternalTempValue=${25}    HVACTemperatureCabinCurrentValue=${26}    Timestamp=${tstart}    CommandId=${Apim_CommandId}
    END

    ${notif_type} =    Set Variable If    "${message_type}" == "RCDData"    CommandResponse    RCDData
    ${time} =    Create List    Timestamp
    ${verdict_resp}    ${comment}     ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    ${notif_type}    ${message_type}    ${event_hub_timeout}    ${rcci_dict}    ${time}
    Should Be True    ${verdict_resp}    Failed to CHECK VNEXT NOTIFICATION HVAC SETTINGS: ${comment}

CHECK PRIVACY MODE STATUS ON VNEXT
    [Arguments]    ${state}    ${resp_attr}=&{empty_dict}
    [Documentation]    Check in vNext if the status of Privacy mode is set to state:${state}
    Run Keyword if    "${console_logs}" == "yes"       Log To Console    CHECK PRIVACY MODE STATUS ON VNEXT
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    PrivacyMode    PMA    ${resp_attr}
    Should Be True    ${verdict}    Failed to send VNEXT CHECK PRIVACYMODE REQUEST: ${comment}
    IF    "${ivi_my_feature_id}" == "MyF1"
        ${cmd_result} =    Set Variable if    "${state}".lower() == "on"    0    1
    ELSE
        ${cmd_result} =    Set Variable if    "${state}".lower() == "geolocation_on"    2
        ...    "${state}".lower() == "geolocation_off" or "${state}".lower() == "off"    1    0
    END
    ${privacy_status} =    Create Dictionary    MultimediaPrivacyModeState=${cmd_result}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    PrivacyMode    PMA    Success    ${privacy_status}
    Should Be True    ${verdict}    Privacy mode status is not set to the expected state:${state}

CHECK EVENT HUB POSITION TRACKING NOTIFICATION
    [Arguments]    ${trigger}    ${negative_TC}=${False}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the TWT Position Tracking sent by the IVC.
    ...    == Parameters: ==
    ...    _status_: success/failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Position Tracking    AZURE EVENT HUB
    ${twt_position_tracking} =    Run Keyword If    ${negative_TC}==${False}
    ...    Create Dictionary     Trigger=${trigger}
    ...    ELSE    Create Dictionary    Trigger=${trigger}    TimeStamp=${tstart}
    ${time} =    Run Keyword If    ${negative_TC}!=${False}    Create List    TimeStamp
    ...    ELSE    Create List
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    TWTNotificationGPS    ${event_hub_timeout}    ${twt_position_tracking}    ${time}
    Run Keyword If    ${negative_TC} == ${False}
    ...    Should Be True    ${verdict}    Failed inside CHECK EVENT HUB POSITION TRACKING NOTIFICATION Failed to receive Vnext Notification: ${comment}
    ...    ELSE    Should Not Be True    ${verdict}    Failed inside CHECK EVENT HUB POSITION TRACKING NOTIFICATION Didn't expect any Vnext Notification

CHECK EVENT HUB TWT DEACTIVATION NOTIFICATION
    [Arguments]    ${km}    ${trigger}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the TWT Deactivation sent by the IVC.
    ...    == Parameters: ==
    ...    _status_: success/failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Position Tracking    AZURE EVENT HUB
    ${totaldistancedriven} =    Create Dictionary     Trigger=${trigger}    TotalDistanceDriven=${km}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    TWTNotificationTotalDistance    ${event_hub_timeout}    ${totaldistancedriven}
    Should Be True    ${verdict}    Failed inside CHECK EVENT HUB TWT DEACTIVATION NOTIFICATION Failed to receive Vnext Notification: ${comment}

RETRIEVE KUSTO LOGS FOR
    [Arguments]    ${service}    ${max_cols}=300000
    [Documentation]    == High Level Description: ==
    ...    Retrieve Kusto logs from VNext
    ...    == Parameters: ==
    ...    - _service_: represents the type of the service. It can be: BUMI, CDUI
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${comment} =    RETRIEVE THE KUSTO LOGS    ${service}    ${vnext_vehicle_id}    ${tstart}    ${tstop}    ${max_cols}
    Should Be True    ${verdict}    Failed to Retrieve Kusto Logs: ${comment}

CHECK DATA IN KUSTO
    [Arguments]    ${trigger_type}    ${kusto_label}    ${value}    ${data_expected_present}=True
    [Documentation]    == High Level Description: ==
    ...    Check if data uploaded to VNext matches with dat published
    ...    == Parameters: ==
    ...    - _trigger_type_: represents the type of the trigger.
    ...    - _kusto_label_: represents the kusto label whose data needs to be verified
    ...    - _value_: data value to be verified
    ...    - _data_expected_present_: represents whether expected data to be present in kusto logs or not(By default True:data is present)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${response} =    CHECK DATA IN KUSTO FOR    ${trigger_type}    ${kusto_label}    ${value}
    Run Keyword if    "${data_expected_present}" == "True"     Should Be True    ${verdict}    Failed to validate data with the Kusto Logs received: ${response}
    ...     ELSE    Should Not Be True    ${verdict}    Data is retrieved from KUSTO Logs: ${response}

CHECK NUMBER OF TRIGGER IN KUSTO
    [Arguments]    ${service}   ${max_number_of_messages}
    [Documentation]    == High Level Description: ==
    ...    Retrieve Kusto logs from VNext
    ...    == Parameters: ==
    ...    - _service_: represents the type of the service. It can be: BUMI, CDUI
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${stop} =    RECORD VNEXT DATE & TIME    tstop
    ${vnext_24h_back} =    robot.libraries.DateTime.Subtract Time From Date    ${stop}    1 days
    ${start} =    Fetch From Left    ${vnext_24h_back}    .
    Set Global Variable    ${tstart}    ${start}
    Set Global Variable    ${tstop}    ${stop}
    Run Keyword if    "${console_logs}" == "yes"     Log to Console     Start time: ${tstart}
    Run Keyword if    "${console_logs}" == "yes"     Log to Console     Stop time: ${tstop}
    ${verdict}    ${comment} =    RETRIEVE THE KUSTO LOGS    ${service}    ${vnext_vehicle_id}    ${tstart}    ${tstop}
    ${logs_pattern} =    Get Lines Containing String    ${comment}    TriggerType
    ${number_of_logs} =    Get Line Count    ${logs_pattern}
    Run Keyword if    "${console_logs}" == "yes"     Log to console    NR of logs:${number_of_logs} < ${max_number_of_messages}
    Should Be True	${number_of_logs} < ${max_number_of_messages}

CHECK VNEXT MQTT CONNECTION STATUS
    [Arguments]    ${dut_id}    ${expected_connection_state}
    [Documentation]    == Send a Vnext request in order to check the connectivity with Vnext through MQTT: ==
    ...    == Parameters: ==
    ...    - _dut_id_: IVC or IVI
    ...    - _expected_connection_state_: connected or disconnected
    ...    == Expected Results: ==
    ...    output: Pass if the response of vnext contain the expected_connection_state for the dut_id
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | CCS1-SIT_MULTILIVE | X | to be review | |
    ...    | CCS1-STG_MULTILIVE | X | to be review | |
    ...    | CCS1-KAI-SIT_MULTILIVE | X | to be review | |
    Wait Until Keyword Succeeds    180s    15s    RETRY FOR MQTT CONNECTION STATUS    ${dut_id}    ${expected_connection_state}

RETRY FOR MQTT CONNECTION STATUS
    [Arguments]    ${dut_id}    ${expected_connection_state}
    ${args} =    Create List    CheckDeviceConnectivity    MQTT
    ${StandardAdmin_param} =    Create Dictionary    ResourceType=Vin    ResourceValue=${vehicle_id}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   @{args}   ${StandardAdmin_param}
    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST
    ${response} =    Fetch From Right    ${comment}    received:
    ${response} =   Convert To Dictionary    ${response}
    Should Be Equal     '${response['${dut_id.upper()}']['ConnectionState']}'    '${expected_connection_state.capitalize()}'    ${dut_id} is not ${expected_connection_state}

CHECK VNEXT PROVISIONING STATUS
    [Arguments]    ${state}
    [Documentation]    == High Level Description: ==
    ...    To check that the device is bootstrapped or not
    ...    == Parameters: ==
    ...    - state: Provisioning Status can be "bootstrapped" or "DISPATCHED"
    ...    == Expected Results: ==
    ...    output: passed if the retrieved state is equal with the desired one
    ${args} =    Create List    VehicleAdmin    Summary
    ${StandardAdmin_param} =    Create Dictionary    ResourceType=Vin    ResourceValue=${vehicle_id}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   @{args}   ${StandardAdmin_param}
    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST
    ${response} =    Fetch From Right    ${comment}    received:
    ${response} =   Convert To Dictionary    ${response}
    Should Be Equal     '${response['VehicleCommon']['carStatus']}'    '${state}'
    ...    Wrong provisioning state. '${response['VehicleCommon']['carStatus']}' instead of ${state}

CHECK VNEXT PBO STATUS
    [Arguments]    ${state}   ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Check that PBO status.
    ...    == Parameters: ==
    ...    - state: PBO status
    ...    == Expected Results: ==
    ...    output: Pass if PBO status is ACTIVATED
    ${args} =    Create List    VehicleAdmin    Summary
    ${StandardAdmin_param} =    Create Dictionary    ResourceType=Vin    ResourceValue=${vehicle_id}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   @{args}   ${StandardAdmin_param}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST
    ...    ELSE    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST
    ${response} =    Fetch From Right    ${comment}    received:
    ${response} =   Convert To Dictionary    ${response}
    Should Be Equal     '${response['VehicleCommon']['PBOStatus']}'    '${state}'
    ...    Wrong PBO status. '${response['VehicleCommon']['PBOStatus']}' instead of ${state}

SEND VNEXT RESET VEHICLE STATUS REQUEST
    [Documentation]    == High Level Description: ==
    ...    Send a request to reset the PBO status.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: Pass if PBO status is ACTIVATED
    ${args} =    Create List    PBO    PBOReset
    ${param} =    Create Dictionary       ExcludePBO=${false}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   @{args}   ${param}
    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST for resetting PBO

CHECK VNEXT REQUEST RESPONSE RESET VEHICLE STATUS
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP ACK answer from a reset vehicle status request.
    ...    == Parameters: ==
    ...    - _expected status_: Success, fail, …
    ...    == Expected Results: ==
    ...    Pass if {expected status} is the one received in response
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    VNEXT APIM
    ${args} =    Create List    PBO    PBOReset
    ${status_dict}=    Create Dictionary    status=${expected_status}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    @{args}    ${expected_status}    ${status_dict}
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    Should Be True    ${verdict}    Fail to CHECK VNEXT REQUEST RESPONSE: ${comment}
    Set Test Variable    ${correlationId}    ${response['correlationId']}

SEND VNEXT STATUS REQUEST
    [Documentation]    == High Level Description: ==
    ...    Send a request to get the reset vehicle status.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: Pass if PBO status is ACTIVATED
    ${args} =    Create List    PBO    PBOGetStatus
    ${param} =    Create Dictionary    corrid=${correlationId}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   @{args}   ${param}
    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST for getting the reset status

CHECK VNEXT STATUS RESULT
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP ACK answer from a get vehicle status request.
    ...    == Parameters: ==
    ...    - _expected status_: Success, fail, …
    ...    == Expected Results: ==
    ...    Pass if {expected status} is the one received in response
    [Tags]    Automated    Remote Services Common    VNEXT APIM
    ${args} =    Create List    PBO    PBOGetStatus
    ${param} =    Create Dictionary       correlationId=${correlationId}    status=${expected_status}
    Wait Until Keyword Succeeds    60m    30s    RETRY READ VNEXT STATUS    ${args}    ${expected_status}    ${param}

RETRY READ VNEXT STATUS
    [Arguments]    ${args}    ${expected_status}    ${param}
    SEND VNEXT STATUS REQUEST
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    @{args}    ${expected_status}    ${param}
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    Should Be True    ${verdict}    Fail to CHECK VNEXT REQUEST RESPONSE: ${comment}

CHECKSET SW INVENTORY IS DONE
    [Documentation]    == High Level Description: ==
    ...    Check that the SW inventory has been done.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: Pass if PBO status is ACTIVATED
    Run Keyword if    "${console_logs}" == "yes"     Log    CHECKSET SW INVENTORY IS DONE is not implemented    WARN
    ...    ELSE    Log    CHECKSET SW INVENTORY IS DONE is not implemented

CHECK VNEXT EVENT HUB NOTIFICATION
    [Arguments]    ${profile}    ${value}=${NONE}
    [Documentation]    == High Level Description: ==
    ...    Spy the event hub and check the message is received in vNext event hub.
    ...    == Parameters: ==
    ...    _profile_: type of the notification
    ...    _value_: value to be search for
    ...    == Expected Results: ==
    ...    output: Pass if message is received
    Run Keyword If    "${profile}".lower() == "pbo"    CHECK VNEXT EVENT HUB NOTIFICATION PBO
    ...    ELSE IF    "${profile}".lower() == "bootstrap_status"    CHECK VNEXT EVENT HUB NOTIFICATION BOOTSTRAP
    ...    ELSE    Fail    Implementation not done for profile ${profile}

CHECK VNEXT EVENT HUB NOTIFICATION PBO
    ${event_hub_pbo_params} =    Create Dictionary    MessageType=ServiceActivationPBO    Message=PBO has been activated    Status=Activated
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    ServiceManagement    ServiceActivationPBO    ${event_hub_timeout}    ${event_hub_pbo_params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB NOTIFICATION PBO: ${comment}

CHECK VNEXT EVENT HUB NOTIFICATION BOOTSTRAP
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the Bootstrap.
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Notification Bootstrap    AZURE EVENT HUB
    ${event_hub_bootstrap_params} =    Create Dictionary    MessageType=ServiceActivationBOOTSTRAP    Message=BOOTSTRAP has been activated    Status=Activated
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    ServiceManagement    ServiceActivationBOOTSTRAP    ${event_hub_timeout}    ${event_hub_bootstrap_params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB NOTIFICATION BOOTSTRAP: ${comment}

CHECK VNEXT EVENT HUB NOTIFICATION ANTIFLOODING
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the CGWViolation_antiflooding.
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Notification CGWViolation_antiflooding    AZURE EVENT HUB
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    CGWHSViolationsNotification    ${event_hub_timeout}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB NOTIFICATION ANTIFLOODING: ${comment}

CHECK VNEXT EVENT HUB IVC BOOTSTRAP STATUS
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the Bootstrap for IVC.
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Notification Bootstrap    AZURE EVENT HUB
    ${event_hub_bootstrap_params} =    Create Dictionary    MessageType=AIVCBootstrapEndOK    NotificationType=Notification
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    AIVCBootstrapEndOK    ${event_hub_timeout}    ${event_hub_bootstrap_params}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB IVC BOOTSTRAP STATUS: ${comment}

CHECK VNEXT EVENT HUB NOTIFICATION BATTERY SOC
    [Arguments]    ${battery_state}    ${trigger}    ${no_notif}=${False}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the TWT battery state sent by the IVC.
    ...    == Parameters: ==
    ...    _battery_state_: battery soc value
    ...    _trigger_: Trigger to be validated
    ...    _no_notif_: Used for negative test cases, when you check that no notification has been published
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Position Tracking    AZURE EVENT HUB
    ${battery_data} =    Create Dictionary     BatteryState=${battery_state}     Trigger=${trigger}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    TWTNotificationBattery    ${event_hub_timeout}    ${battery_data}
    Run Keyword If    ${no_notif} == ${False}
    ...    Should Be True    ${verdict}    Failed inside CHECK VNEXT EVENT HUB NOTIFICATION BATTERY SOC Failed to receive Vnext Notification: ${comment}
    ...    ELSE    Should Not Be True    ${verdict}    Failed inside CHECK VNEXT EVENT HUB NOTIFICATION BATTERY SOC You receive Vnext Notification: ${comment}

CHECK EVENT HUB TRIP DATA NOTIFICATION
    [Arguments]    ${trip_data}    ${no_notif}=${False}    ${check_response}=${None}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the TWT trip data sent by the IVC.
    ...    == Parameters: ==
    ...    _trip_data_: data  to be verified inside eventhub notification
    ...    _no_notif_: Used for negative test cases, when you check that no notification has been published
    ...    _check_response_: list of dynamic key params to be verified inside eventhub response
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Position Tracking    AZURE EVENT HUB
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    TWTNotificationStatusVehicle   ${event_hub_timeout}    ${trip_data}    ${check_response}
    Set Test Variable    ${response}    ${response_dict}
    Run Keyword If    ${no_notif} == ${False}
    ...    Should Be True    ${verdict}    Failed inside CHECK EVENT HUB TRIP DATA NOTIFICATION Failed to receive Vnext Notification: ${comment}
    ...    ELSE    Should Not Be True    ${verdict}    Failed inside CHECK EVENT HUB TRIP DATA NOTIFICATION You receive Vnext Notification: ${comment}

CHECK EVENT HUB FAM NOTIFICATION
    [Arguments]    ${fam_service_type}    ${fam_data_set}    ${return_response}=${None}    ${event_hub_timeout}=300    ${no_notif}=${False}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the fleet data sent by the IVC.
    ...    == Parameters: ==
    ...    _fam_service_type_: The name of the FAM service
    ...    _fam_data_set_: The data that will be checked in notification
    ...    _return_response_: The response of the notification
    ...    _event_hub_timeout_: The timeout of the event hub
    ...    _no_notif_: Used for negative test cases, when you check that no notification has been published
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    FAM    AZURE EVENT HUB
    ${message_type} =    Set Variable If
    ...    "${fam_service_type}".lower() == "ftrm"    FTRMBasicNotification
    ...    "${fam_service_type}".lower() == "cflb"    BasicFleetNotification
    ...    "${fam_service_type}".lower() == "cftl"    FTRMMediumNotification
    ...    "${fam_service_type}".lower() == "cfta"    FTRMAdvancedNotification
    Run Keyword if    "${console_logs}" == "yes"      Log To Console     ${message_type}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    ${message_type}    ${event_hub_timeout}    ${fam_data_set}    ${return_response}
    Set Test Variable    ${response}    ${response_dict}
    Run Keyword If    ${no_notif} == ${False}
    ...    Should Be True    ${verdict}    Failed inside CHECK EVENT HUB FLEET DATA NOTIFICATION Failed to receive Vnext Notification: ${comment}
    ...    ELSE    Should Not Be True    ${verdict}    Failed inside CHECK EVENT HUB FLEET DATA NOTIFICATION You receive Vnext Notification: ${comment}

CHECK EVENT HUB FAM NOTIFICATION RETURN VALUE
    [Arguments]    ${response}    ${key}    ${value}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub event response has the desired value
    ...    == Parameters: ==
    ...    _response_: The response dictionary from event hub
    ...    _key_: The key that will be checked from the response dictionary
    ...    _value_: The value that should be checked for the given key
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if the key:value pair match the one from the response dict
    [Tags]    Automated    FAM    AZURE EVENT HUB
    ${response_value} =    Get From Dictionary    ${response}    ${key}
    ${result} =    Convert to Integer    ${response_value}
    Should Be True    ${result}==${value}    Value is different than expected ${result} instead of ${value}

CHECK VNEXT AND KMR LOCATION
    [Documentation]        == High Level Description: ==
    ...     Check and compare latitude, longitude, validity and timetamp from VNEXT and KMR.
    ...    output: passed/failed
    ...    PASS if executed
    ${location_data_vnext} =    SEND VNEXT REQUEST MYCARFINDER    LastknownPositionFromVnext
    ${location_data_vnext} =    Fetch From Right    ${location_data_vnext}    received:
    ${location_data_vnext} =    Fetch From Left    ${location_data_vnext}    )
    ${location_data_vnext_json} =    Evaluate     json.loads("""${location_data_vnext}""")    json
    ${vnext_response_data}=    Set Variable     ${location_data_vnext_json['Payload']['Result']}
    FOR    ${member}    IN     @{vnext_response_data}
        ${field}=    Get From Dictionary   ${member}     field
        IF   '${field}' == 'LocationLatitude'
            ${value}=    Get From Dictionary   ${member}     value
            ${timestamp}=    Get From Dictionary   ${member}     timestamp
            ${latitude_vnext} =    Set Variable    ${value}
            ${timestamp_vnext} =    Set Variable    ${timestamp}
        ELSE IF    '${field}' == 'LocationLongitude'
            ${value}=    Get From Dictionary   ${member}     value
            ${longitude_vnext} =    Set Variable    ${value}
            Run Keyword if    "${console_logs}" == "yes"     Log to Console    ${longitude_vnext}
        END
    END
    ${location_data_kmr} =    SEND KMR REQUEST MYCARFINDER GET LAST KNOWN LOCATION
    ${location_data_kmr} =    Fetch From Right    ${location_data_kmr}    received:
    ${location_data_kmr_json} =    Evaluate    json.loads("""${location_data_kmr}""")    json
    ${latitude_kmr} =    Set Variable    ${location_data_kmr_json['data']['attributes']['gpsLatitude']}
    ${longitude_kmr} =    Set Variable    ${location_data_kmr_json['data']['attributes']['gpsLongitude']}
    ${timestamp_kmr} =    Set Variable    ${location_data_kmr_json['data']['attributes']['lastUpdateTime']}
    Should Be Equal As Numbers     ${longitude_vnext}     ${longitude_kmr}     precision=-1
    Should Be Equal As Numbers     ${latitude_vnext}     ${latitude_kmr}     precision=-1
    Should Be Equal    ${timestamp_vnext}    ${timestamp_kmr}
    [Return]    ${timestamp_kmr}

CHECK RESPONSE DATA
    [Arguments]    ${dict_validate}
    [Documentation]        == High Level Description: ==
    ...     Validate the dynamic location data in the response dict retrieved from eventhub notification
    ...    == Parameters: ==
    ...    _status_: success/failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    FAM    AZURE EVENT HUB
    Run Keyword if    "${console_logs}" == "yes"     Log to Console    ${response}
    ${count} =    Get length    ${dict_validate}
    FOR    ${i}    IN RANGE    ${count}
        ${key} =    Get From List   ${dict_validate}   ${i}
        ${value} =    Set Variable    ${response['${key}']}
        Run Keyword If    "${value}" == "${EMPTY}" or "${value}" != 0 or "${value}" != "${None}"    Log to Console  ${key} : ${value}
        ...    ELSE    Fail    log to console  ${key} : ${value}
    END

GET TRIGGER_PROFILE
    [Arguments]    ${trigger_profile}
    [Documentation]        == High Level Description: ==
    ...     Prepare the dict to be verified in EventHub notification
    ...    == Parameters: ==
    ...    _status_: success/failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    FAM    AZURE EVENT HUB
    ${resp_attr}=    Create Dictionary
    FOR    ${item}    IN    @{FAM_TRIGGER["${trigger_profile}"].keys()}
        Set To Dictionary    ${resp_attr}    ${item}    ${FAM_TRIGGER["${trigger_profile}"]["${item}"]}
    END
    [Return]    ${resp_attr}

CHECK OCTO TIMESTAMP
    [Arguments]    ${tstart}    ${max_diff}
    [Documentation]        == High Level Description: ==
    ...     Check for Event Hub published notification timestamp as a result of the fleet data sent by the IVC with specified limits.
    ...    == Parameters: ==
    ...    _status_: success/failed
    ${trigger_time} =    Set Variable    ${response['TimeStamp']}
    ${time_diff} =    robot.libraries.DateTime.Subtract Date from Date    ${trigger_time}    ${tstart}
    Run Keyword if    "${console_logs}" == "yes"     Log to Console    TIME DIFFERENCE IS ${time_diff}
    ${result} =    Evaluate    ${time_diff} < ${max_diff}
    Should Be True    ${result}    Expected timestamp is not received

CHECK EVENT HUB TRIP CONTEXT NOTIFICATION
    [Arguments]    ${context_data}    ${no_notif}=${False}    ${check_response}=${None}
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the TWT trip data sent by the IVC.
    ...    == Parameters: ==
    ...    _status_: success/failed
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Position Tracking    AZURE EVENT HUB
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Alert    TWTNotificationContext    ${event_hub_timeout}    ${context_data}    ${check_response}
    Set Test Variable    ${response}    ${response_dict}
    Run Keyword If    ${no_notif} == ${False}
    ...    Should Be True    ${verdict}    Failed inside CHECK EVENT HUB TRIP DATA NOTIFICATION Failed to receive Vnext Notification: ${comment}
    ...    ELSE    Should Not Be True    ${verdict}    Failed inside CHECK EVENT HUB TRIP DATA NOTIFICATION You receive Vnext Notification: ${comment}

CHECK VNEXT PING STATUS
    [Documentation]        == High Level Description: ==
    ...    Check vnext ping status with redash tool
    Log    Keyword not mandatory since action is done manually for now

CHECK VNEXT PLUG ANG CHARGE PROHIBITION STATUS
    [Arguments]    ${expected_status}    ${charge_status_expected}   ${battery_level_expected}    ${charge_Prohibition_byRental_value}    ${charge_plug_expected_status}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP answer from a request. Check that {charging_status_expected_value} {battery_energy_level_expected_value}
    ...    {charge_plug_expected_status} {charge_remaining_time} have the expected values and the timestamp for the
    ...    response is close to the expected {time_stamp} +/- 10 seconds.
    ...    == Parameters: ==
    ...    _expected_status_: success, fail
	...    _charge_status_expected: 0, 1, 2
	...    _battery_level_expected_: Battery level expected
    ...    _charge_plug_expected_status_: 0, 1, 2
    ...    _charge_prohibition_by_rental_: 0, 1, 2
    ...    == Expected Results: ==
    ...    PASS if all the parameters have values as expected;
    [Tags]    Automated    Remote Charging Status    VNEXT APIM
    ${args} =    Create List    VehicleDataStatus    VehicleData
    ${charge_status_expectedint} =  Convert To Integer    ${charge_status_expected}
    ${resp_attr_charge_status} =    Create Dictionary    RepositoryLabel=ChargeStatus    Value=${charge_status_expectedint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_status}
    Should Be True    ${verdict}    Failed to get VNext CHARGE STATUS
    ${battery_level_expectedint} =  Convert To Integer    ${battery_level_expected}
    ${resp_attr_battery_level} =    Create Dictionary    RepositoryLabel=EVHVBatteryEnergyLevel    Value=${battery_level_expectedint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_battery_level}
    Should Be True    ${verdict}    Failed to get VNext REMOTE BATTERY LEVEL
    ${charge_Prohibition_byRental_valueint} =  Convert To Integer    ${charge_Prohibition_byRental_value}
    ${resp_attr_charge_Prohibition_byRental} =    Create Dictionary    RepositoryLabel=ChargeProhibitionByRental    Value=${charge_Prohibition_byRental_valueint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_Prohibition_byRental}
    Should Be True    ${verdict}    Failed to get VNext CHARGE PROBIBITION BY RENTAL
    ${charge_plug_expected_statusint} =  Convert To Integer    ${charge_plug_expected_status}
    ${resp_attr_charge_plug} =    Create Dictionary    RepositoryLabel=EVChargePlugConnected    Value=${charge_plug_expected_statusint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_plug}
    Should Be True    ${verdict}    Failed to get VNext REMOTE CHARGE PLUG STATUS

RETRIEVE VNEXT USER
    [Documentation]    == High Level Description: ==
    ...    Send to Vnext a request to retrieve user for a specific VIN
    [Tags]    Automated    RETRIEVE VNEXT USER    VNEXT APIM
    ${user_id}=    Set Variable    None
    ${request_attr} =    Create Dictionary    PageNumber=${1}    PageSize=${50}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    GetVnextUserID    UserID    ${request_attr}
    Should Be True    ${verdict}    Failed to send RETRIEVE VNEXT USER
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM RESPONSE    GetVnextUserID    UserID    Success    ${empty_dict}
    Should Be True    ${verdict}    Failed to GET RETRIEVE VNEXT USER response
    IF    'Payload' in $response
        Run Keyword If    'CommandId' in ${response['Payload']}    Set Test Variable    ${Apim_CommandId}    ${response['Payload']['CommandId']}
    END
    ${length} =    Get Length    ${response['Payload']['Result']['Links']}
    FOR    ${i}    IN RANGE    0    ${length}
    ${role} =    Set Variable    ${response['Payload']['Result']['Links'][${i}]['Role']}
    Run Keyword If    "${role}" == "Primary"   Set Global Variable    ${user_id}    ${response['Payload']['Result']['Links'][${i}]['UserID']}
    EXIT FOR LOOP IF  "${user_id}" != "${None}"
    END
    Run Keyword if  "${user_id}" == "${None}"   Fail    Primary UserID not found in response ${response} sincro your vehicle

CHECK KUSTO LOGS NOT FOUND FOR
    [Arguments]    ${service}
    [Documentation]    == High Level Description: ==
    ...    No Kusto logs found when trying to retrieve the value with service deactivated or in privacy mode
    ...    == Parameters: ==
    ...    - _service_: represents the type of the service. It can be: BUMI, CDUI
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${comment} =    RETRIEVE THE KUSTO LOGS    ${service}    ${vnext_vehicle_id}    ${tstart}    ${tstop}
    Should Not Be True    ${verdict}    Failed while getting results: Found some kusto logs in negative case
    Should Be Equal    "No logs found for kusto query"    "${comment}"

CHECK OFFBOARD HVAC SYNCHECKCHRONIZATION TIME
    ${ts_time} =    Set Variable    ${response.get("TimeStamp")}
    ${convert_time_and_date} =    robot.libraries.DateTime.Convert Date    ${tstart}    result_format=%Y-%m-%dT%H:%M:%SZ     exclude_millis=True
    ${time_diff} =    robot.libraries.DateTime.Subtract Date from Date    ${convert_time_and_date}    ${ts_time}
    ${result} =    Evaluate    ${time_diff} < 120
    Should Be True    ${result}    Synchronization time is taken more than 120 Seconds

FETCH VNEXT MCAF LOCATION DATA
    [Documentation]        == High Level Description: ==
    ...    Fetch latitude, longitude, validity and timetamp from VNEXT.
    ...    output: passed/failed
    ...    PASS if executed
    ${location_data_vnext} =    SEND VNEXT REQUEST MYCARFINDER    LastknownPositionFromVnext
    ${location_data_vnext} =    Fetch From Right    ${location_data_vnext}    received:
    ${location_data_vnext} =    Fetch From Left    ${location_data_vnext}    )
    ${location_data_vnext_json} =    Evaluate     json.loads("""${location_data_vnext}""")    json
    ${latitude_vnext} =    Set Variable    ${location_data_vnext_json['Payload']['Result'][0]['value']}
    ${longitude_vnext} =    Set Variable    ${location_data_vnext_json['Payload']['Result'][1]['value']}
    ${timestap_vnext} =    Set Variable    ${location_data_vnext_json['Payload']['Result'][1]['timestamp']}
    ${validity_vnext} =    Set Variable    ${location_data_vnext_json['Payload']['Result'][3]['value']}
    [Return]    ${timestap_vnext}

SEND VNEXT RESET BOOTSTRAP STATUS REQUEST
    [Documentation]    == High Level Description: ==
    ...    Send a request to reset the BOOTSTRAP status.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    output: Pass if BOOTSTRAP status is ACTIVATED
    ${args} =    Create List    BOOTSTRAP    BOOTSTRAPReset
    ${param} =    Create Dictionary       ExcludeBOOTSTRAP=${false}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST   @{args}   ${param}
    Should Be True    ${verdict}   Failed to SEND VNEXT APIM REQUEST for resetting BOOTSTRAP

SEND VNEXT SMCH REQUEST
    [Documentation]    == High Level Description: ==
    ...    Send an API to Vnext to retrieve the smch data set.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    PASS if Executed
    [Tags]    Automated    SMCH    VNEXT APIM
    ${charging_args} =    Create Dictionary    Type=LastKnown    ServiceId=SMCH    DatasetName=SMCH_ALLDATA
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    VehicleDataStatus    VehicleData    ${charging_args}
    Should Be True    ${verdict}    Failed to send VNext SMCH REQUEST: ${comment}

CHECK VNEXT SMCH STATUS
    [Arguments]    ${expected_status}    ${charge_status_expected}   ${battery_level_expected}    ${ev_Charge_Remaining_Time}    ${charge_plug_expected_status}    ${ev_Available_Energy}    ${ev_ZEV_Autonomy_Display}    ${ev_Charge_Instantaneous_Power}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP answer from a request. Check that {charging_status_expected_value} {battery_energy_level_expected_value}
    ...    {charge_plug_expected_status} {charge_remaining_time} have the expected values and the timestamp for the
    ...    response is close to the expected {time_stamp} +/- 10 seconds.
    ...    == Parameters: ==
    ...    _expected_status_: success, fail
    ...    _charge_status_expected_: 0, 1, 2
	...    _battery_level_expected_: Battery level expected
	...    _ev_Charge_Remaining_Time_: 10,20
    ...    _charge_plug_expected_status_: 0, 1, 2
    ...    _ev_Available_Energy_: 10,20
    ...    _ev_ZEV_Autonomy_Display_: (ex:140,150)
    ...    _ev_Charge_Instantaneous_Power_: 70,80
    ...    == Expected Results: ==
    ...    PASS if all the parameters have values as expected;
    [Tags]    Automated    Smch    VNEXT APIM
    ${args} =    Create List    VehicleDataStatus    VehicleData
    ${charge_status_expectedint} =  Convert To Integer    ${charge_status_expected}
    ${resp_attr_charge_status} =    Create Dictionary    RepositoryLabel=ChargeStatus    Value=${charge_status_expectedint}   Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_status}
    Should Be True    ${verdict}    Failed to get VNext CHARGE STATUS
    ${battery_level_expectedint} =  Convert To Integer    ${battery_level_expected}
    ${resp_attr_battery_level} =    Create Dictionary    RepositoryLabel=EVHVBatteryEnergyLevel    Value=${battery_level_expectedint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_battery_level}
    Should Be True    ${verdict}    Failed to get VNext REMOTE BATTERY LEVEL
    ${ev_Charge_Remaining_Timeint} =  Convert To Integer    ${ev_Charge_Remaining_Time}
    ${resp_evChargeRemainingTime} =    Create Dictionary    RepositoryLabel=EVChargeRemainingTime    Value=${ev_Charge_Remaining_Timeint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_evChargeRemainingTime}
    Should Be True    ${verdict}    Failed to get VNext EV CHARGE REMAINING TIME
    ${charge_plug_expected_statusint} =  Convert To Integer    ${charge_plug_expected_status}
    ${resp_attr_charge_plug} =    Create Dictionary    RepositoryLabel=EVChargePlugConnected    Value=${charge_plug_expected_statusint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE    @{args}    ${expected_status}    ${resp_attr_charge_plug}
    Should Be True    ${verdict}    Failed to get VNext REMOTE CHARGE PLUG STATUS
    ${ev_Available_Energyint} =  Convert To Integer    ${ev_Available_Energy}
    ${resp_ev_Available_Energy} =    Create Dictionary    RepositoryLabel=EV_AvailableEnergy    Value=${ev_Available_Energyint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE   @{args}    ${expected_status}    ${resp_ev_Available_Energy}
    Should Be True    ${verdict}    Failed to get VNext EV AVAILABLE ENERGY
    ${ev_ZEV_Autonomy_Displayint} =  Convert To Integer    ${ev_ZEV_Autonomy_Display}
    ${resp_ev_ZEV_Autonomy_Display} =    Create Dictionary    RepositoryLabel=ZEVAutonomyDisplay    Value=${ev_ZEV_Autonomy_Displayint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE   @{args}    ${expected_status}    ${resp_ev_ZEV_Autonomy_Display}
    Should Be True    ${verdict}    Failed to get VNext EV ZEV Autonomy Display
    ${ev_Charge_Instantaneous_Powerint} =  Convert To Integer    ${ev_Charge_Instantaneous_Power}
    ${resp_ev_Charge_Instantaneous_Power} =    Create Dictionary    RepositoryLabel=ChargeInstantaneousPower    Value=${ev_Charge_Instantaneous_Powerint}    Timestamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK VNEXT APIM VEHICLE DATA RESPONSE   @{args}    ${expected_status}    ${resp_ev_Charge_Instantaneous_Power}
    Should Be True    ${verdict}    Failed to get VNext EV Charge Instantaneous Power

GET DATA IN KUSTO
    [Arguments]    ${trigger_type}    ${kusto_label}
    [Documentation]    == High Level Description: ==
    ...    Check if data uploaded to VNext matches with dat published
    ...    == Parameters: ==
    ...    - _trigger_type_: represents the type of the trigger.
    ...    - _kusto_label_: represents the kusto label whose data needs to be verified
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${response} =    GET DATA IN KUSTO FOR    ${trigger_type}    ${kusto_label}
    [Return]    ${response}

CHECK MCAF VALID LOCATION AND TIME
    [Documentation]    Check latitude, longitude, validity and  compare the MCAF time with Tstart and Tstop
    ${vnext_timestamp} =    FETCH VNEXT MCAF LOCATION DATA
    ${vnext_timestamp} =    robot.libraries.DateTime.Convert Date    ${vnext_timestamp}    result_format=%Y-%m-%d %H:%M:%S     exclude_millis=yes
    Log To Console    T_start:${tstart} vnext_time_stamp:${vnext_timestamp} T_stop:${tstop}
    ${verdict} =    Evaluate    '''${tstart}''' < '''${vnext_timestamp}''' < '''${tstop}'''
    Should Be True    ${verdict}   Time and date should match with the time of the request

START EVENT HUB CAPTURE
    ${verdict} =    START AZURE SERVICE BUS
    SHOULD BE TRUE    ${verdict}

STOP EVENT HUB CAPTURE
    ${verdict} =    STOP AZURE SERVICE BUS
    SHOULD BE TRUE    ${verdict}

CHECKSET SERVICE INITIATE STATUS
    [Arguments]    ${service}
    [Documentation]    If service is already activated, send first a "Deinitiate" command, check technical product is deactivated in vNext, then send "Initiate" command.
    RECORD VNEXT DATE & TIME    tstart
    ${current_status}    ${comment} =    CHECK VNEXT SERVICE ACTIVATION STATUS    ${service}    Activated    True
    IF   "${current_status}" == "True"
        SEND VNEXT REQUEST SERVICE ACTIVATION    Deinitiate    ${service}
        Sleep    5
        CHECK VNEXT NOTIFICATION SERVICE ACTIVATION    ${service}    Deactivated
        SEND VNEXT REQUEST SERVICE ACTIVATION    Initiate    ${service}
    ELSE
        SEND VNEXT REQUEST SERVICE ACTIVATION    Initiate    ${service}
    END

CHECK VNEXT PRIVACY MODE NOTIFICATION
    [Arguments]    ${status}
    [Documentation]    Check in the Vnext event hub that notification is published related to privacy mode
    IF    "${status}" == "privacy_mode_status_enabled"
        ${cmd_result} =    Set Variable    0
    ELSE
        IF    "${status}" == "privacy_mode_status_disabled"
            ${cmd_result} =    Set Variable    1
        ELSE
            Fail    Please enter valid value for privacy mode notification: ${status}
        END
    END
    ${privacy_mode_notification} =    Create Dictionary    MultimediaPrivacyModeState=${cmd_result}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    PrivacyModeNotification    ${60}    ${privacy_mode_notification}
    Should Be True    ${verdict}    Fail to CHECK VNEXT NOTIFICATION PRIVACY MODE: ${comment}

CHECK EVENT HUB FACTORY RESET NOTIFICATION
    [Documentation]    == High Level Description: ==
    ...    Check Vnext publish a notification and check the content.
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    VNEXT EVENTHUB
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    UAMIVIFactoryReset   ${event_hub_timeout}
    Should Be True    ${verdict}    Failed to receive EVENT HUB FACTORY RESET NOTIFICATION: ${comment}

CHECKSET VNEXT SERVICE ACTIVATION STATUS CDU ALL PACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if CDU all pack services are activated/deactivated. When the service activation status
    ...    is not as expected, activates or deactivates it.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated
    @{list_of_services} =    Create List
    Append To List    ${list_of_services}    Energy_management_ccs2    Lighting_ccs2    Stop_and_start_ccs2
    ...    Dea_m_ccs2    Cassiope_ccs2    Electric_vehicle_ccs2    Hmi_ccs2    Seats_ccs2    Steering_ccs2
    ...    Mirror_wiping_washing_ccs2    Micro_hyb_ccs2
    FOR    ${item}    IN    @{list_of_services}
        CHECKSET VNEXT SERVICE ACTIVATION STATUS FOR    ${item}    ${status}    25m
    END

CHECK VNEXT NOTIFICATION SERVICE ACTIVATION CDU ALL PACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if vNext sends a notification with success status of a service activation request for CDU all pack.
    ...    == Parameters: ==
    ...    - _status_: ActivationInProgress, DeactivationInProgress, Activation Failed, Deactivation Failed, Activated, Deactivated
    @{list_of_services} =    Create List
    Append To List    ${list_of_services}    Energy_management_ccs2    Lighting_ccs2    Stop_and_start_ccs2
    ...    Dea_m_ccs2    Cassiope_ccs2    Electric_vehicle_ccs2    Hmi_ccs2    Seats_ccs2    Steering_ccs2
    ...    Mirror_wiping_washing_ccs2    Micro_hyb_ccs2
    FOR    ${item}    IN    @{list_of_services}
        CHECK VNEXT NOTIFICATION SERVICE ACTIVATION    ${item}    ${status}    25m
    END

CHECK REDBEND FOTA CAMPAIGN CDU ALL PACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check a redbend fota campaign status & profil name for CDU all pack
    ...    == Parameters: ==
    ...    - _status_: Pending, Success, Running, Fail
    @{list_of_services} =    Create List
    Append To List    ${list_of_services}    DActivation_Energy_management_ccs2    DActivation_Lighting_ccs2
    ...    DActivation_Stop_and_start_ccs2    DActivation_Dea_m_ccs2    DActivation_Cassiope_ccs2    DActivation_Electric_vehicle_ccs2
    ...    DActivation_Hmi_ccs2    DActivation_Seats_ccs2    DActivation_Steering_ccs2
    ...    DActivation_Mirror_wiping_washing_ccs2    DActivation_Micro_hyb_ccs22
    FOR    ${item}    IN    @{list_of_services}
        CHECK REDBEND FOTA CAMPAIGN    ${status}    ${item}
    END

SEND VNEXT REMOTE DIAGNOSTIC ON DEMAND REQUEST
    [Arguments]    ${redi_req}
    [Documentation]    Send remote diagnostic on demand
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    SEND VNEXT REMOTE DIAGNOSTIC ON DEMAND REQUEST
    ${cmd_result} =    Set Variable If    "${redi_req}" == "remote_diagnostic"    REDI
    ${redi_params} =    Create Dictionary    Dataset=${0}   VehicleMode=${1}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    RemoteDiagnosticOnDemand    ${cmd_result}    ${redi_params}
    Should Be True    ${verdict}    Failed to SEND VNEXT REMOTE DIAGNOSTIC ON DEMAND REQUEST due to: ${comment}

CHECK VNEXT REMOTE DIAGNOSTIC NOTIFICATION
    [Arguments]    ${message_type}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if VNEXT publishes a notification regarding the Remote Diagnostics Request.
    ...    == Parameters: ==
    ...    - _notification_type_: represents the type of the message.
    ...    - _status_: success/failed
    ...    output: passed/failed
    [Tags]    Automated    Remote Diagnostic Notification    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT REMOTE DIAGNOSTIC NOTIFICATION
    ${redi_result} =    Set Variable if    "${status}".lower() == "success"    ${0}    TIMEOUT
    ${redi_dict} =    Create Dictionary    Status=${redi_result}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    ${message_type}    ${event_hub_timeout}    ${redi_dict}
    Should Be True    ${verdict}    ${comment}

RETRIEVE MCAF LOCATION DATA
    [Documentation]    == High Level Description: ==
    ...    Send an API to Vnext to retrieve the mcaf location data.
    ...    == Parameters: ==
    ...    _None_
    ...    == Expected Results: ==
    ...    PASS if Executed
    ${location_args} =    Create Dictionary    Type=LastKnown    ServiceId=MCAF    DatasetName=ALLFIELDS
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    VehicleDataStatus    VehicleData    ${location_args}
    Should Be True    ${verdict}    Failed to send mcaf vnext location data : ${comment}
    ${location_data_vnext} =    Fetch From Right    ${comment}    received:
    ${location_data_vnext} =    Fetch From Left    ${location_data_vnext}    )
    ${location_data_vnext_json} =    Evaluate     json.loads("""${location_data_vnext}""")    json
    ${vnext_response_data}=    Set Variable     ${location_data_vnext_json['Payload']['Result']['${vehicle_id}']['Data']}
    FOR    ${member}    IN     @{vnext_response_data}
        ${field}=    Get From Dictionary   ${member}     RepositoryLabel
        IF   '${field}' == 'LatitudeAtEndOfJourney'
            ${value}=    Get From Dictionary   ${member}     Value
            ${latitude_vnext} =    Set Variable    ${value}
        ELSE IF    '${field}' == 'LongitudeAtEndOfJourney'
            ${value}=    Get From Dictionary   ${member}     Value
            ${longitude_vnext} =    Set Variable    ${value}
            ${timestamp} =    Get From Dictionary   ${member}     Timestamp
            ${timestamp_vnext} =    Set Variable    ${timestamp}
        END
    END
    [Return]    ${timestamp_vnext}

CHECK VNEXT EVENT HUB NOTIFICATION IVCVIOLATION
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the IVCVIOLATION.
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    Notification    IVCVIOLATION    AZURE EVENT HUB
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification    IVC2SOCsecuritylog    ${event_hub_timeout}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB NOTIFICATION IVCVIOLATION: ${comment}

CHECK CAR DATA PLATFORM
    [Documentation]    == High Level Description: ==
    ...    Check the emulated signals on Car Data Platform
    [Arguments]    ${service}    ${table}
    Run Keyword If    "${tstart}" == "None"    Fail    Please record the timestamp of your simulation
    ${data} =    Run Keyword If    ${CDP_Notification['${service}']['params']}==${None}    Fail    Data params are mandatory
    ...    ELSE    Set To Dictionary    ${CDP_Notification['${service}']['params']}
    ${verdict}    ${comment}    ${response} =    CIRRUS GET CDP MESSAGE    ${table}    ${tstart}    ${tstop}    ${data}
    Should Be True    ${verdict}    CIRRUS - Fail to retrieve CDP Messages : ${comment}
    Log    ${\n}CDP MESSAGE: ${response}${\n}    level=INFO    console=True

CHECK CAR DATA PLATFORM FOR SERVICES
    [Documentation]    == High Level Description: ==
    ...    Check the emulated signals on Car Data Platform
    [Arguments]    ${profile}
    IF    "${profile}" == "dabr_single_trigger_data"
        FOR   ${i}    IN RANGE    1    9
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_single_trigger_cdp_${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_data_periodic_trigger"
        FOR   ${i}    IN RANGE    1    23
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_data_periodic_trigger_cdp_${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "eva_001_single_trigger_data"
        FOR   ${i}    IN RANGE    1    97
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    eva_cdp_${i}    eva.bsha_uid323
        END
    ELSE IF    "${profile}" == "eva_002_single_trigger_data"
        FOR   ${i}    IN RANGE    1    53
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    eva_02_cdp_${i}    eva.bsha_uid323
        END
    ELSE IF    "${profile}" == "eva_003_single_trigger_data"
        FOR   ${i}    IN RANGE    1    14
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    eva_03_cdp_${i}   eva.bsha_uid323
        END
    ELSE IF    "${profile}" == "eva_periodic_trigger_data"
        FOR   ${i}    IN RANGE    1    45
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    eva_04_cdp_${i}   eva.bsha_uid323
        END
    ELSE IF    "${profile}" == "eva_context_trigger_data"
        FOR   ${i}    IN RANGE    1    7
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    eva_05_cdp_${i}   eva.bsha_uid323
        END
    ELSE IF    "${profile}" == "phyd_data"
        FOR   ${i}    IN RANGE    1    10
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    phyd_data_cdp_${i}   usage_based_insurance.phyd_uid857
        END
    ELSE IF    "${profile}" == "ubam_data_single_trigger"
        FOR   ${i}    IN RANGE    1    12
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    ubam_data_single_trigger_cdp_${i}   usage_based_maintenance.ubam_uid499
        END
    ELSE IF    "${profile}" == "ubam_periodic_trigger_data"
        FOR   ${i}    IN RANGE    1    22
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    ubam_periodic_trigger_cdp_data_${i}   usage_based_maintenance.ubam_uid499
        END
    ELSE IF    "${profile}" == "coma_001_trigger"
        FOR   ${i}    IN RANGE    1    42
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    coma_01_cdp_${i}   connected_maintenance.coma_uid820
        END
    ELSE IF    "${profile}" == "dabr_periodic_trigger_120_data"
        FOR   ${i}    IN RANGE    1    10
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_periodic_trigger_120_cdp_data_${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_periodic_300_DuringCharge_trigger"
        FOR   ${i}    IN RANGE    1    3
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_periodic_300_DuringCharge_trigger_${i}   car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_Trg_StartOfJourney_data"
        FOR   ${i}    IN RANGE    1    21
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_Trg_StartOfJourney_data${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_change_outside_lock_state_no_privacy_data"
        FOR   ${i}    IN RANGE    1    6
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_change_outside_lock_state_no_privacy_data${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_periodic_trigger_15_data"
        FOR   ${i}    IN RANGE    1    11
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_periodic_trigger_15_cdp_data_${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_Trg_EndOfJourney_data"
        FOR   ${i}    IN RANGE    1    22
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_Trg_EndOfJourney_data${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE IF    "${profile}" == "dabr_ctx_without_permit_data"
        FOR   ${i}    IN RANGE    1    5
            Run Keyword And Continue On Failure    CHECK CAR DATA PLATFORM    dabr_ctx_without_permit_data_${i}    car_data_backup.826_data_brokering_v1
        END
    ELSE
        Fail    Not yet implemented for this TC
    END

CHECKSET VNEXT SERVICE ACTIVATION STATUS COMMERCIAL SERVICES
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if commercial services are activated/deactivated. When the service activation status
    ...    is not as expected, activates or deactivates it.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated
    @{list_of_services} =    Create List
    Append To List    ${list_of_services}    mycarfinder    rlu    rhl    rvsc    remote_charging_start_and_stop    Remote_HVAC_scheduling
    ...    remote_rchs    ntcs    remote_hvac_on_and_off    ehorizon
    FOR    ${item}    IN    @{list_of_services}
        CHECKSET VNEXT SERVICE ACTIVATION STATUS FOR    ${item}    ${status}
    END

CHECK VNEXT SERVICE ACTIVATION STATUS COMMERCIAL SERVICES
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if VNEXT commercial services are activated/deactivated.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated

    @{list_of_services} =    Create List    mycarfinder    rlu    rvls    rhl    rvsc    remote_charging_start_and_stop    remote_hvac_scheduling
    ...    remote_rchs    ntcs    remote_hvac_on_and_off    ehorizon

    FOR    ${item}    IN    @{list_of_services}
        CHECK VNEXT SERVICE ACTIVATION STATUS    ${item}    ${status}
    END

CHECK VNEXT SERVICE ACTIVATION STATUS FIRST PRIORITY TECHNICAL SERVICES
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if VNEXT first priority technical services are activated/deactivated.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated

    @{list_of_services} =    Create List    mqttao/drx

    IF    "${ivi_my_feature_id}" == "MyF3" and "${bench_type}" == "${sweet400_bench_type}"
        IF    '${ivi_bench_type}' in "'${setup_type}'" and '${ivc_bench_type}' in "'${setup_type}'"
            Append To List    ${list_of_services}    isa_ehorizon_ivc_ivi
        ELSE IF    '${ivc_bench_type}' in "'${setup_type}'"
            Append To List    ${list_of_services}    isa_ehorizon_ivc
        END
    END

    FOR    ${item}    IN    @{list_of_services}
        CHECK VNEXT SERVICE ACTIVATION STATUS    ${item}    ${status}
    END

CHECK VNEXT SERVICE ACTIVATION STATUS SECOND PRIORITY TECHNICAL SERVICES
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if VNEXT second priority technical services are activated/deactivated.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated

    @{list_of_services} =    Create List    ubm    lemon    coma    battery_usage_monitoring_for_internal_use    data_collection    bsha

    FOR    ${item}    IN    @{list_of_services}
        CHECK VNEXT SERVICE ACTIVATION STATUS    ${item}    ${status}
    END

CHECK DBB MESSAGE
    [Documentation]    == High Level Description: ==
    ...    Check the emulated signals on DBB Platform
    [Arguments]    ${service}
    ${timestamp} =    DateTime.Convert Date    ${tstart}    result_format=%Y-%m-%dT%H:%M:%SZ
    Run Keyword If    "${tstart}" == "None"    Fail    Please record the timestamp of your simulation
    ${data} =    Run Keyword If    ${DBB_Notification['${service}']['params']}==${None}    Fail    Data params are mandatory
    ...    ELSE    Set To Dictionary    ${DBB_Notification['${service}']['params']}
    Run Keyword If    "${service}" == "stive_001"    Set To Dictionary    ${data}    rdiagUploadId=${rdiagUploadId}
    ${topic} =    Set Variable    ${DBB_Notification}[${service}][topic]
    ${verdict}    ${comment}    ${response} =    CIRRUS GET DBB MESSAGE    ${topic}    ${event_id}    ${timestamp}    ${data}
    Should Be True    ${verdict}    CIRRUS - Fail to retrieve DBB Messages : ${comment}
    Log    ${\n}DBB MESSAGE: ${response}${\n}    level=INFO    console=True

CHECK DBB MESSAGE FOR SERVICES
    [Documentation]    == High Level Description: ==
    ...    Check the emulated signals on Car Data Platform
    [Arguments]    ${profile}
    IF    "${profile}" == "coma_001_trigger"
        FOR   ${i}    IN RANGE    1    4
            Run Keyword And Continue On Failure    CHECK DBB MESSAGE    coma_001_trigger_${i}
        END
    ELSE IF    "${profile}" == "payd_data"
        Run Keyword If    "${ivi_my_feature_id}" == "MyF3"    Run keyword And Continue On Failure    CHECK DBB MESSAGE    payd_data_myf3
        ...    ELSE    Run keyword And Continue On Failure    CHECK DBB MESSAGE    payd_data
    ELSE IF    "${profile}" == "stive_001"
        Run Keyword And Continue On Failure    CHECK DBB MESSAGE    stive_001
    END

SEND VNEXT REQUEST JWT CONFIG
    [Arguments]
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM to get VIN JWT config
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    [Tags]    Automated    VNEXT APIM
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    JWT    JWTConfig    {}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST JWT CONFIG: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST JWT CONFIG: ${comment}

SEND VNEXT REQUEST JWT RHL
    [Arguments]    ${action}    ${rhl_option}    ${rhl_option2}    ${rhl_option3}    ${jwt_token}=${NONE}    ${TC_folder}=${EMPTY}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RHL request with the parameter needed
    ...    (defined in AIA document for RHL)
    ...    == Parameters: ==
    ...    - _action_: start, Stop
    ...    - _RHL_Options_: list with the following options
    ...    - _RHL_Option_: HornLight, HornOnly, LightOnly
    ...    - _RHL_Option2_: Style1, Style2, Style3 (Optionnal)
    ...    - _RHL_Option3_:  15, 30, 45, 60, 75, 90 (Optionnal)
    ...    - _srp_proof_: Calculated SRP PROOF value if one is required (optional parameter)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    VNEXT APIM
    ${rhl_args} =    Create Dictionary    RHLAction=${action}    RHL_Option=${rhl_option}
    Run Keyword If    "${rhl_option2}"!="NA"    Set To Dictionary    ${rhl_args}    RHL_Option2    ${rhl_option2}
    Run Keyword If    "${rhl_option3}"!="NA"    Set To Dictionary    ${rhl_args}    RHL_Option3    ${{int($rhl_option3)}}
    Run Keyword If    "${jwt_token}"    Set To Dictionary    ${rhl_args}    JwtAuth=${jwt_token}
    ${verdict}    ${comment} =    SEND VNEXT APIM REQUEST    RemoteHornLightsCommand    RHL    ${rhl_args}
    Run Keyword If    "${TC_folder}"=="RELIABILITY"    Run keyword And Continue On Failure    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RHL: ${comment}
    ...    ELSE    Should Be True    ${verdict}    Fail to SEND VNEXT REQUEST RHL: ${comment}

CHECK VNEXT NOTIFICATION JWT RHL ACK
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if VNEXT publishes a notification regarding the Remote Horn&Light Request.
    ...    == Parameters: ==
    ...    - _status_: success/failed
    ...    output: passed/failed
    [Tags]    Automated    Remote Horn&Light Notification    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RHL ACK
    IF  "Success" in $status
        ${event_hub_rhl_params} =   Create Dictionary    RHLStatus=${0}
    ELSE
        ${event_hub_rhl_params} =   Create Dictionary    RHLStatus=${1}    RHLErrorCode=${{int($status.split("=")[1])}}
    END
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RHLCommandAcknowledgement    ${event_hub_timeout}    ${event_hub_rhl_params}
    Should Be True    ${verdict}    ${comment}

CHECK VNEXT NOTIFICATION JWT RLU ACK
    [Arguments]    ${operation_result}    ${lock_status}
    [Documentation]    == High Level Description: ==
    ...    Check if VNEXT publishes a notification regarding the Remote LockUnlock Request.
    ...    == Parameters: ==
    ...    - _status_: success/failed
    ...    output: passed/failed
    [Tags]    Automated    Remote Horn&Light Notification    VNEXT EVENTHUB
    Run Keyword if    "${console_logs}" == "yes"     Log To Console    CHECK VNEXT NOTIFICATION RLU ACK
    ${rlu_result} =   Create Dictionary
    ...    OperationResult=${{'Success' if $operation_result.lower() == 'success' else 'Failed'}}
    ...    StatusDoorOutsideLockedState=${{"0" if $lock_status.lower() == 'unlock' else "1"}}
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF
    ...    CommandResponse    RLUCommandResult    ${event_hub_timeout}    ${rlu_result}
    Should Be True    ${verdict}    ${comment}

CHECK REDBEND FOTA URGENT CAMPAIGN
    [Arguments]    ${status}    ${profil_name}
    [Documentation]    == High Level Description: ==
    ...    Check a redbend fota campaign status & profil name.
    ...    == Parameters: ==
    ...    - _status_: Pending, Success, Running, Fail
    ...    - _profil_name_: name of a campaign profile
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Manual    Service subscription management    REDBEND
    Log    CHECK REDBEND FOTA URGENT CAMPAIGN    WARN


CHECK VNEXT EVENT HUB NOTIFICATION IVI SECURITY LOGS
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the  IVISsecuritylog.
    ...    == Parameters: ==
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    [Tags]    Automated    AZURE EVENT HUB
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    Notification     SecurityLogNotification    ${event_hub_timeout}
    Should Be True    ${verdict}    Fail to CHECK VNEXT EVENT HUB IVI SECURITY LOG NOTIFICATION : ${comment}

CHECK VNEXT NOTIFICATION RHL STATUS
    # CHECK VNEXT NOTIFICATION JWT RHL ACK    Success
    @{rhl_ret} =    Create List    RHLStatus    RHLErrorCode
    ${verdict}    ${comment}    ${response_dict} =    CHECK VNEXT EVENT HUB NOTIF    CommandResponse    RHLCommandAcknowledgement    120    None    ${rhl_ret}
    IF    ${verdict} == True
        IF    ${response_dict}[RHLStatus] != 0
            ${rhl_status} =    Set Variable    False
            Log    RHL Command failed with status ${response_dict}[RHLStatus] - error code ${response_dict}[RHLErrorCode]    WARN    console="yes"
        ELSE
            ${rhl_status} =    Set Variable    True
        END
    ELSE
        ${rhl_status} =    Set Variable    False
        Log    RHL Command failed    WARN    console="yes"
    END
    Should Be True    ${rhl_status}    Fail to CHECK VNEXT NOTIFICATION RHL STATUS : ${comment}

SUBSCRIBE AZURE HUB MESSAGES
   [Arguments]    ${session}    ${notif_type}    ${message_type}    ${ret_params}=None
   [Documentation]        == High Level Description: ==
    ...     Function used to subscribe EventHub appropriate notifications matching given
    ...        criteria (notification_type, message_type)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${comment} =    SUBSCRIBE EVENTHUB MESSAGES    ${session}    ${notif_type}    ${message_type}    ${ret_params}
    Should Be True    ${verdict}    ${comment}

UNSUBSCRIBE AZURE HUB MESSAGES
   [Arguments]    ${session}
   [Documentation]        == High Level Description: ==
    ...     Function used to unsubscribe EventHub appropriate notifications matching given
    ...        criteria (session subscribed before)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict}    ${comment} =    UNSUBSCRIBE EVENTHUB MESSAGES    ${session}
    Should Be True    ${verdict}    ${comment}

WAIT FOR AZURE HUB MESSAGES
    [Arguments]    ${session}    ${duration}    ${time_start}    ${time_stop}
    [Documentation]        == High Level Description: ==
    ...     Wait for Event Hub is published messages
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if notification containing below field is published
    ${verdict}    ${comment}    ${response_hub} =    WAIT FOR EVENTHUB MESSAGES    ${session}    ${duration}    ${time_start}    ${time_stop}
    Should Be True    ${verdict}    ${comment}
    Set Test Variable     ${response_hub}

CHECK VNEXT EVENT HUB NOTIFICATION IVI ANTIFLOODING
    [Documentation]        == High Level Description: ==
    ...     Check if on Event Hub is published a notification as a result of the Security log IVI violation
    ...     no more than 32 times
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if notification containing below field is published no more than 32 times since recorded timestamp
    [Tags]    Automated    Notification SecurityLog    AZURE EVENT HUB
    ${nb_notif}=    Get length    ${response_hub}
    IF    ${nb_notif}<=${32}
        Log    Number of notifications received ${nb_notif}: ${response_hub}
    ELSE
        Fail    Number of notifications exceeded the limit:${nb_notif}
    END
