<#
.SYNOPSIS
Provides the PowerShell logic in `tests/fixtures/projects/single-file/sample.ps1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/fixtures/projects/single-file/sample.ps1`.
#>


Import-Module Az.Storage
Get-DeprecatedStorageAccount -Name 'legacy'
Get-OldAzStorageContainer -Name 'logs' -IncludeDeleted
Get-AzStorageContainer -Name 'logs' -IncludeDeleted
Get-AzStorageContainer -Name 'archive' -IncludeDeleted
Set-AzStorageBlobContent -File './artifact.zip' -Container 'packages' -Overwrite
