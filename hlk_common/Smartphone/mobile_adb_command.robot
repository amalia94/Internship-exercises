#
# Copyright (c) 2020, 2021, 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#

*** Settings ***
Library           Collections
#TODO: Matrix need to create a separate SystemLib for smartphone
#Library           rfw_services.ivi.SystemLib    device=${mobile_adb_id}


*** Variables ***
${console_logs}      yes
${mobile_adb_id}     R58NC1NPL6A

*** Keywords ***
MOBILE_START_INTENT
    [Arguments]    ${app}
    #TODO: Matrix need to create a separate SystemLib for smartphone
#    START INTENT   ${app}
    ${output} =    OperatingSystem.Run    adb -s ${mobile_adb_id} shell am start ${app}
    Sleep    5s

