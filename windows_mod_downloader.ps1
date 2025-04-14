# Define folder locations
$mc_github_folder = "$env:USERPROFILE\mc_github"
$mc_mods_repo = "https://github.com/leafstrat/mc_mods"
$mc_configs_repo = "https://github.com/leafstrat/mc_configs"
$mods_folder = "$env:APPDATA\.minecraft\mods"

# Function for styled console output
function Write-ColorOutput($message, $type) {
    switch ($type) {
        "INFO" { 
            Write-Host "[$type] $message" -ForegroundColor Cyan 
        }
        "SUCCESS" { 
            Write-Host "[$type] $message" -ForegroundColor Green 
        }
        "WARNING" { 
            Write-Host "[$type] $message" -ForegroundColor Yellow 
        }
        "ERROR" { 
            Write-Host "[$type] $message" -ForegroundColor Red 
        }
        default { 
            Write-Host $message 
        }
    }
}

# Check if Git is installed
Write-ColorOutput "Checking if Git is installed..." "INFO"
try {
    $gitVersion = git --version
    Write-ColorOutput "Git is installed: $gitVersion" "SUCCESS"
} catch {
    Write-ColorOutput "Git is not installed or not in PATH. Please install Git and try again." "ERROR"
    exit 1
}

# Create the mc_github folder if it doesn't exist
Write-ColorOutput "Checking if MC GitHub folder exists..." "INFO"
if (-not (Test-Path $mc_github_folder)) {
    Write-ColorOutput "Creating MC GitHub folder at: $mc_github_folder" "INFO"
    New-Item -Path $mc_github_folder -ItemType Directory | Out-Null
    Write-ColorOutput "Folder created successfully" "SUCCESS"
} else {
    Write-ColorOutput "MC GitHub folder already exists" "INFO"
}

# Function to clone or pull a repo into a specific folder
function CloneOrPullRepo($repo_url, $folder_path, $repo_name) {
    Write-ColorOutput "Processing repository: $repo_name" "INFO"
    
    try {
        if (-not (Test-Path $folder_path)) {
            Write-ColorOutput "Cloning $repo_name from $repo_url..." "INFO"
            git clone $repo_url $folder_path
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "Successfully cloned $repo_name repository" "SUCCESS"
            } else {
                Write-ColorOutput "Failed to clone $repo_name repository" "ERROR"
                return $false
            }
        } else {
            Write-ColorOutput "Pulling the latest changes for $repo_name..." "INFO"
            Set-Location -Path $folder_path
            git pull
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "Successfully pulled latest changes for $repo_name" "SUCCESS"
            } else {
                Write-ColorOutput "Failed to pull latest changes for $repo_name" "ERROR"
                return $false
            }
        }
        return $true
    } catch {
        Write-ColorOutput "Error with Git operation: $_" "ERROR"
        return $false
    }
}

# Clone or update the repositories
Write-ColorOutput "`n===== UPDATING REPOSITORIES =====" "INFO"
$mods_success = CloneOrPullRepo $mc_mods_repo "$mc_github_folder\mc_mods" "Minecraft Mods"
$configs_success = CloneOrPullRepo $mc_configs_repo "$mc_github_folder\mc_configs" "Minecraft Configs"

# Sync mc_mods folder to .minecraft/mods
if ($mods_success) {
    Write-ColorOutput "`n===== SYNCING MODS =====" "INFO"
    $source_mods_folder = "$mc_github_folder\mc_mods"
    
    # Ensure the destination mods folder exists
    if (-not (Test-Path $mods_folder)) {
        Write-ColorOutput "Creating Minecraft mods folder at: $mods_folder" "INFO"
        New-Item -Path $mods_folder -ItemType Directory | Out-Null
        Write-ColorOutput "Minecraft mods folder created" "SUCCESS"
    }
    
    # Get all files in the source mods folder
    $source_files = Get-ChildItem -Path $source_mods_folder -File
    Write-ColorOutput "Found $($source_files.Count) mod files in repository" "INFO"
    
    # Get all files in the destination mods folder
    $destination_files = Get-ChildItem -Path $mods_folder -File -ErrorAction SilentlyContinue
    Write-ColorOutput "Found $($destination_files.Count) mod files in Minecraft folder" "INFO"
    
    # Delete files from destination that don't exist in source
    $removed_count = 0
    foreach ($dest_file in $destination_files) {
        $source_file = Join-Path $source_mods_folder $dest_file.Name
        if (-not (Test-Path $source_file)) {
            Write-ColorOutput "Removing outdated mod: $($dest_file.Name)" "WARNING"
            Remove-Item $dest_file.FullName
            $removed_count++
        }
    }
    Write-ColorOutput "Removed $removed_count outdated mod files" "INFO"
    
    # Copy files from source to destination
    $copied_count = 0
    $updated_count = 0
    foreach ($source_file in $source_files) {
        $destination_file = Join-Path $mods_folder $source_file.Name
        
        if (-not (Test-Path $destination_file)) {
            Write-ColorOutput "Installing new mod: $($source_file.Name)" "INFO"
            Copy-Item $source_file.FullName -Destination $mods_folder
            $copied_count++
        } else {
            # Compare file hash to see if content is different
            $sourceHash = Get-FileHash -Path $source_file.FullName
            $destHash = Get-FileHash -Path $destination_file
            
            if ($sourceHash.Hash -ne $destHash.Hash) {
                Write-ColorOutput "Updating mod: $($source_file.Name)" "INFO"
                Copy-Item $source_file.FullName -Destination $mods_folder -Force
                $updated_count++
            }
        }
    }
    
    Write-ColorOutput "Added $copied_count new mod files" "SUCCESS"
    Write-ColorOutput "Updated $updated_count existing mod files" "SUCCESS"
    
    Write-ColorOutput "`n===== SYNC SUMMARY =====" "INFO"
    Write-ColorOutput "Total mods in repository: $($source_files.Count)" "INFO"
    Write-ColorOutput "New mods installed: $copied_count" "INFO"
    Write-ColorOutput "Mods updated: $updated_count" "INFO"
    Write-ColorOutput "Outdated mods removed: $removed_count" "INFO"
    Write-ColorOutput "Sync completed successfully" "SUCCESS"
} else {
    Write-ColorOutput "Skipping mod sync due to repository errors" "ERROR"
}

# Return to original directory
Set-Location -Path $env:USERPROFILE

Read-Host "Press Enter to exit"
