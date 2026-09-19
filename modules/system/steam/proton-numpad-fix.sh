#!/usr/bin/env bash

set -e

# Default Steam paths.
STEAM_COMPAT_DIR="${HOME}/.local/share/Steam/steamapps/compatdata"
AHK_CACHE_DIR="${HOME}/.local/share/ahk"
AHK_ZIP_URL="https://github.com/AutoHotkey/AutoHotkey/releases/download/v1.1.37.02/AutoHotkey_1.1.37.02.zip"
AHK_ZIP_FILE="${AHK_CACHE_DIR}/AutoHotkey.zip"
AHK_EXE="${AHK_CACHE_DIR}/AutoHotkeyU64.exe"

# Payload variables.
AHK_SCRIPT_NAME="numpad_fix.ahk"

if [ -z "$1" ]; then
  echo "Usage: proton-numpad-fix <AppID>"
  echo "Example: proton-numpad-fix 4032769339"
  exit 1
fi

APPID="$1"
PFX_DIR="${STEAM_COMPAT_DIR}/${APPID}/pfx"
DRIVE_C="${PFX_DIR}/drive_c"

if [ ! -d "$PFX_DIR" ]; then
  echo "Error: Proton prefix not found at $PFX_DIR"
  echo "Make sure you have launched the game at least once so Proton creates the prefix."
  exit 1
fi

# Download and extract AutoHotkey if we don't have it.
if [ ! -f "$AHK_EXE" ]; then
  echo "AutoHotkey interpreter not found. Downloading..."
  mkdir -p "$AHK_CACHE_DIR"
  wget -qO "$AHK_ZIP_FILE" "$AHK_ZIP_URL"
  echo "Extracting AutoHotkey..."
  unzip -q -j "$AHK_ZIP_FILE" "AutoHotkeyU64.exe" -d "$AHK_CACHE_DIR"
  rm "$AHK_ZIP_FILE"
fi

# Deploy AHK executable and script to the prefix.
echo "Deploying AutoHotkey and script to drive_c..."
cp "$AHK_EXE" "${DRIVE_C}/AutoHotkeyU64.exe"

cat <<'EOF' >"${DRIVE_C}/${AHK_SCRIPT_NAME}"
; Remap the Shift+Numpad "navigation" events back to Shift+Numbers when NumLock is ON
+NumpadIns::Send {Numpad0}
+NumpadEnd::Send {Numpad1}
+NumpadDown::Send {Numpad2}
+NumpadPgDn::Send {Numpad3}
+NumpadLeft::Send {Numpad4}
+NumpadClear::Send {Numpad5}
+NumpadRight::Send {Numpad6}
+NumpadHome::Send {Numpad7}
+NumpadUp::Send {Numpad8}
+NumpadPgUp::Send {Numpad9}
+NumpadDel::Send {NumpadDot}
EOF

# Create the registry payload.
REG_FILE_PREFIX="${DRIVE_C}/proton_numpad_fix_${APPID}.reg"
echo "Injecting into Windows startup registry..."
cat <<EOF >"$REG_FILE_PREFIX"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run]
"ProtonNumpadFix"="\"C:\\\\AutoHotkeyU64.exe\" \"C:\\\\${AHK_SCRIPT_NAME}\""
EOF

# Apply the registry file via protontricks. Protontricks automatically handles
# finding the right wine/proton runtime.
echo "Applying registry using protontricks..."
protontricks -c "wine regedit /S \"C:\\\\proton_numpad_fix_${APPID}.reg\"" "$APPID"

rm "$REG_FILE_PREFIX"

echo "Success! The Numpad AHK fix has been injected into prefix for AppID $APPID."
echo "It will automatically start in the background the next time you launch the game."
