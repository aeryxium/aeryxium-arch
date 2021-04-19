#!/usr/bin/bash

# $HOME/get_dots.zsh
#
# Attempt to bootstrap dotfiles; may cause all running zshells to exit or
# behave unpredictably if SIGUSER1 is not trapped explicitly by them.

readonly DOTFILES_DIR="${HOME}/.config/dotfiles"
readonly GIT_USERNAME="aeryxium"
readonly GIT_REPONAME="dotfiles"
readonly GIT_REPO="https://github.com/${GIT_USERNAME}/${GIT_REPONAME}.git"

# dotfiles - Call git with options for using dotfiles bare repo
# Arguments:
#     array - git options, parameters and arguments
function dotfiles() {
	if ! /usr/bin/git --git-dir="${DOTFILES_DIR}" --work-tree="${HOME}" "$@"; then
		exit 1
	fi
	return 0
}

# clone_repo - Try to clone dotfiles repo (with https to avoid key issues)
# Arguments:
#     none
function clone_repo() {
	if ! /usr/bin/git clone -q --bare "${GIT_REPO}" "${DOTFILES_DIR}" ; then
		printf "ERROR: Failed cloning dotfiles.\n"
		printf " => Verify internet and try again: '~/get_dots.zsh\n"
		exit 1
	fi
	return 0
}

# set_upstream - Switch upstream to ssh for future usage
# Arguments:
#     none
function set_upstream() {
	dotfiles remote set-url origin "git@github.com:${GIT_USERNAME}/${GIT_REPONAME}.git"
	if ! dotfiles checkout &>/dev/null; then
		printf "ERROR: Failed checking out dotfiles.\n"
		printf " => Check for conflict and try again with: 'dotfiles checkout'\n"
		alias dotfiles="git --git-dir=${HOME}/${DOTFILES_DIR} --work-tree=${HOME}"
		exit 1
	fi
	return 0
}

# Execution starts here
function main() {
	clone_repo
	set_upstream
	# Restart tmux if active to use new environment
	if systemctl --user is-active --quiet tmux.service; then
		systemctl --user restart tmux.service
	fi
	return 0
}

main "$@"
