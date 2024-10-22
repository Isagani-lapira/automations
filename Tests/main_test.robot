*** Settings ***
Library    SeleniumLibrary
Library   ../Libraries/Users.py
Library    ../Libraries/Utilities.py
Library    ../venv/Lib/site-packages/robot/libraries/Collections.py
Variables     ../Variables/variable.py

Test Setup    Launch Browser   
Suite Teardown     Close Browser


*** Variables ***
${var_name}    Isagani
@{added_list}
@{list_of_user_name}

*** Test Cases ***
Test Case 1
    Process Customers
    User Data
    Is All Created User Are Displayed
    Check All Records


Test Case 2
    Check User With Zero Order

*** Keywords ***
Fetch Data
    ${users}    Get Users Via API
    Set Suite Variable    ${USERS}    ${users}


Input Text
    [Arguments]    ${locator}    ${text}
    SeleniumLibrary.Input Text    ${locator}    ${text}


Launch Browser
    [Arguments]    ${url}=https://marmelab.com/react-admin-demo
    ${options}    Set Variable    add_argument("--start-maximized")
    Open Browser    ${url}    chrome     options=${options}
    Process Authentication And Data Retrieval
    Go To Link    Customers

Process Authentication And Data Retrieval
    Sign In
    Fetch Data

Sign In
    Input Text    name:username    demo
    Input Text    name:password    demo
    Click Button    //button[@type="submit"]


Go To Link
    [Arguments]    ${text}
    Click Element    //a[text()="${text}"]


Add User
    [Arguments]    ${users} 
    ${first_name}   Evaluate     " ".join("${users['name']}".split()[:-1]).strip()
    ${last_name}    Evaluate     " ".join("${users['name']}".split()[-1:]).strip()
    ${generated_pass}    Generate Password
    ${birthdate}    Get Todays Date
    ${state}    Get Random Word
    Input Text    ${identity_txt_first_name}    ${first_name}
    Input Text    ${identity_txt_last_name}   ${last_name}
    Input Text    ${identity_txt_email}    ${users['email']}

    Input Text    ${identity_txt_address}    ${users['address']['suite']}+${users['address']['street']}
    Input Text    ${identity_txt_city}    ${users['address']['city']}    
    Input Text    ${identity_txt_state}    ${state}
    Input Text    ${identity_txt_zipcode}    ${users['address']['zipcode']}
    Input Text    ${identity_txt_password}    ${generated_pass}
    Input Text    ${identity_txt_confirm_password}    ${generated_pass}
    Click Button    //button[@type="submit"]

    Append To List    ${added_list}    ${users['name']}
    Wait Until Element Is Visible    //button[text()="Delete"]
    Go To Link    Customers


Check All Records
    Wait Until Element Is Visible    //tbody//tr[1]
    ${web_element}    Get WebElements    //tbody//tr
    Sleep    6s
    ${len}    Get Length    ${web_element}
    FOR    ${i}    IN RANGE    1   ${len}+1
        ${current_tr}    Set Variable    ((//tbody//tr)[${i}]//td)[2]
        ${tr_text}    Get Text    ${current_tr}
        ${tr_text}    Evaluate    """${tr_text}""".replace("\\n","")[1:] 
       

        ${user_status}    Set Variable
        IF    "${tr_text}" in ${added_list}
            ${user_status}    Set Variable    Newly Created
        ELSE
            ${user_status}    Set Variable    Already Created
        END

        Get Row Data    ${i}    ${user_status}    ${tr_text}
        
    END
    

Get Row Data
    [Arguments]    ${index}    ${user_status}    ${tr_text}
    ${last_seen}    Get Text    ((//tbody//tr)[${index}]//td)[3]
    ${orders}    Get Text    ((//tbody//tr)[${index}]//td)[4]
    ${total_spent}    Get Text    ((//tbody//tr)[${index}]//td)[5]
    ${latest_purchase}    Get Text    ((//tbody//tr)[${index}]//td)[6]
    ${news}    Get Element Attribute    ((//tbody//tr)[${index}]//td)[7]//span//*[name()='svg']    aria-label
    ${segment}    Get Text    ((//tbody//tr)[${index}]//td)[8]
    
    Log To Console    ------------- USER ${index} -------------
    Log To Console    ${user_status}: ${tr_text}
    Log To Console    Last Seen: ${last_seen}
    Log To Console    Order: ${orders}
    Log To Console    Total Spent: ${total_spent}
    Log To Console    Latest Purchase: ${latest_purchase}
    Log To Console    News: ${news}
    Log To Console    Segments: ${segment}
    Log To Console    \n\n\n

Process Customers
    FOR    ${i}    IN    @{USERS}
        Go To Link    Customers
        Go To Link    Create
        Wait Until Element Is Visible    //form//div//div//h6[text()="Identity"]
        Add User    ${i}
    END

Is All Created User Are Displayed
    Wait Element to Load

    ${web_element}    Get WebElements    //tbody//tr
    ${len}    Get Length    ${web_element}
    ${list}    Create List

    FOR    ${i}    IN RANGE    1    ${len}+1
        ${name}    Get Text    ((//tbody//tr)[${i}]//td)[2]
        ${name}    Evaluate    """${name}""".replace("\\n","")[1:]     
        Append To List    ${list}    ${name}
    END

    FOR    ${name}    IN    @{list_of_user_name}
        IF  '${name}' not in ${list}
            Fail   ${name} is not included
        END
    END

    Log To Console    All Users Created are Displayed
User Data
    FOR    ${i}    IN    @{USERS}
        Append To List    ${list_of_user_name}    ${i['name']}
    END


Wait Element to Load
    [Arguments]    ${locator}=//tbody//tr[1]
    Go To Link    Customers
    Wait Until Element Is Visible    ${locator}
    Sleep    6s

Check User With Zero Order
    Wait Element to Load
    ${web_element}    Get WebElements    //tbody//tr
    ${len}    Get Length    ${web_element}
    ${list}    Create List

    FOR    ${i}    IN RANGE    1    ${len}+1
        ${name}    Get Text    ((//tbody//tr)[${i}]//td)[2]
        ${orders}    Get Text    ((//tbody//tr)[${i}]//td)[4]

        IF    '${orders}'=='0'
           ${name}    Evaluate    """${name}""".replace("\\n","")[1:]     
            Append To List    ${list}    ${name} 
        END
    END
    
    ${found_no_orders}    Evaluate    len(${list})
    Log To Console    ${found_no_orders}
    IF    ${found_no_orders}>0
        Log To Console    \n\nUsers with 0 orders found.
        Fail    ${list} 
    END
