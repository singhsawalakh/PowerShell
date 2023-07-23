#Take input from the user for Group name
#$InputGroup = Read-Host "Type a group name"
$InputGroup = "Administrators"

# Get AD Group 
$Group = Get-ADGroup $InputGroup -Properties Member

# Get AD Group members
$GroupMembers = $Group | select -ExpandProperty Member


Function GetMemberDomainName($GroupMember)
{
    $GroupMemberDetails = @()
    # Define the distinguished name
    $distinguishedName = $GroupMember

    # Split the distinguished name into its components
    $components = $distinguishedName -split ','

    # Find the domain components
    $domainComponents = $components | Where-Object { $_ -like 'DC=*' }

    # Extract the domain name
    $domainName = $domainComponents -replace 'DC=', '' -join '.'

    # Display the domain name
    $GroupMemberDetails = [PscustomObject]@{"GroupDN" = $GroupMember
                                            "DomainName" = $domainName}
    return $GroupMemberDetails 
}

$GroupMemberDetailsDomainName=@()

Foreach($GroupMember in $GroupMembers)
{
    $GroupMemberDetailsDomainName+= GetMemberDomainName($GroupMember)    
}
Write-host "This is line number 39 `n "

$GroupMemberDetailsDomainName
$GroupMemberDetailsDomainNameDistinguishedName = $GroupMemberDetailsDomainName.GroupDN
$GroupMemberDetailsDomainNameDomainName = $GroupMemberDetailsDomainName.DomainName

$Level1GroupMemberDetails =@()

function GetMemberDetailsFromDomain($GroupMemberDetailsDomainNameDistinguishedName,$GroupMemberDetailsDomainNameDomainName)
{
    Get-ADObject $GroupMemberDetailsDomainNameDistinguishedName -Server $GroupMemberDetailsDomainNameDomainName
    #$Level1GroupMemberDetails+=Get-ADObject $GroupMemberDetailsDomainNameDistinguishedName -Server $GroupMemberDetailsDomainNameDomainName
}
Write-host "This is line number 51 `n "

Foreach($GMDDN in $GroupMemberDetailsDomainName)
{
    $Level1GroupMemberDetails+=GetMemberDetailsFromDomain($GroupMemberDetailsDomainNameDistinguishedName,$GroupMemberDetailsDomainNameDomainName)
}
Write-host "This is line number 58 `n "
$Level1GroupMemberDetails

There was an error generati