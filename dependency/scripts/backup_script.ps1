param (
    [Parameter(Mandatory=$false)]
    [string]$BackupLocation = "$env:USERPROFILE\phone_backups"  # Default to ~/phone_backups if not provided
)

# Configuration
$BackupName = "mission1_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"
$TWRPBackupDir = "/sdcard/TWRP/BACKUPS"
$LocalDir = $BackupLocation
$DeviceSerial = (adb devices -l | Where-Object { $_ -notmatch "List of devices" -and $_ -match "\S+\s+device" } | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)

# Check if device is connected
if (-not $DeviceSerial) {
    Write-Host "[ERROR] No device connected via ADB or not in expected state!" -ForegroundColor Red
    adb devices -l
    exit 1
}
Write-Host "[INFO] Device detected: $DeviceSerial" -ForegroundColor Green

# Create local backup directory
if (-not (Test-Path $LocalDir)) {
    New-Item -Path $LocalDir -ItemType Directory -Force
}
Write-Host "[INFO] Local backup directory: $LocalDir" -ForegroundColor Green

# Reboot into TWRP
Write-Host "[INFO] Rebooting into TWRP..." -ForegroundColor Green
adb -s $DeviceSerial reboot recovery

# Wait for TWRP to boot
Write-Host "[INFO] Waiting for TWRP to start..." -ForegroundColor Green
do {
    $TWRPCheck = adb -s $DeviceSerial shell "ls /sbin 2>/dev/null" | Where-Object { $_ -match "twrp" }
    if (-not $TWRPCheck) {
        Write-Host "[INFO] Still waiting for TWRP (device state: $(adb -s $DeviceSerial get-state))..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
} until ($TWRPCheck)
Write-Host "[INFO] TWRP detected." -ForegroundColor Green

# Create backup in TWRP (Boot, Data, EFS)
Write-Host "[INFO] Starting backup of Boot, Data, EFS..." -ForegroundColor Green
adb -s $DeviceSerial shell "twrp backup BDE '$BackupName' &"

# Wait for backup to complete
$BackupPath = "$TWRPBackupDir/$DeviceSerial/$BackupName"
Write-Host "[INFO] Waiting for backup to finish..." -ForegroundColor Green
do {
    $BackupFiles = adb -s $DeviceSerial shell "ls '$BackupPath' 2>/dev/null" | Where-Object { $_ -match "data.*win" }
    if (-not $BackupFiles) {
        Write-Host "[INFO] Backup in progress (checking $BackupPath)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
} until ($BackupFiles)
Write-Host "[INFO] Backup completed." -ForegroundColor Green

# Pull backup to computer
Write-Host "[INFO] Pulling backup from $BackupPath to $LocalDir..." -ForegroundColor Green
adb -s $DeviceSerial pull "$BackupPath" "$LocalDir/"
if ($LASTEXITCODE -eq 0) {
    Write-Host "[INFO] Backup saved to $LocalDir/$BackupName" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to pull backup!" -ForegroundColor Red
    exit 1
}

# Reboot to system
Write-Host "[INFO] Rebooting to system..." -ForegroundColor Green
adb -s $DeviceSerial reboot

# Wait for system to boot
Write-Host "[INFO] Waiting for system to boot..." -ForegroundColor Green
do {
    $State = adb -s $DeviceSerial get-state
    if ($State -ne "device") {
        Start-Sleep -Seconds 2
    }
} until ($State -eq "device")
Write-Host "[INFO] System booted." -ForegroundColor Green

Write-Host "[INFO] Backup complete!" -ForegroundColor Green