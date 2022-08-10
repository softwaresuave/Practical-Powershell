<#
.DESCRIPTION
    TOOLKIT FOR PATCHING. FIXES COMMON VULNERABILITIES FOUND IN SCANS. VERIFY LOCATION OF COMPUTERS.TXT FILE.
.AUTHOR
    TYLER NEELY
.CREATED
    9/29/2021
#>


Write-Host "
**AVAILABLE FUNCTIONS**
1. Who's logged in
2. Application Checker
3. Update Microsoft Defender (MPSIGSTUB)
4. Fix Registry Unquoted Service Path "                   
$func = Read-Host -Prompt 'input number of function to run'

if ($func -eq '1' ){
    $computer = Read-Host "Enter a computer name"
    $UserLogged = Get-WmiObject –ComputerName $computer –Class Win32_ComputerSystem | Select-Object UserName
    Write-Host "$UserLogged is logged into $computer"
    }
if ($func -eq '2'){
    $Computers = Get-Content "C:\temp\computers.txt"
    foreach ($Computer in $Computers){ 
        Write-Host "Chrome"
        (Get-Item "\\$computer\C$\Program Files\Google\Chrome\Application\chrome.exe").VersionInfo | Select ProductVersion, FileVersion
        Write-Host "FireFox"
        (Get-Item "\\$computer\C$\Program Files\Mozilla Firefox\firefox.exe").VersionInfo | Select ProductVersion, FileVersion
        Write-Host "Edge"
        (Get-Item "\\$Computer\C$\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe").VersionInfo
        Write-Host "AnyConnect"
        (Get-Item "\\$computer\C$\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe").VersionInfo | Select ProductVersion, FileVersion
        Write-Host "Adobe"
        (Get-Item "\\$computer\c$\Program Files (x86)\Adobe\Acrobat DC\Acrobat\acrobat.exe").VersionInfo | Select ProductVersion, FileVersion
        Write-Host "Java"
        (Get-Item "\\$computer\C$\Program Files\McAfee\DLP\Agent\fcags.exe").VersionInfo | Select ProductVersion, FileVersion   
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
    Write-output $Computer 
    } 
}
if ($func -eq '3'){
    $computers = Read-Host "Enter Computer Name or Location of computers.txt File"
        if($computers -match "\\"){
            $computers = Get-Content $computers
            }
ForEach ($computer in $computers) {
    If (Test-Connection $computer -Quiet -Count 2) {
       Invoke-Command -ComputerName $computer -Scriptblock {cmd.exe /c '\\144.101.121.80\temp\tyler\PatchingTools\MicrosoftDefenderUpdate.bat' /quiet}
       Robocopy "\\SDDC05NB842DS04\C$\Windows\System32\" "\\$computer\C$\Windows\System32\" MpSigStub.exe /z /r:2 /w:5
       Write-Output "INSTALLING"
	   Invoke-Command -ComputerName $computer -Scriptblock {cmd.exe /c 'C:\Windows\System32\MpSigStub.exe' /quiet} }
       } 
}
if ($func -eq '4'){
    $computer = Read-Host "Enter Computer Name"
    Invoke-Command -ComputerName $computer -ScriptBlock {
    $BaseKeys = "HKLM:\System\CurrentControlSet\Services",                       #SERVICES
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",             #32BIT
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"  #64BIT
    #Blacklist for keys to ignore
    $BlackList = $Null
    #Create an ArrayList to store results in
    $Values = New-Object System.Collections.ArrayList
    $DiscKeys = Get-ChildItem -Recurse -Directory $BaseKeys -Exclude $BlackList -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Name | %{($_.ToString().Split('\') | Select-Object -Skip 1) -join '\'}
    $Registry = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
ForEach ($RegKey in $DiscKeys){
    Try { $ParentKey = $Registry.OpenSubKey($RegKey, $True) }
    Catch { Write-Debug "Unable to open $RegKey" }
    #Test if registry key has values
    If ($ParentKey.ValueCount -gt 0){
        $MatchedValues = $ParentKey.GetValueNames() | ?{ $_ -eq "ImagePath" -or $_ -eq "UninstallString" }
        ForEach ($Match in $MatchedValues) {
            $ValueRegEx = '(^(?!\u0022).*\s.*\.[Ee][Xx][Ee](?<!\u0022))(.*$)'
            $Value = $ParentKey.GetValue($Match)
            #Test if value matches RegEx
            If ($Value -match $ValueRegEx) {
                $RegType = $ParentKey.GetValueKind($Match)
                If ($RegType -eq "ExpandString") {
                    $ValueRegEx = '(^(?!\u0022).*\.[Ee][Xx][Ee](?<!\u0022))(.*$)'
                    $Value = $ParentKey.GetValue($Match, $Null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                    $Value -match $ValueRegEx
                    }
                $Correction = "$([char]34)$($Matches[1])$([char]34)$($Matches[2])"
                #Attempt to correct the entry
                Try { $ParentKey.SetValue("$Match", "$Correction", [Microsoft.Win32.RegistryValueKind]::$RegType) }
                Catch { Write-Debug "Unable to write to $ParentKey" }
                #Add a hashtable containing details of corrected key to ArrayList
                $Values.Add((New-Object PSObject -Property @{
                "Name" = $Match
                "Type" = $RegType
                "Value" = $Value
                "Correction" = $Correction
                "ParentKey" = "HKEY_LOCAL_MACHINE\$RegKey"
                })) | Out-Null
            }
         }
      }
    $ParentKey.Close()
} }
$Registry.Close()
$Values | Select-Object ParentKey,Value,Correction,Name,Type }
