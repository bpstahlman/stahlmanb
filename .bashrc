# This should be the default.
shopt -s histappend
[[ -r ~/cac-enabled-git-env.sh ]] && . ~/cac-enabled-git-env.sh

# Prepend rakudobrew to PATH.
export PATH=~/.rakudobrew/bin:$PATH

# Prepend Rust's cargo bin dir to PATH (for packages installed with `cargo
# install')
PATH=~/.cargo/bin:$PATH
PATH=~/.local/bin:~/bin:$PATH
PATH=~/.perl6/bin:/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/site/bin:$PATH
# Put latest racket in front of the ancient one installed by ubuntu package
# manager.
# TODO: Probably just remove Ubuntu's.
PATH=~/racket/bin:$PATH
export PATH

export STACK_INSTALL_PATH=~/.local/bin

# Note: Provide an fzf overload of readline's reverse incremental history
# search on C-R (which readline's vi defaults map to readline's
# reverse-search-history).
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
