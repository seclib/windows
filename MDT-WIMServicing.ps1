<#
 
************************************************************************************************************************
 
Created:    2016-08-17
Version:    1.0
 
Author - Michael Niehaus, Anton Romanyuk (modifications for WIM servicing)

Purpose:   Removes some or all of the in-box apps on Windows 8, Windows 8.1,
           or Windows 10 systems.  The script supports both offline and
           online removal.  By default it will remove all apps, but you can
           provide a separate RemoveApps.xml file with a list of apps that
           you want to instead remove.  If this file doesn't exist, the
           script will recreate one in the script folder, so you can
           run the script once, grab the file, make whatever changes you
           want, then put the file alongside the script and it will remove
           only the apps you specified.

 Additional Info:
           Windows as a Service poses new challenges, one of which is the 
		   fact that each feature upgrade reinstalls in-box modern apps 
		   (and potentially adds new ones with each Windows 10 feature upgrade). 
		   Apps that you had removed from Windows 10 1511, e.g. Xbox and Sports, 
		   come back as part of the feature update installation process 
		   (regardless of how you install it – WU, WSUS, ConfigMgr, MDT, media, 
		   etc. all behave the same). Microsoft suggests to remove unwanted apps 
		   either offline or online.
		   
Note:      The script will mount install.wim to a temporary directory C:\temp\Mount,
           uninstall apps, commit changes to install.wim and perform cleanup 
		   activities. Standard directory for W10 ISO content is C:\temp\W10
 
************************************************************************************************************************
 
#>

cls

# ---------------------------------------------------------------------------
# Global variables
# ---------------------------------------------------------------------------

$mount_folder = "Mount"
$mount_path = "C:\temp\"
$mount_full = $mount_path + $mount_folder
$wim_path = "C:\temp\W10\sources\install.wim"

# ---------------------------------------------------------------------------
# Get-AppList:  Return the list of apps to be removed
# ---------------------------------------------------------------------------

function Get-AppList
{
  begin
  {
    # Look for a config file.
    $configFile = "$PSScriptRoot\RemoveApps.xml"
    if (Test-Path -Path $configFile)
    {
      # Read the list
      Write-Verbose "Reading list of apps from $configFile"
      $list = Get-Content $configFile
    }
    else
    {
      # No list? Build one with all apps.
      Write-Verbose "Building list of provisioned apps"
      $list = @()        
      Get-AppxProvisionedPackage -Path $mount_full | % { $list += $_.DisplayName }

      # Write the list to the log path"
      $list | Set-Content $configFile
      Write-Information "Wrote list of apps to $logDir\RemoveApps.xml, edit and place in the same folder as the script to use that list for future script executions"
    }

    Write-Information "Apps selected for removal: $list.Count"
  }

  process
  {
    $list
  }

}

# ---------------------------------------------------------------------------
# Remove-App:  Remove the specified app (online or offline)
# ---------------------------------------------------------------------------

function Remove-App
{
  [CmdletBinding()]
  param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $appName
  )

  begin
  {
      $script:Provisioned = Get-AppxProvisionedPackage -Path $mount_full
  }

  process
  {
    $app = $_

    # Remove the provisioned package
    Write-Information "Removing provisioned package $_"
    $current = $script:Provisioned | ? { $_.DisplayName -eq $app }
    if ($current)
    {
        $a = Remove-AppxProvisionedPackage -Path $mount_full -PackageName $current.PackageName
    }
    else
    {
      Write-Warning "Unable to find provisioned package $_"
    }
  }
}


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

New-Item -Path $mount_path -Name $mount_folder -ItemType Directory -Force | Out-Null

Write-Host "$($myInvocation.MyCommand) - Mounting WIM" -ForegroundColor Green
Mount-WindowsImage -Path $mount_full -ImagePath $wim_path -Index 1 #NOTE: check that image index is correct!

Write-Host "$($myInvocation.MyCommand) - Removing Apps" -ForegroundColor Green
Get-AppList | Remove-App

Write-Host "$($myInvocation.MyCommand) - Committing changes and dismounting WIM" -ForegroundColor Yellow
Dismount-WindowsImage -Path $mount_full -Save