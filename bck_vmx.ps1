
## Set the destination folder
$Destination = 'c:\ibm_apar\vmx\'

## Connect to vCenter
$Server = Read-Host -Prompt 'Provide vCenter IP or FQDN '
Write-Host " Connecting to "$Server
Connect-VIServer $Server


## Get list of VMs and download the VMX files
Get-VM | `
  Get-View | `
  ForEach-Object {
    $vmxfile = $_.Config.Files.VmPathName

    ## Take the datastore name of the VM
    $dsname = $vmxfile.split(" ")[0]

    ## Assign only the name from the string
    $ds_name = $dsname.Substring(1,$dsname.Length-2)
    
    ## Go to the datastore and download the vmx file
    $ds = Get-Datastore -Name $ds_name 
    New-PSDrive -Name ds -PSProvider VimDatastore -Root '/' -Location $ds
    Copy-DatastoreItem -Item "ds:\$($vmxfile.split(']')[1].TrimStart(' '))" -Destination $Destination
    Remove-PSDrive -Name ds
  }

  Disconnect-VIServer -Server * -Force -Confirm:$False
  Write-Host " Disconnecting from "$Server
