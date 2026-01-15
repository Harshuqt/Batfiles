@echo off
title Complete Windows System Maintenance Tool

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo.
    echo ========================================================
    echo ERROR: Administrative privileges required.
    echo Please right-click this file and select "Run as administrator".
    echo ========================================================
    pause
    exit
)

echo.
echo ========================================================
echo Step 1 of 5: Cleaning Component Store
echo.
echo Removing old, superseded Windows updates to clean up
echo the "source" image before we try to repair it.
echo ========================================================
DISM /Online /Cleanup-Image /StartComponentCleanup

echo.
echo ========================================================
echo Step 2 of 5: Check Disk (Scan Only)
echo.
echo Scanning C: drive for file system errors.
echo NOTE: This runs an online scan and will NOT require a reboot.
echo ========================================================
chkdsk C: /scan

echo.
echo ========================================================
echo Step 3 of 5: Restoring System Health (DISM)
echo.
echo Checking for corruption and fixing the system image.
echo This may take some time and appear stuck at 20%%.
echo ========================================================
DISM /Online /Cleanup-Image /RestoreHealth

echo.
echo ========================================================
echo Step 4 of 5: System File Checker (SFC)
echo.
echo Repairing individual system files using the fresh image.
echo ========================================================
sfc /scannow

echo.
echo ========================================================
echo Step 5 of 5: Network Refresh (Optional)
echo.
echo Flushing DNS and resetting Winsock to clear connection issues.
echo ========================================================
ipconfig /flushdns
netsh winsock reset

echo.
echo ========================================================
echo MAINTENANCE COMPLETE!
echo.
echo If "Check Disk" or "SFC" reported errors they couldn't fix,
echo you may need to restart your PC to finish repairs.
echo ========================================================
pause
