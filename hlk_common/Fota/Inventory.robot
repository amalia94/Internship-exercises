#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library    rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library    ../fota_libs/libraries/VnextLib.py
Library    ./Utils/Inventory.py

Resource    Campaign.robot
Resource    ../IVI/adb_command.robot

*** Keywords ***
CHECK LOCAL INVENTORY
    [Documentation]    Check the content of local inventory collected by adb devices
    [Arguments]    ${file}

    SET ROOT
    PULL    /fota/inventory/fota_ecu_inv.json    ${EXECDIR}
    File Should Exist    ${EXECDIR}/fota_ecu_inv.json

    @{attribute_list_RDO} =    Create List
    Append To List    ${attribute_list_RDO}    SOFTWARE    CONFIGURATION

    ${verdict}    ${comment}    ${IVI_SW_val} =    CHECK INVENTORY FILE    ${EXECDIR}/fota_ecu_inv.json    RDO    ${attribute_list_RDO}
    Should Be True    ${verdict}    ${comment}
    List Should Not Contain Value    ${IVI_SW_val}    ${EMPTY}    One empty value was reported during inventory!
    Set Test Variable   ${RDO_sw_onboard}    ${IVI_SW_val}[0]
    Set Test Variable   ${RDO_configuration_onboard}    ${IVI_SW_val}[1]

    @{attribute_list_TCU} =    Create List
    Append To List    ${attribute_list_TCU}    SOFTWARE    CONFIGURATION

    ${verdict}    ${comment}    ${IVC_SW_val} =    CHECK INVENTORY FILE    ${EXECDIR}/fota_ecu_inv.json    TCU    ${attribute_list_TCU}
    Should Be True    ${verdict}    ${comment}
    List Should Not Contain Value    ${IVC_SW_val}    ${EMPTY}    One empty value was reported during inventory!
    Set Test Variable   ${TCU_sw_onboard}    ${IVC_SW_val}[0]
    Set Test Variable   ${TCU_configuration_onboard}    ${IVC_SW_val}[1]

    Run Keyword and Ignore Error    Remove File    ${EXECDIR}/fota_ecu_inv.json

GET OFFBOARD HW INVENTORY
    [Documentation]    Extract HW inventory from offboard
    ${campaign_id}=  GET VARIABLE VALUE  ${camp_id}
    ${verdict}  ${message}  ${hw_inv}=  GET INVENTORY  ${vehicle_id}
    SHOULD BE TRUE  ${verdict}  ${message}
    RETURN FROM KEYWORD     ${hw_inv}

CHECK OFFBOARD HW INVENTORY
    ${hw_inv}=  GET OFFBOARD HW INVENTORY

    ${verdict}  ${message}  ${RDO_sw_offboard}=  GET COMPONENT VERSION  ${vehicle_id}    RDO.SOFTWARE
    ${verdict}  ${message}  ${TCU_sw_offboard}=  GET COMPONENT VERSION  ${vehicle_id}    TCU.SOFTWARE
    ${RDO_configuration_offboard}=    GET FROM DICTIONARY  ${hw_inv}  RDO.CONFIGURATION
    Should Contain  ${RDO_configuration_offboard}  ${RDO_configuration_onboard}
    ${TCU_configuration_offboard}=    GET FROM DICTIONARY  ${hw_inv}  TCU.CONFIGURATION
    Should Contain  ${TCU_configuration_offboard}  ${TCU_configuration_onboard}
    Should Contain    ${RDO_sw_offboard}    ${RDO_sw_onboard}    ignore_case=True
    Should Contain    ${TCU_sw_offboard}    ${TCU_sw_onboard}    ignore_case=True

CHECK VALUES
    [Documentation]  Converts both values to lower case and checks they are equal
    [Arguments]  ${first_string}  ${second_string}
    ${first_string}=  CONVERT TO LOWER CASE  ${first_string}
    ${second_string}=  CONVERT TO LOWER CASE  ${second_string}
    SHOULD BE EQUAL  ${first_string}  ${second_string}

ADB RESTART INVENTORY
    [Documentation]  Starts Inventory Routine on IVI
    ${output} =  OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb Routine start 02A4
    Sleep    3
    ${output} =  OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb hardReset
    Sleep    5
