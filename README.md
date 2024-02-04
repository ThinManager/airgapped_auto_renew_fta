# airgapped_auto_renew_fta
Automatically update FTA license on an air-gapped machine.

FactoryTalk Activation (FTA) does provide a method to automatically update FTA licenses, but this requires FactoryTalk Activation Manager to have an Internet connection. This is configured from the Advanced tab under Configure Automatic Renewals in FactoryTalk Activation Manager (FTAM).

In most ThinManager deployments with FTA, the FTA license is installed on the same machine as ThinManager, and the machine is air-gapped (i.e.:  not connected to the Internet), so the built-in Automatic Renewal option provided by FTAM will not work in these scenarios.

A ThinManager license provides some critical details regarding your entitlement.  For example, the number of terminal connections your license provides, the maximum version of ThinManager to which your license is entitled, and the expiration date of your license, if you purchased a subscription.  If any of these details has been updated since your initial activation, you will need to update the FTA license (i.e.:  if you upgraded ThinManager from one major version to another (from v12 to v13), or if you have renewed your subscription, you will need to update the license that is installed).

Updating an existing FTA license on an air-gapped machine is a 2-step process.  First, you must return the license hosted on your machine to the Rockwell Activation servers.  This process is referred to as a REHOST.  Second, you must get the updated license (with the latest entitlement details) from the Rockwell Activation servers and re-apply it to your machine.  Performing this process manually in an air-gapped deployment requires some additional steps in order to move the necessary files from the air-gapped machine to your Internet connected machine, and then back again.  While not terribly difficult, the process can be time-consuming, especially if you are updating a number of FTA licenses in your Enterprise.

The provided PowerShell script is an example of how to automate this process.  It is intended to be run from an Internet-connected machine that also has connectivity to the air-gapped machine on which ThinManager is installed.  The script was tested with FactoryTalk Activation Manager v5.01 installed on both machines.

In order to use the script in your environment, you will need to change several of the variables:

$Airgapped_Hostname = hostname of air-gapped machine
$Username = username that will be executing the script
$Path_FTA_Tools = path to where the FTACmdUtility.exe file is located - typically c:\Program Files (x86)\Rockwell Software\FactoryTalk Activation\Tools
$Path_FTA_Desktop = location where the various folders and files will be stored during the process - by default, this is the Desktop of the user executing the script
$Rehost_Serial_Number = FTA serial number being rehosted
$Rehost_Product_Key = FTA product key for the serial number being rehosted
$Rehost_Quantity = number of V-FLEX licenses to be rehosted

If your ThinManager deployment utilizes Redundancy, you will need to execute this script on both the Primary ThinManager Server and the Secondary ThinManager Server, changing the $Rehost_Serial_Number, $Rehost_Product_Key, and $Rehost_Quantity variables accordingly for both.



