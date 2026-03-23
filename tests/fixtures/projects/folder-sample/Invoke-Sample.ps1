<#
.SYNOPSIS
Provides the PowerShell logic in `tests/fixtures/projects/folder-sample/Invoke-Sample.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/fixtures/projects/folder-sample/Invoke-Sample.ps1`.
#>


Import-Module Az.Storage
Get-AzStorageContainer -Name 'reports'
