# Add this to the bottom of your bashrc

### git prompt
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_THEME=Single_line_Ubuntu
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
###

alias lsa="ls -lhAG --color=always | sed -re 's/^[^ ]* //'"
alias binobj='find . -iname "bin" -o -iname "obj" | xargs rm -rf'
alias git?='git status'

# Default directory
cd /mnt/c/users/andrew/desktop/github

echo '.bashrc executed. To edit, type: code ~/.bashrc'