$NewComputer = Read-Host "Enter Name of New Computer"
$OldComputer = Read-Host "Enter Name of Old Computer"
#$PSTS = Get-Content "\\$OldComputer\C$\temp"
$PersonsName = Read-Host "Enter First & Last Name of user"
$StorageLocation = Read-Host "Which Room will you be storing this computer?"
$NewComputerDescription = Get-ADComputer -Identity $OldComputer -Properties Description
#Copy Id.gpo

Copy-Item "\\$Oldcomputer\C$\temp" -Destination "\\$NewComputer\C$\temp\OldComputerFiles" -Recurse -Force

Copy-Item "\\$Oldcomputer\C$\temp\id.gpo" -Destination "\\$NewComputer\C$\temp\id.gpo" -Recurse -Force

New-Item -Path "\\$OldComputer\C$\temp" -Name "id.gpo" -Value "Location:$StorageLocation `r`User:Vacant `r`Phone:XXX `r`Lock:XXX `r`Outport:BMT" -Force 

if(Test-Path c:\temp\* -Include "*.pst"){
    Copy-Item c:\temp\* -Include "*.pst" -Destination \\$NewComputer\C$\temp\Psts -Force
    Write-Host "Users PST File is in c:\temp\Psts"
}
else{
    Write-Host "No PST File found on local computer"
}

Set-ADComputer -Identity $NewComputer -Description "$NewComputerDescription"

Set-ADComputer -Identity $OldComputer -Description "$StorageLocation Vacant"































