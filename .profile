# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# gpg has to be started here (or in .xinitrc.exwm), if we want to have encryption in exwm
gpg-connect-agent /bye
SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export SSH_AUTH_SOCK
if [ -z "$DISPLAY" -a "$(tty)" = '/dev/tty5' ]; then
    exec /usr/bin/startx ~/.xinitrc.exwm >/tmp/startx.log 2>&1
fi
