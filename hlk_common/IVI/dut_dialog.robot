#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Documentation     communication/interaction with dut - keywords library
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.FileSystemLib    device=${ivi_adb_id}
Library           OperatingSystem
Resource          ../power_supply.robot

*** Variables ***
${mode}           running
${value}          no
${use_power_supply}    False

*** Keywords ***
CHECKSET POWER IVI
    [Arguments]    ${ivi_adb_id}    ${mode}
    [Documentation]    Check DUT state
    ...    ${ivi_adb_id} the dedicated DUT
    ...    ${mode} the expected mode (on/off)
    ...    ${use_power_supply} whether or not to use a power supply (internal keyword variable)
    # Latest Keyword Released - REPLACES KEYWORDS: [CHECKSET DUT and DO DEBUGBRIDGE]
    Run Keyword If    ${use_power_supply} == True    SETUP POWER SUPPLY
    Run Keyword If    ${use_power_supply} == True and "${mode}" == "on"    SET POWER SUPPLY ON
    Run Keyword If    ${use_power_supply} == True and "${mode}" == "off"    SET POWER SUPPLY OFF
    ${is_mode} =    Run Keyword If    ${use_power_supply} == False    IS DEVICE BOOTED    ${mode}    ${ivi_adb_id}
    Run Keyword If    ${use_power_supply} == False    Should Be True    ${is_mode}    mode is not ${mode} but ${is_mode}
    SET ROOT

GET IVI
    ${value} =    Get Environment Variable    HTTP_PROXY
    [Return]    ${value}

GET IVC
    ${value} =    Get Environment Variable    UPSTART_JOB
    [Return]    ${value}

GET VNEXT
    ${value} =    Get Environment Variable    XAUTHORITY
    [Return]    ${value}

SETUP POWER SUPPLY
    DO POWER SUPPLY ID    ${pw_config}
    DO POWER SUPPLY RESET    ${pw_config}
    DO POWER SUPPLY CONFIG    ${pw_config}

SET POWER SUPPLY ON
    DO POWER SUPPLY FORCE VOLTAGE    ${pw_config}
    DO POWER SUPPLY ON    ${pw_config}
    Sleep    60
    DO POWER SUPPLY MEASURE CURRENT    ${pw_config}

SET POWER SUPPLY OFF
    DO POWER SUPPLY OFF    ${pw_config}
    Sleep    1
    DO POWER SUPPLY MEASURE CURRENT    ${pw_config}
