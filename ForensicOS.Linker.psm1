function New-ChocolateyPackageToolsLink {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$PackageRootPath,

        [ValidateNotNullOrEmpty()]
        [string]$ChocolateyBasePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [ValidateNotNullOrEmpty()]
        [string]$CustomPath = 'C:\tools',

        [ValidateSet('Junction', 'SymbolicLink')]
        [string]$LinkType = 'Junction',

        [switch]$Force,

        [switch]$PassThru
    )

    if (-not [string]::IsNullOrWhiteSpace($PackageRootPath)) {
        $resolvedPackageRootPath = $PackageRootPath
    }
    else {
        if ([string]::IsNullOrWhiteSpace($ChocolateyBasePath)) {
            $ChocolateyBasePath = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Process')
        }

        if ([string]::IsNullOrWhiteSpace($ChocolateyBasePath)) {
            $ChocolateyBasePath = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
        }

        if ([string]::IsNullOrWhiteSpace($ChocolateyBasePath)) {
            throw 'No Chocolatey path input provided and no ChocolateyInstall environment variable found.'
        }

        $resolvedPackageRootPath = Join-Path -Path $ChocolateyBasePath -ChildPath 'lib'
    }

    if (-not (Test-Path -Path $resolvedPackageRootPath -PathType Container)) {
        throw "Chocolatey package root path not found: $resolvedPackageRootPath"
    }

    $packagePath = Join-Path -Path $resolvedPackageRootPath -ChildPath $PackageName
    if (-not (Test-Path -Path $packagePath -PathType Container)) {
        throw "Chocolatey package folder not found: $packagePath"
    }

    $toolsPath = Join-Path -Path $packagePath -ChildPath 'tools'
    if (-not (Test-Path -Path $toolsPath -PathType Container)) {
        Write-Warning "No tools folder found for package '$PackageName' at: $packagePath"
        return $null
    }

    if (-not (Test-Path -Path $CustomPath -PathType Container)) {
        Write-Error "CustomPath does not exist: $CustomPath"
        return $null
    }

    $linkPath = Join-Path -Path $CustomPath -ChildPath $PackageName

    if (Test-Path -Path $linkPath) {
        $existingItem = Get-Item -Path $linkPath -Force

        if ($existingItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            if (-not $Force) {
                throw "Link already exists at '$linkPath'. Use -Force to replace it."
            }

            Remove-Item -Path $linkPath -Force
        }
        else {
            throw "Path already exists and is not a link: $linkPath"
        }
    }

    $newItem = New-Item -Path $linkPath -ItemType $LinkType -Target $toolsPath

    if ($PassThru) {
        return $newItem
    }
}

function New-ChocolateyAllPackageToolsLinks {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$PackageRootPath,

        [ValidateNotNullOrEmpty()]
        [string]$ChocolateyBasePath,

        [ValidateNotNullOrEmpty()]
        [string]$CustomPath = 'C:\tools',

        [ValidateSet('Junction', 'SymbolicLink')]
        [string]$LinkType = 'Junction',

        [switch]$Force,

        [switch]$PassThru
    )

    if (-not [string]::IsNullOrWhiteSpace($PackageRootPath)) {
        $resolvedPackageRootPath = $PackageRootPath
    }
    else {
        if ([string]::IsNullOrWhiteSpace($ChocolateyBasePath)) {
            $ChocolateyBasePath = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Process')
        }

        if ([string]::IsNullOrWhiteSpace($ChocolateyBasePath)) {
            $ChocolateyBasePath = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
        }

        if ([string]::IsNullOrWhiteSpace($ChocolateyBasePath)) {
            throw 'No Chocolatey path input provided and no ChocolateyInstall environment variable found.'
        }

        $resolvedPackageRootPath = Join-Path -Path $ChocolateyBasePath -ChildPath 'lib'
    }

    if (-not (Test-Path -Path $resolvedPackageRootPath -PathType Container)) {
        throw "Chocolatey package root path not found: $resolvedPackageRootPath"
    }

    $packageFolders = Get-ChildItem -Path $resolvedPackageRootPath -Directory -ErrorAction Stop | Sort-Object Name
    $results = @()

    foreach ($pkg in $packageFolders) {
        try {
            $result = New-ChocolateyPackageToolsLink -PackageRootPath $resolvedPackageRootPath -PackageName $pkg.Name -CustomPath $CustomPath -LinkType $LinkType -Force:$Force -PassThru:$PassThru
            if ($PassThru -and $null -ne $result) {
                $results += $result
            }
        }
        catch {
            Write-Error "Failed to create link for package '$($pkg.Name)': $($_.Exception.Message)"
        }
    }

    if ($PassThru) {
        return $results
    }
}

Export-ModuleMember -Function New-ChocolateyPackageToolsLink, New-ChocolateyAllPackageToolsLinks
