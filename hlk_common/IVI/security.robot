#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     Keywords related to Security tests
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           String

*** Variables ***


*** Keywords ***
CHECK SELINUX ENFORCE
    [Arguments]    ${dutid}    ${status}
    [Documentation]    Checks the Selinux status on Android
    # GET SELINUX STATUS
    #
    # Override keyword's default parameters + retrieve returned value
    # ${process} =    GET SELINUX STATUS
    #
    # Retrieve keyword's default returned values
    ${output} =    GET SELINUX STATUS
    ${getenforce_response} =    Convert To Lowercase    ${output}
    Should Contain    ${getenforce_response}    ${status}
