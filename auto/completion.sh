#!/bin/bash

autocompletion_generate_options () {

    declare -a options=(
	"--argument1"
	"--argument2"
	"--no-argument1"
	"--no-argument2"
    )

    # Handle 'option'
    for option in ${options[@]}; do
	for argument in ${@:1:$(($#-1))}; do
	    if [[ "$argument" = "$option" ]]; then
		option=""
		break
	    fi
	done
	echo -n "$option" " "
    done
}

autocompletion () {

    local previous current

    if [[ $COMP_CWORD -gt 0 ]]; then
	current="${COMP_WORDS[-1]}"

	if [[ $COMP_CWORD -gt 1 ]]; then
	    previous="${COMP_WORDS[-2]}"
	fi
    fi
    
    case "$previous" in
	*)
	    options=$(autocompletion_generate_options ${COMP_WORDS[@]})
	    COMPREPLY=($(compgen -W "$options" -- "$current"));;
    esac
}

complete -F autocompletion ./script
