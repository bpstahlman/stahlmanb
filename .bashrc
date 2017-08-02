# This should be the default.
shopt -s histappend
[[ -r ~/cac-enabled-git-env.sh ]] && . ~/cac-enabled-git-env.sh

# Prepend rakudobrew to PATH.
export PATH=~/.rakudobrew/bin:$PATH

export PATH=~/.local/bin:~/bin:$PATH

export STACK_INSTALL_PATH=~/.local/bin

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
