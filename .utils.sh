# This file can be sourced by bash/zsh.
#
# Note for zsh: Following two options must be set before source this file.
# setopt KSH_ARRAYS
# setopt SH_WORD_SPLIT

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
    alias ll='ls -lhF'
else
    alias ll='ls -lhFG --group-directories-first'
    alias df='df -x tmpfs -x devtmpfs -x fuse.sshfs'
fi

alias l.='ls -d .*'

if [ -f /usr/lib64/LispWorks/lispworks-5-1-0-amd64-linux ]; then
    alias lispworks5="/usr/lib64/LispWorks/lispworks-5-1-0-amd64-linux"
fi
if [ -f /usr/local/lib64/LispWorks6.1/lispworks-6-1-0-amd64-linux ]; then
    alias lispworks6="/usr/local/lib64/LispWorks6.1/lispworks-6-1-0-amd64-linux"
fi

alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias cd.....="cd ../../../.."

# check if trash-put exists in $PATH
if command -v trash-put >/dev/null 2>/dev/null; then
    alias rm='trash-put'
fi

################################################################################
if [ -d ~/bin ]; then
    export PATH="~/bin:${PATH}"
fi

export HISTCONTROL=ignoredups

function mkcd {
    mkdir -p "$1" && cd "$1";
}

if [ -f ~/.bcrc ]; then
    export BC_ENV_ARGS=~/.bcrc
fi

# copy fullpath to clipboard.
function cl {
    fullpath=`readlink -nf $1`;
    #echo $fullpath;
    ## test xsel
    xsel >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        # if xsel work normally, copy fullpath to clipboard.
        echo -n $fullpath | xsel -ib
    else
        echo $fullpath;
    fi
}

# Environment variable for wine.
export WINEARCH=win32

# Environment variable for X server
# export DISPLAY=:0.0

################################################################################
################################################################################
## settings/fucntions for emacs

function emacs-start {
    LC_CTYPE=zh_CN.UTF-8 emacs --daemon
}

function emacs-stop {
    emacsclient --eval "(progn (setq kill-emacs-hook 'nil) (kill-emacs))"
}

function emacs-status {
    pgrep -l emacs |awk '{print $1}' |xargs ps -f -p
}

function launch-by-emacs {
    typeset p_pid=$PPID
    typeset ppid_cmd
    while [[ $p_pid != 1 ]]
    do
        ## ppid_cmd=`ps -p $p_pid -o cmd=`
        ## ps in Cygwin does not support -o option.
        ppid_cmd=`ps -p $p_pid | tail -n 1`
        if [[ $ppid_cmd == *emacs* ]]; then
             return 1;
        fi
        #echo "p_pid is " $p_pid
        p_pid=$(get-ppid $p_pid)
        #echo "p_pid after is " $p_pid
        if [[ $p_pid -lt 1 ]]; then
            return 0
        fi
    done
    return 0
}

# The caller can user this method to get ppid: var1=$(get-ppid pid)
#
# The keyword "return" can only return a number between 0 and 255.
# But, ppid may greater than 255, so cannot use "return".
#
# Note: Please do NOT use other "echo" statments in this function.
function get-ppid {
    # First, check if is number.
    if [[ $1 =~ ^[0-9]+$ ]]; then
        #echo "debug. get-ppid arg: "$1 >1.log
        typeset -a stat
        stat=($(< /proc/$1/stat))  # create an array
        # Note：typeset -a stat=($(< /proc/$1/stat)) cannot work in zsh.

        typeset ppid=${stat[3]}    # get the fourth field
        echo $ppid   # "return vaule".
    else
        echo "0"  # error
    fi
}

function em {
    # If current shell is created by emacs (M-x term), then
    #  open file with --no-wait option in current emacs frame.
    launch-by-emacs
    if [[ $? == 1 ]]; then
         emacsclient -n "$@" # -n --no-wait
    else
         emacsclient -t -a "" "$@"
    fi
}

function emn {
    typeset str=$1
    typeset -a array
    array=(${str//:/ })
    ## Note：typeset -a array=(${str//:/ }) cannot work in zsh
    typeset filename=${array[0]}
    typeset line=${array[1]}
    typeset column=${array[2]}
    #echo "filename:" $filename;
    #echo "line:" $line;
    #echo "column:" $column;
    if [[ $line =~ ^[0-9]+$ ]]; then
        if [[ $column =~ ^[0-9]+$ ]]; then
            em +$line:$column $filename
        else
            em +$line $filename
        fi
    else
        em $filename
    fi
}

function ediff {
    typeset quoted1
    typeset quoted2
    if [[ -f $1 && -f $2 ]]; then
        # Idea from: http://stackoverflow.com/questions/8848819/emacs-eval-ediff-1-2-how-to-put-this-line-in-to-shell-script
        quoted1=${1//\\/\\\\}; quoted1=${quoted1//\"/\\\"}
        quoted2=${2//\\/\\\\}; quoted2=${quoted2//\"/\\\"}
        #emacsclient -t -a "" --eval "(ediff \"$quoted1\" \"$quoted2\")"
        launch-by-emacs
        if [[ $? == 1 ]]; then
            emacsclient -n --eval "(ediff \"$quoted1\" \"$quoted2\")"
        else
            emacsclient -t -a "" --eval "(ediff \"$quoted1\" \"$quoted2\")"
        fi
    else
        if [[ -d $1 && -d $2 ]]; then
            quoted1=${1//\\/\\\\}; quoted1=${quoted1//\"/\\\"}
            quoted2=${2//\\/\\\\}; quoted2=${quoted2//\"/\\\"}
            # emacsclient -t -a "" --eval "(ediff-directories \"$quoted1\" \"$quoted2\" nil)"
            if [[ launch-by-emacs == 1 ]]; then
                emacsclient -n --eval "(ediff-directories \"$quoted1\" \"$quoted2\" nil)"
            else
                emacsclient -t -a "" --eval "(ediff-directories \"$quoted1\" \"$quoted2\" nil)"
            fi
        else
            echo "Usage: ediff file1 file2, file1 and file2 must be exsiting files or directories."
        fi
    fi
}


################################################################################
################################################################################
## settings/fucntions for gdb

## usage: gdbbt <pid>
## like pstack, with more information (eg. line number) if compiled with "-g".
gdbbt() {
    tmp=`mktemp`
    echo thread apply all bt >"$tmp"
    gdb -batch -nx -q -x "$tmp" -p "$1"
    rm -f "$tmp"
}


################################################################################
## helper fucntions for cscope

getdef() {
    # get C/C++ function definitions in current directory
    get_info_cscope 1 $1
}

getref() {
    # get C/C++ function references in current directory
    get_info_cscope 3 $1
}

get_info_cscope() {
    # $1 is input field num (counting from 0)
    # $2 is keyword
    if [ ! -a $PWD/cscope.output ]; then
        indexfile=`mktemp`
        listfile=`mktemp`
        cscope-indexer -f $indexfile -i $listfile -r
        cscope -d -f $indexfile -L -$1 $2
        rm -f $indexfile
        rm -f $listfile
    else
        cscope -L -$1 $2
    fi
}
