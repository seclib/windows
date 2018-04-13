<#
$TestString = "This is a test string"
If ($TestString -like "*string") {
    Write-Output "This is a match"
}
#>

$StartingFolder = "D:\Egnyte\Content\Shared\One-Click Bundles"
$SrcDirectory = (Get-ChildItem -Path $StartingFolder | Where-Object { $_.Attributes -eq "Directory" })[0].FullName
$SrcDirectory