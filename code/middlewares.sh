#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

is_authenticated() {
    if valid_session "$(get_cookie 'session')"; then
        AUTHENTICATED=1
        return 0
    else
        AUTHENTICATED=0
        return 1
    fi
}

is_admin() {
    if [[ "$USER" =~ "admin" && -n "$DEBUG" ]]
    then
        ADMIN=1
    else
        ADMIN=0
    fi
}

clientip() {
    for kv in "${!INHDR[@]}"
    do
        if [[ "${kv,,}" =~ x-forwarded-ip || "${kv,,}" =~ x-forwarded-for ]]; then
            CLIENTIP=$(echo "${INHDR[$kv]}" | cut -d' ' -f2)
        fi
    done
}

is_bot() {
    ISBOT=0
    for kv in "${!INHDR[@]}"
    do
        if [[ "${kv}" =~ User-Agent && "${INHDR[$kv]}" =~ (google|bing|yandex) ]]; then
            ISBOT=1
        fi
    done
}

host() {
    for kv in "${!INHDR[@]}"
    do
        if [[ "${kv}" =~ Host ]]; then
            HOST=$(trim "${INHDR[$kv]}")
        fi
    done

    host_ok=0
    for h in "${ALLOWED_HOSTS[@]}"; do
        if [[ $HOST == $h ]]; then
            host_ok=1
        fi
    done

    if [ "$host_ok" -eq 0 ]; then
        answer 500 "Wrong HOST value"
    fi
}

declare -a MIDDLEWARES=(
    host
    clientip
    is_authenticated
    is_admin
    is_bot
)