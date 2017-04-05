@echo off
rem 
rem elysium-wow-cfg.cmd
rem
rem v1.1.0
rem
rem     Configure World of Warcraft Vanilla for use on The Elysium Project
rem                     --- & optionally validate files with MD5 sums ---
rem
rem     by: Fulzamoth
rem

mode con: cols=100 lines=60
set wowEXE_md5=ccf83146dbb3d10ef826aa4de178a5be

rem BS = backspace character. Lets us pretty up prompts with leading spaces
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%A

if not exist .\WoW.exe goto :noWoW
set wowDir=%CD%

cls
echo.
echo.
echo.                    Elysium Project Configurator
echo.                    ----------------------------
echo.
echo.           This script will run through (re-^)configuring your
echo.           Elysium Project WoW install. The following are done:
echo.
echo.              1. Validate your WoW.exe is the right version
echo.              2. Write a new realmlist.wtf
echo.              3. Update WTF\config.wtf
echo.              4. Clears any existing cache files
echo.              5. Turn off compatibility mode (causes disconnects^)
echo.              6. Removes unnecessary EXE files (Optional^)
echo.              7. Creates a shortcut to the game on your desktop (Optional^)
echo.
echo.        
echo.          Press any key to get started...
pause >NUL
:realmMenu
cls
echo.
echo.
echo.                    Elysium Project Configurator
echo.                    ----------------------------        
echo.
echo.           Select the Realm you want to play on. If you haven't 
echo.           created a character yet, any realm will do. You can 
echo.           switch once logged in.
echo.
echo.                      1. Anathema (PvP^)
echo.                      2. Darrowshire (PvE^)
echo.                      3. Elysium (PvP^)
echo.                      4. Zeth'Kur (PvP^)
echo.
echo.
echo.
set /p realm=".%BS%          Enter realm number (1-4): "
if not "%realm%" == "1" if not "%realm%" == "2" if not "%realm%" == "3" if not "%realm%" == "4" goto realmMenu

if "%realm%" == "1" (
    set realmName=Anathema
    goto configStart
)
if "%realm%" == "2" (
    set realmNAme=Darrowshire
    goto configStart
)
if "%realm%" == "3" (
    set realmNAme=Elysium
    goto configStart
) 
if "%realm%" == "4" (
    SET realmName=Zeth'Kur
)
:configStart


echo.
echo.

rem 
rem Check if WoW.exe is valid
rem
echo.
echo.  --------- STEP 1 - Validate your WoW.exe is the right version ---------
echo.
call :GETMD5 .\WoW.exe
echo.       WoW.exe checksum - %md5%
echo.       Correct checksum - %wowEXE_md5%
echo.
if not "%md5%" == "%wowEXE_md5%" goto :badWoWMD5 
echo.       We have a match, so WoW executable checks out. Starting config:
rem 
rem MD5 sum for the WoW executable matches 1.12.1, assume it's valid
rem
echo.
echo.  --------- STEP 2 - Writing realmlist.wtf ------------------------------
echo.
echo. 
echo.       Adding 'set realmlist logon.elysium-project.org' to realmlist.wtf
echo # Elysium Project classic WoW server> realmlist.wtf
echo set realmlist logon.elysium-project.org >> realmlist.wtf
echo.
echo.  --------- STEP 3 - Writing config.wtf ---------------------------------
echo.
echo|set /p=".%BS%       Checking for WTF folder... "
if exist ".\WTF" (
    rem move into the WTF directory to process files
    echo found.
) else (
    rem no WTF directory found, so create one
    echo not found; creating one.
    mkdir WTF
)
cd WTF
echo|set /p=".%BS%       Checking for existing config.wtf file... "
if exist "config.wtf" (
    rem we have an existing config.wtf. Back it up, and remove old 
    rem realmlist and realmname lines
    echo found.
    echo.       - Backing up config.wtf to config.wtf.wowcheck.
    copy config.wtf config.wtf.wowcheck >NUL
    echo.       - Removing existing realmList and realmName entries from config.wtf
    type config.wtf.wowcheck | findstr /v /i realmlist | findstr /v /i realmname >config.wtf
) else (
    echo not found. We'll create an empty one from scratch.
)
echo. 
echo.       Adding 'SET realmList "logon.elysium-project.org"' to config.wtf
echo SET realmList "logon.elysium-project.org" >> config.wtf
echo.       Adding 'SET realmName "%realmName%"' to config.wtf
echo SET realmName "%realmName%" >> config.wtf
echo.
echo.  --------- STEP 4 - clear existing WDB cache ---------------------------
echo.
cd "%wowDir%"
if exist .\WDB (
    echo.       Clearing old cache (WDB folder^).
    del /q .\WDB\*.* >NUL 
	echo.       - done.
)
echo.
echo.  --------- STEP 5 - turn off compatability mode ------------------------
echo.
echo.       Compatability mode is not necessary for World of Warcraft, and
echo.       has been found to cause disconnect problems shortly after logging
echo.       in for some users.
echo.
echo.       We'll disable it just to be sure.
echo.
echo.       Deleting registry key:
echo.
echo.           "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
echo.                         -^>"%wowDir%\WoW.exe"
cd "%wowDir%"
reg.exe DELETE "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%wowDir%\WoW.exe"
)
echo.

echo.
echo.  --------- STEP 6 - Remove unnecessary EXE files -----------------------
echo.
echo.
echo.       The WoW application comes with some executables that are not 
echo.       applicable when playing Vanilla WoW. These are:
echo.
echo.         - Launcher.exe - Launch wrapper for WoW that triggered 
echo.                          updates and displayed news
echo.         - BackgroundDownloader.exe - downloaded patches
echo.         - Repair.exe - repaired WoW installs, only works with retail
echo.
echo.       We can safely delete these without affecting the game. Doing
echo.       so prevents accidentally trying to update your install
echo.       (something we don't want for Vanilla/Classic gaming).
echo.
set YN=
set /p YN="        Do you want to delete the unnecessary executable files? (Y/N) "
if /i "%YN%" == "Y" (
    cd "%wowDir%"
    echo.
    echo        Deleting Launcher.exe
    del Launcher.exe 1>NUL 2>&1
    echo        Deleting BackgroundDownloader.exe
    del BackgroundDownloader.exe 1>NUL 2>&1
    echo        Deleting Repair.exe
    del Repair.exe 1>NUL 2>&1
)
echo.
echo.
echo.  --------- STEP 7 - Create shortcut on desktop -------------------------
echo.

echo.
set YN=
set /p YN="       Do you want a shortcut to Elysium Project WoW on your desktop? (Y/N) "
if /i "%YN%" == "Y" (
    call :createShortcut
)
echo.
echo.       Configuration complete.
echo.
echo.
echo.  --------- STEP 8 - Check MD5 hashes of data files ---------------------
echo.
echo.       If the game is booting you out regularly, it can be caused by
echo.       anti-cheat mechanisms detecting something wrong with your data 
echo.       files. This routine will check the MD5 hashes of the game data
echo.       files against known good versions to validate that your install
echo.       should work. 
echo.
echo.       Any incorrect hashes will be highlighted for you. If there are any
echo.       download the game again from the links on the Elysium Project 
echo.       homepage.
echo.

set YN=
set /p YN=".%BS%       Do you want to check MD5 hashes of the Warcraft data files? (Y/N) "
if /i "%YN%" == "Y" (
    echo.
    call :checkFiles
)

echo.
echo.       We're done. Press any key to close window.
pause >NUL

exit /b

rem
rem End of main script
rem
rem -------------------------------------------------------------------------------

:badWoWMD5
    rem
    rem Mismatch of the MD5 sum for WoW.exe
    rem
    echo.
    echo.        This doesn't look like the correct WoW.exe. 
    echo.
    echo.        Check that the script is running in the correct directory. 
    echo.        If you think it is, re-download the client from the Elysium
    echo.        Project at:
	echo.   
	echo.              https://elysium-project.org/play
    echo.
	echo.
	echo.        Press any key to close window.
	pause >NUL
    exit /b

:getMD5 %1
    rem
    rem Calculate the MD5sum of a the file stored in the %1 variable.
    rem Returns the MD5sum in %md5%
    rem
    echo.       Calculating MD5 sum on : %1
    setlocal enabledelayedexpansion
    set /a count=1 
    for /f "skip=1 delims=:" %%a in ('CertUtil -hashfile "%1" MD5') do (
        if !count! equ 1 set "md5=%%a"
        set/a count+=1
    )
    set "md5=%md5: =%
    endlocal & set "md5=%md5%"
    exit /b

:createShortcut
    rem
    rem Creates a shortcut to WoW on the user's desktop
    rem
    powershell -command "$Shell = New-Object -ComObject WScript.Shell;$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + '\Desktop\Elysium Project WoW.lnk');$Shortcut.TargetPath = \"$pwd\WoW.exe\";$Shortcut.Save()"
    exit /b

:checkFiles
    rem
    rem Checks files for correct MD5 sums
    rem
    rem Hashes should not be changed unless a new version of WoW is used.
    rem
    set files[0]=.\Data\backup.MPQ
    set hashes[0]=3989c9f81bda2be0f4f5e49eaf416d33

    set files[1]=.\Data\base.MPQ
    set hashes[1]=8cedafa446307b8df5544b85ffbd4860

    set files[2]=.\Data\dbc.MPQ
    set hashes[2]=99b0ae4128aff22ae18e4e379c5347ea

    set files[3]=.\Data\fonts.MPQ
    set hashes[3]=4da3882b701fe26431608be8b7597950

    set files[4]=.\Data\interface.MPQ
    set hashes[4]=e782c58cb2b0636b7b3a4094e5ae7630

    set files[5]=.\Data\misc.MPQ
    set hashes[5]=59b877b06aa4c55f3ef2ff94963c78c5

    set files[6]=.\Data\model.MPQ
    set hashes[6]=7d2f6c4917ffbf0b68660cb4a4da362e

    set files[7]=.\Data\patch.MPQ
    set hashes[7]=2fb2f11a13c324526f85db131fb0fef3

    set files[8]=.\Data\patch-2.MPQ
    set hashes[8]=5eb98bea600745f180ffd5b2ed6bc42c

    set files[9]=.\Data\sound.MPQ
    set hashes[9]=ee54af436a227e98cf16f13f2c89822f

    set files[10]=.\Data\speech.MPQ
    set hashes[10]=bb231c882f690799481c24f746c08c2a

    set files[11]=.\Data\terrain.MPQ
    set hashes[11]=8470fb09822b9b574af455ab76de4889

    set files[12]=.\Data\texture.MPQ
    set hashes[12]=96f005cda6296bfa424da4e34e1aef4f

    set files[13]=.\Data\wmo.MPQ
    set hashes[13]=8c71138ce80635f7064f70a6a5c6d89e
 
    set lasthash=13

    setlocal enabledelayedexpansion
    for /l %%x in (0,1,!lasthash!) do (
        set file=!files[%%x]!
        set hash=!hashes[%%x]!
        call :getMD5 !file! 
        echo|set /p=".%BS%       Installed MD5: !md5!"
        if "!md5!" == "!hash!" (
             echo. --- CORRECT 
        ) else ( 
             echo. --- RUH ROH! hashes don't MATCH
             echo.       Correct MD5:   !hash!
        )
        echo.
    )
    endlocal
    exit /b

:noWoW
    rem
    rem Tells user to go find WoW
    rem
    cls
    echo.
    echo.       No WoW.exe found!
    echo.
    echo.       Be sure to run this script from inside your World of Warcraft directory.
    echo.       (Where you extracted the game files to. It contains WoW.exe, Interface, 
    echo.       Data, etc.)
    echo.
    echo.        Press any key to close window...
    pause >NUL
    exit /b

