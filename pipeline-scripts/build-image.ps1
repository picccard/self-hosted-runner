$imageName = "ghrunner-linux"
$imageVersion = "v0.1.0"
$registryName = "eulano"
$runnerVersion = "2.317.0" # (Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/actions/runner/releases/latest').tag_name.TrimStart('v')
$platform = "linux"
$dockerfileDir = "./src/image"
$subscription = "landing-zone-demo-001"

az account set --subscription $subscription

az acr build -t "${imageName}:${imageVersion}" -t "${imageName}:latest" --registry $registryName --platform $platform --build-arg RUNNER_VERSION=$runnerVersion $dockerfileDir

# https://github.com/dotnet/sdk/issues/39907

# https://github.com/actions/runner/pkgs/container/actions-runner
# https://github.com/actions/runner/releases
# https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# https://learn.microsoft.com/en-us/azure/container-apps/tutorial-ci-cd-runners-jobs?tabs=azure-powershell&pivots=container-apps-jobs-self-hosted-ci-cd-github-actions
# https://github.com/Azure-Samples/container-apps-ci-cd-runner-tutorial/blob/main/Dockerfile.github

# https://github.com/xmi-cs/aca-gh-actions-runner/blob/main/src/start.sh