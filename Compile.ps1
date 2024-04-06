$OFS = "`r`n"
$scriptname = "itt.ps1"
# Variable to sync between runspaces
$sync = [Hashtable]::Synchronized(@{})
$sync.PSScriptRoot = $PSScriptRoot
$sync.configs = @{}

if (Test-Path -Path "$($scriptname)")
{
    Remove-Item -Force "$($scriptname)"
}


Write-output '
################################################################################################################
###                                                                                                          ###
###  This file is automatically generated                                                                    ###
###                                                                                                          ###
################################################################################################################
' | Out-File ./$scriptname -Append -Encoding ascii

(Get-Content .\scripts\start.ps1).replace('#{replaceme}',"$(Get-Date -Format yy.MM.dd)") | Out-File ./$scriptname -Append -Encoding ascii 


Get-ChildItem .\functions -Recurse -File | ForEach-Object {
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii 
}

Get-ChildItem .\database | Where-Object {$psitem.extension -eq ".json"} | ForEach-Object {
    $json = (Get-Content $psitem.FullName).replace("'","''")
    $sync.configs.$($psitem.BaseName) = $json | convertfrom-json
    Write-output "`$sync.configs.$($psitem.BaseName) = '$json' `| convertfrom-json" "  "| Out-File ./$scriptname -Append -Encoding ascii 
}




$xaml = (Get-Content .\interface\window.xaml).replace("'","''")


# Assuming taps.xaml is in the same directory as main.ps1
$appXamlPath = Join-Path -Path $PSScriptRoot -ChildPath "interface/Controls/taps.xaml"
$buttonStylePath = Join-Path -Path $PSScriptRoot -ChildPath "interface/Themes/button.xaml"
$scrollbarStylePath = Join-Path -Path $PSScriptRoot -ChildPath "interface/Themes/scrollbar.xaml"
$colorsPath = Join-Path -Path $PSScriptRoot -ChildPath "interface/Themes/colors.xaml"




# Load the XAML content from inputApp.xaml
$appXamlContent = Get-Content -Path $appXamlPath -Raw
$buttonStyleContent = Get-Content -Path $buttonStylePath -Raw
$scrollbarContent = Get-Content -Path $scrollbarStylePath -Raw
$colorsContent = Get-Content -Path $colorsPath -Raw





# Replace the placeholder in $inputXML with the content of inputApp.xaml
$xaml = $xaml -replace "{{Taps}}", $appXamlContent
$xaml = $xaml -replace "{{ButtonStyle}}", $buttonStyleContent
$xaml = $xaml -replace "{{ScrollbarStyle}}", $scrollbarContent
$xaml = $xaml -replace "{{Colors}}", $colorsContent


Write-output "`$inputXML =  '$xaml'" | Out-File ./$scriptname -Append -Encoding ascii 

Get-Content .\scripts\loadXmal.ps1 | Out-File ./$scriptname -Append -Encoding ascii

Get-ChildItem .\loops -Recurse -File | ForEach-Object {
    
    Get-Content $psitem.FullName | Out-File ./$scriptname -Append -Encoding ascii 
}


Get-Content .\scripts\main.ps1 | Out-File ./$scriptname -Append -Encoding ascii

