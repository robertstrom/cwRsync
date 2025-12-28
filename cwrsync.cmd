@ECHO OFF
SETLOCAL

REM Specify where to find rsync and related files
SET CWRSYNCHOME=%~dp0
SET PATH=%CWRSYNCHOME%\bin;%PATH%

REM Get a filename-friendly timestamp
:: for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"') do set "LogStamp=%%a"
:; SET LOG_PATH=C:\Users\rstrom\rsync-logs\rsync_%LogStamp%.log

@echo off
SETLOCAL

REM 1. Get a safe filename date (YYYYMMDD) - No colons or hyphens
for /f "usebackq" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd'"`) do set "FileDate=%%i"

REM 2. Get the log timestamp (Keep this for the local log filename)
for /f "usebackq" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"`) do set "LogStamp=%%i"

SET LOG_PATH=C:\Users\rstrom\rsync-logs\rsync_%LogStamp%.log

SET LOG_PATH=C:\Users\rstrom\rsync-logs\rsync_!LogStamp!.log

REM --- SHARED SETTINGS ---
SET LOG=--log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log
SET SSH_KEY=-e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync"
SET SSH_CMD=ssh -i %SSH_KEY%
SET COMMON=-raivvv --no-owner --no-group --no-perms --protect-args
SET SAFETY=--delete-after --max-delete=50 --fuzzy



REM --- SETTINGS ---
SET SSH_KEY_PATH=C:\Users\rstrom\.ssh\id_ed25519_cwrsync
SET RSYNC_SSH_KEY=/cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync
SET PLEX_HOST=rstrom@192.168.0.36

REM --- 2. PLEX REMOTE OPERATIONS ---
echo *** Stopping Plex Media Server...
ssh -i "%SSH_KEY_PATH%" %PLEX_HOST% "sudo systemctl stop plexmediaserver"

echo *** Creating Plex Backup Tarball...
ssh -i "%SSH_KEY_PATH%" %PLEX_HOST% "sudo tar -czf /home/rstrom/PlexBackup_%FileDate%.tar.gz /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/"

echo *** Verifying Backup File Exists...
ssh -i "%SSH_KEY_PATH%" %PLEX_HOST% "ls -lh /home/rstrom/PlexBackup_%FileDate%.tar.gz"
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Tarball was not found! Restarting Plex and Aborting.
    ssh -i "%SSH_KEY_PATH%" %PLEX_HOST% "sudo systemctl start plexmediaserver"
    exit /b
)

echo *** Restarting Plex Media Server...
ssh -i "%SSH_KEY_PATH%" %PLEX_HOST% "sudo systemctl start plexmediaserver"

echo *** Copying Plex Backup to E: Drive...
rsync -iv %LOG% --protect-args -e "ssh -i %RSYNC_SSH_KEY%" %PLEX_HOST%:/home/rstrom/PlexBackup_%FileDate%.tar.gz "/cygdrive/e/Plex_Config_Backups/"

echo *** Deleting Plex Backups older than 10 days on Remote Host...
%SSH_CMD% rstrom@192.168.0.36 "sudo find . -maxdepth 1 -name 'PlexBackup_*.tar.gz' -mtime +10 -delete"

REM --- GROUP 1: VM IMAGES & LARGE FILES (-W for Whole File) ---
SET VM_FLAGS=%COMMON% -W --info=all
echo *** Transferring VM and Large Image Backups...

rsync %VM_FLAGS% %SAFETY% %LOG% %SSH_KEY% root@192.168.0.227:"/zfspool-1/backups/dump/" "/cygdrive/e/Proxmox-VM-Backups/"
rsync %VM_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.74:"/mnt/Data/vmware/" "/cygdrive/e/VM-Backups/Oryx-Pro-VMs/"
rsync %VM_FLAGS% %SAFETY% %LOG% %SSH_KEY% --exclude 'KVM-VMs/' rstrom@192.168.0.99:"/share/VM-Backups/VirtualMachines/" "/cygdrive/e/VM-Backups/QNAP-VM-Backups-VirtualMachines/"

REM --- GROUP 2: RASPBERRY PI & DOCKER (Sparse File Support -S) ---
SET STD_FLAGS=%COMMON% -S --info=progress2
echo *** Transferring Container and Pi Backups...

rsync %STD_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:/share/shrink-backup/ "/cygdrive/e/shrink-backup/"
rsync %STD_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/VM-Backups/Docker-container-backups/" "/cygdrive/e/VM-Backups/Docker-container-backups/"
rsync %STD_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/VM-Backups/KVM-VMs/" "/cygdrive/e/VM-Backups/KVM-VMs/"

REM --- GROUP 3: HOME DIRECTORY FILES (Space Sensitive) ---
SET HOME_FLAGS=%COMMON% -S --info=progress2
echo *** Syncing Home Directory Folders from QNAP-1...

rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/OSCP_Course/" "/cygdrive/e/QNAP-1_HomeDirFiles/OSCP_Course/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/iBike Rides/" "/cygdrive/e/QNAP-1_HomeDirFiles/iBike Rides/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Cycling/" "/cygdrive/e/QNAP-1_HomeDirFiles/Cycling/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/My Movies/" "/cygdrive/e/QNAP-1_HomeDirFiles/My Movies/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/My Music/" "/cygdrive/e/QNAP-1_HomeDirFiles/My Music/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Forensics Tools/" "/cygdrive/e/QNAP-1_HomeDirFiles/Forensics Tools/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/PenTestTools/" "/cygdrive/e/QNAP-1_HomeDirFiles/PenTestTools/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/S and K Strom/" "/cygdrive/e/QNAP-1_HomeDirFiles/S and K Strom/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Technical Documentation/" "/cygdrive/e/QNAP-1_HomeDirFiles/Technical Documentation/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Technical Training/" "/cygdrive/e/QNAP-1_HomeDirFiles/Technical Training/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Ethical_Hacking_DVD_ISOs/" "/cygdrive/e/QNAP-1_HomeDirFiles/Ethical_Hacking_DVD_ISOs/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/IRTools/" "/cygdrive/e/QNAP-1_HomeDirFiles/IRTools/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/E-Books/" "/cygdrive/e/QNAP-1_HomeDirFiles/E-Books/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/MP3 Music/" "/cygdrive/e/QNAP-1_HomeDirFiles/MP3 Music/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/IRTools_ISOs/" "/cygdrive/e/QNAP-1_HomeDirFiles/IRTools_ISOs/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/My Videos/" "/cygdrive/e/QNAP-1_HomeDirFiles/My Videos/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Libro.fm Audio Books/" "/cygdrive/e/QNAP-1_HomeDirFiles/Libro.fm Audio Books/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/My Pictures/" "/cygdrive/e/QNAP-1_HomeDirFiles/My Pictures/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Jims Music/" "/cygdrive/e/QNAP-1_HomeDirFiles/Jims Music/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Calibre Library/" "/cygdrive/e/QNAP-1_HomeDirFiles/Calibre Library/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Audio Books/" "/cygdrive/e/QNAP-1_HomeDirFiles/Audio Books/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/Software/" "/cygdrive/e/QNAP-1_HomeDirFiles/Software/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/My Videos - Not for Plex/" "/cygdrive/e/QNAP-1_HomeDirFiles/My Videos - Not for Plex/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/Win10_Work_Backup/" "/cygdrive/e/QNAP-1_HomeDirFiles/Win10_Work_Backup/"
rsync %HOME_FLAGS% %SAFETY% %LOG% %SSH_KEY% rstrom@192.168.0.99:"/share/homes/rstrom/My Documents/Penetration Testing/" "/cygdrive/e/QNAP-1_HomeDirFiles/Penetration Testing/"

REM --- CLEANUP ---
echo. >> "%LOG_PATH%"
echo *** CLEANUP LOG: Deleting log files older than 30 days *** >> "%LOG_PATH%"
powershell -NoProfile -Command "Get-ChildItem -Path 'C:\Users\rstrom\rsync-logs' -Filter 'rsync_*.log' | foreach { if ($_.LastWriteTime -lt (Get-Date).AddDays(-30)) { Write-Output \"Deleting old log: $($_.Name)\"; Remove-Item $_.FullName -Force -WhatIf} }" >> "%LOG_PATH%" 2>&1

echo Sync Complete.
ENDLOCAL
