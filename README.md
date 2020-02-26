# LinuxTerminalFailGifs

LinuxTerminalFailGifs is a shell script which uses the new Windows Terminal background feature to display animated gifs when you fail. By fail I mean when the last command you entered returns a failure code.

By default it will only download a fail gif when there is less than 50 gifs that have been previous downloaded. Otherwise it will cycle through them to improve lag time between fail and gif.

## Setup (Ubuntu)
1. Install the Windows Terminal from the Windows Store and set up a WSL environment
2. At an Administrator powered PowerShell prompt run:
```
Install-Module -Name MSTerminalSettings
```
3. In WSL run the following
```
git clone https://github.com/robeving/LinuxTerminalFailGifs
chmod +x LinuxTerminalFailGifs/fail.sh
sudo apt install imagemagick bc uuid jq
```
4. Edit LinuxTerminalFailGifs/fail.sh and ensure the config lines at the top of the file seem reasonable. They are set for Ubuntu 18.04 WSL defaults
5. Go to https://developers.giphy.com/ and get an API key. Add this key to LinuxTerminalFailGifs/gifhy.key
4. Add the following to the end of your .bashrc

```
PROMPT_COMMAND="$PROMPT_COMMAND"$'\n'"__prompt_command"

__prompt_command() {
        local EXIT="$?"
        (~/LinuxTerminalFailGifs/fail.sh $EXIT &)
}
```

5. Attempt to fail
```
cat thisfiledoesnotexist
```
