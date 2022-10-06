<#    
  
.DESCRIPTION 
  Script for administrators to run various functions from a machine  

.LOCATION
   Script
   c:\temp\gpo
   
   
  .NOTES 
    FileName:    toolkit.ps1 
    Author:      Tyler Neely 
    Created:     2021-07-30
    Updated:     2022-02-10



#>

#Writes to the cli to indicate what functions are available to the admin
Write-Host "List of Functions: 1. Copies newest GPO folder to local machine
                   2. PSSession into machine
                   3. 5 minute restart
                   4. Pulls what is in the ID.gpo on the defined machine
                   5. Pulls and changes ID.gpo on the machines temp folder
                   6. PSEXEC session into machine
                   7. Instant restart on machine
                   8. Runs the procedures to have machines report back to SCCM
                   9. Create/Add to administrators/Set password for DoD_Admin
                   10. Get Remote Computer Installed apps and date of installation
                   11. Enable PSRemoting on remote machine
                   12. Enable RDP on remote machine
                   13. Will Run 2 gpupdate /force on a remote machine
                   14. Will prompt and logoff user from machine
                   15. Run GPO on machine
                   16. Windows Update Fix
                   17. Select if you would like to run GPO Report
                   18. DynamicGPO
                   19. Run the update report
                   20. Rename the Registry.pol file(only use as last resort
                       if gpupdate is failing(this will ruin the computer if you don't
                       know what you are doing))
                   21. Application Version Checker
                   22. Registry Fix for USB issue
                   23. Uninstall and Re-install ActivClient(7.1.0.244)
                   24. AD User Audit
                   25. AD Computer Audit
                   26. Workstation Spreadsheet Updater
                   27. BiosCheck
                   28. Firefox Certificates
                   29. Java Fix
                   30. RFID Driver Install
                   "

#Asks the user what function they would like to start using
$func = Read-Host -Prompt 'Please insert the function number of the  you would like to use'

#Determines if the user entry is empty or not
if ( ([string]::IsNullOrEmpty($func))) {
    Write-Host "Toolkit cannot work without input..."
}

#From here on down until noted by next comment are functions, these functions will be called if you chose the correct option

function GPOREPORT {
    Remove-Item c:\temp\gpo\GPOREPORT.CSV -Recurse

    $today = Get-Date -Format yyyyMMdd

    $reportfiles = Get-ChildItem "\\144.101.121.80\temp\gpo\" -Filter *.gpo | Where-Object { $_.LastWriteTime.ToString('yyyyMMdd') -lt $today }
    foreach ($file in $reportfiles) {

        $ID = get-content \\144.101.121.80\temp\gpo\$file -ReadCount 1000 |
        ForEach-Object { $_ -match "ComputerID" }

        $Name = get-content \\144.101.121.80\temp\gpo\$file -ReadCount 1000 |
        ForEach-Object { $_ -match "ComputerName:" }

        $UserName = get-content \\144.101.121.80\temp\gpo\$file -ReadCount 1000 |
        ForEach-Object { $_ -match "User:" }

        $UserName = $UserName -replace '\s', ''
        $Name = $Name -replace '\s', ''
        $ID = $ID -replace '\s', ''

        if ( ([string]::IsNullOrEmpty($Name))) {
            Continue
        }

        if ( ([string]::IsNullOrEmpty($ID))) {
            Continue
        }
        if (-not ([string]::IsNullOrEmpty($ID))) {
            Write-Host $ID
            if (-not ([string]::IsNullOrEmpty($Name))) {
                Write-Host $Name
                "$ID, $Name, $UserName" | Add-Content c:\temp\gpo\GPOREPORT.csv
            }
        }
    }
    C:\temp\gpo\GPOREPORT.csv
}

function dynamicgpo {
    function whatfailed {
        $Computers = Get-Content "\\144.101.121.80\temp\scripts\newgpo\computers.txt"
        $OutFile = "C:\temp\scripts\dynamicgpo\failed.csv"
        $today = (Get-Date).ToString('yyyyMMdd')
        Remove-Item C:\temp\scripts\dynamicgpo\failed.csv
        Remove-Item C:\temp\scripts\dynamicgpo\success.csv
        #Erase an existing output file so as not to duplicate data
        #out-file -filepath $OutFile

        foreach ($Computer in $Computers) {
            if (test-path \\144.101.121.80\temp\gpo\*$computer*) {
                #test to make sure the file exists
                #Get the CreationTime value from the file
                $FileDate = (Get-ChildItem \\144.101.121.80\temp\gpo\*$computer*).LastWriteTime
                if ($FileDate.ToString('yyyyMMdd') -eq $today) {
                    $computer
                    Start-Sleep .5
                    "$Computer" | Add-Content "C:\temp\scripts\dynamicgpo\success.csv"
                }
                else {
                    Write-Host "Adding $computer to FAILED"
                    "$Computer" | Add-Content $OutFile
                }
                #Write the computer name and File date separated by a unique character you can open in Excel easy with"
            }
            else {
                #File did not exist, write that to the log also
                Write-Host "File NO EXIST: Adding $computer to FAILED"
                "$Computer" | Add-Content $OutFile 
            }
        }
    }

    function dynamicgpo {
        $computers = Get-Content \\144.101.121.80\temp\scripts\dynamicgpo\allcomputers.txt
        Remove-Item \\144.101.121.80\temp\scripts\dynamicgpo\running.csv
        Remove-Item \\144.101.121.80\temp\scripts\dynamicgpo\offline.csv
        $final = @()
        $offline = @()
        $computerbyip = @()
        $failed = Get-Content C:\temp\scripts\dynamicgpo\failed.csv

        $computersfinal = @()
        #create/run a Ping job for all $servers
        $computers | ForEach-Object { Set-Variable -Name "Status_$_" -Value (Test-Connection -ComputerName $_ -AsJob -Count 1) }

        #check the results of each ping job 
        Get-Variable "Status_*" -ValueOnly | ForEach-Object {
            $Status = Wait-Job $_ | Receive-Job 
            if ($Status.ResponseTime -ne $null ) {
                #Write-Host "$($Status.Address) is reachable" -ForegroundColor Green
                $computersfinal += $status.Address
            }
            else {
                #Write-Host "$($Status.Address) could not be reached." -ForegroundColor Red
            }
        }
        $computersfinal
        foreach ($computer in $computersfinal) {
            #if(test-Connection -Cn $computer -Count 1 -Quiet ){
            Write-Output "Trying on $computer"
            $hostname = Get-WMIObject -ComputerName $computer Win32_ComputerSystem | Select-Object -ExpandProperty name
            #$version = 'test'
            if (-not ([string]::IsNullOrEmpty($hostname))) {
                $final += $hostname
                if ($failed -match $hostname) {
                    Write-Host "Adding $computer to IP list"
                    $computerbyip += $computer
                }
            }
            else {
                
            }
        }

        $script:computerbyip = $computerbyip

        Write-Host $computerbyip -ForegroundColor Cyan

        foreach ($computer in $computerbyip) {
            if (test-Connection -Cn $computer -Count 2 ) {
                Write-Host "Starting GPO on $computer"
                robocopy \\144.101.121.80\temp\scripts\newgpo\gpo \\$computer\c$\temp\gpo /S /E  /V /XO /MT:32 /R:2 /W:10
                psexec \\$computer -s cmd /c c:\temp\gpo\runme.bat
                Write-Host "Finishing up GPO on $computer"
            }
            else { 
                Write-Host "Cannot reach $computer"
            }
        }
    }

    foreach ($computer in $computerbyip) {
        if (test-Connection -Cn $computer -Count 2 ) {
            Write-Host "Starting RegisterDNS on $computer"
            psexec \\$computer -s cmd /c "ipconfig /registerdns"
            Write-Host "Finishing up RegisterDNS on $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
    whatfailed
    dynamicgpo
    $computerbyip
}

function updatereport {
    Remove-Item c:\temp\gpo\updatereport.CSV -Recurse

    $today = Get-Date -Format yyyyMMdd

    $reportfiles = Get-ChildItem "\\144.101.121.80\temp\gpo\" -Filter *.gpo | Where-Object { $_.LastWriteTime.ToString('yyyyMMdd') -lt $today }
    foreach ($file in $reportfiles) {

        $update = get-content \\144.101.121.80\temp\gpo\$file -ReadCount 1000 |
        ForEach-Object { $_ -match "Update-Status=" }

        $Name = get-content \\144.101.121.80\temp\gpo\$file -ReadCount 1000 |
        ForEach-Object { $_ -match "ComputerName:" }

        $Name = $Name -replace '\s', ''
        $update = $update -replace '\s', ''

        if ( ([string]::IsNullOrEmpty($Name))) {
            Continue
        }

        if ( ([string]::IsNullOrEmpty($update))) {
            Continue
        }

        if (-not ([string]::IsNullOrEmpty($update))) {
            Write-Host $update
            if (-not ([string]::IsNullOrEmpty($Name))) {
                Write-Host $Name
                "$Name, $update" | Add-Content c:\temp\gpo\updatereport.csv
            }
        }
    }
    C:\temp\gpo\updatereport.csv
}

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

function WorkstationSpreadsheetUpdater {

$today = (Get-Date).ToString('yyyyMMddHHmm')
Copy-Item -Path "\\143.71.76.76\share\S6\IM\Accountability\Workstation Accountability\Current Worksheet Accountability Spreadsheets\baseworkstationspreadsheet.xlsx" -Destination "\\143.71.76.76\share\S6\IM\Accountability\Workstation Accountability\Current Worksheet Accountability Spreadsheets\$today.WorkstationSpreadsheet.xlsx"

$endobjexcel = New-Object -ComObject Excel.Application
$endBook = $endobjExcel.Workbooks.Open("\\143.71.76.76\share\S6\IM\Accountability\Workstation Accountability\Current Worksheet Accountability Spreadsheets\$today.WorkstationSpreadsheet.xlsx")

$endobjExcel.Visible = $false
$endSheet = $endBook.sheets.item(1)
$rowMax = ($endsheet.usedrange.rows).count
$rowcompname, $colcompname = "A1"
#$computers = "SDDC05NB842DL09", "SDDC05NB842DL10", "SDDC05NB842DL30"
$computers = Get-Content \\144.101.121.80\temp\scripts\newgpo\computers.txt



foreach ($computer in $computers) {
    Write-Host "Starting on $computer"
    $adapters = @()
    $getName = $endsheet.Range("A1:A$rowmax").find($computer)
    $cellAddress = $getName.Address($false, $false)
    $row = $getName.Row
    $column = $getName.Column
    if (Test-Path \\144.101.121.80\temp\gpo\*$computer*) {
        if (Test-Path \\144.101.121.80\temp\gpo\*$computer*) {
            $adaptcount = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "AdapterCount:" }
        }
        $adaptcount = $adaptcount.Replace("AdapterCount:", "")
    
        For ($i = 1; $i -le $adaptcount; $i++) {
            $adapter = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "AdapterNumber$i" }
            $adapter = $adapter.Replace("AdapterNumber$i", "")
            $adapter = $adapter.Replace(":", "")
            $adapters += $adapter
            $adaptermac = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "AdapterMac$i" }
            $adaptermac = $adaptermac.Replace("AdapterMac$i", "")
            $adaptermac = $adaptermac.Replace(":", "")
            $adapters += $adaptermac
        }
        #$adaptcount
        #$row
        #$column
        #Write-Host $cellAddress
        $adaptersfinal = ""
        foreach ($adapter in $adapters) {
            $adaptersfinal += $adapter
    
            if ($adapter -eq $adapters[-1])
            { }
            else {
                $adaptersfinal += "`r`n"
            }

        }
    
        $adpcolumn = $column + 1
        $endSheet.cells.item($row, $adpcolumn) = $adaptersfinal

        $room = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "Location:" }
        $room = $room -replace "Location:", ""
        $roomcolumn = $column + 2
        $endSheet.cells.item($row, $roomcolumn) = $room

        $phone = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "Phone:" }
        $phone = $phone -replace "Phone:", ""
        $phonecolumn = $column + 3
        $endSheet.cells.item($row, $phonecolumn) = $phone

        $user = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "User:" }
        $user = $user -replace "User:", ""
        $usercolumn = $column + 4
        $endSheet.cells.item($row, $usercolumn) = $user

        $model = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "Model:" }
        $model = $model[1] -replace "Model:", ""
        $modelcolumn = $column + 5
        $endSheet.cells.item($row, $modelcolumn) = $model

        $serialnumber = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "SN:" }
        $serialnumber = $serialnumber -replace "SN:", ""
        $serialnumbercolumn = $column + 6
        $endSheet.cells.item($row, $serialnumbercolumn) = $serialnumber

        $lockcombo = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "Lock:" }
        $lockcombo = $lockcombo -replace "Lock:", ""
        $lockcombocolumn = $column + 7
        $endSheet.cells.item($row, $lockcombocolumn) = $lockcombo

        $monitorstats = @()
        if (Test-Path \\144.101.121.80\temp\gpo\*$computer*) {
            $monitorcount = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "MonitorCount:" }
        }

        $monitorcount = $monitorcount.Replace("MonitorCount:", "")
    
        For ($i = 1; $i -le $monitorcount; $i++) {
            $monitormanufacturer = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "MonitorManufacturer$i" }
            $monitormanufacturer = $monitormanufacturer.Replace("MonitorManufacturer$i", "")
            $monitormanufacturer = $monitormanufacturer.Replace(":", "")
            $monitorstats += $monitormanufacturer
            $monitorname = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "MonitorName$i" }
            $monitorname = $monitorname.Replace("MonitorName$i", "")
            $monitorname = $monitorname.Replace(":", "")
            $monitorstats += $monitorname
            $monitorserial = get-content \\144.101.121.80\temp\gpo\*$computer* -ReadCount 1000 | ForEach-Object { $_ -match "MonitorSerial$i" }
            $monitorserial = $monitorserial.Replace("MonitorSerial$i", "")
            $monitorserial = $monitorserial.Replace(":", "")
            $monitorstats += $monitorserial
        }

        $monitorstatsfinal = ""
        foreach ($stat in $monitorstats) {
            $monitorstatsfinal += $stat
    
            if ($stat -eq $monitorstats[-1])
            { }
            else {
                $monitorstatsfinal += "`r`n"
            }

        }

        $monitorcolumn = $column + 8
        $endSheet.cells.item($row, $monitorcolumn) = $monitorstatsfinal
    }

    #To Do
    #PH#	User	System Model	Serial Number	Lock Combo	Monitor Serial

}

$endBook.save()
$endBook.close()
$endobjExcel.Quit()
$endobjExcel.quit()

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

if ($func -eq '1' ) {
    robocopy \\144.101.121.80\temp\scripts\newgpo\gpo c:\temp\gpo
}
else { }


if ($func -eq '2' ) {
    $computer = Read-Host -Prompt 'Input Computer Name for PSSession'
    Enter-PSSession -Computername $computer
}
    
if ($func -eq '3') {
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '
    foreach ($computer in $computers) {
        psexec \\$computer -s cmd /c shutdown -r -t 300 /c "Your computer will restart in 5 minutes, Please save all documents and log off" -f
        $today = (Get-Date).ToString('hhmm')
        $today
    }
}

if ($func -eq '4') {  
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '
    foreach ($computer in $computers) {
        $file = "\\$computer\C$\temp\ID.gpo"
        Write-Host "Starting on $computer"
        if (Test-Connection -ComputerName $computer -Count 1 ) {
            if (Test-Path $file) {
                $description = Get-Content ($file)
                Write-Host $description
            }
        }
    }
}

if ($func -eq '5') {
    $computer = Read-Host -Prompt 'Input Computer Name'
    $file = "\\$computer\C$\temp\ID.gpo"
    if(!(Test-Path $file)){
        "" >> \\$computer\c$\temp\ID.gpo
        $file = "\\$computer\C$\temp\ID.gpo"
        }
    Write-Host "Starting on $computer"
    if (Test-Path $file) {
        $description = Get-Content ($file)
        Write-Host $description
        $location = Read-Host -Prompt "Input Computers Location"
        $user = Read-Host -Prompt "Input User"
        $phone = Read-Host -Prompt "Input Phone Number"
        $lock = Read-Host -Prompt "Input Lock Number"
        $outport = Read-Host -Prompt "Input OutPort"

        $ID = "Location:$location
User:$user
Phone:$phone
Lock:$lock
Outport:$outport"

        $ID > \\$computer\c$\temp\ID.gpo
    }
    else {
        Write-Output "File does not exist"
    }
}

if ($func -eq '6') {
    $computer = Read-Host -Prompt 'Input Computer Name'
    psexec \\$computer -s cmd /s 
}

if ($func -eq '7') {
    $computers = Read-Host -Prompt '*This is the instant restart! Be careful! * Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '
    foreach ($computer in $computers) {
        shutdown -r -t 0 -f -m \\$computer
    }
}

if ($func -eq '8') {    
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

if ($func -eq '9') {    
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

if ($func -eq '10') {    
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

if ($func -eq '11') {    
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

if ($func -eq '12') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
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

if ($func -eq '13') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            Write-host "Starting on $computer"
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" } 
            Invoke-Command -ComputerName $computer -ScriptBlock { powershell.exe "gpupdate /force" }
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '14') {    
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

if ($func -eq '15') {    
    $computers = Read-Host -Prompt 'Input Computer Name or type location of text file" ' 
    if($computers -match "\\"){
        $computers = Get-Content $computers
        }
    foreach ($computer in $computers) {
        if (test-Connection -Cn $computer -Count 1 ) {
            robocopy \\144.101.121.80\temp\scripts\newgpo\gpo \\$computer\c$\temp\gpo /W:5 /R:2
            robocopy \\144.101.121.80\temp\Scripts\biostoolkit\X86_64 \\$computer\c$\temp\dell /S /E  /V /XO /MT:32 /R:2 /W:10
            robocopy \\144.101.121.80\temp\scripts\anyconnectinstaller\current \\$computer\c$\temp\anyconnect /S /E  /V /XO /MT:32 /R:2 /W:10
            Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\json" "\\$computer\C$\Program Files\Mozilla Firefox\distribution" policies.json /z /r:2 /w:5
            Robocopy "\\144.101.121.80\temp\scripts\Mozilla_ICODES\files\Firefox_certificates\" "\\$computer\C$\Windows\Admin\Firefox_certificates\" /z /r:2 /w:5
            Write-Host "Starting GPO on $computer"
            psexec \\$computer -s cmd /c c:\temp\gpo\runme.bat
            Write-Host "Finishing up GPO on $computer"
        }
        else { Write-Host "Cannot reach $computer" }
    }
}

if ($func -eq '16') {    
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
    GPOREPORT 
}

if ($func -eq '18') {   
    dynamicgpo
}

if ($func -eq '19') {    
    updatereport
}

if ($func -eq '20') {    
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

if ($func -eq '21') {    
    softwarecheck
}

if ($func -eq '22') {    

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


if ($func -eq '23') {
    $computer = Read-Host -Prompt 'Input Computer Name'
    activclientinstall($computer)
}

if ($func -eq '24') {
    ADUserAudit
}

if ($func -eq '25') {
    ADCompAudit
}

if($func -eq '26'){
    WorkstationSpreadsheetUpdater
}

if($func -eq '27'){
    bioscheck
}

if($func -eq '28'){
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

if ($func -eq '29' ) {
    $computers = Read-Host -Prompt 'Input Computer Name or type location of text file" ' 
    if($computers -match "\\"){
        $computers = Get-Content $computers
        }
    foreach($computer in $computers){
        robocopy c:\temp\java \\$computer\c$\Windows\sun\Java\Deployment
    }
}
if ($func -eq '30') {
$computers = Read-Host "Enter a Computer Name or path to file"
        if($computers -match "\\"){
            $computers = Get-Content $computers
        }

ForEach ($computer in $computers) {
    If (Test-Connection $computer -Quiet -Count 2) {
       Robocopy "\\144.101.121.80\temp\Drivers\RFID_Drivers\" "\\$computer\C$\Temp\RFID_Drivers" /z /r:2 /w:5 /s
       Write-Output "Installing RFID Drivers"
       Invoke-Command -ComputerName $computer -Scriptblock {Get-ChildItem "C:\Temp\RFID_Drivers" -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }}
       Invoke-Command -ComputerName $computer -ScriptBlock {Remove-Item -Path "C:\Temp\RFID_Drivers" -Recurse}
       Write-Output "$computer RFID Driver Install Complete"
       }
    Else {
        Write-Output "$computer could not be reached"
        }
    }
}
else { }