function New-Project {
    [CmdletBinding()]
    param (
        # FromDirectory
        [switch]
        $FromDirectory,
        $TemplateDirectoryPath,
        # FromGithubURI
        [switch]
        $FromGithubURI,
        $TemplateGithubURI,
        # Global
        $DestinationRoot,
        $RepositoryName,
        [hashtable]
        $ReplaceTable,
        [switch]
        $Force
    )

    # Check for method select
    if (-not $FromDirectory -and -not $FromGithubURI) {
        $options = "Directory", "Github URI", "Exit"
        $selected = Select-Option -Message $Localization.AskSelectMethod -Options $options
        switch ($selected) {
            "Directory" { $FromDirectory = $true }
            "Github URI" { $FromGithubURI = $true }
            "Exit" { Return }
        }
    }

    if ($FromDirectory) {
        # Ask for template directory
        if ([string]::IsNullOrEmpty($TemplateDirectoryPath)) {
            $TemplateDirectoryPath = Read-Host $Localization.AskTemplateDirectory
        }
    } elseif ($FromGithubURI) {
        # Ask for template directory
        if ([string]::IsNullOrEmpty($TemplateGithubURI)) {
            $TemplateGithubURI = Read-Host $Localization.AskTemplateGithubURI
        }
    }

    # Ask for Destination
    if ([string]::IsNullOrEmpty($DestinationRoot)) {
        $DestinationRoot = Read-Host $Localization.AskDestinationRoot
    }

    # Ask for RepositoryName
    if ([string]::IsNullOrEmpty($RepositoryName)) {
        $RepositoryName = Read-Host $Localization.AskRepositoryName
    }

    # Search for ReplaceTable because user did not used it as an argument
    if (!$ReplaceTable) {
        # Search for json in directory
        if ($FromDirectory) {
            # Find ReplaceTable from json
            $json = Get-ChildItem $TemplateDirectoryPath | Where-Object { $_.Name -eq 'templator.json' }
            if ($null -eq $json) {
                Write-Error $Localization.ErrorCannotFindJson
            }

            # Ask for each generic terms to replace
            [psobject]$ReplaceTable = [ordered]@{}
            $obj = Get-Content $json | ConvertFrom-Json -Depth 2
            $obj.ToReplace.GetEnumerator() | ForEach-Object {
                if ($_ -eq 'ProjectGUID') { $ReplaceTable['ProjectGUID'] = (New-Guid).ToString() }
                else {
                    $read = Read-Host $_
                    $ReplaceTable[$_] = $read
                }
            }
        }
        # Search for json into github template's directory
        if ($FromGithubURI) {
            # Find ReplaceTable from json online
            try {
                $response = Invoke-WebRequest -UseBasicParsing -Uri $TemplateGithubURI | Select-Object Links
                $selected = $response.Links | Where-Object { $_.outerHTML -like "*templator.json*" } | Select-Object -Index 0
                $request = "https://raw.githubusercontent.com$($selected.href)"
                $request = $request -replace '/blob', ''
                $json = (Invoke-WebRequest -Uri $request).Content | ConvertFrom-Json
            } catch {
                Write-Error $Localization.ErrorCannotFindJson
            }
            if ($null -eq $json) {
                Write-Error $Localization.ErrorCannotFindJson
            }

            # Ask for each generic terms to replace
            [psobject]$ReplaceTable = [ordered]@{}
            $json.ToReplace.GetEnumerator() | ForEach-Object {
                if ($_ -eq 'ProjectGUID') { $ReplaceTable['ProjectGUID'] = (New-Guid).ToString() }
                else {
                    $read = Read-Host $_
                    $ReplaceTable[$_] = $read
                }
            }
        }
    }

    # Ready to create the project
    if ($FromDirectory) {
        Invoke-Project -FromDirectory `
            -TemplateDirectoryPath $TemplateDirectoryPath `
            -DestinationRoot $DestinationRoot `
            -RepositoryName $RepositoryName `
            -ReplaceTable $ReplaceTable `
            -Force:$Force
    } elseif ($FromGithubURI) {
        Invoke-Project -FromGithubURI `
            -TemplateGithubURI $TemplateGithubURI `
            -DestinationRoot $DestinationRoot `
            -RepositoryName $RepositoryName `
            -ReplaceTable $ReplaceTable `
            -Force:$Force
    }
}
