<#
.SYNOPSIS
    Install Elastic Packetbeat - a light-weight log shipper for Windows OS.
.DESCRIPTION
    This function will download and install the Elastic Packetbeat log shipper
.EXAMPLE
    PS C:\> Install-Packetbeat -Version '7.12.1'
    Installs Packetbeat version 7.12.1. To install other versions, just reference the version number. 
.INPUTS
    
.OUTPUTS
    
.NOTES
    This cmdlet is meant for Windows PowerShell only.
#>

function Install-Packetbeat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    begin {
        # Set Packetbeat version
        $Packetbeat = 'packetbeat-'+$Version+'-windows-x86_64.msi'

        # Elastic download URL
        $Download = "https://artifacts.elastic.co/downloads/beats/packetbeat/"+$Packetbeat

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

        # Install Packetbeat using ampersand call operator here to install MSI package silently
        Write-Verbose -Message "Installing Packetbeat silently."
        & $Temp\$Packetbeat /qn

        # Starting sleep here to allow for enough time for service to register
        Write-Verbose -Message "Starting sleep for 30 seconds."
        Start-Sleep -Seconds 30
    }
    
    end {
        if (((Get-Service -ServiceName 'Packetbeat').Status) -eq 'Stopped') {
            Write-Host "Packetbeat installed successfully!"
        } else {
            Write-Warning -Message "Packetbeat may not have installed successfully. Please check Packetbeat service."
        }

    # Cleanup
    Write-Verbose -Message "Cleaning up installer."
    Remove-Item -Path $Temp\$Packetbeat -ErrorAction SilentlyContinue
    }
}