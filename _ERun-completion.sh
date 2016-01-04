
## Usgae: _list_folder folder_path
function _list_folder() {
  _lst_folder_=""
  for d in $(/usr/bin/ls "$1")
  do
    if [ -d $1/$d ]
    then
      _lst_folder_="$_lst_folder_ $d"
    fi
  done
}

## Usage: _find_project_version project_name
function _find_project_version() {
  _project_versions=""
  ## FIXME: Should use a list of places store in a 'global' variable
  for root in "$HOME/Work/Projects" "/opt/euclid"
  do
    for d in $(/usr/bin/ls "$root")
    do
      if [ $d == $1 ]
      then
        _list_folder $root/$d
        _project_versions=$_lst_folder_
      fi
    done
  done
}

## usage: _find_project_bin project_name version
function _find_project_bin() {
  _project_bins=""
  ## FIXME: Should use a list of places store in a 'global' variable
  for root in "$HOME/Work/Projects" "/opt/euclid"
  do
    for d in $(/usr/bin/ls "$root")
    do
      if [ $d == $1 ]
      then
	for sd in $(/usr/bin/ls "$root/$d")
	do
	    if [ $sd == $2 ]
	    then

		for bin in "bin" "scripts"
		do
			dir=$root/$d/$sd/InstallArea/x86_64*/$bin
			for file in $(/usr/bin/ls $dir)
			do
				if [ -x $dir/$file ]
				then
					_project_bins="$_project_bins $file"
				fi
			done
		done
	    fi
	done
      fi
    done
  done
}

_ERun() 
{
    ## Set local variables
    local cur prev opts _projects

    ## Init
    COMPREPLY=()
    ## Current input
    cur="${COMP_WORDS[COMP_CWORD]}"
    ## Previous argument on command line
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    ## Set of available OPTION
    opts="-h --help -i --ignore-environment -u --unset -s --set -a --append -p --prepend -x --xml --sh --csh --py --verbose --debug --quiet -b --platform --dev-dir --user-area --no-user-area --runtime-project --overriding-project --no-auto-override --profile"
    ## Custom options for each command
    _CreateElementsProject_opts="--help --dependency --config-file --log-file --log-level --version"

    ## Get list of all projets only once
    ## FIXME: Should use a list of places store in a 'global' variable
    for dir in "$HOME/Work/Projects" "/opt/euclid"
    do
        _list_folder $dir
        _projects="$_projects $_lst_folder_"
    done

    ## Test if current begin by "-"
    if [[ ${cur} == -* ]]
    then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    elif [[ $_projects == *"$prev"* ]]
    then
        _find_project_version $prev
        COMPREPLY=( $(compgen -W "${_project_versions}" -- ${cur}))
    elif [[ $prev =~ [0-9.] ]]
    then
        _find_project_bin "${COMP_WORDS[COMP_CWORD-2]}" $prev
        local cmd=$_project_bins
        COMPREPLY=( $(compgen -W "${cmd}" -- ${cur}))
    elif [ $prev == "ERun" ]
    then
        COMPREPLY=( $(compgen -W "${_projects}" ${cur} ) )
    fi

    case "${prev}" in
	CreateElementsProject)
	    COMPREPLY=( "<PROJECT_NAME> <VERSION>" $(compgen -W "${_CreateElementsProject_opts}" -- ${cur} ))
            return 0
            ;;
        #hostname)
	    #COMPREPLY=( $(compgen -A hostname ${cur}) )
            #return 0
            #;;
        *)
        ;;
    esac

    #COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}
complete -F _ERun ERun
