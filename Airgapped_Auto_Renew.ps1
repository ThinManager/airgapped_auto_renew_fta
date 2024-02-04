#
# This PowerShell script will renew a FactoryTalk Activation (FTA) license on an air-gapped machine (named RDS1 in this example).
# The machine from which this script is run will need connectivity to the air-gapped machine, as well as to the Internet.
# Both the air-gapped machine and the Internet-connected machine will need to have FactoryTalk Activation Manager v5.01 or
# newer installed.  In this example, the labuser user has local Administrator permissions on both machines.  For reference,
# on a virtualized test system, this script took approximately 2.5 minutes to complete.
#
# The process of renewing or upgrading an FTA license requires the current license to be returned (referred to as REHOST) to
# the Rockwell activation servers.  Once rehosted, it can then be downloaded or reactivated again from the Rockwell activation
# servers with the latest entitlement provided by your contract (i.e.:  latest version and/or expiration date of your FTA
# activated product).  To automate this process via scripting, we will utilize the FTACmdUtility.exe located in the Tools folder
# within the FactoryTalk Activation installation folder.
#
# The rehost process for an air-gapped machine is a 4-step process:
# 1. Select Rehost - Run from the air-gapped machine.  Requires the serial number to be hosted, and a path where the Rehost.xml file will be written.
# 2. Update Rehost - Run from the Internet connected machine.  Takes the Rehost.xml file from step #1 and sends it to the Rockwell activation servers and writes back the update to the file.
# 3. Import Rehost - Run from the air-gapped machine.  Takes the updated Rehost.xml file from step #2 to import back into FactoryTalk Activation Manager.
# 4. Confirm Rehost - Run from the Internet-connected machine.  Takes the confirmation rehost file from step #3 and sends it to the Rockwell activation servers.
#
# The get process for an air-gapped machine is a 3-step process:
# 5. Get Bindings - Run from the air-gapped machine.  Creates a Bindings.xml file that includes the local binding IDs, which facilitates getting an activation to an air-gapped machine.
# 6. Get - Run from the Internet connected machine.  Using the Bindings.xml file from step #5, the serial number, product key, and quantity, retrieves the activation from the Rockwell activation servers.
# 7. Import Activations - Run from the air-gapped machine.  Using the license file retrieved from step #6, imports the activation into the air-gapped machine.
#
# For ThinManager deployments with FTA, you will need to restart the ThinServer service after performing the UPDATE/GET process.
# If you have a redundant ThinManager deployment with FTA, you will need to execute this script on both ThinManager servers
# using the associated serial numbers and product keys for both machines.
#
# Create remote PowerShell session on air-gapped machine.
#
$Airgapped_Hostname = "RDS1"
#
# For the purposes of testing, the Get-Credential commandlet prompts for the username and password to be used by the script.
# If you plan on using a Windows Scheduled task, this method will not be suitable.  In the case of a scheduled task, you would
# comment out the $Credential = Get-Credential line, and change the $Session line to:
# $Session = New-PSSession -ComputerName $Airgapped_Hostname -Authentication NegotiateWithImplicitCredential
# Which would use the credentials provided to run the Windows Scheduled Task for the script.
#
$Credential = Get-Credential
$Session = New-PSSession -ComputerName $Airgapped_Hostname -Credential $Credential
$Username = "labuser"
$Path_FTA_Tools = "c:\Program Files (x86)\Rockwell Software\FactoryTalk Activation\Tools"
$Path_FTA_Desktop = "c:\Users\" + $Username + "\Desktop\"
#
# Step 1 - Select Rehost (On Air-Gapped Machine)
# ----------------------------------------------
#
$Rehost_Folder_Name = "Rehost"
$Rehost_File_Name = "Rehost.xml"
$Rehost_Serial_Number = "1234567890"
$Rehost_Product_Key = "XXXXX-YYYYY"
$Rehost_Quantity = 5
$Path_FTA_Rehost_Folder = $Path_FTA_Desktop + $Rehost_Folder_Name
$Path_FTA_Rehost = $Path_FTA_Rehost_Folder + "\" + $Rehost_File_Name
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Rehost_Folder -Recurse -ErrorAction SilentlyContinue}
Invoke-Command -Session $Session -ScriptBlock {New-Item -Path $Using:Path_FTA_Desktop -Name $Using:Rehost_Folder_Name -ItemType Directory}
Invoke-Command -Session $Session -ScriptBlock {Set-Location -Path $Using:Path_FTA_Tools}
Invoke-Command -Session $Session -ScriptBlock {.\FTACmdUtility.exe selectRehost -sn $Using:Rehost_Serial_Number -d="$Using:Path_FTA_Rehost"}
#
# Step 2 - Update Rehost (On Internet Connected Machine)
# ------------------------------------------------------
#
Remove-Item $Path_FTA_Rehost_Folder -Recurse -ErrorAction SilentlyContinue
New-Item -Path $Path_FTA_Desktop -Name $Rehost_Folder_Name -ItemType Directory
Copy-Item $Path_FTA_Rehost -Destination $Path_FTA_Rehost -FromSession $Session
Set-Location -Path $Path_FTA_Tools
.\FTACmdUtility.exe updateRehost -d="$Path_FTA_Rehost"
#
# Step 3 - Import Rehost (On Air-Gapped Machine)
# ----------------------------------------------
#
$Rehost_Import_Folder_Name = "Rehost_Import"
$Path_FTA_Rehost_Import_Folder = $Path_FTA_Desktop + $Rehost_Import_Folder_Name
$Path_FTA_Rehost_Import = $Path_FTA_Rehost_Import_Folder + "\" + $Rehost_File_Name
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Rehost_Import_Folder -Recurse -ErrorAction SilentlyContinue}
Invoke-Command -Session $Session -ScriptBlock {New-Item -Path $Using:Path_FTA_Desktop -Name $Using:Rehost_Import_Folder_Name -ItemType Directory}
Copy-Item $Path_FTA_Rehost -Destination $Path_FTA_Rehost_Import_Folder -ToSession $Session -Recurse
Invoke-Command -Session $Session -ScriptBlock {.\FTACmdUtility.exe importRehost -d="$Using:Path_FTA_Rehost_Import"}
#
# Step 4 - Confirm Rehost (On Internet Connected Machine)
# -------------------------------------------------------
#
$Rehost_Confirm_Folder_Name = "Rehost_Confirm"
$Path_FTA_Rehost_Confirm_Folder = $Path_FTA_Desktop + $Rehost_Confirm_Folder_Name
$Path_FTA_Rehost_Confirm = $Path_FTA_Rehost_Confirm_Folder + "\" + $Rehost_File_Name
Remove-Item $Path_FTA_Rehost_Confirm_Folder -Recurse -ErrorAction SilentlyContinue
New-Item -Path $Path_FTA_Desktop -Name $Rehost_Confirm_Folder_Name -ItemType Directory
Copy-Item $Path_FTA_Rehost_Import -Destination $Path_FTA_Rehost_Confirm_Folder -FromSession $Session
.\FTACmdUtility.exe confirmRehost -d="$Path_FTA_Rehost_Confirm"
#
# Step 5 - Get Bindings (On Air-Gapped Machine)
# ---------------------------------------------
#
$Bindings_Folder_Name = "Bindings"
$Bindings_File_Name = "Bindings.xml"
$Path_FTA_Bindings_Folder = $Path_FTA_Desktop + $Bindings_Folder_Name
$Path_FTA_Bindings = $Path_FTA_Rehost_Folder + "\" + $Bindings_File_Name
$Activations_Folder_Name = "Activations"
$Path_FTA_Activations = $Path_FTA_Desktop + $Activations_Folder_Name
$Path_FTA_Activations_Folder = $Path_FTA_Activations + "\"
$Path_FTA_Activations_Hostname_Folder = $Path_FTA_Activations_Folder + $Airgapped_Hostname
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Bindings_Folder -Recurse -ErrorAction SilentlyContinue}
Invoke-Command -Session $Session -ScriptBlock {New-Item -Path $Using:Path_FTA_Desktop -Name $Using:Bindings_Folder_Name -ItemType Directory}
Invoke-Command -Session $Session -ScriptBlock {.\FTACmdUtility.exe getBindings -d="$Using:Path_FTA_Bindings"}
#
# Step 6 - Get (On Internet Connected Machine)
# --------------------------------------------
#
Remove-Item $Path_FTA_Bindings_Folder -Recurse -ErrorAction SilentlyContinue
New-Item -Path $Path_FTA_Desktop -Name $Bindings_Folder_Name -ItemType Directory
Copy-Item $Path_FTA_Bindings -Destination $Path_FTA_Bindings -FromSession $Session
Remove-Item $Path_FTA_Activations_Folder -Recurse -ErrorAction SilentlyContinue
.\FTACmdUtility.exe get -sn $Rehost_Serial_Number -pk $Rehost_Product_Key -q $Rehost_Quantity -d="$Path_FTA_Bindings"
#
# Step 7 - Import Activations (On Air-Gapped Machine)
# ---------------------------------------------------
#
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Activations -Recurse -ErrorAction SilentlyContinue}
Copy-Item $Path_FTA_Activations_Folder -Destination $Path_FTA_Desktop -ToSession $Session -Recurse
Invoke-Command -Session $Session -ScriptBlock {.\FTACmdUtility.exe importActivations -i "$Using:Path_FTA_Activations_Hostname_Folder"}
#
# Remove the various folders created on the air-gapped machine as well as the machine from which this script was launched.
#
Remove-Item $Path_FTA_Rehost_Folder -Recurse -ErrorAction SilentlyContinue
Remove-Item $Path_FTA_Rehost_Import_Folder -Recurse -ErrorAction SilentlyContinue
Remove-Item $Path_FTA_Rehost_Confirm_Folder -Recurse -ErrorAction SilentlyContinue
Remove-Item $Path_FTA_Bindings_Folder -Recurse -ErrorAction SilentlyContinue
Remove-Item $Path_FTA_Activations_Folder -Recurse -ErrorAction SilentlyContinue
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Rehost_Folder -Recurse -ErrorAction SilentlyContinue}
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Rehost_Import_Folder -Recurse -ErrorAction SilentlyContinue}
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Bindings_Folder -Recurse -ErrorAction SilentlyContinue}
Invoke-Command -Session $Session -ScriptBlock {Remove-Item $Using:Path_FTA_Activations_Folder -Recurse -ErrorAction SilentlyContinue}
#
# For ThinManager deployments with FTA, restart the ThinServer service.
#
Invoke-Command -Session $Session -ScriptBlock {Restart-Service -Name 'ThinServer'}
