#!/bin/bash

# --- CONFIGURATION ---
SOURCE_USER="rstrom"
SOURCE_IP="192.168.0.99"
SSH_KEY="$HOME/.ssh/id_ed25519"
# Linux example: /mnt/e/...  | macOS example: /Volumes/E/...
DEST_BASE="/mnt/e/QNAP-1_HomeDirFiles" 
LOG_DIR="$HOME/rsync-logs"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Get a filename-friendly timestamp
LOG_STAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOG_DIR/rsync_$LOG_STAMP.log"

# --- SHARED SETTINGS ---
# Using 'rsync' command. (Note: On macOS, install via 'brew install rsync' for v3+ features)
SSH_CMD="ssh -i $SSH_KEY"
COMMON="-raivvv --no-owner --no-group --no-perms --protect-args"
SAFETY="--delete-after --max-delete=50 --fuzzy"
LOG_OPTS="--log-file=$LOG_FILE"

echo "---------------------------------------------------" >> "$LOG_FILE"
echo "Sync Started: $(date)" >> "$LOG_FILE"

# --- GROUP 1: VM IMAGES & LARGE FILES (-W) ---
VM_FLAGS="$COMMON -W --info=all"

rsync $VM_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" root@192.168.0.227:"/zfspool-1/backups/dump/" "/mnt/e/Proxmox-VM-Backups/"
rsync $VM_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" rstrom@192.168.0.74:"/mnt/Data/vmware/" "/mnt/e/VM-Backups/Oryx-Pro-VMs/"
rsync $VM_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" --exclude 'KVM-VMs/' rstrom@192.168.0.99:"/share/VM-Backups/VirtualMachines/" "/mnt/e/VM-Backups/QNAP-VM-Backups-VirtualMachines/"

# --- GROUP 2: RASPBERRY PI & DOCKER (Sparse -S) ---
STD_FLAGS="$COMMON -S --info=progress2"

rsync $STD_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" rstrom@192.168.0.99:/share/shrink-backup/ "/mnt/e/shrink-backup/"
rsync $STD_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" rstrom@192.168.0.99:"/share/VM-Backups/Docker-container-backups/" "/mnt/e/VM-Backups/Docker-container-backups/"
rsync $STD_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" rstrom@192.168.0.99:"/share/VM-Backups/KVM-VMs/" "/mnt/e/VM-Backups/KVM-VMs/"

# --- GROUP 3: HOME DIRECTORY FILES ---
HOME_FLAGS="$COMMON -S --info=progress2"

# Helper function to keep the script readable
sync_home() {
    rsync $HOME_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" "$SOURCE_USER@$SOURCE_IP:/share/homes/rstrom/My Documents/$1/" "$DEST_BASE/$1/"
}

sync_home "OSCP_Course"
sync_home "iBike Rides"
sync_home "Cycling"
sync_home "My Movies"
sync_home "My Music"
sync_home "Forensics Tools"
sync_home "PenTestTools"
sync_home "S and K Strom"
sync_home "Technical Documentation"
sync_home "Technical Training"
sync_home "Ethical_Hacking_DVD_ISOs"
sync_home "IRTools"
sync_home "E-Books"
sync_home "MP3 Music"
sync_home "IRTools_ISOs"
sync_home "My Videos"
sync_home "Libro.fm Audio Books"
sync_home "My Pictures"
sync_home "Jims Music"
sync_home "Calibre Library"
sync_home "Audio Books"
sync_home "My Videos - Not for Plex"
sync_home "Penetration Testing"

# Folders not inside "My Documents"
rsync $HOME_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" "$SOURCE_USER@$SOURCE_IP:/share/homes/rstrom/Software/" "$DEST_BASE/Software/"
rsync $HOME_FLAGS $SAFETY $LOG_OPTS -e "$SSH_CMD" "$SOURCE_USER@$SOURCE_IP:/share/homes/rstrom/Win10_Work_Backup/" "$DEST_BASE/Win10_Work_Backup/"

# --- CLEANUP ---
echo "*** CLEANUP LOG: Deleting log files older than 30 days ***" >> "$LOG_FILE"
find "$LOG_DIR" -name "rsync_*.log" -type f -mtime +30 -exec echo "Deleting old log: {}" \; -exec rm {} \; >> "$LOG_FILE" 2>&1

echo "Sync Complete: $(date)" >> "$LOG_FILE"
