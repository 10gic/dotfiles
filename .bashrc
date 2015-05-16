# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

PS1='\u@\h \w\\$ '

# set titile, make it update dynamically
# see also http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss4.3
case "$TERM" in
    xterm*|rxvt*|cygwin)
        PS1="\[\033]0;\u@\h: \w\007\]$PS1"
        ;;
    *)
        ;;
esac

################################################################################
if [ -f ~/.shellrc ]; then
    . ~/.shellrc
fi

################################################################################
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
