#!/bin/bash
# Written by Sebastian Neef (@gehaxelt / neef.it), 2022


source handlers.sh
source middlewares.sh

declare -A PURLS=(
    ['^/register$']=p_register
    ['^/login']=p_login
    ['^/new$']=p_new
    ['^/$']=p_index
)

declare -A GURLS=(
    ['^/static(.*)$']=g_static
    ['^/login']=g_login
    ['^/logout$']=g_logout
    ['^/register$']=g_register
    ['^/vuln/(.*)']=g_vuln
    ['^/vulns']=g_vulns
    ['^/new$']=g_new
    ['^/debug$']=g_debug
    ['^/$']=g_index
)