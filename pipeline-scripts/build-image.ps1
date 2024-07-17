
[CmdletBinding()]
param (
    [string]$Subscription = "landing-zone-demo-001",
    [string]$RegistryName = "eulano",

    [ValidateSet(
        "ghrunner-frompwsh-linux",
        "ghrunner-fromghcr-linux"
    )]
    [string]$ImageName = "ghrunner-frompwsh-linux",
    [string]$RunnerVersion = "2.317.0", # (Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/actions/runner/releases/latest').tag_name.TrimStart('v')
    [string]$Platform = "linux",
    [string]$DockerfileDir = "src/images/",
    [string]$VersionFilePath = "src/images/versions.json",
    [ValidateSet(
        "None",
        "Major",
        "Minor",
        "Patch"
    )]
    [string]$UpdateType = "None"
)
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot/modules/version.psm1" -Force

$validImageNamesToDockerfile = @{
    "ghrunner-frompwsh-linux" = Join-Path -Path $DockerfileDir -ChildPath "Dockerfile.frompwsh"
    "ghrunner-fromghcr-linux" = Join-Path -Path $DockerfileDir -ChildPath "Dockerfile.fromghcr"
}
$dockerfileName = $validImageNamesToDockerfile[$ImageName]


# update image version
$imageVersion = Get-CurrentVersion -ImageName $ImageName -Path $VersionFilePath
$imageVersion = $UpdateType -eq "None" ? $imageVersion : (New-Version -UpdateType $UpdateType -Version $imageVersion)
$null = Set-CurrentVersion -Version $imageVersion -ImageName $ImageName -Path $VersionFilePath


Write-Debug @"
az acr build -t "${ImageName}:v${imageVersion}" -t "${ImageName}:latest" --registry $RegistryName --Platform $Platform --build-arg RUNNER_VERSION=$RunnerVersion --file $dockerfileName $DockerfileDir
"@

az account set --subscription $Subscription
az acr build -t "${ImageName}:v${imageVersion}" -t "${ImageName}:latest" --registry $RegistryName --platform $Platform --build-arg RUNNER_VERSION=$RunnerVersion --file $dockerfileName $DockerfileDir




# https://github.com/dotnet/sdk/issues/39907

# https://github.com/actions/runner/pkgs/container/actions-runner
# https://github.com/actions/runner/releases
# https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=azure-powershell&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions
# https://github.com/Azure-Samples/container-apps-ci-cd-runner-tutorial/blob/main/Dockerfile.github

# https://github.com/xmi-cs/aca-gh-actions-runner/blob/main/src/start.sh