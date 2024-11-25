#!/usr/bin/env bash

# Set the number of generations to keep
GENERATIONS_TO_KEEP=5

# Path to the system profile
SYSTEM_PROFILE="/nix/var/nix/profiles/system"

# Get a list of all system generations
# Format: generation number   date   time   description
GENERATIONS_LIST=$(sudo nix-env -p "$SYSTEM_PROFILE" --list-generations)

# Check if we got any generations
if [ -z "$GENERATIONS_LIST" ]; then
  echo "No generations found."
  exit 1
fi

# Extract the generation numbers into an array
mapfile -t GENERATION_NUMBERS < <(echo "$GENERATIONS_LIST" | awk '{print $1}')

# Count the total number of generations
TOTAL_GENERATIONS=${#GENERATION_NUMBERS[@]}

# Calculate the number of generations to delete
GENERATIONS_TO_DELETE=$((TOTAL_GENERATIONS - GENERATIONS_TO_KEEP))

if [ "$GENERATIONS_TO_DELETE" -le 0 ]; then
  echo "There are $TOTAL_GENERATIONS generations. No generations to delete."
  exit 0
fi

# Get the list of generations to delete (the oldest ones)
GENERATIONS_TO_DELETE_LIST=("${GENERATION_NUMBERS[@]:0:$GENERATIONS_TO_DELETE}")

echo "Total generations: $TOTAL_GENERATIONS"
echo "Keeping the most recent $GENERATIONS_TO_KEEP generations."
echo "Deleting the following generations: ${GENERATIONS_TO_DELETE_LIST[*]}"

# Confirm deletion
read -p "Are you sure you want to delete these generations? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborting."
  exit 0
fi

# Delete the old generations
sudo nix-env -p "$SYSTEM_PROFILE" --delete-generations "${GENERATIONS_TO_DELETE_LIST[@]}"

# Clean up the Nix store
sudo nix-store --gc

# Remove old entries from the boot loader
sudo nixos-rebuild boot

echo "Old generations deleted and Nix store garbage collected."

