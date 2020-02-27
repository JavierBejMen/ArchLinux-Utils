#!/bin/bash
##### Constants

TITLE="System Information for $HOSTNAME"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"
TAB="   "

#helpers
short_help(){
  printf "\n"$0": "$0" [OPTIONS] path [path]...\n"
}

help(){
  short_help
  printf "$TAB""Upgrade AUR package from given directories assuming git repository exists\n"
  printf "\nOPTIONS\n""$TAB""-h, --help\n""$TAB""$TAB""print this information\n"
  printf "$TAB""-r, --recursive\n""$TAB""$TAB""Look for all directories inside \
specified path, 1 level recursion\n"
}

#main functions
process_dir(){
  #check if directory exists
  if [[ ! -d $1 ]]; then
    printf "[Error] can't open path: ""$1""\n" >&2
    return 1
  fi

  printf "Updating package stored at ""$1""\n"
  cd $1
  #check if remote repository is available
  remote_url=$(git config --get remote.origin.url)
  if [ -z "$remote_url" ]; then
    printf "[Error] can't find remote git url: remote.origin.url\n" >&2
    return 1
  fi

  #check if updates are available
  git_diff=$(git diff-index HEAD)
  if [[ -z "$git_diff" ]]; then
    printf "No updates available\n"
    printf "Aborted, no changes were made"
    return 0
  fi

  printf "Update available\n"

  #check untracked files
  # TODO HEREEE
  untracked_files=$(git ls-files | egrep -v '/$')

  if [ ! -z "$untracked_files" ]; then
    printf "Detected untracked files:\n"
    for f in $untracked_files
    do
      printf "$TAB""$f""\n"
      if [[ f =~ .*.pkg ]]
    done

    printf "\nRemove untracked files? [y/N]\n"
    continue="N"
    read continue
    if [[ ${continue^^} == "N" || -z "$continue" ]]; then
      printf "Aborted, no changes made\n"
      return 0
    elif [[ ${continue^^} != "Y" ]]; then
      printf "[Error] unknown response: ""$continue""\n" >&2
      printf "Aborted, no changes made\n"
      return 1
    fi
  fi

  printf "Pulling from ""$remote_url""\n"
  git pull $remote_url
  if [[ $? == 1 ]]; then
    printf "[Error] pulling operation returned fail code\n" >&2
    printf "Check file status\n"
    return 1
  fi

  printf "Building pakage\n"
  makepkg
  if [[ $? == 1 ]]; then
    printf "[Error] makepkg operation returned fail code\n" >&2
    printf "Check file status\n"
    return 1
  fi

  package=$(ls | grep *pkg.tar.xz)
  IFS=$'\n'

  for pkg in $package
  do
    printf "$pkg""\n"
  done
}

process_recursive_dir(){
  if [[ -d $1 ]]; then
    echo ok
  else
    printf "[Error] can't open path: ""$1""\n" >&2
    return 1
  fi
}

#Check arguments and process
if [[ $# < 1 ]]; then
  printf "[Error] Wrong number of arguments\nReceived "$#" arguments, expected >=1\n" >&2
  short_help
  exit 1
#check help
elif [[ $1 == "-h" || $1 == "--help" ]]; then
  help
#recursive
elif [[ $1 == "-r" || $1 == "--recursive" ]]; then
  if [[ $# != 2 ]]; then
    printf "[Error] argument --recursive expects exactly one path\n" >&2
    printf "Refer to --help for further information\n"
    exit 1
  else
    process_recursive_dir
  fi
#standard
else
  process_dir "$1"
fi

exit 0
