function help_menu() {
  printf "Note management commands:\n\n"

  echo "-c                    collects all .note files to /home/ric/notes"
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
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function collect() {

  notes=$(find /home/ric/ -name '*.note' -not -path "/home/ric/notes/*")
  lines=$(echo "$notes" | wc -l)    # counts number of lines
  chars=$(echo -n "$notes" | wc -c) # counts number of chars

  echo "searching for notes..."
  echo

  if ((chars > 0)); then
    printf "Found $lines note(s):%s\n$notes%s\n"
    echo
    echo "moving notes to /home/ric/notes"

    while IFS= read -r line; do
      mv "$line" ~/notes/
    done <<<"$notes"
  else
    echo "No new notes found"
  fi
}

function update_refs() {
  exec zsh
}