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

    declare -A options=(
	["--argument1"]=1
	["--argument2"]=1
	["--argument3"]=1
	["--no-argument1"]=1
	["--no-argument2"]=1
	["--prerequesite1"]=1
	["--prerequesite2"]=1
	["--prerequesite3"]=2
	["--prerequesite4"]=2
	["--prerequesite5"]=1
    )

    # Handle 'dependon'
    for argument in "${@:1}"; do
	case "$argument" in
	    "--prerequesite1") options["--depend-on1"]=1 ;;
	    "--prerequesite2") options["--depend-on2"]=2 ;;
	    "--prerequesite3") options["--depend-on3"]=1 ;;
	    "--prerequesite4") options["--depend-on4"]=2 ;;
	    "--prerequesite5") options["--depend-on5"]=1 ;;
	    "--depend-on5") options["--depend-on6"]=1 ;;
	esac
    done

    # Handle 'multiple'
    for argument in "${@:1}"; do
	if [[ "${options[$argument]}+_" ]]; then
	    if [[ "${options[$argument]}" -le 1 ]]; then
		unset options["$argument"]
	    else
		options["$argument"]=$((${options[$argument]}-1))
	    fi
	fi
    done

    # Handle 'option'
    for option in "${!options[@]}"; do
	echo "$option"
    done
}

autocomplete () {
    
    # Handle 'argtype'
    case "$3" in
	"--argument1") return ;;
	"--argument2") autocomplete_with autocomplete_argument2_arg; return ;;
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
