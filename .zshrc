# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt appendhistory extendedglob hist_ignore_dups hist_subst_pattern prompt_subst

# Vi line-editing
bindkey -v

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/cygdrive/c/Users/stahlmanb/.zshrc'

autoload -Uz compinit
compinit

autoload -U promptinit
promptinit

# End of lines added by compinstall

# Load version control utilities.
autoload -Uz vcs_info
# Disable all but git and svn for reasons of efficiency.
zstyle ':vcs_info:*' disable bzr cdv darcs fossil hg mtn p4 svk tla

# Set up Git-specific prompt goodies...
zstyle ':vcs_info:*' actionformats \
 '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
# If get-revision isn't set, git commit numbers won't be available.
zstyle ':vcs_info:*' get-revision yes
zstyle ':vcs_info:*' formats       \
 '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%F{3}-%F{5}(%f%6.6i%F{5})'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
# vcs_info must be called in pre-cmd hook to populate ${vcs_info_msg_0_}
precmd () { vcs_info }
# Note: prompt_subst must be set for this to work.
PS1='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_}%f%# '
