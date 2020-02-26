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

#Check arguments
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