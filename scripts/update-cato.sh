#!/usr/bin/env bash
# Updates the Cato client version in modules/cato.nix to the latest from Cato's CDN.
# Usage: ./scripts/update-cato.sh

set -euo pipefail

CATO_NIX="$(dirname "$0")/../modules/cato.nix"

if [[ ! -f "$CATO_NIX" ]]; then
  echo "Error: $CATO_NIX not found" >&2
  exit 1
fi

echo "Checking latest Cato client version..."

# Cato's download page redirects to the latest versioned URL
REDIRECT_URL=$(curl -sI "https://clientdownload.catonetworks.com/public/clients/cato-client-install.deb" \
  | grep -i '^location:' \
  | tr -d '\r' \
  | awk '{print $2}')

if [[ -z "$REDIRECT_URL" ]]; then
  echo "Error: Could not determine latest version from Cato CDN" >&2
  exit 1
fi

NEW_VERSION=$(echo "$REDIRECT_URL" | grep -oP '/(\d+\.\d+\.\d+\.\d+)/' | tr -d '/')

if [[ -z "$NEW_VERSION" ]]; then
  echo "Error: Could not parse version from redirect URL: $REDIRECT_URL" >&2
  exit 1
fi

CURRENT_VERSION=$(grep -oP 'version = "\K[^"]+' "$CATO_NIX")

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
  echo "Already on latest version: $CURRENT_VERSION"
  exit 0
fi

echo "Updating: $CURRENT_VERSION -> $NEW_VERSION"

# Prefetch the new deb and get the SRI hash
NEW_HASH=$(nix-prefetch-url "https://clients.catonetworks.com/linux/${NEW_VERSION}/cato-client-install.deb" 2>/dev/null \
  | xargs nix hash convert --to sri --type sha256 --hash-algo sha256)

if [[ -z "$NEW_HASH" ]]; then
  echo "Error: Failed to prefetch new version" >&2
  exit 1
fi

# Update version and hash in cato.nix
sed -i "s|version = \"$CURRENT_VERSION\"|version = \"$NEW_VERSION\"|" "$CATO_NIX"
sed -i "s|sha256 = \"[^\"]*\"|sha256 = \"$NEW_HASH\"|" "$CATO_NIX"

echo "Updated modules/cato.nix:"
echo "  version: $NEW_VERSION"
echo "  sha256:  $NEW_HASH"
echo ""
echo "Run: sudo nixos-rebuild switch --flake /home/jake/nixos-config#Framework"
