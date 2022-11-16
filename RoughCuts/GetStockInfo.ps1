## Powershell script that takes text file list of stock tickers like
## tickers.txt contains a newline delimited list of stock tickers like:
## AAPL
## IBM
## SAP
## The script will then save the most recent stock price of each stock in tickers.txt in the stockresults file


# take stock symbol from command line and pass an argument -File for a text file contains a newline delimited list of stock symbols.
$file = "C:\website_contents\tickers.txt"
# verify above save location is correct!!!
$results = Get-Content C:\website_contents\StockResults.txt | ForEach-Object {$_ -replace "C:\website_contents\StockResults.txt\*"}


If(($File) -and ((Get-Content $File) -eq $Null)){"Your stock tickers text file '$File' is blank."}
 else{ 

# Remove-Item C:\website_contents\StockResults.txt 

  foreach ($symbol in Get-Content $File | sort-object) {
  $symbol.ToUpper() +  (Invoke-RestMethod -Uri "https://finance.yahoo.com/quote/$symbol/history?period1=1589535885&period2=1621071885&interval=1d&filter=history&frequency=1d&includeAdjustedClose=true" -Method Get) | Set-Content $results 
       }
          }                                           
