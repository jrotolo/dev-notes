#!/bin/bash
# A menu driven interface for dev notes
# By Jarrod Rotolo

# Define some global variables
EDITOR=nvim
PASSWD=/etc/passwd
#RED='\033[0;41;30m'
STD='\033[0;0;39m'
SOURCE_PATH=~/src/dev-notes
DEFAULT_MENU_ITEMS=("Playbook" "Cheatsheets" "Tools" "Research" "Scratchpad")
CURRENT_MENU_ITEMS=()
CURRENT_DIRECTORY=""

# Define some color variables
RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
BLUE=$'\e[1;34m'
MAGENTA=$'\e[1;35m'
CYAN=$'\e[1;36m'
WHITE=$'\e[0m'

# Define emoji variables
PLAYBOOK_SYMBOL=📕
CHEATSHEET_SYMBOL=📝
TOOL_SYMBOL=🛠

playbook() {
  set_current_directory "playbook"
  show_files "playbook"
}

cheatsheets() {
  set_current_directory "cheatsheets"
  show_files "cheatsheets"
}

tools() {
  set_current_directory "tools"
  show_files "tools"
}

scratchpad() {
  set_current_directory "scratchpad"
  show_files "scratchpad"
}

research() {
  set_current_directory "research"
  show_files "research"
}

pause() {
  read -p "Press [Enter] key to continue..." fackEnterKey
}

print_working_path() {
  echo -e "${CYAN} 📂 Current Path: ~/src/dev-notes/${CURRENT_DIRECTORY}"
}

set_current_directory() {
  CURRENT_DIRECTORY=$1
}

# Outputs all the files in a current directory to populate the new menu
show_files() {
  clear
  for file in $SOURCE_PATH/$1/*
  do
    basename "$file"
    f="$(basename -- $file)"
    CURRENT_MENU_ITEMS+=($f)
  done
}

# Outputs the contents of a file to stdout or opens it with vim
view_or_edit() { 
  local choice
  read -p "(v)iew or (e)dit? [Default (v)iew] " choice

  if [[ $choice == 'e' ]]
  then
    $EDITOR $SOURCE_PATH/$CURRENT_DIRECTORY/$1
  else
    cat $SOURCE_PATH/$CURRENT_DIRECTORY/$1 | less
  fi
}

new_file() {
  local filename
  read -p "Name of file: " filename 
  touch $SOURCE_PATH/$CURRENT_DIRECTORY/$filename
  echo -e "${GREEN} ✅ Created file ${filename}"
  pause
}

# Go back to the default menu and reset our global variables to get back to default state
go_back() {
  CURRENT_DIRECTORY=""
  CURRENT_MENU_ITEMS=()
}

show_header() {
  echo "${BLUE}+-------------------------------------------------------------+"
  echo "|                                                             |" 
  echo "|                      D E V - N O T E S                      |"
  echo "| A menu driven interface to interact with my developer notes |"
  echo "|                                                             |"
  echo "+-------------------------------------------------------------+"
  echo ""
}

# Displays the current menu depending on the context
# When `CURRENT_MENU_ITEMS` is empty we are in the default `home` state
# Once an option is selected we need to render a new menu in the context of the selected option
show_menus() {
  if [[ ${#CURRENT_MENU_ITEMS[*]} == 0 ]] 
  then
    default_menu
  else
    active_menu
  fi
}

# The default menu is the home state menu displaying top level directories
default_menu() {
  for index in "${!DEFAULT_MENU_ITEMS[@]}" 
  do
    name=${DEFAULT_MENU_ITEMS[$index]}
    echo -e "${WHITE}$(($index + 1)). ${name}"
  done
}

# The active menu displays the contents of the selected directory
active_menu() {
  for index in "${!CURRENT_MENU_ITEMS[@]}" 
  do
    echo -e "${WHITE}$(($index + 1)). ${CURRENT_MENU_ITEMS[$index]}"
  done
}

# Maps the default menu options to action handling functions
default_menu_options() {
  case $1 in
    1) playbook ;;
    2) cheatsheets ;;
    3) tools ;;
    4) research ;;
    5) scratchpad ;;
    e|E) exit 0;;
    *) report_error
  esac
}

# Maps the menu options to their correct action handling functions
menu_options() {
  last_item_index=$((${#CURRENT_MENU_ITEMS[*]}))

  # Here is where we handle the user input and map it to the correct option.
  # `$1` is the user input.
  case $1 in
    [1-$(($last_item_index))]) view_or_edit ${CURRENT_MENU_ITEMS[$1 - 1]} ;;
    n|N) new_file ;;
    e|E) exit 0;;
    b|B) go_back ;;
    *) report_error 
  esac
}

report_error() {
  echo -e "${RED} 🚫 Error...${STD}" && sleep 1
}

# Reads the user input and calls the corresponding menu options function
read_options() {
  local choice
  echo ""
  read -p "Enter choice " choice

  if [[ ${#CURRENT_MENU_ITEMS[*]} == 0 ]]
  then
    default_menu_options $choice
  else
    menu_options $choice
  fi
}

show_commands() {
  echo "Options------------------------------------+"
  echo "|   (N)ew File   |   (E)xit   |   (B)ack   |"
  echo "+------------------------------------------+"
}

## Main Execution Context

# Capture Ctrl-c , Ctrl-z escapes
trap '' SIGINT SIGQUIT SIGTSTP

# Main program loop - draws menus to screen and waits for user input
while true
do
  clear
  show_header
  print_working_path
  echo ""
  show_menus
  echo ""
  show_commands
  read_options
done
