# shellcheck shell=bash

# Check if the script is being run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

HARD_RESET=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --hard)
      HARD_RESET=true
      shift
      ;;
    -h|--help)
      echo "Usage: network-reset-wireless [--hard]"
      echo "  (default)  Perform a lightweight reset by reloading the iwlwifi driver."
      echo "  --hard     Perform a hard reset by disconnecting/rescanning the PCI device."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: network-reset-wireless [--hard]"
      exit 1
      ;;
  esac
done

if [ "$HARD_RESET" = true ]; then
  PCI_ADDRESS="0000:05:00.0"
  DEVICE_PATH="/sys/bus/pci/devices/$PCI_ADDRESS"

  echo "Performing hard wireless reset..."
  echo "Unloading iwlwifi driver..."
  modprobe -r iwlwifi

  # Give the kernel a second to clear the module.
  sleep 1

  if [ -d "$DEVICE_PATH" ]; then
    echo "Disconnecting PCI device $PCI_ADDRESS..."
    echo 1 >"$DEVICE_PATH/remove"
    sleep 1
  else
    echo "Device $PCI_ADDRESS not found on the bus. It might already be disconnected."
  fi

  echo "Rescanning the PCI bus..."
  echo 1 >/sys/bus/pci/rescan

  sleep 1
else
  echo "Performing lightweight wireless reset..."
  echo "Unloading iwlwifi driver..."
  modprobe -r iwlwifi

  # Give the kernel a second to clear the module.
  sleep 1

  echo "Loading iwlwifi driver..."
  modprobe iwlwifi

  sleep 1
fi

echo "Done! You can run ip link to verify the network interface is present."
