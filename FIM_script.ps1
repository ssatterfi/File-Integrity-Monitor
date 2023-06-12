############################################
# File Integraty Monitor Lab
# Author: Scott E Satterfield
# ###########################################
#Environment Config Info ##########################
$version = "20230606"
$baselineFilePath = "C:\Scripts\Basic_FIM\baseline.csv"
$filePathtoMonitor = "C:\Scripts\Basic_FIM\Files\TestFileA.txt"
#################################################
function Add-FileToBaseline {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$baselineFilePath,
        [Parameter(Mandatory)]$targetFilePath
    )
    try {
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction stop
        }
        if ((Test-Path -Path $targetFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction stop
        }
        $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","
        if ($targetFilePath -in $currentBaseline.path) {
            Write-Output "File path detected already in baseline file"
            do {
                $overwrite = Read-Host -Prompt "Path exists already in the baseline file, Do you want to overwrite[Y/N]?"
                if ($overwrite -in @('y', 'yes')) {
                    Write-Output "Path will be overwritten"  

                    $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath -Delimiter "," 
                    $filehash = Get-FileHash -Path $filePathtoMonitor -Algorithm SHA512
                    "$($targetFilePath),$($filehash.hash)" | Out-File  -FilePath $baselineFilePath -Append 
                    Write-Output "Entry successfully added into baseline"  

                }
                elseif ($overwrite -in @('n', 'no')) {
                    Write-Output "Path will not be overwritten"
                }
                else {
                    Write-Output "Invalid Entry, please entery y to overwrite or n to overwrite"
                }
            }while ($overwrite -notin @("y", "yes", "n", "no"))         
        }
        else {
            $filehash = Get-FileHash -Path $filePathtoMonitor -Algorithm SHA512
            "$($targetFilePath),$($filehash.hash)" | Out-File  -FilePath $baselineFilePath -Append 
            Write-Output "Entry successfully added into baseline"
        }

    }
    catch {
        return $_.Exception.Message
    }
}

function Verify-Baseline {
    [CmdletBinding()]   
    param (
        [Parameter(Mandatory)]$baselineFilePath       
    )
    try {
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
        }
        $baselineFilePath = Import-Csv -Path $baselineFilePath -Delimiter ","

        foreach ($file in $baselineFilePath) {
            if (Test-Path -Path $file.path) {
                $currenthash = Get-FileHash -Path $file.path
                if ($currenthash.Hash -eq $file.hash) {
                    Write-Output "$($file.path) hash is the same"
                }
                else {
                    Write-Output "$($file.path) hash is different something has changed"
                }
            }
            else {
                Write-Output "$($file.path) is not found!"
        
            }

        }

    }
    catch {
        return $_.Exception.Message
    }
}

function Create-Baseline {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath
    )
    try {
        if ((Test-Path -Path $baselineFilePath)) {
            Write-Error -Message "$baselineFilePath already exist with this name" -ErrorAction Stop
        }
        "path,hash" | Out-File -FilePath $baselineFilePath -Force

    }
    catch {
        return $_.Exception.Message
    }
}

$baselineFilePath = "C:\Scripts\Basic_FIM\baseline.csv"

Create-Baseline -baselineFilePath $baselineFilePath
Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath "C:\Scripts\Basic_FIM\Files\TestFileA.txt"
#Verify-Baseline -baselineFilePath $baselineFilePath