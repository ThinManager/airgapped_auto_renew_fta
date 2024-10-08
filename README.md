# airgapped_auto_renew_fta
Automatically update FTA license on an air-gapped machine.

FactoryTalk Activation (FTA) does provide a method to automatically update FTA licenses, but this requires FactoryTalk Activation Manager to have an Internet connection. This is configured from the Advanced tab under Configure Automatic Renewals in FactoryTalk Activation Manager (FTAM).

In most ThinManager deployments with FTA, the FTA license is installed on the same machine as ThinManager, and the machine is air-gapped (i.e.:  not connected to the Internet), so the built-in Automatic Renewal option provided by FTAM will not work in these scenarios.

A ThinManager license provides some critical details regarding your entitlement.  For example, the number of terminal connections your license provides, the maximum version of ThinManager to which your license is entitled, and the expiration date of your license, if you purchased a subscription.  If any of these details has been updated since your initial activation, you will need to update the FTA license (i.e.:  if you upgraded ThinManager from one major version to another (from v12 to v13), or if you have renewed your subscription, you will need to update the license that is installed).

Updating an existing FTA license on an air-gapped machine is a 2-step process.  First, you must return the license hosted on your machine to the Rockwell Activation servers.  This process is referred to as a REHOST.  Second, you must get the updated license (with the latest entitlement details) from the Rockwell Activation servers and re-apply it to your machine.  Performing this process manually in an air-gapped deployment requires some additional steps in order to move the necessary files from the air-gapped machine to your Internet connected machine, and then back again.  While not terribly difficult, the process can be time-consuming, especially if you are updating a number of FTA licenses in your enterprise.

The provided PowerShell script is an example of how to automate this process.  It is intended to be run from an Internet-connected machine that also has connectivity to the air-gapped machine on which ThinManager is installed.  The script was tested with FactoryTalk Activation Manager v5.01 installed on both machines and leverages the FTACmdUtility.exe located in the Tools folder of the FactoryTalk Activation install folder.  To see all of the capabilities of FTACmdUtility, you can execute the FTACmdUtility.exe -h from a command prompt.  To get help on a specific command, like selectRehost, you can execute FTACmdUtility.exe selectRehost -h from a command prompt.

In order to use the script in your environment, you will need to change several of the variables:

$Airgapped_Hostname = hostname of air-gapped machine

$Username = username that will be executing the script

$Path_FTA_Tools = path to where the FTACmdUtility.exe file is located - typically c:\Program Files (x86)\Rockwell Software\FactoryTalk Activation\Tools

$Path_FTA_Desktop = location where the various folders and files will be stored during the process - by default, this is the Desktop of the user executing the script

$Rehost_Serial_Number = FTA serial number being rehosted

$Rehost_Product_Key = FTA product key for the serial number being rehosted

$Rehost_Quantity = number of V-FLEX licenses to be rehosted


If your ThinManager deployment utilizes Redundancy, you will need to execute this script on both the Primary ThinManager Server and the Secondary ThinManager Server, changing the $Rehost_Serial_Number, $Rehost_Product_Key, and $Rehost_Quantity variables accordingly for both.

It should also be noted that currently an FTA license has a maximum number of REHOSTS of 5.  You can request increasing this number through Rockwell technical support.  For testing purposes, you can also request a temporary activation instead of working with production licenses.


### Disclaimer

Rockwell Automation maintains these repositories as a convenience to you and other users. Rockwell Automation reserves the right at any time and for any reason to refuse access, to edit, or remove content from this Repository. You acknowledge and agree to accept sole responsibility and liability for any Repository content posted, transmitted, downloaded, or used by you. Rockwell Automation has no obligation to monitor or update Repository content

The examples provided are to be used as a reference for building your own application and should not be used in production as-is. It is recommended to adapt the example code based on your project/needs while observing the highest quality and safety standards.

The following list, while not inclusive, are pieces of software that require a paid license or subcription to run in production:
- ThinManager
- ThinManager Logix PinPoint
- FactoryTalk® Optix
- FactoryTalk® View SE
