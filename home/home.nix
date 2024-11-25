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
      # Set prefix to normal
set -g prefix C-b

# Enable mouse mode (allows for selecting panes, resizing with the mouse)

# Set the base index for windows to 1 (default is 0)
set -g base-index 1

# Set the default terminal mode to 256 colors
set -g default-terminal "screen-256color"

#Set Kitty
#set-option -ga terminal-overrides ",xterm-kitty:Tc"


# Status bar configuration
set -g status-interval 5
set -g status-justify centre
set-option -g status-position top

# Set status bar colors and format
set -g status-style bg=colour235,fg=colour136

# Left side of status bar
set -g status-left-length 40
set -g status-left '#[fg=colour46,bg=colour235] #S #[default]'
# Right side of status bar
set -g status-right-length 150
set -g status-right '#[fg=colour136,bg=colour235] %Y-%m-%d #[fg=colour136,bg=colour235] %H:%M #[default]'

# Window tabs styling
setw -g window-status-style bg=colour235,fg=colour136
setw -g window-status-current-style bg=colour240,fg=colour255
setw -g window-status-format '#[fg=colour136] #I #[fg=colour250]#W #[fg=colour244]#{?window_flags,#F, }'
setw -g window-status-current-format '#[bg=colour240,fg=colour51] #I #[bg=colour240,fg=colour255]#W #[fg=colour244]#{?window_flags,#F, }'

# Pane border styling
set -g pane-border-style fg=colour235
set -g pane-active-border-style fg=colour51

# Pane number display
set -g display-panes-active-colour colour51
set -g display-panes-colour colour235

# Enable window renaming
set -g allow-rename on
# Reload configuration with prefix + r
bind r source-file ~/.tmux.conf \; display "Config relo
aded!"

# Copy and paste integration with Linux clipboard
 bind-key -T copy-mode-vi MouseDragEnd1Pane send -X cop
y-pipe-and-cancel "xclip -selection clipboard -i"
 bind-key -T copy-mode-vi y send -X copy-pipe-and-cance
l "xclip -selection clipboard -i"

#Bind new panes and windows to current path 
bind-key c new-window -c "#{pane_current_path}"
bind-key % split-window -h -c "#{pane_current_path}"
bind-key '"' split-window -v -c "#{pane_current_path}"

# Navigate between panes with arrow keys
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Use Alt + hjkl for pane navigation
 bind -n M-h select-pane -L
 bind -n M-j select-pane -D
 bind -n M-k select-pane -U
 bind -n M-l select-pane -R

# Resize panes with arrow keys + prefix
# Use Ctrl + Alt + h/j/k/l for resizing panes
bind -n C-h resize-pane -L 5
bind -n C-j resize-pane -D 5
bind -n C-k resize-pane -U 5
bind -n C-l resize-pane -R 5

# Use vi keys in copy mode
setw -g mode-keys vi

# Set Zsh as the default shell
set-option -g default-shell /etc/profiles/per-user/jake/bin/zsh

set -g mouse on
'';
};

  # Install user-specific packages
  home.packages = with pkgs; [
    zsh       # Ensure Zsh is included in packages
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



  # Link dotfiles
  home.file.".zshrc".source = ./dotfiles/.zshrc;
#  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".config/kitty".source = ./kitty;
  home.file.".icons".source = ./dotfiles/.icons;


  # Ensure the .ssh directory exists with correct permissions
#  home.file.".ssh" = {
#    directory = true;
#    mode = "0700";
#  };

  # SSH key management
#  home.file.".ssh/id_ed25519" = {
#    source = ../secrets/ssh/id_ed25519;
#    mode = "0600";
#  };
#  home.file.".ssh/id_ed25519.pub" = {
#    source = ../secrets/ssh/id_ed25519.pub;
#    mode = "0644";
#  };
}

