#
# Copyright (c) 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation    Library for JWT keywords
Library          rfw_services.JWTLib

*** Variables ***
${jti}    4875
${kid}    testjwt0
&{error_aud}    aud=VF1FD00000MPLJ077
${created_vin_date}    False

*** Keywords ***
DO JWT INIT
    [Arguments]    ${vehicle_id}
    [Documentation]    == High Level Description: ==
    ...    Initialize JWT
    ...    == Parameters: ==
    ...    - _vehicle_id_: Vehicle ID (VIN)
    IF    "${created_vin_date}" == "True"
        JWT INIT    ${vehicle_id}    ${kid}    ${createdDate}
    ELSE
        JWT INIT    ${vehicle_id}    ${kid}
    END

DO JWT GENERATE
    [Documentation]    == High Level Description: ==
    ...    Encoded token is returned
    ...    == Parameters: ==
    ...    - _target_: Name of the service to be requested
    ...    - _action_: Name of the service action to be requested
    ...    - _exp_time_: The expiration time value in seconds
    ...    == Expected Results: ==
    ...    - Outcome: PASSED
    ...    - Updates test variables: _jwt_token_
    [Arguments]    ${target}    ${action}    ${exp_time}=None
    IF    ${exp_time}
        ${exp_time} =   Convert To Integer    ${exp_time}
    END
    ${jwt_token_generated} =    JWT GENERATE    ${target}    ${action}    ${jti}    ${exp_time}
    Set Test Variable    ${jwt_token}    ${jwt_token_generated}

DO JWT GENERATE WITH INDUCED ERROR
    [Documentation]    == High Level Description: ==
    ...    Encoded token with error is returned
    ...    == Parameters: ==
    ...    - _target_: Name of the service to be requested
    ...    - _action_: Name of the service action to be requested
    ...    - _exp_time_: The expiration time value in seconds
    ...    == Expected Results: ==
    ...    - Outcome: PASSED
    ...    - Updates test variables: _jwt_token_error_
    [Arguments]    ${target}    ${action}    ${exp_time}
    ${exp_time} =   Convert To Integer    ${exp_time}
    ${jwt_token_error} =    JWT GENERATE    ${target}    ${action}    ${jti}    ${exp_time}    ${error_aud}
    Log    The JWT token with induced error is: ${jwt_token_error}
    Set Test Variable    ${jwt_token}    ${jwt_token_error}

DO JWT CHECK
    [Arguments]    ${vehicle_id}    ${target}    ${action}
    [Documentation]    == High Level Description: ==
    ...    Check JWT token
    ${iat_value} =  Get Time    epoch
    ${exp_time} =   Convert To Integer    300
    ${exp_value_calculated} =    Evaluate     ${iat_value} + ${exp_time}
    Log To Console     ${exp_value_calculated}
    ${command_dict} =  Create Dictionary    TargetID=${target}    Action=${action}
    ${validate_header_dict} =    Create Dictionary    alg=PS384    kid=${kid}    typ=JWT
    ${command_dict_values} =    Create Dictionary    TargetID=${target}    Action=${action}
#    ${validation_dict} =    Create Dictionary    jti=${jti}   exp=${exp_value_calculated}    iat=${iat_value}    aud=${vehicle_id}    iss=Offboard    command=${command_dict_values}
    ${validation_dict} =    Create Dictionary    aud=${vehicle_id}    iss=Offboard    command=${command_dict_values}
    ${compare_dict} =    Create Dictionary    payload=${validation_dict}    header=${validate_header_dict}
    JWT CHECK    ${jwt_token}    ${compare_dict}    no_aud=True    no_exp=True
