#!/bin/sh

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

    echo "\nSelect repo:"
    source ./select_option.sh 
    select_option "${repos[@]}"
    choice=$?

    if [ "$choice" -eq 0 ]
    	then
    		branches+=(`git branch` "*** new branch ***")
    	else
    		branches+=(`git branch --remote --list ${repos[$choice]}/*`)
    	fi

    branches+=("<----- back ------")

    # BRANCHES NEED TO BE FILTERED FOR ACCURACY
    select_branch
}

select_branch() {
    echo "\nSelect branch:"
    source ./select_option.sh 
    select_option "${branches[@]}"
    branchChoice=$?

    if [ "$choice" -eq 0 ]
        then
            if [ "${branches[$branchChoice]}" == "*** new branch ***" ]
                then
                    echo
                    read -p "Insert new branch name (cannot contain spaces): " branchName
                    echo "\n"
                    git checkout -b "$branchName"
                elif [ "${branches[$branchChoice]}" == "<----- back ------" ]
                    then
                        select_repo
                else
                    echo
                    git checkout ${branches[$branchChoice]}
                fi
        else
            if [ "${branches[$branchChoice]}" == "<----- back ------" ]
                then
                    select_repo
                else
                    echo "\nSelect action:"
                    actions=("fetch" "pull" "<----- back ------")
                    source ./select_option.sh 
                    select_option "${actions[@]}"
                    actionsChoice=$?

                        if [ "$actionsChoice" -eq 0 ]
                            then
                                git fetch ${branches[$branchChoice]}
                            elif [ "$actionsChoice" -eq 1 ]
                                then
                                    git pull ${branches[$branchChoice]}
                            else
                                select_branch
                            fi
                fi
        fi
}

select_repo
