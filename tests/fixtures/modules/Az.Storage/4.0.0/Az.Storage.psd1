@{
    RootModule        = 'Az.Storage.psm1'
    ModuleVersion     = '4.0.0'
    GUID              = '4bdc57d9-ef9b-4b99-b181-92c2b06d2128'
    Author            = 'Fixture'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('Get-AzStorageContainer', 'Set-AzStorageBlobContent', 'Get-DeprecatedStorageAccount')
    AliasesToExport   = @('Get-OldAzStorageContainer')
}
