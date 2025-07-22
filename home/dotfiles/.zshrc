# Load and initialize the completion system
autoload -Uz compinit
compinit

# Enable color support for ls and define the color scheme
if [[ "$TERM" == "xterm-256color" ]]; then
  export CLICOLOR=1
  export LSCOLORS=ExFxCxDxBxegedabagacad
fi

if [ -n "$TMUX" ]; then
    export TERM="screen-256color"
else
    export TERM="xterm-kitty"
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

# Share history across all sessions
setopt share_history
setopt hist_ignore_all_dups
setopt inc_append_history


# Alias for ls with color support
alias ls='ls --color=auto'
alias cat='bat --style=plain --color=always'
alias grep='rga'
#alias x='xclip -selection clipboard'
alias x='wl-copy'
alias k='kubectl'
alias htop='btop'
alias ssh='kitten ssh'
alias vim='nvim'
alias vi='nvim'


# k9s
export K9S_EDITOR=nvim
export EDITOR=nvim
export VISUAL='nvim'
export EDITOR="$VISUAL"

#Fun Sounds
	# THE DEBUGGING VERSION
	# setopt BEEP
  # This creates an empty file and has no dependencies.
  #
# ========================================================
#           CUSTOM SOUND CONFIGURATION (COMPLETE)
# ========================================================

# PART 1: Hijack the Terminal Bell (^G) for tab-completion failures.
# -----------------------------------------------------------------
#my_custom_bell() {
#  bash /home/jake/.config/waybar/scripts/play-random-fail.sh > /dev/null 2>&1 &|
#}
#zle -N my_custom_bell
#bindkey '^G' my_custom_bell
#

# PART 2: Play a sound when any command exits with an error status.
# -----------------------------------------------------------------
autoload -U add-zsh-hook
play_sound_on_error() {
  # Check if the last command's exit code ($?) was not 0 (success).
  if [[ $? -ne 0 ]]; then
    bash /home/jake/.config/waybar/scripts/play-random-fail.sh > /dev/null 2>&1 &|
  fi
}
add-zsh-hook precmd play_sound_on_error
