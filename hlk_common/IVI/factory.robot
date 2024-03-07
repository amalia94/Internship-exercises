#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     filesystem keywords library
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           String
Library           OperatingSystem


*** Variables ***

*** Keywords ***
CHECK IVI TRUSTED CLOCK
    [Arguments]    ${date_time}=None
    [Documentation]    Compares the trusted clock timestamp with the given date time.

    ${status}    ${trusted_clock_timestamp} =    GET TRUSTED CLOCK TIMESTAMP
    Should Be True    ${status}    The trusted clock timestamp could not be retrieved!
    Log    Trusted clock timestamp: ${trusted_clock_timestamp}.

    ${date_time} =    Set Variable If    "${date_time}" == "None"    ${tstart}    ${date_time}
    Log    Date time: ${date_time}.

    ${verdict} =    Evaluate    '''${trusted_clock_timestamp}''' > '''${date_time}'''
    Should Be True    ${verdict}    The trusted clock timestamp is not greater than the provided date time!
