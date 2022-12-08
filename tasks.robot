*** Settings ***
Documentation       Download CSV file and place robot orders/save confirmations based on that data, then package it as a zip

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.PDF
Library             RPA.Archive
Library             DateTime


*** Variables ***
${CSV_URL}=             https://robotsparebinindustries.com/orders.csv
${Order_URL}=           https://robotsparebinindustries.com/#/robot-order
${Screenshot_DIR}       ${OUTPUT_DIR}${/}screenshots
${Receipt_DIR}          ${OUTPUT_DIR}${/}receipts


*** Tasks ***
Order robots
    [Setup]    Startup    ${Screenshot_DIR}    ${Receipt_DIR}

    Open Browser for Ordering    ${Order_URL}

    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Close modal
        Add order details    ${order}
        Preview Order
        Take Screenshot of Robot    ${order}[Order number]
        Submit Order
        Generate Receipt PDF    ${order}[Order number]
        Open New Order
        Create final PDF    ${order}[Order number]    ${Screenshot_DIR}    ${Receipt_DIR}
    END

    Create ZIP    ${Receipt_DIR}

    [Teardown]    Close Browser for Ordering


*** Keywords ***
Create ZIP
    [Arguments]    ${folder}
    ${date}=    Get Current Date
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

Preview Order
    Wait Until Keyword Succeeds    5x    2s    Click Button    id:preview

Take Screenshot of Robot
    [Arguments]    ${no}
    Wait Until Page Contains Element    id:robot-preview-image
    Sleep    0.5s
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}order${no}.png

Close modal
    Wait And Click Button    css:.btn-dark

Open New Order
    Wait Until Keyword Succeeds    5x    2s    Click Element When Visible    id:order-another

Submit Order
    Click Element    id:order
    Wait Until Keyword Succeeds    5x    2s    Wait Until Page Contains Element    id:receipt

Generate Receipt PDF
    [Arguments]    ${no}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}order${no}.pdf

Create final PDF
    [Arguments]    ${no}    ${screenshot_dir}    ${receipt_dir}
    ${pdf}=    Open Pdf    ${receipt_dir}${/}order${no}.pdf
    Add Watermark Image To Pdf
    ...    ${screenshot_dir}${/}order${no}.png
    ...    ${receipt_dir}${/}order${no}.pdf
    ...    ${receipt_dir}${/}order${no}.pdf
    Close Pdf

Startup
    [Arguments]    ${screenshot_dir}    ${receipt_dir}
    ${screenshot_exists}=    Does Directory Exist    ${screenshot_dir}
    IF    ${screenshot_exists} == ${True}
        Remove Directory    ${screenshot_dir}    recursive=${True}
    END

    ${receipt_exists}=    Does Directory Exist    ${receipt_dir}
    IF    ${receipt_exists} == ${True}
        Remove Directory    ${receipt_dir}    recursive=${True}
    END

    Download CSV    ${CSV_URL}
