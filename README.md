# Default
This is a quickstart for JR powershell scripts.
```powershell

    #region Help
        <#
        .SYNOPSIS
        This is an quick description.
        
        .DESCRIPTION
        This is a full walkthrough of what the script does.

        .PARAMETER Parameter 1
        The first parameter, such as the directory you want to use.

        .PARAMETER Parameter 2
        The second parameter, such as a file/folder destination you want to use.
        This parameter is not required. It will default to Development. 

        .PARAMETER Transcript
        The directory to save the transcript to. Defaults to the current directory and name of the function.

        .EXAMPLE

        .NOTES
        Reference any sources here and add attribution
        Last Edited <Current Date>
        #>
    #endregion Help

    #region Parameters

        # Add CmdletBinding attribute to support common parameters
        [CmdletBinding(SupportsShouldProcess)]

        #Specify Parameters. If needed set as Mandatory and any positioning. If there is a default, add it.
        param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Parameter1

        [Parameter(Mandatory=$false,)]
        [string]$Parameter2

        [Parameter(Mandatory=$false, Position=1)]
        [string]$transcript = "."
        )
    
    #endregion Parameters
    
    #region Transcript

        # Initialize a counter variable
        if (-not (Test-Path Variable:Global:LogCounter)) {
            Set-Variable -Name LogCounter -Value 0 -Scope Global
        }

        # Increment the counter
        $global:LogCounter++

        # Get the name of the current function
        $currentFunctionName = (Get-PSCallStack)[0].Command

        # Create the log file name
        $logFileName = "{0}_{1}_{2}.log" -f $currentFunctionName, (Get-Date -Format "yyyyMMdd"), $global:LogCounter

        # Create the full path to the log file
        $logFilePath = Join-Path -Path $transcript -ChildPath $logFileName

        # Start the transcript
        Start-Transcript -Path $logFilePath

    #endregion Transcript

    #region Run

    #endregion Run

    #region TranscriptReview
    
        # Stop the transcript
        Stop-Transcript
        
        # Ask user if they want to open the transcript
        $openTranscript = Read-Host -Prompt "Do you want to open the transcript? (Y/N)"
        if ($openTranscript -eq "Y") {
            Invoke-Item -Path $logFilePath
        }

    #endregion TranscriptReview   
```

# Help
Help Regions describe the parameters that you have set inside your code, as well as giving others background into your thought process. 


```powershell
    #region Help
        <#
        .SYNOPSIS
        This is an quick description.
        
        .DESCRIPTION
        This is a full walkthrough of what the script does.

        .PARAMETER Parameter 1
        The first parameter, such as the directory you want to use.

        .PARAMETER Parameter 2
        The second parameter, such as a file/folder destination you want to use.
        This parameter is not required. It will default to Development. 

        .PARAMETER Transcript

        .EXAMPLE
        
        .NOTES
        Reference: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/upload-generalized-managed
        Created by James Ruland 13 November 2021
        Last Edited 12 October 2021
        #>
    #endregion Help
```


# Transcript
The Transcript Region allows you to create a log of what your script/function/module is doing. 
The Transcript Region sets up the variables and starts the transcript, and the review region stops the logging it before asking if the user wishes to review.

```powershell

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

    #region TranscriptReview

    # Stop the transcript
    Stop-Transcript
    
    # Ask user if they want to open the transcript
    $openTranscript = Read-Host -Prompt "Do you want to open the transcript? (Y/N)"
    if ($openTranscript -eq "Y") {
        Invoke-Item -Path $logFilePath
    }

    #endregion TranscriptReview
```
