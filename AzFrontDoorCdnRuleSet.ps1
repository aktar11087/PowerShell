# Input Parameters - Customize these values
$ResourceGroupName = "t-xx-xx1"  # Replace with your resource group name
$ProfileName = "t-xxx-xx1"        # Replace with your Front Door profile name
$EndpointName = "t-xx-ek1-dygdhxxx9gk.k01.azurefd.net"  # Replace with your endpoint name (hostname)
$RouteNames = @("t-xx-ek1-compress-files-function-lab-com", "t-xxx-ek1-email-function-lab-com")  # Replace with the names of your routes
$subscriptionId = "99ada4b6-ss-480b-82f8-099dbcbedcca6"  # Replace with your Subscription ID
$ruleSetName = "SecurityAppend" # The name of the ruleset to add

# Connect to Azure if not already connected
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

# Set the Azure Subscription context
Set-AzContext -SubscriptionId $subscriptionId

# Get the Front Door profile
$frontDoor = Get-AzFrontDoorCdnProfile -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName
if (-not $frontDoor) {
    Write-Error "Front Door profile '$ProfileName' not found in resource group '$ResourceGroupName'."
    return
}

# Get the Rule Set
$ruleSet = Get-AzFrontDoorCdnRuleSet -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName -RuleSetName $ruleSetName
if (-not $ruleSet) {
    Write-Error "Rule set '$ruleSetName' not found in profile '$ProfileName'."
    return
}

# Get the Endpoint
$endpoint = Get-AzFrontDoorCdnEndpoint -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName | Where-Object { $_.HostName -eq $EndpointName }
if (-not $endpoint) {
    Write-Error "Endpoint with hostname '$EndpointName' not found in profile '$ProfileName'."
    return
}

# Store success/failure for summary
$updateResults = @{}
$successfulRoutes = @() # Array to store successfully updated routes

# Iterate through each route and associate the rule set
foreach ($routeName in $RouteNames) {
    # Get the route
    $route = Get-AzFrontDoorCdnRoute -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName -EndpointName $endpoint.Name -RouteName $routeName

    # Check if the route exists before proceeding
    if ($route) {
        # Create a new resource reference object for the Rule Set
        $ruleSetReference = New-Object Microsoft.Azure.PowerShell.Cmdlets.Cdn.Models.Api20210601.ResourceReference
        $ruleSetReference.Id = $ruleSet.Id

        # Update the route using Update-AzFrontDoorCdnRoute with error handling
        try {
            Update-AzFrontDoorCdnRoute -ResourceGroupName $ResourceGroupName -ProfileName $ProfileName -EndpointName $endpoint.Name -RouteName $routeName -RuleSet $ruleSetReference -ErrorAction Stop
            $updateResults[$routeName] = "Success"
            $successfulRoutes += $routeName # Add successful route to array
        } catch {
            Write-Host "Error associating Rule Set '$ruleSetName' with Route '$routeName' on Endpoint '$($endpoint.HostName)' (Profile: '$ProfileName'): $($_.Exception.Message)" -ForegroundColor Red
            $updateResults[$routeName] = "Failed: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Route '$routeName' not found on Endpoint '$($endpoint.HostName)' (Profile: '$ProfileName')." -ForegroundColor Yellow
        $updateResults[$routeName] = "Failed: Route not found"
    }
}

# Print summary with a numbered list of routes in success message and different color
Write-Host "`n" -NoNewline
Write-Host "Summary:" -ForegroundColor Yellow
if ($successfulRoutes.Count -gt 0) {
    Write-Host "Rule Sets '$ruleSetName' has been associated with the following routes on Endpoint '$($endpoint.HostName)' (Profile: '$ProfileName'):" -ForegroundColor Cyan
    Write-Host "Routes:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $successfulRoutes.Count; $i++) {
        Write-Host ($i + 1).ToString()". $($successfulRoutes[$i])" -ForegroundColor Green
    }
}
foreach ($routeName in $RouteNames) {
    if($updateResults[$routeName] -ne "Success"){
        Write-Host "Route '$routeName': $($updateResults[$routeName])" -ForegroundColor Red
    }
}

# Disconnect from Azure
Write-Host "`nDisconnecting from Azure..." -ForegroundColor Green
Disconnect-AzAccount -ErrorAction SilentlyContinue
Write-Host "Disconnected from Azure." -ForegroundColor Yellow
