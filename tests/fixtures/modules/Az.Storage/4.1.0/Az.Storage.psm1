<#
.SYNOPSIS
Provides the PowerShell logic in `tests/fixtures/modules/Az.Storage/4.1.0/Az.Storage.psm1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/fixtures/modules/Az.Storage/4.1.0/Az.Storage.psm1`.
#>


<#

.SYNOPSIS

Gets Az storage container.


.DESCRIPTION

Provides comment-based help for `Get-AzStorageContainer`.


.PARAMETER Name

Specifies the `Name` value.


.PARAMETER Context

Specifies the `Context` value.


.PARAMETER IncludeDeleted

Specifies the `IncludeDeleted` value.

#>


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
<#

.SYNOPSIS

Sets Az storage blob content.


.DESCRIPTION

Provides comment-based help for `Set-AzStorageBlobContent`.


.PARAMETER File

Specifies the `File` value.


.PARAMETER Container

Specifies the `Container` value.


.PARAMETER Overwrite

Specifies the `Overwrite` value.

#>


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
<#

.SYNOPSIS

Gets Deprecated storage account.


.DESCRIPTION

Provides comment-based help for `Get-DeprecatedStorageAccount`.


.PARAMETER Name

Specifies the `Name` value.

#>


function Get-DeprecatedStorageAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
}

Set-Alias -Name Get-OldAzStorageContainer -Value Get-AzStorageContainer
Export-ModuleMember -Function Get-AzStorageContainer, Set-AzStorageBlobContent, Get-DeprecatedStorageAccount -Alias Get-OldAzStorageContainer
