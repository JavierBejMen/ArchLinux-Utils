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
  if [[ -d $1 ]]; then
    printf "Updating package stored at ""$1""\n"
    cd $1
    remote_url=$(git config --get remote.origin.url)
    if [ -z "$remote_url" ]; then
      printf "[Error] can't find remote git url: remote.origin.url\n" >&2
      exit 1
    else
      untracked_files=$(git ls-files --other --exclude-standard --directory | egrep -v '/$')

      if [ ! -z "$untracked_files" ]; then
        printf "Detected untracked files:\n""$TAB""$untracked_files\n"
        printf "Do you wish to continue? [y/N]\n"
        continue="N"
        read continue
        if [[ ${continue^^} == "N" || -z "$continue" ]]; then
          printf "Aborted, no changes made\n"
          exit 0
        elif [[ ${continue^^} == "Y" ]]; then
          #statements
          printf "Pulling from ""$remote_url""\n"

          # TODO - last here
        else
          printf "[Error] unknown response: ""$continue""\n" >&2
          printf "Aborted, no changes made\n"
          exit 1
        fi
      fi
    fi
  else
    printf "[Error] can't open path: ""$1""\n" >&2
    exit 1
  fi
}

process_recursive_dir(){
  if [[ -d $1 ]]; then
    echo ok
  else
    printf "[Error] can't open path: ""$1""\n" >&2
    exit 1
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
