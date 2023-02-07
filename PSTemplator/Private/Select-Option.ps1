function Select-Option {
    param(
        [parameter(Mandatory = $true, Position = 0)][string]$Message,
        [parameter(Mandatory = $true, Position = 1)][string[]]$Options
    )
    $Selected = $null
    while ($null -eq $Selected) {
        Write-Host $Message -ForegroundColor DarkMagenta
        for ($i = 0; $i -lt $Options.Length; $i++) {
            Write-Host "$($i+1): $($Options[$i])"
        }
        $SelectedIndex = Read-Host "Select an option"
        if ($SelectedIndex -gt 0 -and $SelectedIndex -le $Options.Length) {
            $Selected = $Options[$SelectedIndex - 1]
        } else {
            Write-Host "Invalid Option." -ForegroundColor Yellow
        }
    }
    return $Selected
}
