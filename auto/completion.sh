#!/bin/bash

autocomplete_with () {
    complete -F "$1" ./script
    return 124
}

autocomplete_loopback () {
    if [[ "${#COMPREPLY[@]}" -eq 1 ]]; then
	autocomplete_with autocomplete
    fi

    return 0
}

autocomplete_argument2_arg () {
    COMPREPLY=($(IFS=$'|'; compgen -W "2valueA|2valueB" -- "$2"))

    autocomplete_loopback
}

autocomplete_argument3_arg () {
    COMPREPLY=($(IFS=$'|'; compgen -W "3valueA|3valueB|3valueC" -- "$2"))
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
	["-x"]=0
	["-y"]=1
	["-z"]=2
	["--prerequesite1"]=1
	["--prerequesite2"]=1
	["--prerequesite3"]=2
	["--prerequesite4"]=2
	["--prerequesite5"]=1
	["--depend-on1"]=1
	["--depend-on2"]=2
	["--depend-on3"]=1
	["--depend-on4"]=2
	["--depend-on5"]=1
	["--depend-on6"]=1
    )

    declare -A short=(
	["-a"]="--no-argument1"
	["-b"]="--no-argument2"
	["-c"]="--no-argument3"

	["-p"]="--prerequesite1"
	["-d"]="--depend-on1"
    )

    declare -A long2short=(
	["--no-argument1"]="-a"
	["--no-argument2"]="-b"
	["--no-argument3"]="-c"

	["--prerequesite1"]="-p"
	["--depend-on1"]="-d"
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

    for mode in "${modes[@]}"; do
	for argument in "${@}"; do
	    local -n modearray="${mode}"
	    if [[ -v "modearray[$argument]" ]]; then
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

    for group in "${groups[@]}"; do
	for argument in "${@}"; do
	    local -n grouparray="${group}"
	    if [[ -v "grouparray[$argument]" ]]; then
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
    declare -A dependon=(
	["--prerequesite1"]="--depend-on1"
	["--prerequesite2"]="--depend-on2"
	["--prerequesite3"]="--depend-on3"
	["--prerequesite4"]="--depend-on4"
	["--prerequesite5"]="--depend-on5"
	["--depend-on5"]="--depend-on6"
    )

    for argument in "$@"; do
	for dependent in "${!dependon[@]}"; do
	    if [[ "$argument" = "$dependent" ]]; then
		dependon["$argument"]=""
	    elif [[ -v "short[$argument]" ]]; then
		if [[ "${short[$argument]}" = "$dependent" ]]; then
		    dependon["${short[$argument]}"]=""
		fi
	    fi
	done
    done

    for unmet in "${!dependon[@]}"; do
	if [[ -n "${dependon[$unmet]}" ]]; then
	    unset options["${dependon[$unmet]}"]

	    for option in "${!short[@]}"; do
		if [[ "${short[$option]}" = "${dependon[$unmet]}" ]]; then
		    unset short["$option"]
		fi
	    done
	fi
    done

    # Handle 'multiple'
    for argument in "$@"; do
	local shortarg=""

	if [[ -v "short[$argument]" ]]; then
	    shortarg="$argument"
	    argument="${short[$argument]}"
	elif [[ -v "long2short[$argument]" ]]; then
	    shortarg="${long2short[$argument]}"
	fi

	if [[ -v "options[$argument]" ]]; then
	    # 0 is infinite
	    if [[ "${options[$argument]}" -eq 1 ]]; then
		unset options["$argument"]
		if [[ -n "$shortarg" ]]; then
		    unset short["$shortarg"]
		fi
	    elif [[ "${options[$argument]}" -gt 1 ]]; then
		options["$argument"]=$((${options[$argument]}-1))
	    fi
	fi
    done

    echo "${!options[@]} ${!short[@]}"
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
    COMPREPLY+=($(compgen -W "$(IFS=$' '; autocomplete_option ${COMP_WORDS[@]:1})" -- "$2"))
}

autocomplete_with autocomplete
