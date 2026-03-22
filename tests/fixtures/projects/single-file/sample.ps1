Import-Module Az.Storage
Get-DeprecatedStorageAccount -Name 'legacy'
Get-OldAzStorageContainer -Name 'logs' -IncludeDeleted
Get-AzStorageContainer -Name 'logs' -IncludeDeleted
Get-AzStorageContainer -Name 'archive' -IncludeDeleted
Set-AzStorageBlobContent -File './artifact.zip' -Container 'packages' -Overwrite
