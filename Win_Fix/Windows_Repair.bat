@echo off
setlocal EnableDelayedExpansion
title Complete Windows System Maintenance Tool v3.0

:: ========================================================
:: LOG CLEANUP CHECK
:: ========================================================
:: Check if any old logs exist
if exist "%USERPROFILE%\Desktop\Windows_Repair_Log_*.txt" (
    echo.
    echo ========================================================
    echo LOG FILE CLEANUP
    echo ========================================================
    echo Found previous repair logs on your Desktop.
    echo.
    set /p "CleanLogs=Do you want to delete them? (Y/N): "
    if /i "!CleanLogs!"=="Y" (
        del /q "%USERPROFILE%\Desktop\Windows_Repair_Log_*.txt"
        echo.
        echo Previous logs deleted.
        timeout /t 2 >nul
    ) else (
        echo.
        echo Keeping previous logs.
    )
)

:: ========================================================
:: CONFIGURATION & SETUP
:: ========================================================
:: Create a unique log name using timestamp
set "LogFile=%USERPROFILE%\Desktop\Windows_Repair_Log_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt"
:: Remove spaces from filename if time has single digits
set "LogFile=!LogFile: =0!"
set "PendingRestart=0"

:: Start Logging
echo ======================================================== > "!LogFile!"
echo WINDOWS SYSTEM REPAIR LOG >> "!LogFile!"
echo Date: %date% Time: %time% >> "!LogFile!"
echo ======================================================== >> "!LogFile!"

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo.
    echo Success: Administrative permissions confirmed.
) else (
    echo.
    echo ========================================================
    echo ERROR: Administrative privileges required.
    echo Please right-click this file and select "Run as administrator".
    echo ========================================================
    echo.
    pause
    del "!LogFile!"
    exit
)

echo.
echo ========================================================
echo SYSTEM MAINTENANCE STARTED
echo Logs will be saved to: "!LogFile!"
echo ========================================================
echo.

:: ========================================================
:: STEP 1: Component Store Cleanup
:: ========================================================
echo.
echo ========================================================
echo Step 1 of 5: Cleaning Component Store
echo.
echo Removing old, superseded Windows updates...
echo ========================================================

:: Log header to file
echo. >> "!LogFile!"
echo [STEP 1] Component Store Cleanup >> "!LogFile!"

DISM /Online /Cleanup-Image /StartComponentCleanup >> "!LogFile!" 2>&1
if %errorlevel% equ 0 (
    echo [OK] Component Store Cleanup Completed.
    echo [OK] Component Store Cleanup Completed. >> "!LogFile!"
) else (
    echo [ERROR] Component Store Cleanup encountered an issue.
    echo [ERROR] Component Store Cleanup encountered an issue. >> "!LogFile!"
)

:: ========================================================
:: STEP 2: Check Disk (Smart Scan)
:: ========================================================
echo.
echo ========================================================
echo Step 2 of 5: Check Disk (Scan & Auto-Schedule)
echo.
echo Scanning C: drive for file system errors...
echo ========================================================

echo. >> "!LogFile!"
echo [STEP 2] Check Disk Scan >> "!LogFile!"

:: Run scan and capture output to temp file for analysis
chkdsk C: /scan > "%temp%\chkdsk_temp.log"

:: Display output to screen AND append to log
type "%temp%\chkdsk_temp.log"
type "%temp%\chkdsk_temp.log" >> "!LogFile!"

:: Analyze logs for specific error triggers
findstr /C:"Windows has found problems that must be fixed offline" "%temp%\chkdsk_temp.log" >nul
if %errorlevel%==0 (
    echo.
    echo ! WARNING ! ERRORS DETECTED THAT REQUIRE OFFLINE REPAIR.
    echo Scheduling "chkdsk /spotfix" for the next restart...
    
    echo ! WARNING ! Offline repair required. Scheduling spotfix. >> "!LogFile!"
    
    echo y | chkdsk C: /spotfix >> "!LogFile!" 2>&1
    set "PendingRestart=1"
) else (
    echo.
    echo [OK] No offline repairs required.
    echo [OK] No offline repairs required. >> "!LogFile!"
)

:: Check specifically for "Cross-linked" files
findstr /C:"own logical cluster" "%temp%\chkdsk_temp.log" >nul
if %errorlevel%==0 (
    echo.
    echo ! CRITICAL ! Cross-linked files detected.
    echo Some files are corrupt and sharing the same disk space.
    echo A RESTART IS MANDATORY TO FIX THIS.
    
    echo ! CRITICAL ! Cross-linked files detected. >> "!LogFile!"
    set "PendingRestart=1"
)

del "%temp%\chkdsk_temp.log"

:: ========================================================
:: STEP 3: Restore System Health (DISM)
:: ========================================================
echo.
echo ========================================================
echo Step 3 of 5: Restoring System Health (DISM)
echo.
echo Checking for corruption and fixing the system image.
echo This may take some time and appear stuck at 20%% or 62.3%%.
echo ========================================================

echo. >> "!LogFile!"
echo [STEP 3] DISM RestoreHealth >> "!LogFile!"

DISM /Online /Cleanup-Image /RestoreHealth >> "!LogFile!" 2>&1
if %errorlevel% equ 0 (
    echo [OK] RestoreHealth Completed.
    echo [OK] RestoreHealth Completed. >> "!LogFile!"
) else (
    echo [ERROR] RestoreHealth failed. See logs for details.
    echo [ERROR] RestoreHealth failed. >> "!LogFile!"
)

:: ========================================================
:: STEP 4: System File Checker (SFC)
:: ========================================================
echo.
echo ========================================================
echo Step 4 of 5: System File Checker (SFC)
echo.
echo Repairing individual system files...
echo ========================================================

echo. >> "!LogFile!"
echo [STEP 4] SFC Scan >> "!LogFile!"

sfc /scannow >> "!LogFile!" 2>&1
if %errorlevel% equ 0 (
    echo [OK] SFC Scan Completed. No violations found.
    echo [OK] SFC Scan Completed. >> "!LogFile!"
) else (
    echo [INFO] SFC Scan Completed. Violations found/repaired.
    echo [INFO] SFC Scan found issues. >> "!LogFile!"
)

:: ========================================================
:: STEP 5: Network Refresh
:: ========================================================
echo.
echo ========================================================
echo Step 5 of 5: Network Refresh
echo ========================================================

echo. >> "!LogFile!"
echo [STEP 5] Network Refresh >> "!LogFile!"

ipconfig /flushdns >> "!LogFile!" 2>&1
netsh winsock reset >> "!LogFile!" 2>&1
echo [OK] Network settings reset.
echo [OK] Network settings reset. >> "!LogFile!"

:: ========================================================
:: FINAL REPORT & RESTART HANDLER
:: ========================================================
echo.
echo ========================================================
echo MAINTENANCE COMPLETE!
echo ========================================================
echo.
echo Full log saved to: "!LogFile!"
echo.

if "!PendingRestart!"=="1" (
    echo ! IMPORTANT ACTION REQUIRED !
    echo.
    echo 1. Disk errors were found that require a restart to fix (SpotFix).
    echo 2. Your computer will undergo repair during the next boot.
    echo.
    echo It is HIGHLY RECOMMENDED to restart immediately.
    echo.
    set /p "AskRestart=Do you want to restart your PC now? (Y/N): "
    if /i "!AskRestart!"=="Y" (
        echo [INFO] User initiated restart. >> "!LogFile!"
        shutdown /r /t 0
    ) else (
        echo [INFO] User deferred restart. >> "!LogFile!"
        echo.
        echo Please restart manually as soon as possible.
    )
) else (
    echo No critical disk errors were found.
    echo It is still good practice to restart to finalize network resets.
    echo.
    pause
)
