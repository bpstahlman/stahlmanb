# Note: Copied and slightly modified (see caveat below) from an article on github.
# Note: ~/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.

# IMPORTANT CAVEAT/WORKAROUND: ssh-agents spawned in Cygwin can't communicate
# with ssh-agents spawned in (e.g.) MSysGit. Thus, if we simply hardcode the
# name of the file (e.g., agent.env), ssh agents will be spuriously spawned.
# Example: Cygwin updates the single env file with socket information its
# ssh-agent can use. When agent_load_env loads this information within MSysGit,
# agent_is_running reports "not running" because it's unable to communicate
# with the Cygwin ssh-agent. Accordingly, MSysGit spawns a new ssh-agent and
# *overwrites* the Cygwin-specific socket information in the single env file,
# with the result that subsequent invocations from within Cygwin will be unable
# to communicate with the original Cygwin ssh-agent, and will need to spawn
# another!
# Solution: Use system-specific env var files (e.g., using uname). The only
# drawback is that passphrase will need to be entered once for each system
# (according to uname), but this is certainly better than the old situation.
env=~/.ssh/`uname`-agent.env

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).

agent_is_running() {
    if [ "$SSH_AUTH_SOCK" ]; then
        # ssh-add returns:
        #   0 = agent running, has keys
        #   1 = agent running, no keys
        #   2 = agent not running
        ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
        false
    fi
}

agent_has_keys() {
    ssh-add -l >/dev/null 2>&1
}

agent_load_env() {
    . "$env" >/dev/null
}

agent_start() {
    (umask 077; ssh-agent >"$env")
    env|grep SSH
    . "$env" >/dev/null
}

if ! agent_is_running; then
    agent_load_env
fi

if ! agent_is_running; then
    agent_start
    ssh-add
elif ! agent_has_keys; then
    ssh-add
fi

unset env

# vim:ts=4:sw=4:tw=120
