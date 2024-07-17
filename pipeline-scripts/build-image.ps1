param (
    [string]$subscription = "landing-zone-demo-001",
    [string]$registryName = "eulano",
    [string]$imageName = "ghrunner-frompwsh-linux",
    [string]$imageVersion = "v0.1.0",
    [string]$runnerVersion = "2.317.0", # (Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/actions/runner/releases/latest').tag_name.TrimStart('v')
    [string]$platform = "linux",
    [string]$dockerfileDir = "./src/images"
)

$validImageNamesToDockerfile = @{
    "ghrunner-frompwsh-linux" = "Dockerfile.frompwsh"
    "ghrunner-fromghcr-linux" = "Dockerfile.fromghcr"
}

if ($imageName -notin $validImageNamesToDockerfile.Keys) {
    throw [System.ArgumentException]::new("Invalid image name. Valid image names are: $($validImageNamesToDockerfile.Keys -join ', ')")
}
$dockerfileName = $validImageNamesToDockerfile[$imageName]

az account set --subscription $subscription
az acr build -t "${imageName}:${imageVersion}" -t "${imageName}:latest" --registry $registryName --platform $platform --build-arg RUNNER_VERSION=$runnerVersion --file $dockerfileName $dockerfileDir

# https://github.com/dotnet/sdk/issues/39907

# https://github.com/actions/runner/pkgs/container/actions-runner
# https://github.com/actions/runner/releases
# https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=azure-powershell&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions
# https://github.com/Azure-Samples/container-apps-ci-cd-runner-tutorial/blob/main/Dockerfile.github

# https://github.com/xmi-cs/aca-gh-actions-runner/blob/main/src/start.sh