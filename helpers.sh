function help_menu() {
  echo "Notes Help Menu"
  echo
  echo "Options:"
  echo "-c                      collects all .note files to /home/ric/notes-repo. commits"
  echo "-d [line-number] [name] edits a note"
  echo "-e [name]               edits a note"
  echo "-f [query]              finds notes containing [query]"
  echo "-h                      shows this help menu"
  echo "-l                      lists all notes in long format"
  echo "-m [current] [new]      renames [current] to [new]. commits"
  echo "-n [name] [\"content\"]   creates/updates a note. commits"
  echo "-s [filter]             search for notes that match *[filter]*.note"
  echo "-v [name]               prints a note to the terminal"
  echo "-x [name]               deletes a note. commits"
  echo
  echo "Arguments:"
  echo "sync                    sync with git server. commits"
  echo "status                  show git repo status"
  echo "No args                 short list all notes"
}

function print_separator() {
  echo "$1"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function view(){
	  print_separator "$1"
    cat /home/ric/notes-repo/"$1".note
    print_separator
}

function collect() {q
  notes=$(find /home/ric/ -name '*.note' -not -path "/home/ric/notes-repo/*")
  lines=$(echo "$notes" | wc -l)    # counts number of lines
  chars=$(echo -n "$notes" | wc -c) # counts number of chars

  echo "searching for notes..."
  echo

  if ((chars > 0)); then
    printf "Found $lines note(s):%s\n$notes%s\n"
    echo
    echo "moving notes to /home/ric/notes-repo"

    while IFS= read -r line; do
      mv "$line" ~/notes-repo/
    done <<<"$notes"
  else
    echo "No new notes found"
  fi
}

function commit(){
  git --git-dir=/home/ric/notes-repo/.git --work-tree=/home/ric/notes-repo/ add . >> /dev/null
  git --git-dir=/home/ric/notes-repo/.git --work-tree=/home/ric/notes-repo/ commit -m "$(date +%y-%m-%d_%T)"
}

function sync() {
    echo ">>> checking for server changes..."
    git --git-dir=/home/ric/notes-repo/.git --work-tree=/home/ric/notes-repo/ pull

    echo ">>> committing all files..."
    commit

    echo ">>> merging with server..."
    git --git-dir=/home/ric/notes-repo/.git --work-tree=/home/ric/notes-repo/ push

    echo "done!"
}

function status() {
     git --git-dir=/home/ric/notes-repo/.git --work-tree=/home/ric/notes-repo/ status
}

function update_refs() {
  exec zsh
}

function new() {
    echo -e "$2" >> /home/ric/notes-repo/"$1".note
    view $1
    commit
    update_refs
}
