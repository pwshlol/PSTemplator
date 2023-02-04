Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'

Set-Location $PSScriptRoot
Import-Module .\PSTemplator\PSTemplator.psd1 -Force

[hashtable]$ReplaceTable = @{
    ProjectName              = 'PSTModuleTest'
    ProjectAuthor            = 'innovatodev'
    ProjectCompany           = 'pwshlol'
    ProjectMail              = 'contact@pwsh.lol'
    ProjectDescription       = 'A powershell module doing something.'
    ProjectVersion           = '0.1.0'
    ProjectPowerShellVersion = '5.1'
    ProjectCopyright         = '2023 pwshlol, all rights reserved.'
    ProjectRepositoryOwner   = 'pwshlol'
    ProjectGUID              = (New-Guid).ToString()
}

# Test from directory
New-Project -FromDirectory `
    -TemplateDirectoryPath "$($PSScriptRoot | Split-Path)\PSTModule" `
    -DestinationRoot "$($PSScriptRoot | Split-Path)" `
    -RepositoryName 'PSTModuleTestDirectory' `
    -ReplaceTable $ReplaceTable `
    -Force

# Test from Github URI
New-Project -FromGithubURI `
    -TemplateGithubURI "https://github.com/pwshlol/PSTModuleAdvanced" `
    -DestinationRoot "$($PSScriptRoot | Split-Path)" `
    -RepositoryName 'PSTModuleTestGithubURI' `
    -ReplaceTable $ReplaceTable `
    -Force
