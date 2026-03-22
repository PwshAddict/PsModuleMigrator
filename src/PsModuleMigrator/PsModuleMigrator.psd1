@{
    RootModule           = 'PsModuleMigrator.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'd56ed57a-cd2a-494a-8167-5f7754cb59a8'
    Author               = 'PsModuleMigrator'
    CompanyName          = 'Open Source'
    Copyright            = '(c) PsModuleMigrator'
    PowerShellVersion    = '7.4'
    CompatiblePSEditions = @('Core')
    FunctionsToExport    = @('Find-ModuleUpgradeImpact')
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('PowerShell', 'Migration', 'StaticAnalysis')
            ProjectUri   = 'https://github.com/pwshaddict/PsModuleMigrator'
            LicenseUri   = 'https://github.com/pwshaddict/PsModuleMigrator/blob/main/LICENSE'
            ReleaseNotes = 'Initial implementation for module upgrade impact analysis.'
        }
    }
}
