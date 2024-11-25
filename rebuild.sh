#!/usr/bin/env bash
read -p "Enter a name for this NixOS build: " custom_name
full_name="${custom_name} - $(date '+%Y-%m-%d')"


current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

git add -A 
git commit -m "$current_datetime"
git push

sudo nixos-rebuild switch --flake .#Framework --profile-name $custom_name-$(date +"%b-%d-%Y")
