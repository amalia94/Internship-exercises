#
# Copyright (c) 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
#
*** Settings ***
Library           Collections
Library           String
Library           robot.libraries.DateTime
Library           OperatingSystem

*** Keywords ***
LOAD JSON FILE
    [Arguments]    ${file_name}
    [Documentation]    Open the json File and read its contents
    ${final_list} =    Create List
    ${json} =    Get file    ${file_name}    encoding=utf-8-sig
    ${object} =    Evaluate    json.loads('''${json}''')    json
    ${type string}=    Evaluate     type(${object})
    Log To Console     ${type string}
    ${nb} =    GET LENGTH    ${object}
    Log To Console     ${nb}
    FOR    ${var}    IN RANGE    0    ${nb}
        ${trigger_name} =    Run Keyword If    "CM Context" in ${object[${var}]}    Set Variable    "CM Context"
        ...    ELSE IF    "Computation Condition" in ${object[${var}]}    Set Variable    "Computation Condition"
        ...    ELSE IF    "Trigger Condition" in ${object[${var}]}    Set Variable    "Trigger Condition"
        ${trigger_value} =    Run Keyword If    ${trigger_name} == "CM Context" and "${object[${var}][${trigger_name}]}" == "-"
        ...    Set Variable    "Trigger Condition"
        ...    ELSE IF    ${trigger_name} == "CM Context" and "${object[${var}][${trigger_name}]}" != "-"
        ...    Set Variable    "CM Context"
        ...    ELSE   Set Variable    ${trigger_name}
        ${sample_dict} =    Create Dictionary
        Set To Dictionary    ${sample_dict}   trigger    ${object[${var}][${trigger_value}]}
        ...    signal_name    ${object[${var}]["Repository Name(DMF)"]}
        ...    expected_value    ${object[${var}]["Expected results"]}
        Append To List    ${final_list}    ${sample_dict}
    END
    [Return]     ${object}    ${final_list}

WRITE DATA TO JSON
    [Arguments]    ${object}    ${value}    ${var}
    [Documentation]    Open the json File and write its contents
    ${value_updated} =    Replace String    ${value}   "    ${EMPTY}
    #${latest_value} =    Set Variable If    "," in "${value_updated}"   [${value_updated}]    ${value_updated}
    Append Value To Json Object    ${object}    kusto_value    ${value_updated}    ${var}

WRITE DIFFERENCE PERCENTAGE
    [Arguments]    ${object}    ${expected}    ${obtained}    ${var}    ${empty_list}
    [Documentation]    Open the json File and write its contents
    ${set_zero} =    Convert To Number    0
    @{set_list_values} =    Create List
    Insert Into List    ${set_list_values}    0    ${EMPTY}
    Insert Into List    ${set_list_values}    1    N/A
    Insert Into List    ${set_list_values}    2    Not Calculated
    Insert Into List    ${set_list_values}    3    Not calculated
    Insert Into List    ${set_list_values}    4    N/A for C1A_HS
    Insert Into List    ${set_list_values}    5    Not in CAN log
    ${value_expected} =    Run Keyword If    "${expected}[expected_value]" not in ${set_list_values}   Convert To Number    ${expected}[expected_value]
    ...    ELSE    Set Variable    ${set_zero}
    ${value_obtained} =    Replace String    ${obtained}   "    ${EMPTY}
    ${value_obtained} =    Run Keyword If    "${obtained}" != ""    Convert To Number    ${value_obtained}
    ...    ELSE    Set Variable    ${set_zero}
    ${ratio} =    Calculate Accuracy    ${value_expected}    ${value_obtained}
    ${ratio} =    Set Variable If    ${ratio} != None    ${ratio}    ${EMPTY}
    &{expected_data} =    Create Dictionary    trigger=${expected}[trigger]    signal_name=${expected}[signal_name]    ratio=${ratio}   kusto_value=${obtained}
    Append To List    ${empty_list}    ${expected_data}
    Append Value To Json Object    ${object}    accuracy_percentage    ${ratio}    ${var}
    [Return]     ${empty_list}

VALIDATE ACCURACY VALUES
    [Arguments]    ${accuracy_values}
    [Documentation]    Validates the accuracy list should not contain value less than 95
    ${accuracy_list} =     Create List
    &{accuracy_notok} =    Create Dictionary
    ${nb} =    GET LENGTH    ${accuracy_values}
    FOR    ${var}    IN RANGE    0    ${nb}
             IF   "${accuracy_values[${var}]['ratio']}"!=""
                 ${accuracy} =    Convert To Number    ${accuracy_values[${var}]['ratio']}
                 IF   ${accuracy}<95
                     ${accuracy_notok} =    Create Dictionary    trigger=${accuracy_values[${var}]['trigger']}    signal_name=${accuracy_values[${var}]['signal_name']}    ratio=${accuracy_values[${var}]['ratio']}
                     Append To List    ${accuracy_list}    ${accuracy_notok}
                 END
              END
    END
    ${accuracy_len} =    GET LENGTH    ${accuracy_list}
    Run Keyword If    ${accuracy_len}!= 0    Fail   ${accuracy_list}
    [Return]     ${accuracy_notok}

APPEND VALUE TO JSON OBJECT
    [Arguments]    ${filename}    ${key}    ${value_needed}    ${var}
    [Documentation]    Appends the dictionary value to json
    ${file_data} =    Evaluate    json.load(open("${filename}", 'r+'))   json
    Set To Dictionary    ${file_data[${var}]}   ${key}    ${value_needed}
    Evaluate    json.dump(${file_data}, open("${filename}", 'w'), indent=4)

CALCULATE ACCURACY
    [Arguments]    ${expected_value}    ${kusto_value}
    [Documentation]    Validates the accuracy list should not contain value less than 95
    ${value} =    Set Variable If    ${expected_value} == 0 or ${expected_value} == 0.0 or ${kusto_value} == 0 or ${kusto_value} == 0.0
    ...   100.0   None
    Return From Keyword If    ${value} == 100.0
    ${value} =    Evaluate    1 - abs(${expected_value} - ${kusto_value})/max(${expected_value}, ${kusto_value})
    ${value} =    Evaluate    ${value} * 100
    ${value} =    Convert To Number    ${value}    2
    ${value} =    Evaluate    "%.2f" % ${value}
    [Return]    ${value}

CHECK EXPECTED RESULT FORMAT
    [Arguments]    ${expected}
    [Documentation]    Checks the expected result is string or list
    ${str_or_list} =    Set Variable If    "["    IN    ${expected}    list    str
    Return From Keyword If    "${str_or_list}" == "str"
    ${val} =    REPLACE STRING    ${expected}   "["    ${EMPTY}
    ${val} =    REPLACE STRING    ${val}   "]"    ${EMPTY}
    ${val} =    SPLIT STRING    ${val}   ,
    ${val} =    CONVERT TO LIST    ${val}
    Log To Console    ${val}
    [Return]    ${str_or_list}    ${val}
