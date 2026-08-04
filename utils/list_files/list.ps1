# --- CONFIGURATION ---
$TargetFolders = @(
    @{ Path = "design"; Recurse = $false },
    @{ Path = "lib"; Recurse = $true },
    @{ Path = "functions"; Recurse = $true; Exclude = @("functions\venv", "functions\__pycache__") }
)

# Resolves 2 levels up from utils\list_files\ to project root
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

function Ensure-RelativePath ($Root, $Full) {
    if ($Full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Full.Substring($Root.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    }
    return $Full
}

# Single output file destination
$OutputFile = "$PSScriptRoot\llm_project_paths.txt"

# Reset/create blank output file on fresh run
Clear-Content -Path $OutputFile -ErrorAction SilentlyContinue

foreach ($Target in $TargetFolders) {
    $FolderRelativePath = $Target.Path
    $FolderFullPath     = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $FolderRelativePath))

    $ShouldRecurse  = if ($Target.ContainsKey('Recurse')) { $Target.Recurse } else { $false }
    $FilterIncludes = if ($Target.ContainsKey('Include')) { $Target.Include } else { $null }

    $Exclusions = @()
    if ($Target.ContainsKey('Exclude') -and $Target.Exclude) {
        $Exclusions = $Target.Exclude | ForEach-Object { 
            [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot $_)) 
        }
    }

    if (-not (Test-Path $FolderFullPath)) {
        Write-Warning "Directory not found, skipping: $FolderFullPath"
        continue
    }

    Write-Host "`nScanning directory: $FolderRelativePath (Recurse: $ShouldRecurse)" -ForegroundColor Yellow

    # Removed -File parameter so Get-ChildItem captures both files (empty or not) and directories
    $GciParams = @{
        Path = $FolderFullPath
    }
    if ($ShouldRecurse)   { $GciParams.Recurse = $true }
    if ($FilterIncludes) { $GciParams.Include = $FilterIncludes }

    $Items = Get-ChildItem @GciParams
    $PathList = [System.Collections.Generic.List[string]]::new()

    foreach ($Item in $Items) {
        $NormalizedPath = [System.IO.Path]::GetFullPath($Item.FullName)

        $IsExcluded = $false
        foreach ($ExcludePath in $Exclusions) {
            $CheckPath = $ExcludePath
            if (-not $CheckPath.EndsWith([System.IO.Path]::DirectorySeparatorChar) -and (Test-Path $CheckPath -PathType Container)) {
                $CheckPath += [System.IO.Path]::DirectorySeparatorChar
            }

            if ($NormalizedPath.StartsWith($CheckPath, [System.StringComparison]::OrdinalIgnoreCase) -or 
                $NormalizedPath.Equals($ExcludePath, [System.StringComparison]::OrdinalIgnoreCase)) {
                $IsExcluded = $true
                break
            }
        }

        if ($IsExcluded) { continue }

        $RelativePath = Ensure-RelativePath $ProjectRoot $NormalizedPath
        
        # Append trailing separator if it's a folder to make structure obvious
        if ($Item.PSIsContainer) {
            $RelativePath += "\"
        }

        $PathList.Add($RelativePath)
        Write-Host "   Path listed: $RelativePath"
    }

    $TotalItems = $PathList.Count
    $PathsText  = $PathList -join "`n"

    $Header = @"
========================================================================
FILE PATH STRUCTURE FOR: $FolderRelativePath
Total Items Listed: $TotalItems
========================================================================
"@

    # Append header and paths into the single file
    Add-Content -Path $OutputFile -Value $Header
    if ($PathsText) {
        Add-Content -Path $OutputFile -Value $PathsText
    }
    Add-Content -Path $OutputFile -Value "`n"
}

Write-Host "`nSuccess! All file and directory paths compiled into: $OutputFile" -ForegroundColor Green