<#
.SYNOPSIS
    Install Elastic Winlogbeat - a light-weight log shipper for Windows OS.
.DESCRIPTION
    This function will download and install the Elastic Winlogbeat log shipper
.EXAMPLE
    PS C:\> Install-Winlogbeat -Version '7.12.1'
    Installs Winlogbeat version 7.12.1. To install other versions, just reference the version number. 
.INPUTS
    
.OUTPUTS
    
.NOTES
    This cmdlet is meant for Windows PowerShell only.
#>

function Install-Winlogbeat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    begin {
        # Set Winlogbeat version
        $Winlogbeat = 'winlogbeat-'+$Version+'-windows-x86_64.msi'

        # Elastic download URL
        $Download = "https://artifacts.elastic.co/downloads/beats/winlogbeat/"+$Winlogbeat

        # Download to this directory
        $Temp = 'C:\Temp'
        $TempPath =  Test-Path -Path $Temp

        # Test for C:\Temp Directory and create if it does not exist
        if ($TempPath -eq $false) {
            Write-Verbose -Message "Path NOT FOUND!"
            New-Item -ItemType Directory -Name 'Temp' -Path 'C:\'
        } else {
            Write-Verbose -Message "Path FOUND!"
        }
    }
    
    process {
        # Download latest MSI files
        Write-Verbose -Message "Downloading installation file."
        Start-BitsTransfer -TransferType Download -Source $Download -Destination $Temp

        # Install Winlogbeat using ampersand call operator here to install MSI package silently
        Write-Verbose -Message "Installing Winlogbeat silently."
        & $Temp\$Winlogbeat /qn

        # Starting sleep here to allow for enough time for service to register
        Write-Verbose -Message "Starting sleep for 30 seconds."
        Start-Sleep -Seconds 30
    }
    
    end {
        if (((Get-Service -ServiceName 'Winlogbeat').Status) -eq 'Stopped') {
            Write-Host "Winlogbeat installed successfully!"
        } else {
            Write-Warning -Message "Winlogbeat may not have installed successfully. Please check Winlogbeat service."
        }

    # Cleanup
    Write-Verbose -Message "Cleaning up installer."
    Remove-Item -Path $Temp\$Winlogbeat -ErrorAction SilentlyContinue
    }
}