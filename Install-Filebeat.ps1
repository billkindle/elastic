<#
.SYNOPSIS
    Install Elastic Filebeat - a light-weight log shipper for Windows OS.
.DESCRIPTION
    This function will download and install the Elastic Filebeat log shipper
.EXAMPLE
    PS C:\> Install-Filebeat -Version '7.12.1'
    Installs Filebeat version 7.12.1. To install other versions, just reference the version number. 
.INPUTS
    
.OUTPUTS
    
.NOTES
    This cmdlet is meant for Windows PowerShell only.
#>

function Install-Filebeat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    begin {
        # Set Filebeat version
        $Filebeat = 'filebeat-'+$Version+'-windows-x86_64.msi'

        # Elastic download URL
        $Download = "https://artifacts.elastic.co/downloads/beats/filebeat/"+$Filebeat

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

        # Install Filebeat using ampersand call operator here to install MSI package silently
        Write-Verbose -Message "Installing Filebeat silently."
        & $Temp\$Filebeat /qn

        # Starting sleep here to allow for enough time for service to register
        Write-Verbose -Message "Starting sleep for 30 seconds."
        Start-Sleep -Seconds 30
    }
    
    end {
        if (((Get-Service -ServiceName 'filebeat').Status) -eq 'Stopped') {
            Write-Host "Filebeat installed successfully!"
        } else {
            Write-Warning -Message "Filebeat may not have installed successfully. Please check filebeat service."
        }

    # Cleanup
    Write-Verbose -Message "Cleaning up installer."
    Remove-Item -Path $Temp\$Filebeat -ErrorAction SilentlyContinue
    }
}