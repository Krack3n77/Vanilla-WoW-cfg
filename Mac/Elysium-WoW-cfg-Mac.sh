#!/bin/bash
#
# Elysium-WoW-cfg-Mac.sh
#
#    Configure World of Warcraft Vanilla for use on The Elysium Project
#             --- & optionally validate files with MD5 sums ---
#
#     by: Fulzamoth
#


readonly siteName="** Elysium Project **"
readonly siteCaption="World of Warcraft (Classic/Vanilla)"
readonly scriptDesc="Install/Repair/Maintain Tool"
readonly menuWidth=80 # number of columns to format for
# this is a list of valid realms. MUST be kept current, or else it'll give the user errors.
readonly REALMS=("Anathema" "Darrowshire" "Elysium" "Zeth'Kur")


# Constants that shouldn't need to change unless Elysium Project makes major changes:
readonly WOW_VERSION="1.12.1"							# Current version of WoW supported
readonly WOWEXEC_MD5="018ed0fd479cae508669259736874379"	# MD5 hash of "World of Warcraft" executable

readonly REALMCMT="# Elysium Project World of Warcraft (Vanilla)"
readonly REALMLIST="logon.elysium-project.org"

#
# Standard color escapes
#

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly LIGHTGRAY='\033[0;37m'
readonly DARKGRAY='\033[1;30m'
readonly LIGHTRED='\033[1;31m'
readonly LIGHTGREEN='\033[1;32m'
readonly LIGHTYELLOW='\033[1;33m'
readonly LIGHTBLUE='\033[1;34m'
readonly LIGHTPURPLE='\033[1;35m'
readonly LIGHTCYAN='\033[1;36m'
readonly WHITE='\033[1;37m'
readonly NOCOLOR='\033[0m'

checkWoWDir() {
	#
	# A simple check to ensure we're in the right directory. Some things, like fixing file permissions
	# could be destructive if run in the wrong place.
	#
	# Uses the global $wowApp to avoid having to pass the name around excessively
	#
	# return 0 if we're in the right place, exits the script otherwise.
	#
	cd "${wowDir}"
	if [[ -d "$wowApp" ]]; then
		return 0
	else
		redError "we're in the wrong directory, and bad things can happen if changes are made here.\n\n"
		printf "This script needs to be run from within the World of Warcraft install directory.\n"
		printf "I see WoW installed in '${LIGHTGREEN}$(guessWoWDir "$wowApp")${NOCOLOR}'. Try rerunning from there."
		exit 1
	fi
}

fixWoWFilePerms() {
    find . -type d -exec chmod 0755 {} \;
	find . -type f -exec chmod -x {} \;
    find . -path "*/MacOS/*" -type f -name "World of Warcraft" -exec chmod +x {} \;
}

printMenu() {
	#
	# Prints a standard menu header
	#
	clear
	printf "\n\n"
	local menuHalf=$(( $menuWidth/2 ))
	local offset=$(( $menuHalf - ${#siteName}/2 ))
	printf '%*s' ${offset} 
	printf "${LIGHTBLUE}$siteName${NOCOLOR}\n\n"
	offset=$(( $menuHalf - ${#siteCaption}/2 ))
	printf '%*s' ${offset} 
	printf "${GREEN}${siteCaption}${NOCOLOR}\n"
	offset=$(( $menuHalf - ${#scriptDesc}/2 ))
	printf '%*s' ${offset} 
	printf "${GREEN}${scriptDesc}${NOCOLOR}\n\n"
	offset=$(( $menuHalf - ${#menuName}/2 ))
	printf '%*s' ${offset} 
	printf "$menuName\n"
	if [[ "${#siteName}" -gt "${#siteCaption}" ]] ; then
		lineLength=${#siteName}
	elif [[ "${#siteCaption}" -gt "${#menuName}" ]] ; then
		lineLength=${#siteCaption}
	else
		lineLength=${#menuName}
	fi
	offset=$(( $menuHalf - ${lineLength}/2 ))
	printf '%*s' ${offset} 
	line=$(printf '%*s' ${lineLength})
	echo "${line// /-}"
	echo
	local max=0
	for menuItem in "${menuOptions[@]}" ; do
		menuItem="${menuItem/\\033\[*m/}"
		if [[ "${#menuItem}" -gt "$max" ]] ; then
			max="${#menuItem}"
		fi
	done
	offset=$(( $menuHalf - ${max}/2 ))
	for menuItem in "${menuOptions[@]}" ; do
		printf '%*s' ${offset} 
		printf "$menuItem\n"
 	done
	echo
	echo
	offset=$(( $menuHalf - ${#menuPrompt}/2 ))
	printf '\r'
	printf '%*s' ${offset} 
	printf "$menuPrompt  \033[1D"

}
	
mainMenu() {
	menuName="Main Menu"	
	menuOptions=( 
		"1. Configure new install"
		"2. Fix (most) disconnect errors" 
		"3. Test connectivity"
		"4. Maintance menu"
	)
	menuPrompt="Select option from list above or 'q':"
	while true ; do
		printMenu
		read -n 1 choice

		case $choice in
			1) configNewInstall ;;
			2) fixDisconnectErrors ;;
			3)  ;;
			4) maintenanceMenu ;;
			q) break;;
		esac
	done
	echo " - $realm selected."
	printf "$realm"
}

maintenanceMenu() {
	menuName="Maintainance Menu"
	menuOptions=( 
		"1. Repair permissions" 
		"2. Rebuild ${CYAN}${wowApp}${NOCOLOR}"
		"3. Validate files (Check MD5 checksums)"
		"4. Rewrite realmList configuration"
		"5. Clear WDB cache"
		"6. Reset Chat window configs"
		)
	menuPrompt="Select option from list above or 'q': "
	while true ; do
		printMenu
		read -n 1 choice
		echo
		case $choice in
			1) x	repairPermissions ;;
			2) rebuildWoWApp ;;
			3) validateHashes ;;
			4) rewriteRealmlist ;;
			5) clearCache ;;
			6) resetChatWindows ;;
			q) break;;
		esac
	done
}
userGetRealm() {
	menuName="Realm Selection"
	menuOptions=()
	local x=1
	for realm in "${REALMS[@]}"; do
		menuOptions+=($(printf '%2s. %s' "$x" "$realm"))
		x=$(( $x + 1 ))
	done
	menuPrompt="Enter the realm you want to play on:"
	while true ; do
		printMenu
		read -n 1 realmChoice

		case $realmChoice in
			1) realm="Anathema" ;;
			2) realm="Darrowshire" ;;
			3) realm="Elysium" ;;
			4) realm="Zeth'Kur" ;;
		esac
	done
	echo " - $realm selected."
	printf "$realm"
}

resetChatWindows() {
	toonMenu
	read -p "Account: $chosenAccount"
}

toonMenu() {
	#
	# Generates a menu with a list of toons from the WTF folder
	#
	local accountList=()
	while IFS=  read -r -d $'\0'; do
    	accountList+=("$REPLY")
	done < <(find ./WTF/Account ! -path '*/SavedVariables/*' -type d -mindepth 3 -maxdepth 3 -print0)

	local headingAccount="Account"
	local headingRealm="Realm"
	local headingToon="Character"
	
	local cwAccount=${#headingAccount}		# sets minimum column widths
	local cwRealm=${#headingRealm}			#
	local cwToon=${#headingCharacter}		#

	local accounts=()
	local realms=()
	local toons=()

	local x=0
	for accountLine in "${accountList[@]}"; do
		accountLine="${accountLine#./WTF/Account/}"
		account="${accountLine%%/*}"
		toon="${accountLine##*/}"
		realm="${accountLine%/*}"
		realm="${realm#*/}"
		if [[ "${#realm}" -gt "$cwRealm" ]] ; then
			cwRealm="${#realm}"
		fi
		if [[ "${#account}" -gt "$cwAccount" ]]; then
			cwAccount="${#account}"
		fi
		if [[ "${#toon}" -gt "$cwToon" ]]; then
			cwToon="${#toon}"
		fi				
		toons[$x]="$toon"
		accounts[$x]="$account"
		realms[$x]="$realm"
		x=$(($x + 1))
	done
	local i=0
	menuOptions=()
	while [[ "$i" -lt "$x" ]]; do	
		menuOptions[$i]=$(printf "%2d)   %-${cwAccount}s   %-${cwRealm}s   %-${cwToon}s" "$i" "${accounts[$i]}" "${realms[$i]}" "${toons[$i]}")
		i=$(($i + 1))
	done
	menuName=$(printf "      %-${cwAccount}s   %-${cwRealm}s   %-${cwToon}s" "Account" "Realm" "Character")
	menuPrompt="Select option from list above or 'q':"

	# Display menu
	chosenAccount=""
	while [[ "$chosenAccount" == "" ]] ; do
		printMenu
		read choice
		echo
		case $choice in
			[0-9]*)	if [[ ! -z "${accountList[$choice]}" ]] ; then
						chosenAccount="${accountList[$choice]}"
					fi
					;;
			q) break ;;
		esac
	done

	
}
	

validateHashes() {
	#
	# checks all distribution files against hashes from a known working install
	#
	#
	# MD5 hashes of WoW files

	# ./Data 
	local files[0]='./Data/backup.MPQ'
	local hashes[0]='68db292d79151076046e1851a7974405'
	files[1]="./Data/base.MPQ"
	hashes[1]='281db155fc2671bfec9d59b80c4fc115'
	files[2]="./Data/dbc.MPQ"
	hashes[2]='6573bbd7f29c68724cc00aeefd1daa0d'
	files[3]="./Data/fonts.MPQ"
	hashes[3]='3e0390c70ec88ef961562cbb4d33046b'
	files[4]="./Data/interface.MPQ"
	hashes[4]='6054af22a2314d0fca8dd0a3cc087f89'
	files[5]="./Data/misc.MPQ"
	hashes[5]='144638046316a506160485f562d5240a'
	files[6]="./Data/model.MPQ"
	hashes[6]='81dfd7ff9ad6d1ca7bf9a065480fd6b7'
	files[7]="./Data/patch-2.MPQ"
	hashes[7]='c3ded7272f9a37d25605c8330abbe55e'
	files[8]="./Data/patch.MPQ"
	hashes[8]='d9eb36170ec680757baa1d100f9d0c52'
	files[9]="./Data/sound.MPQ"
	hashes[9]='4405e85224816854dd4171f8d98e82c8'
	files[10]="./Data/speech.MPQ"
	hashes[10]='043ca457dd4ef4194e04678e5f448a8f'
	files[11]="./Data/terrain.MPQ"
	hashes[11]='ca2064c4272a726cecdb75b426f437a5'
	files[12]="./Data/texture.MPQ"
	hashes[12]='bc92d7e0e3258da459f3310782b9d1b1'
	files[13]="./Data/wmo.MPQ"
	hashes[13]='118fd5bf991c01e147564cd7df31fa07'
	# .app files
	files[14]="./${wowApp}/Contents/Info.plist"
	hashes[14]='4b94a46d26a39d6296eecece888e9a79'
	files[15]="./${wowApp}/Contents/MacOS/World of Warcraft"
	hashes[15]='018ed0fd479cae508669259736874379'
	files[16]="./${wowApp}/Contents/PkgInfo"
	hashes[16]='d61ad07e3e6043f59d833a233f16a7a8'
	files[17]="./${wowApp}/Contents/Resources/mpq.icns"
	hashes[17]='32feb28b780577e86bda4564779cc0ea'
	files[18]="./${wowApp}/Contents/Resources/wow.icns"
	hashes[18]='5444e69fdedc790f44d2795b3f9ad834'
	# non essential app files

	filesNonEssential=19  # set this lowest non-essential file in array
	files[19]="./${wowApp}/Contents/Resources/DivX Gaming.component/Contents/PkgInfo"
	hashes[19]='e63de08e92f179c8343c474052a9b552'
	files[20]="./${wowApp}/Contents/Resources/DivX Gaming.component/Contents/Resources/DivX Gaming.rsrc"
	hashes[20]='e2ddbd8aca8b78ab7941ce3a1880e0ea'
	files[21]="./${wowApp}/Contents/Resources/DivX Gaming.component/Contents/Info.plist"
	hashes[21]='0370ec1491420872cf4f49e80b12e955'
	files[22]="./${wowApp}/Contents/Resources/DivX Gaming.component/Contents/MacOS/DivX Gaming"
	hashes[22]='87f3fc9b941774d2ab890b2a4d75fe72'
	files[23]="./${wowApp}/Contents/Resources/Main.nib/classes.nib"
	hashes[23]='d4f654c0244466c22e6192e76ec71210'
	files[24]="./${wowApp}/Contents/Resources/Main.nib/info.nib"
	hashes[24]='58d6221c2411227d836c46360ddfa496'
	files[25]="./${wowApp}/Contents/Resources/Main.nib/objects.xib"
	hashes[25]='e0ffe160ce85c7e5982c68240a13047b'


	checkWoWDir
	echo
	local x=0
	local errval=0
	printf "Checking hashes...\n"
	for file in "${files[@]}" ; do
		if [[ -e "$file" ]]; then
				
			printf "Checking ${CYAN}$file${NOCOLOR}..."
			hash=$(md5 -q "$file")
			if [[ "$hash" == "${hashes[$x]}" ]] ; then
				printf "hash matches.\n"
			else
				if [[ "$x" -lt "19" ]] ; then
					printf "${RED}ERROR - hash mismatch.${NOCOLOR}\n"
					errval=1
				else
					printf "${YELLOW}ERROR - hash mismatch.${NOCOLOR}\n"
					errval=$(( $errval == 1 ? 1 : 2 ))
				fi
				printf "hash is:      ${PURPLE}$hash${NOCOLOR}\n"
				printf "is should be: ${PURPLE}${hashes[$x]}${NOCOLOR}\n"
			fi
		else
			if [[ "$x" -lt "19" && "$rebuiltAlready" == "0" ]] ; then
				redError "missing ${CYAN}$file${NOCOLOR} - run a Rebuild (Maintenance Menu) first.\n"
			elif [[ "$x" -lt "19" && "$rebuiltAlready" == "0" ]] ; then
				redError "missing ${CYAN}$file${NOCOLOR} - you'll need to find a copy of it. Exiting.\n"
				exit 1
			else
				yellowError "missing ${CYAN}$file${NOCOLOR} - game may still run. You can try running a Rebuild to fix.\n"
			fi
		fi
		x=$(($x+1))
	done
	read -p "Press any key to continue..."
	return $errval
		
}

getWoWAppName() {
	#
	# sets WoW app name and path of "World of Warcraft" executable
	#
	local wowExecs=()
	while IFS=  read -r -d $'\0'; do
    	wowExecs+=("$REPLY")
	done < <(find . -path "*/MacOS/*" -type f -name "World of Warcraft" -print0)  # This filename we know for sure.
	if [[ "${#wowExecs[@]}" -ne "1" ]] ; then
		printf "\n${RED}FATAL ERROR${NOCOLOR} - more than one WoW application found in this directory:\n\n"
		for appDir in "${wowExecs[@]}" ; do
			local appName="${appDir%.app/*}.app"
			appName=${appName##*/}
			printf "    ${CYAN}$appName${NOCOLOR}\n"
		done
		printf "\nThere should only be one application.\n\n"
		exit 1
	fi
	local appName="${wowExecs[0]%.app/*}.app"
	appName=${appName##*/}
	wowApp="$appName"
}

guessWoWDir() {
	#
	# Returns our best guess of the WoW install directory based on app name provided. 
	#  - should only be used to inform the user, not take action.
	#
	local wowApp=$1
	local appDir=$(find . -type d -name "$wowApp")
	appDir=${appDir%/*}
	printf "$appDir"
}

getWoWVersion() {
	#
    # returns version number of WoW install from Info.plist
	#
	local wowApp="$1"
	local wowVersion=$(plutil -p "${wowApp}/Contents/Info.plist" | grep 'CFBundleShortVersionString.*')
	wowVersion=${wowVersion%\"*}
	wowVersion=${wowVersion##*\"}
	printf "$wowVersion"
}

getMD5() {
	#
	# Returns the MD5 hash of a file
	#
	printf $(md5 -q "$1")
}

setRealmListWtf() {
	#
	# Configures the realmlist.wtf 
	#
	local errval=0
	if checkWoWDir ; then
		echo $REALMCMT > realmlist.wtf
		echo "set realmlist $REALMLIST" >> realmlist.wtf
	else
		redError "wrong directory for realmlist.wtf file."
		errval=1
	fi
	return $errval
} 
	
setConfigWtf() {
	#
	# Configures the config.wtf file:
	#  1. writes SET realmList line
	#  2. if realmName is passed, writes SET realmName line
	#
	local errval=0
	local realmName=$1
	if [[ -d ./WTF ]]; then
		if [[ -e "./WTF/config.wtf" ]]; then
			cp "./WTF/config.wtf" "./WTF/config.wtf.ewc"
			if [[ "$?" != "0" ]] ; then
				redError "can't make a backup of config.wtf."
				errval=1
			fi
			grep -v -i -e "^set realmlist" -e "^set realmname" "./WTF/config.wtf.ewc" > "./WTF/config.wtf"
		fi
	else
		mkdir WTF
		if [[ "$?" != "0" ]] ; then
			redError "can't create WTF folder."
			errval=1
		fi
	fi		
	if [[ "$errval" == "1" ]] ; then
		printf "It's probably a permissions issue. Fix from Maintenance Menu.\n"
	else
		echo "SET realmList \"$REALMLIST\"" >> "./WTF/Config.wtf"
		if [[ "$realmName" != "" ]] ; then
			echo "SET realName \"$realmName\"" >> "./WTF/Config.wtf"
		fi
	fi
	return $errval
}

getCurrentRealm() {
	#
	# Returns the currently configured realmName
	#
	local realmName=$(grep -i -e '^set realmname' WTF/config.wtf)
	realmName=${realmName%\"*}
	realmName=${realmName#*\"}
	printf "$realmName"
}


listRealms() {
	#
	# Displays a list of valid realms to user
	#
	echo 
}

checkConfig() {
	#
	# Validates that current configuration should work.
	# Rather than simply overwriting, let's highlight any problems. Call writeConfig() to fix errors
	#
	# returns: 0 = valid config
	#          1 = fatal error (game won't run)
	#          2 = minor error (game should correct itself)
    #
	local errval=0
	local realmlist=$(lower "set realmlist $REALMLIST")
	if [[ ! -e realmlist.wtf ]]; then
		redError "missing realmlist.wtf\n\n"
		errval=1
	else  
		local realmlist_wtf=$(grep -i -e '^set realmlist' realmlist.wtf | tr -d '\r')
		realmlist_wtf=$(lower "$realmlist_wtf")
		if [[ "$realmlist" != "$realmlist_wtf" ]] ; then
			redError "misconfigured realmlist.wtf\n\n" 
			printf "realmlist.wtf contains: ${CYAN}$realmlist_wtf${NOCOLOR}\n" 
			printf "It should contain:      ${CYAN}$realmlist${NOCOLOR}\n" 
			errval=1
		fi
	fi
	if [[ ! -d ./WTF ]]; then
		yellowError "missing WTF directory. This is normal on new installs, or
					if you've erased it as part of your troubleshooting.\n "
		errval=1
	elif [[ ! -e ./WTF/config.wtf ]] ; then
		yellowError "missing config.wtf. This is normal on new installs, or
					if you've erased it as part of your troubleshooting.\n "
		errval=$(( $errval == 1 ? 1 : 2 ))
	else	# check contents of config.wtf file	
		realmlist=$(lower "set realmlist \"$REALMLIST\"")
		local realmlist_cfgwtf=$(grep -i -e '^set realmlist' WTF/config.wtf | tr -d '\r')
#		realmlist_cfgwtf=$(lower "$realmlist_wtf")
		if [[ "$realmlist" != "$(lower "$realmlist_cfgwtf")" ]] ; then 
			redError "realmlist line, '$realmlist_cfgwtf' in config.wtf is invalid.\n"
			errval=1
		fi
		local userRealm=$(getCurrentRealm)
		if [[ "$userRealm" == "" ]] ; then
			yellowError "no realm configured in config.wtf."
			errval=$(( "$errval" == "1" ? 1 : 2 ))
		fi
		if [[ "${REALMS[@]/$userRealm/}" == "$REALMS" ]] ; then	# check if realm is in list of realms defined at top
			redError "your currently configured realm, '$userRealm', is invalid.\n" 
			printf "Valid realms are:\n"
			printf '     %s\n' "${REALMS[@]}"
			errval=1
		fi
	fi
	return $errval
}

isArrayMember() {
	#
	# checks if string is member of an array
	#
	#	$1 = string
	#	$2 = array 
	#
	local string="$1"
	local array="${2}[@]"
	if [[ "${!array[@]/$string/}" == "${!array}" ]] ; then	# remove string and see if array still matches itself
		# String is not a member
		return 1
	else
		# String is a member
		return 0
	fi
}

rebuildWoWApp() {
	# 
	# Removes unnecessary files
	#
	# returns: 0 = success, 1 = fatal, 2 = warning
	#
	local errval=0
	checkWoWDir
	echo
	if [[ -d "./Background Downloader.app" ]]; then
		printf "Removing: ${CYAN}Background Downloader.app${NOCOLOR}. We won't be downloading updates with this client.\n"
		rm -Rf "./Background Downloader.app"
	fi
	#
	# Mac "apps" are actually directories with set structures. The following are lists of th files and directories
	# that make up the application.
	#
	appDirsR=(	"Contents"									# appDirsR = vital (RED error) dirs; must exist for game to run
				"Contents/MacOS"
				"Contents/Resources"
			)
	
	appDirsY=(	"Contents/Resources/Main.nib"				# appDirsY = non-vital (YELLOW error) dirs; should exist, but game still runs
				"Contents/Resources/DivX Gaming.component"
				"Contents/Resources/DivX Gaming.component/Contents"
				"Contents/Resources/DivX Gaming.component/Contents/MacOS"
				"Contents/Resources/DivX Gaming.component/Contents/Resources"
			)
	appFilesR=(	"Contents/Info.plist"						# appFilesY = vital (RED error) files; must exist for game to run
				"Contents/PkgInfo"
				"Contents/MacOS/World of Warcraft"
				"Contents/Resources/mpq.icns"
				"Contents/Resources/wow.icns"
			  )
	appFilesY=(	"Contents/Resources/Main.nib/classes.nib"
				"Contents/Resources/Main.nib/info.nib"
				"Contents/Resources/Main.nib/objects.xib"
				"Contents/Resources/DivX Gaming.component/Contents/Info.plist"
				"Contents/Resources/DivX Gaming.component/Contents/PkgInfo"
				"Contents/Resources/DivX Gaming.component/Contents/MacOS/DivX Gaming"
				"Contents/Resources/DivX Gaming.component/Contents/Resources/DivX Gaming.rsrc"
			 )
	# make a new copy of the App itself, with only the needed files.
	appDirs=( "${appDirsR[@]}" "${appDirsY[@]}" )
	appFiles=( "${appFilesR[@]}" "${appFilesY[@]}" )
	local TEMPDIR=.
	tempApp=$(mktemp -d -t wow)
	printf "Transferring only necessary files to new application.\n"
	for dir in "${appDirs[@]}"; do mkdir -p "${tempApp}/$dir"
		if [[ ! -d "${wowApp}/$dir" ]]; then								# Houston, we have a problem
			if [[ -f "${wowApp}/$dir" ]]; then								# a problem with some archivers/extractors - filename created for dir
				rm -f "${wowApp}/$dir"										# Fix: 1. remove the file
				if [[ -d "${wowApp}/$dir.1" ]] ; then						#      2. usually dir exits, but with a .1
					mv "${wowApp}/$dir.1" "${wowApp}/$dir"					#         so rename it.
				else														#        But,
					local lead="${dir%.*}"									#         if the directors has an extenstion like .app or .component,
					local tail="${dir#*.}"									#         the .1 will be before the extension
					if [[ -d "${wowApp}/${lead}.1.${tail}" ]] ; then		#         so we check if the dir exists with that name
						yellowError "directory structure is corrupted.\n"
						printf "Found:  ${CYAN}${wowApp}/${lead}.1.${tail}${NOCOLOR}\n"
						printf "wanted: ${CYAN}${wowApp}/$dir${NOCOLOR}. Renaming.\n\n"
						mv "${wowApp}/${lead}.1.${tail}" "${wowApp}/$dir"	#         and rename if it does. 
					fi
				fi
			fi
		fi
		if [[ ! -d "${wowApp}/$dir" ]]; then								# All that effort, and no satisfaction.
			if isArrayMember "$dir" ${appDirsR[@]} ; then
				redError "${CYAN}${wowApp}/$dir${NOCOLOR} is missing, and game won't run.\n"
				errval=1
			else
				yellowError "${CYAN}${wowApp}/$dir${NOCOLOR} is missing. You should fix that, but game should still run.\n"
				errval=$(( $errval == 1 ? 1 : 2 ))
			fi
			#
			#
		fi	
	done
	for file in "${appFiles[@]}"; do
		if [[ -e "${wowApp}/$file" ]]; then
			mv "${wowApp}/$file" "${tempApp}/$file"
		else
			redError "missing $file from your application. This is a fatal error. Extract the\n original archive again, or download a new copy.\n\n"
			printf "Command line version of ${CYAN}unzip${NOCOLOR} will sometimes unpack incorrectly. Don't use it.\n"
			errval=1
		fi
	done
	cd "${wowApp}"
	filesLeft=("$(find . -type f)")
	if [[ ! -z "${filesLeft[@]}" ]]; then
		printf "Removed the following files:\n"
		for file in "${filesLeft[@]}" ; do
			printf "    ${CYAN}${file}${NOCOLOR}\n"
		done
	else
		printf "No unnecessary files found in the application itself.\n"
	fi
	cd ..
	# ensure executables are +x
	find "$tempApp" -path "*/MacOS/*" -type f -exec chmod +x {} \;
	printf "Removing old version of application\n"
	rm -Rf "${wowApp}"
	mv "$tempApp" "$wowApp"
	printf "Done.\n\n"
	read -p "Press any key to continue..."
	return $errval
}

createDesktopLink() {
	#
	# Creates a desktop icon for "Elysium Project Wow"
	#
	ln -s "${wowDir}/$wowApp" "${HOME}/Desktop/Elysium Project Wow"
}
	
upper() {
	#
	# Returns string in UPPER case
	#
	echo $(tr '[:lower:]' '[:upper:]'<<<$1)
}

lower() {
	#
	# Return string in lower case
	#
	echo $(tr '[:upper:]' '[:lower:]'<<<$1)
}

redError() {
	#
	# Prints an error with a leading red "ERROR:". String should come with '\n' if needed.
	#
	printf "${RED}ERROR:${NOCOLOR} $1"
}

yellowError() {
	#
	# Prints an error with a leading yellow "ERROR:". String should come with '\n' if needed.
	#
	printf "${YELLOW}ERROR:${NOCOLOR} $1"
}

error() {
	local func=$1
	local msg=$2
	printf "${RED}ERROR:${NOCOLOR} Function $func reported: $msg"
	exit 1
}

configNewInstall() {
	#
	# checks, validates install, and then asks user for realm
	#
	echo "Configuring..."	
	
}

repairPermissions() {
	#
	# resets permissions on the game directory
	#
	checkWoWDir
	local errval=0
	if [[ "$USER" == "root" ]] ; then
		redError "this script should be run as your regular user account.\n"
		exit 1
	fi
	printf "\nRepairing permissions.\n\n${LIGHTBLUE}NOTE:${NOCOLOR} this is a little coarse, and will remove +x from executables not part of the stock WoW apps.\n"
	local groupName=$(id -gn)
	chown -R $USER:$groupName *	# change ownership to user
	if [[ "$?" != 0 ]] ; then
		redError "can't change ownership. Script exiting. You'll need to fix that first, likely with sudo access.\n\n"
		exit 1
	fi
	printf "Setting directory permissions...\n"
	find . -type d -exec chmod 0755 {} \;					# set directory permissions
	printf "Setting file permissions...\n"
	find . -type f -exec chmod 0644 {} \;					# set file permissions
	printf "Setting +x on WoW executables...\n"
	find . -type f -path "*/MacOS/*" -exec chmod +x {} \;	# set +x on executables in apps
	printf "Done.\n\n"
	read -p "Press any key to continue..."
	return 0
}

clearCache() {
	#
	# Clears WDB cache
	#
	checkWoWDir
	local errval=0
	if [[ -d ./WDB ]] ; then
		rm -rf ./WDB/*
		if [[ "$?" != 0 ]] ; then
			redError "unable to clear the contents of ./WDB. Fix the permissions on the directory (in Maintance menu).\n"
			return 1
		else
			printf "Contents of ${CYAN}./WDB${NOCOLOR} cleared.\n"
		fi
	fi
	printf "Done.\n\n"
	read -p "Press any key to continue..."
	return 0
}

rewriteRealmlist() {
	checkWoWDir
	printf "Writing ${CYAN}realmlist.wtf${NOCOLOR}\n"
	if ! setRealmListWtf ; then
		read -p "Errors found. Fix, and rerun. Press any key to continue..."
		return 1
	fi
	printf "Writing ${CYAN}config.wtf${NOCOLOR}\n"
	if ! setConfigWtf ; then
		read -p "Errors found. Fix, and rerun. Press any key to continue..."
		return 1
	fi
	printf "Done.\n\n"
	read -p "Press any key to continue..."
	return 0
}
	
fixDisconnectErrors () {
	checkWoWDir
	clear
	printf "Most disconnect errors are caused by incorrect realmList and realmName configurations.\n\n"
	printf "To fix, we'll:\n\n    1. Clear caches\n    2. Re-write realmList configs\n    3. Clear your realmName config\n\n"
	if ! clearCache ; then
		read -p "Errors found. Fix, and rerun. Press any key to continue..."
		return 1
	fi
	if ! setRealmListWtf ; then
		read -p "Errors found. Fix, and rerun. Press any key to continue..."
		return 1
	fi
	if ! setConfigWtf ; then
		read -p "Errors found. Fix, and rerun. Press any key to continue..."
		return 1
	fi
	return 0
}

cleanUp() {
	#
	# Cleanup routines here
	#
	echo
	if [[ "$?" != "0" ]]; then 
		exit 1
	else
		exit 0
	fi
}

# ---------------------------------------------------------------------------
#  Main script starts here
# ---------------------------------------------------------------------------s
set -e
trap cleanUp EXIT

getWoWAppName
wowDir=$(pwd)

#
# Check we're running the correct version of WoW (defined at top of script).
#
wowExec=$(find . -type f -path "./${wowApp}/*" -name 'World of Warcraft')
wowExecMD5=$(getMD5 "$wowExec")
wowVersion=$(getWoWVersion "$wowApp")
if [[ "$wowVersion" != "$WOW_VERSION" || "$wowExecMD5" != "$WOWEXEC_MD5" ]]; then
	printf "\n             ${LIGHTRED}RUH ROH, error found!${NOCOLOR}\n\n"
	printf "Your install is World of Warcraft version:           ${RED}${wowVersion}${NOCOLOR} - ${CYAN}${wowExecMD5}${NOCOLOR}\n"
	printf "This script, and the Elysium Project only supports:  ${LIGHTBLUE}1.12.1${NOCOLOR} - ${CYAN}${WOWEXEC_MD5}${NOCOLOR}\n\n"
fi

if ! checkConfig ; then
	echo 
	exit 1
fi

mainMenu




