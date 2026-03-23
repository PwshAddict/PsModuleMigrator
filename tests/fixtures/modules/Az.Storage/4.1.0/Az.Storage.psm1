<#

.SYNOPSIS
Returns a storage container from the test fixture module.

.DESCRIPTION
Implements the fixture version of Get-AzStorageContainer used by tests.


.PARAMETER Name
Optional container name used by the fixture function.


.PARAMETER Context
Required storage context used by the fixture function.


.PARAMETER IncludeDeleted
Includes deleted containers in fixture behavior when specified.

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
Sets blob content in the test fixture module.

.DESCRIPTION
Implements the fixture version of Set-AzStorageBlobContent used by tests.


.PARAMETER File
Path to the source file for fixture blob upload behavior.


.PARAMETER Container
Target container name for fixture blob upload behavior.


.PARAMETER Overwrite
Allows fixture behavior to overwrite existing content.

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
Returns a deprecated storage account from the test fixture module.

.DESCRIPTION
Implements the fixture function used by tests to represent deprecated APIs.


.PARAMETER Name
Storage account name used by the fixture function.

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
