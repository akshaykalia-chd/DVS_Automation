Start-Transcript -Append -Path "$env:USERPROFILE\Documents\DVScopy.log"
$vCenterIP = Read-Host "Enter vCenter IP or Name where the operation needs to be executed"
$myDatacenter = Read-Host "Enter Datacenter Name where the operation needs to be executed"
$Cluster = Read-Host "Enter Cluster Name where the operation needs to be executed"
$NewDVS = Read-Host "Enter a Name for the DVS in the New vCenter"
Connect-VIServer $vCenterIP
[uint16]$Choice=1
While ($Choice -ne 0)
{
Write-Host -ForegroundColor Red "Step 1,2 and 3 are expected to be run sequentially. Unless you have migrated all the VM to $NewDVS and would like to execute Step 2 to move additional Nic"
Write-Host -ForegroundColor Green "What would you like to do?"
Write-Host -ForegroundColor Green "1: Add Hosts to $NewDVS"
Write-Host -ForegroundColor Green "2: Move Physical Nics to $NewDVS"
Write-Host -ForegroundColor Green "3: Move VMs to $NewDVS"
Write-Host -ForegroundColor Green "0: Exit"
[uint16]$Choice=Read-Host "Select the operation you would like to perform [0]"
$hostnames=Get-Datacenter -Name $myDatacenter | Get-Cluster -Name $Cluster | Get-VMHost
$hostnames=$hostnames.name
switch($Choice) 
{
   1 {
        Write-Host -ForegroundColor Green "You have selected to add Hosts to $NewDVS"         
        ################Adding the Host to the new DVS by reading the host list########################
        ForEach ($hostname in $hostnames)
        {
        Get-VDSwitch -Name $NewDVS|Add-VDSwitchVMHost -VMHost $hostname -Confirm:$false
        Write-Host -ForegroundColor Green "Added $hostname to $NewDVS"
        }
      } 
        
   2 {
        Write-Host -ForegroundColor Green "You have selected to Move Physical Nics to $NewDVS"      
        ################Move Physical Nics######################################
        $NicName=Read-Host "Enter a Name of the uplink to move[vmnic0]"
        Write-Host -ForegroundColor Red "Moving uplink $NicName for all Host in the  slected cluster.This can lead to Network outage"
        $Execute ="no"
        While ($Execute -ne "yes")
        {
        $Execute =Read-Host "Should I proceed[yes]"
        }
        ForEach ($hostname in $hostnames)
        {  
         $vmhostNetworkAdapter = Get-VMHostNetworkAdapter -Physical|Where-Object {($_.VMHost.Name -eq $hostname) -and ($_.Name -in $NicName)}
         Get-VDSwitch $NewDVS | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter $vmhostNetworkAdapter -Confirm:$false
         Write-Host -ForegroundColor Green "Moved $NicName for $hostname to $NewDVS"
        }
     } 
       
   3 {
        Write-Host -ForegroundColor Green "You have selected to Move VMs to $NewDVS"       
        ###################Move VMs#########################
        #Validation Prompt
        $Execute = "no"
        While ($Execute -ne "yes")
        {
        Write-Host -ForegroundColor Red "Moving VMs from one Portgroup to another will lead to a brief network outage."
        Write-Host -ForegroundColor Red "Validate and confirm the Physical Nic placement for Hosts on $NewDVS before proceding."
        $Execute=Read-Host "Would you like to proceed further with VM placement[yes]"
        }
 
        $NetMap = Import-Csv $env:USERPROFILE\Documents\Network_Map.csv
        $VMs = Get-Datacenter -Name $myDatacenter | Get-Cluster -Name $Cluster |Get-VM
         
        #Virtual Machine placement
        ForEach ($VM in $VMs)
        {
            if($VM.Name -in $NetMap.VM) 
            {
            $NetAdapters=Get-VM $VM | Get-NetworkAdapter
                ForEach ($NetAdapter in $NetAdapters)
                {
                    $NetName=$NetMap | Where-Object{($_.VM -eq $VM.Name) -and ($_.Name -eq $NetAdapter.Name)}
                    $NetName=$NetName.NetworkName
                    $error.clear()
                    try
                        {
                            Set-NetworkAdapter -NetworkAdapter $NetAdapter -Portgroup $NetName -Confirm:$false                           
                        }catch{}
                    if(!$error)
                        {
                            Write-Host -ForegroundColor Green "Moved $NetAdapter for $VM to $NewDVS PortGroup $NetName"
                        }
                    else
                        {
                            Write-Host -ForegroundColor red "Error processing $VM"
                        }
                }
             }
            else
            {
                Write-Host -ForegroundColor red "Network mapping not found for $VM"
            }
 
        }
              
     }
   default
        {
            $Choice=0
        }       
}
}
Disconnect-viserver -confirm:$false
Stop-Transcript