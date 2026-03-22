Import-Module Az.Storage
Get-AzStorageContainer -Name 'repo-artifacts'
Get-OldAzStorageContainer -Name 'repo-artifacts' -IncludeDeleted
