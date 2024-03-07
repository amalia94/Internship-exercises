#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation    Library for Alliance SRP keywords
Library          rfw_services.ASRPLib

*** Variables ***


*** Keywords ***
DO SRP INIT
    [Arguments]    ${username}    ${password}
    [Documentation]    == High Level Description: ==
    ...    Initialize SRP library.
    ...    == Parameters: ==
    ...    - _username_: username for SRP
    ...    - _password_: password for SRP
    ...    == Expected Results: ==
    ...    - Outcome: PASSED
    [Tags]    Automated    User Authentication (SRP)
    ASRP INIT    ${username}    ${password}

DO SRP GENERATE VERIFIER & SALT
    [Documentation]    == High Level Description: ==
    ...    Use SRP library to generate client verifier and salt values.
    ...    == Expected Results: ==
    ...    - Outcome: PASSED
    ...    - Updates test variables: _srp_verifier_, _srp_client_salt_
    [Tags]    Automated    User Authentication (SRP)
    ${verdict}    ${verifier}    ${salt} =    ASRP GENERATE VERIFIER & SALT
    Should Be True    ${verdict}    Failed on DO SRP GENERATE VERIFIER & SALT
    Set Test Variable    ${srp_verifier}    ${verifier}
    Set Test Variable    ${srp_client_salt}    ${salt}

DO SRP GENERATE A & a
    [Documentation]    == High Level Description: ==
    ...    Use SRP library to generate A & a values where "A" is client public ephemeral (hexstring format), "a" is client secret ephemeral (hexstring format).
    ...    == Expected Results: ==
    ...    - Outcome: PASSED
    ...    - Updates test variable: _srp_value_A_
    [Tags]    Automated    User Authentication (SRP)
    ${verdict}    ${value_A}    ${secret_a} =    ASRP GENERATE A & a
    Should Be True    ${verdict}    Failed on DO SRP GENERATE A & a
    Set Test Variable     ${srp_value_A}    ${value_A}

DO SRP GENERATE PROOF
    [Arguments]    ${vehicle_id}    ${target_id}    ${action}    ${option}=${NONE}
    [Documentation]    == High Level Description: ==
    ...    Use SRP library to generate SRP Proof value.
    ...    == Parameters: ==
    ...    - _vehicle_id_: Vehicle ID (VIN)
    ...    - _target_id_: Name of the service to be requested
    ...    - _action_: Name of the service action to be requested
    ...    - _option_: option specific to selected action (optional parameter)
    ...    == Expected Results: ==
    ...    - Outcome: PASSED
    ...    - Updates test variable: _srp_proof_
    [Tags]    Automated    User Authentication (SRP)
    ${verdict}    ${comment} =    ASRP PROCESS CHALLENGE    ${srp_server_salt}    ${srp_value_B}
    Should Be True    ${verdict}    Failed on DO SRP PROCESS CHALLENGE: ${comment}
    ${verdict}    ${proof} =    ASRP GENERATE PROOF    ${vehicle_id}    ${target_id}    ${action}    ${option}
    Should Be True    ${verdict}    Failed on DO SRP GENERATE PROOF
    Set Test Variable    ${srp_proof}    ${proof}

DO SRP GENERATE SERVER PROOF
    [Arguments]    ${vehicle_id}    ${target_id}    ${action}    ${option}=${NONE}
    [Documentation]    == High Level Description: ==
    ...    Use SRP library to generate SERVER SRP Proof value.
    ...    == Parameters: =
    ...    - _vehicle_id_: Vehicle ID (VIN)
    ...    - _target_id_: Name of the service to be requested
    ...    - _action_: Name of the service action to be requested
    ...    - _option_: option specific to selected action (optional parameter)
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${verdict} =    ASRP PROCESS CHALLENGE    ${SRP_s}    ${SRP_B}
    Should Be True    ${verdict}    Failed on DO SRP PROCESS CHALLENGE
    ${verdict}    ${serv_proof} =    ASRP SERVER GENERATE PROOF    ${vehicle_id}    ${target_id}    ${action}    ${option}
    Should Be True    ${verdict}    Failed to DO SRP GENERATE SERVER PROOF: ${serv_proof}
    Should Be Equal    ${srp_proof}    ${serv_proof}

DO SRP GENERATE s and B
    [Documentation]    == High Level Description: ==
    ...    Use OCTAV library to generate s & B values
    ...    == Parameters: =
    ...    - _None_
    ...    == Expected Results: ==
    ...    output: passed/failed
    ASRP SERVER INIT    ${username}    ${srp_client_salt}    ${srp_verifier}    ${srp_value_A}
    ${s}    ${B} =    ASRP SERVER GET CHALLENGE
    Set Test Variable    ${SRP_s}    ${s}
    Set Test Variable    ${SRP_B}    ${B}
