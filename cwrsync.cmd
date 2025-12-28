@ECHO OFF
REM *****************************************************************
REM
REM CWRSYNC.CMD - Batch file template to start your rsync command (s).
REM
REM *****************************************************************

REM Make environment variable changes local to this batch file
SETLOCAL

REM Specify where to find rsync and related files
REM Default value is the directory of this batch file
SET CWRSYNCHOME=%~dp0

REM Make cwRsync home as a part of system PATH to find required DLLs
SET PATH=%CWRSYNCHOME%\bin;%PATH%

REM Get a filename-friendly timestamp (YYYY-MM-DD_HH-mm-ss)
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'"') do set "LogStamp=%%a"

REM Windows paths may contain a colon (:) as a part of drive designation and 
REM backslashes (example c:\, g:\). However, in rsync syntax, a colon in a 
REM path means searching for a remote host. Solution: use absolute path 'a la unix', 
REM replace backslashes (\) with slashes (/) and put -/cygdrive/- in front of the 
REM drive letter:
REM 
REM Example : C:\WORK\* --> /cygdrive/c/work/*
REM 
REM Example 1 - rsync recursively to a unix server with an openssh server :
REM
REM    rsync -r /cygdrive/c/work/ remotehost:/home/user/work/
REM
REM Example 2 - Local rsync recursively 
REM
REM    rsync -r /cygdrive/c/work/ /cygdrive/d/work/doc/
REM
REM Example 3 - rsync to an rsync server recursively :
REM  (Double colons?? YES!!)
REM
REM    rsync -r /cygdrive/c/doc/ remotehost::module/doc
REM
REM Rsync is a very powerful tool. Please look at documentation for other options. 
REM

REM ** CUSTOMIZE ** Enter your rsync command(s) here
REM rsync -avSz --progress -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" root@192.168.0.227:'/zfspool-1/backups/dump/*' "/cygdrive/e/Proxmox-VM-Backups/"

REM - trying without compression
REM The --info=all works on systems that have an up to date rsync version. This is the Proxmox server so --info=all works
REM inof=all4 also works but is very verbose
echo.
echo.
echo *** Transferring the Proxmox virtual machine backups
echo.
rsync -raivvvSWP --progress --info=all --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e 'ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync' root@192.168.0.227:'/zfspool-1/backups/dump/' "/cygdrive/e/Proxmox-VM-Backups/"


REM /share/shrink-backup

REM rsync -avSz --progress -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/shrink-backup/' "/cygdrive/e/shrink-backup/"

REM - trying without compression
REM The --info=all works on systems that have an up to date rsync version. This is the QNAP-1 NAS which has an older version of rsync and only info=progrss2 works
echo.
echo.
echo *** Transferring the shrink-backup Raspberry Pi backups
echo.
rsync -raivvvSWP  --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e 'ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync' rstrom@192.168.0.99:/share/shrink-backup/ "/cygdrive/e/shrink-backup/"


REM /share/VM-Backups

REM rsync -avSz --progress -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/VM-Backups/Docker-container-backups/' "/cygdrive/e/VM-Backups/Docker-container-backups/"

REM - trying without compression
REM The --info=all works on systems that have an up to date rsync version. This is the QNAP-1 NAS which has an older version of rsync and only info=progrss2 works
echo.
echo.
echo *** Transferring the Docker container backups
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/VM-Backups/Docker-container-backups/' "/cygdrive/e/VM-Backups/Docker-container-backups/"

REM rsync -avSz --progress -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/VM-Backups/KVM-VMs/' "/cygdrive/e/VM-Backups/KVM-VMs/"

REM - trying without compression
REM The --info=all works on systems that have an up to date rsync version. This is the QNAP-1 NAS which has an older version of rsync and only info=progrss2 works
echo.
echo.
echo *** Transferring the KVM Virtual machine backups
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/VM-Backups/KVM-VMs/' "/cygdrive/e/VM-Backups/KVM-VMs/"

REM The vmdk files were copying very, very slowly
REM From Google search
REM rsync is slow with large VMDKs because it reads/checks the whole file first, causing high I/O and overhead, especially over SSH;
REM to speed up, use -W (whole file) for direct copies, avoid compression (-z), push from source, check disk I/O on both ends (bottlenecks),
REM and consider -P or -partial for resume, or even dd for raw disk copies if applicable.
REM The files are copying much, much faster after making the change to use the -W argument
REM The --info=all works on systems that have an up to date rsync version. This is the Oryx Pro so --info=all works
REM info=all4 also works but is very verbose
echo.
echo.
echo *** Transferring the Oryx Pro VMware Virtual Machine images
echo.
rsync -raivvvW --progress --info=all --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.74:'/mnt/Data/vmware/' "/cygdrive/e/VM-Backups/Oryx-Pro-VMs/"

echo.
echo.
echo *** Transferring the VMware Virtual Machine images from \\QNAP-1\VM-Backups\VirtualMachines ***
echo.
REM *** Excludes paths are relative to the source: Exclusion paths are relative to the source directory specified in the rsync command, not the filesystem root
REM *** Filter rule order: When combining --include and --exclude rules, the order matters. Rules are processed in the order they appear, and the first match wins. The general approach is to use specific includes first, then broad excludes
rsync -raivvvW --exclude 'KVM-VMs/' --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/VM-Backups/VirtualMachines/*' "/cygdrive/e/VM-Backups/QNAP-VM-Backups-VirtualMachines/"

REM files that used to be backed up from QNAP-1 *** to B2 bucket that will now be excluded from that backup
REM files will now be copied over from the QNAP-1 to the TerraMaster DAS and then backup up to Backblaze via the Backblaze backup program
REM The --info=all works on systems that have an up to date rsync version. This is the QNAP-1 NAS which has an older version of rsync and only info=progrss2 works
echo.
echo.
echo *** Transferring the OSCP_Course from QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/OSCP_Course/' "/cygdrive/e/QNAP-1_HomeDirFiles/OSCP_Course/"
echo.
echo.
echo *** Transferring the iBike Rides from QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/iBike Rides/' "/cygdrive/e/QNAP-1_HomeDirFiles/iBike Rides/"
echo.
echo.
echo *** Transferring the Cycling information from QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Cycling/' "/cygdrive/e/QNAP-1_HomeDirFiles/Cycling/"
echo.
echo.
echo *** Transferring the files from the My Movies directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/My Movies/' "/cygdrive/e/QNAP-1_HomeDirFiles/My Movies/"
echo.
echo.
echo *** Transferring the files from the My Music directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/My Music/' "/cygdrive/e/QNAP-1_HomeDirFiles/My Music/"
echo.
echo.
echo *** Transferring the files from the Forensics Tool directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Forensics Tools/' "/cygdrive/e/QNAP-1_HomeDirFiles/Forensics Tools/"
echo.
echo.
echo *** Transferring the files from the PenTestTools directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/PenTestTools/' "/cygdrive/e/QNAP-1_HomeDirFiles/PenTestTools/"
echo.
echo.
echo *** Transferring the files from the S and K Strom directory on QNAP-1 ***
echo.
rsync -raivvvS --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" 'rstrom@192.168.0.99:/share/homes/rstrom/My Documents/S and K Strom/' '/cygdrive/e/QNAP-1_HomeDirFiles/S and K Strom/'
echo.
echo.
echo *** Transferring the files from the Technical Documentation directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Technical Documentation/' "/cygdrive/e/QNAP-1_HomeDirFiles/Technical Documentation/"
echo.
echo.
echo *** Transferring the files from the Technical Training directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Technical Training/' "/cygdrive/e/QNAP-1_HomeDirFiles/Technical Training/"
echo.
echo.
echo *** Transferring the files from the Ethical_Hacking_DVD_ISOs directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Ethical_Hacking_DVD_ISOs/' "/cygdrive/e/QNAP-1_HomeDirFiles/Ethical_Hacking_DVD_ISOs/"
echo.
echo.
echo *** Transferring the files from the IRTools directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/IRTools/' "/cygdrive/e/QNAP-1_HomeDirFiles/IRTools/"
echo.
echo.
echo *** Transferring the files from the E-Books directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/E-Books/' "/cygdrive/e/QNAP-1_HomeDirFiles/E-Books/"
echo.
echo.
echo *** Transferring the files from the MP3 Music directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/MP3 Music/' "/cygdrive/e/QNAP-1_HomeDirFiles/MP3 Music/"
echo.
echo.
echo *** Transferring the files from the IRTools_ISOs directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/IRTools_ISOs/' "/cygdrive/e/QNAP-1_HomeDirFiles/IRTools_ISOs/"
echo.
echo.
echo *** Transferring the files from the My Videos directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/My Videos/' "/cygdrive/e/QNAP-1_HomeDirFiles/My Videos/"
echo.
echo.
echo *** Transferring the files from the Libro.fm Audio Books directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Libro.fm Audio Books/' "/cygdrive/e/QNAP-1_HomeDirFiles/"
echo.
echo.
echo *** Transferring the files from the My Pictures directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/My Pictures/' "/cygdrive/e/QNAP-1_HomeDirFiles/My Pictures/"
echo.
echo.
echo *** Transferring the files from the Jims Music directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Jims Music/' "/cygdrive/e/QNAP-1_HomeDirFiles/Jims Music/"
echo.
echo.
echo *** Transferring the files from the Calibre Library directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Calibre Library/' "/cygdrive/e/QNAP-1_HomeDirFiles/Calibre Library/"
echo.
echo.
echo *** Transferring the files from the Audio Books directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Audio Books/' "/cygdrive/e/QNAP-1_HomeDirFiles/Audio Books/"
echo.
echo.
echo *** Transferring the files from the My Movies directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/My Movies/' "/cygdrive/e/QNAP-1_HomeDirFiles/My Movies/"
echo.
echo.
echo *** Transferring the files from the ~/Software directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/Software/' "/cygdrive/e/QNAP-1_HomeDirFiles/Software/"
echo.
echo.
echo *** Transferring the files from the My Videos - Not for Plex directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/My Videos - Not for Plex/' "/cygdrive/e/QNAP-1_HomeDirFiles/My Videos - Not for Plex/"
echo.
echo.
echo *** Transferring the files from the 10_Work_Backup directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/Win10_Work_Backup/' "/cygdrive/e/QNAP-1_HomeDirFiles/Win10_Work_Backup/"
echo.
echo.
echo *** Transferring the files from the Penetration Testing directory on QNAP-1 ***
echo.
rsync -raivvvS  --progress --info=progress2 --no-owner --no-group --no-perms --log-file=/cygdrive/c/Users/rstrom/rsync-logs/rsync_%LogStamp%.log -e "ssh -i /cygdrive/c/Users/rstrom/.ssh/id_ed25519_cwrsync" rstrom@192.168.0.99:'/share/homes/rstrom/My Documents/Penetration Testing/' "/cygdrive/e/QNAP-1_HomeDirFiles/Penetration Testing/"

icacls "E:\" /reset /T /C

rsync --version
ssh -V
