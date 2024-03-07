*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn


*** Variables ***
#${INPUT_FILE}              TC_SWQUAL_CCS2_RELIABILITY_B2B_PA.robot
#${INPUT_FILE_PATH}         ${CURDIR}/${INPUT_FILE}
#${RESOURCE_FILES_PATH}     ${CURDIR}/../${INPUT_FILE}
#${OUTPUT_FILE}             Imposters.robot
${REGEX_SETUP_HKL}         (?m)^SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001.*(?:\\n(?!^[\\w]+\\b).*)*
${REGEX_HLKS_IN_SETUP}      (\\b(?:[^{]\\b[A-Z]+\\b|(?<=\\s))[A-Z]+\\b(?:\\s+(?!.*{)[A-Z]+\\b(?!.*$))*)
${INPUT_FILE}    ${CURDIR}/ccs2/RELIABILITY/TC_SWQUAL_CCS2_RELIABILITY_B2B_PA.robot


*** Test Cases ***
Test Existence of Setup HKLs in Resources
    [Documentation]    Test Existence of Setup HKLs in Resources
    [Tags]    Hkls
    ${hkl_data}=    Extract Hkls From Input File    ${INPUT_FILE}
    Log    @{hkl_data}

*** Keywords ***
Extract Hkls From Input File
    [Arguments]    ${file_path}
    ${file_content}=    Get File    ${file_path}
    # Extract the lines in HLK SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    ${setup_lines}=     Get Regexp Matches  ${file_content}  ${REGEX_SETUP_HKL}
    # My next steps:
    # Extract only the HLKs written in uppercase
    ${extracted_hlks}=  Get Regexp Matches  ${setup_lines}[0]  ${REGEX_HLKS_IN_SETUP}
    # Loop through all of them and insert into a hashset

    # Loop recursively through all files in Resources directory and extract HLKs into a hashset, same as above, get the methods written in uppercase

    # Find what values in set of hlks in setup do not exist in the set of hlks in resources directory

    # Print them to Imposters.robot file following this pattern
    # <name of the missing HLK>
    #    [Arguments]    ${foo}
    #    Keyword not defined, waiting for implementation.

    RETURN  ${setup_lines}



#Extract Keyword Content
#    [Arguments]    ${file_path}    ${keyword}
#    ${file_content}=    Get File    ${file_path}
#    ${lines}=    Split To Lines    ${file_content}
#    ${keyword_content}=    Evaluate    sys.maxsize    sys
#    FOR    ${line}    IN    @{lines}
#        Run Keyword If    "'${keyword}' in '${line}'"    Set Variable    ${keyword_content}=    ${line}   ${CRLF}   ${keyword_content}
#            ELSE IF    ${{keyword_content}}    Set Variable    ${keyword_content}=    ${keyword_content}   ${CRLF}   ${line}
#            AND    '${line}' == ''    Exit For Loop
#    Log    ${keyword_content}
#    [Return]    ${keyword_content}





