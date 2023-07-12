# Import the Active Directory module
Import-Module ActiveDirectory

# Function to recursively get group members and generate HTML
function Get-GroupMembersRecursively {
    param (
        [Parameter(Mandatory = $true)]
        [String]$GroupName,
        [Parameter(Mandatory = $true)]
        [int]$IndentLevel
    )

    # Get the group object
    $group = Get-ADGroup $GroupName

    # Output the group name as a collapsible button
    Write-Output ("<button class='collapsible'>" + ("&nbsp;" * 4 * $IndentLevel) + $group.Name + "</button>")
    Write-Output ("<div class='content'>")

    # Get the group members
    $members = Get-ADGroupMember $group | Where-Object { $_.objectClass -eq 'user' } | Select-Object -ExpandProperty SamAccountName

    # Output the member users as a list
    Write-Output ("<ul>")
    foreach ($member in $members) {
        Write-Output ("<li>" + ("&nbsp;" * 4 * ($IndentLevel + 1)) + $member + "</li>")
    }
    Write-Output ("</ul>")

    # Recursively process nested groups
    $nestedGroups = Get-ADGroup $group | Get-ADGroupMember | Where-Object { $_.objectClass -eq 'group' }
    foreach ($nestedGroup in $nestedGroups) {
        Get-GroupMembersRecursively -GroupName $nestedGroup.SamAccountName -IndentLevel ($IndentLevel + 1)
    }

    Write-Output ("</div>")
}

# Generate the HTML report
$report = @"
<!DOCTYPE html>
<html>
<head>
<style>
.collapsible {
    background-color: #777;
    color: white;
    cursor: pointer;
    padding: 18px;
    width: 100%;
    border: none;
    text-align: left;
    outline: none;
    font-size: 15px;
}

.active, .collapsible:hover {
    background-color: #555;
}

.content {
    max-height: 300px;
    overflow-y: auto;
}

.content ul {
    margin: 0;
    padding: 0;
    list-style: none;
}

.content li {
    line-height: 1.5;
}
</style>
</head>
<body>
<script>
var coll = document.getElementsByClassName("collapsible");
var i;

for (i = 0; i < coll.length; i++) {
  coll[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.maxHeight){
      content.style.maxHeight = null;
    } else {
      content.style.maxHeight = content.scrollHeight + "px";
    }
  });
}
</script>
<div class="content">
"@

# Specify the AD security group name
$groupName = "TestGroup0"

# Call the function to generate the report
Get-GroupMembersRecursively -GroupName $groupName -IndentLevel 1 | Out-String | Out-File -FilePath "GroupMembersReport.html" -Append

# Append the closing tags to the report
$report += "</div></body></html>"

# Save the report to a file
$report | Out-File -FilePath "GroupMembersReport.html" -Append
