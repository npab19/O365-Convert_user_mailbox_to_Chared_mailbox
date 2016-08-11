# This will convert a user mailbox to a shared mailbox and remove the License from the same user. 


#Accept input parameters
Param(
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [string] $Office365Username,
	[Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)]
    [string] $Office365Password,	
	[Parameter(Position=2, Mandatory=$True, ValueFromPipeline=$true)]
    [string] $EmailAddress
)
#Encrypt password for transmission to Office365
$SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Office365Password -Force    
	
#Build credentials object
$Office365Credentials  = New-Object System.Management.Automation.PSCredential $Office365Username, $SecureOffice365Password
	
#Create remote Powershell session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Office365credentials -Authentication Basic -AllowRedirection    	
    
#Import the session
Import-PSSession $Session -AllowClobber | Out-Null

Connect-MsolService -Credential $Office365Credentials

#Main
Function Main {

	# Converts usermailbox to shared mailbox
	get-mailbox -identity $EmailAddress | set-mailbox -type "Shared"
	
	# Get the license assigned to this user
	$user = Get-MsolUser -UserPrincipalName  $EmailAddress
	$Licenses = $user.Licenses.accountskuid
    
	# Removes Licenses from the user
	Set-MsolUserLicense -UserPrincipalName $EmailAddress -RemoveLicenses $Licenses
	
	# Hides mailbox from Global Address List
	Set-Mailbox -Identity $EmailAddress -HiddenFromAddressListsEnabled $true
	
	# Clean up session
	Get-PSSession | Remove-PSSession
}
# Start script
. Main