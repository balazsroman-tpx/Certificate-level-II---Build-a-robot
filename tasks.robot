*** Settings ***
Documentation       Download CSV file and place robot orders/save confirmations based on that data, then package it as a zip

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault
Library             DateTime
Library             OperatingSystem

Suite Teardown      Close All Browsers


*** Variables ***
${URL_CSV}=             https://robotsparebinindustries.com/orders.csv
# ${URL_Web}=    https://robotsparebinindustries.com/#/robot-order
${DIR_Receipt}          ${OUTPUT_DIR}${/}receipts
${DIR_Screenshot}       ${OUTPUT_DIR}${/}screenshots
${MAX_Retry}            5x
${MIN_Timeout}          1s


*** Tasks ***
Order robots
    [Setup]    Startup    ${DIR_Screenshot}    ${DIR_Receipt}    ${URL_CSV}

    ${URL_Web}=    Get Web URL
    Open Browser for Ordering    ${URL_Web}

    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Close modal
        Add order details    ${order}
        Preview Order
        Take Screenshot of Robot    ${order}[Order number]
        Try to Submit Order
        Generate Receipt PDF    ${order}[Order number]
        Open New Order
        Create final PDF    ${order}[Order number]    ${DIR_Screenshot}    ${DIR_Receipt}
    END

    Create ZIP    ${DIR_Receipt}

    [Teardown]    Close Browser for Ordering


*** Keywords ***
Collect search query from user
    Add text input    URL    label=CSV Location
    ${response}=    Run dialog
    RETURN    ${response.URL}

Create ZIP
    [Arguments]    ${folder}
    ${date}=    Get Current Date    result_format=%Y-%m-%d %H.%M
    Archive Folder With Zip    ${folder}    ${OUTPUT_DIR}${/}${date}.zip

Open Browser for Ordering
    [Arguments]    ${URL}
    Open Available Browser    ${URL}

Close Browser for Ordering
    Close Browser

Download CSV
    [Arguments]    ${URL}
    Download    ${URL}    overwrite=True

Add order details
    [Arguments]    ${order}
    Select From List By Index    head    ${order}[Head]
    Click Element    id:id-body-${order}[Body]
    Input Text    //label[contains(.,'Legs')]/../input    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

Submit Order
    Click Element    id:order
    Wait Until Page Contains Element    id:receipt

Take Screenshot of Robot
    [Arguments]    ${no}
    Wait Until Page Contains Element    id:robot-preview-image
    Sleep    0.5s
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}order${no}.png

Close modal
    Wait And Click Button    css:.btn-dark

Open New Order
    Wait Until Keyword Succeeds    ${MAX_Retry}    ${MIN_Timeout}    Click Element When Visible    id:order-another

Preview Order
    Wait Until Keyword Succeeds    ${MAX_Retry}    ${MIN_Timeout}    Click Button    id:preview

Try to Submit Order
    Wait Until Keyword Succeeds    ${MAX_Retry}    ${MIN_Timeout}    Submit Order

Generate Receipt PDF
    [Arguments]    ${no}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}order${no}.pdf

Create final PDF
    [Arguments]    ${no}    ${DIR_Screenshot}    ${DIR_Receipt}
    Wait Until Keyword Succeeds
    ...    ${MAX_Retry}
    ...    ${MIN_Timeout}
    ...    File Should Exist
    ...    ${DIR_Receipt}${/}order${no}.pdf

    Add Watermark Image To Pdf
    ...    ${DIR_Screenshot}${/}order${no}.png
    ...    ${DIR_Receipt}${/}order${no}.pdf
    ...    ${DIR_Receipt}${/}order${no}.pdf
    Close Pdf

Startup
    [Arguments]    ${DIR_Screenshot}    ${DIR_Receipt}    ${URL_CSV}
    ${screenshot_exists}=    Does Directory Exist    ${DIR_Screenshot}
    IF    ${screenshot_exists} == ${True}
        Remove Directory    ${DIR_Screenshot}    recursive=${True}
    END

    ${receipt_exists}=    Does Directory Exist    ${DIR_Receipt}
    IF    ${receipt_exists} == ${True}
        Remove Directory    ${DIR_Receipt}    recursive=${True}
    END

    ${URL_CSV}=    Collect search query from user
    Download CSV    ${URL_CSV}

Get Web URL
    ${Secret}=    Get Secret    Secret
    RETURN    ${Secret}[URL]
    # Set Global Variable    ${URL_Web}    ${Secret}[URL]
