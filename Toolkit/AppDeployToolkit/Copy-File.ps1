Function Copy-File {
    <#
.SYNOPSIS

Copy a file or group of files to a destination path.

.DESCRIPTION

Copy a file or group of files to a destination path.

.PARAMETER Path

Path of the file to copy.

.PARAMETER Destination

Destination Path of the file to copy.

.PARAMETER Recurse

Copy files in subdirectories.

.PARAMETER Flatten

Flattens the files into the root destination directory.

.PARAMETER ContinueOnError

Continue if an error is encountered. This will continue the deployment script, but will not continue copying files if an error is encountered. Default is: $true.

.PARAMETER ContinueFileCopyOnError

Continue copying files if an error is encountered. This will continue the deployment script and will warn about files that failed to be copied. Default is: $false.

.INPUTS

None

You cannot pipe objects to this function.

.OUTPUTS

None

This function does not generate any output.

.EXAMPLE

Copy-File -Path "$dirSupportFiles\MyApp.ini" -Destination "$envWinDir\MyApp.ini"

.EXAMPLE

Copy-File -Path "$dirSupportFiles\*.*" -Destination "$envTemp\tempfiles"

Copy all of the files in a folder to a destination folder.

.NOTES

.LINK

https://psappdeploytoolkit.com
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [String[]]$Path,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Destination,
        [Parameter(Mandatory = $false)]
        [Switch]$Recurse = $false,
        [Parameter(Mandatory = $false)]
        [Switch]$Flatten,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$ContinueOnError = $true,
        [ValidateNotNullOrEmpty()]
        [Boolean]$ContinueFileCopyOnError = $false
    )

    Begin {
        ## Get the name of this function and write header
        [String]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -CmdletBoundParameters $PSBoundParameters -Header
    }
    Process {
        Try {
            If ((-not ([IO.Path]::HasExtension($Destination))) -and (-not (Test-Path -LiteralPath $Destination -PathType 'Container'))) {
                Write-Log -Message "Destination folder does not exist, creating destination folder [$destination]." -Source ${CmdletName}
                $null = New-Item -Path $Destination -Type 'Directory' -Force -ErrorAction 'Stop'
            }

            If ($Flatten) {
                If ($Recurse) {
                    Write-Log -Message "Copying file(s) recursively in path [$path] to destination [$destination] root folder, flattened." -Source ${CmdletName}
                    If ($ContinueFileCopyOnError) {
                        $null = Get-ChildItem -Path $path -Recurse -Force -ErrorAction 'SilentlyContinue' | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
                            Copy-Item -Path ($_.FullName) -Destination $destination -Force -ErrorAction 'SilentlyContinue' -ErrorVariable 'FileCopyError'
                        }
                    }
                    Else {
                        $null = Get-ChildItem -Path $path -Recurse -Force -ErrorAction 'SilentlyContinue' | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
                            Copy-Item -Path ($_.FullName) -Destination $destination -Force -ErrorAction 'Stop'
                        }
                    }
                }
                Else {
                    Write-Log -Message "Copying file in path [$path] to destination [$destination]." -Source ${CmdletName}
                    If ($ContinueFileCopyOnError) {
                        $null = Copy-Item -Path $path -Destination $destination -Force -ErrorAction 'SilentlyContinue' -ErrorVariable 'FileCopyError'
                    }
                    Else {
                        $null = Copy-Item -Path $path -Destination $destination -Force -ErrorAction 'Stop'
                    }
                }
            }
            Else {
                If ($Recurse) {
                    Write-Log -Message "Copying file(s) recursively in path [$path] to destination [$destination]." -Source ${CmdletName}
                    If ($ContinueFileCopyOnError) {
                        $null = Copy-Item -Path $Path -Destination $Destination -Force -Recurse -ErrorAction 'SilentlyContinue' -ErrorVariable 'FileCopyError'
                    }
                    Else {
                        $null = Copy-Item -Path $Path -Destination $Destination -Force -Recurse -ErrorAction 'Stop'
                    }
                }
                Else {
                    Write-Log -Message "Copying file in path [$path] to destination [$destination]." -Source ${CmdletName}
                    If ($ContinueFileCopyOnError) {
                        $null = Copy-Item -Path $Path -Destination $Destination -Force -ErrorAction 'SilentlyContinue' -ErrorVariable 'FileCopyError'
                    }
                    Else {
                        $null = Copy-Item -Path $Path -Destination $Destination -Force -ErrorAction 'Stop'
                    }
                }
            }

            If ($FileCopyError) {
                Write-Log -Message "The following warnings were detected while copying file(s) in path [$path] to destination [$destination]. `r`n$FileCopyError" -Severity 2 -Source ${CmdletName}
            }
            Else {
                Write-Log -Message 'File copy completed successfully.' -Source ${CmdletName}
            }
        }
        Catch {
            Write-Log -Message "Failed to copy file(s) in path [$path] to destination [$destination]. `r`n$(Resolve-Error)" -Severity 3 -Source ${CmdletName}
            If (-not $ContinueOnError) {
                Throw "Failed to copy file(s) in path [$path] to destination [$destination]: $($_.Exception.Message)"
            }
        }
    }
    End {
        Write-FunctionHeaderOrFooter -CmdletName ${CmdletName} -Footer
    }
}