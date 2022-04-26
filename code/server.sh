#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

export PATH="$(pwd)/bin:$PATH"

source urls.sh
source utils.sh

pageTimeStart

declare -g CLIENTIP=""
declare -A INHDR=()
declare -a OUTHDR=(
    "Server: BashHTTP"
    "X-Frame-Options: sameorigin"
    "X-XSS-Protection: 1; prevent"
    "X-Content-Type: nosniff"
    "Content Type: text/html"
)
declare -A STATUS=(
   [200]="OK"
   [302]="Found"
   [403]="Forbidden"
   [404]="Not Found"
   [500]="Internal Server Error"
)
declare -A GPARAMS=()
declare -A PPARAMS=()
declare -A TPLPARAMS=()
declare -A MESSAGES=()
declare -A COOKIES=()


addMsg() {
    MESSAGES+=(["$1"]="$2")
}

debug() {
    echo "$(date), $SOCAT_PEERADDR $@" | tee -a "$LOGPATH" >&2
}

addOutHdr() {
    OUTHDR+=("$1: $2")
}

addInHdr() {
    local IFS=':'
    read -r -a p <<< "$1"
    if [ -n "${p[0]}" -a -n "${p[1]}" ]
    then
        if [ -n "${p[2]}" ]; then
            INHDR+=(["${p[0]}"]="${p[1]}:${p[2]}")
        else
            INHDR+=(["${p[0]}"]="${p[1]}")
        fi
    fi
}

addGParam() {
    local IFS='='
    read -r -a p <<< "$1"
    if [ -n "${p[0]}" -a -n "${p[1]}" ]
    then
        GPARAMS+=(["${p[0]}"]="${p[1]}")
    fi
}

addPParam() {
    local IFS='='
    read -r -a p <<< "$1"
    if [ -n "${p[0]}" -a -n "${p[1]}" ]
    then
        PPARAMS+=(["${p[0]}"]="${p[1]}")
    fi
}

setCookie() {
    COOKIES+=(["$1"]="$2")
}

addTplParam() {
    TPLPARAMS+=(["$1"]="$2")
}

parseArgs() {
    local IFS=' '
    read -r -a p <<< "$1"
    RMETH="${p[0]}"
    RURL="${p[1]}"
    RVER="${p[2]}"
    if [ -z "$RMETH" -o -z "$RURL" -o -z "$RVER" ]
    then
        exit 1
    fi
}

parseReqHdrs() {
    while read -r hdrLine; do
        hdrLine=${hdrLine%%$'\r'}
        if [ ! -n "$hdrLine" ]
        then
            break 
        fi
        addInHdr "$hdrLine"
    done
}

parseBody() {
    read -d '' -r -n "${INHDR['Content-Length']}" body
    if [ ! -n "$body" ]
    then 
        return 
    fi
    local IFS='&'
    read -r -a ps <<< "$body"
    for kv in "${ps[@]}"
    do
        addPParam "$kv"
    done
}

parseParams() {
    p=${RURL#*\?}
    local IFS='&'
    read -r -a ps <<< "$p"
    for kv in "${ps[@]}"
    do
        addGParam "$kv"
    done
}

parseRequest() {
    read -r httpLine
    if [ ! $? -eq 0 ]
    then
        exit 1
    fi
    httpLine=${httpLine%%$'\r'}
    debug "$httpLine"

    parseArgs "$httpLine"
    debug "$RMETH, $RURL, $RVER"

    parseReqHdrs

    if [ "$RMETH" = "GET" ]
    then 
        parseParams
    elif [ "$RMETH" = "POST" ]
    then 
        parseParams
        parseBody
    elif [ "$RMETH" = "HEAD" ]
    then 
        return 
    fi

    for mw in "${MIDDLEWARES[@]}"
    do 
        $mw
    done
}

matchURI() {
    local -n rs=$1
    debug "$rs"
    for r in "${!rs[@]}"
    do
        if [ -z "$r" ]
        then
            continue 
        fi
        if [[ "$RURL" =~ $r ]]
        then
            ${rs[$r]} "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
            return 
        fi
    done
    answer 404 "Not Found"
}

routeURI() {
    if [ "$RMETH" = "GET" ]
    then 
        matchURI GURLS
    elif [ "$RMETH" = "POST" ]
    then 
        matchURI PURLS
    fi
}

answer() {
    s="$1"
    st="${STATUS[$s]}"
    c="$2"
    echo "HTTP/1.0 $s $st"
    for h in "${OUTHDR[@]}"
    do
        echo "$h"
    done
    cookies=""
    for k in "${!COOKIES[@]}"
    do
        cookies="$k=${COOKIES[$k]}; $cookies"
    done
    if [ -n "$cookies" ]
    then
        echo "Set-Cookie: $cookies"
    fi
    if [ -n "$c" ]
    then
        echo "Content-Length: $(echo "$c"| wc -c)"
        echo
        echo "$c"
    else
        echo
        echo
    fi
    exit 0
}

error() {
    if [ $# -eq 1 ]
    then
        answer 500 "Internal Server Error, $1"
    else
        answer 500 "Internal Server Error"
    fi
    exit 1
}

doRender() {
    local t="$1"
    if [ ! -f "./templates/$t" ]
    then
        error
    fi
    for k in "${!TPLPARAMS[@]}"
    do
        if [ -z "$k" ]
        then
            continue 
        fi
        local v="${TPLPARAMS[$k]}"
        local -n r="$k"
        r="$v"
    done
    source "./templates/$t"
}

render() {
    doRender $*
}

includeTpl() {
    if [ -f "./templates/$1" ]
    then
        addTplParam "$1" "$(render $1)"
    fi 
}

redirect() {
    addOutHdr "Location" "$1"
    answer 302 ""
}

parseRequest
routeURI