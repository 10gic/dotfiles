# This file can be sourced by bash/ksh/zsh.
#
# Note for portability:
# pgrep is not available in AIX by default.
# whoami is not available in Solaris by default.
# Hyphen (-) can not used in function name in ksh (Version AJM 93u+ 2012-08-01).
#
# Note for zsh: Following two options must be set before source this file.
# setopt KSH_ARRAYS
# setopt SH_WORD_SPLIT

if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

if [ -d "${HOME}/go/bin" ]; then
    export PATH="${HOME}/go/bin:${PATH}"
fi

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

case "$(uname -s)" in
    Linux|CYGWIN*)
        alias ls='ls --color=auto'
        # In old version (for example, 5.97) of `ls', --group-directories-first is not available.
        if ls --group-directories-first >/dev/null 2>&1; then
            alias ll='ls -lhFG --group-directories-first'
        else
            alias ll='ls -lhFG'
        fi
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
        alias zgrep='zgrep --color=auto'
        alias df='df -x tmpfs -x devtmpfs -x fuse.sshfs'
        ;;
    Darwin)
        # The default color for directory is blue, but it's not distinguishable,
        # Following setting change directory color to cyan.
        export LSCOLORS='gxfxcxdxbxegedabagacad'
        # In Emacs(Mac) term mode, `ls` can't show Chinese correctly,
        # After adding 'LANG=en_US.UTF-8', Chinese can be shown.
        alias ls='LANG=en_US.UTF-8 ls -GF'
        alias ll='ls -lhF'

        # https://superuser.com/questions/117841/get-colors-in-less-or-more
        alias grepc='grep --color=always'
        alias fgrepc='fgrep --color=always'
        alias egrepc='egrep --color=always'
        alias zgrepc='zgrep --color=always'
        alias less='less -R'
        ;;
    AIX)
        alias ll='ls -lF'
        ;;
    SunOS)
        alias ll='ls -lhF'
        ;;
esac

alias l.='ls -d .*'

alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias cd.....="cd ../../../.."

# Don't delete the input files when using unxz
alias unxz='unxz -k'

# ulimit command by default changes the HARD limits
# Use the -S option to change the SOFT limits
alias ulimit='ulimit -S'

# Compute sum of stdin line by line
## If there are too many lines, tool bc would fail.
## All numbers are represented internally in decimal and all computation is done in decimal.
alias my_sum='paste -sd+ - |bc'

# Cat file, and remove comments
alias cat_no_comment='egrep -v "^\s*(#|$)"'

# Check if trash-put exists in $PATH
if command -v trash-put >/dev/null 2>&1; then
    alias rm='trash-put'
fi

# Check if rlwrap exists in $PATH
if command -v rlwrap >/dev/null 2>&1; then
    alias sqlplus='rlwrap sqlplus'
    alias db2='rlwrap db2'
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

# mkdir and cd the new directory
mkcd () {
    mkdir -p "$1" && cd "$1";
}

# rm files/directories except the specified items.
rm_not () {
    if [ ! "$1" ] ; then
        echo 'Usage: rm_not file1 file2 ...'
        return
    fi

    typeset ignore_files="";
    typeset ignore_file;
    for ignore_file in "$@";
    do
        ignore_file="${ignore_file/%\//}"  # remove trailing '/', for example: dir1/ -> dir1
        ignore_files="${ignore_files}-not -name ${ignore_file} ";
    done;

    find . $ignore_files -delete
}

# Copy fullpath of $1 to clipboard.
cl () {
    if [[ "$1" == /* ]]; then
        # check whether the first character of $1 is '/'
        typeset fullpath="$1"
    else
        typeset fullpath="$PWD/$1"
    fi
    if command -v python >/dev/null 2>&1; then
        # normalize path by using python
        fullpath=$(python -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$fullpath")
    fi
    case "$(uname -s)" in
        Linux|CYGWIN*)
            ## readlink -f option does not exist on Mac OS X
            typeset normalpath="$(readlink -nf "$fullpath")";
            ## test xsel
            xsel >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                # if xsel work normally, copy path to clipboard.
                echo -n "$normalpath" | xsel -ib
                echo "$normalpath is copied to clipboard"
            else
                echo "$normalpath is NOT copied to clipboard"
            fi
            ;;
        Darwin)
            echo -n "$fullpath" | pbcopy
            echo "$fullpath is copied to clipboard"
            ;;
        *)
            echo "$fullpath is NOT copied to clipboard"
            ;;
    esac
}

# You don't need it if dos2unix is available.
dos2unix_() {
    if [ ! "$1" ] ; then
        echo 'Usage: dos2unix_ file1 file2 ...'
        return
    fi

    typeset TMP
    while [ "$1" ] ; do
        TMP=$1.$$
        if tr -d '\r' <"$1" >"$TMP" ; then
            cp -a -f "$TMP" "$1"
        fi
        rm -f "$TMP"
        shift
    done
}

# convert decimal to hex, support big number
my_10to16() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: my_10to16 number'
        return
    fi
    typeset num="$1"
    typeset result=`python -c "print(hex(${num}))"`
    # The result may contains trailing 'L', remove it.
    echo ${result%L}
}

# convert hex to decimal, support big number
my_16to10() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: my_16to10 number'
        return
    fi
    typeset num="$1"
    python -c "print(int(\"${num}\", 16))"
}

# convert binary to hex
my_2to16() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: my_2to16 number'
        return
    fi
    typeset num="$1"
    python -c "print(hex(int(\"${num}\", 2)))"
}

# convert hex to binary
my_16to2() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: my_16to2 number'
        return
    fi
    typeset num="$1"
    python -c "print(bin(int(\"${num}\", 16)))"
}

my_getpidenv() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: my_getpidenv pid'
        return
    fi
    local pid=$1
    if [ "$(uname -s)" = "Linux" ]; then
        tr "\0" "\n" < "/proc/$pid/environ"
    elif [ "$(uname -s)" = "Darwin" ]; then
        # option e in ps show env
        # use `command` to bypass grep alias
        ps ewww $pid | command grep -o '[^ ]*=[^ ]*'
    else
        echo 'my_getpidenv do not support your system'
    fi
}

proxy_on() {
    export http_proxy='http://localhost:1087'
    export https_proxy='http://localhost:1087'
    echo "proxy on"
}

proxy_off() {
    unset http_proxy
    unset https_proxy
    echo "proxy off"
}

################################################################################
################################################################################
## helper functions for emacs

alias em='emacs -q -nw'

if [ "$(uname -s)" = "Darwin" ]; then
    # Open file with Aquamacs
    ema() {
        for f in "$@";
        do
            test -e "$f" || touch "$f"
        done
        open -a Aquamacs "$@"
    }
    emx() {
        Emacs=/Applications/Emacs.app/Contents/MacOS/Emacs
        for f in "$@";
        do
            test -e "$f" || touch "$f"
        done
        open -a $Emacs "$@"
    }
fi

# start emacs daemon
emacs_start() {
    LC_CTYPE=zh_CN.UTF-8 emacs --daemon
}

# stop emacs daemon
emacs_stop() {
    emacsclient --eval "(progn (setq kill-emacs-hook 'nil) (kill-emacs))"
}

# kill all emacs process
emacs_killall() {
    typeset user=$(id | sed s"/) .*//" | sed "s/.*(//")  # current user.
    typeset pids=$(pgrep -u ${user} emacs Emacs Aquamacs);
    if [ -n "$pids" ]; then
        echo kill -9 $pids
    else
        echo "Cannot find any emacs process for user ${user}.";
    fi
}

# check emacs status
emacs_status() {
    typeset pids=$(pgrep emacs Emacs Aquamacs);
    if [ -n "$pids" ]; then
        case "$(uname -s)" in
            CYGWIN*)
                # In CYGWIN, "-p" option in ps can only accept ONE pid.
                # So, show processes one by one.
                set -- $pids;
                while [ "$1" ]; do
                    ps -f -p $1
                    shift
                done
                ;;
            *)
                ps -f -p $pids;
                ;;
        esac
    else
        echo "Cannot find emacs process.";
    fi
}

# Check current shell is launched by emacs or not.
# Return 0 if it's not launched by emacs
# Return 1 if it's launched by emacs
# Return 2 if it's launched by Aquamacs (A emacs variant in Mac OS X)
launch_by_emacs() {
    typeset p_pid=$PPID
    typeset ppid_cmd
    while [[ $p_pid != 1 ]]
    do
        # ppid_cmd=`ps -p $p_pid -o cmd=` ## -o is not supported by ps in Cygwin
        ppid_cmd=$(ps -p $p_pid | tail -n 1)
        if [[ $ppid_cmd == *emacs* ]]; then
            return 1;
        fi
        if [[ $ppid_cmd == *Emacs* ]]; then
            # In Mac, Emacs.app has name `Emacs`
            return 1;
        fi
        if [[ $ppid_cmd == *Aquamacs* ]]; then
            return 2;
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

# Get the parent process ID of process $1.
#
# The caller can user this method to get ppid: var1=$(get-ppid pid)
#
# The keyword "return" can only return a number between 0 and 255.
# But, ppid may greater than 255, so cannot use "return".
#
# Note 1: Please do NOT echo others into stdout in this function.
# Note 2: ps in Cygwin does not support -o option.
# Note 3: Mac OS X, for example Yosemite, does not have directory /proc
get_ppid() {
    if [ ! "$1" ] ; then
        echo 'Usage: get_ppid pid' 1>&2;  # print usage into stderr
        echo '-1'  # error
    fi
    # First, check if is number.
    if [[ $1 =~ ^[0-9]+$ ]]; then
        #echo "debug. get-ppid arg: "$1 >1.log
        if [ -a /proc/$1/stat ]; then
            typeset -a stat
            stat=($(< /proc/$1/stat))  # create an array
            # Note: typeset -a stat=($(< /proc/$1/stat)) cannot work in zsh.

            typeset ppid=${stat[3]}    # get the fourth field
            echo $ppid   # "return vaule".
        else
            typeset ppid=$(ps -p $1 -o ppid=);
            # The equal sign in "ppid=" suppresses the output of the header line
            echo $ppid
        fi
    else
        echo '-1'  # error
    fi
}

emc() {
    # If current shell is created by emacs (M-x term), then
    #  open file with -n (--no-wait) option in current emacs frame.
    launch_by_emacs
    typeset retcode=$?
    if [[ $retcode == 2 ]]; then
        open -a Aquamacs "$@"
    elif [[ $retcode == 1 ]]; then
        emacsclient -n "$@"
    else
        emacsclient -t -a "" "$@"
    fi
}

emn() {
    # Open file and jump to specified line
    # For example, `emn file.txt:102` would open file.txt, and jump to line 102
    typeset str=$1
    if [[ -z "$str" ]]; then
        em
    else
        typeset -a array
        array=(${str//:/ })
        ## Note: typeset -a array=(${str//:/ }) cannot work in zsh
        typeset filename=${array[0]}
        typeset line=${array[1]}
        typeset column=${array[2]}
        #echo "filename:" $filename;
        #echo "line:" $line;
        #echo "column:" $column;
        if [[ $line =~ ^[0-9]+$ ]]; then
            if [[ $column =~ ^[0-9]+$ ]]; then
                em +$line:$column "$filename"
            else
                em +$line "$filename"
            fi
        else
            em "$filename"
        fi
    fi
}

ediff() {
    typeset quoted1
    typeset quoted2
    # diff two files
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
        # diff two directories
        if [[ -d $1 && -d $2 ]]; then
            quoted1=${1//\\/\\\\}; quoted1=${quoted1//\"/\\\"}
            quoted2=${2//\\/\\\\}; quoted2=${quoted2//\"/\\\"}
            # emacsclient -t -a "" --eval "(ediff-directories \"$quoted1\" \"$quoted2\" nil)"
            launch_by_emacs
            if [[ $? == 1 ]]; then
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
    typeset tmp=$(mktemp /tmp/gdbbt.XXXXXX)
    echo thread apply all bt >"$tmp"
    gdb -batch -nx -q -x "$tmp" -p "$1"
    rm -f "$tmp"
}

# gdbwait wait a process and debug it.
# usage: gdbwait <program-name>
#
# In Apple's version of gdb, you can capture processes by:
# (gdb) attach --waitfor <process-name>
# But it's not available in official GNU gdb.
# Refer to
# http://stackoverflow.com/questions/4382348/is-there-any-way-to-tell-gdb-to-wait-for-a-process-to-start-and-attach-to-it
#
# Note:
# It may not work if your program name is too short.
# Because gdbwait use pgrep to find pid for matched keyword.
# But the matching is not EXACT, if you run `pgrep ls`, you may find undesired
# pids which related with /usr/bin/pulseaudio
gdbwait() {
    if [ ! "$1" ] ; then
        echo 'Usage: gdbwait process-name'
        return
    fi

    typeset prog_nm=$1
    typeset current_user=$USER
    # Backup old matching pid , we don't debug existing processes
    typeset old_pids=$(pgrep -u $current_user $prog_nm)
    typeset new_pid=""
    while [ "$new_pid" = "" ]; do
        new_pid=$(pgrep -u $current_user -n $prog_nm)
        # -n in pgrep means newest matching processes
        if [[ "$new_pid" != "" ]]; then
            if [[ "$old_pids" == *$new_pid* ]]; then
                new_pid=""
            fi
        fi
    done
    echo "Begin debug pid: $new_pid"
    gdb -q -p $new_pid
}

# Do not print the introductory and copyright messages in gdb.
alias gdb='gdb -q'

################################################################################
## helper functions for cscope

my_getfuncdef() {
    # get function definitions in current directory
    if [ ! "$1" ] ; then
        echo "Usage: my_getfuncdef [func_name]"
        return
    fi
    cscope_query 1 $1
}

my_getfuncref() {
    # get function references in current directory
    if [ ! "$1" ] ; then
        echo "Usage: my_getfuncref [func_name]"
        return
    fi
    cscope_query 3 $1
}

cscope_query() {
    # $1 is input field num (counting from 0)
    # $2 is keyword
    if ! command -v cscope >/dev/null 2>&1; then
        echo "cscope is not found."
        return
    fi
    if [ ! -a "$PWD/cscope.output" ]; then
        typeset index_file=$(mktemp /tmp/cscopeindex.XXXXXX)
        typeset list_file=$(mktemp /tmp/cscopelist.XXXXXX)
        if command -v cscope-indexer >/dev/null 2>&1; then
            cscope-indexer -f $index_file -i $list_file -r
        else
            # generate index file manually if cscope-indexer is not available.
            my_gencscopefiles $list_file
            cscope -b -i $list_file -f $index_file
        fi
        cscope -d -f $index_file -L -$1 $2
        rm -f $index_file
        rm -f $list_file
    else
        cscope -L -$1 $2
    fi
}

my_gencscopefiles () {
    typeset list_file=cscope.files
    if [ $# -ge 1 ]; then
        list_file=$1
    fi
    ( find "$PWD" \( -type f -o -type l \) ) | \
        egrep -i '\.([chly](xx|pp)*|cc|hh|go|java)$' | \
        sed -e '/\/CVS\//d' -e '/\/RCS\//d' -e 's/^\.\///' | \
        sort > $list_file
}

################################################################################
## helper functions for VirtualBox

# lists all virtual machines currently registered with VirtualBox
my_vmlist() {
    VBoxManage list vms
}

my_vmlistrunning() {
    VBoxManage list runningvms
}

# usage: my_vmstart [vmname]
# start virtual machine in headless mode, and show ip of guest OS.
my_vmstart () {
    typeset vmname="$1"
    if [ ! "$1" ] ; then
        echo "Usage: my_vmstart [vmname]"
        echo ""
        echo "Candidate of vmname:"
        VBoxManage list vms | cut -d' ' -f1
        return
    fi
    # start vm in headless mode
    VBoxManage startvm $vmname --type headless

    # my_vmcheckip $vmname;
    echo "You can run 'my_vmcheckip ${vmname}' to check the ip of vm."
}

# usage: my_vmstop [vmname]
# stop virtual machine
my_vmstop () {
    typeset vmname="$1"
    if [ ! "$1" ] ; then
        echo "Usage: my_vmstart [running_vmname]"
        echo ""
        echo "Candidate of running_vmname:"
        VBoxManage list runningvms | cut -d' ' -f1
        return
    fi
    # shutdown virtual machine
    VBoxManage controlvm $vmname poweroff
}

# usage: my_vmcheckip [your_vmname]
my_vmcheckip () {
    typeset vmname="$1"
    if [ ! "$1" ] ; then
        echo "Usage: my_vmcheckip [vmname]"
        return
    fi
    # try to show ip of guest OS, this method sometimes incorrectly (it may incorrect when host OS IP changed).
    typeset ip=$(VBoxManage guestproperty enumerate $vmname | grep "Net.*V4.*IP" | awk -F"," '{print $2}' | awk '{print $2}')
    if [ -z $ip ]; then
        echo "Cannot obtain ip of $vmname"
    else
        echo "$vmname ip may be $ip"
    fi
}
