#!/usr/bin/env bash

input_target="${1:-}"

conn=""
remote_path=""

if [ -n "$input_target" ]; then
  if [[ "$input_target" == *":"* ]]; then
    conn="${input_target%%:*}"
    remote_path="${input_target#*:}"
  else
    conn="$input_target"
  fi
fi

host=""
user=""

if [ -n "$conn" ]; then
  if [[ "$conn" == *"@"* ]]; then
    user="${conn%%@*}"
    host="${conn#*@}"
  else
    user="$(whoami)"
    host="$conn"
  fi
fi

if [ -z "$host" ]; then
  host=$(gum input --placeholder "Enter remote host")
  if [ -z "$host" ]; then
    echo "ERROR: Host is required." >&2
    exit 1
  fi
fi

if [ -z "$user" ]; then
  default_user="$(whoami)"
  user=$(gum input --placeholder "Enter remote user (default: $default_user)")
  user="${user:-$default_user}"
fi

if [ -z "$remote_path" ]; then
  remote_path=$(gum input --placeholder "Enter remote path")
  if [ -z "$remote_path" ]; then
    echo "ERROR: Remote path is required." >&2
    exit 1
  fi
fi

leaf="$(basename "$remote_path")"
if [ "$leaf" = "/" ] || [ -z "$leaf" ]; then
  leaf="root"
fi

mount_base="$HOME/mnt"
mount_dir="${mount_base}/${user}@${host}/${leaf}"

if mountpoint -q "$mount_dir" 2>/dev/null; then
  echo "Warning: Something is already mounted at $mount_dir" >&2
  exit 1
fi

echo "Mounting ${user}@${host}:${remote_path} to ${mount_dir}..."

mkdir -p "$mount_dir"

if ! sshfs -C -o idmap=user,uid="$(id -u)",gid="$(id -g)",kernel_cache,reconnect "${user}@${host}:${remote_path}" "$mount_dir"; then
  echo "ERROR: Failed to mount remote directory via SSHFS." >&2
  if [ -d "$mount_dir" ] && ! mountpoint -q "$mount_dir" 2>/dev/null; then
    rmdir "$mount_dir" 2>/dev/null || true
    rmdir "$(dirname "$mount_dir")" 2>/dev/null || true
  fi
  exit 1
fi

echo "Successfully mounted!"
echo "${mount_dir}"
