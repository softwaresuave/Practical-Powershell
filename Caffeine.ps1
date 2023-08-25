<<<<<<< HEAD
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
=======
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
>>>>>>> efdd8be09dcb72adcd9be1136b6a4970bcfc47b7
