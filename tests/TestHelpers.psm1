function Get-RepositoryRoot {
    [CmdletBinding()]
    param()

    return Split-Path -Parent $PSScriptRoot
}

function Get-ModuleManifestPath {
    [CmdletBinding()]
    param()

    return Join-Path (Get-RepositoryRoot) 'src/PsModuleMigrator/PsModuleMigrator.psd1'
}

        function Import-TestModule {
            [CmdletBinding()]
            param()

            Import-Module (Get-ModuleManifestPath) -Force -Global
        }

function Get-FixturePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    return Join-Path (Join-Path (Get-RepositoryRoot) 'tests/fixtures') $RelativePath
}

function Initialize-FixtureRepository {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RepositoryPath
    )

    if (-not (Test-Path -LiteralPath $RepositoryPath)) {
        throw "Repository fixture path '$RepositoryPath' does not exist."
    }

    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryPath '.git'))) {
        & git -C $RepositoryPath init | Out-Null
        & git -C $RepositoryPath config user.email 'fixture@example.com' | Out-Null
        & git -C $RepositoryPath config user.name 'Fixture User' | Out-Null
    }

    & git -C $RepositoryPath add . | Out-Null
    return $RepositoryPath
}

function New-TemporaryPowerShellFixture {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string[]]$Files
    )

    $root = Join-Path ([System.IO.Path]::GetTempPath()) ("PsModuleMigrator-$Name-$([guid]::NewGuid().ToString('N'))")
    $null = New-Item -ItemType Directory -Path $root -Force
    foreach ($file in $Files) {
        $target = Join-Path $root $file
        $null = New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force
        Set-Content -LiteralPath $target -Value "Get-Date | Out-Null`n" -Encoding utf8
    }

    return $root
}

Export-ModuleMember -Function Get-RepositoryRoot, Get-ModuleManifestPath, Import-TestModule, Get-FixturePath, Initialize-FixtureRepository, New-TemporaryPowerShellFixture
