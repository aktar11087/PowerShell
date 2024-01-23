        # Reading API configuration settings from file ##
        - pwsh: |
            $filecontent= Get-Content -Path '$(Build.SourcesDirectory)\Pipeline\Infrastructure\appsettingsAPI.${{parameters.Stage}}.json'
            $json = $filecontent | ConvertFrom-Json 
            $DBConfig = $json | Where-Object name -EQ 'DBConfig' 
            $DBConfig.value = "$(DatabaseConnectionString)"
            $BlobStorageConfig = $json | Where-Object name -EQ 'BlobStorageConfig'
            $BlobStorageConfig.value = "$(BlobConnectionString)"
            $appSettings = @()
            $connectionStrings = @()
            for($i=0; $i -lt $json.Length; $i++){
                Write-Host $json[$i]
                if($json[$i].name -in ('DBConfig', 'BlobStorageConfig'))
                {
                $connectionStrings += $json[$i]
            }

            else {
              $appSettings += $json[$i]
              }
              }
            
            $appSettingsJson = $appSettings | ConvertTo-Json
            $connectionStringJson = $connectionStrings | ConvertTo-Json
            $appSettingsJson = $appSettingsJson -replace "`n","" -replace " ","" -replace "`r",""
            $connectionStringJson = $connectionStringJson -replace "`n","" -replace '(?<=;)\s+',"" -replace "`r",""
            Write-Host "app settings"
            Write-Host "##vso[task.setvariable variable=varappSettingsJSON;]$appSettingsJson"
            Write-Host "connection strings"
            Write-Host "##vso[task.setvariable variable=varConStringJSON;]$connectionStringJson"
          displayName: 'Reading API app setting from file'

        ## Apply app configuration from file
        - task: AzureAppServiceSettings@1
          displayName: 'Azure API App Service Settings'
          inputs:
            azureSubscription: '${{parameters.AzureSubscription}}'
            appName:   '${{parameters.AppServiceName}}'
            resourceGroupName:  '${{parameters.ResourceGroup}}'
            appSettings: |
                  $(varappSettingsJSON)
            connectionStrings: |
                  $(varConStringJSON)

## Another Approch

        # Reading API configuration settings from file ##
        - pwsh: |
              # Define the path to the JSON configuration file
              $jsonFilePath = Get-Content -Path "Pipeline\Infrastructure\appsettingsPSDocumentSubmissionAPI.${{parameters.Stage}}.json"

              # Read JSON file and convert to PowerShell object
              $jsonContent = $jsonFilePath | ConvertFrom-Json 

              # Update Database Connection String
              $dbConfig = $jsonContent | Where-Object { $_.name -eq 'Default' }
              $dbConfig.value = "$(databaseConnectionString)"

              # Separate App Settings and Connection Strings
              $appSettings = $jsonContent | Where-Object { $_.name -notin ('Default') }
              $connectionStrings = $jsonContent | Where-Object { $_.name -in ('Default') }
              
              # Convert Arrays to JSON
              $appSettingsJson = $appSettings | ConvertTo-Json -AsArray
              $connectionStringJson = $connectionStrings | ConvertTo-Json -AsArray

              # Cleanup JSON Strings
              $appSettingsJson = $appSettingsJson -replace "`n|(?<=[;=])\s+|`r",""
              $connectionStringJson = $connectionStringJson -replace "`n|(?<=[;=])\s+|`r",""

              # Set Azure DevOps Pipeline Variables
              Write-Host "App Settings JSON: $appSettingsJson"
              Write-Host "Connection Strings JSON: $connectionStringJson"
              Write-Host "##vso[task.setvariable variable=varappSettingsJSON;]$appSettingsJson"
              Write-Host "##vso[task.setvariable variable=varConStringJSON;]$connectionStringJson"
          displayName: 'Reading API app settings from file'


        # Apply app configuration from file
        - task: AzureAppServiceSettings@1
          displayName: 'Azure API App Service Settings'
          inputs:
            azureSubscription: '${{parameters.AzureSubscription}}'
            appName:   '${{parameters.AppServiceName}}'
            resourceGroupName:  '${{parameters.ResourceGroup}}'
            appSettings: |
                  $(varappSettingsJSON)
            connectionStrings: |
                  $(varConStringJSON)
