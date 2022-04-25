#!/bin/bash

for k in "${!MESSAGES[@]}"
do
    type="$k"
    msg="${MESSAGES[$k]}"
    echo "<div class='alert alert-$type' role='$type'>$(htmlEscape "$msg")</div>"
done