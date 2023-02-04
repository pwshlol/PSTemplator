function Invoke-Check
{
    [CmdletBinding()]
    param (
        # Path
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Path,
        # ReplaceTable
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $ReplaceTable
    )
    $IsError = $false
    Write-Verbose "Testing $Path"
    if (Test-Path $Path)
    {
        $get = Get-Item $Path
        if ($get -is [System.IO.FileInfo])
        {
            $content = Get-Content -Path $get -Raw
            $ReplaceTable.GetEnumerator() | ForEach-Object {
                if ($content -like "*$($_.Key)*")
                {
                    Write-Warning ($Localization.WarningFileStillContainsTerms -f $get.FullName)
                }
            }
            Set-Content -Path $get -Value $content.TrimEnd()
            $ReplaceTable.GetEnumerator() | ForEach-Object {
                if ($get.BaseName -like "*$($_.Key)*")
                {
                    Write-Warning ($Localization.WarningFileStillContainsTerms -f $get.FullName)
                }
            }
        }
        elseif ($get -is [System.IO.DirectoryInfo])
        {
            $ReplaceTable.GetEnumerator() | ForEach-Object {
                if ($get.BaseName -like "*$($_.Key)*")
                {
                    Write-Warning ($Localization.WarningFileStillContainsTerms -f $get.FullName)
                }
            }
        }
    }
    if ($IsError)
    {
        Throw ($Localization.ErrorProjectStillContainsTerms)
    }
}
