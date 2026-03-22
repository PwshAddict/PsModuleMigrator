function Get-AnalysisTargetFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    function Get-PowerShellFiles {
        param([Parameter(Mandatory)][string]$RootPath)

        $extensions = @('.ps1', '.psm1', '.psd1')
        return @(Get-ChildItem -LiteralPath $RootPath -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $extensions -contains $_.Extension } |
            Select-Object -ExpandProperty FullName)
    }

    try {
        $resolvedPath = ConvertTo-NormalizedPath -Path $Path
    }
    catch {
        throw (New-PsModuleMigratorException -Message "Analysis target path '$Path' does not exist or cannot be read." -ErrorId 'InvalidTargetPath' -Category 'InvalidArgument')
    }

    $warnings = [System.Collections.Generic.List[string]]::new()
    $result = [ordered]@{
        TargetKind = $null
        TargetPath = $resolvedPath
        FilePaths  = @()
        Warnings   = @()
    }

    if (Test-Path -LiteralPath $resolvedPath -PathType Leaf) {
        if ([System.IO.Path]::GetExtension($resolvedPath) -notin @('.ps1', '.psm1', '.psd1')) {
            throw (New-PsModuleMigratorException -Message "Analysis target file '$resolvedPath' must be a .ps1, .psm1, or .psd1 file." -ErrorId 'InvalidTargetPath' -Category 'InvalidArgument')
        }

        $result.TargetKind = 'File'
        $result.FilePaths = @($resolvedPath)
        return [PSCustomObject]$result
    }

    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Container)) {
        throw (New-PsModuleMigratorException -Message "Analysis target path '$resolvedPath' is not a file or directory." -ErrorId 'InvalidTargetPath' -Category 'InvalidArgument')
    }

    $gitDirectory = Join-Path $resolvedPath '.git'
    if (Test-Path -LiteralPath $gitDirectory) {
        $result.TargetKind = 'Repository'

        $gitOutput = & git -C $resolvedPath ls-files -- '*.ps1' '*.psm1' '*.psd1' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $filePaths = foreach ($relativePath in $gitOutput) {
                if ([string]::IsNullOrWhiteSpace($relativePath)) {
                    continue
                }

                $fullPath = Join-Path $resolvedPath $relativePath.Trim()
                if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
                    (Get-Item -LiteralPath $fullPath).FullName
                }
            }

            $result.FilePaths = @($filePaths | Sort-Object -Unique)
        }
        else {
            $warnings.Add("git ls-files failed for '$resolvedPath'; falling back to recursive PowerShell file discovery.")
            $result.FilePaths = @(Get-PowerShellFiles -RootPath $resolvedPath | Sort-Object -Unique)
        }
    }
    else {
        $result.TargetKind = 'Folder'
        $result.FilePaths = @(Get-PowerShellFiles -RootPath $resolvedPath | Sort-Object -Unique)
    }

    if ($result.FilePaths.Count -eq 0) {
        $warnings.Add("No PowerShell files were found under '$resolvedPath'.")
    }

    $result.Warnings = @($warnings)
    return [PSCustomObject]$result
}
