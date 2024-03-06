*** Settings ***
Library           Collections
Library           OperatingSystem
Library           DateTime
Library           BuiltIn
Library           String


*** Variables ***
${LOG_FILE}                     ${CURDIR}/logcat_applications.txt
${OUTPUT_FILE}                  ${CURDIR}/../log/logcat_applications_output.yml
${REGEX_ACTIVITY}               .*((ActivityTaskManager: START u0)|(Layer: Destroyed ActivityRecord)).*
${REGEX_TIMESTAMP_PACKAGE}      \\d{2}-\\d{2}\\s\\d{2}:\\d{2}:\\d{2}\\.\\d{3}|com\\.[\\w\\d]+(?:\\.[\\w\\d]+)*
${START_TIMESTAMP_LIST_INDEX}   0
${END_TIMESTAMP_LIST_INDEX}     1
${LIFESPAN_LIST_INDEX}          2
${RESULT_VERDICT_INDEX}         0
${PERCENTAGE_VERDICT_INDEX}     1
${APPS_VERDICT_INDEX}           2
${EMPTY_LIST}

*** Test Cases ***
Test Logcat Analysis
    [Documentation]  Test logcat analysis and verdict
    [Tags]  Logcat
    ${EMPTY_LIST}=              Create List
    ${parsed_data}              Parse Logcat  ${LOG FILE}
    Log                         ${parsed_data}
    Create Log Analysis File    ${parsed_data}    ${OUTPUT_FILE}
    ${verdict}                  Calculate Verdict  ${parsed_data}
    Log                         Verdict: ${verdict}[${RESULT_VERDICT_INDEX}]
    Log                         Percent apps lifespan > 30s: ${verdict}[${PERCENTAGE_VERDICT_INDEX}]
    Log                         Apps with lifespan > 30s: ${verdict}[${APPS_VERDICT_INDEX}:]
    Should Be Equal As Strings  ${verdict}[${RESULT_VERDICT_INDEX}]  PASSED
   # ${message}=    Evaluate    'PASSED: apps lifespan < 30s: %s' % '${verdict}[${PERCENTAGE_VERDICT_INDEX}]' if '${verdict}[${RESULT_VERDICT_INDEX}]' == 'PASSED' else 'FAILED: apps lifespan < 30s: %s' % '${verdict}[${PERCENTAGE_VERDICT_INDEX}]'
   # Run Keyword If    '${verdict}[${RESULT_VERDICT_INDEX}]' == 'PASSED'    Pass Execution    ${message}    ELSE    Fail    ${message}


*** Keywords ***
Parse Logcat
    [Arguments]  ${input_file}
    ${log_file}=            Get File  ${input_file}
    ${lines}=               Get Regexp Matches  ${log_file}  ${REGEX_ACTIVITY}
    ${packages_dict}=       Create Dictionary
    FOR  ${line}  IN  @{lines}
        ${timestamp_package}=   Get Regexp Matches  ${line}  ${REGEX_TIMESTAMP_PACKAGE}
        Append To Dictionary  ${timestamp_package}  ${packages_dict}
    END
    RETURN  ${packages_dict}

Append to Dictionary
    [Arguments]  ${timestamp_package}  ${dictionary}
    ${timestamp}=   Set Variable  ${timestamp_package}[0]
    ${package}=     Set Variable  ${timestamp_package}[1]
    ${value}=       Get From Dictionary    ${dictionary}    ${package}     ${EMPTY_LIST}
    ${length} =     Get Length  ${value}
    IF  ${length} == 0
        ${value}=   Create List    ${timestamp}    0    0
    ELSE
        Set List Value    ${value}    1    ${timestamp}
    END
    ${is_ended}=   Convert To String   ${value}[1]
    IF  $is_ended != '0'
        #Compute time difference
        ${start_datetime}=      Catenate   SEPARATOR=-     2023    ${value}[0]
        ${end_datetime}=        Catenate    SEPARATOR=-     2023    ${value}[1]
        ${start_datetime}=      Convert Date  ${start_datetime}    result_format=%Y-%m-%d %H:%M:%S.%f
        ${end_datetime}=        Convert Date    ${end_datetime}    result_format=%Y-%m-%d %H:%M:%S.%f
        ${time_diff}=           Subtract Date From Date    ${end_datetime}    ${start_datetime}
        Set List Value    ${value}    2    ${time_diff}
    END
    Set To Dictionary    ${dictionary}    ${package}    ${value}

Generate Output
    [Arguments]  ${parsed_data}  ${output_file}
    ${output}=  Create List
    FOR  ${item}  IN  @{parsed_data}
        Append To List  ${output}  ${item['package']}  ${item['start_time']}  ${item['end_time']}  ${item['lifespan']}
    Create File  ${output_file}  ${output}
    END


Calculate Verdict
    [Arguments]  ${apps}
    ${total_apps}=              Get Length  ${apps}
    ${more_than_30_seconds}=    Evaluate    [(key, value[2]) for key, value in ${apps}.items() if value[2] > 30]
    ${percentage}=              Evaluate  (len(${more_than_30_seconds}) / ${total_apps}) * 100
    ${verdict}=                 Run Keyword If  ${percentage} <= 25  Set Variable  PASSED  ELSE  Set Variable  FAILED
    RETURN  ${verdict}  ${percentage}  @{more_than_30_seconds}



Create Log Analysis File
    [Arguments]    ${data}    ${filename}
    ${output}=      Set Variable    applications:\n
    ${dict_len}=    Get Length    ${data}
    ${packages}=    Get Dictionary Keys     ${data}     sort_keys=False
    FOR    ${index}    IN RANGE    ${dict_len}
        ${name}=                Set Variable    ${packages}[${index}]
        ${timestamp_info}=      Get From Dictionary    ${data}    ${name}      ${None}
        ${app_output}=          Set Variable
        ...    - application_${index+1}\n
        ...    ...    - app_path:          ${name}\n
        ...    ...    - ts_app_started:    ${timestamp_info}[${START_TIMESTAMP_LIST_INDEX}]\n
        ...    ...    - ts_app_closed:     ${timestamp_info}[${END_TIMESTAMP_LIST_INDEX}]\n
        ...    ...    - lifespan:          ${timestamp_info}[${LIFESPAN_LIST_INDEX}]\n
        ${output}=    Set Variable    ${output}${app_output}\n
    END
    Create File    ${filename}    ${output}