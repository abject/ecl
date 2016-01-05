
## Usgae: _list_folder folder_path
function _list_folder() {
  _lst_folder_=""
  for d in $($LS_BIN "$1")
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
  for root in "${ECL_COMP_PROJECT_PLACE[@]}"
  do
    for d in $($LS_BIN "$root")
    do
      if [ $d == $1 ]
      then
        _list_folder $root/$d
        _project_versions=$_lst_folder_
      fi
    done
  done
}

## Usage: _find_project_bin project_name version bin_place [bin_place...]
function _find_project_bin() {
  _project_bins=""
  local project_name=$1
  local version=$2
  local bin_places=(${@:3})
  for root in "${ECL_COMP_PROJECT_PLACE[@]}"
  do
    for d in $($LS_BIN "$root")
    do
      if [ $d == $project_name ]
      then
	for sd in $($LS_BIN "$root/$d")
	do
	    if [ $sd == $version ]
	    then

		for bin in "${bin_places[@]}"
		do
			dir=$root/$d/$sd/$ECL_COMP_INSTALL_AREA/$bin
			for file in $($LS_BIN $dir)
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
    local cur prev opts _projects _CreateElementsProject_opts
    local LS_BIN="/usr/bin/ls"
    local ECL_COMP_PROJECT_PLACE=("$HOME/Work/Projects" "/opt/euclid")
    local ECL_COMP_PROJECT_ELEMENTS_BIN_PLACE=("scripts")
    local ECL_COMP_PROJECT_BIN_PLACE=("bin" "scripts")
    local ECL_COMP_INSTALL_AREA="InstallArea/x86_64*"

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
    for dir in "${ECL_COMP_PROJECT_PLACE[@]}"
    do
        _list_folder $dir
        _projects="$_projects $_lst_folder_"
    done

    ## Test current and previous command line argument to make completion
    if [[ ${cur} == -* ]]
    then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    elif [[ $_projects == *"$prev"* ]]
    then
        _find_project_version $prev
        COMPREPLY=( $(compgen -W "${_project_versions}" -- ${cur}))
    elif [[ $prev =~ [0-9.] ]]
    then
	BIN_PLACES=$ECL_COMP_PROJECT_PLACE
	if [ "${COMP_WORDS[COMP_CWORD-2]}" == "Elements" ]
	then
		BIN_PLACES=$ECL_COMP_PROJECT_ELEMENTS_BIN_PLACE
	fi
        _find_project_bin "${COMP_WORDS[COMP_CWORD-2]}" $prev "${BIN_PLACES[@]}"
        local cmd=$_project_bins
        COMPREPLY=( $(compgen -W "${cmd}" -- ${cur}))
    elif [ $prev == "ERun" ]
    then
        COMPREPLY=( $(compgen -W "${_projects}" ${cur} ) )
    fi

    ## Case over last argument option and usage
    ## TODO: make all the option available for all cases
    ## FIXME: Is it necessary at this moment?
    case "${prev}" in
	CreateElementsProject)
	    COMPREPLY=( "<PROJECT_NAME> <VERSION>" $(compgen -W "${_CreateElementsProject_opts}" -- ${cur} ))
            return 0
            ;;
        *)
        ;;
    esac
}

## Make completion works for ERun command line
complete -F _ERun ERun

