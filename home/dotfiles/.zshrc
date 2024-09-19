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
alias cat='bat --style=plain --color=always'
