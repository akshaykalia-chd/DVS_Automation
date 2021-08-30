Start-Transcript -Append -Path "$env:USERPROFILE\Documents\NetMap.log"
$vCenterIP = Read-Host "Enter vCenter IP or Name where the operation needs to be executed"
$myDatacenter = Read-Host "Enter Datacenter Name where the operation needs to be executed"
$Cluster = Read-Host "Enter Cluster Name where the operation needs to be executed"
Connect-VIServer $vCenterIP
Get-Datacenter -Name $myDatacenter | Get-Cluster -Name $Cluster |Get-VM | Get-NetworkAdapter | Select @{N="VM";E={$_.Parent.Name}},Name,NetworkName|export-Csv  "$env:USERPROFILE\Documents\Network_Map.csv" -NoTypeInformation
Disconnect-viserver -confirm:$false
Stop-Transcript