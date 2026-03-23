<#
.SYNOPSIS
Provides the PowerShell logic in `tests/fixtures/repositories/sample-repo/src/Invoke-RepoSample.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/fixtures/repositories/sample-repo/src/Invoke-RepoSample.ps1`.
#>


Import-Module Az.Storage
Get-AzStorageContainer -Name 'repo-artifacts'
Get-OldAzStorageContainer -Name 'repo-artifacts' -IncludeDeleted
