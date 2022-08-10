<#
    .DESCRIPTION
        IMPORT SAVED Wi-Fi PROFILES FROM ONE COMPUTER TO ANOTHER. 
        IF USERS DO NOT HAVE A CACHED CREDENTIAL, ETHERNET ACCESS, OR ARE ISSUED A NEW MACHINE, THERE IS NO WAY FOR THEM TO CONNECT TO VPN AT THE LOCK SCREEN IF THEY ARE OFF-SITE. 
        CURRENT SECURITY RULES DO NOT ALLOW USERS TO CONNECT TO NEW WLAN NETWORKS AT THE LOCK SCREEN OFTEN LEAVING MANY TELEWORKERS UNABLE TO LOGIN TO THE VPN.
        THIS RESOLVES THE ISSUE BY IMPORTING WLAN PROFILES FROM A MACHINE THAT HAS ALREADY BEEN CONNECTED THE TARGET Wi-Fi (THEIR OLD MACHINE) ALLOWING THEM TO CONNECT TO Wi-Fi > VPN AT THE LOCK SCREEN.
        DO THIS BEFORE ISSUING THE MACHINE.
    .AUTHOR
        TYLER NEELY
    .CREATED
        10/27/2021
#>
$oldcomputer = Read-Host "Type the name of the source computer"
$newcomputer = Read-Host "Type the name of the target computer"
$oldcomputerlist =  "\\$oldcomputer\C$\temp\profiles"
$newcomputerlist =  "\\$newcomputer\C$\temp\profiles"
$removeoldlist  = do{remove-item -Path $oldcomputerlist -Recurse}
                    while(test-path $oldcomputerlist = True)
$removenewlist  = do{remove-item -path $newcomputerlist -Recurse}
                    while(Test-Path $newcomputerlist = True)
if((Test-Connection $oldcomputer -Count 1 -Quiet) -and (Test-Connection $newcomputer -Count 1 -Quiet)){
    Invoke-Command -ComputerName $oldcomputer {netsh wlan show profiles}
    $decision = Read-host "Do you want to delete wireless profiles from a computer? y/n"
        if($decision -match "y"){
            $computer = Read-Host "Which Computer?"
            do{
                Invoke-Command -ComputerName $computer{
                netsh wlan show profiles
                $input = Read-Host "Input the name of the profile you want to delete or use * to delete all"
                netsh wlan delete profile name=$input}
                $loopcontrol = Read-host "Finished deleting profiles? (y/n)"
                }
            until($loopcontrol -eq "y")            
            }
$removeoldlist 
$removenewlist
New-Item -path $oldcomputerlist , $newcomputerlist -ItemType Directory -Force
Invoke-Command -ComputerName $oldcomputer{netsh wlan export profile key=clear folder=C:\temp\profiles}  
Write-Host -ForegroundColor Red "THE ABOVE PROFILE LIST WILL BE IMPORTED UNLESS EDITED RIGHT NOW ON THE OLD COMPUTERS c:\temp\profiles"
Read-Host -prompt "PRESS ANY KEY TO CONTINUE"  
Robocopy "\\$oldcomputer\C$\temp\profiles" "\\$newcomputer\C$\temp\profiles"
$profilelist = Get-ChildItem -Path $oldcomputerlist    
foreach($profile in $profilelist){
    $fullname = Join-Path "C:\temp\profiles\" $profile.Name
    Invoke-Command -ComputerName $newcomputer{
    param([string[]]$fullname)
    netsh wlan add profile filename=$fullname user=all} -ArgumentList (,$fullname)
    }
}
else{
    Write-Host "Cannot reach the machines, check connection" -ForegroundColor Red
    }
$removelist