#!/usr/bin/env bash

# Check current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Convert to linux line-endings for cygwin
case "$(uname)" in
    CYGWIN*)
        echo "Convert to LF files"
        find "${CWD}/" -name "*.sh" -type f -exec sed -i.bak 's/\r$//g' {} \;
        ;;
    *)
        ;;
esac