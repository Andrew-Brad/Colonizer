# https://www.quora.com/What-is-bash_profile-and-what-is-its-use
# Cmder will pick this file up if it is in your user directory (C:\Users\Andrew)

echo '.bashrc executed. To edit, type: code ~/.bashrc'

alias lsa="ls -lhAG --color=always | sed -re 's/^[^ ]* //'"

# Bash Git Prompt - https://github.com/magicmonty/bash-git-prompt
# To setup, run: git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
# git prompt settings:
GIT_PROMPT_ONLY_IN_REPO=1
GIT_PROMPT_FETCH_REMOTE_STATUS=0 #avoid fetching remote status
GIT_PROMPT_IGNORE_STASH=1 #ignore any stashes.
GIT_PROMPT_THEME=Single_line_NoExitState_Gentoo
# GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch

source ~/.bash-git-prompt/gitprompt.sh
##################################################################

alias git?='git status'
alias binobj='find . -iname "bin" -o -iname "obj" | xargs rm -rf'
