# PSTemplator

## ABOUT

PSTemplator is a tiny template engine written entirely in PowerShell.

It does not require any dependencies and can be used on Windows, Mac and Linux.

This project is based on the module template found [here](https://github.com/pwshlol/PSTModule).

## FEATURES

### [Template engine](https://github.com/pwshlol/PSTemplator)

- Download prebuilt templates from pwshlol's github repositories
- Import/Download prebuilt user made templates (locally or on github)
- Interactive mode (Ask for missing parameters for the new project if some/all are missing)
- Dynamically find the required terms that needs to be replaced based on a json

### [PSTModule](https://github.com/pwshlol/PSTModule)

- Manifest/module generation
- Private/Public functions
- Vscode configuration
- Vscode tasks for testing, building, publishing
- Github templates ( bug report creation, features demand )
- Github actions for PSScriptAnalyzer, Pester tests on all platforms ( pwsh linux , mac, windows & windows powershell ) on push/pull request and/or manually
- Basic Pester tests integrated for the module itself
- Generic files used in projects (MIT license, changelog, gitignore/attributes, ScriptAnalyzer rules etc.)

## HOW TO USE

Actually the module is not released/published.

You can still use it as standalone module but it need to be downloaded manually until we release/publish it.

Fully interactive use :

```powershell
Import-Module .\PSTemplator\PSTemplator.psd1 -Force
New-Project
```

Import from local directory with predefined options:

```powershell
Import-Module .\PSTemplator\PSTemplator.psd1 -Force
[hashtable]$ReplaceTable = @{
    ProjectName              = 'NewCoolProject'
    ProjectAuthor            = 'innovatodev'
    ProjectCompany           = 'pwshlol'
    ProjectMail              = 'contact@pwsh.lol'
    ProjectDescription       = 'A powershell module doing something.'
    ProjectVersion           = '0.1.0'
    ProjectPowerShellVersion = '5.1'
    ProjectCopyright         = '2023 pwshlol, all rights reserved.'
    ProjectRepositoryOwner   = 'innovatodev'
    ProjectGUID              = (New-Guid).ToString()
}
New-Project -FromDirectory `
    -TemplateDirectoryPath "C:\The\Directory\Where\The\Template\Is\At" `
    -DestinationRoot "C:\The\Directory\Where\I\Want\My\Project" `
    -RepositoryName 'NewCoolProject' `
    -ReplaceTable $ReplaceTable
```

Download from github with predefined options:

```powershell
Import-Module .\PSTemplator\PSTemplator.psd1 -Force
[hashtable]$ReplaceTable = @{
    ProjectName              = 'NewCoolProject'
    ProjectAuthor            = 'innovatodev'
    ProjectCompany           = 'pwshlol'
    ProjectMail              = 'contact@pwsh.lol'
    ProjectDescription       = 'A powershell module doing something.'
    ProjectVersion           = '0.1.0'
    ProjectPowerShellVersion = '5.1'
    ProjectCopyright         = '2023 pwshlol, all rights reserved.'
    ProjectRepositoryOwner   = 'innovatodev'
    ProjectGUID              = (New-Guid).ToString()
}
New-Project -FromGithubURI `
    -TemplateGithubURI "https://github.com/pwshlol/PSTModule" `
    -DestinationRoot "C:\The\Directory\Where\I\Want\My\Project" `
    -RepositoryName 'NewCoolProject' `
    -ReplaceTable $ReplaceTable
```
