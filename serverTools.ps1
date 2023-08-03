<#    
.DESCRIPTION 
    Script for administrators to run various functions on remote computers. 
    Installing the Active Direcory module is required to run ADtools.

.LOCATION
   
.NOTES 
    FileName:    toolkit.ps1 
    Author:      Tyler Neely 
    Created:     2021-03-27
    Updated:     2022-06-10
#>

#Display list of scripts/ functions available

Write-Host '     ' "WORKSTATION TOOLS" -ForegroundColor Yellow -NoNewline
Write-Host '              LIST OF SCRIPTS               '"ACTIVE DIRECTORY TOOLS" -ForegroundColor Yellow
'' 
" (01)  Prompts & logs off user                                (19)  Replicate all Domain Controllers                    
 (02)  Issue instant restart                                  (20)  List Domain Controller                   
 (03)  Runs 2 gpupdate /force                                 (21)  List of Active GPOs                
 (04)  PSSession into machine                                 (22)  List all Windows Clients      
 (05)  PSEXEC into machine                                    (23)  List all Windows Servers  
 (06)  Enable RDP                                             (24)  List Domain Admins        
 (07)  Enable PSRemoting                                      (25)  List User Properties            
 (08)  List all Installed apps & Install date                 (26)  List of Active GPOs                    
 (09)  Application Version Checker                            (27)  List Group Membership by User               
 (10)  BiosCheck/ Get Computer Info                           (28)  Show Default Domain Password Policy   
 (11)  Windows Update Fix                                     (29)  Users Last Domain Logon              
 (12)  Firefox Certificates                                   (30)  Find Near Expiry User or Computer Accounts                            
 (13)  Remove & Re-install ActivClient                        (31)  Disable AD User | Offboarding         
 (14)  SCCM Fix/ Report back & Repair                         (32)  Move Computer to OU  
 (15)  Create local DoD_Admin or Change PW                    (33)  Send message to Users Desktop        
 (16)  Registry Fix for USB issue                             (34)  AD User Audit      
 (17)  GPupdate Fix/ Rename registry.pol(caution)             (35)  AD Computer Audit     
 " 

#Asks the user what function they would like to start using then checks for user input
Write-Host "INPUT THE NUMBER OF WHICH FUNCTION YOU WOULD LIKE TO RUN" -NoNewline -ForegroundColor Green
$func = Read-Host -Prompt ' '
cls
if ( ([string]::IsNullOrEmpty($func))) {
    Write-Host "Toolkit cannot work without input..."
}
#From here on down until noted by next comment are functions, these functions will be called if you chose the correct option
function softwarecheck {
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

    function adobe {
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $adobe = (get-item "\\$computer\c$\Program Files (x86)\Adobe\Acrobat DC\Acrobat\acrobat.exe").VersionInfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $adobe.productversion
            Write-Output "File Version"
            $adobe.fileVersion
        }
    }

    function Anyconnect {
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $anyconnect = (get-item "\\$computer\C$\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe").VersionInfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $anyconnect.productversion
            Write-Output "File Version"
            $anyconnect.fileVersion
        }
    }

    function chrome {
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $chrome = (get-item "\\$computer\C$\Program Files (x86)\Google\Chrome\Application\chrome.exe").VersionInfo | Select ProductVersion, FileVersion
            Write-Output "Product Version"
            $chrome.productversion
            Write-Output "File Version"
            $chrome.fileVersion
        }
    }

    function Java {
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $x64java = (Get-ChildItem "\\$computer\c$\Program Files\Java" -Recurse -Filter java.exe).VersionInfo
            Write-Output "x64 Product Version"
            $x64java.ProductVersion
            Write-Output "x64 File Version"
            $x64java.fileversion
            $x86java = (Get-ChildItem "\\$computer\c$\Program Files (x86)\Java" -Recurse -Filter java.exe).VersionInfo
            Write-Output "x86 Product Version"
            $x86Java.productversion
            Write-Output "x86 File Version"
            $x86Java.fileVersion
        }
    }

    function firefox {
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $x64firefox = (get-item "\\$computer\C$\Program Files\Mozilla Firefox\firefox.exe").VersionInfo | Select ProductVersion, FileVersion
            $x86firefox = (get-item "\\$computer\C$\Program Files (x86)\Mozilla Firefox\firefox.exe").VersionInfo | Select ProductVersion, FileVersion
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
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $kb = Read-Host -Prompt 'Please input the kb you would like to search for(eg: kb4486996)'
            $hotfix = Get-Hotfix -ComputerName $computer | Select-Object HotFixID, InstalledOn | sort Installedon | Select-Object HotFixID
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
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }

        $application = Read-Host -Prompt 'Input application name(e.g: java.exe or chrome.exe (something of the nature))'
        Write-output "This can take a few moments, be patient(This can take up to 10 minutes if not longer on some files\computers)"
        foreach($computer in $computers){
            $wildcard = (Get-ChildItem "\\$computer\c$\" -Recurse -Filter $application -ErrorAction SilentlyContinue )
            foreach ($WC in $wildcard) {
                Write-Output "Location is as follows"
                $WC.Fullname
                $version = $WC.VersionInfo
                Write-Output "Product Version Info is as follows"
                $version.productversion
                Write-Output "File Version Info is as follows"
                $version.fileversion
                ""
            }
        }
    }

    function edge {
        $computers = Read-Host -Prompt 'Input Computer Name for Software Check'
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }
        foreach($computer in $computers){
            $chrome = (get-item "\\$computer\C$\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo | Select ProductVersion, FileVersion
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

function activclientinstall($computer) {
    #Link to download newest activclient, now you can maintain this later on
    #https://isdp.nih.gov/isdp/version.action?prodid=127
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
        Write-Host "Install finished"
        Write-Host "Starting update"
        msiexec.exe /update C:\Temp\activclient\AC_7.1.0.244.msp /quiet /norestart
        Write-Host "Update finished"
        Write-Host "Pausing script(30 seconds) to wait for install, then checking for install completion"
        Start-Sleep -Seconds 30
        $app = Get-WmiObject -Class Win32_Product | Where-Object { 
            $_.Name -match "ActivClient" 
        }

        if ($app.name -like "ActivID ActivClient x64") {
            Write-Host "Install is Good"
        }
        else {
            Write-Host "Well install didn't work in the time it should have, investigate further"
        }
    }
    robocopy \\144.101.121.80\temp\Programs\ActivClient\7.1.0.244 \\$computer\c$\temp\activclient /S /E  /V /XO /MT:32 /R:2 /W:10
    Invoke-Command -ComputerName $computer -ScriptBlock $Scriptblock
}

function ADUserAudit {

    If (Test-Path "C:\temp\gpo\ADAudit.csv") {
        Remove-Item "c:\temp\gpo\ADAudit.csv" -Recurse -Force
    }
    Add-Content c:\temp\gpo\ADAudit.csv "Username, LastLoginDate, LastLogon, AccountExpirationDate, EmailAddress"
    $users = Get-ADUser -SearchBase “OU=SDDC_U,OU=SDDC,OU=Hood,OU=Installations,DC=nasw,DC=ds,DC=army,DC=mil” -Filter * -Properties *

    foreach ($User in $users) {   
        $username = $user.Name
        $userlld = $user.LastLogonDate
        $time = $user.LastLogon
        $dt = [DateTime]::FromFileTime($time)
        $useraed = $user.AccountExpirationDate
        $useremail = $user.EmailAddress
        Add-Content c:\temp\gpo\ADAudit.csv "$username, $userlld, $dt, $useraed, $useremail"
    }

    c:\temp\gpo\ADAudit.csv

}

function ADCompAudit {
    Write-Host "List of Functions: 1. Computer Description Audit with Descriptions intact
                   2. Computer Description Audit with Descriptions deletion"

    $option = Read-Host -Prompt "Enter Option"

    function CDADI {
        $ADCompAuditPath = "c:\temp\gpo\ADCompAudit.csv"
        if (Test-Path $ADCompAuditPath) {
            Remove-Item $ADCompAuditPath
        }
        Add-Content $ADCompAuditPath "ComputerName, AD_Description, GPO_Description, FixedWith"
        $adcomputers = Get-ADComputer -SearchBase “OU=SDDC_C,OU=SDDC,OU=Hood,OU=Installations,DC=nasw,DC=ds,DC=army,DC=mil” -Filter * -Properties * | Sort-Object
        foreach ($adcomputer in $adcomputers) {
            $adcomputer.name
            $computer = $adcomputer.name
            $ADComputerDesc = $adcomputer.Description
            if (Test-Path \\144.101.121.80\temp\gpo\*$computer*) {
                $ID = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "ComputerID" }
            }
            else {
                $ID = "GPO file does not exist for $computer"
            }
            if ($adcomputer.Description -eq $null) {
                write-host "No Description"
        
                if ($ID -eq "GPO file does not exist for $computer") {
                    Write-Host "Not setting Description on $computer"
                }
                else {
                    $ID = $ID.Replace("ComputerID=", "")
                    $goodID = $ID.Replace("_", " ")
                    $Comp = Get-ADComputer -Identity $computer 
                    $Comp.Description = $goodID
                    Set-ADComputer -Instance $Comp
                }
                Add-Content $ADCompAuditPath "$computer, $ADComputerDesc, $ID, $goodID"
            }
            else {
                $adcomputer.description
                Add-Content $ADCompAuditPath "$computer, $ADComputerDesc, $ID"
            }
        }
        C:\temp\gpo\ADCompAudit.csv

    }

    function CDADD {
        $ADCompAuditPath = "c:\temp\gpo\ADCompAudit.csv"
        if (Test-Path $ADCompAuditPath) {
            Remove-Item $ADCompAuditPath
        }
        Add-Content $ADCompAuditPath "ComputerName, AD_Description, GPO_Description, FixedWith"
        $adcomputers = Get-ADComputer -SearchBase “OU=SDDC_C,OU=SDDC,OU=Hood,OU=Installations,DC=nasw,DC=ds,DC=army,DC=mil” -Filter * -Properties * | Sort-Object
        foreach ($adcomputer in $adcomputers) {
            #$adcomputer.name
            $computer = $adcomputer.name
            $deleteddescription = $null
            $Comp = Get-ADComputer -Identity $computer 
            $Comp.Description = $deleteddescription
            Set-ADComputer -Instance $Comp
            $adcomputer = Get-ADComputer -Identity $computer
            $computer = $adcomputer.name
            #$adcomputer.name
            #$computer = $adcomputer.name
            $ADComputerDesc = $adcomputer.Description
            if (Test-Path \\144.101.121.80\temp\gpo\*$computer*) {
                $ID = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "ComputerID" }
            }
            else {
                $ID = "GPO file does not exist for $computer"
            }
            if ($adcomputer.Description -eq $null) {
                write-host "No Description"
        
                if ($ID -eq "GPO file does not exist for $computer") {
                    Write-Host "Not setting Description on $computer"
                }
                else {
                    Write-Host "Setting Description on $computer"
                    $ID = $ID.Replace("ComputerID=", "")
                    $goodID = $ID.Replace("_", " ")
                    $Comp = Get-ADComputer -Identity $computer 
                    $Comp.Description = $goodID
                    Set-ADComputer -Instance $Comp
                }
                Add-Content $ADCompAuditPath "$computer, $ADComputerDesc, $ID, $goodID"
            }
            else {
                $adcomputer.description
                Add-Content $ADCompAuditPath "$computer, $ADComputerDesc, $ID"
            }
        }
        C:\temp\gpo\ADCompAudit.csv

    }


    if ($option -eq "1") {
        CDADI
    }
    if ($option -eq "2") {
        Write-Host "This is a very dangerous option, are you sure you want to proceed?"
        $dangerous = Read-Host -Prompt "Enter Y\N"
        if ($dangerous.ToUpper() -eq "Y") {
            CDADD
        }
        elseif ($dangerous.ToUpper() -eq "N") {
        }
        elseif ($dangerous -eq "") {
            Write-Host "I need input to work....."
        
        }
    }
}

function bioscheck {
    if (Test-Path c:\temp\gpo\bioscheck.csv) {
        Remove-Item c:\temp\gpo\bioscheck.csv
        Add-Content c:\temp\gpo\bioscheck.csv "Model, Manufacturer, ComputerName, BiosVersion, SecureBoot Status, TPM Status, TPM Version, UEFI NW Stack, BiosPW, ExternalUSB"
    }
    else {
        Add-Content c:\temp\gpo\bioscheck.csv "Model, Manufacturer, ComputerName, BiosVersion, SecureBoot Status, TPM Status, TPM Version, UEFI NW Stack, BiosPW, ExternalUSB"
    }
    
    $input = Read-Host -Prompt "Would you like a singular computer or all computers?
                                    1. Singular
                                    2. All Computers
                                    "
    
    if ($input -eq "1") {
        $computers = Read-Host -Prompt "Input computer name"
    }
    elseif ($input -eq "2") {
        $computers = Get-Content \\144.101.121.80\temp\scripts\newgpo\computers.txt
    }
    
    foreach ($computer in $computers) {
        $computer = $computer.ToUpper()
        $computer
    
        $BiosVersion = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "BiosVersion:" }
        $BiosVersion = $BiosVersion -replace "BiosVersion:", ""
    
        $model = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "Model:" }
        $model = $model[1] -replace "Model:", ""
    
        $Manufacturer = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "Manufacturer:" }
        $Manufacturer = $Manufacturer[0] -replace "Manufacturer:", ""
    
        $SecureBoot = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "SecureBoot:" }
        $SecureBoot = $SecureBoot -replace "SecureBoot:", ""
    
        $TpmSecurity = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "TpmSecurity:" }
        $TpmSecurity = $TpmSecurity -replace "TpmSecurity:", ""
    
        $TpmVersion = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "TPM:" }
        $TpmVersion = $TpmVersion -replace "TPM:", ""
    
        $UefiNwStack = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "UefiNwStack:" }
        $UefiNwStack = $UefiNwStack -replace "UefiNwStack:", ""
    
        $BiosPW = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "BiosPW:" }
        $BiosPW = $BiosPW -replace "BiosPW:", ""

        $ExternalUSB = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "UsbPortsExternal:" }
        $ExternalUSB = $ExternalUSB -replace "UsbPortsExternal:", ""
    
        Add-Content c:\temp\gpo\bioscheck.csv "$model, $Manufacturer, $computer, $BiosVersion, $SecureBoot, $TpmSecurity, $TpmVersion, $UefiNwStack, $BiosPW, $ExternalUSB"
    
    }
    
    C:\temp\gpo\bioscheck.csv
    
}

#From here on down are the entries for each of the functions. They are explained either in the code or in the list that runs at the beginning

if ($func -eq '04' ) {
    $computer = Read-Host -Prompt 'Input Computer Name for PSSession'
    Enter-PSSession -Computername $computer
}

if ($func -eq '05') {
    $computer = Read-Host -Prompt 'Input Computer Name'
    psexec \\$computer -s cmd /s 
}

if ($func -eq '07') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting to enable PSRemoting on $computer"
            psexec \\$computer -s cmd /c powershell.exe Enable-PSRemoting -Force
            Write-Host "Finishing up on $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '06') {    
    $computers = Read-Host -Prompt "Input Computer Name or type Get-Content C:\temp\location of text file containing multiple computers"    
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting $computer"
            Invoke-Command -Computername $computer -ScriptBlock { Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0 }
            Invoke-Command -Computername $computer -ScriptBlock { Enable-NetFirewallRule -DisplayGroup "Remote Desktop" }
            Write-Host "Finishing $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '02') {
    $computers = Read-Host -Prompt '*This is the instant restart! Be careful! * Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '
    foreach ($computer in $computers) {
        shutdown -r -t 0 -f -m \\$computer
    }
}

if ($func -eq '08') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Getting software on $computer"
            Invoke-command -computer $computer { Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, InstallDate }
            Write-Host "End of software list on $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '15') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    $password = Read-Host -prompt "Enter new password for user *Be careful entering password* " -assecurestring
    $decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            $computer
            $user = [adsi]"WinNT://$computer/DoD_Admin"
            $user.SetPassword($decodedpassword)
            $user.UserFlags = 66049
            $user.SetInfo()
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe 
                Add-LocalGroupMember -Group "Administrators" -Member "DoD_Admin" }
            Write-Host -ForegroundColor Green "Installation successful on $computer"
            #Add-Content C:\temp\Scripts\dodadmin\success.csv  "$computer, Success"
        } 
        else {
            Write-Host -ForegroundColor Red "$computer is not online, Install failed"
            #Add-Content C:\temp\Scripts\dodadmin\failed.csv  "$computer, Down"   
        }
    }
}

if ($func -eq '14') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        Write-host "Starting on $computer"
        if (Test-Connection -ComputerName $computer -Count 1 ) {
            Invoke-Command -ComputerName $computer -ScriptBlock { Net stop ccmexec
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

if ($func -eq '03') {    
    $computers = Read-Host -Prompt "Input Computer Name or type Get-Content C:\temp\location of text file containing multiple computers"   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-host "Starting on $computer"
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" } 
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '01') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        quser /server:$computer
        $user = Read-Host -Prompt 'What user would you like to logoff? Please type in username exactly as shown in USERNAME section'   
        $userName = "$user"
        $sessionId = ((quser /server:$computer | Where-Object { $_ -match $userName }) -split ' +')[2]
        $sessionId
        logoff $sessionId /server:$computer
    }
}

if ($func -eq '11') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting Windows Update Fix on $computer"
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted }
            Invoke-Command -ComputerName $computer -ScriptBlock { net stop wuauserv
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
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '17') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-Host "Starting Registry.pol Fix on $computer"
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe move C:\windows\System32\GroupPolicy\Machine\Registry.pol C:\windows\System32\GroupPolicy\Machine\Registry_Backup.pol }
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" } 
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '09') {    
    softwarecheck
}

if ($func -eq '16') {    

    $computers = Read-Host -Prompt 'Input Computer Name, if local computer type in computername '   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            $scriptblock = {
                reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}" /v UpperFilters /f
                reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}" /v LowerFilters /f
            }
            Write-Host "Starting USB Registry Fix on $computer"
            Invoke-Command -ComputerName $computer -scriptblock $scriptblock
            Write-host "THIS NEEDS A RESTART"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '13') {
    $computer = Read-Host -Prompt 'Input Computer Name'
    activclientinstall($computer)
}

if ($func -eq '34') {
    ADUserAudit
}

if ($func -eq '35') {
    ADCompAudit
}

if($func -eq '10'){
    bioscheck
}

if($func -eq '12'){
$computers = Read-Host -Prompt "Input Computer Name or type location of text file" 
$online = "null"

ForEach ($computer in $computers) {
    If (Test-Connection $computer -Quiet -Count 2) {
        $quserResult = quser /server:$computer
        $users = Get-ChildItem "\\$computer\C$\Users"
        If ( $quserResult.Count -gt 0 ) {
            $quserRegex = $quserResult | ForEach-Object -Process { $_ -replace '\s{2,}', ',' }
            $quserObject = $quserRegex | ConvertFrom-Csv
            $onlines = $quserObject.USERNAME}
        ElseIf ($quserResult.Count -lt 1) { 
            $users
            $onlines = Read-Host -Prompt "No one is logged in. Would you like to enter a username?"}
            Write-Output "Users online are $onlines"
            Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\json" "\\$computer\C$\Program Files\Mozilla Firefox\distribution" policies.json /z /r:2 /w:5
            Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\Firefox_certificates\" "\\$computer\C$\Windows\Admin\Firefox_certificates\" /z /r:2 /w:5
            ForEach ($online in $onlines) {
                Write-Output "Current user is $online"
                If (Test-Path "\\144.101.121.80\userdata\$online\AppData\Roaming\Mozilla\Firefox\Profiles") {
                    $ProfileFolder = (Get-ChildItem "\\144.101.121.80\userdata\$online\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter *.default-esr).FullName
                    Write-Output $ProfileFolder
                    If (Test-Path $ProfileFolder) {
                        $acl = Get-Acl $ProfileFolder
                        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("SDDC_SA","FullControl","Allow")
                        $acl.SetAccessRule($AccessRule)
                        $acl | Set-Acl $ProfileFolder
                        Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\user_prefs\" "$ProfileFolder" user.js /z /r:2 /w:5
                        Write-Output "$ProfileFolder is $onlines Profile Folder"
                    }
                    Else { Write-Output "$online has No Profile Folder" }
                    Write-Output "Looking for local accounts"
                    ForEach ($user in $users) {
                        If (Test-Path "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles") {
                            $LocalFolder = (Get-ChildItem "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter *.default-esr).FullName
                            If ($LocalFolder -ne $null) {
                                Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\user_prefs\" "$LocalFolder" user.js /z /r:2 /w:5
                                Write-Output "$LocalFolder is $user Local Folder"
                            }
                            Else { Write-Output "$user has no local folder" }
                        }
                        Else {Write-Output "$user does not have a profiles folder"}
                    }
                }
                Else {Write-Output "$online does not have an online profile"
                                        Write-Output "Looking for local accounts"
                    ForEach ($user in $users) {
                        If (Test-Path "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles") {
                            $LocalFolder = (Get-ChildItem "\\$computer\C$\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles" -Filter *.default-esr).FullName
                            If ($LocalFolder -ne $null) {
                                Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\user_prefs\" "$LocalFolder" user.js /z /r:2 /w:5
                                Write-Output "$LocalFolder is $user Local Folder"
                            }
                            Else { Write-Output "$user has no local folder" }
                        }
                        Else {Write-Output "$user does not have a profiles folder"}
                    }
                }
            }
        }

    Else {
        Write-Output "$computer could not be reached"
        }
    }
    }

if($func -eq '20') {
    $dcs=Get-ADDomainController -Filter * 
    $dccount=$dcs | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "Active Directory Domain Controller ($env:userdnsdomain)" 
    $domdc=@()
    foreach ($dc in $dcs) {
        $domdc += New-Object -TypeName PSObject -Property (
        [ordered]@{
        'Name' = $dc.Name
        'IP Address' = $dc.IPv4Address
        'OS' = $dc.OperatingSystem
        'Site' = $dc.Site
        'Global Catalog' = $dc.IsGlobalCatalog
        'FSMO Roles' = $dc.OperationMasterRoles -join ','
        })
	}  
    $domdc | Format-Table -AutoSize -Wrap
    Write-Host 'Total Number: '$dccount"" -ForegroundColor Yellow
    $ping=Read-Host "Do you want to test connectivity (ping) to these Domain Controllers? (Y/N)"
    If ($ping -eq 'Y') {
	    foreach ($items in $dcs.Name) {
	        Test-Connection $items -Count 1 | Format-Table Address, IPv4Address, ReplySize, ResponseTime}
            Read-Host 'Press 0 and Enter to continue'
            } 
    else {
        Read-Host 'Press 0 and Enter to continue'
        }
  }

if($func -eq '19') { 
    Write-Host "This sub-menu replicates all Domain Controller on all Sites of the Domain $env:userdnsdomain."
    Write-Host 'START REPLICATION?' -ForegroundColor Yellow
    $startr=Read-Host 'Y/N'
    If ($startr) {
        (Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess | Out-Host
        }
  }

if($func -eq '28') {
    Write-Host -ForegroundColor Green 'The Default Domain Policy is configured as follows:'`n 
    Get-ADDefaultDomainPasswordPolicy | Format-List ComplexityEnabled, LockoutDuration,LockoutObservationWindow,LockoutThreshold,MaxPasswordAge,MinPasswordAge,MinPasswordLength,PasswordHistoryCount,ReversibleEncryptionEnabled
    Read-Host 'Press 0 and Enter to continue' 
    } 

if($func -eq '24') {
    Write-Host -ForegroundColor Green 'The following users are member of the Domain Admins group:'`n
    $sid=(Get-ADDomain).DomainSid.Value + '-512'
    Get-ADGroupMember -identity $sid | Format-Table Name,SamAccountName,SID -AutoSize -Wrap
    Read-Host 'Press 0 and Enter to continue'
    } 

if($func -eq '21') {
    Write-Host -ForegroundColor Green 'The GPOs below are linked to AD Objects:'`n 
    Get-GPO -All | ForEach-Object {
    If ( $_ | Get-GPOReport -ReportType XML | Select-String '<LinksTo>' ) {
        Write-Host $_.DisplayName}}
        Read-Host 'Press 0 and Enter to continue'
        }

if($func -eq '22') {
    $client=Get-ADComputer -Filter {operatingsystem -notlike '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address 
    $ccount=$client | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "Windows Clients $env:userdnsdomain"
    Write-Output $client | Sort-Object Operatingsystem | Format-Table Name,Operatingsystem,OperatingSystemVersion,IPv4Address -AutoSize
    Write-Host 'Total: '$ccount"" -ForegroundColor Yellow
    Read-Host 'Press 0 and Enter to continue'
    }

if($func -eq '23') {
    $server=Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address 
    $scount=$server | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "Windows Server $env:userdnsdomain" 
    Write-Output $server | Sort-Object Operatingsystem | Format-Table Name,Operatingsystem,OperatingSystemVersion,IPv4Address
    Write-Host 'Total: '$scount"" -ForegroundColor Yellow
    Read-Host 'Press 0 and Enter to continue'
    }

if($func -eq 'XXX')  {   
    do {
        Write-Host 'This runs systeminfo on specific computers. Select scope:' -ForegroundColor Green
        Write-Host '1 - Localhost' -ForegroundColor Yellow
        Write-Host '2 - Remote Computer (Enter Computername)' -ForegroundColor Yellow
        Write-Host '3 - All Windows Server' -ForegroundColor Yellow
        Write-Host '4 - All Windows Computer' -ForegroundColor Yellow
        Write-Host '0 - Quit' -ForegroundColor Yellow
        Write-Host ''
        $scopesi=Read-Host 'Select'
        $header='Host Name','OS','Version','Manufacturer','Configuration','Build Type','Registered Owner','Registered Organization','Product ID','Install Date','Boot Time','System Manufacturer','Model','Type','Processor','Bios','Windows Directory','System Directory','Boot Device','Language','Keyboard','Time Zone','Total Physical Memory','Available Physical Memory','Virtual Memory','Virtual Memory Available','Virtual Memory in Use','Page File','Domain','Logon Server','Hotfix','Network Card','Hyper-V'
        switch ($scopesi) {
        1 {
            & "$env:windir\system32\systeminfo.exe" /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header | Out-Host
          }
        2 {
            Write-Host 'Separate multiple computernames by comma. (example: server01,server02)' -ForegroundColor Yellow
            $comps=Read-Host 'Enter computername'
            $comp=$comps.Split(',')
            $cred=Get-Credential -Message 'Enter Username and Password of a Member of the Domain Admins Group'
            Invoke-Command -ComputerName $comps -Credential $cred {systeminfo /FO CSV | Select-Object -Skip 1} -ErrorAction SilentlyContinue | ConvertFrom-Csv -Header $header | Out-Host
            }
        3 { 
            $cred=Get-Credential -Message 'Enter Username and Password of a Member of the Domain Admins Group'
            Invoke-Command -ComputerName (Get-ADComputer -Filter {operatingsystem -like '*server*'}).Name -Credential $cred {systeminfo /FO CSV | Select-Object -Skip 1} -ErrorAction SilentlyContinue | ConvertFrom-Csv -Header $header | Out-Host
            }
        4 {
            $cred=Get-Credential -Message 'Enter Username and Password of a Member of the Domain Admins Group'
            Invoke-Command -ComputerName (Get-ADComputer -Filter *).Name -Credential $cred {systeminfo /FO CSV | Select-Object -Skip 1} -ErrorAction SilentlyContinue | ConvertFrom-Csv -Header $header | Out-Host
            }
            }  
            }
    while ($scopesi -ne '0')
   }

if($func -eq '32') {
    Write-Host 'This sections moves Computer Accounts to an OU.' -ForegroundColor Green
    do {
        Write-Host 'Enter Computer Name or Q to quit' -ForegroundColor Yellow
        $comp=Read-Host 'Computer Name'
        $c=Get-ADComputer -Filter 'name -like $comp' -Properties CanonicalName -ErrorAction SilentlyContinue
        $cfound=$c.Name
        If ($comp -eq 'Q') {Break}
        If ($cfound){
            $discfound=$c.CanonicalName
            Write-host -foregroundcolor Green "$comp in $discfound found!"
            }
    elseif (!$cfound) {
        Write-Host -ForegroundColor Red "$comp not found. Please try again."}
        }
    while (!$cfound)
        do {
            If (($comp -eq 'Q') -or (!$cfound)) {Break}
                $Domain=(Get-ADDomain).DistinguishedName
                Write-Host 'Enter Name of OU (e.g. HR) or Q to quit' -ForegroundColor Yellow
                $OU=Read-Host 'Enter OU Name'
                $OUfound=Get-ADOrganizationalUnit -Filter 'name -like $OU'
            If ($OU -eq 'Q') {Break}
            If ($OUfound){
                Write-host -foregroundcolor Green "$OUfound found!"
                }
            elseif (!$OUfound) {
                Write-Host -ForegroundColor Red "$OU not found. Please try again."
                }
            }
    while (!$OUfound)
        If ($comp -eq 'Q') {Break}
        If ($OUfound -and $cfound) {
            Write-Host "Are you sure you want to move Computer $cfound to $OUfound ?" -ForegroundColor Yellow
            $dec=Read-Host "Press Y or any other key to abort"}
        If ($dec -eq "Y"){
            $dis=$OUfound.DistinguishedName
            Get-ADComputer $cfound | Move-ADObject -TargetPath "$dis"
            Write-Host "Computer $cfound moved to $OUfound" -ForegroundColor Green
            Get-ADComputer -Identity $cfound | Select-Object Name,DistinguishedName,Enabled,SID | Out-Host
            }
else {
    Write-Host 'OPERATION ABORTED' -ForegroundColor Red
    }
    Read-Host 'Press 0 and Enter to continue'
    } 

 if($func -eq '27') {
    do {
        $groupm=Read-Host 'Enter group name'
        Write-Host "Group Members of $groupm" -ForegroundColor Green
        Get-ADGroupMember $groupm | Format-Table Name,SamAccountName,SID -AutoSize -Wrap
        $input=Read-Host 'Quit searching groups? (Y/N)'
        }
    while ($input -eq 'N')
    }

 if($func -eq '25') {
    do {
        $userp=Read-Host 'Enter user logon name'
        Write-Host "Details of user $userp" -ForegroundColor Green
        Get-ADUser $userp -Properties * | Format-List GivenName,SurName,DistinguishedName,Enabled,EmailAddress,ProfilePath,ScriptPath,MemberOf,LastLogonDate,whencreated
        $input=Read-Host 'Quit searching users? (Y/N)'
        }
    while ($input -eq 'N')
    }

 if($func -eq '29') { 
    Write-Host "This section shows the latest Users Active Directory Logon based on all Domain Controllers of $env:userdnsdomain." -ForegroundColor Green    
    do {
    do {
        Write-Host 'Enter USER LOGON NAME (Q to quit)' -ForegroundColor Yellow
        $userl=Read-Host 'USER LOGON NAME'
        If ($userl -eq 'Q') {Break}
            $ds=dsquery user -samid $userl
        If ($ds){
            Write-Host "User $userl found! Please wait ... contacting all Domain Controllers ... Showing results from most current DC ..." -ForegroundColor Green
            }
        else {
            Write-Host "User $userl not found. Try again" -ForegroundColor Red}
            }
        while (!$ds)
            $resultlogon=@()
        If ($userl -eq 'Q') {Break}
            $getdc=(Get-ADDomainController -Filter *).Name
        foreach ($dc in $getdc) {
            Try {
                $user=Get-ADUser $userl -Server $dc -Properties lastlogon -ErrorAction Stop
                $resultlogon+=New-Object -TypeName PSObject -Property ([ordered]@{
                'Most current DC' = $dc
                'User' = $user.Name
                'LastLogon' = [datetime]::FromFileTime($user.'lastLogon')
                })}
            Catch {
                Write-Host "No reports from $dc!" -ForegroundColor Red
                }
            }
        If ($userl -eq 'Q') {Break}
            $resultlogon | Where-Object {$_.lastlogon -NotLike '*1601*'} | Sort-Object LastLogon -Descending | Select-Object -First 1 | Format-Table -AutoSize
        If (($resultlogon | Where-Object {$_.lastlogon -NotLike '*1601*'}) -EQ $null){
            Write-Host "All domain controllers report that the user"$user.name"has never logged on til now." -ForegroundColor Red}
            Write-Host 'Search again? Press Y or any other key to quit ' -ForegroundColor Yellow
            $input=Read-Host 'Enter (Y/N)'    
        }
    while ($input -eq 'Y')
    }

 if($func -eq '33') {    
    do {
        Write-Host 'To which computers should a message be sent?'
        Write-Host '1 - Localhost' -ForegroundColor Yellow
        Write-Host '2 - Remote Computer (Enter Computername)' -ForegroundColor Yellow
        Write-Host '3 - All Windows Server' -ForegroundColor Yellow
        Write-Host '4 - All Windows Computer' -ForegroundColor Yellow
        Write-Host '0 - Quit' -ForegroundColor Yell
        $scopemsg=Read-Host 'Select'
        switch ($scopemsg) {
        1 {
            Write-Host 'Enter message sent to all users logged on LOCALHOST' -ForegroundColor Yellow
            $msg=Read-Host 'Message'
            msg * "$msg"
          }
        2 {
            Write-Host 'Separate multiple computernames by comma. (example: server01,server02)' -ForegroundColor Yellow
            $comp=Read-Host 'Enter Computername'
            $comps=$comp.Split(',')
            $msg=Read-Host 'Enter Message'
            $cred=Get-Credential -Message 'Enter Username and Password of a Member of the Domain Admins Group'
            Invoke-Command -ComputerName $comps -Credential $cred -ScriptBlock {msg * $using:msg}
          } 
        3 {
            Write-Host 'Note that the message will be sent to all servers!' -ForegroundColor Yellow
            $msg=Read-Host 'Enter Message'
            $cred=Get-Credential -Message 'Enter Username and Password of a Member of the Domain Admins Group'
            (Get-ADComputer -Filter {operatingsystem -like '*server*'}).Name | Foreach-Object {Invoke-Command -ComputerName $_ -ScriptBlock {msg * $using:msg} -Credential $cred -ErrorAction SilentlyContinue}}
         4 { 
            Write-Host 'Note that the message will be sent to all computers!' -ForegroundColor Yellow
            $msg=Read-Host 'Enter Message'
            $cred=Get-Credential -Message 'Enter Username and Password of a Member of the Domain Admins Group'
            (Get-ADComputer -Filter *).Name | Foreach-Object {Invoke-Command -ComputerName $_ -ScriptBlock {msg * $using:msg} -Credential $cred -ErrorAction SilentlyContinue}}
           }}
    while ($scopemsg -ne '0')
    }

 if($func -eq '30') {
    Write-Host 'Enter U for searching orphaned USER accounts or C for COMPUTER accounts or Q to quit' -ForegroundColor Yellow
    $orp=Read-Host 'Enter (U/C)'
    If ($orp -eq 'Q')
        {Break}
    Write-Host 'Enter time span in DAYS in which USERS or COMPUTERS have not logged on since today. Example: If you enter 365 days, the system searches for all users/computers who have not logged on for a year.' -ForegroundColor Yellow
    $span=Read-Host 'Timespan'
    If ($orp -eq 'U') {
        Write-Host "The following USERS are enabled and have not logged on for $span days:" -ForegroundColor Green
        Get-ADUser -Filter 'enabled -ne $false' -Properties LastLogonDate,whenCreated | Where-Object {$_.lastlogondate -ne $null -and $_.lastlogondate -le ((get-date).adddays(-$span))} | Format-Table Name,SamAccountName,LastLogonDate,whenCreated
        Write-Host 'User and Computer Logons are replicated every 14 days. Data might be not completely up-to-date.' -ForegroundColor Yellow
        Read-Host 'Press 0 and Enter to continue'
        }
    If ($orp -eq 'C') {
        Write-Host "The following COMPUTERS are enabled have not logged on for $span days:" -ForegroundColor Green
        Get-ADComputer -Filter 'enabled -ne $false' -Properties LastLogonDate,whenCreated | Where-Object {$_.lastlogondate -ne $null -and $_.lastlogondate -le ((get-date).adddays(-$span))} | Format-Table Name,SamAccountName,LastLogonDate,whenCreated
        Write-Host 'User and Computer Logons are replicated every 14 days. Data might be not completely up-to-date.' -ForegroundColor Yellow
        Read-Host 'Press 0 and Enter to continue'
        }
   }

 if($func -eq '31') {
    Write-Host "This menu item deactivates an AD User in the domain $env:userdnsdomain." -ForegroundColor Yellow
    do {
        $a=Read-Host 'Enter LOGON NAME of the user to be deactivated (Q to quit)'
    If ($a -eq 'Q') {Break}
    If (dsquery user -samid $a){
        Write-host -foregroundcolor Green "AD User $a found!"
        }
    elseif ($a = "null") {
        Write-Host -ForegroundColor Red "AD User not found. Please try again."
        }
        }
    while ($a -eq "null")
        If ($a -eq 'Q') {Break}
            $det=((Get-ADuser -Identity $a).GivenName + ' ' + (Get-ADUser -Identity $a).SurName)
            Write-Host "User $det will be deactivated. Are you sure? (Y/N)" -ForegroundColor Yellow
            $sure=Read-Host 'Enter (Y/N)'
        If ($sure -eq 'Y'){
            Get-ADUser -Identity "$a" | Set-ADUser -Enabled $false
            Write-Host -ForegroundColor Green "User $a has been deactivated."
            $b=Read-Host "Do you want to remove all group memberships from that user ($a)? (Y/N)"
        If ($b -eq 'Y') {
            $ADgroups = Get-ADPrincipalGroupMembership -Identity "$a" | where {$_.Name -ne 'Domain Users'}
        If ($ADgroups -ne $null) {
            Remove-ADPrincipalGroupMembership -Identity "$a" -MemberOf $ADgroups -Confirm:$false -WarningAction SilentlyContinue -ErrorAction Ignore}
            } 
         }
        else {Break}
    Write-Host 'The following user has been deactivated by the Active Directory Services Section Tool:' -ForegroundColor Green
    Get-ADUser $a -Properties * | Format-List GivenName,SurName,DistinguishedName,Enabled,MemberOf,LastLogonDate,whencreated
    Read-Host 'Press 0 and Enter to continue'
    }

else { }
