# Define the folder path to search for JavaScript files
$folderPath = "C:\GIt\ors.inposition\Main\Source\InPosition\Scripts\Pos\Mod\Ordering"

# Define the list of parameters to search for
$parameters = @(
    "ALLOW_WEBORDER_ITEM_DELETE",
    "ALLOW_WEBORDER_ITEM_COMMENT",
    "ALLOW_ORDER_ITEM_RESERVATION",
    "ALLOW_WEBORDER",
    "ALLOW_WEBORDER_CHANGE",
    "ALLOW_WEBORDER_RETURN",
    "ALLOW_RETURN_WEBORDER_CHANGE",
    "RETURN_ORDER_ASK_AUTOMATIC_TENDER_ONLY",
    "AUTO_SELECT_QUANTITY_ONE_WEB_ORDER_RETURNS",
    "DISPLAY_ORDER_DETAILS",
    "DISPLAY_WEBORDER_MENUBAR",
    "ORDER_DISPLAY_STATUS_IN_ORDER_SUMMARY",
    "ORDER_DISPLAY_TOTAL_AMOUNT_IN_ORDER_SUMMARY",
    "ENABLE_WEBORDER_RETURN_PRESETTLE",
    "GET_ORDERS_ON_CUSTOMER_REGISTRATION",
    "MAX_WEBORDERS_PER_TICKET"
)

# Initialize an empty dictionary to store the function blocks and function names for each parameter
$parameterFunctionData = @{}

# Recursively search for JavaScript files
$javascriptFiles = Get-ChildItem -Path $folderPath -File -Recurse -Include "*.js"

# Iterate through each JavaScript file
foreach ($file in $javascriptFiles) {
    $fileContent = Get-Content -Path $file.FullName -Raw

    # Search for parameter usage and extract function blocks
    foreach ($param in $parameters) {
        $pattern = [regex]::Escape($param)
        $matches = [regex]::Matches($fileContent, $pattern)

        if ($matches.Count -gt 0) {
            # Extract function blocks and find the largest one
            $functionBlocks = $fileContent -split 'function\s*\(' | Where-Object { $_ -match $pattern }

            # Find the largest function block
            $largestFunctionBlock = $functionBlocks | Sort-Object Length -Descending | Select-Object -First 1

            # Get the function name
            $functionName = $file.Name

            # Store the parameter data
            $parameterData = @{
                "FunctionBlock" = $largestFunctionBlock
                "FunctionName" = $functionName
            }

            # Add or update the data for the parameter
            if ($parameterFunctionData.ContainsKey($param)) {
                $parameterFunctionData[$param] = $parameterData
            } else {
                $parameterFunctionData.Add($param, $parameterData)
            }
        }
    }
}

# Generate a JSON structure with parameter names, function blocks, and function names
$jsonResults = @()
foreach ($param in $parameters) {
    $parameterData = $parameterFunctionData[$param]
    $jsonResult = @{
        "ParameterName" = $param
        "FunctionBlock" = $parameterData["FunctionBlock"]
        "FunctionName" = $parameterData["FunctionName"]
    }
    $jsonResults += $jsonResult
}

# Output the JSON results
$jsonResults | ConvertTo-Json | Out-File -FilePath "output.json"
