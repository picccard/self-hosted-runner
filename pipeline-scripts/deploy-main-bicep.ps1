#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="7.2.0" }

param(
    [switch]$AsStack
)

$adminObjectId = '<redacted>'
$azSubscriptionName = 'landing-zone-demo-001'
$azRegion = 'norwayeast'

$splat = @{
    Name                           = "self-hosted-runners-stack"
    Location                       = $azRegion
    TemplateFile                   = 'src/bicep/main.bicep'
    TemplateParameterFile          = 'main.bicepparam'
    ActionOnUnmanage               = "DeleteAll" # DeleteAll | DeleteResources | DetachAll
    DenySettingsMode               = "DenyWriteAndDelete" # None | DenyDelete | DenyWriteAndDelete
    DenySettingsApplyToChildScopes = $true
    DenySettingsExcludedPrincipal  = @( $adminObjectId )
}

Select-AzSubscription -Subscription $azSubscriptionName

if ($AsStack) {
    $stackExists = $null -ne (Get-AzSubscriptionDeploymentStack -Name $splat.Name -ErrorAction SilentlyContinue)
    if ($stackExists) {
        Set-AzSubscriptionDeploymentStack @splat
    }
    else {
        New-AzSubscriptionDeploymentStack @splat
    }
    exit 0
}

$deploySplat = @{
    Name                           = "self-hosted-runners-nonstack-{0}" -f (Get-Date).ToString("yyyyMMdd-HH-mm-ss")
    Location                       = $azRegion
    TemplateFile                   = 'src/bicep/main.bicep'
    TemplateParameterFile          = 'main.bicepparam'
    Verbose                        = $true
}
New-AzSubscriptionDeployment @deploySplat
