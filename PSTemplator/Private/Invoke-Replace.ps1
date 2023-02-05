<#
.SYNOPSIS

Replace generic terms to new ones from file name, content and directory.

.DESCRIPTION

Replace generic terms to new ones from file name, content and directory.

.PARAMETER Path

Specifies the file or directory path.

.PARAMETER ReplaceTable

Specifies the hashtable to replace the presence of generic terms to new ones.

.INPUTS

None.

.OUTPUTS

None.

.EXAMPLE

PS> Invoke-Replace -Path "c:\PSTModuleTest" -replace $ReplaceTable = @{ ProjectName = 'PSTModuleTest' }

It will replace all instances of 'ProjectName' from directory name, file name and content.

.LINK

https://github.com/pwshlol/PSTemplator

#>
function Invoke-Replace
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
    Write-Verbose "New file $Path"
    if (Test-Path $Path)
    {
        $get = Get-Item $Path
        if ($get -is [System.IO.FileInfo])
        {
            $content = Get-Content -Path $get -Raw
            $ReplaceTable.GetEnumerator() | ForEach-Object { $content = $content -replace $_.Key, $_.Value }
            Set-Content -Path $get -Value $content.TrimEnd()
            $ReplaceTable.GetEnumerator() | ForEach-Object {
                if ($get.BaseName -like "*$($_.Key)*")
                {
                    $name = $get.BaseName -replace $($_.Key), $($_.Value)
                    Write-Verbose "Renaming $($get.FullName) > $($name)$($get.Extension)"
                    Rename-Item -Path $get.FullName -NewName "$($name)$($get.Extension)"
                }
            }
        }
        elseif ($get -is [System.IO.DirectoryInfo])
        {
            $ReplaceTable.GetEnumerator() | ForEach-Object {
                if ($get.BaseName -like "*$($_.Key)*")
                {
                    $name = $get.BaseName -replace $($_.Key), $($_.Value)
                    Write-Verbose "Renaming $($get.FullName) > $name"
                    Rename-Item -Path $get.FullName -NewName $name
                }
            }
        }
    }
}
