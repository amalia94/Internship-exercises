*** Settings ***
Library           Collections
Library           OperatingSystem
Library           DateTime
Library            BuiltIn
Library            String


*** Variables ***
${LOG_FILE}       ${CURDIR}/logcat_applications.txt


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
    ${parsed_data}=  Create List
    ${lines}=  Split To Lines  ${log_data}
    FOR  ${single_line}  IN  @{lines}
        Parse Line And Append  ${single_line}  ${parsed_data}
#        ${ignore_main}=  Run Keyword And Return Status  Should Start With  ${single_line}  --------- beginning of main
#        ${ignore_system}=  Run Keyword And Return Status  Should Start With  ${single_line}  --------- beginning of system
#        Run Keyword If  '${ignore_main}' == 'True' or '${ignore_system}' == 'True'  Continue For Loop
#        Run Keyword If  'ActivityTaskManager: START u0' in ${single_line}  Parse Start Line  ${single_line}  ${parsed_data}
#        Run Keyword If  'Layer: Destroyed ActivityRecord' in ${single_line}  Parse End Line  ${single_line}  ${parsed_data}
    END
    RETURN  ${parsed_data}


Parse Line And Append
    [Arguments]  ${line}  ${parsed_data}
#    ${match}=  Get Regexp Matches  ${line}  (?P<package>[\w.]+)/(?P<start_time>\d+\.\d+)
    Run Keyword If    '${line}' Matches Regex    .*((ActivityTaskManager: START u0)|(Layer: Destroyed ActivityRecord)).*    Append To List    ${matched_lines}    ${line}
    ${match}=  Get Regexp Matches  ${line}  (?P<package>[\w.]+)/(?P<start_time>\d+\.\d+)
    ${package}=  Set Variable  ${match}[0][0]
    ${start_time}=  Set Variable  ${match}[0][1]
    Append To List  ${parsed_data}  ${package}  ${start_time}


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


