# sd-copy
Shell Script to automatically mount, copy the contents to a specific directory and unmount a SD-Card. 
It does so by selecting the largest partition on `/dev/mmcblk0`.

## How to use this

1. Copy sd-copy.service to `/etc/systemd/system/`
2. Copy sd-copy.sh wherever you like. I prefer `/root/scripts/`
3. Edit the Mount & Output Folder Path to your preference. As well as set the correct /dev/mmcblkX Number
4. Make the script executable `sudo chmod +x /root/scripts/sd-copy.sh`
5. Reload the systemd manager configuration to read the new service file `sudo systemctl daemon-reload`
6. Enable the service to start on boot `sudo systemctl enable myscript.service`
7. Start the service `sudo systemctl start sd-copy.service`
8. Before inserting a SD-Card make sure the mount folder exists

You can check the status with this command: `sudo systemctl status sd-copy.service`

## Tip
Install `progress`. You can monitor all current transfers by using the command `progress -M`