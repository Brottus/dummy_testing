@{
    RootModule            = 'ForensicOS.Linker.psm1'
    ModuleVersion         = '1.0.0'
    GUID                  = 'e7f4c1a8-9b2d-4e6f-8c3a-1d5b9a2f7e4c'
    Author                = 'Forensicos'
    CompanyName           = 'Forensicos'
    Copyright             = '(c) 2026 Forensicos. All rights reserved.'
    Description           = 'Creates junction and symbolic links for Chocolatey package tools to a centralized location. Supports single package or bulk linking of all installed packages.'
    PowerShellVersion     = '5.1'
    FunctionsToExport     = @('New-ChocolateyPackageToolsLink', 'New-ChocolateyAllPackageToolsLinks')
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @()
    PrivateData           = @{
        PSData = @{
            Tags                       = @('Chocolatey', 'Linker', 'Tools', 'Forensics', 'Package-Manager', 'Windows')
            LicenseUri                 = 'https://github.com/Forensicos/wingetrepo/blob/main/LICENSE'
            ProjectUri                 = 'https://github.com/Forensicos/wingetrepo'
            ReleaseNotes               = 'Initial release. Creates junction/symbolic links for Chocolatey package tools.'
            Prerelease                 = ''
            RequireLicenseAcceptance   = $false
        }
    }
    RequiredModules       = @()
    RequiredAssemblies    = @()
    ModuleList            = @()
    FileList              = @()
}
