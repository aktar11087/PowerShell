function Set-AllowFromVnet {

<#
.Synopsis
    The function check and automatically update inbound traffic allow rules for app services based on OutboundIpAddresses in VNET Integration
.DESCRIPTION
    This function will update inbound traffic allow rules for app services based on OutboundIpAddresses in VNET Integration
    
    Authors:
    Aktar Hossain
            ## Date: 17.10.2022
            ## Company: XX
            ## Version: 1.0
.EXAMPLE

    > Example of how to use this cmdlet

.NOTES
=================================================
TO DO:        
===============================================
#>

    [CmdletBinding()]
    Param
    (
    [Parameter(Mandatory = $true)][Int]$Priority,
    [Parameter(Mandatory = $true)][String]$SOURCERG_NAME,
    [Parameter(Mandatory = $true)][String]$SOURCEWebApp_NAME,
    [Parameter(Mandatory = $true)][String]$TARGETRG_NAME,
    [Parameter(Mandatory = $true)][String]$TARGETWebAPP_NAME,
    [Parameter(Mandatory = $true)][String]$RuleName
    )

    #Basic Parameter
    $IP_ADDR = (Get-AzWebApp -ResourceGroup $SOURCERG_NAME -name $SOURCEWebApp_NAME).PossibleOutboundIpAddresses
    $IP_ADDR = $IP_ADDR.Split(',')
    
    # Looping the IP and increasing the counter and append with /32
    for ($i=0;$i -lt $IP_ADDR.Length; $i+4){
    $IP_RANGE = $IP_ADDR[$i]+"/32"
    $Priority += 100

    
    Write-Host "Adding $IP_RANGE with $Priority"

    #Adding Allow Rules
    Add-AzWebAppAccessRestrictionRule -ResourceGroupName $TARGETRG_NAME -WebAppName $TARGETWebApp_NAME -Name $RuleName -Priority $Priority -Action Allow -IpAddress $IP_RANGE 
    }
}
