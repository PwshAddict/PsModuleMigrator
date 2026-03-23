<#

.SYNOPSIS
Returns a storage container from the test fixture module.

.DESCRIPTION
Implements the fixture version of Get-AzStorageContainer used by tests.


.PARAMETER Name
Optional container name used by the fixture function.


.PARAMETER Context
Required storage context used by the fixture function.

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
Sets blob content in the test fixture module.

.DESCRIPTION
Implements the fixture version of Set-AzStorageBlobContent used by tests.


.PARAMETER File
Path to the source file for fixture blob upload behavior.


.PARAMETER Container
Target container name for fixture blob upload behavior.

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
