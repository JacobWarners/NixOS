{ config, pkgs, ... }:

{
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "23.05"; # Adjust this to match your Home Manager version

  #ZSH
  programs.zsh = {
    enable = true;
  };

  #TMUX and VIM
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      bind-key S setw synchronize-panes

    '';
  };

  # Install user-specific packages
  home.packages = with pkgs; [
    zsh # Ensure Zsh is included in packages
    yazi
    # Add other user-specific packages here
  ];

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox
    ];
    extraConfig = ''
      " Adds syntax highlighting
      syntax on

      " Color scheme
      colorscheme gruvbox
      set background=dark

      " Enable line numbers
      set number

      " Set cursorline
      set cursorline

      " Show matching parentheses
      set showmatch

      " Toggle paste with F2
      set pastetoggle=<F2>

      " Enable mouse support
      set mouse=a

      " Custom keybinding to exit directory with Q
      nnoremap Q :Rexplore<CR>
      inoremap jj <Esc>
    '';
  };

    home.sessionVariables = {
      PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
            };

            
  # librewolf settings
  home.sessionVariables = {
  XDG_DATA_DIRS = "${config.home.homeDirectory}/.nix-profile/share:/run/current-system/sw/share:/usr/local/share:/usr/share";
};
home.sessionVariables = {
  BROWSER = "librewolf";
};
programs.zsh.initContent = ''
  alias firefox="librewolf"
'';


programs.librewolf = {
  enable = true;
  settings = {
    # Adjust cookie clearing on exit
    "privacy.clearOnShutdown.cookies" = false;
    "privacy.clearOnShutdown.cache" = false;
    "privacy.clearOnShutdown.downloads" = false;
    "privacy.clearOnShutdown.formdata" = false;
    "privacy.clearOnShutdown.offlineApps" = false;
    "privacy.clearOnShutdown_v2.cache" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    "privacy.sanitize.sanitizeOnShutdown" = false;

    # Adjust cookie lifetime policy (closer to Firefox)
    "network.cookie.lifetimePolicy" = 0;

    # Enable autofill and history saving
    "browser.formfill.enable" = true;
    "places.history.enabled" = true;

    # Adjust browser homepage
    "browser.startup.homepage" = "https://chatgpt.com/?model=gpt-4o";

    # Adjust search engine
    "browser.policies.runOncePerModification.setDefaultSearchEngine" = "DuckDuckGo";
    "browser.urlbar.placeholderName" = "Google";

    # Privacy & Fingerprinting adjustments
    "privacy.fingerprintingProtection" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.emailtracking.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;

    # Safe browsing adjustments
    "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
    "browser.safebrowsing.downloads.remote.block_uncommon" = false;
    "browser.safebrowsing.downloads.remote.enabled" = false;

    # Disable captive portal
    "network.captive-portal-service.enabled" = false;
    "network.connectivity-service.enabled" = false;

    # Disable prefetching & speculative connections
    "network.predictor.enabled" = false;
    "network.prefetch-next" = false;

    # Remove unnecessary permissions delegation
    "permissions.delegation.enabled" = false;

    # Remove Google Safe Browsing data-sharing URL
    "browser.safebrowsing.provider.google4.dataSharingURL" = "";

    # Remove Mozilla tracking
    "browser.region.network.url" = "";
    "browser.region.update.enabled" = false;

    # Installed Extensions
    "browser.policies.runOncePerModification.extensionsInstall" = "[\"https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi\"]";

    # Remove Default Search Engines (except DuckDuckGo)
    "browser.policies.runOncePerModification.extensionsUninstall" = "[\"google@search.mozilla.org\",\"bing@search.mozilla.org\",\"amazondotcom@search.mozilla.org\",\"ebay@search.mozilla.org\",\"twitter@search.mozilla.org\"]";
    "browser.policies.runOncePerModification.removeSearchEngines" = "[\"Google\",\"Bing\",\"Amazon.com\",\"eBay\",\"Twitter\"]";
  };
};


#Flatpak
  services.flatpak.enable = true;
  

  # Link dotfiles
  home.file.".zshrc".source = ./dotfiles/.zshrc;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".config/kitty".source = ./kitty;
  home.file.".icons".source = ./dotfiles/.icons;
}
