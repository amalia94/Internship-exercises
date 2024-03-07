#
# Copyright (c) 2020, 2021 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#

*** Settings ***
Library           rfw_services.ivi.LemonadLib    device=${ivi_adb_id}
Library           rfw_services.ivi.AndroidDriverLib    device=${ivi_adb_id}
Library           String
Library           robot.libraries.DateTime
Library           rfw_libraries.lemon.LemonAPILibrary.LemonAPILibrary
Library           rfw_services.ivi.SystemLib    device=${ivi_adb_id}
Library           rfw_services.ivi.WaitForAdbDevice

*** Variables ***
${ivi_adb_id}    a27ca66a

*** Keywords ***
CREATE A TOMBSTONE EVENT
    [Arguments]    ${process_name}
    [Documentation]    == High Level Description: ==
    ...    perform a tombstone event by killing an android package
    ...    == Parameters: ==
    ...    - process_name: android package to be killed
    ...    == Expected Results: ==
    ...    output: passed/failed
    CLEAR LOGCAT
    ${pid}     ${stderr} =    GET RUNNING PROCESS    ${process_name}
    should not be empty    ${pid}    Failed to find the process ${process_name}
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell kill -11 ${pid}
    GET CURRENT TIME

CHECK TOMBSTONE EVENT UPDATED TO LEMON
    [Arguments]    ${process_name}
    [Documentation]    == High Level Description: ==
    ...    Validate tombstone event published to lemon server
    ...    == Parameters: ==
    ...    - process_name: android package for which tombstine event was created
    ...    == Expected Results: ==
    ...    output: passed/failed
    ${output} =    CHECK LEMON SERVER EVENT     ${process_name}
    ${raw_response} =     Set Variable      ${output["raw"]}
    ${response} =     Convert To Dictionary     ${raw_response}
    Log To Console      Response of the event ${response}
    should be equal    ${response['data']['message']['event']['data']['process']}    ${process_name}    Process name is not same as ${process_name}
    should be equal    ${response['data']["message"]["event"]["name"]}    tombstone    Event is not tombstone
    ${event_occured} =	robot.libraries.DateTime.Convert Date	${response['data']["timeStamp"]}    result_format=%Y-%m-%dT%H:%M:%SZ    exclude_millis=True
    ${time_diff} =	robot.libraries.DateTime.Subtract Date From Date    ${event_occured}	 ${event_time}
    Should be True    "${time_diff}" <= "5"    Mismatch of timing in lemon server

CHECK LEMON SERVER EVENT
    [Arguments]    ${expected_value}
    [Documentation]    == High Level Description: ==
    ...    Get event details using Lemon API
    ...    == Parameters: ==
    ...    - expected_value: value to verified in response
    ...    == Expected Results: ==
    ...    output: should return event details as response
    FOR    ${i}    IN RANGE    120
        ${result}    ${value} =    Run Keyword And Ignore Error    LEMONAD GET SESSION ID SEQ NB
        Exit For Loop If    "${result}" == "PASS" and "${value}" != "('', '')"
        Sleep    0.1
    END
    Should be Equal    ${result}    PASS    Could not get Session Id for the event
    ${session_id}    ${seq_no} =     Set Variable     ${value}
    Log To Console     ${session_id}
    Should Not Be Empty     ${session_id}
    ${result}    ${value} =    Run Keyword And Ignore Error    GET LEMON EVENT DETAILS    ${session_id}    ${seq_no}
    ${output} =      Evaluate     '${expected_value}' in """${value}"""
    IF    ${output}
        ${verdict}    ${response} =     Set Variable     ${value}
    ELSE
        FOR    ${i}    IN RANGE    200
            ${result}    ${value} =    Run Keyword And Ignore Error    GET LEMON EVENT DETAILS    ${session_id}    ${i}
            ${verdict}    ${response} =     Set Variable     ${value}
            ${output} =      Evaluate     '${expected_value}' in """${response}"""
            Exit For Loop If     "${verdict}" == "${TRUE}" and "${output}" == "${TRUE}"
            Sleep    0.1
        END
    END
    should be true    ${output}    Failed to update event to Lemon server
    Log     ${response}
    [RETURN]    ${response}

GET CURRENT TIME
    [Documentation]    == High Level Description: ==
    ...    Set Current Timestamp
    ...    output: set current time as test variable
    ${event_time} =    robot.libraries.DateTime.Get Current Date    UTC    result_format=%Y-%m-%dT%H:%M:%SZ    exclude_millis=True
    Set Test Variable    ${event_time}

CHECK BOOT EVENT PUBLISHED TO LEMON SERVER
    [Arguments]    ${expectedreason}
    [Documentation]    == High Level Description: ==
    ...    Check for boot event properly published in Lemon
    ...    == Parameters: ==
    ...    - expectedreason: expected boot reason to be verified
    ...    == Expected Results: ==
    ...    output: passed/failed
    GET CURRENT TIME
    ${response} =    CHECK LEMON SERVER EVENT     ${expectedreason}
    Log    ${response}
    should contain    ${response['raw']}    ${expectedreason}    Boot reason is not same as expected reason
    ${event_occured} =    robot.libraries.DateTime.Convert Date    ${response['occurredAt']['value']}    result_format=%Y-%m-%dT%H:%M:%SZ    exclude_millis=True
    ${time_diff} =    robot.libraries.DateTime.Subtract Date From Date    ${event_occured}    ${event_time}
    Should be True    ${time_diff} <= 60.0    Mismatch of timing in lemon server

CREATE KERNEL PANIC EVENT
    [Documentation]    == High Level Description: ==
    ...    Create a kernel panic event in the ivi
    CLEAR LOGCAT
    SYSTEM CRASH
    KILL ADB SERVER
    Sleep    5
    START ADB SERVER

RETRIEVE LEMON EVENT DETAILS
    [Arguments]    ${session_id}    ${seq_no}
    [Documentation]    == High Level Description: ==
    ...    Get event details using Lemon API
    ...    == Expected Results: ==
    ...    output: should return event details as response
    ${result}    ${response} =    GET LEMON EVENT DETAILS    ${session_id}    ${seq_no}
    should be true    ${result}    Failed to update event to Lemon server
    [RETURN]    ${response}

CHECK FOR LEMON SERVER EVENT NOT PUBLISHED
    [Documentation]    == High Level Description: ==
    ...    Check that an event is not published to lemon server
    ...    == Expected Results: ==
    ...    output: passed/failed
    CLEAR LOGCAT
    ${result}    ${value} =    Run Keyword And Ignore Error    LEMONAD GET SESSION ID SEQ NB
    ${verdict} =     Evaluate    "${value}" == "('', '')"
    Should be True     ${verdict}    Lemon event got published
    Should be Equal     ${result}     PASS

DO IVI HARD RESET
    [Documentation]    to send command to IVI and retrieve the results
    OperatingSystem.Run    adb -s ${ivi_adb_id} shell cmd DiagAdb hardReset
