# Keep customizations in .bashrc so they're available in non-login shells.
# ~/.profile won't be run in bash, so keep common stuff (e.g., ssh-agent spawning) there...
for f in ~/.bashrc ~/.profile ~/cac-enabled-git-env.sh; do
	[[ -r $f ]] && . "$f"
done
