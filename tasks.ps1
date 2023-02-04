param(
    # Task
    [Parameter(Mandatory = $true, Position = 0)]
    [string]
    $Task
)

Set-Location $PSScriptRoot

Write-Host "TASK = $Task"

function Invoke-Clean
{
    if (Test-Path "output")
    {
        Remove-Item "output" -Recurse -Force -Confirm:$false
    }
}

function Invoke-Build
{
    Invoke-Clean

    $version = (Import-PowerShellDataFile -Path "$PSScriptRoot\PSTemplator\PSTemplator.psd1").ModuleVersion.ToString()

    if (Get-Item "output" -ErrorAction SilentlyContinue)
    {
        Remove-Item "output" -Recurse -Force -Confirm:$false
    }

    # Copy module folder to output folder
    $sourceDir = 'PSTemplator'
    $targetDir = "output\PSTemplator\$version"
    Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Container -Verbose

    # Set global vars to use in tests
    $env:BuildProjectName = 'PSTemplator'
    $env:BuildModuleManifest = "$targetDir\PSTemplator.psd1"
    $env:BuildProjectPath = $PSScriptRoot

    # Tests
    $Pester = Invoke-Pester -Path .\Tests\Build -PassThru
    if ($Pester.FailedCount -gt 0)
    {
        Write-Host "Not ready to publish !" -ForegroundColor Yellow
        Exit 1
    }
    else
    {
        Write-Host "Can publish !" -ForegroundColor Green
    }
}

if ($Task -eq 'clean')
{
    Invoke-Clean
}
elseif ($Task -eq 'build')
{
    Invoke-Build
}
