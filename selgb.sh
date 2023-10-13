#!/bin/sh

# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
#   Author: Alexander Klimetschek, https://github.com/alexkli, https://unix.stackexchange.com/a/415155
function select_option {
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    cursor_blink_on

    return $selected
}

# -------------- select git branch code --------------
# Author: Ethan Franks, https://github.com/ethanfranks

# color constants for echo output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
DCYAN='\033[38;5;24m'
NC='\033[0m'

# loop through remotes and add any with fetch permission to array
strArr=(`git remote -v`)
repos=(local)
for i in "${!strArr[@]}"
	do
		var=${strArr[`expr $i + 2`]}
		if [ "$var" == "(fetch)" ]
		then
			repos+=(${strArr[$i]})
		fi
	done

# initialize globally available branches array
branches=()
select_repo() {
    # empty the branches array upon each call
    # necessary for proper "back" selection functionality
    branches=()

    # prompt user for repo choice
    echo "${CYAN}Select repo:${NC}"
    select_option "${repos[@]}"
    choice=$?

    if [ "$choice" -eq 0 ]
        # if user selects "local" repo add local branches to branches array
    	  then
            branchStr="`git branch`"
            parsedBranchStr="${branchStr//\*/ }"
    		    branches+=($parsedBranchStr "${YELLOW}*** new branch ***${NC}")
    	  # if user selects a remote repo add remote branches to branches array
        else
            branchStr="`git branch --remote --list ${repos[$choice]}/*`"
            branchStrArr=($branchStr)
            parsedBranchStr="${branchStrArr[@]:3}"
    	  	  branches+=($parsedBranchStr)
    	  fi

    branches+=("${DCYAN}<----- back ------${NC}")
    select_branch
}

select_branch() {
    # prompt user for branch choice
    echo "${CYAN}Select branch:${NC}"
    select_option "${branches[@]}"
    branchChoice=$?

    if [ "$choice" -eq 0 ]
        # local repo control flow
        then
            if [ "${branches[$branchChoice]}" == "${YELLOW}*** new branch ***${NC}" ]
                then
                    read -p "Insert new branch name (cannot contain spaces): " branchName
                    echo
                    git checkout -b "$branchName"
                elif [ "${branches[$branchChoice]}" == "${DCYAN}<----- back ------${NC}" ]
                    then
                        select_repo
                else
                    echo
                    git checkout ${branches[$branchChoice]}
                fi
        # remote repo control flow
        else
            if [ "${branches[$branchChoice]}" == "${DCYAN}<----- back ------${NC}" ]
                then
                    select_repo
                else
                    # prompt user for remote repo action                    
                    echo "${CYAN}Select action:${NC}"
                    actions=("fetch" "pull" "${DCYAN}<----- back ------${NC}")
                    select_option "${actions[@]}"
                    actionsChoice=$?
                    # format repo and branch names for git shell command
                    repoBranchStr="${branches[$branchChoice]}"
                    repoBranch=("${repoBranchStr//// }")
                        # remote repo action control flow
                        if [ "$actionsChoice" -eq 0 ]
                            then
                                echo
                                git fetch $repoBranch
                            elif [ "$actionsChoice" -eq 1 ]
                                then
                                    echo
                                    git pull $repoBranch
                            else
                                select_branch
                            fi
                fi
        fi
}

select_repo
