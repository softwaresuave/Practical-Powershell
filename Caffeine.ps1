<#
.DESCRIPTION
    Computer will never go to sleep while this script is running. 
    A harmless keystroke is simulated every minute.
    Keeps computer active, repelling the screen saver etc.
.AUTHOR
    TYLER NEELY
.CREATED
    6/15/2022
#>

$wsh = New-Object -ComObject WScript.Shell
while (1) {   
  $wsh.SendKeys('+{F15}')
  Start-Sleep -seconds 59
  }
