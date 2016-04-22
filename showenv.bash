function __ps1_showenv() {
    local _lang=$1
    local _var=''
    local _prefix=''
    local _venv=''
    local _root=
    if [[ "$_lang" == 'ruby' ]]; then
        _version=$RBENV_VERSION
    elif [[ $_lang == 'node' ]]; then
        _version=$NODENV_VERSION
    elif [[ $_lang == 'go' ]]; then
        _version=$GOENV_VERSION
    elif [[ $_lang == 'python' ]]; then
        _version=$PYENV_VERSION
    fi

    if [ -z $_version ]; then
        _version=$(__ps1_upsearch .${_lang}-version cat)
    else
        _prefix='*'
    fi

    if [ ! -z $_version ]; then
        eval "local _colour=\$$PS1_MODULE_SHOWENV_COLOUR"
        if [[ $_lang == 'python' ]] && [[ ! $_version =~ ^[0-9\.]+$ ]]; then
            if [ -z "$PYENV_ROOT" ]; then
                _root="${HOME}/.pyenv"
            else
                _root=$PYENV_ROOT
            fi
            _venv=$_version
            _version=$(basename `cat ${_root}/versions/${_venv}/lib/*/orig-prefix.txt 2>/dev/null` 2>/dev/null)
            if [ ! -z $_version ]; then
                echo "${_colour}${_lang}-${_version} ${_venv}"
            else
                echo "${_colour}${_lang} *${_venv}"
            fi
        else
            echo "${_prefix}${_colour}${_lang}-${_version}"
        fi
    fi
}
