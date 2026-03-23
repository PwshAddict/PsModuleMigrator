<#
.SYNOPSIS
Provides the PowerShell logic in `tests/fixtures/modules/Az.Storage/5.0.0/Az.Storage.psm1`.

.DESCRIPTION
Contains test or fixture PowerShell logic for `tests/fixtures/modules/Az.Storage/5.0.0/Az.Storage.psm1`.
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

#>


function Get-AzStorageContainer {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Context
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

#>


function Set-AzStorageBlobContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$File,

        [Parameter(Mandatory)]
        [string]$Container
    )
}

Export-ModuleMember -Function Get-AzStorageContainer, Set-AzStorageBlobContent
