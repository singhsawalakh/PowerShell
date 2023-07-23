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