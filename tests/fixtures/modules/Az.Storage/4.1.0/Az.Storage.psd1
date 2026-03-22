@{
    RootModule        = 'Az.Storage.psm1'
    ModuleVersion     = '4.1.0'
    GUID              = '8799f249-59b0-4dd0-8d9b-a99e1099bd7c'
    Author            = 'Fixture'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('Get-AzStorageContainer', 'Set-AzStorageBlobContent', 'Get-DeprecatedStorageAccount')
    AliasesToExport   = @('Get-OldAzStorageContainer')
}
