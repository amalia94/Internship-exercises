*** Settings ***
Library           Collections
Library           OperatingSystem
Library           DateTime
Library            BuiltIn
Library            String


*** Variables ***
${LOG_FILE}       ${CURDIR}/logcat_applications.txt
${REGEX_MATCH}    .*((ActivityTaskManager: START u0)|(Layer: Destroyed ActivityRecord)).*
${REGEX_EXTRACT_MATCHED}    (?:\d{2}:\d{2}:\d{2}\.\d{3})|(?:com\.[^\s]+(?<!\.)\b)


*** Test Cases ***
Test Logcat Analysis
    [Documentation]  Test logcat analysis and verdict
    [Tags]  Logcat
    ${parsed_data}  Parse Logcat  ${LOG FILE}
    Generate Output  ${parsed_data}  ${output_file}
    ${verdict}      Calculate Verdict  ${parsed_data}
    Log             Verdict: ${verdict}
    Should Be Equal As Strings  ${verdict}  PASSED


*** Keywords ***

Parse Logcat
    [Arguments]  ${input_file}
    ${log_data}=  Get File  ${input_file}
    ${matched_list}=  Create List
    ${lines}=  Split To Lines  ${log_data}
    FOR  ${single_line}  IN  @{lines}
        Parse Line And Append  ${single_line}  ${matched_list}
#        ${ignore_main}=  Run Keyword And Return Status  Should Start With  ${single_line}  --------- beginning of main
#        ${ignore_system}=  Run Keyword And Return Status  Should Start With  ${single_line}  --------- beginning of system
#        Run Keyword If  '${ignore_main}' == 'True' or '${ignore_system}' == 'True'  Continue For Loop
#        Run Keyword If  'ActivityTaskManager: START u0' in ${single_line}  Parse Start Line  ${single_line}  ${parsed_data}
#        Run Keyword If  'Layer: Destroyed ActivityRecord' in ${single_line}  Parse End Line  ${single_line}  ${parsed_data}
    END
    RETURN  ${matched_list}


Parse Line And Append
    [Arguments]  ${line}  ${matched_list}
    ${valid_line}=    Get Regexp Matches  ${line}  ${REGEX_MATCH}
    ${match}=  Get Regexp Matches  ${line}  ${REGEX_EXTRACT_MATCHED})
#    Run Keyword If    '${line}' Matches Regex    ${MATCH_PATTERN}     Append To List    ${matched_lines}    ${line}
#    ${match}=  Get Regexp Matches  ${line}  (?P<package>[\w.]+)/(?P<start_time>\d+\.\d+)
    ${package}=  Set Variable  ${match}[0][0]
    ${start_time}=  Set Variable  ${match}[0][1]
    Append To List  ${matched_list}  ${package}  ${start_time}

Append Parameters
    [Arguments]    ${parameters}    ${matches}
    FOR    ${match}    IN    @{matches}
        ${timestamp}=    Set Variable    ${match}[1]
        ${package}=    Set Variable    ${match}[2]
        Append To List    ${parameters}    (${timestamp}, ${package})
    END

Parse Start Line
    [Arguments]  ${line}  ${parsed_data}
#    ${match}=  Get Regexp Matches  ${line}  (?P<package>[\w.]+)/(?P<start_time>\d+\.\d+)
    ${match}=  Get Regexp Matches  ${line}  (?P<package>[\w.]+)/(?P<start_time>\d+\.\d+)
    ${package}=  Set Variable  ${match}[0][0]
    ${start_time}=  Set Variable  ${match}[0][1]
    Append To List  ${parsed_data}  ${package}  ${start_time}

Parse End Line
    [Arguments]  ${line}  ${parsed_data}
    ${match}=  Get Regexp Matches  ${line}  (?P<package>[\w.]+)/(?P<end_time>\d+\.\d+)
    ${package}=  Set Variable  ${match}[0][0]
    ${end_time}=  Set Variable  ${match}[0][1]
    FOR  ${index}  ${item}  IN ENUMERATE  ${parsed_data}
        Run Keyword If  '${item}' == ${package}  Set End Time  ${index}  ${end_time}  ${parsed_data}
    END


Set End Time
    [Arguments]  ${index}  ${end_time}  ${parsed_data}
    Set To Dictionary  ${parsed_data}[${index}]  end_time=${end_time}
    ${lifespan}=  Evaluate


Generate Output
    [Arguments]  ${parsed_data}  ${output_file}
    ${output}=  Create List
    FOR  ${item}  IN  @{parsed_data}
        Append To List  ${output}  ${item['package']}  ${item['start_time']}  ${item['end_time']}  ${item['lifespan']}
    Create File  ${output_file}  ${output}
    END


Calculate Verdict
    [Arguments]  ${parsed_data}
    ${total_apps}=  Get Length  ${parsed_data}
    ${less_than_30_seconds}=  Evaluate  len([app for app in ${parsed_data} if app['lifespan'] < 30])
    ${percentage}=  Evaluate  (${less_than_30_seconds} / ${total_apps}) * 100
    ${verdict}=  Run Keyword If  ${percentage} >= 75  Set Variable  PASSED  ELSE  Set Variable  FAILED
    RETURN  ${verdict}


