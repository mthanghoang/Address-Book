#!/bin/sh
BOOK=~/Desktop/LearnShellScripting/.addressbook
old_IFS=$IFS
IFS=:

. ./library.sh

##########################################################
############ Main script starts here #####################
##########################################################

if [ ! -f $BOOK ]; then
  echo "Creating $BOOK ..."
  touch $BOOK
fi

if [ ! -r $BOOK ]; then
  echo "Error: $BOOK not readable"
  exit 1
fi

if [ ! -w $BOOK ]; then
  echo "Error: $BOOK not writeable"
  exit 2
fi

show_menu
while :
do
	echo -en "Enter your choice: "
	read INPUT
	case $INPUT in
		1)
			search
			;;
		2)
			add
			;;
		3)
			remove
			;;
		4)
			edit
			;;
		5)
			display
			;;
		6)
			exit
			;;
		*)
			echo "Sorry, wrong input"
			;;
	esac
done
# execute



