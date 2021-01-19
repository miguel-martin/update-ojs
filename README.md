# OJS update script

Bash script to update Open Journal System software:

- Downloads specified OJS release
- Backups old OJS db and files
- Stops Apache
- Moves new release to htdocs folder
- Copies previous config.inc.php, public/ and plugins/ to new release
- Edits config.inc.php ('installed = On' to 'installed = Off')
- Runs OJS update script
- Ensures correct user:group permission of everything in ojsfolder
- Starts Apache

You might run this as a privileged user (root). Use at your own risk! :)

## Configure
- Customize variables in `updateOjs.sh` (such as `newVersionUrl` or `backupTo` dir). Code is quite self-explanatory.
- Give the script execution permissions `chmod +x updateOjs.sh`

## Run
```./updateOjs.sh```