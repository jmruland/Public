function New-CBZfromFolder
{
    #region Help
        <#
        .SYNOPSIS
        This script will scan a directory for subfolders with images in them and create a .cbz file for each.

        .DESCRIPTION
        It will scan a directory for subfolders with images in them. If it finds one, it creates a .cbz file of that folder and then moves the parent folder to a folder called "Processed" in the root directory.

        .PARAMETER directory
        The directory to scan for subfolders. This parameter is mandatory.
        
        .PARAMETER transcript
        The directory to save the transcript to. Defaults to the current directory.

        .EXAMPLE
        New-CBZfromFolder -directory "C:\Users\James\Downloads\Comics" -transcript "C:\Users\James\Downloads\Comics\Transcripts"

        .NOTES
        Created by James Ruland with heavy help from AI Assistant Copilot.
        Last Edited 15 December 2023
        #>
    #endregion Help

    #region Parameters

    # Add CmdletBinding attribute to support common parameters
    [CmdletBinding(SupportsShouldProcess)]

    # Specify Directory and Transcript parameters
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]$directory = ".",

        [Parameter(Mandatory=$false, Position=1)]
        [string]$transcript = "$directory"
    )

    #endregion Parameters

    #region Transcript

    # Initialize a counter variable
    if (-not (Test-Path Variable:Global:CreateCBZFileCounter)) {
        Set-Variable -Name CreateCBZFileCounter -Value 0 -Scope Global
    }
    
    # Increment the counter
    $global:CreateCBZFileCounter++

    # Start the transcript

    $currentFunctionName = (Get-PSCallStack)[0].Command
    $logFileName = "{0}_{1}_{2}.log" -f $currentFunctionName, (Get-Date -Format "yyyyMMdd"), $global:CreateCBZFileCounter
    $logFilePath = Join-Path -Path $transcript -ChildPath $logFileName

    Start-Transcript -Path $logFilePath

    #endregion Transcript

    # Get all subdirectories in the directory specified by the user
    $subDirectories = Get-ChildItem -Path $directory -Directory

    # Loop through each subdirectory
    foreach ($subDirectory in $subDirectories) {
        # Check if the subdirectory contains any image files
        $imageFiles = Get-ChildItem -Path $subDirectory.FullName -Include *.jpg,*.jpeg,*.png,*.gif -File
        if ($imageFiles) {
            # If image files are found, create a .cbr file
            $cbrFileName = "{0}.cbr" -f $subDirectory.Name
            $cbrFilePath = Join-Path -Path $directory -ChildPath $cbrFileName
            Compress-Archive -Path $imageFiles.FullName -DestinationPath $cbrFilePath

            # Move the subdirectory to a "Processed" folder in the root directory
            $processedDirectory = Join-Path -Path $directory -ChildPath "Processed"
            if (-not (Test-Path -Path $processedDirectory)) {
                New-Item -Path $processedDirectory -ItemType Directory | Out-Null
            }
            Move-Item -Path $subDirectory.FullName -Destination $processedDirectory
        }
    }

    # Stop the transcript
    Stop-Transcript
  
    # Ask user if they want to open the transcript
    $openTranscript = Read-Host -Prompt "Do you want to open the transcript? (Y/N)"
    if ($openTranscript -eq "Y") {
        Invoke-Item -Path $logFilePath
    }
}
