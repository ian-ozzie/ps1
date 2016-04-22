function __ps1_upsearch {
    local searchdir="`pwd`/"
    local foundcmd=${2:-echo}
    while [ ! -z "${searchdir}" ]; do
        searchdir="${searchdir%/*}"
        test -e "$searchdir/$1" && $foundcmd "$searchdir/$1" && return
    done
}

function __ps1_versearch {
    local searchdir="`pwd`/"
    while [ ! -z "${searchdir}" ]; do
        searchdir="${searchdir%/*}";
        if [ $(ls -1 ${searchdir}/.*-version 2>/dev/null | wc -l) -eq 1 ]; then
            local file=$(basename `ls -1 $searchdir/.*-version`)
            local lang=${file%-*}
            local ver=$(cat $searchdir/$file)
            if [[ $ver =~ ^[0-9\.]+$ ]]; then
                echo "$lang-$ver" && return
            elif [ $lang == 'python' ]; then
                local venv=$ver
                ver=$(basename `cat ${PYENV_ROOT}/versions/${venv}/lib/*/orig-prefix.txt 2>/dev/null` 2>/dev/null)
                if [ -n $ver ]; then
                    echo "$lang-$ver $venv" && return
                fi
            fi
        fi
    done
}

function __ps1_async_run() {
    {
        if [ -n $MTYPE ]; then
            case $MTYPE in
                Darwin|Linux)
                    echo "$1 &> /dev/null" | at now &> /dev/null ;;
                *)
                    return ;;
            esac
        fi
    }
}
