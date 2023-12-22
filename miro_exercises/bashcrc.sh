# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" =
    PS1=
else
    PS1=
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1=
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls=
    #alias dir=
    #alias vdir=

    alias grep=
    alias fgrep=
    alias egrep=
fi

# colored GCC warnings and errors
#export GCC_COLORS=

# some more ls aliases
alias ll=
alias la=
alias l=

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert=

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Show git branch name

force_color_prompt=

color_prompt=

parse_git_branch() {

export ANDROID_HOME=

git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'

}

if [ "$color_prompt" =

PS1=

else

PS1=

fi

unset color_prompt force_color_promp

#alias ivcssh=
#alias ivc=
#alias ivcscp=

alias ivcssh=
alias ivc=
alias ivcscp=
alias iscrcpy=
alias ivishell=
alias iviroot=
alias ivimqtt=
alias 3f4=
alias matrix_restart=
export LD_LIBRARY_PATH=
export LD_LIBRARY_PATH=
export LD_LIBRARY_PATH=
export NEWCOMMANDTIMEOUT=
export ARTIFACTORY_API_KEY=
export ARTIFACTORY_USER=
export RFW_TOKEN=
export PA_TOKEN=
export CK=
export clearCK=
export client_secret=


export JAVA_HOME=
#export JAVA_HOME=


export IVI_ADB_SERIAL=

ARTIFACTORY_API_KEY= VmFsZW9AR2VuMjB4Cg
export ARTIFACTORY_USER= s1rkrann
export ANDROID_HOME=/usr/lib/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export IVI_ADB_SERIAL= sZW9AR2VuMjB4
