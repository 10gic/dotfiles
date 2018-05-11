HOST=`hostname`
PS1='${USER}@${HOST}:${PWD} \$ '

set -o emacs

if [ -f ~/.utils.sh ]; then
    . ~/.utils.sh
fi

## Local Variables: ##
## mode:sh ##
## End: ##
