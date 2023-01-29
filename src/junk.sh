#!/bin/bash
#This is the homework 1 junk.sh file


#Variables
helpFlag=0
listFlag=0
purgeFlag=0

#turns out I can't use the script parameters inside this function so right now this is a placeholder
recycleFiles(){
	echo "TODO"
	
}
printGuide(){
# test string
#echo "printing guide now:"

cat << ENDOFTEXT
Usage: junk.sh [-hlp] [list of files]
     -h: Display help.
     -l: List junked files.
     -p: Purge all files.
     [list of files] with no other arguments to junk those files.
ENDOFTEXT

}
displayList(){
#test string
#echo "displaying list:"

ls -lAF "$HOME/.junk"
exit 0




}

purgeFiles(){
#test string
echo "purging now:"
	rm "$HOME/junk.sh/*"
	rm "$HOME/junk.sh/.*"
	exit 0



}



checkErrors(){
#test string
#echo "checking errors now:"

	if [ $((helpFlag + listFlag + purgeFlag)) -eq 0 ] && [ $OPTIND -eq 0 ]; then
		printGuide
		exit 1
	fi
	if [ $((helpFlag + listFlag + purgeFlag)) -gt 1 ]; then
	        echo "Error Too many options enabled." >&2
		printGuide
		exit 1	    
	fi	
}
doThings(){
#test string
#echo "deciding what to do now:"

	if [ $helpFlag -eq 1 ]; then
		#debugging
		echo "print guide chosen"
		printGuide
		exit 0
	fi
	if [ $listFlag -eq 1 ]; then
		#debugging
		echo "list files chosen"
		displayList
		exit 0
	fi
	if [ $purgeFlag -eq 1 ] ; then
		#debugging
		echo "purge files chosen"
		purgeFiles
		exit 0
	fi

	

}
#check input for too many flags and set flags
#test string
echo "Input Function starts here:"
while getopts ":hlp" option; do
	case "$option"  in
	h) helpFlag=1
		;;
	l) listFlag=1
		;;
	p) purgeFlag=1
		;;
	?) printf "Error: Unkown option '-%s'.\n" "$OPTARG" >&2
		printGuide
		exit 1
		;;
	esac
done
#check for directory and make one if necesssary
if [ ! -d "$HOME/.junk" ]; then
		mkdir "$HOME/.junk"
	fi
#debugging
echo $helpFlag
echo $listFlag
echo $purgeFlag
#check for format errors in arguments
checkErrors
#either list files, purge files, show help, or place file in junk
doThings

################
#This is where the recycle function goes (I had to put it in main script to use parameters)
###############
	#debugging
	echo "recycle files chosen"
	echo $#
	#place files inside recycle dir
	while  [ $# -gt 0 ]; do
	echo "doing a pass through files"
	echo $1
	if [ ! -f $1 ]; then
		printf "Warning: '-%s' not found \n" $1
	
	else
		mv "$1" "$HOME/.junk/$1"
	fi
	#shift the input parameters by 1 for next file
	shift 
done

exit 0

#debugging

cat << ENDOFTEXT 
"This string  means program went too long"
ENDOFTEXT
