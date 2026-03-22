Import-Module (Join-Path $PSScriptRoot 'TestHelpers.psm1') -Force
Import-TestModule

$config = New-PesterConfiguration
$config.Run.Path = $PSScriptRoot
$config.Run.PassThru = $true
$config.Output.Verbosity = 'Detailed'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = @(
    (Join-Path (Get-RepositoryRoot) 'src/PsModuleMigrator/Public/*.ps1'),
    (Join-Path (Get-RepositoryRoot) 'src/PsModuleMigrator/Private/*.ps1')
)

$result = Invoke-Pester -Configuration $config
if (-not $result) {
    throw 'Invoke-Pester did not return a result object. Ensure pass-through results are enabled.'
}

$coveragePercent = $result.CodeCoverage.CoveragePercent
if ($coveragePercent -lt 90) {
    throw "Coverage below 90%: $coveragePercent"
}

$result
