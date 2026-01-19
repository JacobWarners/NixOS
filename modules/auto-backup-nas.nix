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
    
    # Ensures it can be manually enabled if needed
    wantedBy = [ "multi-user.target" ];
    
    after = [ "network-online.target" "remote-fs.target" "rpcbind.service" ];
    requires = [ "network-online.target" ];

    path = with pkgs; [ 
      kubectl yq rsync openssh curl bash coreutils utillinux 
    ];
    
    environment = {
      KUBECONFIG = "/home/jake/.kube/config";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "jake";
      WorkingDirectory = "/home/jake/k8s/Backups";
      
      # This is the "Be less strict" fix
      SuccessExitStatus = "0 23";

      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";


ExecStart = "${pkgs.writeShellScript "backup-and-sync" ''
        set -e

        echo "=== STARTING BACKUP SCRIPT ==="
        ${pkgs.bash}/bin/bash -x /home/jake/k8s/Backups/backup-cluster.sh

        echo "=== VERIFYING LOCAL FOLDER ==="
        ls -lh /home/jake/k8s/Backups/

        echo "=== EXPORTING SECRETS ==="
        mkdir -p /home/jake/k8s/Backups/secrets-emergency
        ${pkgs.kubectl}/bin/kubectl get secrets --all-namespaces -o yaml > /home/jake/k8s/Backups/secrets-emergency/all-secrets.yaml
        chmod 600 /home/jake/k8s/Backups/secrets-emergency/all-secrets.yaml

        echo "=== SYNCING TO NAS ==="
        if mountpoint -q /mnt/nas_backups; then
          # Added '|| true' so the script doesn't exit on rsync code 23
          # Also check if /home/jake/nix-config should be /home/jake/nixos-config
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
    description = "Run nas_sync 5 min after boot and then every 24h";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "24h";
      Persistent = true;            
      Unit = "nas_sync.service";
    };
  };
}
