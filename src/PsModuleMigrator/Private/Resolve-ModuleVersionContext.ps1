function Resolve-ModuleVersionContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter()]
        [string]$TargetVersion
    )

    $resolvedTargetPath = ConvertTo-NormalizedPath -Path $Path
    $availableVersions = [System.Collections.Generic.List[object]]::new()

    $fixtureRoot = Join-Path (Get-PsModuleMigratorRepositoryRoot) 'tests/fixtures/modules'
    $fixtureModuleRoot = Join-Path $fixtureRoot $ModuleName
    if (Test-Path -LiteralPath $fixtureModuleRoot) {
        foreach ($versionDirectory in Get-ChildItem -LiteralPath $fixtureModuleRoot -Directory | Sort-Object Name) {
            $manifestPath = Join-Path $versionDirectory.FullName "$ModuleName.psd1"
            if (-not (Test-Path -LiteralPath $manifestPath)) {
                continue
            }

            try {
                $version = [version]$versionDirectory.Name
            }
            catch {
                continue
            }

            $availableVersions.Add([PSCustomObject]@{
                    Source     = 'Fixture'
                    Version    = $version
                    ModulePath = $manifestPath
                })
        }
    }

    foreach ($installedModule in Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending) {
        $manifestPath = if ($installedModule.Path) { $installedModule.Path } else { Join-Path $installedModule.ModuleBase "$ModuleName.psd1" }
        if (-not (Test-Path -LiteralPath $manifestPath)) {
            continue
        }

        if ($availableVersions.Where({ $_.Version -eq $installedModule.Version }).Count -gt 0) {
            continue
        }

        $availableVersions.Add([PSCustomObject]@{
                Source     = 'Installed'
                Version    = $installedModule.Version
                ModulePath = $manifestPath
            })
    }

    if ($TargetVersion) {
        try {
            $requestedVersion = [version]$TargetVersion
        }
        catch {
            throw (New-PsModuleMigratorException -Message "Target version '$TargetVersion' is not a valid version string for module '$ModuleName'." -ErrorId 'InvalidTargetVersion' -Category 'InvalidArgument')
        }
    }

    if ($availableVersions.Count -eq 0 -and (Get-Command -Name Save-PSResource -ErrorAction Ignore)) {
        $cacheRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'PsModuleMigrator/module-cache'
        $null = New-Item -Path $cacheRoot -ItemType Directory -Force

        try {
            if ($TargetVersion) {
                Save-PSResource -Name $ModuleName -Version $TargetVersion -Path $cacheRoot -TrustRepository -ErrorAction Stop | Out-Null
            }
            else {
                $remoteVersions = Find-PSResource -Name $ModuleName -Type Module -ErrorAction Stop | Sort-Object Version -Descending | Select-Object -First 2
                foreach ($remoteVersion in $remoteVersions) {
                    Save-PSResource -Name $ModuleName -Version $remoteVersion.Version -Path $cacheRoot -TrustRepository -ErrorAction Stop | Out-Null
                }
            }
        }
        catch {
            if ($TargetVersion) {
                throw (New-PsModuleMigratorException -Message "Target version '$TargetVersion' could not be resolved for module '$ModuleName'." -ErrorId 'InvalidTargetVersion' -Category 'InvalidArgument')
            }
        }

        $downloadedModuleRoot = Get-ChildItem -LiteralPath $cacheRoot -Directory -Filter $ModuleName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($downloadedModuleRoot) {
            foreach ($manifestPath in Get-ChildItem -LiteralPath $downloadedModuleRoot.FullName -Filter "$ModuleName.psd1" -Recurse -File) {
                try {
                    $version = [version](Split-Path -Leaf (Split-Path -Parent $manifestPath.FullName))
                }
                catch {
                    continue
                }

                if ($availableVersions.Where({ $_.Version -eq $version }).Count -gt 0) {
                    continue
                }

                $availableVersions.Add([PSCustomObject]@{
                        Source     = 'SavedResource'
                        Version    = $version
                        ModulePath = $manifestPath.FullName
                    })
            }
        }
    }

    if ($availableVersions.Count -eq 0) {
        throw (New-PsModuleMigratorException -Message "Module '$ModuleName' could not be resolved from fixtures, installed modules, or PSResourceGet." -ErrorId 'InvalidModuleName' -Category 'ObjectNotFound')
    }

    $orderedVersions = $availableVersions | Sort-Object Version -Descending
    $targetEntry = if ($TargetVersion) {
        $orderedVersions | Where-Object Version -EQ $requestedVersion | Select-Object -First 1
    }
    else {
        $orderedVersions | Select-Object -First 1
    }

    if (-not $targetEntry) {
        throw (New-PsModuleMigratorException -Message "Target version '$TargetVersion' could not be resolved for module '$ModuleName'." -ErrorId 'InvalidTargetVersion' -Category 'InvalidArgument')
    }

    $baselineEntry = $orderedVersions | Where-Object Version -LT $targetEntry.Version | Select-Object -First 1
    if (-not $baselineEntry) {
        throw (New-PsModuleMigratorException -Message "No analyzable baseline version was found below '$($targetEntry.Version)' for module '$ModuleName'." -ErrorId 'InvalidTargetVersion' -Category 'InvalidArgument')
    }

    [PSCustomObject]@{
        RequestId             = [guid]::NewGuid()
        ModuleName            = $ModuleName
        TargetPath            = $resolvedTargetPath
        RequestedTargetVersion = $TargetVersion
        ResolvedTargetVersion = $targetEntry.Version.ToString()
        BaselineVersion       = $baselineEntry.Version.ToString()
        TargetModulePath      = $targetEntry.ModulePath
        BaselineModulePath    = $baselineEntry.ModulePath
        RequestedAtUtc        = (Get-Date).ToUniversalTime()
    }
}
