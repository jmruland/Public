function Format-MangaFolder 
{
    #region Help
        <#
        .SYNOPSIS
        This script will organize media files into folders based on the name of the file. 

        .DESCRIPTION
        It will compare the file name to a list of known shows and movies and move the file to the appropriate folder. 
        
        It will scan a directory for all files with the extensions .cbz, .zip, .pdf, .rar, and .cbr.     
        It will then create a folder with that name and move the file into it.      
        If it finds files with similar names, it will move them to a folder with the same base name. 
        
        .PARAMETER directory
        The directory to scan for files. Defaults to the current directory.

        .PARAMETER transcript
        The directory to save the transcript to. Defaults to the current directory.

        .EXAMPLE
        Format-Manga -directory "C:\Users\James\Downloads\Comics" -transcript "C:\Users\James\Downloads\Comics\Transcripts"
   
        .NOTES
        Created by James Ruland with heavy help from AI Assistant Copilot.
        Last Edited 15 December 2023
        #>
    #endregion Help

    #region Parameters

    # Add CmdletBinding attribute to support common parameters
    [CmdletBinding(SupportsShouldProcess)]

    #Specify Directory parameter and default to local directory
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]$directory = ".",

        [Parameter(Mandatory=$false,  Position=1)]
        [string]$transcript = "."
    )

    #endregion Parameters

    #region Transcript
    # Initialize a counter variable
    if (-not (Test-Path Variable:Global:FormatMangaCounter)) {
        Set-Variable -Name FormatMangaCounter -Value 0 -Scope Global
    }

    # Increment the counter
    $global:FormatMangaCounter++

    # Start the transcript
    $logFileName = "Format-Manga_{0}_{1}.log" -f (Get-Date -Format "yyyyMMdd"), $global:FormatMangaCounter
    Start-Transcript -Path (Join-Path -Path $transcript -ChildPath $logFileName)

    #endregion Transcript

    # Get all .cbz, .zip, .pdf, .rar, and .cbr files in the directory specified by the user, but not in subdirectories.
    $files = Get-ChildItem -Path $directory -Include *.cbz,*.zip,*.pdf,*.rar,*.cbr -File -Depth 0

    # Create a hashtable to store base names and their corresponding directories
    $baseNameDirectoryMap = @{}

    # Loop through each file
    foreach ($file in $files) {
        # Get the base name of the file
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

        # Clean up the base name. Remove any text in brackets, parentheses, or curly braces. Remove leading and trailing dashes and underscores.
        $baseName = $baseName -replace '\[.*?\]', ''
        $baseName = $baseName -replace '\(.*?\)', ''
        $baseName = $baseName -replace '\{.*?\}', ''
        $baseName = $baseName.Trim()
        $baseName = $baseName.TrimStart('-','_')
        $baseName = $baseName.TrimEnd('-','_')
        
        # Split the base name into words
        $baseNameWords = $baseName -split '\s+'

        # Find a matching base name in the hashtable
        $matchingBaseName = $null
        for ($i = 0; $i -lt $baseNameWords.Count - 2; $i++) {
            $threeWords = $baseNameWords[$i..($i+2)] -join ' '
            $matchingBaseName = $baseNameDirectoryMap.Keys | Where-Object { $_ -like "$threeWords*" }
            if ($matchingBaseName) { break }
        }

        if ($matchingBaseName) {
            # If a matching base name is found, move the file to the corresponding directory
            if ($PSCmdlet.ShouldProcess("$file.FullName", "Move to $baseNameDirectoryMap[$matchingBaseName]")) {
                Move-Item -Path $file.FullName -Destination $baseNameDirectoryMap[$matchingBaseName]
            }
        } else {
            # If no matching base name is found, create a new directory and add it to the hashtable
            if ($PSCmdlet.ShouldProcess("$directory\$baseName", "Create directory")) {
                $newDirectory = New-Item -Path $directory -Name $baseName -ItemType Directory -Force
                $baseNameDirectoryMap[$baseName] = $newDirectory.FullName
            }

            # Move the file to the new directory
            if ($PSCmdlet.ShouldProcess("$file.FullName", "Move to $newDirectory.FullName")) {
                Move-Item -Path $file.FullName -Destination $newDirectory.FullName
            }
        }
    }

    # Ask user if they want to open the directory
    $openDirectory = Read-Host "Do you want to open the directory? (Y/N)"

    # If the user wants to open the directory, open it

    if ($openDirectory -eq "Y") {
        explorer.exe $directory
    }

    # Stop the transcript
    Stop-Transcript

    # Ask user if they want to open the transcript
    $openTranscript = Read-Host "Do you want to open the transcript? (Y/N)"

    # If the user wants to open the transcript, open it
    if ($openTranscript -eq "Y") {
        explorer.exe $transcript
    }

}
