# SCRIPT THAT WILL FIND WHO IS LOGGED INTO A MACHINE #

$computer = Read-Host "Enter a computer name"

Get-WmiObject –ComputerName $computer –Class Win32_ComputerSystem | Select-Object UserName


