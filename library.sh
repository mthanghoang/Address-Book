show_menu() {
    echo "---- Address book ----"
	echo "1. Search address book"
	echo "2. Add entries"
	echo "3. Remove entries"
	echo "4. Edit entries"
	echo "5. Display all records"
    echo "6. Quit"
}

confirm() {
    ans="yes"
    echo -en "Confirm $@ [ $ans ]?"
    read ans
    ans=`echo $ans | tr '[a-z]' '[A-Z]'`
    if [ -z "$ans" ] || [ "$ans" == "Y" ] || [ "$ans" == "YES" ]; then
        return 0
    else
        return 1
    fi
}

add() {
    echo "Enter your record"
    name=""
    while [ -z "$name" ]
    do
        echo -en "Name: "
        read name
        [ -z "$name" ] && echo "ERROR: Empty name"
    done

    if [ `find_lines "^${name}:"` -ne 0 ]; then
        echo "An entry with this name already exists"
        show_menu
        return 1
    fi

    phone=""
    while [ -z "$phone" ]
    do
        echo -en "Phone: "
        read phone
        [ -z "$phone" ] && echo "ERROR: Empty phone number"
    done

    email=""
    while [ -z "$email" ]
    do
        echo -en "Email: "
        read email
        [ -z "$email" ] && echo "ERROR: Empty email"
    done

    confirm "adding this entry"
    if [ "$?" -eq "0" ]; then
        echo "Entry added successfully"
        echo "$name:$phone:$email" >> $BOOK
    else
        echo "Cancelled"
    fi
    show_menu
    return 0
}

locate_single_entry() {
    echo -en "Entry to search for: "
    read search_term
    n=`find_lines "$search_term"`
    while [ "$n" -ne "1" ]
    do
        grep -i "$search_term" "$BOOK"
        echo -en "${n} matches found. Enter a specific search term: "
        read search_term
        n=`find_lines "$search_term"`
    done
    echo "1 entry found"
    grep -i "$search_term" "$BOOK"
    return `grep -i -n "$search_term" "$BOOK" | cut -d":" -f1`
}

remove() {
    # result=`locate_single_entry`
    locate_single_entry
    line_num="$?"
    echo "$line_num"
    confirm "removing this query"
    if [ "$?" -eq "0" ]; then
        sed -i "${line_num}d" $BOOK
        echo "ENTRY REMOVED"
    else
        echo "REMOVING CANCELLED"
    fi
    show_menu
}

edit() {
    locate_single_entry
    line_num="$?"
    old_entry=`sed -n "${line_num}p" "$BOOK"`

    old_name=`echo "$old_entry" | cut -d":" -f1`
    old_phone=`echo "$old_entry" | cut -d":" -f2`
    old_email=`echo "$old_entry" | cut -d":" -f3`
    echo -en "New name [ $old_name ]:"
    read new_name
    if [ ! -z "$new_name" ]; then
        old_name=$new_name
    fi

    echo -en "New phone [ $old_phone ]:"
    read new_phone
    if [ ! -z "$new_phone" ]; then
        old_phone=$new_phone
    fi

    echo -en "New email [ $old_email ]:"
    read new_email
    if [ ! -z "$new_email" ]; then
        old_email=$new_email
    fi
    new_entry="${old_name}:${old_phone}:${old_email}"
    confirm "editing"
    if [ "$?" -eq "0" ]; then
        sed -i "s/${old_entry}/${new_entry}/" "$BOOK"
        echo "ENTRY EDITED"
    else
        echo "EDITING CANCELLED"
    fi
    show_menu
}

search() {
    echo -en "Search for (press RETURN to display all records):"
    read search
    if [ -z "$search" ]; then
        cat $BOOK
    else
        grep -i "$search" $BOOK
        if [ "$?" -ne "0" ]; then
            echo "No matches found"
        fi
    fi
    show_menu
    return
}

display() {
    num_lines=`grep -c "" $BOOK`
    # echo $num_lines
    if [ "$num_lines" -eq "0" ]; then
        echo "------Address book-------"
        echo "No entries in address book"
    else
        echo "------Address book-------"
        cat "$BOOK"
    fi
    show_menu
}

find_lines()
{
  # Find lines matching $1
    if [ -z "$1" ]; then
        grep -c -i "" $BOOK
    else
        grep -c -i "$1" $BOOK
    fi
}

 