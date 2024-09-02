#!/usr/bin/env bash

# Copy this file to ~/.bash_aliases
# cp "./os/linux/.bash_aliases" ~

# this first one simply lists out the aliases in the terminal for quick reference
alias ab-alias='while read line; do if [[ $line == alias* ]]; then echo $line; fi; done < ~/.bash_aliases | sort;'
alias ab-aliases='ab-alias;'

# colonizer aliases to help get your dotfiles in a fresh environment
alias ab-colonizer-seed-bash-aliases='cp ~/git/Colonizer/os/linux/.bash_aliases ~'

# misc ab-* aliases
alias ab-update="sudo apt update && sudo apt upgrade -y && sudo snap refresh;"

# Git aliases
alias g="git status"
alias gitgud="git add -A && git commit --amend --no-edit && git push -f;"

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Shortcuts
alias dirdownloads="cd ~/Downloads"
alias dirdesktop="cd ~/Desktop"
alias dirgit='if [[ "$OSTYPE" == "linux-gnu"* ]]; then cd ~/git; elif [[ "$OSTYPE" == "darwin"* ]]; then cd ~/Desktop/git; elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then cd /c/Users/$USER/Desktop/git; else echo "Unknown OS"; fi'
alias dircolonizer='if [[ "$OSTYPE" == "linux-gnu"* ]]; then cd ~/git/Colonizer; elif [[ "$OSTYPE" == "darwin"* ]]; then cd ~/Desktop/git/Colonizer; elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then cd /c/Users/$USER/Desktop/git/Colonizer; else echo "Unknown OS"; fi'

# List all files colorized in long format
alias l="ls -lF ${colorflag}"

# List all files colorized in long format, excluding . and ..
alias la="ls -lAF ${colorflag}"

# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

# Always use color output for `ls`
alias ls="command ls ${colorflag}"

# Clear
alias cl="clear"

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
# alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# Show/hide hidden files in Finder
alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Stuff I never really use but cannot delete either because of http://xkcd.com/530/
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume output volume 100'"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
