*** Settings ***
Library           OperatingSystem
Library           String

*** Variables ***
${INPUT_FILE}              TC_SWQUAL_CCS2_RELIABILITY_B2B_PA.robot
${INPUT_FILE_PATH}         ${CURDIR}/${INPUT_FILE}
${RESOURCE_FILES_PATH}     ${CURDIR}/../${INPUT_FILE}
${OUTPUT_FILE}             Imposters.robot
${REGEX_SETUP_HKL}         ${CURDIR}/${input_file}


*** Test Cases ***
Test Existence of Setup HKLs in Resources
    [Documentation]  Test Existence of Setup HKLs in Resources
    [Tags]  Hkls
    # Create a dictionary of HKLs found in the setup of TC_SWQUAL_CCS2_RELIABILITY_B2B_PA.robot
    ${parsed_data}         Extract Hkls From Input File  ${LOG FILE}
    #
    ${keyword_content}=    Extract Keyword Content    ${INPUT_FILE_PATH}    SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    Log    ${keyword_content}


*** Keywords ***
Extract Hkls From Input File
    [Arguments]    ${file_path}
    ${file_content}=    Get File    ${file_path}
    # Extract the lines in HLK SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    ${setup_lines}=     Get Regexp Matches  ${file_content}  ${REGEX_ACTIVITY}

    # My next steps:

    # Extract only the HLKs written in uppercase

    # Loop through all of them and insert into a hashset

    # Loop recursively through all files in Resources directory and extract HLKs into a hashset, same as above, get the methods written in uppercase

    # Find what values in set of hlks in setup do not exist in the set of hlks in resources directory

    # Print them to Imposters.robot file following this pattern
    # <name of the missing HLK>
    #    [Arguments]    ${foo}
    #    Keyword not defined, waiting for implementation.


    

Extract Keyword Content
    [Arguments]    ${file_path}    ${keyword}
    ${file_content}=    Get File    ${file_path}
    ${lines}=    Split To Lines    ${file_content}
    ${keyword_content}=    Evaluate    sys.maxsize    sys
    FOR    ${line}    IN    @{lines}
        Run Keyword If    "'${keyword}' in '${line}'"    Set Variable    ${keyword_content}=    ${line}   ${CRLF}   ${keyword_content}
            ELSE IF    ${{keyword_content}}    Set Variable    ${keyword_content}=    ${keyword_content}   ${CRLF}   ${line}
            AND    '${line}' == ''    Exit For Loop
    Log    ${keyword_content}
    [Return]    ${keyword_content}

