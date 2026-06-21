param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('development', 'uat', 'production')]
    [string]$Environment
)

# Get the root directory of the project relative to the script location
$scriptDir = $PSScriptRoot
$rootDir = (Get-Item $scriptDir).Parent.FullName

# Determine the source environment file
$envFileName = ".env.$Environment"
$envFile = Join-Path $rootDir "env/$envFileName"
$targetFile = Join-Path $rootDir ".env"

# Check if environment file exists
if (-not (Test-Path $envFile)) {
    Write-Error "Environment file $envFile not found! (Expected at $envFile)"
    exit 1
}

# Copy the environment file to the project root
Copy-Item -Path $envFile -Destination $targetFile -Force

Write-Host "Environment file set to $Environment (copied $envFileName to .env in root)" -ForegroundColor Green

# --- Secret Injection Logic ---
Write-Host "Injecting secrets from .env into native config files..." -ForegroundColor Cyan

# Parse .env into a hashtable
$envVars = @{}
Get-Content $targetFile | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $parts = $_.Split('=', 2)
    $key = $parts[0].Trim()
    $val = $parts[1].Trim().Trim("'").Trim('"')
    $envVars[$key] = $val
}

# Find all .template files
$templates = Get-ChildItem -Path $rootDir -Filter "*.template" -Recurse

foreach ($template in $templates) {
    $targetPath = $template.FullName.Replace(".template", "")
    $content = Get-Content $template.FullName -Raw

    # Replace placeholders
    foreach ($key in $envVars.Keys) {
        $placeholder = "{{" + $key + "}}"
        if ($content.Contains($placeholder)) {
             $content = $content.Replace($placeholder, $envVars[$key])
        }
    }

    $content | Set-Content $targetPath -NoNewline
    Write-Host "  Generated: $($targetPath.Replace($rootDir, ""))" -ForegroundColor Gray
}
# ------------------------------

# Map input environment to enum value
$enumValue = switch ($Environment) {
    "development" { "FREE_FAKE_API" }
    "uat" { "UAT" }
    "production" { "PROD" }
}

# Update the main environment configuration
# Target the file that actually contains the environment definition
$configFile = Join-Path $rootDir "modules/app_config/lib/core/config/http/http_client/http_client_config.dart"

if (-not (Test-Path $configFile)) {
    Write-Error "Config file $configFile not found!"
    exit 1
}

$configContent = Get-Content $configFile -Raw

# Update the environment setting
# Matches both 'static Environment environment = _getEnvironmentFromArgs();'
# and 'static Environment environment = Environment.SOME_VAL;'
$pattern = 'static Environment environment = (Environment\.[A-Z_]+|_getEnvironmentFromArgs\(\));'
$replacement = "static Environment environment = Environment.$enumValue;"

if ($configContent -match $pattern) {
    $configContent = $configContent -replace $pattern, $replacement
    # Save the updated configuration
    $configContent | Set-Content $configFile -NoNewline
    Write-Host "Updated $configFile with $enumValue environment" -ForegroundColor Green
} else {
    Write-Warning "Could not find environment setting pattern in $configFile. Please check the file content."
}
