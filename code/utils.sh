#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

# https://stackoverflow.com/a/1683850/8957548
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}

# https://stackoverflow.com/a/37840948/234234d
get_cookie() {
    local cookies="${INHDR[Cookie]}"
    local IFS=';'
    read -r -a cks <<< "$cookies"

    for ck in "${cks[@]}"
    do
        local IFS='='
        read -r -a c <<< "$ck"
        if [ "$1" = "$(trim ${c[0]})" ]
        then
            echo "$(trim ${c[1]})"
            break
        fi
    done
}

# https://stackoverflow.com/a/37840948/8957548
urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# https://gist.github.com/cdown/1163649
urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%s' "$c" | xxd -p -c1 |
                   while read c; do printf '%%%s' "$c"; done ;;
        esac
    done
}

# https://stackoverflow.com/a/17841619/8957548
join_by() { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

echo "I_H4V3_R3AD_TH3_SOURCE_AND_WILL_INCLUDE_THIS_TOKEN" > /dev/null

# https://stackoverflow.com/questions/12873682/short-way-to-escape-html-in-bash/52570455#52570455
function htmlEscape () {
    s=${1//&/&amp;}
    s=${s//</&lt;}
    s=${s//>/&gt;}
    s=${s//'"'/&quot;}
    echo $s
}

serverTime() {
    date
}

pageTimeStart() {
    declare -g pageTimeStartS=$(date +%s)
    declare -g pageTimeStartNS=$(date +%N)
}
pageTime() {
    nowS=$(date +%s)
    nowNS=$(date +%N)
    diffS=$((nowS - pageTimeStartS))
    if [ $diffS -eq 0 ]; then 
        diffNS=$((nowNS - pageTimeStartNS))
        echo "$diffNS ns"
    else
        echo "$diffS s"
    fi
}