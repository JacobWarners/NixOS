{ config, pkgs, ... }:

let
  # Import your local secrets file (ensure it contains GOTIFY_TOKEN)
  secrets = import ../secrets.nix; 
  
  gotifyUrl = "https://gotify.thebestemail.lol/message";
in
{
  # Ensure background RPC services and NFS kernel modules are active
  services.rpcbind.enable = true;
  boot.supportedFilesystems = [ "nfs" ];

  # 1. The Mount Point (Lazy-mounted for boot speed)
  fileSystems."/mnt/nas_backups" = {
    device = "192.168.5.40:/mnt/ZFS-Cold-Storage/Cold-Storage/Linux/laptop-backups";
    fsType = "nfs";
    options = [ 
      "nfsvers=3"           # Forces v3 protocol
      "x-systemd.automount" 
      "noauto"              
      "x-systemd.idle-timeout=600" 
      "soft"                
      "intr"                
      "_netdev"             # Wait for network hardware
    ];
  };

  # 2. Failure Notification Service
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

  # 3. Main Backup and Sync Service
  systemd.services.nas_sync = {
    description = "K8s Manifest Export and NAS Sync";
    onFailure = [ "nas_sync_failed.service" ];
    
    after = [ "network-online.target" "remote-fs.target" "rpcbind.service" ];
    requires = [ "network-online.target" ];

    path = with pkgs; [ 
      kubectl 
      yq 
      rsync 
      openssh 
      curl 
      bash 
      coreutils 
      utillinux 
    ];
    
    environment = {
      KUBECONFIG = "/home/jake/.kube/config";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "jake";
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      
      ExecStart = pkgs.writeScript "backup-and-sync" ''
        #!${pkgs.stdenv.shell}
        set -e
        
        echo "=== STARTING BACKUP SCRIPT ==="
        # Using bash -x to show exactly what the script is doing in the logs
        # This will reveal if it fails to mkdir the new folder
        ${pkgs.bash}/bin/bash -x /home/jake/k8s/Backups/backup-cluster.sh
        
        echo "=== VERIFYING LOCAL FOLDER ==="
        # List the k8s backup folder to PROVE the new date folder exists
        ls -lh /home/jake/k8s/Backups/
        
        echo "=== EXPORTING SECRETS ==="
        mkdir -p /home/jake/k8s/Backups/secrets-emergency
        kubectl get secrets --all-namespaces -o yaml > /home/jake/k8s/Backups/secrets-emergency/all-secrets.yaml
        chmod 600 /home/jake/k8s/Backups/secrets-emergency/all-secrets.yaml
        
        echo "=== SYNCING TO NAS ==="
        if mountpoint -q /mnt/nas_backups; then
          # Removed the exclude for old backups so everything syncs
          # Still excluding the VM file that caused "Permission denied"
          ${pkgs.rsync}/bin/rsync -av --delete \
            --no-perms --no-owner --no-group \
            --exclude="vms/vol.qcow2" \
            /home/jake/Documents/ \
	    /home/jake/nix-config \
            /home/jake/k8s/Backups \
            /mnt/nas_backups/
        else
          echo "ERROR: Mount point /mnt/nas_backups is not active."
          exit 1
        fi

        echo "Notifying Gotify..."
        curl -X POST "${gotifyUrl}?token=${secrets.GOTIFY_TOKEN}" \
             -F "title=✅ Backup Successful" \
             -F "message=K8s manifests and Documents synced to NAS." \
             -F "priority=2"
      '';
    };
  };

  # 4. The Timer
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
