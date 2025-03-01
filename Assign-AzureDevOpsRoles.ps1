# Parameters (Update these with actual values)
$organizationName = 'unit6-global'                     # Your Azure DevOps organization name
$projectId = '58675174'                                # Replace with actual project ID (GUID)
$personalAccessToken = '4HAAtbKkrAAASAZDOrbfR' | ConvertTo-SecureString -AsPlainText -Force # Your Azure DevOps PAT

# Convert the PAT to a plain text string
$plainTextPAT = (New-Object System.Net.NetworkCredential -ArgumentList " ", $personalAccessToken).Password

# Create the Basic authentication header
$header = @{
    Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($plainTextPAT)"))
}

# Define the list of user GUIDs and environment IDs
$userGuids = @('ec2220-9946c88889e25f', 'ebb20-9946c952f') # Add more user GUIDs as needed
$environmentIds = @('1018', '1064', '2106') # Add more environment IDs as needed

# Loop through each user and environment to assign roles
foreach ($userGuid in $userGuids) {
    foreach ($environmentId in $environmentIds) {

        # Construct the body for the role assignment
        $body = ConvertTo-Json -InputObject @{ userId = $userGuid; roleName = "Administrator" }  # Role: Administrator/User/Reader

        # Construct the URI for the API request
        $uri = "https://dev.azure.com/$organizationName/_apis/securityroles/scopes/distributedtask.environmentreferencerole/roleassignments/resources/$($projectId)_$($environmentId)?api-version=7.2-preview.1"

        # Send the request to assign the role
        try {
            $response = Invoke-RestMethod -UseBasicParsing -Uri $uri -Method "PUT" -Body $body -ContentType application/json -Headers $header
            Write-Host "Role assignment successful for User GUID: $userGuid in Environment: $environmentId. Response: $($response | ConvertTo-Json -Depth 10)"
        }
        catch {
            Write-Host "Error assigning role for User GUID: $userGuid in Environment: $environmentId. Error: $_"
        }
    }
}
