#!/bin/bash

source $HOME/codebase/scripts/notes/ts
repo=~/notes-repo/
custom_file=~/.oh-my-zsh/custom/custom.zsh

function help_menu() {
  echo "Notes Help Menu"
  echo
  echo "Options:"
  echo "-c, collect                                 collects all .note files to ~/notes-repo. commits"
  echo "-d, delete line [line-number/range] [name]  deletes a line or range of lines \"2,5\". commits"
  echo "-e, edit [name]                             edits a note"
  echo "-f, find [query]                            finds notes containing [query]"
  echo "-h, help                                    shows this help menu"
  echo "-i, ins [line-number] [\"content\"] [name]    inserts a line. commits"
  echo "-l, lists                                   lists all notes in long format"
  echo "-m, mv rename [current] [new]               renames [current] to [new]. commits"
  echo "-s, search [filter]                         search for notes that match *[filter]*.note"
  echo "-v, view [name]                             prints a note to the terminal with line numbers"
  echo "-x, delete [name]                           deletes a note. commits"
  echo
  echo "Arguments:"
  echo "clear [name]            clear the contents of a note. commits"
  echo "copy [name] [new name]  copies a note. appends -copy if no [new name] is passed"
  echo "sync                    sync with git server. commits. pulls. pushes"
  echo "status                  show git repo status. fetches"
  echo "[name] [content]        same as -n. commits"
  echo "No args                 short list all notes"
  echo "init                    add to PATH and source autocomplete"
}

function print_separator() {
	if [ -z "$1" ]; then 
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	else
		echo "$1"
		echo
	fi
}

function init(){
  # install bat
  echo "installing bat"
  sudo pacman -S bat
  
  # install exa
  echo "installing exa"
  sudo pacman -S exa

  echo "installing micro"
    sudo pacman -S micro

  echo "installing zoxide"
    yay zoxide

  echo "" >> "$custom_file"
	echo "## NOTES APP" >> "$custom_file"
	echo 'export PATH="$PATH:$HOME/codebase/scripts/notes"' >> "$custom_file"
	echo "source ~/codebase/scripts/notes/notes-autocomplete" >> "$custom_file"
}

function clear() {
    if [[ -n $1 ]]; then
      rm "$repo""$1".note
      touch "$repo""$1".note

      commit
      exit
    fi

    echo "note name is required"
}

function view(){
	bat -n "$repo""$1".note
	echo
}

function addToCommands(){

  note="$repo""commands.note"
  result=$(grep -Fxin "******""$1" $note)
  ln=$(("${result%%:*}")) #substring line number

  if [ "$ln" -gt 0 ]; then
    ((ln=ln+1))   #increment line number

    sed -i "${ln}i $2" $note #insert new line
  fi
}

function new() {

  if [[ -z $2 ]]; then
    view $1
    exit
  fi

	if [[ "$1" == "thoughts" ]]; then
		echo -e "$(ts) $2" >> "$repo""$1".note
  elif [[ "$1" == *"-todo" ]]; then
    echo -e "[] $2" >> "$repo""$1".note
  elif [[ "$1" == "commands" ]]; then
      addToCommands "$2" "$3"
	else
		echo -e "$2" >> "$repo""$1".note
	fi
    
  view $1
  commit
  update_refs
}

function copy(){
	if [ -z $2 ]; then
		cp "$repo""$1".note "$repo""$1"-copy.note 
	else
		cp "$repo""$1".note "$repo""$2".note 
	fi
	
	commit
	update_refs
}

function collect() {
  notes=$(find ~ -name '*.note' -not -path "$repo""*")
  lines=$(echo "$notes" | wc -l)    # counts number of lines
  chars=$(echo -n "$notes" | wc -c) # counts number of chars

  echo "searching for notes..."
  echo

  if ((chars > 0)); then
    printf "Found $lines note(s):%s\n$notes%s\n"
    echo
    echo "moving notes to $repo"

    while IFS= read -r line; do
      mv "$line" ~/notes-repo/
    done <<<"$notes"
  else
    echo "No new notes found"
  fi
}

function git_it(){
	git --git-dir="$repo".git --work-tree="$repo" "$1"
}

function commit(){
  echo "syncing notes..."
  git --git-dir="$repo".git --work-tree="$repo" add . > /dev/null 2>&1
  git --git-dir="$repo".git --work-tree="$repo" commit -m "$(date +%y-%m-%d_%T)" > /dev/null 2>&1
  git_it "push" > /dev/null 2>&1
  echo "done!"
}

function sync() {
    git --git-dir="$repo".git --work-tree="$repo" add . #add
    git --git-dir="$repo".git --work-tree="$repo" commit -m "$(date +%y-%m-%d_%T)" #commit
    git_it "pull"
    git_it "push"
}

function status() {
     git_it "fetch"
     git_it "status"
}

function update_refs() {
	exec zsh
}
