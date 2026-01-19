{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix; 
  gotifyUrl = "https://gotify.thebestemail.lol/message";
in
{
  services.rpcbind.enable = true;
  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/mnt/nas_backups" = {
    device = "192.168.5.40:/mnt/ZFS-Cold-Storage/Cold-Storage/Linux/laptop-backups";
    fsType = "nfs";
    options = [ 
      "nfsvers=3"
      "x-systemd.automount" 
      "noauto"              
      "x-systemd.idle-timeout=600" 
      "soft"                
      "intr"                
      "_netdev"
    ];
  };

  systemd.services.nas_sync_failed = {
    description = "Notify Gotify on Sync Failure";
    path = [ pkgs.curl ];
    serviceConfig.User = "jake";
    script = ''
      curl -X POST "${gotifyUrl}?token=${secrets.GOTIFY_TOKEN}" \
           -F "title=❌ Backup FAILED" \
           -F "message=The NAS sync for $(hostname) failed. Check journalctl -u nas_sync." \
           -F "priority=8"
    '';
  };

  systemd.services.nas_sync = {
    description = "K8s Manifest Export and NAS Sync";
    onFailure = [ "nas_sync_failed.service" ];
    after = [ "network-online.target" "remote-fs.target" "rpcbind.service" ];
    requires = [ "network-online.target" ];

    # Added 'diffutils' for the comparison logic
    path = with pkgs; [ 
      kubectl yq rsync openssh curl bash coreutils util-linux diffutils
    ];
    
    environment = {
      KUBECONFIG = "/home/jake/.kube/config";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "jake";
      
      # Run inside the backup dir
      WorkingDirectory = "/home/jake/k8s/Backups";
      
      SuccessExitStatus = "0 23";
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      
      ExecStart = "${pkgs.writeShellScript "backup-and-sync" ''
        set -e

        echo "=== STARTING BACKUP SCRIPT ==="
        ${pkgs.bash}/bin/bash -x /home/jake/k8s/Backups/backup-cluster.sh

        echo "=== CHECKING FOR CHANGES ==="
        # 1. Find the 2 most recent backup directories (Newest first)
        # ls -td sorts by time (newest top). head -2 grabs the top two.
        DIRS=$(ls -td ./cluster-backup-*/ 2>/dev/null | head -2)
        
        # 2. Assign them to variables
        NEWEST=$(echo "$DIRS" | head -n1)
        PREVIOUS=$(echo "$DIRS" | tail -n1)

        # 3. Compare them
        if [ -n "$NEWEST" ] && [ -n "$PREVIOUS" ] && [ "$NEWEST" != "$PREVIOUS" ]; then
            echo "Comparing new backup ($NEWEST) with previous ($PREVIOUS)..."
            
            # diff -r = recursive, -q = brief (report only when files differ)
            if ${pkgs.diffutils}/bin/diff -r -q "$NEWEST" "$PREVIOUS" >/dev/null; then
                echo "♻️  No changes detected in cluster config."
                echo "🗑️  Removing redundant backup: $NEWEST"
                rm -rf "$NEWEST"
            else
                echo "📝 Changes detected. Keeping new backup: $NEWEST"
            fi
        else
            echo "ℹ️  First backup or not enough history to compare. Keeping."
        fi

        echo "=== VERIFYING LOCAL FOLDER ==="
        ls -lh /home/jake/k8s/Backups/

        echo "=== EXPORTING SECRETS ==="
        mkdir -p /home/jake/k8s/Backups/secrets-emergency
        ${pkgs.kubectl}/bin/kubectl get secrets --all-namespaces -o yaml > /home/jake/k8s/Backups/secrets-emergency/all-secrets.yaml
        chmod 600 /home/jake/k8s/Backups/secrets-emergency/all-secrets.yaml

        echo "=== SYNCING TO NAS ==="
        if mountpoint -q /mnt/nas_backups; then
          ${pkgs.rsync}/bin/rsync -av --delete \
            --no-perms --no-owner --no-group \
            --exclude="vms/vol.qcow2" \
            --exclude="target/" \
            --exclude="node_modules/" \
            --exclude=".cache/" \
            /home/jake/Documents/ \
            /home/jake/nixos-config \
            /home/jake/k8s/Backups \
            /mnt/nas_backups/ || true
        else
          echo "ERROR: Mount point /mnt/nas_backups is not active."
          exit 1
        fi

        echo "Notifying Gotify..."
        ${pkgs.curl}/bin/curl -X POST "${gotifyUrl}?token=${secrets.GOTIFY_TOKEN}" \
             -F "title=✅ Backup Successful" \
             -F "message=K8s manifests and Documents synced to NAS." \
             -F "priority=2"
      ''}";
    }; 
  }; 

  systemd.timers.nas_sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "24h";
      Persistent = true;            
      Unit = "nas_sync.service";
    };
  };
}
