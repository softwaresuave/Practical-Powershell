#SCRIPT THAT CREATES CSV REPORT OF ALL MACHINES NETWORK STATUS
#ADD COMPUTER NAMES TO TXT FILE IN LOCATION BELOW

$computers = Get-Content C:\temp\Allcomputers.txt
foreach($computer in $computers){
    try{
        [pscustomobject]$output = @{
        ComputerName  = $computer
        IPAddress     = $null
        IsOnline      = $false
        Error         = $null
        }
        if (Test-Connection -ComputerName $computer -Count 1 -Quiet){
            $output.IsOnline = $true
            }
        if ($IPAddress = (Resolve-DnsName -Name $computer -ErrorAction Stop).IPAddress){
            $output.IPAddress = "$IPAddress"
            }
    }
    catch{
        $output.Error = $_.Exception.Message
        }
    finally{
        [pscustomobject]$output | Select-Object -Property ComputerName, IPAddress, IsOnline, Error | Export-Csv -Path C:\temp\scripts\pingresults.csv -Force -append -NoTypeInformation
        [pscustomobject]$output 
        } 
}
    