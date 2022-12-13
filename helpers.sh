source ts
repo=~/notes-repo/

function help_menu() {
  echo "Notes Help Menu"
  echo
  echo "Options:"
  echo "-c, collect                      			collects all .note files to ~/notes-repo. commits"
  echo "-d, delete line [line-number/range] [name]		deletes a line or range of lines \"2,5\". commits"
  echo "-e, edit [name]               				edits a note"
  echo "-f, find [query]              				finds notes containing [query]"
  echo "-h, help		                      		shows this help menu"
  echo "-l, lists			                      	lists all notes in long format"
  echo "-m, mv rename [current] [new]      			renames [current] to [new]. commits"
  echo "-n, new [name] [\"content\"]   				creates/updates a note. commits"
  echo "-s, search [filter]             			search for notes that match *[filter]*.note"
  echo "-v/v1, view [name]               			prints a note to the terminal. -v1 will print line numbers"
  echo "-x, delete [name]               			deletes a note. commits"
  echo
  echo "Arguments:"
  echo "copy [name] [new name]                  		copies a note. appends -copy if no [new name] is passed"
  echo "sync                    				sync with git server. commits. pulls. pushes"
  echo "status                  				show git repo status. fetches"
  echo "No args                 				short list all notes"
}

function print_separator() {
	if [ -z "$1" ]; then 
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	else
		echo "$1"
		echo
	fi
}

function view(){
	print_separator "$1"
	
	if [[ "$2" == "-v1" ]]; then
		cat -n "$repo""$1".note
	else
		cat "$repo""$1".note
	fi
	echo
    print_separator
}

function new() {
	if [[ "$1" == "thoughts" ]]; then
		echo -e "$(ts) $2" >> "$repo""$1".note
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
	git --git-dir="$repo".git --work-tree="$repo" $1
}

function commit(){
  git --git-dir="$repo".git --work-tree="$repo" add . >> /dev/null
  git --git-dir="$repo".git --work-tree="$repo" commit -m "$(date +%y-%m-%d_%T)"
}

function sync() {
    echo ">>> checking for server changes..."
    git_it "pull"

    echo ">>> committing all files..."
    commit

    echo ">>> merging with server..."
    git_it "push"

    echo "done!"
}

function status() {
     git_it "fetch"
     git_it "status"
}

function update_refs() {
  exec zsh
}
