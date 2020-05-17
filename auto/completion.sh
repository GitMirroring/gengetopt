#!/bin/bash

autocomplete_with () {
    complete -F "$1" ./script
    return 124
}

autocomplete_loopback () {
    if [[ "${#COMPREPLY[@]}" -eq 1 ]]; then
	autocomplete_with "autocomplete"
    fi

    return 0
}

autocomplete_argument2_arg () {
    COMPREPLY=($(IFS=$' |'; compgen -W "2valueA | 2valueB" -- "$2"))

    autocomplete_loopback
}

autocomplete_argument3_arg () {
    COMPREPLY=($(IFS=$' |'; compgen -W "3valueA | 3valueB | 3valueC" -- "$2"))
}

autocomplete_argument4_arg () {
    COMPREPLY=($(compgen -o dirnames -A directory -- "$2"))

    if [[ "${#COMPREPLY[@]}" -eq 1 ]]; then
	local dir="${COMPREPLY[0]}"
	COMPREPLY=($(compgen -o dirnames -A directory -- "$dir/"))

	if [[ "${#COMPREPLY[@]}" -le 1 ]]; then
	    COMPREPLY=("$dir")
	fi
    fi

    autocomplete_loopback
}

autocomplete_unnamed () {
    compopt -o filenames
    COMPREPLY=($(compgen -A file -- "$2"))
}

autocomplete_option () {

    # Handle 'option'
    declare -A options=(
	["--argument1"]=1
	["--argument2"]=1
	["--argument3"]=1
	["--argument4"]=0
	["--no-argument1"]=0
	["--no-argument2"]=1
	["--no-argument3"]=2
	["--prerequesite1"]=1
	["--prerequesite2"]=1
	["--prerequesite3"]=2
	["--prerequesite4"]=2
	["--prerequesite5"]=1
    )

    # Handle 'mode'
    declare -a modes=(
	"modeA"
	"modeB"
    )

    declare -A modeA=(
	["--modeA-1"]=0
	["--modeA-2"]=1
	["--modeA-3"]=2
    )

    declare -A modeB=(
	["--modeB-1"]=1
	["--modeB-2"]=2
    )

    for argument in "${@:1}"; do
	for mode in "${modes[@]}"; do
	    local -n modearray="${mode}"
	    if [[ "${modearray[$argument]+_}" ]]; then
		for othermode in "${modes[@]}"; do
		    if [[ "$othermode" != "$mode" ]]; then
			unset $othermode
			declare -A $othermode
		    fi
		done
		break
	    fi
	done
    done

    for mode in "${modes[@]}"; do
	local -n modearray="${mode}"
	for option in "${!modearray[@]}"; do
	    options["$option"]+="${modearray[$option]}"
	done
    done

    # Handle 'group'
    declare -a groups=(
	"groupA"
	"groupB"
    )

    declare -A groupA=(
	["--groupA-1"]=0
	["--groupA-2"]=1
	["--groupA-3"]=2
    )

    declare -A groupB=(
	["--groupB-1"]=1
	["--groupB-2"]=2
    )

    for argument in "${@:1}"; do
	for group in "${groups[@]}"; do
	    local -n grouparray="${group}"
	    if [[ "${grouparray[$argument]+_}" ]]; then
		local -i multiple="${grouparray[$argument]}"
		unset grouparray
		declare -A grouparray=(["$argument"]="$multiple")
	    fi
	done
    done

    for group in "${groups[@]}"; do
	local -n grouparray="${group}"
	for option in "${!grouparray[@]}"; do
	    options["$option"]+="${grouparray[$option]}"
	done
    done

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
	if [[ "${options[$argument]+_}" ]]; then
	    # 0 is infinite
	    if [[ "${options[$argument]}" -eq 1 ]]; then
		unset options["$argument"]
	    elif [[ "${options[$argument]}" -gt 1 ]]; then
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
	"--argument4") autocomplete_with autocomplete_argument4_arg; return ;;
    esac

    # Handle 'argoptional' and 'unnamed'
    case "$3" in
	"--argument3") autocomplete_argument3_arg "$1" "$2" "$3" ;;
	*) autocomplete_unnamed "$1" "$2" "$3" ;;
    esac

    # Handle 'option'
    local IFS=$'\n'
    COMPREPLY+=($(compgen -W "$(autocomplete_option ${COMP_WORDS[@]})" -- "$2"))
}

autocomplete_with autocomplete
