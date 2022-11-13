*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc level2.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Robocorp.Vault
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc level2.
    Launch the intranet browser
    Fill the orders from csv file
    create zip file
    [Teardown]    Close Browser


*** Keywords ***
Launch the intranet browser
    ${url}=    Get Secret    url_Level2
    Download    ${url}[csvfileurl]    overwrite=True
    Open Available Browser    ${url}[websiteurl]    maximized=Browser
    Wait Until Page Contains Element    //button[@class="btn btn-dark"]

Fill the form for one person
    [Arguments]    ${csv_row}
    Click Button    //button[@class="btn btn-dark"]
    Wait Until Page Contains Element    //Select[@name="head"]    ${csv_row}[Head]
    Select From List By Value    //Select[@name="head"]    ${csv_row}[Head]
    Click Element    //input[@value="${csv_row}[Body]"]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${csv_row}[Legs]
    Input Text    //input[@placeholder="Shipping address"]    ${csv_row}[Address]
    Click Button    //button[@id="preview"]
    Wait Until Page Contains Element    //div[@id="robot-preview-image"]
    Click Button    //button[@id="order"]
    Wait Until Page Contains Element    //div[@id="receipt"]
    Screenshot    //div[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}${csv_row}[Order number].png
    ${html_attribute}=    Get Element Attribute    //div[@id="receipt"]    outerHTML
    Html To Pdf    ${html_attribute}    ${OUTPUT_DIR}${/}${csv_row}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}${csv_row}[Order number].png
    ...    ${OUTPUT_DIR}${/}${csv_row}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}${csv_row}[Order number].pdf
    Click Button    //button[@id="order-another"]
    Wait Until Page Contains Element    //button[@class="btn btn-dark"]

Fill the orders from csv file
    ${Input_csv_Table}=    Read table from CSV    orders.csv    header=True
    FOR    ${csv_row}    IN    @{Input_csv_Table}
        Fill the form for one person    ${csv_row}
    END

create zip file
    Archive Folder With Zip    ${OUTPUT_DIR}${/}    ${OUTPUT_DIR}${/}Final_Report.zip

Close Browser
    Close Browser
