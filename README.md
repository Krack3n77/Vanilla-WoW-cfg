# Vanilla WoW Configuration Script

Configuration script for use with:

- The Elysium Project
- Light's Hope

## What does it do?
The script does the following:
* Validates your WoW.exe is the right version (MD5 hash check)
* Writes a new `realmlist.wtf`
* Updates `WTF\config.wtf`
* Clears any existing cache files
* Turns off compatibility mode (causes disconnects)
* Removes unnecessary EXE files (Optional)
* Creates a shortcut to the game on your desktop (Optional)
* Checks the MD5 hashes of game data files (Optional)

## How do I use it?
1. Download the ZIP file from the repository Releases page (link at top of post).
2. Extract the ZIP file.
3. Copy the extracted *Vanilla-WoW-cfg.cmd* file to your Vanilla World of Warcraft directory.
4. In your World of Warcraft directory, double click *Vanilla-WoW-cfg.cmd* to run the script.

The script will prompt you:
* for the server you're going to play on
* for which realm you want configured
* for permission to delete registry key that enables compatability mode (say Yes to this)
* whether you want unnecessary executables disabled (to avoid firing up retail only EXEs by accident)
* to setup a shortcut to Elysium Project WoW on your desktop
* whether to run MD5 hash checks

**NOTE:** The script may be sandboxed by some AV/Firewall applications, in which case changes made will be lost. If this is the case on your machine open a command prompt (shift--right-click on your WoW folder in Explorer, and select Open command window here), and run Elysium-WoW-cfg.cmd from the command line. 
