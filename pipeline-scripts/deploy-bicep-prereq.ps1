#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="7.2.0" }

$adminObjectId = '<redacted>'
$azSubscriptionName = 'landing-zone-demo-001'
$azRegion = 'norwayeast'

$splat = @{
    Name                           = "self-hosted-runners-prereq-stack"
    Location                       = $azRegion
    TemplateFile                   = 'src/bicep/prereq.bicep'
    TemplateParameterFile          = 'prereq.bicepparam'
    ActionOnUnmanage               = "DeleteAll" # DeleteAll | DeleteResources | DetachAll
    DenySettingsMode               = "DenyWriteAndDelete" # None | DenyDelete | DenyWriteAndDelete
    DenySettingsApplyToChildScopes = $true
    DenySettingsExcludedPrincipal  = @( $adminObjectId )
}

Select-AzSubscription -Subscription $azSubscriptionName

$stackExists = $null -ne (Get-AzSubscriptionDeploymentStack -Name $splat.Name -ErrorAction SilentlyContinue)
if ($stackExists) {
    Set-AzSubscriptionDeploymentStack @splat
}
else {
    New-AzSubscriptionDeploymentStack @splat
}
