#!/usr/bin/env bash

# Smiley return for command exit feedback
__ps1_smiley () {
    if [[ $1 -eq 0 ]]; then
        if [ -n "${2-}" ]; then
            echo "$2:)$4";
        else
            echo ":)";
        fi
        return;
    else
        if [ -n "${3-}" ]; then
            echo "$3:($4";
        else
            echo ":(";
        fi
        return;
    fi
}
