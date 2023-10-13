#!/bin/sh
# Colors for echo output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
# LRED='\033[1;31m'
DCYAN='\033[38;5;24m'
NC='\033[0m'

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

branches=()

select_repo() {
    branches=()

    echo "${CYAN}Select repo:${NC}"
    source ./select_option.sh 
    select_option "${repos[@]}"
    choice=$?

    if [ "$choice" -eq 0 ]
    	then
            branchStr="`git branch`"
            parsedBranchStr="${branchStr//\*/ }"
    		branches+=($parsedBranchStr "${YELLOW}*** new branch ***${NC}")
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
    echo "${CYAN}Select branch:${NC}"
    source ./select_option.sh 
    select_option "${branches[@]}"
    branchChoice=$?

    if [ "$choice" -eq 0 ]
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
        else
            if [ "${branches[$branchChoice]}" == "${DCYAN}<----- back ------${NC}" ]
                then
                    select_repo
                else
                    echo "${CYAN}Select action:${NC}"
                    actions=("fetch" "pull" "${DCYAN}<----- back ------${NC}")
                    source ./select_option.sh 
                    select_option "${actions[@]}"
                    actionsChoice=$?

                    repoBranchStr="${branches[$branchChoice]}"
                    repoBranch=("${repoBranchStr//// }")
                    
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
