function help_menu() {
  printf "Note management commands:\n\n"

  echo "-c                    collects all .note files to /home/ric/notes-repo"
  echo "-e [name]             edits a note"
  echo "-e [query]            finds notes containing [query]"
  echo "-h                    shows this help menu"
  echo "-l                    lists all notes"
  echo "-m [current] [new]    renames [current] to [new]"
  echo "-n [name] [content]   creates a new note"
  echo "-p [name]             prints a note to the terminal"
  echo "-s [filter]           search for notes that match *[filter]*.note"
  echo "-x [name]             deletes a note"
}

function print_separator() {
  echo "$1"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function collect() {

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

function update_refs() {
  exec zsh
}
