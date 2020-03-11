import-module RoyalDocument.PowerShell
$RoyalStore = New-RoyalStore -UserName ($env:USERDOMAIN + '\' + $env:USERNAME)
$DocumentParams = @{
    Store    = $RoyalStore
    Name     = "Windows Servers"
    FileName = "$PSScriptRoot\windows-servers.rtsz"
}
$RoyalDocument = New-RoyalDocument @DocumentParams
$Servers = Get-ADComputer -Filter 'OperatingSystem -like "*Server*"' -Properties Name, Description, OperatingSystem, DNSHostname | Select-Object Name, Description, OperatingSystem, DNSHostname | Sort-Object -Property Name
$OperatingSystems = ($Servers | Select-Object OperatingSystem -Unique).OperatingSystem

ForEach ($OS in $OperatingSystems)  {
    $folder= New-RoyalObject -Type RoyalFolder -Folder $RoyalDocument -Name $OS -Description "All $OS servers"
    $FolderItems= $Servers| Where-Object OperatingSystem -EQ $OS
    Foreach ($Item in $FolderItems) {
        $RDS = New-RoyalObject -Type RoyalRDSConnection -Folder $folder -Name "$($Item.Name)"# -URI "$($Item.DNSHostname)"
        $RDS.URI = $Item.DNSHostname
        $RDS.CredentialFromParent =  $true
    }
}

Out-RoyalDocument -Document $RoyalDocument
Close-RoyalDocument -Document $RoyalDocument
