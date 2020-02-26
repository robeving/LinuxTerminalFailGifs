#!/bin/bash

# This is the name of the profile to update with the new settings.
# Check your Windows Terminal settings file for this value
PROFILE="Ubuntu-18.04"
DEFAULT_BG_COLOUR="#000000"
DEFAULT_BG_OPACITY="0"
# This is the directory that downloaded Gifs will be stored. In needs to be referenced in both
# Windows and Linux hence the two paths
GIFDIR_WINDOWS="c:\\FailGifs"
GIFDIR_LINUX="/mnt/c/FailGifs"
GIFHY_API_KEY=$(<~/LinuxTerminalFailGifs/gifhy.key)
# Stop downloading new Gifs at this limit
DOWNLOAD_LIMIT=50

# First check if the powershell script we use is running, we don't want to clobber something else
ps aux | grep [G]et-MSTerminalProfile > /dev/null
result=$?
if [ "${result}" -eq "0" ] ; then
        exit 0
fi

# next check the error code that was passed as an argument. If it is 0 then reset the background.
if [ $1 -eq 0 ]; then
        powershell.exe -Command "Get-MSTerminalProfile -Name \"$PROFILE\" | Set-MSTerminalProfile -BackgroundImageOpacity $DEFAULT_BG_OPACITY -Background \"$DEFAULT_BG_COLOUR\""
else
	mkdir -p $GIFDIR_LINUX
	GIFCOUNT=$(find ${GIFDIR_LINUX} -type f | wc -l)
	if [ $GIFCOUNT -le $DOWNLOAD_LIMIT ]; then
		# download a gif
		uuid=$(uuidgen)
		FailGif=$(curl "https://api.giphy.com/v1/gifs/random?api_key=$GIFHY_API_KEY&tag=fail&rating=PG-13" --silent | jq -r '.data.images["original"].url')
		curl $FailGif -o $GIFDIR_LINUX/$uuid.gif --silent
	fi

	# select a gif
	uuid=$(ls $GIFDIR_LINUX | shuf -n 1)

	# set the background to be the gif
        time=$(/usr/bin/time --format "%e" powershell.exe -Command "Get-MSTerminalProfile -Name \"$PROFILE\" | Set-MSTerminalProfile -BackgroundImage $GIFDIR_WINDOWS/$uuid -BackgroundImageOpacity 0.35 -Background \"$DEFAULT_BG_COLOUR\" -BackgroundImageStretchMode uniformToFill" 2>&1 )

	# we need to workout how long a gif actually runs for so we can display it for the correct amount of time               # turns out this is non trivial here is an OK way
	timeToWait=$(identify -format "%T\n" $GIFDIR_LINUX/$uuid | awk '{t+=$0} END{print t "/100"}' | bc -l)
        timeToWait=$(echo $timeToWait - $time + 0.05 | bc -l | sed 's/^\./0./')

        # sometimes we get a negative number, drop the sign
        timeToWait=`echo $timeToWait | sed 's/[-]*//g'`

        sleep $timeToWait

	# now reset the terminal
        powershell.exe -Command "Get-MSTerminalProfile -Name \"$PROFILE\" | Set-MSTerminalProfile -BackgroundImageOpacity $DEFAULT_BG_OPACITY -Background \"$DEFAULT_BG_COLOUR\""

fi
