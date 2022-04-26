#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022

if [ -z "${QUERYFILE}" ];
then
    declare -g QUERYFILE=$(mktemp)
fi

valid_session() {
    clear_query
    session=$(echo "$1" | sed -e "s/[^a-f0-9]//g")
    if [ -z "$session" ]; then
        return 1
    fi
    prepare_statement "session" "$session"
    local data=$(query "SELECT users.uid, users.username FROM users, sessions WHERE sessions.uid == users.uid and sessions.session = :session LIMIT 1")
    declare -g USERUID=$(echo "$data" | cut -d'|' -f1)
    declare -g USERNAME=$(echo "$data" | cut -d'|' -f2)
    if [ -z "$USERNAME" ]; then
        return 1
    else
        return 0
    fi
}

delete_session() {
    clear_query
    session=$(echo "$1" | sed -e "s/[^a-f0-9]//g")
    prepare_statement "session" "$session"
    query "DELETE FROM sessions WHERE session = :session"
}

clear_query() {
    > "$QUERYFILE"
}

prepare_statement() {
    escaped_param=$(echo "$2" | tr -d "'" 2>/dev/null | tr -d '\' 2>/dev/null | tr -cd "[:print:]" 2>/dev/null)
    echo ".param set :$1 '${escaped_param}'" >> "$QUERYFILE" 
    return 0
}

query() {
    echo "$1" >> "$QUERYFILE"
    sqlite3 "$DBFILE" < "$QUERYFILE"
    return $?
}


init_db() {
    if [ ! -f "$DBDIR/db.sqlite" ]; then
        sqlite3 "$DBFILE" "CREATE TABLE users(uid INTEGER PRIMARY KEY AUTOINCREMENT, username text UNIQUE, password text, role text)"
        sqlite3 "$DBFILE" "INSERT INTO users (username, password) values ('admin', 'admin');"

        sqlite3 "$DBFILE" "CREATE TABLE sessions(uid INTEGER, session text UNIQUE)"
        sqlite3 "$DBFILE" "CREATE TABLE vulns(vid INTEGER PRIMARY KEY AUTOINCREMENT, title text, cve text UNIQUE, content text, uid INTEGER, public INTEGER)"
        sqlite3 "$DBFILE" "INSERT INTO vulns (title, cve, content, uid, public) VALUES ('Demo+Vuln', 'CVE-1337-1333337', 'Demo+Content', 1, 1);"
    fi
}


user_exists() {
    clear_query
    prepare_statement "username" "$1"
    if [ $(query "SELECT COUNT(uid) FROM users WHERE username = :username") == "0" ]; then
        return 1
    else
        return 0
    fi
}

user_login() {
    clear_query
    prepare_statement "username" "$1"
    prepare_statement "password" "$2"
    if [ $(query "SELECT COUNT(uid) FROM users WHERE username = :username and password = :password") == "0" ]; then
        return 1
    else
        return 0
    fi
}

create_user() {
    clear_query
    prepare_statement "username" "$1"
    prepare_statement "password" "$2"
    query "INSERT INTO users (username, password) values (:username, :password);"
}

create_vuln() {
    clear_query
    prepare_statement "title" "$1"
    prepare_statement "cve" "$2"
    prepare_statement "text" "$3"
    prepare_statement "public" "$4"
    prepare_statement "uid" "$USERUID"
    return $(query "INSERT INTO vulns (title, cve, content, public, uid) values (:title, :cve, :text, :public, :uid);")
}

get_vulns() {
    clear_query
    prepare_statement "public" "$1"
    query "SELECT vulns.vid, vulns.title, vulns.cve, users.uid, users.username FROM vulns, users WHERE vulns.uid == users.uid AND vulns.public >= :public AND vulns.vid >= $2 ORDER BY vulns.vid DESC"
}

get_vuln() {
    clear_query
    prepare_statement "vid" "$1"
    query "SELECT vulns.vid, vulns.title, vulns.cve, vulns.content, users.uid, users.username FROM vulns, users WHERE vulns.uid == users.uid AND vulns.vid == :vid"
}

get_users() {
    clear_query
    query "SELECT users.username FROM sessions, users WHERE sessions.uid == users.uid"
}

create_session() {
    clear_query
    prepare_statement "username" "$1"
    uid=$(query "SELECT uid from users where username = :username")

    clear_query
    session=$(echo "$1" | sha256sum | cut -d' ' -f 1)
    prepare_statement "uid" "$uid"
    prepare_statement "session" "$session"
    query "INSERT INTO sessions (uid, session) values (:uid, :session)" > /dev/null

    echo "$session"
}

init_db