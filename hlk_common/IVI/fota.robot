#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation    Suite description
Library    rfw_services.ivi.AndroidDriverLib    device=${target_id}

*** Variables ***
${target_id}         ${None}

*** Keywords ***
CHECK SWMC FOTA CLIENT ACTIVE STATE
    [Arguments]    ${target_id}    ${cmd}    ${status}
    [Documentation]    Check whether fota client is active or not
    ${dumpsys_window} =     OperatingSystem.Run    adb -s ${target_id} shell ${cmd}
    SHOULD CONTAIN     ${dumpsys_window}    ${status}    msg=Fota client is not active
