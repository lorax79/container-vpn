[cmdletbinding()]
param(
    [parameter(Mandatory = $true)]$SubscriptionID,
    $parameterFile = "azuredeploy.parameters.json",
    $deploymentFile = "azuredeploy.json",
    [parameter(Mandatory = $true)]$deploymentRegion
)

#Check PS Version - supports Powershell 6.1
if($PSVersionTable.GitCommitId -lt 6.1.0)
    {
        ThrowError -ExceptionMessage "Please update to the latest version of PowerShell 6 or ensure script was run with pwsh.exe"
    }
else {
    Write-Debug "PSVersion is $($PSVersionTable.PSVersion)"
}
#Check if Azure Modules are installed
if(!(Get-Module -ListAvailable -Name "Az.Accounts"))
    {
        ThrowError -ExceptionMessage "Ensure Azure Modules are Installed.  Try Install-Module -Name Az -scope CurrentUser"
    }
else {
    Write-Debug "Az Accounts module found"
}

Write-Debug -Message "Checking for authenticated session"

$session = Get-AzContext -ea 0
if (!($session)){
    Write-Debug -Message "No Session Found - Logging in"
    Login-AzAccount
    Set-AzContext -Subscription $SubscriptionID
}
elseif ($session.Subscription -ne $subscriptionID) {
    Write-Debug -Message "Setting Subscription Context to $($subscriptionId)"
    Set-AzContext -Subscription $SubscriptionID
}

$templateFileText = [System.IO.File]::ReadAllText($deploymentFile)

$deploymentParams = @{
    Name = "vpnServicesDeployment"
    TemplateObject = (ConvertFrom-JSON $templateFileText -AsHashtable)
    TemplateParameterFile = $parameterFile
    Location = $deploymentRegion
}

New-AzDeployment @deploymentParams