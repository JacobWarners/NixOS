let
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectRoot}/target/release/ratatat-rust";

  # 1. DEFINE LIBRARIES
  libPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];
  
  # 2. DEFINE ALSA PLUGINS
  alsaPluginDir = "${pkgs.alsa-plugins}/lib/alsa-lib";

  # 3. THE DIAGNOSTIC RUNNER (UPDATED)
  debugRunner = pkgs.writeShellScript "ratatat-debug" ''
    echo "========== RATATAT DIAGNOSTICS =========="
    
    # --- FIX: Add mpg123 to the PATH explicitly ---
    export PATH="${pkgs.mpg123}/bin:$PATH"
    # ----------------------------------------------

    echo "1. CHECKING AUDIO PLAYER:"
    if command -v mpg123 >/dev/null 2>&1; then
        echo "   [OK] mpg123 found at: $(command -v mpg123)"
    else
        echo "   [ERROR] mpg123 NOT FOUND in PATH!"
        echo "   Current PATH: $PATH"
    fi

    echo "2. CHECKING FILE:"
    # Note: main.rs uses a hardcoded absolute path, but we check here for sanity
    if [ -f "Loud-pipes.mp3" ]; then
      echo "   [OK] Loud-pipes.mp3 found in CWD."
    else
      echo "   [WARNING] Loud-pipes.mp3 not in CWD (Rust binary might use absolute path)."
    fi

    # Set up the environment for the binary
    export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
    export ALSA_PLUGIN_DIRS="${alsaPluginDir}"
    
    echo "3. STARTING BINARY..."
    exec ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "${binaryPath}"
  '';

in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener (Diagnostic)";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" "pipewire.service" ];
    wants = [ "pipewire.service" ];

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = "${debugRunner}";
      WorkingDirectory = projectRoot;
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
