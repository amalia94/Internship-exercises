*** Settings ***
Library           Collections
Library           OperatingSystem
Library           DateTime
Library           BuiltIn
Library           String


*** Variables ***
${LOG_FILE}             ${CURDIR}/log_small.txt
${OUTPUT_FILE}             ${CURDIR}/../log/logcat_applications_output.yaml
${REGEX_ACTIVITY}       .*((ActivityTaskManager: START u0)|(Layer: Destroyed ActivityRecord)).*
${REGEX_TIMESTAMP_PACKAGE}   \\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2}\\.\\d{3}|com\\.[\\w\\d]+(?:\\.[\\w\\d]+)*
#${REGEX_DATE_PACKAGE_CLASS}   ((?:\\b\\d{2}-\\d{2}\\s)\\d{2}:\\d{2}:\\d{2}\\.\\d{3})(?=.*((ActivityTaskManager: START u0)|(Layer: Destroyed ActivityRecord)).* )(com\\.[a-zA-Z0-9]+(?:\\.[a-zA-Z0-9]+)*)
${EMPTY_LIST}

*** Variables ***
${text}    03-14 17:56:30.882  5230  5252 I Layer: Destroyed ActivityRecord{d2590bc u0 com.sec.android.app.camera12.log}


*** Test Cases ***
Test Regular Expression Matching
    ${valid_line}=    Get Regexp Matches  ${text}  ${REGEX_ACTIVITY}
#    Run Keyword If  '${valid_line}' == []  Return
#    IF  ${valid_line}==[]
#        RETURN
#    END
    ${matches}=    Get Regexp Matches    ${text}    ${REGEX_TIMESTAMP_PACKAGE}
    Log    Matches: ${matches[0]}
    Log    Matches: ${matches[1]}

Test Logcat Analysis
    [Documentation]  Test logcat analysis and verdict
    [Tags]  Logcat
    ${EMPTY_LIST}=      Create List
    ${parsed_data}  Parse Logcat  ${LOG FILE}
    Log    ${parsed_data}
#    Generate Output  ${parsed_data}  ${OUTPUT_FILE}
    Create YAML    ${parsed_data}    ${OUTPUT_FILE}
    ${verdict}      Calculate Verdict  ${parsed_data}
    Log             Verdict: ${verdict}
    Should Be Equal As Strings  ${verdict}  PASSED


*** Keywords ***

Parse Logcat
    [Arguments]  ${input_file}
    ${log_file}=  Get File  ${input_file}
#    ${matched_list}=  Create List
    ${lines}=  Split To Lines  ${log_file}
    ${packages_dict}=    Create Dictionary
    FOR  ${line}  IN  @{lines}
        ${valid_line}=    Get Regexp Matches  ${line}  ${REGEX_ACTIVITY}
        Run Keyword If  ${valid_line} == []  Continue For Loop
        ${timestamp_package}=   Parse Line  ${line}
        Append To Dictionary  ${timestamp_package}  ${packages_dict}
    END
    Log    ${packages_dict}
#    ${valid_line}=    Get Regexp Matches  ${log_data}  ${REGEX_TIMESTAMP_PACKAGE}
##    FOR  ${single_line}  IN  @{lines}
##        Parse Line And Append  ${single_line}  ${matched_list}
###        ${ignore_main}=  Run Keyword And Return Status  Should Start With  ${single_line}  --------- beginning of main
###        ${ignore_system}=  Run Keyword And Return Status  Should Start With  ${single_line}  --------- beginning of system
###        Run Keyword If  '${ignore_main}' == 'True' or '${ignore_system}' == 'True'  Continue For Loop
###        Run Keyword If  'ActivityTaskManager: START u0' in ${single_line}  Parse Start Line  ${single_line}  ${parsed_data}
###        Run Keyword If  'Layer: Destroyed ActivityRecord' in ${single_line}  Parse End Line  ${single_line}  ${parsed_data}
##    END
    RETURN  ${packages_dict}


Parse Line
    [Arguments]  ${line}
    ${match}=    Get Regexp Matches  ${line}  ${REGEX_TIMESTAMP_PACKAGE}
    ${start_time}=  Set Variable  ${match}[0]
    ${package}=  Set Variable  ${match}[1]
    RETURN  ${match}

Append to Dictionary
    [Arguments]  ${timestamp_package}  ${dictionary}
    ${timestamp}=  Set Variable  ${timestamp_package}[0]
    ${package}=  Set Variable  ${timestamp_package}[1]
    ${value}=    Get From Dictionary    ${dictionary}    ${package}     ${EMPTY_LIST}
    ${length} =  Get Length  ${value}
    IF  ${length} == 0
        ${value}=   Create List    ${timestamp}    0    0
    ELSE
        Set List Value    ${value}    1    ${timestamp}
    END
#    ${value}=    Run Keyword If    ${length} == 0   Create List    ${timestamp}    0    0      ELSE       Set List Value    ${value}    1    ${timestamp}
    Log    ${value}
    ${is_ended}=   Convert To String   ${value}[1]
    IF  $is_ended != '0'
        #Compute time difference
        ${start_datetime}=   Catenate   SEPARATOR=-     2023    ${value}[0]
        ${end_datetime}=    Catenate    SEPARATOR=-     2023    ${value}[1]
        ${start_datetime}=    Convert Date  ${start_datetime}    result_format=%Y-%m-%d %H:%M:%S.%f
        ${end_datetime}=    Convert Date    ${end_datetime}    result_format=%Y-%m-%d %H:%M:%S.%f
        ${time_diff}=    Subtract Date From Date    ${end_datetime}    ${start_datetime}
        Set List Value    ${value}    2    ${time_diff}
    END
    Set To Dictionary    ${dictionary}    ${package}    ${value}

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
#    ${lifespan}=  Evaluate


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


Create YAML
    [Arguments]    ${data}    ${filename}
    ${output}=    Set Variable    applications:\n
    ${index}=    Set Variable    1

    ${application_id}=    Get Length    ${data}
    ${keys}=    Get Dictionary Keys     ${data}     sort_keys=False
    FOR    ${index}    IN RANGE    ${application_id}
        ${app_name}=    Set Variable    ${keys}[${index}]
        ${app_data}=    Get From Dictionary    ${data}    ${app_name}      ${None}

        ${app_output}=    Set Variable
        ...    - application_${index}\n
        ...    - app_path:  ${app_name}\n
        ...    - ts_app_started: ${app_data}[0]\n
        ...    - ts_app_closed:  ${app_data}[1]\n
        ...    - lifespan:  ${app_data}[2]\n
        ${output}=    Set Variable    ${output}${app_output}\n
    END
    Create File    ${filename}    ${output}