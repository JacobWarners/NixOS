cd /nix/var/nix/profiles/system-profiles && \
ls -1t | grep -v '\-1-link$' | grep -v '^golden$' | grep -v '^GOLDENIMAGE' | tail -n +2 | while read profile; do
  echo "Removing $profile and its links..."
  sudo rm -rf "$profile" "$profile"-1-link "$profile"-2-link "$profile"-3-link
done

