#
# Copyright (c) 2022 Renault S.A.S
# Developed by Renault S.A.S and affiliates which hold all
# intellectual property rights. Use of this software is subject
# to a specific license granted by RENAULT S.A.S.
# pip install robotframework-jsonlibrary
*** Settings ***
Library           rfw_libraries.ivi.MyFxMigration   WITH NAME   DB2
Library           Collections
Library           String

*** Variables ***


***Keywords***

LOAD INPUT CONFIGURATION
    [Arguments]             ${path_db1}   ${path_db2}
    [Documentation]         Load databases from the given paths
    ...     arg ${path_db1}:    path for databases list of myfx befor upgrade
    ...     type ${path_db1}    string
    ...     arg ${path_db2}:    path for databases list of myfx after upgrade
    ...     type ${path_db2}    string
    DB2.load_configuration  ${path_db1}   ${path_db2}

GET INPUT DATABASES
    [Arguments]      ${confx}
    [Documentation]     Return the list of databases from the given paths
    ...     while call the `LOAD INPUT CONFIGURATION`  Keyword
    ...     arg ${confx}:   The databses order path_01 or path_02 
    ...     type ${confx}   integer
    ...     Return:         databses list
    ...     return type()   List
    ${databases} =   Run Keyword If   ${confx} == ${1}    myf1_databases
    ...              ELSE IF          ${confx} == ${2}    myf2_databases
    ...              ELSE             Fail     "No Databses configured"
    [Return]         ${databases}

GET INPUT CONFIG_01 DATABASES
    [Documentation]     Return the list of databases in the first path given by
    ...     `LOAD INPUT CONFIGURATION`  Keyword
    ...     Return:         databses list inside config_01
    ...     return type()   List
    ${databases} =    GET INPUT DATABASES   ${1}
    [Return]         ${databases}

GET INPUT CONFIG_02 DATABASES
    [Documentation]     Return the list of databases in the second path given by
    ...     `LOAD INPUT CONFIGURATION`  Keyword
    ...     Return:         databses list inside config_02
    ...     return type()   List
    ${databases} =   GET INPUT DATABASES   ${2}
    [Return]         ${databases}

GET INPUT COMMON DATABASES
    [Documentation]     Get Common DB's between config_01 and config_02
    ${common_dbs} =     DB2.get_common_databases
    [Return]            ${common_dbs}

GET INPUT DIFF DATABASES
    [Documentation]     Get Diff DB's between config_01 and config_02
    ${diffs_dbs} =      DB2.get_diff_databases
    [Return]            ${diffs_dbs}

GET INPUT DATABSE VERSION
    [Arguments]     ${db}  ${confx}
    [Documentation]     Return the version of the database from input paths databases
    ...  ${confx}: config refernce path use with `LOAD INPUT CONFIGURATION`  Keyword
    ...  if ${confx} == 1 , handle first input databases path
    ...  if ${confx} == 2 , handle second input databases path

    ${version} =    DB2.get_database_version   ${db}   ${confx}
    [Return]   ${version}

GET DB VERSION CONFIG 01
    [Arguments]     ${db}
    ${version} =    GET INPUT DATABSE VERSION   ${db}   ${1}
    [Return]   ${version}

GET DB VERSION CONFIG 02
    [Arguments]     ${db}
    ${version} =    GET INPUT DATABSE VERSION   ${db}   ${2}
    [Return]   ${version}

GET INPUT TABLES
    [Arguments]         ${database}  ${confx}
    [Documentation]     return all tables for the given database name and config order
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${confx}: configuration input folder databases
    ...     type ${database}: int
    ...     List common tables
    ...     return type()   List
    ${result} =   DB2.get_tables   ${database}   ${confx}
    [Return]        ${result}

GET INPUT TABLES CONFIG 01
    [Arguments]         ${database}
    [Documentation]     return all tables for the given database name for config 01
    ...      ${database}: database name
    ...     type ${database}: str
    ...     List common tables
    ...     return type()   List

    ${result} =   GET INPUT TABLES   ${database}   ${1}
    [Return]        ${result}

GET INPUT TABLES CONFIG 02
    [Arguments]         ${database}
    [Documentation]     return all tables for the given database name for config 01
    ...      ${database}: database name
    ...     type ${database}: str
    ...     List common tables
    ...     return type()   List

    ${result} =   GET INPUT TABLES   ${database}   ${2}
    [Return]        ${result}

GET INPUT TABLE KEYS
    [Arguments]     ${database}  ${table}  ${confx}
    [Documentation]     return all table keys for the given database and configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${table}: str
    ...      ${confx}: configuration input folder databases
    ...     type ${confx}: int
    ...     Return List common tables
    ...     return type()   List
    ${result} =     DB2.get_keys_in_table   ${database}  ${table}  ${confx}
    [Return]        ${result}


GET INPUT TABLE KEYS CONFIG 01
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database for first configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${table}: str
    ...     Return List common tables
    ...     return type()   List
    ${keys} =     GET INPUT TABLE KEYS  ${database}  ${table}  ${1}
    [Return]        ${keys}

GET INPUT TABLE KEYS CONFIG 02
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database for first configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${table}: str
    ...     Return List common tables
    ...     return type()   List
    ${keys} =     GET INPUT TABLE KEYS  ${database}  ${table}  ${2}
    [Return]        ${keys}


CHECK INPUT TABLE DATA
    [Arguments]     ${database}  ${table}
    [Documentation]     return all table keys for the given database for first configuration
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${table}: str
    ...     Return List common tables
    ...     return type()   List
    ${verdict}  ${result} =   DB2.check_table_data   ${database}  ${table}
    [Return]    ${verdict}  ${result}


GET INPUT TABLE DATABSE DATA
    [Arguments]     ${database}  ${table}  ${confx}  ${rtype}
    [Documentation]     return database data
    ...      ${database}: database name
    ...     type ${database}: str
    ...      ${table}: table name
    ...     type ${table}: str
    ...     ${confx}: configuration input folder databases
    ...     type ${confx}: int
    ...     ${rtype}: return type
    ...     type of ${rtype}: str, Possible value = list or dict
    ...     return table data
    ...     return type()   ${rtype}

    ${data} =   DB2.get_table_data   ${database}  ${table}  ${confx}  cursor_type=${rtype}
    [Return]   ${data}

GET INPUT CONFIG 01 DATABASE TABLE DATA AS LIST
    [Arguments]     ${database}  ${table}
    ${data} =   GET INPUT TABLE DATABSE DATA   ${database}  ${table}  ${1}  list
    [Return]   ${data}

GET INPUT CONFIG 01 DATABASE TABLE DATA AS DICT
    [Arguments]     ${database}  ${table}
    ${data} =   GET INPUT TABLE DATABSE DATA   ${database}  ${table}  ${1}  dict
    [Return]   ${data}

GET INPUT CONFIG 02 DATABASE TABLE DATA AS LIST
    [Arguments]     ${database}  ${table}
    ${data} =   GET INPUT TABLE DATABSE DATA   ${database}  ${table}  ${2}  list
    [Return]   ${data}

GET INPUT CONFIG 02 DATABASE TABLE DATA AS DICT
    [Arguments]     ${database}  ${table}
    ${data} =   GET INPUT TABLE DATABSE DATA   ${database}  ${table}  ${2}  dict
    [Return]   ${data}