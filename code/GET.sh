#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022


source db.sh

g_index() {
    answer 200 "$(addTplParam 'TITLE' 'Hello World'; render 'index.sh')"
}

g_vulns() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login?page=/vulns"
    fi

    answer 200 "$(addTplParam 'TITLE' 'Vulns'; render 'vulns.sh')"
}

g_new() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login?page=/new"
    fi
    answer 200 "$(addTplParam 'TITLE' 'New'; render 'new.sh')"
}

g_login() {
    local page=$(echo "${GPARAMS[page]}" | sed -e "s/[^a-z0-9:\\/\\.]//g")
    if [ -n "$page" ]; then
        addTplParam 'PAGE' "?page=$page";
    fi

    answer 200 "$(addTplParam 'TITLE' 'Login'; render 'login.sh')"
}

g_logout() {
    delete_session "$(get_cookie 'session')"
    AUTHENTICATED=0
    setCookie "session" ""
    answer 200 "$(addTplParam 'TITLE' 'Login'; render 'login.sh')"
}

g_register() {
    answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')"
}

g_debug() {
    if [ $AUTHENTICATED -eq 0 ] || [ "$CLIENTIP" != "127.0.0.1" ]; then
        redirect "/login?page=/debug"
    fi
    answer 200 "$(addTplParam 'TITLE' 'Debug'; render 'debug.sh')"
}

g_vulns() {
    if [ $AUTHENTICATED -eq 1 ] || [ $ISBOT -eq 1 ]; then
        local public=0
    else
        local public=1
    fi

    local start="${GPARAMS[start]}"
    if [ -z "$start" ]; then
        start="0"
    fi

    declare -A VULNS=()
    declare -a VULNIDS=()
    for vuln in $(get_vulns "$public" "$start"); do
        local vid=$(echo "$vuln" | cut -d"|" -f1)
        local title=$(echo "$vuln" | cut -d"|" -f2)
        local cve=$(echo "$vuln" | cut -d"|" -f3)
        local uid=$(echo "$vuln" | cut -d"|" -f4)
        local user=$(echo "$vuln" | cut -d"|" -f5)
        VULNS+=(["${vid}_title"]="$title")
        VULNS+=(["${vid}_cve"]="$cve")
        VULNS+=(["${vid}_uid"]="$uid")
        VULNS+=(["${vid}_username"]="$user")

        debug "$vid $title $cve $uid $username"

        VULNIDS+=("$vid")
    done
    addTplParam 'VULNS' "$VULNS"
    addTplParam 'VULNIDS' "$VULNIDS"
    answer 200 "$(addTplParam 'TITLE' 'Vulns'; render 'vulns.sh')"
}

g_vuln() {
    local vuln=$(get_vuln "$1")
    addTplParam "vuln_vid" $(echo "$vuln" | cut -d"|" -f1)
    addTplParam "vuln_title" $(echo "$vuln" | cut -d"|" -f2)
    addTplParam "vuln_cve" $(echo "$vuln" | cut -d"|" -f3)
    addTplParam "vuln_content" $(echo "$vuln" | cut -d"|" -f4)
    addTplParam "vuln_uid" $(echo "$vuln" | cut -d"|" -f5)
    addTplParam "vuln_username" $(echo "$vuln" | cut -d"|" -f6)
    answer 200 "$(addTplParam 'TITLE' 'Vuln'; render 'vuln.sh')"
}

g_static() {
    addOutHdr "Expires" "$(date -d "$(date +"%a, %d %b %Y %H:%M:%S %Z") +5 min" +"%a, %d %b %Y %H:%M:%S %Z")"
    addOutHdr "Cache-Control" "max-age=300"
    if [ -f "./$RURL" ]
    then
        answer 200 "$(cat "./$RURL")"
    elif [ -d "./$RURL" ]
    then
        answer 200 "$(ls -lha "./$RURL")"
    else
        answer 404 "Forbidden"
    fi
}
