*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn


*** Variables ***
${DIR_INPUT_FILE}               ${CURDIR}/ccs2/RELIABILITY/
${INPUT_FILE}                   TC_SWQUAL_CCS2_RELIABILITY_B2B_PA.robot
${OUTPUT_FILE}                  Imposters.robot
${REGEX_SETUP_HLK}              (?m)^SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001.*(?:\\n(?!^[\\w]+\\b).*)*
${REGEX_HLKS_IN_SETUP}          \\b(?![^{}]+})[A-Z]+(?:\\s[A-Z]+)*\\b
# fixed length of whitespaces because variable length positive lookbehind is not supported
${REGEX_RESOURCE_FILES}         (?<=Resource\\s{10})\\S.*
${REGEX_ALL_AFTER_KEYWORDS}     (?<=\\*\\*\\* Keywords \\*\\*\\*\\n)[.|\\n|\\W|\\w]*
${REGEX_HLKS_IN_RESOURCE_FILE}  (?m)^\\w.*[^\\n]$


*** Test Cases ***
Test Existence of Setup HKLs in Resources
    [Documentation]    Test Existence of Setup HKLs in Resources
    [Tags]    Hkls
    ${hlks_not_implemented}=  Extract Hkls From Input File    ${DIR_INPUT_FILE}   ${INPUT_FILE}
    Create Imposters File   ${CURDIR}  ${OUTPUT_FILE}   ${hlks_not_implemented}

*** Keywords ***
Extract Hkls From Input File
    [Arguments]    ${file_dir}  ${file_name}
    ${file_content}=  Get File   ${file_dir}${file_name}
    # Extract the lines in HLK SETUP_TC_SWQUAL_CCS2_RELIABILITY_B2B_PA_001
    ${setup_lines}=   Get Regexp Matches  ${file_content}  ${REGEX_SETUP_HLK}
    # Extract only the HLKs written in uppercase
    ${hlks}=          Get Regexp Matches  ${setup_lines}[0]  ${REGEX_HLKS_IN_SETUP}
    # Loop through all of them and insert into a hashset
    ${hlks_set}=      Evaluate  set(${hlks})
    # Loop recursively through all files in Resources directory and extract HLKs into a hashset
    ${files}=         Get Regexp Matches  ${file_content}  ${REGEX_RESOURCE_FILES}
    FOR    ${file}    IN    @{files}
        ${file_content}=      Get File   ${file_dir}${file}
        # Get Text below *** Keywords *** or find a better regex to combine the next 2 get regexp
        ${hlks_with_impl}=    Get Regexp Matches  ${file_content}   ${REGEX_ALL_AFTER_KEYWORDS}
        # Extract the HLKs in resources, in the list above they all start on column 0 of each line and there are no other methods besides them
        ${file_hlks_list}=    Get Regexp Matches  ${hlks_with_impl}[0]  ${REGEX_HLKS_IN_RESOURCE_FILE}
        # Create a set with unique values found in resource file
        ${hlks_res_set}=      Evaluate   set(${file_hlks_list})
        # Find which elements are not common and update the HLKs that are checked for existence
        ${hlks_set}=          Evaluate   ${hlks_set}.difference(${hlks_res_set})
        # If set difference returned an empty set break because all the HLKs are defined
        ${size}=              Get Length  ${hlks_set}
        Exit For Loop If  ${size} == 0
    END
    RETURN  ${hlks_set}


Create Imposters File
    [Arguments]    ${file_dir}  ${file_name}  ${hlks}
    # Print them to Imposters.robot file following this pattern
    # <name of the missing HLK>
    #    [Arguments]    ${foo}
    #    Keyword not defined, waiting for implementation.
    ${output}=    Set Variable
    FOR    ${hlk}    IN    @{hlks}
        ${hlk_output}=    Catenate
        ...    <${hlk}>\n
        ...    \t[Arguments]    \${foo}\n
        ...    \tKeyword not defined, waiting for implementation.\n
        ${output}=    Set Variable    ${output}${hlk_output}
    END
    Create File    ${file_dir}/${file_name}   ${output}

