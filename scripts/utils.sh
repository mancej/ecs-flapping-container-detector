#!/usr/bin/env bash

die() {
    e_error "$1"
    exit 1
}

############## FORMATTING UTILS #################

# Useful formatting functions
reset=$(tput -T xterm-color sgr0)
red=$(tput -T xterm-color setaf 1)
green=$(tput -T xterm-color setaf 2)
blue=$(tput -T xterm-color setaf 4)

e_arrow() {
    printf "➜ %s\n" "$@"
}

e_success() {
     printf "${green}✔ %s${reset}\n" "$@"
}

e_notify() {
    printf "${blue}➜ %s${reset}\n" "$@"
}

e_error() {
    printf "${red}✖ %s${reset}\n" "$@"
}
