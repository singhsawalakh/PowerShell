$csvfile = Import-Csv C:\temp\InputFile.Csv

function PreImplementation{

$premasterlist = @()
$ipreimp =0
Foreach($preRecord in $csvfile)
    {
    $ipreimp ++
    Write-Host "Woring on record # $($ipreimp) ## $($preRecord.SamAccountName)"
        #try{
        $predata = Get-ADgroup $preRecord.SamAccountName -Properties members
        
            if (-not $?) {
    #Write-Host "An error occurred in the last command.`n $?"
    $prelist = [PSCustomObject] @{
            "TimeStamp" = (Get-Date).ToString('dd-MMM-yyyy-HH-mm-ss-fff') 
            "SamAccountName" = $preRecord.SamAccountName
            "DistinguishedName" = "Error"
            "GroupName" = "Error"
            "GroupMemberCount" = "Error"
            "Error" = "$($Error[0].Exception.Message)"
                                    }
            $premasterlist +=$prelist

} else {
    #Write-Host "Last command executed successfully."
    $count = ($predata | select -ExpandProperty members).count
    $prelist = [PSCustomObject] @{
            "TimeStamp" = (Get-Date).ToString('dd-MMM-yyyy-HH-mm-ss-fff') 
            "SamAccountName" = $predata.SamAccountName
            "DistinguishedName" = $predata.DistinguishedName
            "GroupName" = $predata.Name
            "GroupMemberCount" = $count
            "Error" = "No"
                                    }
            $premasterlist +=$prelist
}
            
        #}catch{$messagepre=$_.Exception.message}
        
    }
$premasterlist | Export-Csv C:\temp\Output_Pre_implementation_Evidence.csv
}


function PostImplementation{
$postmasterlist = @()
$ipostimp
    Foreach($postRecord in $csvfile)
    {
    $ipostimp ++
    Write-Host "Woring on record # $($ipostimp) ## $($postRecord.SamAccountName)"
        #try{
        $postdata = Get-ADgroup $postRecord.SamAccountName -Properties members
         if (-not $?) 
         {   
            $postlist = [PSCustomObject] @{
                    "TimeStamp" = (Get-Date).ToString('dd-MMM-yyyy-HH-mm-ss-fff') 
                    "SamAccountName" = $postdata.SamAccountName
                    "DistinguishedName" = "Error"
                    "GroupName" = "Error"
                    "Error" = "$($Error[0].Exception.Message)"
                                            }
            $postmasterlist +=$postlist
         }
         Else
         {
            $postlist = [PSCustomObject] @{
                    "TimeStamp" = (Get-Date).ToString('dd-MMM-yyyy-HH-mm-ss-fff') 
                    "SamAccountName" = $postRecord.SamAccountName
                    "DistinguishedName" = $postRecord.DistinguishedName
                    "GroupName" = $postRecord.Name
                    "Error" = "N/A"
                                            }
            $postmasterlist +=$postlist
         }    
                
                #}catch{$messagepost = $_.Exception.message}
    }
$postmasterlist | Export-Csv C:\temp\Output_Post_implementation_Evidence.csv
}

function Get-ErrorStatus {
    #Check the error status of the last operation
    if ($?) {
        #The last operation succeeded
        return $true
    }
    else {
        #The last operation failed
        return $false
    }
}

function Implementaiton{
$impnum = 0
Foreach($impRecord in $csvfile)
    {
        $impnum++
        Write-Host "Trying to delete group # $impnum # $($impRecord.samaccountname)"
        Get-ADgroup $impRecord.SamAccountName | Remove-ADObject -Confirm:$false | Out-Null
        #Check error status
        if (Get-ErrorStatus) {
        #Delete succeeded
        Write-Host "Delete succeeded: $($impRecord.samaccountname)"
            }
        else {
        #Delete failed
        Write-Host "Delete failed: $($impRecord.samaccountname)"
        }
    }
}

function Rollback{
$rolldata = Get-ADObject -filter 'isDeleted -eq $true -and objectclass -eq "group"' -IncludeDeletedObjects -Properties samaccountname | select Samaccountname,Distinguishedname,Objectclass,Deleted,Name,objectguid
$finalrollbackdata =@()
$finalrollbackdataguid=@()
$rollnum = 0
foreach($rollrecord in $csvfile)
{
    $rollnum++
    Write-Host "Working on group # $rollnum # $($rollrecord.samaccountname)"
    if($rollrecord.objectGUID -in $rolldata.objectguid)
    #if($rollrecord.samaccountname -in $rolldata.samaccountname )
    {
        $keyobjectguid = $rollrecord.objectguid
        $matchingItemguid = $rolldata | Where-Object { $_.objectguid -eq $keyobjectguid }
        $finalrollbackdataguid += [pscustomobject]@{SamaccountnameInputFile = $rollrecord.samaccountname
                                                SamaccountnameDeleted = $matchingItemguid.samaccountname
                                                ObjectGuidInputFile = $rollrecord.objectguid
                                                objectguiddeleted = $matchingItemguid.objectguid
                                                RestoreDN= $matchingItemguid.distinguishedname
                                               }

       
    }
    
    }
    #$finalrollbackdata | ogv
    $finalrollbackdataguid | ogv
    Pause
    
    Write-Host "Displayed is the of the DN of the objects to bre stored"
    
    $delinput = Read-Host -Prompt "Enter Yes to restore Or No to cancel the operation"
    If($delinput -eq "Yes")
    {
        Foreach($restorerecord in $finalrollbackdataguid)
        {
            Get-ADObject $restorerecord.RestoreDN -IncludeDeletedObjects | Restore-ADObject  
        }
    }elseif($delinput -eq "No")
    {Write-host "Deletion operation cancelled"}
    Else{Write-Host "Entered option is incorrect. Please try again and enter a valid option."}
}


$Userinput = $null

function userinputfunc{
Write-host "Choices `n 1.PreImplementation `n 2.PostImplementation `n 3.Implementaiton `n 4.Rollback"

$Userinput = Read-Host -Prompt "Enter you choice"

If($Userinput -eq 1)
{PreImplementation}
elseIf($Userinput -eq 2)
{PostImplementation}
elseIf($Userinput -eq 3)
{Implementaiton}
elseIf($Userinput -eq 4)
{Rollback}
Else{Write-Host "Entered option is incorrect. Plese enter the correct option"
userinputfunc }
}
userinputfunc

