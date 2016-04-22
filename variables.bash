# Make sure $HOSTNAME is set
if [[ -z $HOSTNAME ]]; then export HOSTNAME=$(hostname -s); fi

# Make sure $MTYPE is set
if [[ -z $MTYPE ]]; then
    if [ "$(uname)" == "Darwin" ]; then
        MTYPE="Darwin"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        MTYPE="Linux"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        MTYPE="Windows"
    else
        MTYPE="Unknown"
    fi
fi

# Core colours
if [[ -z $PS1_COLOUR_PRIMARY_LOCAL ]]; then PS1_COLOUR_PRIMARY_LOCAL='Blue'; fi
if [[ -z $PS1_COLOUR_PRIMARY_REMOTE ]]; then PS1_COLOUR_PRIMARY_REMOTE='Red'; fi
if [[ -z $PS1_COLOUR_SECONDARY ]]; then PS1_COLOUR_SECONDARY='BoldGreen'; fi

# Show smiley for errors module // Show errors
if [[ -z $PS1_MODULE_SMILEY ]]; then PS1_MODULE_SMILEY=1; fi
if [[ -z $PS1_MODULE_ERRORS ]]; then PS1_MODULE_ERRORS=1; fi

# Show *-version for langs
if [[ -z $PS1_MODULE_SHOWENV ]]; then PS1_MODULE_SHOWENV=1; fi
if [[ -z $PS1_MODULE_SHOWENV_COLOUR ]]; then PS1_MODULE_SHOWENV_COLOUR='Cyan'; fi

# Show git status
if [[ -z $PS1_MODULE_GIT ]]; then PS1_MODULE_GIT=1; fi
if [[ -z $PS1_MODULE_GIT_COLOUR ]]; then PS1_MODULE_GIT_COLOUR='Magenta'; fi

# Fancy git settings/display characters
if [[ -z $PS1_MODULE_GIT_FANCY ]]; then PS1_MODULE_GIT_FANCY=1; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_BRANCH ]]; then PS1_MODULE_GIT_PROMPT_BRANCH="${Magenta}"; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_STAGED ]]; then PS1_MODULE_GIT_PROMPT_STAGED="${Yellow}"; fi
if [[ -z $PS1_MODULE_GIT_SYMBOL_STAGED ]]; then PS1_MODULE_GIT_SYMBOL_STAGED="☑ "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_CONFLICTS ]]; then PS1_MODULE_GIT_PROMPT_CONFLICTS="${Red}"; fi
if [[ -z $PS1_MODULE_GIT_SYMBOL_CONFLICTS ]]; then PS1_MODULE_GIT_SYMBOL_CONFLICTS="✗ "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_CHANGED ]]; then PS1_MODULE_GIT_PROMPT_CHANGED="${Blue}"; fi
if [[ -z $PS1_MODULE_GIT_SYMBOL_CHANGED ]]; then PS1_MODULE_GIT_SYMBOL_CHANGED="☒ "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_REMOTE ]]; then PS1_MODULE_GIT_PROMPT_REMOTE=" "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_UNTRACKED ]]; then PS1_MODULE_GIT_PROMPT_UNTRACKED="${Cyan}"; fi
if [[ -z $PS1_MODULE_GIT_SYMBOL_UNTRACKED ]]; then PS1_MODULE_GIT_SYMBOL_UNTRACKED="☐ "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_STASHED ]]; then PS1_MODULE_GIT_PROMPT_STASHED="${BoldMagenta}"; fi
if [[ -z $PS1_MODULE_GIT_SYMBOL_STASHED ]]; then PS1_MODULE_GIT_SYMBOL_STASHED="⚑ "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_CLEAN ]]; then PS1_MODULE_GIT_PROMPT_CLEAN="${Green}"; fi
if [[ -z $PS1_MODULE_GIT_SYMBOL_CLEAN ]]; then PS1_MODULE_GIT_SYMBOL_CLEAN="✓ "; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_SYMBOLS_AHEAD ]]; then PS1_MODULE_GIT_PROMPT_SYMBOLS_AHEAD="↟"; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_SYMBOLS_BEHIND ]]; then PS1_MODULE_GIT_PROMPT_SYMBOLS_BEHIND="↡"; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_SYMBOLS_PREHASH ]]; then PS1_MODULE_GIT_PROMPT_SYMBOLS_PREHASH=":"; fi
if [[ -z $PS1_MODULE_GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING ]]; then PS1_MODULE_GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING="L"; fi

# bash-git-prompt gitstatus.sh
if [[ -z $__GIT_PROMPT_SHOW_UNTRACKED_FILES ]]; then __GIT_PROMPT_SHOW_UNTRACKED_FILES='all'; fi
