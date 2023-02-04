BeforeAll {
    $moduleName = $env:BuildProjectName
    $manifest = Import-PowerShellDataFile -Path $env:BuildModuleManifest
    $outputDirectory = Join-Path -Path $ENV:BuildProjectPath -ChildPath 'Output'
    $outputModDir = Join-Path -Path $outputDirectory -ChildPath $env:BuildProjectName
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputManifestPath = Join-Path -Path $outputModVerDir -Child "$($moduleName).psd1"
    $manifestData = Test-ModuleManifest -Path $outputManifestPath -Verbose:$false -ErrorAction Stop -WarningAction SilentlyContinue
    $manifestData

    $changelogPath = Join-Path -Path $env:BuildProjectPath -Child 'CHANGELOG.md'
    $changelogVersion = Get-Content $changelogPath | ForEach-Object {
        if ($_ -match "^##\s\[(?<Version>(\d+\.){1,3}\d+)\]")
        {
            $changelogVersion = $matches.Version
            $changelogVersion
            break
        }
    }
    $changelogVersion
    $script:manifest = $null
}
Describe 'Build Module Manifest' {

    Context 'Validation' {

        It 'Has a valid manifest' {
            $manifestData | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid name in the manifest' {
            $manifestData.Name | Should -Be $moduleName
        }

        It 'Has a valid root module' {
            $manifestData.RootModule | Should -Be "$($moduleName).psm1"
        }

        It 'Has a valid version in the manifest' {
            $manifestData.Version -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid description' {
            $manifestData.Description | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid author' {
            $manifestData.Author | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid guid' {
            { [guid]::Parse($manifestData.Guid) } | Should -Not -Throw
        }

        It 'Has a valid copyright' {
            $manifestData.CopyRight | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid version in the changelog' {
            $changelogVersion | Should -Not -BeNullOrEmpty
            $changelogVersion -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Changelog and manifest versions are the same' {
            $changelogVersion -as [Version] | Should -Be ( $manifestData.Version -as [Version] )
        }
    }
}

Describe 'Git tagging' -Skip {
    BeforeAll {
        $gitTagVersion = $null ; $gitTagVersion

        if ($git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue)
        {
            $thisCommit = & $git log --decorate --oneline HEAD~1..HEAD
            if ($thisCommit -match 'tag:\s*(\d+(?:\.\d+)*)') { $gitTagVersion = $matches[1] }
        }
    }

    It 'Is tagged with a valid version' {
        $gitTagVersion | Should -Not -BeNullOrEmpty
        $gitTagVersion -as [Version] | Should -Not -BeNullOrEmpty
    }

    It 'Matches manifest version' {
        $manifestData.Version -as [Version] | Should -Be ( $gitTagVersion -as [Version])
    }
}

Describe 'Testing a new project from github template' {
    BeforeAll {
        Import-Module $manifestData -Force

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

        $project = New-Project -FromGithubURI `
            -TemplateGithubURI "https://github.com/pwshlol/PSTModule" `
            -DestinationRoot $env:TMP `
            -RepositoryName 'PSTModuleTestGithubURI' `
            -ReplaceTable $ReplaceTable `
            -Force

        $project
        Write-Host "[SUCCESS] $env:TMP\PSTModuleTestGithubURI" -ForegroundColor Green
        Remove-Item "$env:TMP\PSTModuleTestGithubURI" -Recurse -Confirm:$false -Force
    }

    It 'Has not thrown an error' {
        { $project } | Should -Not -Throw
    }
}
