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

# brew may put executables in /usr/local/sbin
export PATH="/usr/local/sbin:$PATH"

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

# Only show files starts with dot
alias l.='ls -d .*'

# Don't delete the input files when using unxz
alias unxz='unxz -k'

# ulimit command by default changes the HARD limits
# Use the -S option to change the SOFT limits
alias ulimit='ulimit -S'

# Compute sum of stdin line by line
## If there are too many lines, tool bc would fail.
## All numbers are represented internally in decimal and all computation is done in decimal.
alias my_sum='paste -sd+ - |bc'

# Just like du, but sorted by human-readable size
alias my_du='du -d 1 -h |sort -h'

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

# zsh need this, otherwise Chinese in PS1 can not shown correctly
export LANG=en_US.UTF-8

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
            if xsel >/dev/null 2>&1; then
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

# Generate a random password
my_gen_pw() {
    openssl rand -base64 20
}

# You don't need it if dos2unix is available.
dos2unix_() {
    if [ ! "$1" ] ; then
        echo 'Usage: dos2unix_ file1 file2 ...'
        return
    fi

    typeset TMP
    while [ "$1" ] ; do
        TMP="$1.$$"
        if tr -d '\r' <"$1" >"$TMP" ; then
            cp -a -f "$TMP" "$1"
        fi
        rm -f "$TMP"
        shift
    done
}

# convert file from GB18030 to UTF-8
my_gb18030_to_utf8() {
    if [ ! "$1" ]; then
        echo 'Usage: my_gb18030_to_utf8 file'
        return
    fi

    typeset target_file
    while [ "$1" ] ; do
        target_file="$1.bak$RANDOM"
        if iconv -f GB18030 -t UTF-8 "$1" >"$target_file"; then
            mv "$target_file" "$1"
        else
            rm -f "$target_file"
        fi
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

# https://www.codeproject.com/Tips/470308/XOR-Hex-Strings-in-Linux-Shell-Script
my_xor()
{
    if [ ${#@} -ne 2 ]; then
        echo 'Usage: my_xor str1 str2'
        return
    fi
    if [[ -n $ZSH_VERSION ]]; then
        setopt KSH_ARRAYS
    fi
    typeset res=(`echo "$1" | sed "s/../0x& /g"`)
    shift 1
    while [[ "$1" ]]; do
        typeset one=(`echo "$1" | sed "s/../0x& /g"`)
        typeset count1=${#res[@]}
        if [ $count1 -lt ${#one[@]} ]
        then
            count1=${#one[@]}
        fi
        for (( i = 0; i < $count1; i++ ))
        do
            res[$i]=$((${one[$i]:-0} ^ ${res[$i]:-0}))
        done
        shift 1
    done
    printf "%02x" "${res[@]}"
}


################################################################################
################################################################################
proxy_on() {
    export http_proxy='http://localhost:8118'
    export https_proxy='http://localhost:8118'
    export JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=8118"
    export JAVA_OPTS="$JAVA_OPTS -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=8118"
    ## Default, sbt use gigahorse as HTTP client, but gigahorse do not support proxy, so disable gigahorse
    ## https://github.com/sbt/sbt/issues/3696
    export JAVA_OPTS="$JAVA_OPTS -Dsbt.gigahorse=false"
    if command -v npm >/dev/null 2>&1; then
        npm config set proxy http://localhost:8118
        npm config set https-proxy http://localhost:8118
    fi
    echo "proxy on"
}

proxy_off() {
    unset http_proxy
    unset https_proxy
    if command -v npm >/dev/null 2>&1; then
        npm config delete proxy
        npm config delete https-proxy
    fi
    export JAVA_OPTS=$(echo $JAVA_OPTS | sed -e 's/-Dhttp.proxy[^ ]* //g' -e 's/-Dhttps.proxy[^ ]* //g')
    echo "proxy off"
}

proxy_status() {
    echo "http_proxy=$http_proxy"
    echo "https_proxy=$https_proxy"
    if command -v npm >/dev/null 2>&1; then
        echo -n "npm config get proxy="
        npm config get proxy
        echo -n "npm config get https-proxy="
        npm config get https-proxy
    fi
    echo "JAVA_OPTS=$JAVA_OPTS"
}

################################################################################
################################################################################
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
my_get_ppid() {
    if [ ! "$1" ] ; then
        echo 'Usage: my_get_ppid pid' 1>&2;  # print usage into stderr
        echo '-1'  # error
    fi
    # First, check if is number.
    if [[ $1 =~ ^[0-9]+$ ]]; then
        #echo "debug. get-ppid arg: "$1 >1.log
        if [ -a "/proc/$1/stat" ]; then
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

# Show env of process
my_get_pidenv() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: my_get_pidenv pid'
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
