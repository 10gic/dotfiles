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

################################################################################
################################################################################
#
# extends bash's CD to keep, display and access history of visited directory
# names
#
# From: http://linuxgazette.net/109/marinov.html
#
# DESCRIPTION
#
# cd --
#
# Shows the history list of visited directories. The list shows the most
# recently visited names on the top.
#
# cd -NUM
#
# Changes the current directory with the one at position NUM in the history
# list. The directory is also moved from this position to the top of the list.

cd_func ()
{
    local x2 the_new_dir adir index
    local -i cnt

    if [[ $1 ==  "--" ]]; then
        dirs -v
        return 0
    fi

    the_new_dir=$1
    [[ -z $1 ]] && the_new_dir=$HOME

    if [[ ${the_new_dir:0:1} == '-' ]]; then
        #
        # Extract dir N from dirs
        index=${the_new_dir:1}
        [[ -z $index ]] && index=1
        adir=$(dirs +$index)
        [[ -z $adir ]] && return 1
        the_new_dir=$adir
    fi

    #
    # '~' has to be substituted by ${HOME}
    [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

    #
    # Now change to the new dir and add to the top of the stack
    pushd "${the_new_dir}" > /dev/null
    [[ $? -ne 0 ]] && return 1
    the_new_dir=$(pwd)

    #
    # Trim down everything beyond 11th entry
    popd -n +11 2>/dev/null 1>/dev/null

    #
    # Remove any other occurence of this dir, skipping the top of the stack
    for ((cnt=1; cnt <= 10; cnt++)); do
        x2=$(dirs +${cnt} 2>/dev/null)
        [[ $? -ne 0 ]] && return 0
        [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
        if [[ "${x2}" == "${the_new_dir}" ]]; then
            popd -n +$cnt 2>/dev/null 1>/dev/null
            cnt=cnt-1
        fi
    done

    return 0
}

alias cd=cd_func
################################################################################
