
[CmdletBinding()]
param (
    [string]$Subscription = "landing-zone-demo-001",
    [string]$RegistryName = "eulano",
    [ValidateSet(
        "ghrunner-frompwsh-linux",
        "ghrunner-fromghcr-linux"
    )]
    [string]$ImageName = "ghrunner-frompwsh-linux",
    [string]$ImageVersion = "v0.1.0",
    [string]$RunnerVersion = "2.317.0", # (Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/actions/runner/releases/latest').tag_name.TrimStart('v')
    [string]$Platform = "linux",
    [string]$DockerfileDir = "src/images/"
)
$ErrorActionPreference = 'Stop'

$validImageNamesToDockerfile = @{
    "ghrunner-frompwsh-linux" = Join-Path -Path $DockerfileDir -ChildPath "Dockerfile.frompwsh"
    "ghrunner-fromghcr-linux" = Join-Path -Path $DockerfileDir -ChildPath "Dockerfile.fromghcr"
}
$dockerfileName = $validImageNamesToDockerfile[$ImageName]

Write-Debug @"
az acr build -t "${ImageName}:${ImageVersion}" -t "${ImageName}:latest" --registry $RegistryName --Platform $Platform --build-arg RUNNER_VERSION=$RunnerVersion --file $dockerfileName $DockerfileDir
"@

az account set --subscription $Subscription
az acr build -t "${ImageName}:${ImageVersion}" -t "${ImageName}:latest" --registry $RegistryName --platform $Platform --build-arg RUNNER_VERSION=$RunnerVersion --file $dockerfileName $DockerfileDir
