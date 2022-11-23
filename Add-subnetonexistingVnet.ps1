function AddSubnets {

<#
.Synopsis
    The function will check the Subnet and create if it's not found on the existing Virtual Network
.DESCRIPTION
    The function checks the Subnet and creates if it's not found on the existing Virtual Network for app services in VNET Integration
    
    Authors:
    Aktar Hossain
            ## Date: 22.11.2022
            ## Company: XX
            ## Version: 1.0
.EXAMPLE

    > PS> AddSubnets -SubNetName "S-ASG-SUB-010-105-022-128" -SubNetPrefix "10.105.22.128/26"

.NOTES
=================================================
TO DO:
    - Input the mandatory Param
    - Login to Azure Portal       
===============================================
#>

    [CmdletBinding()]
    Param
    (
    [Parameter(Mandatory = $true)][String]$SubNetName,
    [Parameter(Mandatory = $true)][String]$SubNetPrefix
    )

    #Basic Parameter
    $virtualNetworkName = 'S-ASG-VNET-010-105'
    $virtualNetworkResourceGroup = 'S-ASG'
    $routeTable = 'S-ASG-NGF-CLUSTER'
    $virtualNetwork = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $virtualNetworkResourceGroup
    $delegation = New-AzDelegation -Name "Microsoft.Web/serverFarms" -ServiceName "Microsoft.Web/serverFarms"
    $subNetConfig = Get-AzVirtualNetworkSubnetConfig -Name $SubNetName -VirtualNetwork $virtualNetwork
    
    # Looping the Subnet and creating if it's not found on the existing Virtual Network
    if ($null -eq $subNetConfig) {
        $subNetConfig = Add-AzVirtualNetworkSubnetConfig `
            -Name $SubNetName `
            -AddressPrefix $SubNetPrefix `
            -RouteTable $routeTable `
            -Delegation $delegation `
            -VirtualNetwork $virtualNetwork

        $virtualNetwork | Set-AzVirtualNetwork
    }
    else {
        Write-Host "$SubNetName already exists"
    }
}
