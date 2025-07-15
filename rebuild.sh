#!/usr/bin/env bash

# Prompt for a custom name for the Git commit
read -p "Enter a name for this NixOS build commit: " custom_commit_name

# Format Nix files
nixpkgs-fmt *.nix

# Stage all changes
git add -A

# Commit changes with the custom name
git commit -m "$custom_commit_name"

# Push changes to the remote repository
git push

# Perform a standard NixOS flake switch
sudo nixos-rebuild switch --flake .#Framework

# Uncomment the line below if you want to run a generation cleaner script
# ./generation-cleaner.sh
