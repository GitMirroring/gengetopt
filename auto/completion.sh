#!/bin/bash

autocomplete_with () {
    complete -F "$1" ./script
    return 124
}

autocomplete_loopback() {
    if [[ "${#COMPREPLY[@]}" -eq 1 ]]; then
	autocomplete_with "autocomplete"
    fi

    return 0
}

autocomplete_argument2_arg() {
    COMPREPLY=($(IFS=$' |'; compgen -W "2valueA | 2valueB" -- "$2"))

    autocomplete_loopback
}

autocomplete_argument3_arg() {
    COMPREPLY=($(IFS=$' |'; compgen -W "3valueA | 3valueB | 3valueC" -- "$2"))
}

autocomplete_option () {

    declare -a options=(
	"--argument1"
	"--argument2"
	"--argument3"
	"--no-argument1"
	"--no-argument2"
    )

    # Handle 'option'
    for option in ${options[@]}; do
	for argument in ${@:1}; do
	    if [[ "$argument" = "$option" ]]; then
		option=""
		break
	    fi
	done
	echo "$option"
    done
}

autocomplete () {
    
    # Handle 'argtype'
    case "$3" in
	"--argument1") return ;;
	"--argument2") autocomplete_with "autocomplete_argument2_arg"; return ;;
    esac

    # Handle 'argoptional'
    case "$3" in
	"--argument3") autocomplete_argument3_arg "$1" "$2" "$3" ;;
    esac

    # Handle 'option'
    local IFS=$'\n'
    COMPREPLY+=($(compgen -W "$(autocomplete_option ${COMP_WORDS[@]})" -- "$2"))
}

autocomplete_with autocomplete
