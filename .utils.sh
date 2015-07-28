# This file can be sourced by bash/ksh/zsh.
#
# Note for zsh: Following two options must be set before source this file.
# setopt KSH_ARRAYS
# setopt SH_WORD_SPLIT

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

case "$(uname -s)" in
    Linux|CYGWIN*)
        alias ls='ls --color=auto'
        alias ll='ls -lhFG --group-directories-first'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
        alias df='df -x tmpfs -x devtmpfs -x fuse.sshfs'
        ;;
    Darwin)
        alias ls='ls -G'
        alias ll='ls -lhF'
        ;;
    AIX)
        alias ll='ls -lF'
        ;;
    SunOS)
        alias ll='ls -lhF'
        ;;
esac

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

# Don't delete the input files when using unxz
alias unxz='unxz -k'

# check if trash-put exists in $PATH
if command -v trash-put >/dev/null 2>&1; then
    alias rm='trash-put'
fi

# check if rlwrap exists in $PATH
if command -v rlwrap >/dev/null 2>&1; then
    alias sqlplus='rlwrap sqlplus'
    alias db2='rlwrap db2'
fi

################################################################################
if [ -d ~/bin ]; then
    export PATH="~/bin:${PATH}"
fi

export HISTCONTROL=ignoredups

# Environment variable for wine.
export WINEARCH=win32

# Environment variable for X server
# export DISPLAY=:0.0

# Environment variable for bc
if [ -f ~/.bcrc ]; then
    export BC_ENV_ARGS=~/.bcrc
fi

################################################################################
# Note for portability:
# Hyphen can not used in function name in ksh (Version AJM 93u+ 2012-08-01).

mkcd () {
    mkdir -p "$1" && cd "$1";
}

# Copy fullpath of $1 to clipboard.
cl () {
    if [[ "$1" == /* ]]; then
        # check whether the first character of $1 is '/'
        typeset fullpath="$1"
    else
        typeset fullpath="$PWD/$1"
    fi
    case "$(uname -s)" in
        Linux|CYGWIN*)
            ## readlink -f option does not exist on Mac OS X
            typeset normalpath=`readlink -nf $fullpath`;
            ## test xsel
            xsel >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                # if xsel work normally, copy path to clipboard.
                echo -n $normalpath | xsel -ib
                echo "$normalpath copied"
            else
                echo $normalpath
            fi
            ;;
        Darwin)
            echo -n $fullpath | pbcopy
            echo "$fullpath copied"
            ;;
        *)
            echo $fullpath
    esac
}

################################################################################
################################################################################
## helper functions for emacs

function emacs_start {
    LC_CTYPE=zh_CN.UTF-8 emacs --daemon
}

function emacs_stop {
    emacsclient --eval "(progn (setq kill-emacs-hook 'nil) (kill-emacs))"
}

function emacs_status {
    pids=`pgrep emacs`;
    if [ $? -eq 0 ]; then
        ps -f -p $pids;
    else
        echo "Cannot find emacs process.";
    fi
}

function launch_by_emacs {
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
        p_pid=$(get_ppid $p_pid)
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
# Note 1: Please do NOT use other "echo" statments in this function.
# Note 2: ps in Cygwin does not support -o option.
# Note 3: Mac OS X, for example Yosemite, does not have directory /proc
function get_ppid {
    # First, check if is number.
    if [[ $1 =~ ^[0-9]+$ ]]; then
        #echo "debug. get-ppid arg: "$1 >1.log
        if [ -a /proc/$1/stat ]; then
            typeset -a stat
            stat=($(< /proc/$1/stat))  # create an array
            # Note：typeset -a stat=($(< /proc/$1/stat)) cannot work in zsh.

            typeset ppid=${stat[3]}    # get the fourth field
            echo $ppid   # "return vaule".
        else
            typeset ppid=`ps -p $1 -o ppid=`;
            # The equal sign in "ppid=" suppresses the output of the header line
            echo $ppid
        fi
    else
        echo "-1"  # error
    fi
}

function em {
    # If current shell is created by emacs (M-x term), then
    #  open file with --no-wait option in current emacs frame.
    launch_by_emacs
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
        launch_by_emacs
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
            if [[ launch_by_emacs == 1 ]]; then
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
## helper functions for gdb

## usage: gdbbt <pid>
## like pstack, with more information (eg. line number) if compiled with "-g".
gdbbt() {
    typeset tmp=`mktemp /tmp/gdbbt.XXXXXX`
    echo thread apply all bt >"$tmp"
    gdb -batch -nx -q -x "$tmp" -p "$1"
    rm -f "$tmp"
}

# Do not print the introductory and copyright messages in gdb.
alias gdb='gdb -q'

################################################################################
################################################################################
## helper functions for perl

# usage: perl_ftrace fun1,fun2 yourprogram.pl [arguments]
# Prerequisite: Debug::LTrace
perl_ftrace () {
    if [ ${#@} -lt 2 ]; then
        echo "usage: perl_ftrace fun1,fun2 yourprogram.pl [arguments]"
        return
    fi
    typeset fun=$1
    typeset prog=$2
    typeset args=$3
    PERL5LIB="$HOME/.perllib":$PERL5LIB perl -MDebug::LTrace="$fun" -- "$prog" $args
}


################################################################################
## helper functions for cscope

getdef() {
    # get C/C++ function definitions in current directory
    cscope_query 1 $1
}

getref() {
    # get C/C++ function references in current directory
    cscope_query 3 $1
}

cscope_query() {
    # $1 is input field num (counting from 0)
    # $2 is keyword
    if ! command -v cscope >/dev/null 2>&1; then
        echo "cscope is not found."
        return
    fi
    if [ ! -a $PWD/cscope.output ]; then
        typeset index_file=`mktemp /tmp/cscope.XXXXXX`
        typeset list_file=`mktemp /tmp/cscope2.XXXXXX`
        if command -v cscope-indexer >/dev/null 2>&1; then
            cscope-indexer -f $index_file -i $list_file -r
        else
            # generate index file manually if cscope-indexer is not available.
            cscope_generate_list $list_file
            cscope -b -i $list_file -f $index_file
        fi
        cscope -d -f $index_file -L -$1 $2
        rm -f $index_file
        rm -f $list_file
    else
        cscope -L -$1 $2
    fi
}

cscope_generate_list ()
{
    typeset list_file=cscope.files
    if [ $# -ge 1 ]; then
        list_file=$1
    fi
    ( find $PWD \( -type f -o -type l \) ) | \
        egrep -i '\.([chly](xx|pp)*|cc|hh)$' | \
        sed -e '/\/CVS\//d' -e '/\/RCS\//d' -e 's/^\.\///' | \
        sort > $list_file
}
