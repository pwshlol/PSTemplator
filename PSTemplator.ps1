Import-Module .\PSTemplator\PSTemplator.psd1 -Force

[hashtable]$ReplaceTable = @{
    ProjectName              = 'ProjectTest'
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
New-Project
