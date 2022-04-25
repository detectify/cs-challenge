#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

source db.sh

p_index() {
    redirect "/"
}

p_login() {
    if [ $AUTHENTICATED -eq 1 ]; then
        redirect "/"
    fi

    local username="${PPARAMS[username]}"
    local password="${PPARAMS[password]}"

    if [ -z "$username" -o -z "$password" ]
    then
        addMsg "warning" "Not all fields were provided."
        answer 200 "$(addTplParam 'TITLE' 'Login'; render 'login.sh')"
    fi

    if ! user_login "$username" "$password"; then 
        addMsg "warning" "Wrong credentials."
        answer 200 "$(addTplParam 'TITLE' 'Login'; render 'login.sh')"
    fi

    sessiontoken=$(create_session "$username")

    USERNAME="$username"
    AUTHENTICATED=1

    addMsg "success" "Login successful!"

    setCookie "session" "$sessiontoken"

    local redirTarget="${GPARAMS[page]}"
    if [ -z "$redirTarget" ]; then 
        redirTarget="/vulns"
    fi
    redirect "$redirTarget"
}

p_new() {
    if [ $AUTHENTICATED -eq 0 ]; then
        redirect "/login?page=/new"
    fi

    local title="${PPARAMS[title]}"
    local cve="${PPARAMS[cve]}"
    local description="${PPARAMS[description]}"
    local public="${PPARAMS[public]}"

    if [ -z "$title" -o -z "$cve" -o -z "$description" ]
    then
        addMsg "warning" "Not all fields were provided."
        answer 200 "$(addTplParam 'TITLE' 'New'; render 'new.sh')"
    fi

    if [[ ! "$cve" =~ ^CVE-[0-9]{4}-[0-9]{4,7}$ ]]
    then
        addMsg "warning" "Invalid CVE-ID"
        answer 200 "$(addTplParam 'TITLE' 'New'; render 'new.sh')"
    fi

    if [ -n "$public" -a "$public" == "on" ]; then 
        public=1
    else
        public=0
    fi

    create_vuln "$title" "$cve" "$description" "$public"
    if [ $? -eq 1 ]; then 
        addMsg "warning" "Failed to add vulnerability - Does it already exist?"
        answer 200 "$(addTplParam 'TITLE' 'New'; render 'new.sh')"
    fi

    addMsg "success" "Successfully created submission!"
    answer 200 "$(addTplParam 'TITLE' 'New'; render 'new.sh')"
}

p_register() {
    if [ $AUTHENTICATED -eq 1 ]; then
        redirect "/"
    fi

    local username="${PPARAMS[username]}"
    local password="${PPARAMS[password]}"
    local password_repeat="${PPARAMS[password_repeat]}"

    if [ -z "$username" -o -z "$password" -o -z "$password_repeat" ]
    then
        addMsg "warning" "Not all fields were provided."
        answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')"
    fi

    if [[ ! "$username" =~ ^[a-zA-Z0-9]+$ ]] || [[ ! "$password" =~ ^[a-zA-Z0-9]+$ ]]
    then
        addMsg "warning" "invalid usernames or password"
        answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')"
    fi

    if [ ! "$password" == "$password_repeat" ]
    then
        addMsg "warning" "Passwords do not match"
        answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')"
    fi

    if user_exists "$username"; then 
        addMsg "warning" "User already exists"
        answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')"
    fi

    if ! create_user "$username" "$password"; then
        addMsg "warning" "Failed to create user :-/"
        answer 200 "$(addTplParam 'TITLE' 'Register'; render 'register.sh')"
    fi

    addMsg "success" "Successfully signed up as $username!"

    answer 200 "$(addTplParam 'TITLE' 'Login'; render 'login.sh')"
}