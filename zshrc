# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam2

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
if command -v dircolors >/dev/null 2>/dev/null; then
    eval "$(dircolors -b)"
fi
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'



################################################################################
################################################################################
# set the xterm title to "username@hostname: directory"
# http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss4.1
case $TERM in
    xterm*)
        precmd () {print -Pn "\e]0;%n@%m: %~\a"}
        ;;
esac

if command -v dircolors >/dev/null 2>/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
fi


# if command not found, prompt which package it in.
[ -f /etc/zsh_command_not_found ] && . /etc/zsh_command_not_found


# set M-DEL should stop at /
# Refer to http://chneukirchen.org/dotfiles/.zshrc
WORDCHARS="*?_-.[]~&;$%^+"
_backward_kill_default_word() {
    WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' zle backward-kill-word
}
zle -N backward-kill-default-word _backward_kill_default_word
bindkey '\e=' backward-kill-default-word   # = is next to backspace


# set M-m copy the last word of current line.
# Refer to http://chneukirchen.org/blog/archive/2013/03/10-fresh-zsh-tricks-you-may-not-know.html
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word


################################################################################
# source common utils/settings
setopt KSH_ARRAYS
setopt SH_WORD_SPLIT
if [ -f ~/.utils.sh ]; then
    source ~/.utils.sh
fi

## Local Variables: ##
## mode:sh ##
## End: ##
