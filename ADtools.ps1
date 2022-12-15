<#
.DESCRIPTION
	SYSADMIN TOOLKIT. INCLUDES A VARIETY OF ACTIVE DIRECTORY FUNCTIONS.
.AUTHOR
	TYLER NEELY
.LASTMOD
	2/18/2022
#>

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
    } 
else {
    Write-Host "Operation aborted. No Active Directory Module found. Run this tool on a Domain Controller." -ForegroundColor Red  
    throw $error
    }
cls
do {
Write-Host '     LIST OF FUNCTIONS' -ForegroundColor Green 
Write-Host ' 1 - List Domain Controller'
Write-Host ' 2 - Replicate all Domain Controller'
Write-Host ' 3 - Show Default Domain Password Policy'
Write-Host ' 4 - List of Active GPOs'
Write-Host ' 5 - List all Machines on Domain'
Write-Host ' 6 - Move Computer to OU'
Write-Host ' 7 - List Group Membership by User'
Write-Host ' 8 - List User Properties'
Write-Host ' 9 - Users Last Domain Logon'
Write-Host '10 - Find orphaned User or Computer Accounts'
Write-Host '11 - Disable AD User | Offboarding'
Write-Host '12 - Add DHCP Filter'
Write-Host '0  - Quit' -ForegroundColor Red

$input=Read-Host 'Select Function'
switch ($input) { 

1 {
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
2 { 
    Write-Host "This sub-menu replicates all Domain Controller on all Sites of the Domain $env:userdnsdomain."
    Write-Host 'START REPLICATION?' -ForegroundColor Yellow
    $startr=Read-Host 'Y/N'
    If ($startr) {
        (Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess | Out-Host
        }
  }
3 {
    Write-Host -ForegroundColor Green 'The Default Domain Policy is configured as follows:'`n 
    Get-ADDefaultDomainPasswordPolicy | Format-List ComplexityEnabled, LockoutDuration,LockoutObservationWindow,LockoutThreshold,MaxPasswordAge,MinPasswordAge,MinPasswordLength,PasswordHistoryCount,ReversibleEncryptionEnabled
    Read-Host 'Press 0 and Enter to continue' 
    } 
4 {
    Write-Host -ForegroundColor Green 'The GPOs below are linked to AD Objects:'`n 
    Get-GPO -All | ForEach-Object {
    If ( $_ | Get-GPOReport -ReportType XML | Select-String '<LinksTo>' ) {
        Write-Host $_.DisplayName}}
        Read-Host 'Press 0 and Enter to continue'
        }
5 {
    $client=Get-ADComputer -SearchBase “OU=,DC=,DC=,DC=,DC=” -Filter * -Properties * | Sort-Object
    Write-Host -ForegroundColor Green "List of Machines on the domain"
    Write-Output $client | Sort-Object Operatingsystem | Format-Table Name,Operatingsystem,OperatingSystemVersion,IPv4Address -AutoSize
    Write-Host 'Total: '$ccount"" -ForegroundColor Yellow
    Read-Host 'Press 0 and Enter to continue'
    }
6 {
    do {
        $groupm=Read-Host 'Enter group name'
        Write-Host "Group Members of $groupm" -ForegroundColor Green
        Get-ADGroupMember $groupm | Format-Table Name,SamAccountName,SID -AutoSize -Wrap
        $input=Read-Host 'Quit searching groups? (Y/N)'
        }
    while ($input -eq 'N')
    }
7 {
    do {
        $userp=Read-Host 'Enter user logon name'
        Write-Host "Details of user $userp" -ForegroundColor Green
        Get-ADUser $userp -Properties * | Format-List GivenName,SurName,DistinguishedName,Enabled,EmailAddress,ProfilePath,ScriptPath,MemberOf,LastLogonDate,whencreated
        $input=Read-Host 'Quit searching users? (Y/N)'
        }
    while ($input -eq 'N')
    }
8  { 
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
9 {
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
 10 {
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
 11 {
    $macAddresses = Read-Host "Enter path to csv file containing MAC Addresses to allow"
    Import-Csv $macAddresses | foreach{netsh dhcp server v4 add filter allow $_.'MAC Address' $_.Description}    

 }
  }
}
while ($input -ne '0')
