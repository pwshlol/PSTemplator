function Invoke-Project {
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
        [Parameter( Mandatory = $true )]
        $DestinationRoot,
        [Parameter( Mandatory = $true )]
        [string]
        $RepositoryName,
        [Parameter( Mandatory = $true )]
        [hashtable]
        $ReplaceTable,
        [switch]
        $Force
    )
    # Check for method select
    if (-not $FromDirectory -and -not $FromGithubURI) {
        Write-Error ($Localization.ErrorMustSelectMethod)
    }

    # Printing the parameters
    if ($FromDirectory) {
        Write-Host ("Template Directory : {0}" -f $TemplateDirectoryPath)
    } elseif ($FromGithubURI) {
        Write-Host ("Template URI : {0}" -f $TemplateGithubURI)
    }
    Write-Host ("Destination : {0}" -f $DestinationRoot)
    Write-Host ("Repository Name : {0}" -f $RepositoryName)
    $ReplaceTable.GetEnumerator() | ForEach-Object {
        Write-Host ("{0} > {1}" -f $_.Key, $_.Value)
    }

    # Remove last \ from DestinationRoot if exist
    [string]$rootDir = $DestinationRoot
    if ($rootDir.EndsWith("\")) {
        $rootDir = $rootDir.Substring(0, $rootDir.Length - 1)
    }
    $rootDir = "$rootDir\$RepositoryName"

    # Check if project already exist in this location
    if (Test-Path $rootDir) {
        if ($Force) {
            Write-Verbose "Overwriting $rootDir"
            Remove-Item $rootDir -Recurse -Confirm:$false -Force
        } else { Write-Error ($Localization.ErrorProjectAlreadyExist) }
    }

    New-Item $rootDir -ItemType Directory | Out-Null
    if ($FromDirectory) {
        if (!(Test-Path $TemplateDirectoryPath)) {
            Write-Error ($Localization.ErrorNoTemplate)
        } else {
            # Copy files from template to root directory
            try {
                Copy-Item -Path "$TemplateDirectoryPath\*" `
                    -Destination $rootDir -Container -Recurse -Confirm:$false
            } catch {
                Write-Error ($Localization.ErrorTemplateCopy)
            }

            # Counting number of files in template
            $templateCount = (Get-ChildItem -Path $TemplateDirectoryPath -Recurse | Measure-Object).Count
        }
    } elseif ($FromGithubURI) {
        try {
            # Search for the zip direct URI
            $response = Invoke-WebRequest -UseBasicParsing -Uri $TemplateGithubURI | Select-Object Links
            $selected = $response.Links | Where-Object { $_.outerHTML -like "*.zip*" } | Select-Object -Index 0

            # Download it
            Invoke-RestMethod "https://github.com/$($selected.href)" -OutFile "$env:TEMP\template.zip"

            # Extract it
            Expand-Archive "$env:TEMP\template.zip" "$env:TEMP\template"
        } catch {
            Write-Error ($Localization.ErrorCantDownload)
        }

        # Get child directory because of the zip structure
        $getFirstDir = Get-ChildItem "$env:TEMP\template" | Select-Object -First 1

        # Copy files from template to root directory
        try {
            Copy-Item -Path "$getFirstDir\*" `
                -Destination $rootDir -Recurse -Confirm:$false
        } catch {
            Write-Error ($Localization.ErrorTemplateCopy)
        }

        # Counting number of files in template
        $templateCount = (Get-ChildItem -Path $getFirstDir -Recurse | Measure-Object).Count
    }

    # Test if number of files match
    $rootDirCount = (Get-ChildItem -Path $rootDir -Recurse | Measure-Object).Count
    if ($rootDirCount -ne $templateCount) {
        Write-Error ($Localization.ErrorFilesCountNotMatch -f $templateCount, $rootDirCount)
    } else { Write-Host ($Localization.SuccessCopy -f $rootDirCount) -ForegroundColor DarkGreen }

    # Replace files content and name
    foreach ($item in Get-ChildItem -Path "$rootDir\*" -Recurse |
        Where-Object { $_.PSIsContainer -eq $false }) {
        Invoke-Replace -Path $item -replace $ReplaceTable
    }

    # Rename directories names
    foreach ($item in Get-ChildItem "$rootDir\*" -Recurse |
        Where-Object { $_.PSIsContainer -eq $true } ) {
        Invoke-Replace -Path $item -replace $ReplaceTable
    }

    # Test if project still contains generic terms
    foreach ($item in Get-ChildItem -Path "$rootDir\*" -Recurse) {
        Invoke-Check -Path $item -replace $ReplaceTable
    }

    # Clean downloaded files
    if (Test-Path "$env:TEMP\template.zip") {
        Remove-Item "$env:TEMP\template.zip" -Recurse -Force -Confirm:$false
    }
    if (Test-Path "$env:TEMP\template") {
        Remove-Item "$env:TEMP\template" -Recurse -Force -Confirm:$false
    }

    # Remove templator.json
    if (Test-Path "$rootDir\templator.json") {
        Remove-Item "$rootDir\templator.json" -Force -Confirm:$false
    }

}
