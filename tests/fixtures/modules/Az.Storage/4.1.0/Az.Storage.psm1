function Get-AzStorageContainer {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Context,

        [Parameter()]
        [switch]$IncludeDeleted
    )
}

function Set-AzStorageBlobContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$File,

        [Parameter(Mandatory)]
        [string]$Container,

        [Parameter()]
        [switch]$Overwrite
    )
}

function Get-DeprecatedStorageAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
}

Set-Alias -Name Get-OldAzStorageContainer -Value Get-AzStorageContainer
Export-ModuleMember -Function Get-AzStorageContainer, Set-AzStorageBlobContent, Get-DeprecatedStorageAccount -Alias Get-OldAzStorageContainer
