# Import necessary modules for Azure Storage and Azure Authentication
Import-Module Az.Storage

# Login to your Azure account if not already logged in
Connect-AzAccount

# Set the context to the specified subscription
Set-AzContext -SubscriptionId "22xxxxxxxxxx8a92078d2"

# Define parameters for the storage account and queue
$resourceGroupName = 's-xxx-ek1'
$storageAccountName = 'sxxxk1'
$queueName = 'flow-history-writer-queue'
$desiredFlowId = 'fe39xxxxxxxfaa7b46b438'

# Retrieve the storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$ctx = $storageAccount.Context

# Create the CloudQueueClient from the connection string
$connectionString = $ctx.ConnectionString
$queueClient = [Microsoft.WindowsAzure.Storage.CloudStorageAccount]::Parse($connectionString).CreateCloudQueueClient()

# Retrieve the queue reference
$queue = $queueClient.GetQueueReference($queueName)

# Ensure the queue exists
if (-not $queue.ExistsAsync().GetAwaiter().GetResult()) {
    Write-Host "Queue not found or not accessible."
    return
}

# Define the invisible timeout (message visibility timeout)
$invisibleTimeOut = [System.TimeSpan]::FromSeconds(10)

# Initialize a counter to keep track of messages with the desired FlowId
$messageCount = 0

# Loop through up to 100,000 iterations
for ($i = 0; $i -lt 100, 000; $i++) {
    try {
        # Fetch the message asynchronously
        $queueMessage = $queue.GetMessageAsync($invisibleTimeOut, $null, $null).GetAwaiter().GetResult()

        # If no message is found, exit the loop
        if ($null -eq $queueMessage) {
            Write-Host "No more messages found in the queue."
            break
        }

        # Convert the message to a string, then parse it as JSON
        $messageContent = $queueMessage.AsString
        $json = $messageContent | ConvertFrom-Json

        # Extract the FlowId from the message
        $flowId = $json.data.FlowId

        # Check if the FlowId matches the desired one
        if ($flowId -eq $desiredFlowId) {
            # Increment the counter if FlowId matches
            $messageCount++
            
            # Print the count of messages with the desired FlowId
            #Write-Host "Total messages with FlowId '$desiredFlowId': $messageCount"
            Write-Host "Total messages with FlowId '$desiredFlowId'- Message ID: $($queueMessage.Id) - MessageCount: $messageCount"
        }
    }
    catch {
        Write-Host "Error retrieving message: $_"
    }
}

Write-Host "Process completed."
