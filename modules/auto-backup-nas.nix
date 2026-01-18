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
      "_netdev"             # Tells systemd to wait for network hardware
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
    
    # dependencies: network must be online and the automount must be initialized
    after = [ "network-online.target" "remote-fs.target" "rpcbind.service" ];
    requires = [ "network-online.target" ];

    path = with pkgs; [ kubectl yq rsync openssh curl ];
    
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
        
        echo "Exporting K8s Manifests..."
        /home/jake/k8s/Backups/backup-cluster.sh
        
        echo "Exporting emergency secrets..."
        mkdir -p /home/jake/Backups/secrets-emergency
        kubectl get secrets --all-namespaces -o yaml > /home/jake/Backups/secrets-emergency/all-secrets.yaml
        chmod 600 /home/jake/Backups/secrets-emergency/all-secrets.yaml
        
        echo "Syncing to NAS..."
        # Note: Added a check to ensure the mount is actually a mount before rsyncing
        if mountpoint -q /mnt/nas_backups; then
          ${pkgs.rsync}/bin/rsync -av --delete \
            /home/jake/Documents/ \
            /home/jake/Backups/ \
            /mnt/nas_backups/
        else
          echo "Mount point /mnt/nas_backups is not active. Aborting."
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
      OnBootSec = "5m";            # Initial run 5 mins after boot
      OnUnitActiveSec = "24h";     # Subsequent runs every 24 hours
      Persistent = true;           
      Unit = "nas_sync.service";
    };
  };
}
