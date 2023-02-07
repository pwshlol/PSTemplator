﻿try {
    # Try to import from installed UI Culture
    Import-LocalizedData -BindingVariable Global:Localization -BaseDirectory .\Localizations -FileName PSTemplator -ErrorAction SilentlyContinue
} catch {
    # Import en-US
    Import-LocalizedData -BindingVariable Global:Localization -BaseDirectory .\Localizations -FileName PSTemplator -UICulture en-us
}

# Private functions
Get-ChildItem $PSScriptRoot\Private\*.ps1 -Recurse | ForEach-Object { . $_.FullName }

# Public functions
$public = Get-ChildItem $PSScriptRoot\Public\*.ps1 -Recurse
$public | ForEach-Object { . $_.FullName }
Export-ModuleMember -Function $public.BaseName
