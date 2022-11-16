



$computers = Read-Host -Prompt 'Input Computer Name or type Get-Content "C:\temp\location of text file containing multiple computers" '   

foreach($computer in $computers){
    try{
        [pscustomobject]$output = @{
            ComputerName          = $computer
            ComputerModel         = $Model
            ComputerSerialNumber  = $Serial
            MACAddress            = $MAC
            IPAddress             = $null
            IsOnline              = $false
            User                  = $null
            Error                 = $null
            }
    
        if (Test-Connection -ComputerName $computer -Count 1 -Quiet){
            $output.IsOnline = $true
            $MAC = Invoke-Command -ComputerName $computer {(getmac /FO TABLE /NH) -ne '' -replace '\s.*$' -join ' / '}
            $Serial = Invoke-Command -ComputerName $computer {Get-ComputerInfo -Property BiosSeralNumber}
            $Model  =  Invoke-Command -ComputerName $computer {Get-ComputerInfo -Property CsModel}
            $output.User = Invoke-Command -ComputerName $computer {(Get-WMIObject -ClassName Win32_ComputerSystem | select username).username }
            }
        if ($IPAddress = (Resolve-DnsName -Name $computer -ErrorAction Stop).IPAddress){
            $output.IPAddress = "$IPAddress"
            }
   }

    catch{
        $output.Error = $_.Exception.Message
        }
    finally{
        [pscustomobject]$output  | Select-Object -Property ComputerName, ComputerModel, ComputerSerialNumber, MACAddress, IPAddress, IsOnline, User, Error  | Export-Csv -Path c:\temp\results.csv -Force -append -NoTypeInformation
        [pscustomobject]$output 
        }
    
}