*** Settings ***
Library    SeleniumLibrary
Library    ../Libraries/Users.py
Library    ../Libraries/Utilities.py
# Library    ../venv/lib/python3.12/site-packages/robot/libraries/XML.py
Library    ../venv/lib/python3.12/site-packages/robot/libraries/Collections.py
Resource    ../Resources/SampleResource.resource
Variables     ../Variables/variable.py

Suite Setup    Launch Browser   
Suite Teardown     Close Browser


*** Variables ***
${var_name}    Isagani
@{added_list}

*** Test Cases ***
My First Test Case
    Sign In
    Fetch Data
    Go To Link    Customers
    FOR    ${i}    IN    @{USERS}
        Go To Link    Customers
        Go To Link    Create
        Wait Until Element Is Visible    //form//div//div//h6[text()="Identity"]
        Add User    ${i}
    END
    Check All Records

    Sleep    5s

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
    Open Browser    ${url}    chrome    remote_url=172.17.0.1:4444    options=${options}

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
    Input Text    ${identity_txt_first_name}    ${first_name}
    Input Text    ${identity_txt_last_name}   ${last_name}
    Input Text    ${identity_txt_email}    ${users['email']}
    # Input Text    ${identity_txt_birthday}    ${birthdate}

    Input Text    ${identity_txt_address}    ${users['address']['suite']}
    Input Text    ${identity_txt_city}    ${users['address']['city']}    
    Input Text    ${identity_txt_state}    ${users['email']}
    Input Text    ${identity_txt_zipcode}    ${users['address']['zipcode']}
    Input Text    ${identity_txt_password}    ${generated_pass}
    Input Text    ${identity_txt_confirm_password}    ${generated_pass}
    Click Button    //button[@type="submit"]

    Append To List    ${added_list}    ${users['name']} 
    Wait Until Element Is Visible    //button[text()="Delete"]
    Go To Link    Customers



# Verify User Creation
#     [Arguments]    ${name}



Check All Records
    Wait Until Element Is Visible    //tbody//tr[1]
    ${web_element}    Get WebElements    //tbody//tr
    ${len}    Get Length    ${web_element}
    FOR    ${i}    IN RANGE    1   ${len}+1
        ${current_tr}    Set Variable    ((//tbody//tr)[${i}]//td)[2]
        ${last_seen}    Get Text    ((//tbody//tr)[${i}]//td)[3]
        ${orders}    Get Text    ((//tbody//tr)[${i}]//td)[4]
        ${total_spent}    Get Text    ((//tbody//tr)[${i}]//td)[5]
        ${latest_purchase}    Get Text    ((//tbody//tr)[${i}]//td)[6]
        ${news}    Get Text    ((//tbody//tr)[${i}]//td)[7]//span//*[name()='svg']    aria-label
        ${segment}    Get Text    ((//tbody//tr)[${i}]//td)[8]
        ${tr_text}    Get Text    ${current_tr}
        ${tr_text}    Evaluate    """${tr_text}""".replace("\\n","")[1:] 
        # ${new_val}    Get Element Attribute    //tbody//tr[2]//td[7]//span//*[name()='svg']   aria-label

        Log To Console    ${news}
        ${user_status}    Set Variable
        IF    "${tr_text}" in ${added_list}
            ${user_status}    Set Variable    Newly Created
        ELSE
            ${user_status}    Set Variable    Already Created
        END
        
        # Log To Console    ------------- USER ${i} -------------
        # Log To Console    ${user_status}: ${tr_text}
        # Log To Console    Last Seen: ${last_seen}
        # Log To Console    Order: ${orders}
        # Log To Console    Total Spent: ${total_spent}
        # Log To Console    Latest Purchase: ${latest_purchase}
        # Log To Console    News: ${news}
        # Log To Console    Segments: ${segment}
        # Log To Console    \n\n\n
    END
    

Get User Data
    [Arguments]    ${users} 
    Log To Console    ${users}