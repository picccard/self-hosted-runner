function New-Version {
    param (
        [version]$Version,
        [ValidateSet("Major", "Minor", "Patch")]
        [string]$UpdateType
    )
    $ErrorActionPreference = 'Stop'
    
    $major, $minor, $patch = $Version.ToString().split('.')

    switch ($UpdateType) {
        "Major" {
            $major = [int]$major + 1
            $minor = 0
            $patch = 0
        }
        "Minor" {
            $minor = [int]$minor + 1
            $patch = 0
        }
        "Patch" {
            $patch = [int]$patch + 1
        }
    }

    return [version]::new($major, $minor, $patch)
}

function Get-CurrentVersion {
    param (
        [string]$ImageName,
        [string]$Path
    )
    $ErrorActionPreference = 'Stop'
    
    $versions = Get-Content -Path $Path -Raw | ConvertFrom-Json
    return [version]$versions.$ImageName
}

function Set-CurrentVersion {
    param (
        [version]$Version,
        [string]$ImageName,
        [string]$Path
    )
    $ErrorActionPreference = 'Stop'
    
    Get-Content $Path -Raw | ConvertFrom-Json | ForEach-Object {
        $_.$ImageName = $Version.ToString()
        Set-Content -Path $Path -Value (ConvertTo-Json $_)
        return $_ | Format-List *
    }
    return $null
}