#!/usr/bin/env bash

# Find active sshfs mounts.
mapfile -t sshfs_mounts < <(mount | grep -E "type fuse\.sshfs|sshfs#" | awk '{print $3}' | sort -u)

if [ ${#sshfs_mounts[@]} -eq 0 ]; then
  echo "No active SSHFS mounts found."
  exit 0
fi

target_arg="${1:-}"
target_mount=""

# Filter active mounts by search term if provided (matches all if target_arg is empty)
matches=()
for m in "${sshfs_mounts[@]}"; do
  if [[ "$m" == *"$target_arg"* ]]; then
    matches+=("$m")
  fi
done

if [ ${#matches[@]} -eq 0 ]; then
  echo "ERROR: No active SSHFS mount matching '$target_arg' was found." >&2
  exit 1
else
  target_mount=$(printf "%s\n" "${matches[@]}" | gum filter --placeholder "Select a mount to unmount")
  if [ -z "$target_mount" ]; then
    echo "Cancelled."
    exit 0
  fi
fi

if [ -n "$target_mount" ]; then
  echo "Unmounting ${target_mount}..."

  unmounted=false
  while [ "$unmounted" = false ]; do
    if fusermount3 -u "$target_mount"; then
      unmounted=true
      break
    fi

    echo ""
    echo "Mount is busy. Processes using ${target_mount}:"
    fuser -vm "$target_mount" || true
    echo ""

    action=$(gum choose --header "How would you like to proceed?" \
      "Retry unmount" \
      "Lazy unmount (fusermount3 -uz)" \
      "Kill processes & unmount" \
      "Cancel" || true)

    case "$action" in
      "Retry unmount")
        echo "Retrying unmount of ${target_mount}..."
        ;;
      "Lazy unmount (fusermount3 -uz)")
        echo "Lazy unmounting ${target_mount}..."
        if fusermount3 -uz "$target_mount"; then
          unmounted=true
        else
          echo "ERROR: Failed to lazy unmount $target_mount." >&2
          exit 1
        fi
        ;;
      "Kill processes & unmount")
        echo "Killing processes using ${target_mount}..."
        fuser -km "$target_mount" || true
        sleep 0.5
        if fusermount3 -u "$target_mount" || fusermount3 -uz "$target_mount"; then
          unmounted=true
        else
          echo "ERROR: Failed to unmount $target_mount." >&2
          exit 1
        fi
        ;;
      *)
        echo "Cancelled."
        exit 1
        ;;
    esac
  done

  echo "Successfully unmounted!"

  if [ -d "$target_mount" ]; then
    rmdir "$target_mount" 2>/dev/null || true
    parent_dir="$(dirname "$target_mount")"
    rmdir "$parent_dir" 2>/dev/null || true
  fi
fi
