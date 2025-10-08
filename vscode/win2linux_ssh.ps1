# Excutable permissions  
# powershell -ExecutionPolicy Bypass -File ".\setup-ssh-key.ps1"
# RUN : \setup-ssh-key.ps1 -Hostname "mahesh@myserver.com"
# RUN : \setup-ssh-key.ps1 -Hostname "mahesh@myserver.com" -PublicKeyPath "$HOME\.ssh\custom_key.pub"
 
param(
    [Parameter(Mandatory=$true)]
    [string]$Hostname,
    
    [Parameter(Mandatory=$false)]
    [string]$PublicKeyPath = "$HOME\.ssh\default_key.pub"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    SSH Key Setup Script for VS Code   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Validate hostname format
if ($Hostname -notmatch "^[\w\.-]+@[\w\.-]+$") {
    Write-Host "Error: Invalid hostname format. Please use format: user@hostname" -ForegroundColor Red
    Write-Host "Example: mahesh@myserver.com"
    exit 1
}

# Check if public key exists
if (-not (Test-Path $PublicKeyPath)) {
    Write-Host "Error: SSH public key not found at: $PublicKeyPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "To generate an SSH key pair, run:" -ForegroundColor Yellow
    Write-Host "ssh-keygen -t rsa -b 4096 -C your.email@domain.com" -ForegroundColor Yellow
    exit 1
}

# Display configuration
Write-Host "Configuration:" -ForegroundColor Green
Write-Host "  Target Host: $Hostname" -ForegroundColor White
Write-Host "  Public Key:  $PublicKeyPath" -ForegroundColor White
Write-Host ""

# Read public key
if (Test-Path $PublicKeyPath) {
    $pubKey = Get-Content $PublicKeyPath -Raw
    Write-Host "Successfully read public key" -ForegroundColor Green
} else {
    Write-Host "Error: Failed to read public key file" -ForegroundColor Red
    exit 1
}

# Confirm before proceeding
Write-Host ""
Write-Host "Do you want to proceed with SSH key setup?" -ForegroundColor Yellow
Write-Host "Type 'y' for yes or 'n' for no:" -ForegroundColor Yellow
$confirmation = Read-Host "Enter your choice"

if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Operation cancelled by user" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Setting up SSH key authentication..." -ForegroundColor Green
Write-Host "You may be prompted for your password to complete the setup." -ForegroundColor Yellow
Write-Host ""

# Clean the public key 
$cleanPubKey = $pubKey.Trim()

# Execute SSH command
Write-Host "Executing SSH setup command..." -ForegroundColor Blue

# Use proper quoting for the SSH command
ssh $Hostname "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$cleanPubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SSH key setup completed successfully!" -ForegroundColor Green
    Write-Host "Test your connection:" -ForegroundColor Green
    Write-Host "ssh $Hostname" -ForegroundColor Yellow
} else {
    Write-Host "SSH key setup failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Script completed!" -ForegroundColor Green
