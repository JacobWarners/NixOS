{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix; 
  gotifyUrl = "https://gotify.thebestemail.lol/message";
in
{
  services.rpcbind.enable = true;
  boot.supportedFilesystems = [ "nfs" ];

  fileSystems."/mnt/nas_backups" = {
    device = "192.168.5.40:/mnt/ZFS-Cold-Storage/live-laptop-backups";
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

  fileSystems."/mnt/nas_media" = {
    device = "192.168.5.40:/mnt/Media/Media";
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

  fileSystems."/mnt/k8s_state" = {
    device = "192.168.5.40:/mnt/ZFS-Cold-Storage/k8s-infra/cluster-state";
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
      kubernetes-helm jq gawk
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

        # rsync exits 23/24 when files vanish mid-transfer, which is normal when
        # exporting a live cluster. Any other non-zero exit is a real failure and
        # must abort the script, so that the Gotify "✅ Backup Successful" message
        # at the end cannot fire after a sync that did not happen. Every rsync
        # here previously ended in `|| true`, which meant a totally failed sync
        # still reported success — the same silent-failure shape as the Jul 6
        # four-day outage.
        run_rsync() {
          local rc=0
          "$@" || rc=$?
          case $rc in
            0|23|24) return 0 ;;
            *) echo "ERROR: rsync failed with exit $rc" >&2; return 1 ;;
          esac
        }

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

        echo "=== SYNCING LAPTOP FILES → nas_backups (live-laptop-backups) ==="
        if mountpoint -q /mnt/nas_backups; then
          run_rsync ${pkgs.rsync}/bin/rsync -av --delete \
            --no-perms --no-owner --no-group \
            --exclude="vms/vol.qcow2" \
            --exclude="target/" \
            --exclude="node_modules/" \
            --exclude=".cache/" \
            --exclude="cluster-backup-*" \
            --exclude="secrets-emergency" \
            /home/jake/Documents/ \
            /home/jake/nixos-config \
            /home/jake/k8s/Backups \
            /mnt/nas_backups/
        else
          echo "ERROR: Mount point /mnt/nas_backups is not active."
          exit 1
        fi

        echo "=== SYNCING CLUSTER STATE → k8s_state (k8s-infra/cluster-state) ==="
        if mountpoint -q /mnt/k8s_state; then
          # Sync ONLY the newest export.
          #
          # This was `cluster-backup-*/`, which passes EVERY dated export as a
          # source; rsync merges them all into one destination, so `latest/`
          # became the union of every backup ever taken instead of a
          # point-in-time snapshot. Measured 2026-08-14 before this fix:
          # 6315 files on the NAS against 1151 in the current export — 5067 of
          # them belonging to resources that no longer exist (dead namespaces
          # williams-devspace and open-webui-ns among them), and 191 holding an
          # older version of a resource that had since changed. Restoring from
          # that would have recreated all of it, including the hostPath UniFi
          # mongo deployment whose data died with minihome.
          LATEST_EXPORT=$(ls -td /home/jake/k8s/Backups/cluster-backup-*/ 2>/dev/null | head -n1)
          if [ -z "$LATEST_EXPORT" ]; then
            echo "ERROR: no cluster-backup-* export found to sync." >&2
            exit 1
          fi
          echo "Syncing $LATEST_EXPORT -> /mnt/k8s_state/latest/"
          run_rsync ${pkgs.rsync}/bin/rsync -av --delete \
            --no-perms --no-owner --no-group \
            "$LATEST_EXPORT" \
            /mnt/k8s_state/latest/

          run_rsync ${pkgs.rsync}/bin/rsync -av \
            --no-perms --no-owner --no-group \
            /home/jake/k8s/Backups/secrets-emergency/ \
            /mnt/k8s_state/secrets-emergency/

          # Sanity gate: the destination must track the export, not outgrow it.
          # This is the assertion that would have caught the union bug in 2025
          # instead of nine months later.
          SRC_COUNT=$(find "$LATEST_EXPORT" -type f | wc -l)
          DST_COUNT=$(find /mnt/k8s_state/latest -type f | wc -l)
          echo "cluster-state file counts: export=$SRC_COUNT nas=$DST_COUNT"
          if [ "$DST_COUNT" -gt $(( SRC_COUNT * 2 )) ]; then
            echo "ERROR: /mnt/k8s_state/latest holds $DST_COUNT files vs $SRC_COUNT in the export." >&2
            echo "The destination is accumulating instead of mirroring. Refusing to report success." >&2
            exit 1
          fi
        else
          echo "ERROR: Mount point /mnt/k8s_state is not active."
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
