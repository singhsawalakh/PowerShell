## data stored in a simple text format, each value in a new line.
$data = "TestGroup1
testgroup2
testgroup3
testgroup4"

## Processing the data using split() function and trim() function
    $data = $data.Split("`n").Trim()

## Created new valriable to keep track of the count of iterations in the loop
$i = 0

## Created new variable as an empty array to be used later 
$output = @()

## Starting the for loop to process the records from the list stored in $data
foreach($record in $data)
{
    ## Increasing the count
    $i++
    
    ## Screen message with the count and the record being processed
    Write-Host "Working on record number:: $($i) and the value being processed is :: $($record)"
    
    ## Storing the output in the array
    $output+= Get-ADGroup -Identity $record | select SamAccountName,DistinguishedName
}
## Diplaying the out on the console screen
$output
