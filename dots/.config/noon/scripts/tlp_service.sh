#!/bin/bash

case "$1" in
    get)
        mode=$(tlp-stat -m | head -n1 | tr '[:upper:]' '[:lower:]')
        if [[ $mode == bat* ]]; then
            echo "bat"
        else
            echo "ac"
        fi
        ;;
    set)
        if [[ "$2" == "bat" ]]; then
            pkexec tlp bat
        elif [[ "$2" == "ac" ]]; then
            pkexec tlp ac
        fi
        ;;
    *)
        echo "Usage: $0 {get|set} [bat|ac]"
        exit 1
        ;;
esac
