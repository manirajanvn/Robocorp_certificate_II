# +
*** Settings ***
Documentation   Order robots from RobotSpareBin Industries Inc.

Library     RPA.Robocloud.Secrets
Library     RPA.Archive
Library     RPA.Browser
Library     RPA.Tables
Library     RPA.HTTP
Library     RPA.PDF
Library     Dialogs

# -


***Variable***
${OUTPUT_PATH}=     ${CURDIR}${/}output${/}
${REPORT_PATH}=     ${OUTPUT_PATH}report${/}

# +
*** Keyword***
Get Input From User
    ${input}=   Get Value From User    Press Y to Start the process    Y
    [return]    ${input}

Open the Intranet Website
    ${urls}=    Get Secret    urls
    Open Available Browser  ${urls}[portal]
    Close the annoying modal

Close the annoying modal
    Wait Until Element Is Visible    css:div.alert-buttons 
    Click Button    css:button.btn.btn-dark

Download CSV File
    ${urls}=    Get Secret    urls
    Download        ${urls}[csv]  overwrite=True

Read CSV File
    ${order_list}=      Read table from CSV    orders.csv
    FOR    ${order_data}    IN    @{order_list}
        Fille The Order Form for Each Data      ${order_data}
    END


Fille The Order Form for Each Data
    [Arguments]     ${order_data}
    Select From List By Value    head   ${order_data}[Head]
    Select Radio Button    body   ${order_data}[Body]
    Input Text     //input[@placeholder="Enter the part number for the legs"]   ${order_data}[Legs]
    Input Text    id:address    ${order_data}[Address]
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Keyword Succeeds    5x    3s    Click Order
    
    ${order_completion_html}=  Get Element Attribute   id:order-completion    outerHTML
    Html To Pdf    ${order_completion_html}    ${REPORT_PATH}${order_data}[Order number].pdf
    Screenshot  id:robot-preview-image  ${OUTPUT_PATH}${order_data}[Order number].png
    Add Watermark Image To Pdf  ${OUTPUT_PATH}${order_data}[Order number].png  ${REPORT_PATH}${order_data}[Order number].pdf  ${REPORT_PATH}${order_data}[Order number].pdf
    Click Button    id:order-another
    Close the annoying modal

Click Order
    Click Button   id:order
    Sleep    2s
    Wait Until Element Is Visible    id:order-completion
    
Zip the Folder
    Archive Folder With Zip    ${REPORT_PATH}    ${OUTPUT_PATH}Report.zip

Close The Browser
    Close Browser
# -

*** Tasks ***
Download and Create Table From the CSV File
    ${input}=   Get Input From User
    IF  "${input}" == "Y"
        Open the Intranet Website
        Download CSV File
        Read CSV File
        Zip the Folder
        Close The Browser
    END
    

