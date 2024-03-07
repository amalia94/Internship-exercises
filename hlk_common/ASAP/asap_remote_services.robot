#
# Copyright (c) 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           rfw_services.asap.AsapLib

*** Variables ***

*** Keywords ***
CHECKSET ASAP SERVICE ACTIVATION STATUS FOR
    [Arguments]    ${service_name}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if a given service is activated/deactivated. When the service activation status
    ...    is not as expected, activate or deactivate it.
    ...    == Parameters: ==
    ...    - _service_name_: name of the services. for information only. (eg, MyCarFinder, RLU, ...)
    ...    - _status_: Activated, Deactivated
    ...    == Expected Results: ==
    ...    output: passed/failed
    Log To Console    CHECKSET ASAP SERVICE ACTIVATION STATUS FOR service ${service_name} in state ${status}
    Run Keyword And Ignore Error    CHECK ASAP SERVICE ACTIVATION STATUS    ${service_name}    ${status}
    Return From Keyword If    ${service_activation_verdict} == True
    ${action} =    Set Variable If    "${status}".lower() == "activated"    SERVICES_ACTIVATION    SERVICES_DEACTIVATION
    SEND ASAP SERVICE ACTIVATION REQUEST    ${action}    ${service_name}
    Wait Until Keyword Succeeds    300s    10s    CHECK ASAP SERVICE ACTIVATION STATUS    ${service_name}    ${status}

CHECK ASAP SERVICE ACTIVATION STATUS
    [Arguments]    ${service_name}    ${status}
    [Documentation]    == High Level Description: ==
    ...    Check if a given service is activated or deactivated
    ...    == Parameters: ==
    ...    - _service_name_: name of the services. for information only. (eg, MyCarFinder, RLU, ...)
    ...    - _status_: Activated, Deactivated
    ...    == Expected Results: ==
    ...    output: passed/failed
    ...    == Implementation: ==
    ${UID} =    Set variable    ${kmr_tech_prods["${service_name}".lower()]}
    ${service} =    Convert to string    ${UID}
    ${request_payload} =    CREATE DICTIONARY    vin=${vehicle_id}    service_id=${service}
    ${verdict}    ${comment} =    SEND ASAP REQUEST    Get_ASAP_Status    ServiceActivation    ${request_payload}
    Set test variable    ${service_activation_verdict}    ${verdict}
    Should Be True    ${verdict}    Failed to SEND ASAP REQUEST CHECK SERVICE ACTIVATION STATUS due to ${comment}
    ${UPPER_status}=      Evaluate     "${status}".upper()
    ${services_dict} =    Create Dictionary    featureId=${UID}    status=${UPPER_status}
    ${verdict}    ${comment}    ${response} =   CHECK ASAP RESPONSE   Get_ASAP_Status    ServiceActivation   Success   ${services_dict}
    Set test variable    ${service_activation_verdict}    ${verdict}
    Should Be True    ${verdict}    Please check mannualy the service status, it make take too long for service to activate/deactivate:${comment}

SEND ASAP SERVICE ACTIVATION REQUEST
    [Arguments]    ${action}    ${service_name}
    [Documentation]    == High Level Description: ==
    ...    Send a HTTP request to ASAP APIM to activate or deactivate a service with the parameter needed
    ...    == Parameters: ==
    ...    - _action_: SERVICES_ACTIVATION, SERVICES_DEACTIVATION, SERIAL_SERVICES_ACTIVATION, MNO_REPLACEMENT
    ...    - _service_name_ : Name of the service to be activated/deactivated
    ...    == Expected Results: ==
    ...    output: passed if the provisionning request was created
    [Tags]    Automated    ACTIVATE_SERVICE    ASAP APIM
    ${UID} =    Set variable    ${kmr_tech_prods["${service_name}".lower()]}
    ${service} =    Convert to string    ${UID}
    ${vin}=    Create list    ${vehicle_id}
    ${uuid}=    Evaluate    uuid.uuid4()    modules=uuid
    ${UUID} =    Convert to string    ${uuid}
    ${request_payload} =    CREATE DICTIONARY    externalId=${UUID}    provisioningProcessType=${action}    features=${service}    vins=${vin}
    ${verdict}    ${comment} =    SEND ASAP REQUEST    Provisioning_Requests    Create_Provisioning_Request    ${request_payload}
    Should Be True    ${verdict}    Failed to SEND ASAP SERVICE ACTIVATION STATUS due to ${comment}
    &{response_params}=    CREATE DICTIONARY    provisioningProcessType=${action}    status=CREATED
    ${verdict}    ${comment}    ${response} =   CHECK ASAP RESPONSE   Provisioning_Requests    Create_Provisioning_Request   Success    ${response_params}
    Should Be True    ${verdict}    ${comment}

CHECKSET ASAP SERVICE ACTIVATION STATUS COMMERCIAL SERVICE
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
        CHECKSET ASAP SERVICE ACTIVATION STATUS FOR    ${item}    ${status}
    END
