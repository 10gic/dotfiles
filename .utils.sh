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
        alias df='df -x tmpfs -x devtmpfs -x fuse.sshfs'
        ;;
    Darwin)
        export LSCOLORS='Exfxcxdxbxegedabagacad'   # set for lighter blue directories in mac
        alias ls='ls -G'
        alias ll='ls -lhF'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
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
## This is an alternative: awk ' { totol += $0 } END { print totol }'
alias mysum='paste -sd+ - |bc'

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
                echo "$normalpath is not copied to clipboard"
            fi
            ;;
        Darwin)
            echo -n "$fullpath" | pbcopy
            echo "$fullpath is copied to clipboard"
            ;;
        *)
            echo "$fullpath is not copied to clipboard"
            ;;
    esac
}

# Remove ALL System V IPC objects belong to current user.
kill_ipcs ()
{
    typeset user;
    if [ ! "$1" ]; then
        # Default, whoami and "id -un" is not available in Solaris.
        user=`id | sed s"/) .*//" | sed "s/.*(//"`  # current user.
    else
        user="$1"
    fi

    typeset opt;
    for opt in -q -s -m
    do
        # Use grep to find matched user, false negative errors are possible.
        # In output of ipcs, the msqid/shmid/semid is the second column ($2).
        ipcs $opt | grep " ${user} " | awk '{print "ipcrm ""'$opt'",$2}' | sh -x
    done
}
alias ipcs_kill=kill_ipcs

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

# unzip file with encoding GBK.
unzip_gbk() {
    if [ ! "$1" ] ; then
        echo 'Usage: unzip_gbk filename.zip'
    fi
    if [ -f ~/bin/unzip_gbk.py ]; then
        python ~/bin/unzip_gbk.py $1
    else
        mkdir -p ~/bin;
        cat << EOF >~/bin/unzip_gbk.py
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import zipfile

print u"Processing File %s" % sys.argv[1].decode('utf-8')

file = zipfile.ZipFile(sys.argv[1], "r")
for gbkname in file.namelist():
    utf8name = gbkname.decode('gbk')
    print "Extracting %s" % utf8name
    pathname = os.path.dirname(utf8name)
    if not os.path.exists(pathname) and pathname != "":
        os.makedirs(pathname)
    if not os.path.exists(utf8name):
        data = file.read(gbkname)
        outfile = open(utf8name, "w")
        outfile.write(data)
        outfile.close()
file.close()
EOF
    fi
}

# convert decimal to hex, support big number
10to16() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: 10to16 number'
        return
    fi
    typeset num="$1"
    typeset result=`python -c "print(hex(${num}))"`
    # The result may contains trailing 'L', remove it.
    echo ${result%L}
}

# convert hex to decimal, support big number
16to10() {
    if [ ${#@} -ne 1 ]; then
        echo 'Usage: 16to10 number'
        return
    fi
    typeset num="$1"
    python -c "print(int(\"${num}\", 16))"
}

################################################################################
################################################################################
## helper functions for emacs

alias em='emacs -q -nw'

# emacsclient of Aquamacs (A emacs variant in Mac OS X). Just hard-code it.
emacsclient_mac=/Applications/Aquamacs.app/Contents/MacOS/bin/emacsclient

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
    typeset pids=$(pgrep -u ${user} emacs);
    if [ -n "$pids" ]; then
        echo kill -9 $pids
    else
        echo "Cannot find any emacs process for user ${user}.";
    fi
}

# check emacs status
emacs_status() {
    typeset pids=$(pgrep emacs);
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
# Return 2 if it's launched by Aquamacs
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
        $emacsclient_mac -n "$@"
    elif [[ $retcode == 1 ]]; then
        emacsclient -n "$@"
    else
        emacsclient -t -a "" "$@"
    fi
}

emn() {
    typeset str=$1
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

# export org file into pdf
org2pdf () {
    if [ ${#@} -ne 1 ] && [ ${#@} -ne 2 ] && [ ${#@} -ne 3 ]; then
        echo 'Usage: org2pdf [-k] filename.org [output_dir]'
        return
    fi

    typeset removelogfiles=t     # nil or t (default)
    if [ "$1" = "-k" ]; then
        removelogfiles=nil
        shift
    fi

    typeset orgfile="$1"
    if [ ! -e ${orgfile} ]; then
        echo "File ${orgfile} does not exist, do nothing."
        return;
    fi

    typeset outputdir="$2"
    if [ -n "${outputdir}" ] && [ ! -d "${outputdir}" ]; then
        echo "Directory ${outputdir} does not exist, do nothing."
        return;
    fi

    ## There are issues when export latex file with svg image.
    ## If svg image exist in file, change [[./xxx/image.svg]] to [[./xxx/image.pdf]]
    ## Note: Please make sure there is corresponding pdf image,
    ## If not, you can convert svg to pdf by `inkscape -f file.svg -A file.pdf;`
    typeset containsvg="false"
    if fgrep -q '.svg]]' "${orgfile}"; then
        containsvg="true"
        ## remove svg, save it to filename.nosvg.org
        sed 's/.svg\]\]/.pdf\]\]/g' "${orgfile}" > "${orgfile/%org/nosvg.org}"
        orgfile="${orgfile/%org/nosvg.org}"
    fi

    ## There are issues when export latex file with gif image.
    ## If gif image exist in file, change [[./xxx/image.gif]] to [[./xxx/image.pdf]]
    ## Note: Please make sure there is corresponding pdf image,
    ## If not, you can convert gif to pdf by `sips -s format pdf file.gif --out file.pdf;` in Mac
    typeset containgif="false"
    if fgrep -q '.gif]]' "${orgfile}"; then
        containgif="true"
        ## remove gif, save it to filename.nogif.org
        sed 's/.gif\]\]/.pdf\]\]/g' "${orgfile}" > "${orgfile/%org/nogif.org}"
        orgfile="${orgfile/%org/nogif.org}"
    fi

    typeset EMACS=emacs
    if [[ "$(uname -s)" == "Darwin" ]] && [[ -x /Applications/Emacs.app/Contents/MacOS/Emacs ]]; then
        EMACS=/Applications/Emacs.app/Contents/MacOS/Emacs
    fi

    echo "Begin generating pdf for ${orgfile}"
    if [ -e ~/.emacs.d/customize-org.el ]; then
        $EMACS -batch -l "~/.emacs.d/customize-org.el" -f toggle-debug-on-error -eval \
               "(progn
                    (setq org-export-allow-bind-keywords t
                          org-confirm-babel-evaluate nil
                          org-latex-remove-logfiles ${removelogfiles})
                    (find-file \"${orgfile}\") (org-latex-export-to-pdf))"
    else
        $EMACS -batch -f toggle-debug-on-error -eval \
               "(progn
                    (setq org-export-allow-bind-keywords t
                          org-confirm-babel-evaluate nil)
                    (setq org-latex-pdf-process
                          '(\"xelatex -interaction nonstopmode -output-directory %o %f\"
                            \"xelatex -interaction nonstopmode -output-directory %o %f\"
                            \"xelatex -interaction nonstopmode -output-directory %o %f\"))
                    (find-file \"${orgfile}\") (org-latex-export-to-pdf))"
    fi

    typeset pdf="${orgfile/%org/pdf}"
    if [ -s "${pdf}" ]; then
        ## Here, the pdf file name may be filename.nosvg.nogif.pdf
        if [ ${containgif} = "true" ]; then
            ## cp filename.nogif.pdf filename.pdf
            cp "${pdf}" "${pdf/%nogif.pdf/pdf}"
            pdf="${pdf/%nogif.pdf/pdf}"
        fi
        if [ ${containsvg} = "true" ]; then
            ## cp filename.nosvg.pdf filename.pdf
            cp "${pdf}" "${pdf/%nosvg.pdf/pdf}"
            pdf="${pdf/%nosvg.pdf/pdf}"
        fi

        if [ -n "${outputdir}" ]; then
            mv "${pdf}" "${outputdir}"
        fi
        echo "Generate pdf for $1 finished."
    else
        echo "Fail to generate pdf for $1."
    fi
}

findPdfsWithKeywordMeta() {
    if [ ${#@} -ne 2 ]; then
        echo 'Usage: findPdfsWithKeywordInDir dirname keyword'
        return
    fi
    typeset dir=$1
    typeset keyword=$2

    typeset output
    typeset keywords
    if [ -d ${dir} ]; then
        # Example of exiftool output (exiftool -Keywords ${dir}/*.pdf)
        # ======== file1.pdf
        # Keywords                        : test1
        # ======== file2.pdf
        # Keywords                        : test2
        exiftool -Keywords ${dir}/*.pdf | egrep -i "^Keywords *:.*${keyword}.*" -B 1 | grep '^========' | cut -d ' ' -f 2-
    else
        if [ ! -a ${dir} ]; then
            echo "directory $dir is not existing"
        else
            echo "$dir is not a directory"
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
        typeset index_file=$(mktemp /tmp/cscope.XXXXXX)
        typeset list_file=$(mktemp /tmp/cscope2.XXXXXX)
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

cscope_generate_list () {
    typeset list_file=cscope.files
    if [ $# -ge 1 ]; then
        list_file=$1
    fi
    ( find "$PWD" \( -type f -o -type l \) ) | \
        egrep -i '\.([chly](xx|pp)*|cc|hh)$' | \
        sed -e '/\/CVS\//d' -e '/\/RCS\//d' -e 's/^\.\///' | \
        sort > $list_file
}

################################################################################
## helper functions for VirtualBox

# usage: startvm [your_vmname]
# start virtual machine in headless mode, and show ip of guest OS.
startvm () {
    typeset vmname="$1"
    if [ ! "$1" ] ; then
        vmname="Debian8"   # My default virtual machine name.
    fi
    # start vm in headless mode
    VBoxManage startvm $vmname --type headless

    checkvmip $vmname;
    echo "You can run 'checkvmip ${vmname}' to check the ip of vm."
}

# usage: stopvm [your_vmname]
# stop virtual machine
stopvm () {
    typeset vmname="$1"
    if [ ! "$1" ] ; then
        vmname="Debian8"   # My default virtual machine name.
    fi
    # shutdown virtual machine
    VBoxManage controlvm $vmname poweroff
}

# usage: checkvmip [your_vmname]
# checkvmip virtual machine
checkvmip () {
    typeset vmname="$1"
    if [ ! "$1" ] ; then
        vmname="Debian8"   # My default virtual machine name.
    fi
    # try to show ip of guest OS, this method sometimes incorrectly (it may incorrect when host OS IP changed).
    typeset ip=$(VBoxManage guestproperty enumerate $vmname | grep "Net.*V4.*IP" | awk -F"," '{print $2}' | awk '{print $2}')
    if [ -z $ip ]; then
        echo "Cannot obtain ip of $vmname"
    else
        echo "$vmname ip may be $ip"
    fi
}
