<#    
.DESCRiPTiON 
    Script for administrators to run various functions on remote computers. 
    Explanation of each function is given in the code or in the output.

.LOCATiON
    \\SDDC05PS842DS01\C$\scripts\toolkit\Wtools.ps1
   
.NOTES 
    FileName:    toolkit.ps1 
    Author:      Tyler Neely 
    Created:     2021-03-27
#>

#Display list of available scripts
Write-Host '       WORKSTATiON TOOLS' -ForegroundColor Green 
Write-Host '       LiST OF SCRiPTS' -ForegroundColor Yellow   
' 1  -  PROMPTS & LOGS OFF USER                                                  
 2  -  iSSUE iNSTANT RESTART                                                   
 3  -  RUNS 2 GPUPDATE /FORCE                                               
 4  -  PSSESSiON iNTO MACHiNE                                      
 5  -  PSEXEC iNTO MACHiNE                                 
 6  -  ENABLE RDP                                                   
 7  -  ENABLE PSREMOTiNG                                                
 8  -  GET iNSTALLED APPS & iNSTALL DATE                                    
 9  -  GET COMPUTER iNFO                                     
 10 -  APPLiCATiON VERSiON CHECKER                          
 11 -  WiNDOWS UPDATE FiX                                         
 12 -  FiREFOX CERTS                                                             
 13 -  RE-iNSTALL ACTiVCLiENT                                     
 14 -  SCCM FiX | REPORT BACK & REPAiR                       
 15 -  CREATE LOCAL DoD_ADMiN | CHANGE PW                           
 16 -  REGiSTRY FiX FOR USB iSSUE                                
 17 -  GPUPDATE FiX | RENAME REGiSTRY.POL (CAUTiON!)               
 18 -  FiND LOGGED iN USER 
 19 -  GET MACHiNES NETWORK STATUS
 20 -  TEAMS FiX
 21 -  TAKE WiFi PROFiLES & PASSWORDS | iMPORT
 22 -  SEND MESSAGE TO USERS COMPUTER
 23 -  iNSTALL DRiVERS
 24 -  CAFFEiNE' 
 
#Asks the user what function they would like to start using then checks for user input
Write-Host "SELECT SCRiPT TO EXECUTE" -NoNewline -ForegroundColor Green
$func = Read-Host -Prompt ' '
cls

if ( ([string]::isNullOrEmpty($func))) {
    Write-Host "Toolkit cannot work without input..."
}

#From here on down unless noted by a comment are functions, these functions will be called if you choose the correct option
if($func -eq '1'){
#PROMPTS & LOGS OFF USER
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }    
    foreach ($computer in $computers) {
        quser /server:$computer
        $user = Read-Host -Prompt 'What user would you like to logoff? Please type in username exactly as shown in USERNAME section'   
        $userName = "$user"
        $sessionid = ((quser /server:$computer | Where-Object { $_ -match $userName }) -split ' +')[2]
        $sessionid
        logoff $sessionid /server:$computer
    }
}
if($func -eq '2'){
#iSSUE iNSTANT RESTART
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }    
    Write-Warning '!This is an instant restart! Be careful!' 
    foreach ($computer in $computers) {
        shutdown -r -t 0 -f -m \\$computer
    }
}
if($func -eq '3'){
#RUNS 2 GPUPDATE /FORCE   
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }    
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-host "Starting on $computer"
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" } 
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '4'){
#PSSESSiON iNTO MACHiNE
    $computer = Read-Host -Prompt 'input Computer Name for PSSession'
    Enter-PSSession -Computername $computer
}
if($func -eq '5'){
#PSEXEC iNTO MACHiNE
    $computer = Read-Host -Prompt 'input Computer Name'
    psexec \\$computer -s cmd /s 
}
if($func -eq '6'){
#ENABLE RDP
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }    
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting $computer"
            invoke-Command -Computername $computer -ScriptBlock { Set-itemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0 }
            invoke-Command -Computername $computer -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }
            Write-Host "Finishing $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '7'){ 
#ENABLE PSREMOTiNG    
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting to enable PSRemoting on $computer"
            psexec \\$computer -s cmd /c powershell.exe Enable-PSRemoting -Force
            Write-Host "Finishing up on $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '8'){ 
#LiST iNSTALLED APPS iNFO   
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }  
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Getting software on $computer"
            invoke-command -computer $computer { Get-itemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, installDate }
            Write-Host "End of software list on $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '9'){ 
#GET COMPUTER iNFO 
#CSV is exported at end of script with computer info
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }

    foreach($computer in $computers){
        try{
            [pscustomobject]$output = @{
                ComputerName          = $computer
                ComputerModel         = $Model
                ComputerSerialNumber  = $Serial
                MACAddress            = $MAC
                iPAddress             = $null
                isOnline              = $false
                User                  = $null
                Error                 = $null
            }
    
            if (Test-Connection -ComputerName $computer -Count 1 -Quiet){
                $output.isOnline = $true
                $MAC = invoke-Command -ComputerName $computer {(getmac /FO TABLE /NH) -ne '' -replace '\s.*$' -join ' / '}
                $Serial = invoke-Command -ComputerName $computer {Get-Computerinfo -Property BiosSeralNumber}
                $Model  =  invoke-Command -ComputerName $computer {Get-Computerinfo -Property CsModel}
                $output.User = invoke-Command -ComputerName $computer {(Get-WMiObject -ClassName Win32_ComputerSystem | select username).username }
            }
            if ($iPAddress = (Resolve-DnsName -Name $computer -ErrorAction Stop).iPAddress){
                $output.iPAddress = "$iPAddress"
            }
    }
    catch{
        $output.Error = $_.Exception.Message
        }
    finally{
        [pscustomobject]$output  | Select-Object -Property ComputerName, ComputerModel, ComputerSerialNumber, MACAddress, iPAddress, isOnline, User, Error  | Export-Csv -Path c:\temp\results.csv -Force -append -NoTypeinformation
        [pscustomobject]$output 
        } 
    }
}
if($func -eq '9'){
#APPLiCATiON VERSiON CHECKER   
    Write-Host "List of Functions: 1. Adobe
                   2. Cisco AnyConnect
                   3. Google Chrome
                   4. Java (x86 & x64
                   5. Mozilla FireFox
                   6. KB's
                   7. WildCard
                   8. edge
                   "
    $func = Read-Host -Prompt 'Please insert the function number of the  you would like to use'

    #From here on down until noted by next comment are functions, these functions will be called if you chose the correct option
    function adobe {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $adobe = (get-item "\\$computer\c$\Program Files (x86)\Adobe\Acrobat DC\Acrobat\acrobat.exe").Versioninfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $adobe.productversion
            Write-Output "File Version"
            $adobe.fileVersion
        }
    }
    function Anyconnect {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $anyconnect = (get-item "\\$computer\C$\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe").Versioninfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $anyconnect.productversion
            Write-Output "File Version"
            $anyconnect.fileVersion
        }
    }
    function chrome {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $chrome = (get-item "\\$computer\C$\Program Files (x86)\Google\Chrome\Application\chrome.exe").Versioninfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $chrome.productversion
            Write-Output "File Version"
            $chrome.fileVersion
        }
    }
    function Java {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $x64java = (Get-Childitem "\\$computer\c$\Program Files\Java" -Recurse -Filter java.exe).Versioninfo
            Write-Output "x64 Product Version"
            $x64java.ProductVersion
            Write-Output "x64 File Version"
            $x64java.fileversion
            $x86java = (Get-Childitem "\\$computer\c$\Program Files (x86)\Java" -Recurse -Filter java.exe).Versioninfo
            Write-Output "x86 Product Version"
            $x86Java.productversion
            Write-Output "x86 File Version"
            $x86Java.fileVersion
        }
    }
    function firefox {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $x64firefox = (get-item "\\$computer\C$\Program Files\Mozilla Firefox\firefox.exe").Versioninfo | Select ProductVersion, FileVersion
            $x86firefox = (get-item "\\$computer\C$\Program Files (x86)\Mozilla Firefox\firefox.exe").Versioninfo | Select ProductVersion, FileVersion
            if ($x64firefox -eq $null) {
                Write-Output "Firefox is not installed in the default x64 location, checking x86"
                if ($x86 -eq $null) {
                    Write-Output "Firefox is not installed in the default x86 location"
                    continue
                }
            }
            if ($x64firefox -ne $null) {
                Write-Output "x64 Product Version"
                $x64firefox.productversion
                Write-Output "x64 File Version"
                $x64firefox.fileVersion
            }
            if ($x86firefox -ne $null) {
                Write-Output "x86 Product Version"
                $x86firefox.productversion
                Write-Output "x86 File Version"
                $x86firefox.fileVersion
            }
        }
    }
    function kb {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $kb = Read-Host -Prompt 'Please input the kb you would like to search for(eg: kb4486996)'
            $hotfix = Get-Hotfix -ComputerName $computer | Select-Object HotFixiD, installedOn | sort installedon | Select-Object HotFixiD
            #$file = Get-Content \\$computer\c$\temp\kb1.txt
            $kb = $kb.ToUpper()
            $computer = $computer.ToUpper()
        
            if ($hotfix -Match $KB ) {
                Write-Output "$KB is installed on $computer"        
            }
            else {
                Write-Output "$KB is not installed on $computer"
            }
        }
    }
    function wildcard {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }

        $application = Read-Host -Prompt 'input application name(e.g: java.exe or chrome.exe (something of the nature))'
        Write-output "This can take a few moments, be patient(This can take up to 10 minutes if not longer on some files\computers)"
        foreach($computer in $computers){
            $wildcard = (Get-Childitem "\\$computer\c$\" -Recurse -Filter $application -ErrorAction SilentlyContinue )
            foreach ($WC in $wildcard) {
                Write-Output "Location is as follows"
                $WC.Fullname
                $version = $WC.Versioninfo
                Write-Output "Product Version info is as follows"
                $version.productversion
                Write-Output "File Version info is as follows"
                $version.fileversion
                ""
            }
        }
    }
    function edge {
        $computers = Read-Host -Prompt 'input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $chrome = (get-item "\\$computer\C$\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").Versioninfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $chrome.productversion
            Write-Output "File Version"
            $chrome.fileVersion
        }
    }

    if ($func -eq '1') {    
        Adobe 
    }
           
    if ($func -eq '2') {    
        Anyconnect 
    }         
   
    if ($func -eq '3') {    
        chrome
    }         

    if ($func -eq '4') {    
        java
    }

    if ($func -eq '5') {   
        firefox
    }

    if ($func -eq '6') {   
        kb
    }

    if ($func -eq '7') {   
        wildcard
    }

    if ($func -eq '8') {
        edge
    }
}
if($func -eq '10'){ 
#WiNDOWS UPDATE FiX  
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting Windows Update Fix on $computer"
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted }
            invoke-Command -ComputerName $computer -ScriptBlock { net stop wuauserv
                net stop cryptSvc /Y
                net stop bits
                net stop msiserver
                ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
                ren C:\Windows\System32\catroot2 catroot2.old
                net start wuauserv
                net start cryptSvc
                net start bits
                net start msiserver }  
            Write-Host "Finishing Windows Update Fix on $computer"
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '12'){
#FiREFOX CERTS
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }   
    $online = "null"

    ForEach ($computer in $computers) {
        if (Test-Connection $computer -Quiet -Count 2) {
            $quserResult = quser /server:$computer
            $users = Get-Childitem "\\$computer\C$\Users"
        if ( $quserResult.Count -gt 0 ) {
            $quserRegex = $quserResult | ForEach-Object -Process { $_ -replace '\s{2,}', ',' }
            $quserObject = $quserRegex | ConvertFrom-Csv
            $onlines = $quserObject.USERNAME}
        elseif ($quserResult.Count -lt 1) { 
            $users
            $onlines = Read-Host -Prompt "No one is logged in. Would you like to enter a username?"}
            Write-Output "Users online are $onlines"
            Robocopy "\\144.101.121.80\temp\scripts\Mozilla_iCODES\files\json" "\\$computer\C$\Program Files\Mozilla Firefox\distribution" policies.json /z /r:2 /w:5
            Robocopy "\\144.101.121.80\temp\scripts\Mozilla_iCODES\files\Firefox_certificates\" "\\$computer\C$\Windows\Admin\Firefox_certificates\" /z /r:2 /w:5
            ForEach ($online in $onlines) {
                Write-Output "Current user is $online"
                if (Test-Path "\\144.101.121.80\userdata\$online\AppData\Roaming\Mozilla\Firefox\Profiles") {
                    $ProfileFolder = (Get-Childitem "\\144.101.121.80\userdata\$online\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter *.default-esr).FullName
                    Write-Output $ProfileFolder
                    if (Test-Path $ProfileFolder) {
                        $acl = Get-Acl $ProfileFolder
                        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SDDC_SA","FullControl","Allow")
                        $acl.SetAccessRule($AccessRule)
                        $acl | Set-Acl $ProfileFolder
                        Robocopy "\\144.101.121.80\temp\scripts\Mozilla_iCODES\files\user_prefs\" "$ProfileFolder" user.js /z /r:2 /w:5
                        Write-Output "$ProfileFolder is $onlines Profile Folder"
                    }
                    else { Write-Output "$online has No Profile Folder" }
                    Write-Output "Looking for local accounts"
                    ForEach ($user in $users) {
                        if (Test-Path "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles") {
                            $LocalFolder = (Get-Childitem "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter *.default-esr).FullName
                            if ($LocalFolder -ne $null) {
                                Robocopy "\\144.101.121.80\temp\scripts\Mozilla_iCODES\files\user_prefs\" "$LocalFolder" user.js /z /r:2 /w:5
                                Write-Output "$LocalFolder is $user Local Folder"
                            }
                            else { Write-Output "$user has no local folder" }
                        }
                        else {Write-Output "$user does not have a profiles folder"}
                    }
                }
                else {Write-Output "$online does not have an online profile"
                                        Write-Output "Looking for local accounts"
                    ForEach ($user in $users) {
                        if (Test-Path "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles") {
                            $LocalFolder = (Get-Childitem "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter *.default-esr).FullName
                            if ($LocalFolder -ne $null) {
                                Robocopy "\\144.101.121.80\temp\scripts\Mozilla_iCODES\files\user_prefs\" "$LocalFolder" user.js /z /r:2 /w:5
                                Write-Output "$LocalFolder is $user Local Folder"
                            }
                            else { Write-Output "$user has no local folder" }
                        }
                        else {Write-Output "$user does not have a profiles folder"}
                    }
                }
            }
        }

    else {
        Write-Output "$computer could not be reached"
        }
    }
}
if($func -eq '13'){
#RE-iNSTALL ACTiVCLiENT
#Link to download newest activclient, now you can maintain this later on
#https://isdp.nih.gov/isdp/version.action?prodid=127
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        } 
    Write-host "Starting on $computer"
    $Scriptblock = {
        Write-host "Getting info for uninstall"

        $app = Get-WmiObject -Class Win32_Product | Where-Object { 
            $_.Name -match "ActivClient" 
        }

        #$app
        $app.Uninstall()
        Write-Host "Uninstall finished, starting install"
        msiexec.exe /i "c:\temp\activclient\activclient7.1\Product\ACx647.1.msi" /quiet /norestart
        Write-Host "install finished"
        Write-Host "Starting update"
        msiexec.exe /update C:\Temp\activclient\AC_7.1.0.244.msp /quiet /norestart
        Write-Host "Update finished"
        Write-Host "Pausing script(30 seconds) to wait for install, then checking for install completion"
        Start-Sleep -Seconds 30
        $app = Get-WmiObject -Class Win32_Product | Where-Object { 
            $_.Name -match "ActivClient" 
        }

        if ($app.name -like "ActiviD ActivClient x64") {
            Write-Host "install is Good"
        }
        else {
            Write-Host "Well install didn't work in the time it should have, investigate further"
        }
    }
    robocopy \\144.101.121.80\temp\Programs\ActivClient\7.1.0.244 \\$computer\c$\temp\activclient /S /E  /V /XO /MT:32 /R:2 /W:10
    invoke-Command -ComputerName $computer -ScriptBlock $Scriptblock
}
if($func -eq '14'){  
#SCCM FiX | REPORT BACK & REPAiR  
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }  
    foreach ($computer in $computers) {
        Write-host "Starting on $computer"
        if (Test-Connection -ComputerName $computer -Count 1 ) {
            invoke-Command -ComputerName $computer -ScriptBlock { Net stop ccmexec
                Net stop winmgmt /y
                Winmgmt  /resetrepository
                Net start winmgmt
                Net start ccmexec
                C:\Windows\CCM\ccmrepair.exe
            }
        }
        else {
            Write-Host "Cannot reach $computer"
        }
    }
}
if($func -eq '15'){  
#CREATE LOCAL DoD_ADMiN | CHANGE PW  
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
    $password = Read-Host -prompt "Enter new password for user *Be careful entering password* " -assecurestring
    $decodedpassword = [System.Runtime.interopServices.Marshal]::PtrToStringAuto([System.Runtime.interopServices.Marshal]::SecureStringToBSTR($password))
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            $computer
            $user = [adsi]"WinNT://$computer/DoD_Admin"
            $user.SetPassword($decodedpassword)
            $user.UserFlags = 66049
            $user.Setinfo()
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe 
                Add-LocalGroupMember -Group "Administrators" -Member "DoD_Admin" }
            Write-Host -ForegroundColor Green "installation successful on $computer"
            #Add-Content C:\temp\Scripts\dodadmin\success.csv  "$computer, Success"
        } 
        else {
            Write-Host -ForegroundColor Red "$computer is not online, install failed"
            #Add-Content C:\temp\Scripts\dodadmin\failed.csv  "$computer, Down"   
        }
    }
}
if($func -eq '16'){  
#REGiSTRY FiX FOR USB iSSUE  
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }     
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            $scriptblock = {
                reg delete "HKEY_LOCAL_MACHiNE\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}" /v UpperFilters /f
                reg delete "HKEY_LOCAL_MACHiNE\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}" /v LowerFilters /f
            }
            Write-Host "Starting USB Registry Fix on $computer"
            invoke-Command -ComputerName $computer -scriptblock $scriptblock
            Write-host "THiS NEEDS A RESTART"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '17'){  
#GPUPDATE FiX | RENAME REGiSTRY.POL (CAUTiON!) 
#Use as last resort! This can ruin the computer
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting Registry.pol Fix on $computer"
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe move C:\windows\System32\GroupPolicy\Machine\Registry.pol C:\windows\System32\GroupPolicy\Machine\Registry_Backup.pol }
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" } 
            invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}
if($func -eq '18'){ 
#GET LOGGED iN USER
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
    Get-WmiObject –ComputerName $computer –Class Win32_ComputerSystem | Select-Object UserName
}
if($func -eq '19'){
#GET MACHiNES NETWORK STATUS
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\") {
            $computers = Get-Content $computers
        } 

    foreach($computer in $computers){
        try{
            [pscustomobject]$output = @{
            ComputerName  = $computer
            iPAddress     = $null
            isOnline      = $false
            Error         = $null
            }

            if (Test-Connection -ComputerName $computer -Count 1 -Quiet ){
                $output.isOnline = $true
            }
            if ($iPAddress = (Resolve-DnsName -Name $computer -ErrorAction Stop).iPAddress) {
                $output.iPAddress = "$iPAddress"
            }
        }
        catch{
            $output.Error = $_.Exception.Message
        }
        finally{
            [pscustomobject]$output | Select-Object -Property ComputerName, iPAddress, isOnline, Error | Export-Csv -Path C:\temp\scripts\results.csv -Force -append -NoTypeinformation
            [pscustomobject]$output 
        }    
    }
}
if($func -eq '20'){
#Quick Microsoft Teams Fix - clears all Teams cache
    $Computer = Read-Host "Enter Computer Name"
    $TargetUser = Read-Host "Enter user name as it appears in c:\users\"
    invoke-Command -ComputerName $Computer -ScriptBlock {Stop-Process -Name "Teams"}
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\Application Cache -Force -Recurse}
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\blob_storage -Force -Recurse}
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\Cache -Force -Recurse}
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\databases -Force -Recurse}
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\GPUCache -Force -Recurse}
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\indexedDB -Force -Recurse} 
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\Local Storage -Force -Recurse} 
    invoke-Command -ComputerName $Computer -ScriptBlock {Remove-item C:\Users\$TargetUser\AppData\Roaming\Microsoft\Teams\tmp -Force -Recurse}
    Write-Host "Restart Teams"
}
if($func -eq '21'){
#import Wireless from one computer to another. The passwords can be viewed in the $lists files.
    $targetComputer = Read-Host "Type the name of the source computer"
    $newComputer = Read-Host "Type the name of the target computer"
    $targetComputerList =  "\\$targetComputer\C$\temp\profiles"
    $newComputerList =  "\\$newComputer\C$\temp\profiles"
    $removeOldList  = do{remove-item -Path $targetComputerList -Recurse}
                    while(test-path $targetComputerList = True)
    #$removeNewList  = do{remove-item -path $newcomputerlist -Recurse}
    #                while(Test-Path $newComputerList = True)
    if((Test-Connection $targetComputer -Count 1 -Quiet) -and (Test-Connection $newComputer -Count 1 -Quiet)) {
        invoke-Command -ComputerName $oldcomputer {netsh wlan show profiles}
        $decision = Read-host "Do you want to delete wireless profiles from a computer? y/n"
            if($decision -match "y"){
                $computer = Read-Host "Which Computer?"
                do{
                    invoke-Command -ComputerName $computer{
                    netsh wlan show profiles
                    $input = Read-Host "input the name of the profile you want to delete or use * to delete all"
                    netsh wlan delete profile name=$input}
                    $loopcontrol = Read-host "Finished deleting profiles? (y/n)"
                }
                until($loopcontrol -eq "y")            
                }
        $removeoldlist 
        #$removenewlist
        New-item -path $targetComputerList , $newComputerList -itemType Directory -Force
        invoke-Command -ComputerName $targetComputer{netsh wlan export profile key=clear folder=C:\temp\profiles}  
        Write-Host -ForegroundColor Red "THE ABOVE PROFiLE LiST WiLL BE iMPORTED UNLESS EDiTED RiGHT NOW ON THE OLD COMPUTERS c:\temp\profiles"
        Read-Host -prompt "PRESS ANY KEY TO CONTiNUE"  
        Robocopy "\\$targetComputer\C$\temp\profiles" "\\$newComputer\C$\temp\profiles"
        $profilelist = Get-Childitem -Path $targetComputerList    
        foreach($profile in $profilelist) {
            $fullname = Join-Path "C:\temp\profiles\" $profile.Name
            invoke-Command -ComputerName $newComputer{
            param([string[]]$fullname)
            netsh wlan add profile filename=$fullname user=all} -ArgumentList (,$fullname)
        }
    }
    else{
        Write-Host "Cannot reach the machines, check connection" -ForegroundColor Red
    }
    #$removelist
}
if($func -eq '22'){
    $Computer = read-host "input computer name "
    $msg = read-host "Enter your message "
    invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $Computer
}  
if($func -eq '23'){
#install Drivers on remote machine. Use '\\' if using a remote driver file
    $driversPath = Read-Host "input path to driver file"
    $computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
    foreach ($computer in $computers) {
        if (Test-Connection $computer -Quiet -Count 2) {
            Robocopy $driversPath "\\$computer\C$\Temp\Drivers" /z /r:2 /w:5 /s
            Write-Output "installing Drivers"
            invoke-Command -ComputerName $computer -Scriptblock {Get-Childitem $driversPath -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }}
            invoke-Command -ComputerName $computer -ScriptBlock {Remove-item -Path $driversPath -Recurse}
            Write-Output "$computer Driver install Complete"
        }
        else {
            Write-Output "$computer could not be reached"
        }
    }
}
if($func -eq '24'){
#CAFFEiNE. Computer will never go to sleep with this script 
    $wsh = New-Object -ComObject WScript.Shell
    while (1) {   
        try{
            $wsh.SendKeys('+{F15}')
            Write-Host "Your computer will not go to sleep until you close this window."
            Start-Sleep -seconds 120
        }
        catch{
            Write-Error "Error running script"
        }

    }
}
else {Write-Host "something went wrong :(" }
