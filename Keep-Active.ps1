<#
.SYNOPSIS
This script will keep the computer session active by emulating NumLock key press in ever 120 seconds.

.DESCRIPTION
This script is designed to ensure that the NumLock key remains in an active state (on) consistently every 120 seconds, regardless of its previous status. 
It does this by checking the NumLock status, sending the NumLock keypress accordingly, and then sleeping for 120 seconds before repeating the process. 

.PARAMETER ParameterName
N/A

.EXAMPLE
Example of how to use the script:
.\Keep-Active.ps1

.NOTES
Author: Rattandeep Singh
Date: 23 Jul 2023
Version: V.0.1
#>


while ($true)
{
    $numlockstatus = [console]::NumberLock
    if($numlockstatus -eq $false)
    {
        (New-Object -ComObject WScript.Shell).SendKeys('{NUMLOCK}')
    }
    else
    {
        (New-Object -ComObject WScript.Shell).SendKeys('{NUMLOCK}')
        (New-Object -ComObject WScript.Shell).SendKeys('{NUMLOCK}')
    }
    Start-Sleep -Seconds 120
}