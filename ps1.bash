#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Interactive Shells
function __ps1_load_error() {
    echo ' !! Error initiating PS1, using default.'
    [ -n "$1" ] && echo " !! $1"
    echo
    export PS1='[\u@\h \W]\$ '
    return 0
}

export PROMPT_DIRTRIM=4

# Check if .ps
if [ ! -e $HOME/.ps1 ]; then
    __ps1_load_error "$HOME/.ps1 not found" && return
else
    if [ -e $HOME/.ps1/bash-git-prompt/prompt-colors.sh ]; then
        source $HOME/.ps1/bash-git-prompt/prompt-colors.sh
    else
        __ps1_load_error "$HOME/.ps1/bash-git-prompt/prompt-colors.sh not found" && return
    fi

    if [ -e $HOME/.ps1/core_functions.bash ]; then
        source $HOME/.ps1/core_functions.bash
    else
        __ps1_load_error "$HOME/.ps1/core_functions.bash not found" && return
    fi

    if [ -e $HOME/.ps1/variables.bash ]; then
        source $HOME/.ps1/variables.bash
    else
        __ps1_load_error "$HOME/.ps1/variables.bash not found" && return
    fi
fi

if [[ -r $HOME/.ps1/smiley.bash ]]; then
    source $HOME/.ps1/smiley.bash
else
    __ps1_load_error "$HOME/.ps1/smiley.bash not found" && return
fi

if [[ -r $HOME/.ps1/showenv.bash ]]; then
    source $HOME/.ps1/showenv.bash
else
    __ps1_load_error "$HOME/.ps1/showenv.bash not found" && return
fi

if [[ -r $HOME/.ps1/git.bash ]]; then
    source $HOME/.ps1/git.bash
else
    __ps1_load_error "$HOME/.ps1/git.bash not found" && return
fi

function set_prompt_command {
    # Store previous exit code
    local prev_exit_code=$?

    if [ -z "$SSH_CLIENT" ]; then
        eval "local COL1=\$$PS1_COLOUR_PRIMARY_LOCAL"
    else
        eval "local COL1=\$$PS1_COLOUR_PRIMARY_REMOTE"
    fi
    eval "local COL2=\$$PS1_COLOUR_SECONDARY"

    # Clear PS1
    PS1=""

    if [[ $PS1_MODULE_SMILEY -eq 1 ]]; then
        PS1+="$(__ps1_smiley $prev_exit_code $Green $Red $ResetColour) "
    fi

    local ps1_user="${COL1}\u"
    local ps1_hostname="${COL1}${HOSTNAME}"
    local ps1_wd="${COL1}\w"
    PS1+="${COL2}[${ps1_user}${COL2}@${ps1_hostname}${COL2}:${ps1_wd}${COL2}]"

    if [[ $PS1_MODULE_SHOWENV -eq 1 ]]; then
        for lang in ruby node python go; do
            local showenv=$(__ps1_showenv $lang)
            if [ ! -z "$showenv" ]; then
                PS1+=" ${COL2}[${showenv}${COL2}]${ResetColour}"
            fi
        done
    fi

    if [[ $PS1_MODULE_GIT -eq 1 ]]; then
        local git_file=`__ps1_upsearch .git`
        if [ ! -z "$git_file" ]; then
            eval "local git_colour=\$$PS1_MODULE_GIT_COLOUR"
            if [[ $PS1_MODULE_GIT_FANCY -eq 1 ]]; then
                if declare -F __ps1_git_fancy > /dev/null; then
                    local _git_ps1_output="$(__ps1_git_fancy)"
                    if [ -n "${_git_ps1_output}" ]; then
                        PS1+=" ${COL2}[${git_colour}${_git_ps1_output}${COL2}]${ResetColour}"
                    fi
                fi
            else
                if declare -F __ps1_git > /dev/null; then
                    local _git_ps1_output="$(__ps1_git '%s')"
                    if [ -n "${_git_ps1_output}" ]; then
                        PS1+=" ${COL2}[${git_colour}${_git_ps1_output}${COL2}]${ResetColour}"
                    fi
                fi
            fi
        fi
    fi

    if [[ $PS1_MODULE_ERRORS -eq 1 && $prev_exit_code != 0 ]]; then
        local exit_status=${prev_exit_code}
        # Lookup signal numbers between 0 and 64; these are returned as
        # exit codes between 128 and 192
        if [ ${prev_exit_code} -gt 128 -a ${prev_exit_code} -lt 192 ]; then
            local exit_status=$((128-prev_exit_code))" "$(kill -l ${prev_exit_code} 2>/dev/null || echo -n '?')
        fi
        PS1+=" ${Red}${exit_status}${ResetColour} "
    fi

    PS1+="${White}\\\$${ResetColour} "

    # Secondary prompt (continuation lines)
    PS2="${COL2}> ${ResetColour}"
    return $prev_exit_code
}
PROMPT_COMMAND=set_prompt_command
