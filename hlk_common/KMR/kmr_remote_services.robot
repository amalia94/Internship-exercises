#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Resource          ${CURDIR}/../Tools/bench_config.robot
Library           rfw_services.kameleon.KameleonLib    @{kameleon_config_data}
Library           Collections
Library           String
Library           robot.libraries.DateTime
Variables         ../unsorted/tech_prod_ids.yaml
Variables         ../unsorted/calendars.yaml
Resource          ../Tools/tools.robot
Resource          ../jwt.robot

*** Variables ***
@{kameleon_config_data}    APIM    RABBIT_MQ
${console_logs}    yes
${wrong_pin}      8889
${event_hub_timeout}    300
${client_secret}    ${None}
&{empty_dict}

*** Keywords ***
CHECK KMR NOTIFICATION
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Waits for KMR notification
    ...    is not as expected, activate or deactivate it.
    ...    == Parameters: ==
    ...    - _services_: name of the services. for information only. (eg, MyCarFinder, RLU, ...)
    ...    - _expected_status_: Activated, Deactivated
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    KMR Notification    KMR
    ${comment} =    Wait Until Keyword Succeeds    120s    2s    WAIT FOR KMR NOTIFICATION    ${status}
    [Return]    ${comment}

WAIT FOR KMR NOTIFICATION
    [Arguments]    ${status}
    &{notif} =    Create Dictionary    status=${status}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    Get_KMR_Status    0    ${notif}
    [Return]    ${comment}
    Should Be True    ${verdict}

SEND KMR REQUEST
    [Arguments]    ${action}
    [Documentation]    == High Level Description: ==
    ...    From KMR sends an API request in order to ${action} the pairing.
    ...    == Parameters: ==
    ...    - _action_:: Pairing_blocked, Pairing_unblocked
    ${action_type} =     Set Variable If    "${action}" == "Pairing_blocked"    B2B_WITHOUTPAIRING    B2B_WITHPAIRING
    &{msg_body} =   Create Dictionary    usageMode=${action_type}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ${action}    0    ${msg_body}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST:${comment}

SEND KMR REQUEST RHL
    [Arguments]    ${action}    ${rhl_option}    ${srp_proof}=${NONE}   ${duration}=${None}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RHL request with the parameter needed
    ...    (defined in AIA document for RHL)
    ...    == Parameters: ==
    ...    - _action_: start, stop
    ...    - _rhl_option_: list with the following options: horn_lights, horn, lights
    ...    - _srp_proof_: Calculated SRP PROOF value if one is required (optional parameter)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    KMR APIM    KMR
    &{rhl_args} =    Create Dictionary    type=HornLights    action=${action}    target=${rhl_option}
    Run Keyword If    "${duration}"    Set To Dictionary    ${rhl_args}    duration=${duration}
    Run Keyword If    "${srp_proof}"    Set To Dictionary    ${rhl_args}    SRP_PROOF=${srp_proof}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RHL    0    ${rhl_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST RHL: ${comment}

CHECK KMR REQUEST RESPONSE
    [Arguments]    ${services}    ${expected_status}    ${resp_attr}=${empty_dict}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP ACK answer from a request.
    ...    == Parameters: ==
    ...    - _services_: HornLights, LockUnlock, SendNavigation, …
    ...    - _expected status_: Success, Fail, …
    ...    == Expected Results: ==
    ...    Pass if_expected status} is the one received in response
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    KMR APIM    KMR
    @{args} =    Run Keyword If    "${services}" == "SrpSets"    Create List    KMR_Requests    SRPRequestSalt
    ...    ELSE IF    "${services}" == "HornLights"    Create List    KMR_Requests    RHL
    ...    ELSE IF    "${services}" == "LockUnlock"    Create List    KMR_Requests    RLU
    ...    ELSE IF    "${services}" == "EngineStart"    Create List    KMR_Requests    RES
    ...    ELSE IF    "${services}" == "RefreshLocation"    Create List    KMR_Requests    MyCarFinder_Refresh_Location
    ...    ELSE IF    "${services}" == "SendNavigation"    Create List    KMR_Requests    SendNavigation
    ...    ELSE IF    "${services}" == "HvacStart"    Create List    KMR_Requests    RHOO
    ...    ELSE IF    "${services}" == "BatteryInhibition"    Create List    KMR_Requests    BCHI
    ...    ELSE IF    "${services}" == "SrpInitiates"    Create List    KMR_Requests    SRP
    ...    ELSE IF    "${services}" == "ChargingStart"    Create List    KMR_Requests    RCSS
    ...    ELSE IF    "${services}" == "HvacSchedule"    Create List    KMR_Requests    PresoakScheduleCalendar
    ...    ELSE IF    "${services}" == "RefreshHvacStatus"    Create List    KMR_Requests    RCCI
    ...    ELSE IF    "${services}" == "HvacStatus"    Create List    Get_KMR_Status    RCCI_Status
    ...    ELSE IF    "${services}" == "ChargeModeScheduled"    Create List    KMR_Requests    ScheduleMode
    ...    ELSE IF    "${services}" == "GetLastKnownLocation"    Create List    Get_KMR_Status    MyCarFinder_Get_Last_Known_Location
    ...    ELSE IF    "${services}" == "ChargeScheduled"    Create List    KMR_Requests    ScheduleCalendars
    ...    ELSE IF    "${services}" == "ChargeMode"    Create List    KMR_Requests    ScheduleMode
    ...    ELSE IF    "${services}" == "VehicleLockStatus"    Create List    KMR_Requests    RVLS
    ...    ELSE IF    "${services}" == "post_otp"    Create List    KMR_Requests    OTP
    ...    ELSE IF    "${services}" == "check_otp_code"    Create List    KMR_Requests    OTPCheck
    ...    ELSE IF    "${services}" == "PBOReset"    Create List    KMR_Requests    Service_Reset
    ...    ELSE IF    "${services}" == "COCKPIT"    Create List    Get_KMR_Status    COCKPIT_Status
    ...    ELSE IF    "${services}" == "AlwaysCharging"    Create List    KMR_Requests    ScheduleMode
    ...    ELSE IF    "${services}" == "BOOTSTRAPReset"    Create List    KMR_Requests    Service_Bootstrap_Reset
    ...    ELSE IF    "${services}" == "redi"    Create List    KMR_Requests    RemoteDiagnosticOnDemand
    ${resp_attr} =   Run Keyword If    "${services}" == "BatteryInhibition"    Create Dictionary    type=BatteryInhibition    action=${resp_attr}
    ...    ELSE    Create Dictionary
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    ${expected_status}    ${resp_attr}
    Should Be True    ${verdict}
    [Return]    ${verdict}    ${response}

SEND KMR GET TOKEN
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to retrieve the access KMR token
    ...    == Parameters: ==
    ...    -_None_
    ${client_secret_var} =    Get Environment Variable    CLIENT_SECRET    ${client_secret}
    ${client_id} =    Run Keyword If    "sit-emea" == "${env}"    Set Variable    k-internal-google-restlet-int
    ...    ELSE IF    "stg-emea" == "${env}"    Set Variable    k-internal-google-restlet-pprd
    ...    ELSE    Fail    No implementation for environment ${env}
    &{req_attr} =    Create Dictionary    grant_type=client_credentials
    ...    client_secret=${client_secret_var}
    ...    client_id=${client_id}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_GET_TOKEN    KMR_GET_TOKEN    1    ${req_attr}
    Should Be True    ${verdict}    Failed inside SEND KMR GET TOKEN: ${comment}

SEND KMR REQUEST SRP SALT
    [Arguments]    ${srp_username}
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
    [Tags]    Automated    User Authentication (SRP)    KMR APIM    KMR
    &{req_attr} =    Create Dictionary    type=SrpSets    SRPLoginSRP_I=${srp_username}    SRPLoginSRP_A=${srp_value_A}
    ${verdict}    ${comment} =   SEND KMR APIM REQUEST    KMR_Requests    SRPRequestSalt    0    ${req_attr}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST SRP SALT: ${comment}

SEND KMR REQUEST SRP INIT PIN CODE
    [Arguments]    ${srp_username}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to [KMR] for a SRP INIT PIN code request
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
    [Tags]    Automated    User Authentication (SRP)    KMR APIM    KMR
    &{srp_args} =    Create Dictionary    type=SrpInitiates    SRPVerifier=${srp_verifier}    SRPLoginSRP_I=${srp_username}    SRPLoginSRP_Salt=${srp_client_salt}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    SRP    0    ${srp_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST SRP INIT CODE: ${comment}

CHECKSET KMR USER CREATED
    [Arguments]    ${user_id}
    [Documentation]    == High Level Description: ==
    ...    Checks that the {user_id} is created in [KMR].
    ...    == Parameters: ==
    ...    - _user_id_: user_id parameter
    ...    == Expected Results: ==
    ...    output: Pass if executed.
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    KMR APIM    KMR
    &{resp_attr} =    Create Dictionary      User=${user_id}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    UserCreation    0    ${resp_attr}
    Should Be True    ${verdict}    Failed to CHECKSET KMR USER CREATED
    @{args_get} =    Create List    Get_KMR_Status    UserCreation
    &{dict_get} =    Create Dictionary
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args_get}    Success    ${dict_get}
    Return From Keyword If    ${verdict} == True
    &{attr_create_user_req} =    Create Dictionary    type=User    realm=R_MYRONE    idp=WIRED    ropId=95c2425d-626a-4d14-be2d-dcd0cbd3d7c8
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    CreateUser    0    ${attr_create_user_req}
    Should Be True    ${verdict}    Failed to SEND KMR APIM REQUEST with ${comment}
    @{args_create} =    Create List    KMR_Requests    CreateUser
    &{dict_create} =    Create Dictionary    type=User
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args_create}    Success    ${dict_create}
    Should Be True    ${verdict}    Failed to CHECK KMR APIM RESPONSE with ${response}

CHECKSET KMR USER ASSOCIATED WITH VIN
    [Arguments]    ${user_id}    ${resp_attr}=${empty_dict}
    [Documentation]    == High Level Description: ==
    ...    Checks that the {user_id} is associated with the [VIN] in [KMR].
    ...    == Parameters: ==
    ...    - _user_id_: user_id parameter
    ...    == Expected Results: ==
    ...    output: Pass if executed.
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    User Authentication (SRP)    KMR APIM    KMR
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    LinkUserVIN    0    ${resp_attr}
    Should Be True    ${verdict}    Failed to SEND KMR APIM REQUEST with ${comment}
    @{args} =    Create List    Get_KMR_Status    LinkUserVIN
    &{resp_attr} =    Create Dictionary    User=${user_id}
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${resp_attr}
    Should Be True    ${verdict}    Failed to CHECK KMR APIM RESPONSE with ${response}
    Return From Keyword If    ${verdict} == True
    &{attr_otp_req} =    Create Dictionary    type=OTP    vin=${vehicle_id}    userId=${user_id}
    ...    textLine1=Veuillez saisir le code    textLine2=Dans votre application mobile    buttonLabel=C'est fait
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    OTP    0    ${attr_otp_req}
    Should Be True    ${verdict}    Failed to SEND KMR APIM REQUEST with ${comment}
    @{otp_resp} =    Create List    KMR_Requests    OTP
    &{otp_dict_resp} =    Create Dictionary    type=OTP     vin=${vehicle_id}    userId=${user_id}
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{otp_resp}    Success    ${otp_dict_resp}
    Should Be True    ${verdict}    Failed to CHECK KMR APIM RESPONSE with ${response}
    ${otp_code} =    Set Variable    ${response['data']['attributes']['code']}
    &{link_dict} =    Create Dictionary    type=LinkUserVehicle    verificationCode=${otp_code}    role=OWNER
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    LinkUserVehicle    0    ${link_dict}
    Should Be True    ${verdict}    Failed to SEND KMR APIM REQUEST with ${comment}
    @{link_resp} =    Create List    KMR_Requests    LinkUserVehicle
    &{link_dict_resp} =    Create Dictionary    type=LinkUserVehicleResponse     vin=${vehicle_id}    userId=${user_id}    role=OWNER
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{link_resp}    Success    ${link_dict_resp}
    Should Be True    ${verdict}    Failed to CHECK KMR APIM RESPONSE with ${response}

GET DOORS STATUS
    [Arguments]    ${expected_status}    ${state}    ${doors_status}
    [Documentation]    Check the last known status of the doors.
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    Doors_Status    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND KMR APIM REQUEST: ${comment}
    @{args} =    Create List    Get_KMR_Status    Doors_Status
    &{rlu_args} =    Create Dictionary    lockStatus=${state}    doorStatusRearLeft=${doors_status}    doorStatusRearRight=${doors_status}
    ...    doorStatusDriver=${doors_status}    doorStatusPassenger=${doors_status}    engineHoodStatus=${doors_status}
    ...    hatchStatus=${doors_status}
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${rlu_args}
    Should Be True    ${verdict}    Failed to CHECK KMR APIM RESPONSE with ${response}

SEND KMR REQUEST RLU
    [Arguments]    ${action}    ${target}    ${keyOption}    ${srp_proof}=${NONE}
    [Documentation]    == High Level Description: ==
    ...    Send a remote lock order with computed SRP proof to [KMR]
    ...    == Parameters: ==
    ...    - _action_: lock, unlock
    ...    - _target_: doors_hatch
    ...    - _keyOption_: inside/outside (optional parameter, if empty then 'NA')
    ...    - _srp_proof_:  Calculated SRP PROOF value if one is required (optional parameter)
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Connected Services Domain    Remote Lock/Unlock    KMR    KMR Request
    ${from} =    Set Variable if    "${keyOption}".lower() != "na"    from    ${none}
    &{rlu_args} =    Create Dictionary    type=LockUnlock    action=${action}    target=${target}    ${from}=${keyOption}
    Run Keyword If    "${srp_proof}"    Set To Dictionary    ${rlu_args}    SRP_PROOF=${srp_proof}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RLU    0    ${rlu_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST RLU: ${comment}

SEND KMR REQUEST RVLS
    [Documentation]    == High Level Description: ==
    ...    Send HTTP request to KMR
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Connected Services Domain    Remote Vehicle Lock Status    KMR    KMR Request
    &{rvls_args} =    Create Dictionary    type=RefreshLockStatus
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RVLS    0    ${rvls_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST RVLS: ${comment}

SEND KMR OTP MESSAGE
    [Arguments]    ${notification_type}    ${code}=${None}
    [Documentation]    == High Level Description: ==
    ...    ...    Send HTTP request to KMR for one time password
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    Connected Services Domain    OTP    KMR    KMR Request
    @{otp_kmr_request} =     Run Keyword If    "${notification_type}" == "post_otp"
    ...    Create List    KMR_Requests    OTP
    ...    ELSE IF    "${notification_type}" == "check_otp_code"
    ...    Create List    KMR_Requests    OTPCheck
    &{otp_args} =    Run Keyword If    "${notification_type}" == "post_otp"
    ...    Create Dictionary    type=OTP    vin=${vehicle_id}    userID=${user_id}
    ...    textLine1=Please enter the code    textLine2=in your mobile application    buttonLabel=Done
    ...    ELSE IF    "${notification_type}" == "check_otp_code"
    ...    Create Dictionary    type=OTPCheck    vin=${vehicle_id}    code=${code}
    ...    ELSE    Fail    Failed to SEND KMR OTP MESSAGE, invalid notification type
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{otp_kmr_request}    0    ${otp_args}
    Should Be True    ${verdict}    Failed to send KMR apim request : SEND KMR OTP MESSAGE: ${comment}
    ${code} =    Fetch From Right    ${comment}    "code":"
    ${code} =    Fetch From Left    ${code}    ","expirationDate":
    Set Test Variable    ${kmr_otp_code}    ${code}

SEND KMR HVAC START
    [Arguments]    ${action}
    [Documentation]        == High Level Description: ==
    ...    Send an HTTP request to KMR APIM for RHOO with the desired {action} to be performed.
    ...    == Parameters: ==
    ...    _action_: start/stop
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote HVAC On Off    KMR APIM    KMR
    &{rhoo_args} =    Create Dictionary    type=HvacStart    action=${action}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RHOO    0    ${rhoo_args}
    Should Be True    ${verdict}    Failed to SEND KMR HVAC REQUEST: ${comment}

SEND KMR CHARGE STATE
    [Arguments]    ${action}
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a remote order to {action} the charge.
    ...    == Parameters: ==
    ...    _action_: block/unblock
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    BCHI    KMR APIM    KMR
    &{bchi_args} =    Create Dictionary    type=BatteryInhibition    action=${action}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    BCHI    0    ${bchi_args}
    Should Be True    ${verdict}    Failed to SEND KMR CHARGE STATE: ${comment}

RETRIEVE KMR CHARGE STATE
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retrieve the charge state
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    BCHI_Status    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND KMR CHARGE STATE REQUEST: ${comment}

CHECK KMR INHIBITOR STATE
    [Arguments]    ${status}
    [Documentation]        == High Level Description: ==
    ...    Check the battery inhibitor {status} retrieved from KMR
    ...    == Parameters: ==
    ...    _status_: blocked/unblocked
    @{args} =    Create List    Get_KMR_Status    BCHI_Status
    &{bchi_args} =    Run Keyword If    "${status}" == "blocked"    Create Dictionary    batteryInhibitorStatus=${0}    TimeStamp=${tstart}
    ...    ELSE    Create Dictionary    batteryInhibitorStatus=${2}    TimeStamp=${tstart}
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${bchi_args}
    Should Be True    ${verdict}    Failed to CHECK KMR INHIBITOR STATE with ${response}

SEND KMR REQUEST MYCARFINDER REFRESH LOCATION
    [Documentation]    Send a refresh location request to KMR for My Car Finder Service
    &{services_kmr_dict_location} =    Create Dictionary    type=RefreshLocation
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    MyCarFinder_Refresh_Location    0    ${services_kmr_dict_location}
    Should Be True    ${verdict}    Failed to Send a refresh location request

SEND KMR CHARGE MODE CHANGE REQUEST
    #to be checked after test steps are visible again in Silk
    [Arguments]    ${charge_mode}
    [Documentation]    Send to KMR a remote order to change the charge mode.
    &{dict_action_mode} =    Create Dictionary    type=ChargeMode    action=${charge_mode}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ScheduleMode    0    ${dict_action_mode}
    Should Be True    ${verdict}    Failed to Send Charge Mode request

GET KMR CHARGE MODE RESPONSE
    [Arguments]    ${charge_mode}
    [Documentation]    Get KMR response of the charge mode.
    ${verdict}    ${change_action_response} =    SEND KMR APIM REQUEST    Get_KMR_Status    GET_CHARGE_MODE    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to Get Charge Mode Response

SEND KMR REMOTE ORDER ONE ACTIVE CALENDAR
    [Documentation]    Send to KMR a remote order to schedule one calendar.
    &{rcss_args} =    Create Dictionary    type=ChargeSchedule    schedules=${ScheduleOneCalendarActive}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ScheduleCalendars    0    ${rcss_args}
    Should Be True    ${verdict}    Failed to Send REMOTE ORDER ONE ACTIVE CALENDAR

SEND KMR REMOTE CHARGE ACTION
    [Documentation]    Send to KMR a remote charging order to retrieve the charging settings
    ${verdict}    ${change_action_response} =    SEND KMR APIM REQUEST    Get_KMR_Status    ChangeAction    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to Send Charge Mode request
    Set Suite Variable    ${change_action_response}

SEND KMR RCHS REQUEST
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retrieve the data set
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RCHS_Status    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND KMR RCHS REQUEST: ${comment}

CHECK KMR ACK
    [Arguments]    ${rchs_params}
    [Documentation]        == High Level Description: ==
    ...    Check the parameters {status} retrieved from KMR for remote charging status
    ...    == Parameters: ==
    ...    _rchs_params_: dictionary of the elements to be checked
    Set To Dictionary    ${rchs_params}    TimeStamp=${tstart}
    @{args} =    Create List    Get_KMR_Status    RCHS_Status
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${rchs_params}
    Should Be True    ${verdict}    Failed to CHECK KMR RCHS PARAM with ${response}

CHECK KMR CHARGING SETTING RESPONSE
    [Arguments]    ${profile}    ${delay_flag}=${None}
    [Documentation]    Check the KMR charging setting response.
    ${remove_words} =    Fetch From Right    ${change_action_response}     KMR: Response received:\n
    &{result_dict} =    Convert To Dictionary    ${remove_words}
    &{dict_request} =    set to dictionary    ${result_dict['data']['attributes']}
    &{dict_response} =    set to dictionary    ${ChangeAction['${profile}']}
    @{args} =    Create List    Get_KMR_Status    ChangeAction
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${dict_response}
    Run Keyword If    ${delay_flag} == True    Should Be True    "${dict_request['delay']}" == "${delay_value}"
    Should Be True    ${verdict}    Failed to CHECK KMR CHARGING SETTING RESPONSE

SEND KMR REQUEST MYCARFINDER GET LAST KNOWN LOCATION
    [Documentation]        == High Level Description: ==
     ...    Send a Get Last Known location request to KMR for My Car Finder Service
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    MyCarFinder_Get_Last_Known_Location    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to Send a Get Last Known location request
    [Return]    ${comment}

CHECK KMR CAR LOCATION DATA
    [Arguments]    ${action}=car_data_location_enabled
    [Documentation]        == High Level Description: ==
     ...    Check Kamereon receives the response about the car location request, checking by lastUpdateTime.
     @{args} =    Create List    Get_KMR_Status    MyCarFinder_Get_Last_Known_Location
     &{uc1_args}=    Create Dictionary    TimeStamp=${tstart}
     ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${uc1_args}
     Run Keyword if    '${action}'=='car_data_location_disabled' and '${comment}'=='Timestamp value check fail: Wrong timestamp received'
     ...    Should Not Be True    ${verdict}    KMR CAR LOCATION DATA is updated: ${response}
     ...    ELSE    Should Be True    ${verdict}    Failed to Check KMR CAR LOCATION DATA: ${response}

SEND KMR INSTANT CHARGE
    #to be checked after test steps are visible again in Silk
    [Arguments]    ${action}
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a remote order to activate an instant charge
    ...    == Parameters: ==
    ...    _action_: start
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    RCSS    KMR APIM    KMR
    &{rcss_args} =    Create Dictionary    type=ChargingStart    action=${action}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RCSS    0    ${rcss_args}
    Should Be True    ${verdict}    Failed to SEND KMR INSTANT CHARGE: ${comment}

CHECK KMR PRESOAK SETTINGS RESPONSE
    [Arguments]    ${state}    ${calendar_profile}
    [Documentation]        == High Level Description: ==
    ...    Retry KMR request and check Response
    ...    == Parameters: ==
    ...    _state_: Success/Fail
    ...    _calendar_profile_: calendars to be checked
    Wait Until Keyword Succeeds    120s    10s    RETRY CHECK KMR PRESOAK SETTINGS    ${state}    ${calendar_profile}

RETRY CHECK KMR PRESOAK SETTINGS
    [Arguments]    ${state}    ${calendar_profile}
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retireve presoak schedule set and Check the response received {state} {parameter}
    ...    == Parameters: ==
    ...    _state_: Success/Fail
    ...    _calendar_profile_: calendars to be checked
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RHVS_Status    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND GET PRESOAK SETTINGS KMR REQUEST: ${comment}

    @{args} =    Create List    Get_KMR_Status    RHVS_Status
    ${size} =    Get Length    ${kmr_calendars["${calendar_profile}"]}
    FOR    ${index}    IN RANGE    0    ${size}
        ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    ${state}    ${kmr_calendars["${calendar_profile}"][${index}]}
        Should Be True    ${verdict}    Failed to SEND KMR PRESOAK SETTINGS RESPONSE with ${comment}: ${response}
    END

SEND KMR DELAYED CHARGE
    [Arguments]    ${delay}
    [Documentation]    send to KMR Car Adapter a remote order for a delayed charge
    RECORD VNEXT DATE & TIME    tstart
    ${convert_time_and_date} =    robot.libraries.DateTime.Convert Date    ${tstart}    result_format=%Y-%m-%dT%H:%M:%SZ     exclude_millis=True
    ${vnext_time_only} =    robot.libraries.DateTime.Convert Date    ${tstart}    result_format=%H:%M:%S    exclude_millis=True
    ${endDate} =    robot.libraries.DateTime.Add Time To Date    ${convert_time_and_date}    ${delay}m    exclude_millis=True
    ${delay_value} =    Evaluate    ${delay} - ${1}
    ${delay_value} =    Convert To String    ${delay_value}
    Set Global Variable    ${delay_value}
    ${convertEndDate} =    robot.libraries.DateTime.Convert Date    ${endDate}    result_format=%Y-%m-%dT%H:%M:%SZ
    &{dict_action_mode} =    Create Dictionary    type=ChargingStart    action=start    startDateTime=${convertEndDate}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RCSS    0    ${dict_action_mode}
    Should Be True    ${verdict}    Failed to SEND KMR DELAYED CHARGE

SEND KMR REMOTE ORDER DEACTIVATE
    [Documentation]    Send to KMR a remote order to deactivate the charging schedules
    &{rcss_args} =    Create Dictionary    type=ChargeSchedule    schedules=${ChangeAction['schedule_five_calendars_deactivated']}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ScheduleCalendars    0    ${rcss_args}
    Should Be True    ${verdict}    Failed to Send REMOTE ORDER DEACTIVATE

SEND KMR REQUEST PRESOAK SCHEDULE ACTIVE CALENDAR
    [Arguments]    ${presoak_calendar_profile}
    [Documentation]          == High Level Description: ==
    ...    Send a KMR presoak order to activate a calendar
    ...    == Parameters: ==
    ...    _presoak_calendar_profile_: a profile with specific calendar entries
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    PASS if executed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | | | |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | | | |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    RHVS    KMR APIM    KMR
    &{rhvs_args} =    Create Dictionary    type=HvacSchedule    schedules=${KMR_Presoak_calendars["${presoak_calendar_profile}"]}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    PresoakScheduleCalendar    0    ${rhvs_args}
    Should Be True    ${verdict}    Failed to Send REQUEST PRESOAK SCHEDULE ACTIVE CALENDAR

SEND KMR HVAC SETTINGS REQUEST
    [Arguments]    ${action}
    [Documentation]          == High Level Description: ==
    ...    Send a KMR hvac setting
    ...    == Parameters: ==
    ...    _action_: send a remote order to retrieve the HVAC settings related parameters on demand
    ...    == Expected Results: ==
    ...    output: passed if request is sent successfully (200, 202 code)
    ...    fail otherwise
    ...    PASS if executed
    [Tags]    Automated    RCCI    KMR APIM    KMR
    &{rcci_args} =    Run Keyword If    "${action}" == "on_demand"    Create Dictionary    type=RefreshHvacStatus
    ...    ELSE    FAIL    profile not implemented
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RCCI    0    ${rcci_args}
    Should Be True    ${verdict}    Failed to Send HVAC SETTINGS REQUEST

GET HVAC SETTINGS KMR
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retireve hvac settings
    ...    == Parameters: ==
    ...    _None_:
    ...    output: pass if request is sent successfully
    ...    fail otherwise
    ...    PASS if executed
    [Tags]    Automated    HVAC    KMR APIM    KMR
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RCCI_Status    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to GET HVAC SETTINGS KMR: ${comment}

CHECK KMR HVAC SETTINGS
    [Arguments]    ${hvacStatus}=${NONE}    ${internalTemperature}=${NONE}
    [Documentation]        == High Level Description: ==
    ...    KMR hvac settings response received {state}
    ...    == Parameters: ==
    ...    _state_: Success/Fail
    ...    output: pass if hvac settings are the expected one
    ...    fail otherwise
    [Tags]    Automated    RCCI    KMR APIM    KMR
    IF    '${internalTemperature}' == '${None}' or '${internalTemperature}' == '${EMPTY}'
        &{rcci_args} =    Create Dictionary    hvacStatus=${hvacStatus}

    ELSE
        &{rcci_args} =    Create Dictionary    hvacStatus=${hvacStatus}    internalTemperature=${internalTemperature}

    END
    &{rcci_args} =    Create Dictionary    hvacStatus=${hvacStatus}    internalTemperature=${internalTemperature}
    @{args} =    Create List    Get_KMR_Status    RCCI_Status
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    Success    ${rcci_args}
    Should Be True    ${verdict}    Failed to CHECK KMR HVAC SETTINGS with ${comment}: ${response}

GET VEHICLE DETAILS
    [Arguments]   ${parameter}
    [Documentation]        == High Level Description: ==
    ...    KMR request to get a specific value of a VIN
    ...    == Parameters: ==
    ...    _parameter_: the value of desired parameter to be stored
    ...    output: store the parameter of a VIN
    [Tags]    Automated    Vehicle Details    KMR APIM    KMR
    @{args} =    Create List    Get_KMR_Status    VehicleDetails
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND GET VEHICLE DETAILS REQUEST: ${comment}
    ${remove_comment} =    Fetch From Right    ${comment}     KMR: Response received:\n
    &{result_dict} =    Convert To Dictionary    ${remove_comment}
    Set Test Variable    ${${parameter}}    ${result_dict['${parameter}']}

SEND KMR RESET STATUS API
    [Documentation]        == High Level Description: ==
    ...    KMR request to reset the PBO and service status
    ...    == Parameters: ==
    ...    _None_:
    ...    output: None
    [Tags]    Automated    Vehicle Details    KMR APIM    KMR
    @{args} =    Create List    KMR_Requests    Service_Reset
    &{req_args} =    Create Dictionary    uuid=${uuid}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${req_args}
    Should Be True    ${verdict}    Failed to SEND KMR RESET STATUS API: ${comment}

CHECK KMR REQUEST RESPONSE RESET STATUS
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Check the KMR HTTP ACK answer from a request.
    ...    == Parameters: ==
    ...    - _expected status_: Success, fail, …
    ...    == Expected Results: ==
    ...    Pass if ${expected status} is the one received in response
    CHECK KMR REQUEST RESPONSE    PBOReset    ${expected_status}

CHECK KMR ACTIVATION STATUS PBO
    [Arguments]    ${expected_state}
    [Documentation]    == High Level Description: ==
    ...    Check the PBO state on KMR.
    ...    == Parameters: ==
    ...    - _expected_state_: activated, not activated, …
    ...    == Expected Results: ==
    ...    Pass if ${expected_state} is the one received in response
    @{args} =    Create List    Get_KMR_Status    VehicleDetails
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND GET VEHICLE DETAILS REQUEST: ${comment}
    ${remove_comment} =    Fetch From Right    ${comment}     KMR: Response received:\n
    &{result_dict} =    Convert To Dictionary    ${remove_comment}
    Log    ${result_dict['pushButtonOrder']['state']}
    Run Keyword If    "${expected_state}" == "not activated"    Should Contain    ${result_dict['pushButtonOrder']['state']}    TODO
    ...    ELSE    Should Contain    ${result_dict['pushButtonOrder']['state']}    DONE

SEND KMR RESET BOOTSTRAP STATUS API
    [Documentation]        == High Level Description: ==
    ...    KMR request to reset the BOOTSTRAP and service status
    ...    == Parameters: ==
    ...    _None_:
    ...    output: None
    [Tags]    Automated    Vehicle Details    KMR APIM    KMR
    SEND KMR DELETE BOOTSTRAP STATUS API
    KMR RESET BOOTSTRAP STATUS API

SEND KMR DELETE BOOTSTRAP STATUS API
    [Documentation]        == High Level Description: ==
    ...    KMR request to delete the BOOTSTRAP and service status
    ...    == Parameters: ==
    ...    _None_:
    ...    output: None
    [Tags]    Automated    Vehicle Details    KMR APIM    KMR
    @{args} =    Create List    KMR_Requests    Unpair_Bootstrap_Reset
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND KMR DELETE STATUS BOOTSTRAP API: ${comment}

KMR RESET BOOTSTRAP STATUS API
    [Documentation]        == High Level Description: ==
    ...    KMR request to reset the BOOTSTRAP and service status
    ...    == Parameters: ==
    ...    _None_:
    ...    output: None
    [Tags]    Automated    Vehicle Details    KMR APIM    KMR
    @{args} =    Create List    KMR_Requests    Service_Bootstrap_Reset
    &{req_args} =    Create Dictionary    uuid=${uuid}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${req_args}
    Should Be True    ${verdict}    Failed to SEND KMR RESET STATUS BOOTSTRAP API: ${comment}

CHECK KMR REQUEST RESPONSE RESET BOOTSTRAP STATUS
    [Arguments]    ${expected_status}
    [Documentation]    == High Level Description: ==
    ...    Check the KMR HTTP ACK answer from a request.
    ...    == Parameters: ==
    ...    - _expected status_: Success, fail, …
    ...    == Expected Results: ==
    ...    Pass if ${expected status} is the one received in response
    CHECK KMR REQUEST RESPONSE    BOOTSTRAPReset    ${expected_status}

CHECK EHORIZON LICENSE STATUS IN KMR ACTIVE
    [Documentation]    send KMR request to check status of EHorizon license is Active or not
    &{license_args} =    Create Dictionary    vehicleUuid=${uuid}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    EHorizonLicence    0    ${license_args}
    ${chk_str} =    Set Variable    \"ehzLicenseStatus\":\"ACTIVE\"
    Should Contain    ${comment}    ${chk_str}

SEND KMR SERVICE ACTIVATION REQUEST
    [Arguments]    ${action}    ${service_name}    ${system_id}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to KMR APIM to activate or deactivate a service with the parameter needed
    ...    == Parameters: ==
    ...    - _action_: Activate, Deactivate, initiate
    ...    - _service_name_ : Name of the service to be activated/deactivated
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    ACTIVATE_SERVICE    KMR APIM    KMR
    &{service} =    Create Dictionary    code=${kmr_tech_prods["${service_name}".lower()]}
    @{service} =    Create List    ${service}
    Log To Console    @{service}
    &{cdu_args} =    Create Dictionary    type=ActivateService    action=${action}    systemId=${system_id}    vin=${vehicle_id}
    ...    services=@{service}
    Log To Console    ${cdu_args}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ActivateServices    0    ${cdu_args}
    Should Be True    ${verdict}    Failed to SEND KMR SERVICE ACTIVATE REQUEST: ${comment}

SEND KMR REQUEST STOLEN VEHICLE STATUS
    [Arguments]
    [Documentation]    Send a Get stolen vehicle status request to KMR
    @{args} =    Create List    Get_KMR_Status    StolenTrackingStatus
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to Send a Get Stolen vehicle status request
    [Return]    ${comment}

RETRIEVE KMR USER
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retrieve user for a specific VIN
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RetrieveUser    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to RETRIEVE KMR USER: ${comment}
    ${remove_comment} =    Fetch From Right    ${comment}     KMR: Response received:\n
    &{result_dict} =    Convert To Dictionary    ${remove_comment}
    Set Test Variable    ${user_id}    ${result_dict['data']['id']}

GET KMR CHARGE HISTORY
    [Arguments]    ${type}    ${duration_of_days}=${None}    ${start}=${None}    ${end}=${None}
    [Documentation]    Get KMR response of the charge history.
    ...    == Parameters: ==
    ...    - type: day or month
    ...    - duration_of_days : before how many days from the current date
    ...    - start : check charge history on particular start date (Format :YYYYMM /YYYYMMDD )
    ...    - end : check charge history on particular end date (Format :YYYYMM /YYYYMMDD )
    ${date} =	robot.libraries.DateTime.Get Current Date
    IF    "${end}" == "${None}"and"${start}" == "${None}"
          ${convert_date} =	  robot.libraries.DateTime.Subtract Time From Date		${date}	  ${duration_of_days} days
          IF    "${type}" == "month"
          ${start} =    robot.libraries.DateTime.Convert Date		${convert_date}		  result_format=%Y%m
          ${end} =    robot.libraries.DateTime.Convert Date		${date}		  result_format=%Y%m
          ELSE
          ${start} =    robot.libraries.DateTime.Convert Date		${convert_date}		  result_format=%Y%m%d
          ${end} =    robot.libraries.DateTime.Convert Date		${date}		  result_format=%Y%m%d
          END
    END
    &{history_args} =    Create Dictionary    type=${type}    start=${start}    end=${end}
    ${verdict}    ${change_action_response} =    SEND KMR APIM REQUEST    Get_KMR_Status    Get_Charge_History    0    ${history_args}
    ${remove_words} =    Fetch From Right    ${change_action_response}     KMR: Response received:\n
    &{result_dict} =    Convert To Dictionary    ${remove_words}
    ${keystatus}=     Run Keyword And Return Status    Dictionary Should Contain Key    ${result_dict}     data
    Run keyword if  '${keystatus}'=='False'    Return from keyword    False
    Should Be True    ${verdict}    Failed to Get Charge History Response
    [Return]      ${change_action_response}

GET NUMBER OF KMR CHARGE HISTORY
    [Arguments]    ${json}
    [Documentation]    Get number of KMR response of the charge history.
    ...    == Parameters: ==
    ...    - json: The json returned by HLK GET KMR CHARGE HISTORY
    ${json} =    Fetch From Right    ${json}    received:
    &{json} =    Convert To Dictionary     ${json}
    ${number_of_charge} =    Set Variable    ${json['data']['attributes']['chargeSummaries']}[0]
    ${number_of_charge} =    Set Variable    ${number_of_charge['totalChargesNumber']}
    [Return]    ${number_of_charge}

SEND KMR COCKPIT REQUEST
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retrieve the data set
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    COCKPIT_Status    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND kmr COCKPIT REQUEST: ${comment}

RECEIVE DATE AND STATE OF CHARGE
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RCHS_Status    0    ${empty_dict}
    ${comment_formated} =    Fetch From Right    ${comment}    received:
    ${comment_formated} =    Fetch From Left    ${comment_formated}    )
    ${comment_json} =    Evaluate     json.loads("""${comment_formated}""")    json
    ${timestamp} =    Set Variable    ${comment_json['data']['attributes']['timestamp']}
    ${plugStatus} =    Set Variable    ${comment_json['data']['attributes']['plugStatus']}
    [Return]    ${timestamp}    ${plugStatus}

CHECK KMR PRIVACY MODE RESPONSE
    [Arguments]    ${privacy_value}
    [Documentation]    Get KMR response of the Privacy Mode.
    ...    == Parameters: ==
    ...    - privacy_value: Required privacy mode status
    ${verdict}    ${change_action_response} =    SEND KMR APIM REQUEST    Get_KMR_Status    Get_Privacy_Mode    0    ${empty_dict}
    Should Contain    ${change_action_response}    "privacyMode": "${privacy_value}"    FAILED TO CHECK PRIVACY MODE
    Should Be True    ${verdict}    Failed to Get Charge Mode Response

RECEIVE DATE STATE OF CHARGE AUTONOMY TEMPERATURE
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RCHS_Status    0    ${empty_dict}
    ${comment_formated} =    Fetch From Right    ${comment}    received:
    ${comment_formated} =    Fetch From Left    ${comment_formated}    )
    ${comment_json} =    Evaluate     json.loads("""${comment_formated}""")    json
    ${timestamp} =    Set Variable    ${comment_json['data']['attributes']['timestamp']}
    ${plugStatus} =    Set Variable    ${comment_json['data']['attributes']['plugStatus']}
    ${autonomy} =    Set Variable    ${comment_json['data']['attributes']['batteryAutonomy']}
    ${temperature} =    Set Variable    ${comment_json['data']['attributes']['batteryTemperature']}
    [Return]    ${timestamp}    ${plugStatus}    ${autonomy}    ${temperature}

CHECK ECCH MYR DATA WITH KMR
    [Arguments]    ${change_action_response}    ${total_charging_numbers}    ${total_charging_duration}
    [Documentation]    CHECK MYR Data With KMR response of the charge history.
    ${length_total_charging_duration} =    Get Length    ${total_charging_duration}
    ${smp} =    Remove String    ${total_charging_duration}    m
    IF    "${total_charging_numbers}" == "-" or "${total_charging_duration}" == "-"
    Should Not Contain    ${change_action_response}    "totalChargesDuration": ${total_charging_duration}
    Should Not Contain    ${change_action_response}    "totalChargesNumber": ${total_charging_numbers}
    ELSE IF    ${length_total_charging_duration} == 3 or ${length_total_charging_duration} == 2
    ${time_in_min} =    Remove String    ${total_charging_duration}    m
    ${charge_duration_in_minutes}    Convert To Integer    ${time_in_min}
    Should Contain    ${change_action_response}    "totalChargesDuration": ${charge_duration_in_minutes}    FAILED TO CHECK CHARGE DURATION
    Should Contain    ${change_action_response}    "totalChargesNumber": ${total_charging_numbers}    FAILED TO CHECK TOTAL CHARGE NUMBERS
    ELSE
    ${charge_duration} =	robot.libraries.DateTime.Convert Time    ${total_charging_duration}    result_format=number
    ${time_in_min}=  Evaluate  ${charge_duration} / 60
    ${charge_duration_in_minutes}    Convert To Integer    ${time_in_min}
    Should Contain    ${change_action_response}    "totalChargesDuration": ${charge_duration_in_minutes}    FAILED TO CHECK CHARGE DURATION
    Should Contain    ${change_action_response}    "totalChargesNumber": ${total_charging_numbers}    FAILED TO CHECK TOTAL CHARGE NUMBERS
    END

CHECK KMR SERVICE ACTIVATION STATUS
    [Arguments]    ${service_name}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if a given service is activated or deactivated
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
    [Tags]    Manual    Service subscription management    KMR APIM    KMR
    GET VEHICLE DETAILS    uuid
    &{services_dict} =    Create Dictionary    UID=${kmr_tech_prods["${service_name}".lower()]}    Status=${status}    uuid=${uuid}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    ServiceActivation    0    ${services_dict}
    Run Keyword And Warn On Failure    Should Be True    ${verdict}    Failed to CHECK KMR SERVICE ACTIVATION STATUS Please check Asap status, Asap activation kw not implemented

CHECK DISTANCE TOTALIZER IN KMR RESPONSE
    [Arguments]    ${response}    ${value}
    [Documentation]    == High Level Description: ==
    ...    Check the value of Milage from KMR response is same as expected value
    ...    == Parameters: ==
    ...    - response: The KMR response received after sending the milage request
    ...    - value: The Expected value for Milage
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${received_milage_value} =    Set Variable     ${response['data']['attributes']['totalMileage']}
    Should Be Equal    "${received_milage_value}"     "${value}"

CHECK KMR CHARGE HISTORY ALIGNED
    [Arguments]    ${charge_value_from_kmr}    ${initial_charge}
    [Documentation]    == High Level Description: ==
    ...    Check the charge history value from KMR is aligned with the current expected value of charge
    ...    == Parameters: ==
    ...    - charge_value_from_kmr: Recent KMR charge history response
    ...    - initial_charge: The charge number before adding the current charge
    ${final_charge} =    GET NUMBER OF KMR CHARGE HISTORY    ${charge_value_from_kmr}
    ${expected_charge_number} =    Evaluate    ${initial_charge}+${1}
    Should Be Equal    ${expected_charge_number}    ${final_charge}

CHECK FUEL LEVEL IN KMR RESPONSE
    [Arguments]    ${response}    ${value}
    [Documentation]    == High Level Description: ==
    ...    Check the value of Fuel quantity from KMR response is same as expected value
    ...    == Parameters: ==
    ...    - response: The KMR response received after sending the Fuel quantity
    ...    - value: The Expected value for fuel quantity
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${received_fuel_value} =    Set Variable     ${response['data']['attributes']['fuelQuantity']}
    Should Be Equal    "${received_fuel_value}"     "${value}"

PURGE KMR RABBITMQ QUEUE
    [Arguments]    ${queue_name}
    [Documentation]    Purge Contents of Rabbitmq Queue
    ${verdict}    ${comment} =     PURGE KMR RMQ QUEUE    ${queue_name}
    Should Be True    ${verdict}    Failed to Purge contents of rabbitmq queue contents: ${comment}

SEND SERVICE ACTIVATION REQUEST USING RABBITMQ
    [Arguments]    ${code}    ${request_id}
    [Documentation]    Send a Rabbitmq request to publish a message
    ${corr_id} =    Generate Random UUID
    Set Test Variable    ${corr_id}
    Set Test Variable    ${request_id}
    Log To Console    ${request_id}
    Log    ${request_id}
    &{code} =    Create Dictionary    code=${code}
    @{service} =    Create List    ${code}
    &{request_payload} =    Create Dictionary    services=${service}    systemId=VEGAS    instanceId=INSTANCE1    eventType=ACTIVATION_REQUEST    vin=${vehicle_id}    userId=VEGASUSER    corrId=${corr_id}    requestId=${request_id}
    Log To Console     ${request_payload}
    ${verdict}    ${comment} =     SEND KMR RMQ MESSAGE    service.exchange    acms.kamereon.service.VEGAS.action.activate.request.INSTANCE1    ACTIVATION_REQUEST    ${request_payload}
    Should Be True    ${verdict}    Failed to Purge contents of rabbitmq queue contents: ${comment}

CHECK RABBITMQ CONSUMES ACTIVATION REQUEST
    [Arguments]    ${code}    ${corr_id}=${corr_id}    ${request_id}=${request_id}
    [Documentation]    Send a Rabbitmq request to publish a message
    ${service_dict} =    Create Dictionary    code=${code}
    @{service} =    Create List    ${service_dict}
    &{request_payload} =    Create Dictionary    services=${service}    systemId=VEGAS    instanceId=INSTANCE1    eventType=ACTIVATION_REQUEST    vin=${vehicle_id}    userId=VEGASUSER    corrId=${corr_id}    requestId=${request_id}
    ${verdict}    ${comment}    ${response} =     CHECK KMR RMQ MESSAGE    acms.kamereon.service.VEGAS.action.activate.request.INSTANCE1    ACTIVATION_REQUEST    ${request_payload}
    Should Be True    ${verdict}    Failed to check rabbitmq queue contents: ${comment}

SEND SERVICE DEACTIVATION REQUEST USING RABBITMQ
    [Arguments]    ${code}    ${request_id}
    [Documentation]    Send a Rabbitmq request to publish a message
    ${corr_id} =    Generate Random UUID
    Set Test Variable    ${corr_id}
    Set Test Variable    ${request_id}
    Log To Console    ${request_id}
    Log    ${request_id}
    &{code} =    Create Dictionary    code=${code}
    @{service} =    Create List    ${code}
    &{request_payload} =    Create Dictionary    services=${service}    systemId=VEGAS    instanceId=INSTANCE1    eventType=DEACTIVATION_REQUEST    vin=${vehicle_id}    userId=VEGASUSER    corrId=${corr_id}    requestId=${request_id}
    Log To Console     ${request_payload}
    ${verdict}    ${comment} =     SEND KMR RMQ MESSAGE    service.exchange    acms.kamereon.service.VEGAS.action.deactivate.request.INSTANCE1   DEACTIVATION_REQUEST   ${request_payload}
    Should Be True    ${verdict}    Failed to complete activation of rabbitmq queue contents: ${comment}

CHECK RABBITMQ CONSUMES DEACTIVATION REQUEST
    [Arguments]    ${code}    ${corr_id}=${corr_id}    ${request_id}=${request_id}
    [Documentation]    Send a Rabbitmq request to publish a message
    ${service_dict} =    Create Dictionary    code=${code}
    @{service} =    Create List    ${service_dict}
    &{request_payload} =    Create Dictionary    services=${service}    systemId=VEGAS    instanceId=INSTANCE1    eventType=DEACTIVATION_REQUEST    vin=${vehicle_id}    userId=VEGASUSER    corrId=${corr_id}    requestId=${request_id}
    ${verdict}    ${comment}    ${response} =     CHECK KMR RMQ MESSAGE    acms.kamereon.service.VEGAS.action.deactivate.request.INSTANCE1    DEACTIVATION_REQUEST    ${request_payload}
    Should Be True    ${verdict}    Failed to check rabbitmq queue contents: ${comment}

COMPARE TIMESTAMP KMR AND MYR
    [Arguments]    ${kmr_timestamp}    ${myr_timestamp}
    [Documentation]        == High Level Description: ==
    ...     Check the KMR and MYR timestamp of update data about location
    ...    output: passed/failed
    ...    PASS if the timestamp are the same
    ${kmr_hour} =    DateTime.Convert Date    ${kmr_timestamp}    result_format=%H
    ${kmr_minute} =    DateTime.Convert Date    ${kmr_timestamp}    result_format=%M
    ${kmr_hour} =    Convert To Integer   ${kmr_hour}
    ${kmr_hour_sync_string} =	Convert To String    ${kmr_hour}
    IF   ${kmr_hour} <= 9
    ${kmr_hour_sync_string} =    Set Variable    0${kmr_hour_sync_string}
    END
    ${myr_timestamp} =    Fetch From Right    ${myr_timestamp}    at${SPACE}
    ${myr_timestamp} =    Fetch From Left    ${myr_timestamp}    ${SPACE}
    ${myr_hour} =     robot.libraries.DateTime.Get Current Date    UTC    result_format=%H    exclude_millis=True
    ${myr_minute} =    Fetch From Right    ${myr_timestamp}    :
    Should Be Equal    ${myr_hour}    ${kmr_hour_sync_string}    KMR time must be same as myRenault,  please check the difference between KMR and myRenault time.
    Should Be Equal    ${myr_minute}    ${kmr_minute}

SEND KMR REQUEST ONBOARD SERVICE ACTIVATION
    [Arguments]    ${service_name}     ${status}
    [Documentation]    == High Level Description: ==
    ...    Do a technical service request onboard deactivation
    ...    == Parameters: ==
    ...    - _service_name_: name of the services. for information only. (eg, TWT)
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Manual    Service subscription management    KMR APIM    KMR
    &{code} =    Create Dictionary    code=${kmr_tech_prods["${service_name}".lower()]}
    @{service} =    Create List    ${code}
    &{service_args} =    Create Dictionary    systemId=BSD   services=@{service}
    ${verdict}    ${comment} =    Run Keyword If    "${status}".lower() == "activate"    SEND KMR APIM REQUEST    KMR_Requests    Request_Onboard_Activation    0    ${service_args}
    ...    ELSE IF    "${status}".lower() == "deactivate"    SEND KMR APIM REQUEST    KMR_Requests    Request_Onboard_Deactivation    0    ${service_args}
    Should Be True    ${verdict}    Failed to SEND KMR APIM REQUEST with ${comment}

CHECK KMR VEHICLE STOLEN STATUS
    [Arguments]    ${status}
    [Documentation]        == High Level Description: ==
    ...     Check status of Vehicle Stolen Status in KMR.
    ...    output: passed/failed
    ...    PASS if executed
    ${response_stolen_vehicle_status} =    SEND KMR REQUEST STOLEN VEHICLE STATUS
    ${response_stolen_vehicle_status} =    Fetch From Right    ${response_stolen_vehicle_status}    received:
    ${response_stolen_vehicle_status} =    Fetch From Left    ${response_stolen_vehicle_status}    )
    ${response_stolen_vehicle_status_json} =    Evaluate     json.loads("""${response_stolen_vehicle_status}""")    json
    ${status_kmr} =    Set Variable    ${response_stolen_vehicle_status_json['data']['attributes']['stolenVehicleTracking']['status']}
    Should Be Equal    ${status}    ${status_kmr}

CHECK KMR USER VEHICLE LIST VIN
    [Arguments]    ${expected_status}
    [Documentation]        == High Level Description: ==
    ...    Send to KMR a request to retrieve vehicle informations
    ${args} =    Create List    Get_KMR_Status    VehicleListVin
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to RETRIEVE User Information
    ${remove_comment} =    Fetch From Right    ${comment}     "attributes":
    ${remove_comment} =    Fetch From Left    ${remove_comment}    }
    ${remove_comment} =    Set variable    ${remove_comment}}
    Log    ${remove_comment}
    ${result_dict} =    Convert To Dictionary    ${remove_comment}
    Log    ${result_dict['vin']}
    Run Keyword If    "${expected_status}" == "present"    Should Contain    ${result_dict['vin']}    ${vehicle_id}
    ...    ELSE    Should not Contain    ${result_dict['vin']}    ${vehicle_id}

CHECK KMR VEHICLE OWNER INFORMATION
    [Arguments]    ${status}
    [Documentation]        == High Level Description: ==
    ...    Send a KMR remote order to retrieved the vehicle owner information
    ...    Check that vehicle is owned by user
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    VehicleOwnerInformation    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to Retrive vehicle owner
    IF    "${status}" == "present"
    ${remove_comment} =    Fetch From Right    ${comment}     "attributes":
    ${remove_comment} =    Fetch From Left    ${remove_comment}    }
    ${remove_comment} =    Set variable    ${remove_comment}}
    ${result_dict} =    Convert To Dictionary    ${remove_comment}
    Should Contain    ${result_dict}    vehicleOwnedSince
    ELSE
    ${remove_comment} =    Fetch From Right    ${comment}    "errors":[
    ${remove_comment} =    Fetch From Left    ${remove_comment}    }
    ${remove_comment} =    Set variable    ${remove_comment}}
    ${result_dict} =    Convert To Dictionary    ${remove_comment}
    Should Contain    ${result_dict}    User not found
    END

SEND KMR EHORIZON SERVICE ACTIVATION REQUEST
    [Arguments]    ${action}    ${service_name}    ${system_id}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to KMR APIM to activate or deactivate a service with SID
    ...    == Parameters: ==
    ...    - _action_: Initiate, Deinitiate
    ...    - _service_name_ : Name of the service to be activated/deactivated
    ...    - system_id : NCE
    ...    == Expected Results: ==
    ...    output: passed/failed
    [Tags]    Automated    ACTIVATE_SERVICE    KMR APIM    KMR
    ${service} =    Create Dictionary    code=${kmr_tech_prods["${service_name}".lower()]}
    @{service} =    Create List    ${service}
    Log To Console    @{service}
    ${cdu_args} =    Create Dictionary    type=ActivateService    action=${action}    systemId=${system_id}    vin=${vehicle_id}
    ...    services=@{service}
    Log To Console    ${cdu_args}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ActivateEhorizon    0    ${cdu_args}
    Should Be True    ${verdict}    Failed to SEND KMR SERVICE ACTIVATE REQUEST: ${comment}

SEND A KMR KDIAG REMOTE DIAGNOSTIC REQUEST ON DEMAND
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to KMR APIM to trigger remote diagnosis on demand
    ...    output: passed/failed
    [Tags]    Automated    REMOTE_DIAG    KMR APIM    KMR
    Log    SEND A KMR KDIAG REMOTE DIAGNOSTIC REQUEST ON DEMAND
    ${list_vins} =    Create List    ${vehicle_id}
    ${redi_args} =    Create Dictionary    vins=${list_vins}    lang=en    source=DDP    userId=${userId}    entityId=REDI
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RemoteDiagnosticOnDemand    0    ${redi_args}
    Should Be True    ${verdict}    Failed to SEND A KMR KDIAG REMOTE DIAGNOSTIC REQUEST ON DEMAND with ${comment}

SEND KMR KDIAG REQUEST REMOTE DIAGNOSIS STATUS
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to KMR to get remote diagnosis status
    ...    output: passed/failed
    [Tags]    Automated    REMOTE_DIAG    KMR APIM    KMR
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    Get_KMR_Status    RemoteDiagnostic    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND KMR KDIAG REQUEST REMOTE DIAGNOSIS STATUS with ${comment}
    # Store comment response to use it on CHECK KMR KDIAG REMOTE DIAGNOSTIC STATUS keyword
    Set test variable    ${comment}

CHECK KMR KDIAG REMOTE DIAGNOSTIC STATUS
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    KMR Remote Diag bosch convertor response received
    ...    == Parameters: ==
    ...    _state_: Success/Fail
    ...    _response_: response received to be checked
    [Tags]     Automated    REMOTE_DIAG    KMR APIM    KMR
    @{args} =    Create List    Get_KMR_Status    RemoteDiagnostic
    ${my_list}    Evaluate    json.loads('''${comment}''')    json
    ${list_size}    Get Length    ${my_list}
    ${last_element} =     Set Variable    ${my_list}[-1]
    ${id_field} =    Get From Dictionary   ${last_element}    id
    ${component_state} =    Get From Dictionary    ${last_element}    componentStep
    ${state} =    Get From Dictionary    ${last_element}    state
    Set test variable    ${id_field}
    ${resp_attr} =    Create Dictionary    id=${id_field}    vin=${vehicle_id}    componentStep=VDH    state=SUCCESS
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    ${status}    ${empty_dict}
    Should Be Equal    ${componentState}    VDH
    Should Be Equal    ${state}    SUCCESS
    Should Be True    ${verdict}    Failed to CHECK KMR KDIAG REMOTE DIAGNOSTIC STATUS with ${comment}: ${response}

CHECK KMR KDIAG REMOTE DIAGNOSTIC STATUS SUCCESS
    [Documentation]    == High Level Description: ==
    ...    KMR Remote Diag bosch convertor response received
    ...    _response_: response received to be checked
    [Tags]     Automated    REMOTE_DIAG    KMR APIM    KMR
    Wait Until Keyword Succeeds    120s    5s    CHECK KMR KDIAG REMOTE DIAGNOSTIC STATUS    Success

SEND KMR KDIAG REQUEST PRINT REMOTE DIAGNOSTIC
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to KMR to get print diagnosis status
    ...    output: passed/failed
    [Tags]    Automated    REMOTE_DIAG    KMR APIM    KMR
    Log    Keyword not implemented

CHECK KMR KDIAG REQUEST PRINT REMOTE DIAGNOSTIC
    [Documentation]    == High Level Description: ==
    ...    KMR Remote Diag print diagnosis response received
    [Tags]     Automated    REMOTE_DIAG    KMR APIM    KMR
    Log    Keyword not implemented

CHECK KMR SERVICE ACTIVATION STATUS COMMERCIAL SERVICE
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if commercial services are activated/deactivated. When the service activation status
    ...    is not as expected, activate or deactivate it.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated
    ...    == Expected Results: ==
    ...    output: passed/failed
    @{list_of_services} =    Create List
    Append To List    ${list_of_services}    mycarfinder    rlu    rhl    rvls    res_status_check    remote_charging_start_and_stop
    ...    remote_hvac_scheduling    remote_rchs    ecch    ntcs    remote_hvac_on_and_off    ehorizon
    FOR    ${item}    IN    @{list_of_services}
        CHECK KMR SERVICE ACTIVATION STATUS    ${item}    ${status}
    END

SEND KMR REQUEST JWT RHL
    [Arguments]    ${action}    ${rhl_option}   ${jwt_token}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RHL request with the parameter needed
    ...    (defined in AIA document for RHL)
    ...    == Parameters: ==
    ...    - _action_: start, stop
    ...    - _rhl_option_: list with the following options: horn_lights, horn, lights
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    KMR APIM    KMR
    &{rhl_args} =    Create Dictionary    type=HornLights    action=${action}    target=${rhl_option}
    Run Keyword If    "${jwt_token}"    Set To Dictionary    ${rhl_args}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RHL    0    ${rhl_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST RHL: ${comment}

CHECK JWT KMR REQUEST RESPONSE
    [Arguments]    ${services}    ${expected_status}    ${resp_attr}=${empty_dict}
    [Documentation]    == High Level Description: ==
    ...    Check the Vnext HTTP ACK answer from a request.
    ...    == Parameters: ==
    ...    - _services_: HornLights, LockUnlock, SendNavigation, …
    ...    - _expected status_: Success, Fail, …
    ...    == Expected Results: ==
    ...    Pass if_expected status} is the one received in response
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Services Common    KMR APIM    KMR
    @{args} =    Run Keyword If    "${services}" == "HornLights"    Create List    KMR_Requests    RHL
    ...    ELSE IF    "${services}" == "LockUnlock"    Create List    KMR_Requests    RLU
    ${verdict}    ${comment}    ${response} =    CHECK KMR APIM RESPONSE    @{args}    ${expected_status}    ${resp_attr}
    Should Be True    ${verdict}    Failed to CHECK JWT KMR REQUEST RESPONSE: ${comment}
    [Return]    ${verdict}    ${response}

SEND KMR REQUEST JWT RLU
    [Arguments]    ${action}    ${rlu_option}   ${jwt_token}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to Vnext APIM for a RHL request with the parameter needed
    ...    (defined in AIA document for RHL)
    ...    == Parameters: ==
    ...    - _action_: start, stop
    ...    - _rhl_option_: list with the following options: horn_lights, horn, lights
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ...    | =Test Configuration= | =Step Implementation= | =Status= | =Matrix Delivery= |
    ...    | IVI-RSL-ANDP_SIL_LINUX | X | Accepted by TE | 2.10 |
    ...    | IVI-RSL-ANDP_HIL_RENH3M4 | X | Accepted by TE | 2.11 |
    ...    | IVI-REN-ANDP_HIL_RENH3M4 | | | Accepted by TE |
    ...    | CLUSTER-CSPP_HIL_RENH3M4 | | | |
    [Tags]    Automated    Remote Horn & Lights    KMR APIM    KMR
    &{rlu_args} =    Create Dictionary    type=LockUnlock    action=${action}    target=${rlu_option}
    Run Keyword If    "${jwt_token}"    Set To Dictionary    ${rlu_args}
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    RLU    0    ${rlu_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST RLU: ${comment}

SEND KMR REQUEST READ UCD CONFIGURATION
    [Documentation]        == High Level Description: ==
     ...    Check Kamereon receives the response with UCD Configuration Id.
    &{ucd_args} =    Create Dictionary    type=ReadUcdConfiguration
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    KMR_Requests    ReadUCDConfig    0    ${ucd_args}
    Should Be True    ${verdict}    Failed to SEND KMR REQUEST UCD: ${comment}
    [Return]    ${comment}

STORE UCD CONFIG REQ ID
    [Arguments]    ${ucd_response}
    [Documentation]        == High Level Description: ==
     ...    Store the UCD Configuration Id.
    ${ucd_response} =    Evaluate    ${ucd_response}
    ${ucd_config_id} =    Set Variable    ${ucd_response['data']['id']}
    Set Suite Variable    ${ucd_config_id}

GET KMR SECURITY PROTOCOL
    [Documentation]    == High Level Description: ==
    ...    Depending on the architecture sw200 or sw400
    ...    KMR request to get a security protocol value of a VIN
    @{args} =    Create List    Get_KMR_Status    VehicleDetails
    ${verdict}    ${comment} =    SEND KMR APIM REQUEST    @{args}    0    ${empty_dict}
    Should Be True    ${verdict}    Failed to SEND GET VEHICLE DETAILS REQUEST: ${comment}
    ${remove_comment} =    Fetch From Right    ${comment}     KMR: Response received:\n
    &{result_dict} =    Convert To Dictionary    ${remove_comment}
    IF    '${sweet400_bench_type}' in "'${bench_type}'"
        GET KMR SECURITY PROTOCOL FOR SW400    &{result_dict}
    ELSE
        GET KMR SECURITY PROTOCOL FOR SW200    &{result_dict}
    END

GET KMR SECURITY PROTOCOL FOR SW400
    [Arguments]   &{result_dict}
    [Documentation]        == High Level Description: ==
    ...    KMR request to check security protocol value of remoteSecurityProtocol and offboardTokenKeyId
    ...    == Parameters: ==
    ...    _parameter_: the value of desired parameter to be stored
    ...    output: store the parameter of a VIN
    Should Be Equal    ${result_dict['remoteSecurityProtocol']}    JWT
    Should Be Equal    ${result_dict['offboardTokenKeyIdStatus']}    ${1}
    Should Be True    ${result_dict['jwtSupported']}
    Should Not Be Empty    ${result_dict['offboardTokenKeyId']}
    Set Global Variable    ${kid}    ${result_dict['offboardTokenKeyId']}

GET KMR SECURITY PROTOCOL FOR SW200
    [Arguments]   &{result_dict}
    [Documentation]        == High Level Description: ==
    ...    KMR request to check security protocol value of remoteSecurityProtocol and jwtSupported
    ...    == Parameters: ==
    ...    _parameter_: the value of desired parameter to be stored
    ...    output: store the parameter of a VIN
    Should Be Equal    ${result_dict['remoteSecurityProtocol']}    SRP
    Should Not Be True    ${result_dict['jwtSupported']}

CHECK KMR SERVICE ACTIVATION STATUS COMMERCIAL SERVICES
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if KMR commercial services are activated/deactivated.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated

    @{list_of_services} =    Create List    ecall    ota_sw_update_it_master    mycarfinder    rlu    rvls    rhl    rlu_vehicle_status_check
    ...    remote_charging_start_and_stop    remote_charging_schedule_avn    remote_hvac_scheduling    cabintemperature    remote_rchs    ecch    ntcs
    ...    remote_hvac_on_and_off    gas_affichange_myr    internet_access_for_gas    ehorizon    remote_diag_scomo

    FOR    ${item}    IN    @{list_of_services}
        CHECK KMR SERVICE ACTIVATION STATUS    ${item}    ${status}
    END

CHECK KMR SERVICE ACTIVATION STATUS FIRST PRIORITY TECHNICAL SERVICES
#TODO : after test design is finished, add the required services to this keyword; ticket CCAR-67388
#Description for the above to do: Design needs to be updated to know which KMR services are considered First Priority Technical services
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if KMR first priority technical services are activated/deactivated.
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated

    @{list_of_services} =    Create List

    IF    "${ivi_my_feature_id}" == "MyF1"
        Append To List    ${list_of_services}
    ELSE IF    "${ivi_my_feature_id}" == "MyF2"
        Append To List    ${list_of_services}
    ELSE IF    "${ivi_my_feature_id}" == "MyF3"
        Append To List    ${list_of_services}
    END

    FOR    ${item}    IN    @{list_of_services}
        CHECK KMR SERVICE ACTIVATION STATUS    ${item}    ${status}
    END

CHECK KMR SERVICE ACTIVATION STATUS SECOND PRIORITY TECHNICAL SERVICES
    [Arguments]    ${status}
    [Documentation]    == High Level Description: ==
    ...    Checks if KMR second technical services are activated/deactivated. W
    ...    == Parameters: ==
    ...    - _status_: Activated, Deactivated

    @{list_of_services} =    Create List    ubm    lemon    coma    blms    ivc_log_and_trace    soh

    FOR    ${item}    IN    @{list_of_services}
        CHECK KMR SERVICE ACTIVATION STATUS    ${item}    ${status}
    END
