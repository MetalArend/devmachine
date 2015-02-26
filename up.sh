#!/usr/bin/env bash

# Convert to linux line-endings for cygwin
case "$(uname)" in
    CYGWIN*)
        echo "Convert to LF files"
        find "${CWD}/../" -name "*.sh" -type f -exec sed -i.bak 's/\r$//g' {} \;
        ;;
    *)
        ;;
esac

(cd ./vagrant; vagrant destroy; vagrant up)