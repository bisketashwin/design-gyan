# ============================================================================
# CONFIGURATION
# ============================================================================

# Ignore these folder/file names anywhere in the project
$GlobalIgnoreNames = @(
    "__pycache__",
    ".git",
    ".github",
    ".dart_tool",
    ".idea",
    ".vscode",
    "node_modules",
    "build",
    "dist",
    "bin",
    "obj",
    ".vs",
    ".pytest_cache"
)

# Ignore files by wildcard
$GlobalIgnorePatterns = @(
    "*.g.dart",
    "*.pyc",
    "*.pyo",
    "*.log",
    "*.tmp",
    "*.cache"
)

# Target folders
$TargetFolders = @(
    # @{ Path = "design" }

    @{ Path = "lib" }

    # @{
    #     Path = "functions"
    #     Exclude = @(
    #         "functions\venv"
    #         # Example:
    #         # "functions\main.py"
    #     )
    # }
)

# Remove blank lines and Dart comments
$Optimize = $true

# ============================================================================
# HELPERS
# ============================================================================

function Ensure-RelativePath($Root, $Full) {
    if ($Full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Full.Substring($Root.Length).TrimStart('\','/')
    }
    return $Full
}

function Test-GlobalIgnore {
    param(
        [string]$FullPath
    )

    $Parts = $FullPath -split '[\\/]'

    foreach ($Name in $GlobalIgnoreNames) {
        if ($Parts -contains $Name) {
            return $true
        }
    }

    $FileName = [System.IO.Path]::GetFileName($FullPath)

    foreach ($Pattern in $GlobalIgnorePatterns) {
        if ($FileName -like $Pattern) {
            return $true
        }
    }

    return $false
}

function Test-TargetExclude {
    param(
        [string]$FullPath,
        [array]$ExcludePaths
    )

    foreach ($ExcludePath in $ExcludePaths) {

        $CheckPath = $ExcludePath

        if (
            (Test-Path $ExcludePath -PathType Container) -and
            (-not $CheckPath.EndsWith([IO.Path]::DirectorySeparatorChar))
        ) {
            $CheckPath += [IO.Path]::DirectorySeparatorChar
        }

        if (
            $FullPath.Equals($ExcludePath,
                [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            return $true
        }

        if (
            $FullPath.StartsWith(
                $CheckPath,
                [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            return $true
        }
    }

    return $false
}

# ============================================================================
# MAIN
# ============================================================================

$ProjectRoot = (Resolve-Path "$PSScriptRoot\..\..").Path

foreach ($Target in $TargetFolders) {

    $FolderRelativePath = $Target.Path
    $FolderFullPath = [IO.Path]::GetFullPath(
        (Join-Path $ProjectRoot $FolderRelativePath)
    )

    if (-not (Test-Path $FolderFullPath)) {
        Write-Warning "Directory not found: $FolderFullPath"
        continue
    }

    $Exclusions = @()

    if ($Target.ContainsKey("Exclude")) {
        $Exclusions = $Target.Exclude | ForEach-Object {
            [IO.Path]::GetFullPath((Join-Path $ProjectRoot $_))
        }
    }

    $CleanFolderName = $FolderRelativePath -replace '[\\/]', '_'
    $OutputFile = Join-Path $PSScriptRoot "llm_${CleanFolderName}_context.txt"

    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "Scanning : $FolderRelativePath" -ForegroundColor Yellow
    Write-Host "Output   : $OutputFile" -ForegroundColor Gray

    if ($Exclusions.Count -gt 0) {
        Write-Host "Custom Excludes:" -ForegroundColor DarkYellow
        $Target.Exclude | ForEach-Object {
            Write-Host "   $_"
        }
    }

    $TempFile = [IO.Path]::GetTempFileName()
    $ProcessedCount = 0

    Get-ChildItem -Path $FolderFullPath -File -Recurse | ForEach-Object {

        $File = $_
        $FullName = [IO.Path]::GetFullPath($File.FullName)

        # Global ignores
        if (Test-GlobalIgnore $FullName) {
            return
        }

        # Per-target excludes
        if (Test-TargetExclude -FullPath $FullName -ExcludePaths $Exclusions) {
            return
        }

        $RelativePath = Ensure-RelativePath $ProjectRoot $FullName

        Write-Host "   $RelativePath"

        $ProcessedCount++

        Add-Content $TempFile "`n=== START OF FILE: $RelativePath ==="

        if ($Optimize) {

            foreach ($Line in Get-Content $FullName) {

                $Trimmed = $Line.Trim()

                if ([string]::IsNullOrWhiteSpace($Trimmed)) {
                    continue
                }

                if (
                    $File.Extension -eq ".dart" -and
                    $Trimmed.StartsWith("//")
                ) {
                    continue
                }

                Add-Content $TempFile $Line
            }

        }
        else {

            Add-Content $TempFile (Get-Content $FullName -Raw)

        }

        Add-Content $TempFile "=== END OF FILE: $RelativePath ===`n"
    }

    $RawText = ""

    if (Test-Path $TempFile) {
        $RawText = Get-Content $TempFile -Raw
    }

    $CharCount = $RawText.Length
    $EstimatedTokens = [Math]::Round($CharCount / 3.2)

    $Header = @"
========================================================================
METADATA & CONTEXT METRICS FOR: $FolderRelativePath

Files Included        : $ProcessedCount
Character Count       : $CharCount
Estimated Token Count : ~$EstimatedTokens

========================================================================

"@

    Set-Content $OutputFile $Header

    if ($RawText.Length -gt 0) {
        Add-Content $OutputFile $RawText
    }

    Remove-Item $TempFile -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Completed : $ProcessedCount files" -ForegroundColor Green
    Write-Host "Characters: $CharCount" -ForegroundColor Cyan
    Write-Host "Tokens    : ~$EstimatedTokens" -ForegroundColor Cyan
    Write-Host ""
}