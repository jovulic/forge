# shellcheck shell=bash

# Check if the script is being run as root.
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

PCI_ADDRESS="0000:05:00.0"
DEVICE_PATH="/sys/bus/pci/devices/$PCI_ADDRESS"

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

echo "Done! You can run ip link to verify the network interface is present."
