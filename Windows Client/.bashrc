# https://www.quora.com/What-is-bash_profile-and-what-is-its-use
# Cmder will pick this file up if it is in your user directory (C:\Users\Andrew)

echo '.bashrc executed. To edit, type: code ~/.bashrc'

################################# Posh Git Prompt for Bash - https://github.com/lyze/posh-git-sh #########################
# To setup, run: 
# cd   (in bash this takes you to home directory)
# curl -O https://raw.githubusercontent.com/lyze/posh-git-sh/master/git-prompt.sh
export PROMPT_COMMAND='__posh_git_ps1 "\\[\[\e[0;32m\]\u@\h \[\e[0;33m\]\w" " \[\e[1;34m\]\n\$\[\e[0m\] ";'$PROMPT_COMMAND
source ~/git-prompt.sh
##########################################################################################################################

alias lsa="ls -lhAG --color=always | sed -re 's/^[^ ]* //'"
alias binobj='find . -iname "bin" -o -iname "obj" | xargs rm -rf'
alias git?='git status'