# Switch Branch

![Screenshot 2023-12-21 at 4 01 48 PM](https://github.com/ethanfranks/switch-branch/assets/100048121/cf6325d0-49dc-4ba5-b335-1a8b78f7c5ab)

![Screenshot 2023-12-21 at 4 02 29 PM](https://github.com/ethanfranks/switch-branch/assets/100048121/b44bff20-215f-456e-92d3-08cdbdf35873)

https://github.com/ethanfranks/switch-branch/assets/100048121/fb4483bc-20d0-42d9-b4ad-50d6cfc8047a

## Description

Anyone else intimidated by shell scripting? I understand the feeling. To overcome my (irrational) fear of shell scripting I created this little script that allows the user to select a git branch to checkout from a list in their terminal using up and down arrow keys.

First, the user selects the location of the branch they want to checkout from a list of local and remote repositories. Then they can see a list of branches in the selected repo, select the branch they're interested in, go back, or create a new branch locally.

This project challenged me to work in a new syntax, expand my knowledge of the Git CLI, learn to add custom scripts to a bash/zsh profile and experiment with ASCII art.

Big thank you to Alexander Klimetschek for his wizardry creating the script that allows the arrow key functionality. I initially set out to write this myself and quickly learned it is quite a challenging feature to implement in the shell.

Check out Alexander's work here: https://lnkd.in/gjA8QTNc

## Installation

1. Clone this repo into a secure location on your machine.
   - ex: `~/.local`
2. Add the path to the `swib` file to your `PATH` in `.zshrc` or `.bashrc`,
   depending on which shell you use.
   - ex:

      ```text
      SWIB=~/.local/switch-branch
      PATH=$SWIB:$PATH
      ```

## Using swib

1. From any git repository on your machine enter the command:

```bash
swib
```

2. Use the ***up and down arrow keys*** to select the repo containing the branch
   you would like to switch to and select that repo with the ***enter*** key. You will now see a list of all
   of the branches in that repo.

3. Use the ***up and down arrow keys*** to select the branch you would like to switch
   to in the chosen repo. Switch to that branch by pressing the ***enter*** key, or select
   `<----- back ------` to go back to the repo list.

- At any point press (***ctrl*** + ***c***) to exit `swib` without switching branches.

### Git Commands (Under the Hood)

If you are:

- checking out an existing branch from your local repo:
  `git checkout <branch_name>`
- checking out a new branch locally: `git checkout -b <branch_name>`
- switching to a remote branch: `git fetch <remote_repo_name>` &&
  `git switch <branch_name>`
