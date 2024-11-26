#!/usr/bin/env bash

# Number of profiles to keep
PROFILES_TO_KEEP=5

# Path to system profiles directory
SYSTEM_PROFILES_DIR="/nix/var/nix/profiles/system-profiles"

# Profile to keep forever
PROFILE_TO_KEEP="Fully-Functional-0-Nov-25-2024"

# Get the currently active system profile
CURRENT_PROFILE=$(readlink -f /nix/var/nix/profiles/system)
CURRENT_PROFILE_BASENAME=$(basename "$CURRENT_PROFILE")

# Get the list of all profiles with their modification time, sorted by oldest first
mapfile -t PROFILES < <(find "$SYSTEM_PROFILES_DIR" -maxdepth 1 -type l -printf "%T@ %p\n" | sort -n | awk '{print $2}')

# Initialize array for profiles to delete
PROFILES_TO_DELETE=()

# Total number of profiles
TOTAL_PROFILES=${#PROFILES[@]}

# Calculate the number of profiles to delete
PROFILES_TO_DELETE_COUNT=$((TOTAL_PROFILES - PROFILES_TO_KEEP))

if [ "$PROFILES_TO_DELETE_COUNT" -le 0 ]; then
  echo "There are $TOTAL_PROFILES profiles. No profiles to delete."
  exit 0
fi

# Loop through profiles to identify which ones to delete
for (( i=0; i<${#PROFILES[@]}; i++ )); do
  PROFILE_PATH="${PROFILES[$i]}"
  PROFILE_NAME=$(basename "$PROFILE_PATH")

  # Skip the currently active profile
  if [[ "$PROFILE_NAME" == "$CURRENT_PROFILE_BASENAME" ]]; then
    continue
  fi

  # Skip the profile to keep forever
  if [[ "$PROFILE_NAME" == "$PROFILE_TO_KEEP" ]]; then
    continue
  fi

  # Add to deletion list if we haven't reached the limit
  if [ "${#PROFILES_TO_DELETE[@]}" -lt "$PROFILES_TO_DELETE_COUNT" ]; then
    PROFILES_TO_DELETE+=("$PROFILE_NAME")
  else
    # We have collected enough profiles to delete
    break
  fi
done

if [[ ${#PROFILES_TO_DELETE[@]} -eq 0 ]]; then
  echo "No profiles to delete."
  exit 0
fi

echo "Total profiles: $TOTAL_PROFILES"
echo "Keeping the most recent $PROFILES_TO_KEEP profiles."
echo "Deleting the following profiles:"
for PROFILE in "${PROFILES_TO_DELETE[@]}"; do
  echo "- $PROFILE"
done

# Confirm deletion
read -p "Are you sure you want to delete these profiles? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborting."
  exit 0
fi

# Delete the old profiles
for PROFILE in "${PROFILES_TO_DELETE[@]}"; do
  PROFILE_PATH="$SYSTEM_PROFILES_DIR/$PROFILE"
  echo "Deleting profile: $PROFILE_PATH"
  sudo rm -rf "$PROFILE_PATH"
done

# Garbage collect
sudo nix-store --gc

echo "Old profiles deleted and Nix store garbage collected."

