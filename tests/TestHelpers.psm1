<#

.SYNOPSIS
Returns the repository root path.

.DESCRIPTION
Resolves the repository root relative to the tests directory.

#>


function Get-RepositoryRoot {
    [CmdletBinding()]
    param()

    return Split-Path -Parent $PSScriptRoot
}
<#

.SYNOPSIS
Returns the module manifest path.

.DESCRIPTION
Builds the absolute path to the PsModuleMigrator module manifest.

#>


function Get-ModuleManifestPath {
    [CmdletBinding()]
    param()

    return Join-Path (Get-RepositoryRoot) 'src/PsModuleMigrator/PsModuleMigrator.psd1'
}
<#

.SYNOPSIS
Imports the module under test.

.DESCRIPTION
Imports PsModuleMigrator from the manifest path into the global scope for tests.

#>


function Import-TestModule {
    [CmdletBinding()]
    param()

    Import-Module (Get-ModuleManifestPath) -Force -Global
}
<#

.SYNOPSIS
Returns a fixture path under tests/fixtures.

.DESCRIPTION
Combines the repository root and a relative fixture path.


.PARAMETER RelativePath
Relative path under tests/fixtures.

#>


function Get-FixturePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    return Join-Path (Join-Path (Get-RepositoryRoot) 'tests/fixtures') $RelativePath
}
<#

.SYNOPSIS
Initializes a git repository fixture.

.DESCRIPTION
Ensures the fixture path exists, initializes git if needed, and stages all files.


.PARAMETER RepositoryPath
Path to a fixture repository directory.

#>


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
<#

.SYNOPSIS
Creates a temporary PowerShell fixture directory.

.DESCRIPTION
Creates a temporary directory and writes the requested fixture files.


.PARAMETER Name
Name component used in the temporary directory path.


.PARAMETER Files
List of relative file paths to create in the fixture.

#>


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
