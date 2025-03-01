# Description

This PowerShell script connects to Azure, retrieves all routes associated with a specified Front Door endpoint, and filters routes containing specific keywords (func, selfhealer, taf, consumption-updater, invitation). It then displays the matching route names.

# Connect to Azure (if needed)
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

# Set the Azure context (replace with your actual subscription ID)
$subscriptionId = "22811xxxxxxxxx8a92078d2" # Example: "e1xx56-b789-12cd-3dd5-f6789a0b1c2d"
Set-AzContext -SubscriptionId $subscriptionId

# Input parameters

$ResourceGroupName = "s-xxx-xx1-preview"  # Replace with your resource group name
$ProfileName = "s-xxx-xx1-preview"        # Replace with your Front Door profile name
$EndpointName = "s-xx-ek1-preview-hdfzb0b.kk01.azurefd.net"  # Replace with your endpoint name (hostname)

# Get the endpoint
$endpoint = Get-AzFrontDoorCdnEndpoint -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName

# Check if endpoint exists
if ($endpoint -eq $null) {
  Write-Error "Endpoint '$EndpointName' not found"
  return
}

# Get all routes associated with the endpoint
$routes = Get-AzFrontDoorCdnRoute -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName -EndpointName $endpoint.Name

# Filter endpoints that contain "func" in their name
$filterRoutes = $routes | Where-Object { $_ -like "*func*" -or $_ -like "*selfhealer*" -or $_ -like "*taf*" -or $_ -like "*consumption-updater*" -or $_ -like "*invitation*"}


# Display the route names
if ($filterRoutes) {
    Write-Host "`nList of available routes that only have the keyword 'func' in the endpoint '$($endpoint.Name)' within the profile '$ProfileName'`n"
    foreach ($route in $filterRoutes) {  # Iterate through $filterRoutes
        Write-Host $route.Name
    }
} else {
    Write-Host "No routes found for endpoint '$($endpoint.Name)' that contain 'func' in their name."
}
