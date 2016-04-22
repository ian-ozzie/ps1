# mashup of bash-git-prompt/gitprompt.sh and https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh

# bash/zsh git prompt support
__ps1_git () {
    local pcmode=no
    local detached=no
    local ps1pc_start='\u@\h:\w '
    local ps1pc_end='\$ '
    local printf_format=' (%s)'

    case "$#" in
        0|1)    printf_format="${1:-$printf_format}"
        ;;
        *)    return
        ;;
    esac

    local git_command="command git"
    local repo_info rev_parse_exit_code
    repo_info="$(${git_command} rev-parse --git-dir --is-inside-git-dir \
        --is-bare-repository --is-inside-work-tree \
        --short HEAD 2>/dev/null)"
    rev_parse_exit_code="$?"

    if [ -z "$repo_info" ]; then
        if [ $pcmode = yes ]; then
            #In PC mode PS1 always needs to be set
            PS1="$ps1pc_start$ps1pc_end"
        fi
        return
    fi

    local short_sha
    if [ "$rev_parse_exit_code" = "0" ]; then
        short_sha="${repo_info##*$'\n'}"
        repo_info="${repo_info%$'\n'*}"
    fi
    local inside_worktree="${repo_info##*$'\n'}"
    repo_info="${repo_info%$'\n'*}"
    local bare_repo="${repo_info##*$'\n'}"
    repo_info="${repo_info%$'\n'*}"
    local inside_gitdir="${repo_info##*$'\n'}"
    local g="${repo_info%$'\n'*}"

    local r=""
    local b=""
    local step=""
    local total=""
    if [ -d "$g/rebase-merge" ]; then
        read b 2>/dev/null <"$g/rebase-merge/head-name"
        read step 2>/dev/null <"$g/rebase-merge/msgnum"
        read total 2>/dev/null <"$g/rebase-merge/end"
        if [ -f "$g/rebase-merge/interactive" ]; then
            r="|REBASE-i"
        else
            r="|REBASE-m"
        fi
    else
        if [ -d "$g/rebase-apply" ]; then
            read step 2>/dev/null <"$g/rebase-apply/next"
            read total 2>/dev/null <"$g/rebase-apply/last"
            if [ -f "$g/rebase-apply/rebasing" ]; then
                read b 2>/dev/null <"$g/rebase-apply/head-name"
                r="|REBASE"
            elif [ -f "$g/rebase-apply/applying" ]; then
                r="|AM"
            else
                r="|AM/REBASE"
            fi
        elif [ -f "$g/MERGE_HEAD" ]; then
            r="|MERGING"
        elif [ -f "$g/CHERRY_PICK_HEAD" ]; then
            r="|CHERRY-PICKING"
        elif [ -f "$g/REVERT_HEAD" ]; then
            r="|REVERTING"
        elif [ -f "$g/BISECT_LOG" ]; then
            r="|BISECTING"
        fi

        if [ -n "$b" ]; then
            :
        elif [ -h "$g/HEAD" ]; then
            # symlink symbolic ref
            b="$(${git_command} symbolic-ref HEAD 2>/dev/null)"
        else
            local head=""
            if ! read head 2>/dev/null <"$g/HEAD"; then
                if [ $pcmode = yes ]; then
                    PS1="$ps1pc_start$ps1pc_end"
                fi
                return
            fi
            # is it a symbolic ref?
            b="${head#ref: }"
            if [ "$head" = "$b" ]; then
                detached=yes
                b="$(
                case "${PS1_MODULE_GIT_PS1_DESCRIBE_STYLE-}" in
                (contains)
                    $git_command describe --contains HEAD ;;
                (branch)
                    $git_command describe --contains --all HEAD ;;
                (describe)
                    $git_command describe HEAD ;;
                (* | default)
                    $git_command describe --tags --exact-match HEAD ;;
                esac 2>/dev/null)" ||

                b="$short_sha..."
                b="($b)"
            fi
        fi
    fi

    if [ -n "$step" ] && [ -n "$total" ]; then
        r="$r $step/$total"
    fi

    local w=""
    local i=""
    local s=""
    local u=""
    local c=""
    local p=""

    if [ "true" = "$inside_gitdir" ]; then
        if [ "true" = "$bare_repo" ]; then
            c="BARE:"
        else
            b="GIT_DIR!"
        fi
    elif [ "true" = "$inside_worktree" ]; then
        $git_command diff --no-ext-diff --quiet --exit-code || w="*"
        if [ -n "$short_sha" ]; then
            $git_command diff-index --cached --quiet HEAD -- || i="+"
        else
            i="#"
        fi
    fi

    local z="${PS1_MODULE_GIT_PS1_STATESEPARATOR-" "}"

    local f="$w$i$s$u"
    local gitstring="$c${b##refs/heads/}${f:+$z$f}$r$p"

    if [ $pcmode = yes ]; then
        if [[ -n ${ZSH_VERSION-} ]]; then
            gitstring=$(printf -- "$printf_format" "$gitstring")
        else
            printf -v gitstring -- "$printf_format" "$gitstring"
        fi
        PS1="$ps1pc_start$gitstring$ps1pc_end"
    else
        printf -- "$printf_format" "$gitstring"
    fi
}

__ps1_count_lines() { echo "$1" | egrep -c "^$2" ; }
__ps1_all_lines() { echo "$1" | grep -v "^$" | wc -l ; }
__ps1_git_fancy_replaceSymbols() {
    local VALUE=${1//_AHEAD_/${PS1_MODULE_GIT_PROMPT_SYMBOLS_AHEAD}}
    local VALUE1=${VALUE//_BEHIND_/${PS1_MODULE_GIT_PROMPT_SYMBOLS_BEHIND}}
    local VALUE2=${VALUE1//_NO_REMOTE_TRACKING_/${PS1_MODULE_GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING}}

    echo ${VALUE2//_PREHASH_/${PS1_MODULE_GIT_PROMPT_SYMBOLS_PREHASH}}
}

__ps1_git_fancy () {
    local repo=`command git rev-parse --show-toplevel 2> /dev/null`

    if [[ ! -e "$repo" ]]; then
        return
    fi

    if [[ -d "$repo/.git" ]]; then
        local FETCH_HEAD="$repo/.git/FETCH_HEAD"
    elif [[ -f "$repo/.git" ]]; then
        local FETCH_HEAD="$repo/$(cat $repo/.git | grep '^gitdir:' | awk '{ print $2 }')/FETCH_HEAD"
    fi

    if [[ ! -e "$FETCH_HEAD"  ||  -e `find "$FETCH_HEAD" -mmin +5` ]]; then
        if [[ -n $(command git remote show) ]]; then
            (
                __ps1_async_run "git fetch --quiet"
            ) && touch "$FETCH_HEAD"
        fi
    fi

    local -a git_status_fields
    git_status_fields=($("${HOME}/.ps1/bash-git-prompt/gitstatus.sh" 2>/dev/null))

    local GIT_BRANCH=$(__ps1_git_fancy_replaceSymbols ${git_status_fields[0]})
    local GIT_REMOTE="$(__ps1_git_fancy_replaceSymbols ${git_status_fields[1]})"
    if [[ "." == "$GIT_REMOTE" ]]; then
        unset GIT_REMOTE
    fi

    local GIT_UPSTREAM="${git_status_fields[2]}"
    if [[ -z "${__GIT_PROMPT_SHOW_UPSTREAM}" || "^" == "$GIT_UPSTREAM" ]]; then
        unset GIT_UPSTREAM
    else
        GIT_UPSTREAM="${GIT_PROMPT_UPSTREAM//_UPSTREAM_/${GIT_UPSTREAM}}"
    fi

    local GIT_STAGED=${git_status_fields[3]}
    local GIT_CONFLICTS=${git_status_fields[4]}
    local GIT_CHANGED=${git_status_fields[5]}
    local GIT_UNTRACKED=${git_status_fields[6]}
    local GIT_STASHED=${git_status_fields[7]}
    local GIT_CLEAN=${git_status_fields[8]}

    local STATUS="${PS1_MODULE_GIT_PROMPT_BRANCH}${GIT_BRANCH}${ResetColour}"

    __chk_gitvar_status() {
        local v
        if [[ "x$2" == "x-n" ]] ; then
            v="$2 \"\$GIT_$1\""
        else
            v="\$GIT_$1 $2"
        fi
        if eval "test $v" ; then
            if [[ $# -lt 2 || "$3" != '-' ]]; then
                __add_status "\$PS1_MODULE_GIT_PROMPT_$1\$GIT_$1\$PS1_MODULE_GIT_SYMBOL_$1\$ResetColour"
            else
                __add_status "\$PS1_MODULE_GIT_PROMPT_$1\$PS1_MODULE_GIT_SYMBOL_$1\$ResetColour"
            fi
        fi
    }

    # __add_status SOMETEXT
    __add_status() {
        eval "STATUS=\"$STATUS$1\""
    }

    __chk_gitvar_status 'REMOTE'     '-n'
    __add_status        "|"
    __chk_gitvar_status 'STAGED'     '-ne 0'
    __chk_gitvar_status 'CONFLICTS'  '-ne 0'
    __chk_gitvar_status 'CHANGED'    '-ne 0'
    __chk_gitvar_status 'UNTRACKED'  '-ne 0'
    __chk_gitvar_status 'STASHED'    '-ne 0'
    __chk_gitvar_status 'CLEAN'      '-eq 1'   -
    __add_status        "$ResetColour$GIT_PROMPT_SUFFIX"

    echo $STATUS
}
