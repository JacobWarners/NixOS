#!/bin/bash

# Function to detect the package manager and install packages
install_package() {
    local package=$1
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y $package
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm $package
    elif command -v yum &> /dev/null; then
        sudo yum install -y $package
    elif command -v pkg &> /dev/null; then
        sudo pkg install -y $package
    else
        echo "No known package manager found. Please install $package manually."
        exit 1
    fi
}

# Install necessary programs
install_package zsh
install_package tmux
install_package vim
install_package dconf-cli

# Define the dotfiles content
zshrc_content=$(cat << 'EOF'
# Load and initialize the completion system
autoload -Uz compinit
compinit

# Enable color support for ls and define the color scheme
if [[ "$TERM" == "xterm-256color" ]]; then
  export CLICOLOR=1
  export LSCOLORS=ExFxCxDxBxegedabagacad
fi

# Use GNU ls if available, otherwise use BSD ls
if command -v gls > /dev/null; then
  alias ls='gls --color=auto'
else
  alias ls='ls -G'
fi

# Define LS_COLORS to customize colors for different file types
export LS_COLORS='di=34:ex=32:*.zip=31:*.tar=31:*.tgz=31:*.gz=31:*.bz2=31:'

# Enable menu selection with tab
zstyle ':completion:*' menu select

# Define colors for the completion list
zstyle ':completion:*:default' list-colors ''

# Format descriptions
zstyle ':completion:*:descriptions' format '%B%d%b'

# Format messages and warnings
zstyle ':completion:*:messages' format '%B%d%b'
zstyle ':completion:*:warnings' format '%B%d%b'

# Show all matches at once without having to scroll
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Enable detailed and multi-column completion lists
zstyle ':completion:*' list-prompt %S%M matches%s
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Improve the look of the completion menu
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Allow partial completion
zstyle ':completion:*' completer _complete _approximate

# Avoid showing duplicate matches
zstyle ':completion:*' squeeze-multiple true

# Ensure proper alignment of columns
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Reduce spacing between items
zstyle ':completion:*' list-separator ' '

# Set the prompt to show username and current directory
autoload -U colors && colors

# Define colors
BLUE="%F{blue}"
GREEN="%F{green}"
RESET="%f"

# Set the prompt
PS1="${GREEN}%n${BLUE}~%1d${RESET}> "

# Alias for ls with color support
alias ls='ls --color=auto'
EOF
)

tmux_conf_content=$(cat << 'EOF'
# Set prefix to normal
set -g prefix C-b

# Enable mouse mode (allows for selecting panes, resizing with the mouse)
set -g mouse on

# Set the base index for windows to 1 (default is 0)
set -g base-index 1

# Set the default terminal mode to 256 colors
set -g default-terminal "screen-256color"

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
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Copy and paste integration with Linux clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -selection clipboard -i"

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
set-option -g default-shell /bin/zsh
EOF
)

vimrc_content=$(cat << 'EOF'
" initialize plugin system
call plug#begin('~/.vim/plugged')

" Add Gruvbox
Plug 'morhetz/gruvbox'

call plug#end()

" Adds syntax highlighting
syntax on

" Color scheme
colorscheme gruvbox

set background=dark

" Enable line numbers
set number

"Set cursorline
set cursorline

" show matching paraentheses
set showmatch

" Toggle paste, first always set to paste then toggle here
set paste
set pastetoggle=<F2>

set mouse=a

" Exit to directory with Q
nnoremap Q :Rexplore<CR>

EOF
)

# Write the dotfiles to the home directory
echo "$zshrc_content" > ~/.zshrc
echo "$tmux_conf_content" > ~/.tmux.conf
echo "$vimrc_content" > ~/.vimrc

# Create a script for configuring GNOME Terminal with Gruvbox theme
gnome_terminal_script=$(cat << 'EOF'
#!/bin/bash

# Ensure dconf is installed
if ! command -v dconf &> /dev/null; then
    echo "dconf-cli not found, installing..."
    sudo pacman -S --noconfirm dconf
fi

# Get the default profile UUID
default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
echo "Default Profile UUID: $default_profile"

# Create a new profile UUID
new_profile=$(uuidgen)
echo "New Profile UUID: $new_profile"

# Copy settings from default profile to new profile
dconf dump /org/gnome/terminal/legacy/profiles:/:$default_profile/ | dconf load /org/gnome/terminal/legacy/profiles:/:$new_profile/

# Add the new profile to the list of profiles
profiles_list=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d "[]," | tr -d "'")
gsettings set org.gnome.Terminal.ProfilesList list "[${profiles_list// /,}, '$new_profile']"

# Set the new profile as default (optional)
#gsettings set org.gnome.Terminal.ProfilesList default "$new_profile"

# Apply Gruvbox colors to the new profile
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/background-color "'#282828'"
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/foreground-color "'#ebdbb2'"
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/bold-color "'#ebdbb2'"
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/cursor-colors-set true
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/cursor-background-color "'#ebdbb2'"
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/cursor-foreground-color "'#282828'"
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/use-theme-colors false
dconf write /org/gnome/terminal/legacy/profiles:/:$new_profile/palette "['#282828', '#cc241d', '#98971a', '#d79921', '#458588', '#b16286', '#689d6a', '#a89984', '#928374', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#ebdbb2']"

echo "Gruvbox theme applied to new GNOME Terminal profile."
EOF
)

# Write the GNOME Terminal script to a file
echo "$gnome_terminal_script" > ~/configure_gnome_terminal.sh

# Make the script executable
chmod +x ~/configure_gnome_terminal.sh

# Execute the script to configure GNOME Terminal
~/configure_gnome_terminal.sh

echo "Configuration complete. Please restart your terminal."

