<#
.DESCRIPTION
    IMPORT SAVED Wi-Fi PROFILES FROM ONE COMPUTER TO ANOTHER. COLLECTS ALL CONFiG iNFO & PWs.
.AUTHOR
    TYLER NEELY
.CREATED
    10/27/2021
#>

$oldcomputer = Read-Host "Type the name of the source computer"
$newcomputer = Read-Host "Type the name of the target computer"
$oldcomputerlist =  "\\$oldcomputer\C$\temp\profiles"
$newcomputerlist =  "\\$newcomputer\C$\temp\profiles"

#collect and import wireless profiles from target computer if it is online
if((Test-Connection $oldcomputer -Count 1 -Quiet) -and (Test-Connection $newcomputer -Count 1 -Quiet)){
    New-Item -path $oldcomputerlist , $newcomputerlist -ItemType Directory -Force
    Write-Host "Collecting Wireless Profiles from $oldcomputer"
    Invoke-Command -ComputerName $oldcomputer {netsh wlan show profiles}
    Write-Host -ForegroundColor Red "THE ABOVE PROFILE LIST WILL BE IMPORTED UNLESS EDITED NOW ON THE OLD COMPUTERS c:\temp\profiles"
    Start-Sleep -Seconds 3
    Invoke-Command -ComputerName $oldcomputer{netsh wlan export profile key=clear folder=C:\temp\profiles}  
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
    Write-Host "Cannot reach the machine(s), check connection." -ForegroundColor Red
    }

#cleanup folders created for exporting profiles
if(Test-Path $oldComputerList){
    Remove-Item -Path $oldComputerList -Recurse
}
if(Test-Path $newComputerList){
    Remove-Item -Path $newComputerList -Recurse
}

#option to delete profiles from a computer        
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

