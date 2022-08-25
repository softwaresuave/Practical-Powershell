#Quick Microsoft Teams Fix - clears all Teams cache

$Computer = Read-Host "Enter Name of Users Computer"
Invoke-Command -ComputerName $Computer -ScriptBlock {Stop-Process -Name "Teams"}
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\Application Cache -Force -Recurse}
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\blob_storage -Force -Recurse}
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\Cache -Force -Recurse}
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\databases -Force -Recurse}
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\GPUCache -Force -Recurse}
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\IndexedDB -Force -Recurse} 
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\Local Storage -Force -Recurse} 
Invoke-Command -ComputerName $Computer -ScriptBlock {Remove-Item C:\Users\$env:UserProfile\AppData\Roaming\Microsoft\Teams\tmp -Force -Recurse}
