#
# Copyright (c) 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
# pip install robotframework-jsonlibrary
*** Settings ***
Library           Collections
Library           String
Library           rfw_libraries.ivi.DataTypes

*** Variables ***


***Keywords***
LOAD REF CONFIGURATION
    [Arguments]         ${path_reference_config}
    [Documentation]         Load refernce configuration:
    ...     and load variables from yaml config ref file.
    ...     arg ${path_reference_config}:    path for refrence configuration files.
    ...     type ${path_reference_config}    string
    Set Suite Variable  ${path_reference_config}
    Import Variables    ${path_reference_config}/${config_yaml_ref_file}
    SET REF CONFIGURATION KEYS

GET REF DATABASES
    [Arguments]     ${myfx}
    [Documentation]   Return list of databases names from the reference configuration file.
    ...     arg ${myfx}: structure version of myfx
    
    ${configuration} =   Set Variable   ${structure_myf${myfx}}[databases]
    ${keys_databases} =  Get Dictionary Keys  ${configuration}	
    @{databases} =  Create List
    FOR  ${key}  IN  @{keys_databases}
        ${db} =   Replace String   ${configuration}[${key}][file]   .db   ${EMPTY}
        Append To List  ${databases}   ${db}
    END
    Sort List   ${databases}
    [Return]   ${databases}

GET MYF1 REF DATABASES
    [Documentation]   Return list of databases names in myf1 refernce structure
    ${databases} =   GET REF DATABASES  ${1}
    [Return]   ${databases}

GET MYF2 REF DATABASES
    [Documentation]   Return list of databases names in myf2 refernce structure
    ${databases} =   GET REF DATABASES  ${2}
    [Return]   ${databases}

GET MYF3 REF DATABASES
    [Documentation]   Return list of databases names in myf3 refernce structure
    ${databases} =   GET REF DATABASES  ${3}
    [Return]   ${databases}

SET REF CONFIGURATION KEYS
    [Documentation]     Set Main configuration access keys
    &{myf1_ref_keys} =  Create Dictionary
    &{myf2_ref_keys} =  Create Dictionary
    &{myf3_ref_keys} =  Create Dictionary
    
    
    ${config_01} =   Set Variable   ${structure_myf1}[databases]
    ${config_02} =   Set Variable   ${structure_myf2}[databases]
    ${config_03} =   Set Variable   ${structure_myf3}[databases]

    ${keys_01} =  Get Dictionary Keys  ${config_01}	
    FOR  ${key}  IN  @{keys_01}
        ${db} =   Replace String   ${config_01}[${key}][file]   .db   ${EMPTY}
        Set To Dictionary	${myf1_ref_keys}   ${db}=${key}
    END

    ${keys_02} =  Get Dictionary Keys  ${config_02}	
    FOR  ${key}  IN  @{keys_02}
        ${db} =   Replace String   ${config_02}[${key}][file]   .db   ${EMPTY}
        Set To Dictionary	${myf2_ref_keys}   ${db}=${key}
    END

    ${keys_03} =  Get Dictionary Keys  ${config_03}	
    FOR  ${key}  IN  @{keys_03}
        ${db} =   Replace String   ${config_03}[${key}][file]   .db   ${EMPTY}
        Set To Dictionary	${myf3_ref_keys}   ${db}=${key}
    END

    Set Suite Variable   &{myf1_ref_keys}
    Set Suite Variable   &{myf2_ref_keys}
    Set Suite Variable   &{myf3_ref_keys}
    Log       ${myf1_ref_keys}
    Log       ${myf2_ref_keys}
    Log       ${myf3_ref_keys}

MYF1 GET REF DATABASE VERSION
    [Arguments]     ${database}
    [Documentation]   Return the version of the given database from the reference configuration file.
    ${key} =   Set Variable   ${myf1_ref_keys}[${database}]
    ${version} =   Set Variable  ${structure_myf1}[databases][${key}][version]
    [Return]   ${version}

MYF2 GET REF DATABASE VERSION
    [Arguments]     ${database}
    [Documentation]   Return the version of the given database from the reference configuration file.
    ${key} =   Set Variable   ${myf2_ref_keys}[${database}]
    ${version} =   Set Variable  ${structure_myf2}[databases][${key}][version]
    [Return]   ${version}

MYF3 GET REF DATABASE VERSION
    [Arguments]     ${database}
    [Documentation]   Return the version of the given database from the reference configuration file.
    ${key} =   Set Variable   ${myf3_ref_keys}[${database}]
    ${version} =   Set Variable  ${structure_myf3}[databases][${key}][version]
    [Return]   ${version}

# GET CONFIG 01 REF TABLES


GET MYF1 REF TABLES DATABASE
    [Arguments]     ${database}
    [Documentation]   Return Tables list for the given database.
    ${key} =   Set Variable   ${myf1_ref_keys}[${database}]
    ${tables} =   Get Dictionary Keys  ${structure_myf1}[databases][${key}][tables]     
    [Return]   ${tables}

GET MYF2 REF TABLES DATABASE
    [Arguments]     ${database}
    [Documentation]   Return Tables list for the given database.
    ${key} =   Set Variable   ${myf2_ref_keys}[${database}]
    ${tables} =   Get Dictionary Keys  ${structure_myf2}[databases][${key}][tables]    
    [Return]   ${tables}

GET MYF3 REF TABLES DATABASE
    [Arguments]     ${database}
    [Documentation]   Return Tables list for the given database.
    ${key} =   Set Variable   ${myf3_ref_keys}[${database}]
    ${tables} =   Get Dictionary Keys  ${structure_myf3}[databases][${key}][tables]      
    [Return]   ${tables}


GET MYF1 REF TABLE KEYS
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf1_ref_keys}[${database}]
    ${keys} =   Set Variable  ${structure_myf1}[databases][${key}][tables][${table}][keys]     
    [Return]   ${keys}

GET MYF1 REF TABLE MANDATORY KEYS
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf1_ref_keys}[${database}]
    ${mandatory_keys} =   Set Variable  ${structure_myf1}[databases][${key}][tables][${table}][mandatory_keys]  
    [Return]   ${mandatory_keys}

GET MYF2 REF TABLE KEYS
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf2_ref_keys}[${database}]
    ${keys} =   Set Variable  ${structure_myf2}[databases][${key}][tables][${table}][keys]  
    [Return]   ${keys}

GET MYF2 REF TABLE MANDATORY KEYS
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf2_ref_keys}[${database}]
    ${mandatory_keys} =   Set Variable  ${structure_myf2}[databases][${key}][tables][${table}][mandatory_keys]  
    [Return]   ${mandatory_keys}

GET MYF3 REF TABLE KEYS
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf3_ref_keys}[${database}]
    ${keys} =   Set Variable  ${structure_myf3}[databases][${key}][tables][${table}][keys]  
    [Return]   ${keys}

GET MYF3 REF TABLE MANDATORY KEYS
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf3_ref_keys}[${database}]
    ${mandatory_keys} =   Set Variable  ${structure_myf3}[databases][${key}][tables][${table}][mandatory_keys]  
    [Return]   ${mandatory_keys}

READ JSON FILE DATA
    [Arguments]     ${file_name}
    ${result} =    load_json_data   ${path_reference_config}/${file_name}
    [Return]   ${result}

IS MYF1 DATABASE REF CONTAIN MANDATORY DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf1_ref_keys}[${database}]
    ${file} =   Set Variable  ${structure_myf1}[databases][${key}][tables][${table}][mandatory_meta_data]
    ${verdict} =   Run Keyword And Return Status    Should Not Contain    ${file}  N/A
    [Return]   ${verdict}

IS MYF2 DATABASE REF CONTAIN MANDATORY DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf2_ref_keys}[${database}]
    ${file} =   Set Variable  ${structure_myf2}[databases][${key}][tables][${table}][mandatory_meta_data]
    ${verdict} =   Run Keyword And Return Status    Should Not Contain    ${file}  N/A
    [Return]   ${verdict}

IS MYF3 DATABASE REF CONTAIN MANDATORY DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf3_ref_keys}[${database}]
    ${file} =   Set Variable  ${structure_myf3}[databases][${key}][tables][${table}][mandatory_meta_data]
    ${verdict} =   Run Keyword And Return Status    Should Not Contain    ${file}  N/A
    [Return]   ${verdict}

GET MYF1 REF TABLE MANDATORY DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf1_ref_keys}[${database}]
    ${file} =   Set Variable  ${structure_myf1}[databases][${key}][tables][${table}][mandatory_meta_data]  
    ${data} =    READ JSON FILE DATA   ${file}
    [Return]   ${data}

GET MYF2 REF TABLE MANDATORY DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf2_ref_keys}[${database}]
    ${file} =   Set Variable  ${structure_myf2}[databases][${key}][tables][${table}][mandatory_meta_data]  
    ${data} =    READ JSON FILE DATA   ${file}
    [Return]   ${data}

GET MYF3 REF TABLE MANDATORY DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database based on reference configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${database}: str
    ...     Return List common tables
    ...     return type()   List
    ${key} =   Set Variable   ${myf3_ref_keys}[${database}]
    ${file} =   Set Variable  ${structure_myf3}[databases][${key}][tables][${table}][mandatory_meta_data]  
    ${data} =    READ JSON FILE DATA   ${file}
    [Return]   ${data}
