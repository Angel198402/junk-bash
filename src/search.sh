#!/bin/bash

###############################################################################
# Name:          search.sh
# Last modified: Jan. 26, 2023
# Description:   Recurses the file system to find all directories if -d is
#                present, all symbolic links if -s is present, or both if
#                -d -s (or -ds) is present.
#                The recursion starts inside the folder given after all flags
#                on the command line, if present. If no folder is specified,
#                the recursion starts inside the current directory.
###############################################################################

# Use these variables as integers.
directory_count=0
symlink_count=0

# Use these variables as booleans.
directory_flag=0
symlink_flag=0

# Function to recurse the file system.
recurse_dir() {
    # "$1"/* matches all files except hidden files.
    # "$1"/.[!.]* matches hidden files, but not .. which would lead to
    # infinite recursion.
    for file in "$1"/.[!.]* "$1"/*; do
        # -h tests if a file is a symlink.
        if [ "$symlink_flag" -eq 1 ] && [ -h "$file" ]; then
            # readlink prints the location to which the symlink points.
            echo "symlink  : $file -> $(readlink "$file")"
            (( ++symlink_count ))
        fi
        # -d tests if a file is a directory.
        if [ -d "$file" ]; then
            if [ "$directory_flag" -eq 1 ]; then
                echo "directory: $file"
                (( ++directory_count ))
            fi
            recurse_dir "$file"
        fi
    done
}

# getopts is used to conveniently parse command line arguments.
# Below ":ds" is the optstring.
# The initial colon supresses internal error messages, allowing us to write
# custom messages, seen in case ?).
# d and s mean that -d and -s are possible flags the user can pass to the
# script as arguments.
# If something other than -d, -s, or -ds is supplied, the ? matches that
# other character, leading us to print an error message to stderr (>&2).
# In this case $OPTARG will contain the character that is an invalid flag.
while getopts ":ds" option; do
    case "$option" in
       d) directory_flag=1
          ;;
       s) symlink_flag=1
          ;;
       ?) printf "Error: Unknown option '-%s'.\n" "$OPTARG" >&2
          exit 1
          ;;
    esac
done

# This is a small hack to treat booleans as integers.
# If the sum of the flags is 0, no flags have been specified, so the script
# has nothing to do. It's technically an error case, so we exit with a non-zero
# return code.
if [ $(( directory_flag + symlink_flag )) -eq 0 ]; then
    echo "Error: No search parameters specified." >&2
    exit 1
fi

# Process remaining arguments, which should be the folder in which start
# recursing.
# Consider ./search.sh -s -d /tmp
# $0 is ./search.sh
# $1 is -s
# $2 is -d
# $3 is /tmp
# $OPTIND is the index of the next argument on the command line, after all
# flags have been parsed with getopts.
# We want to shift it so that /tmp is now in $1, so we take 3-1 and left shift
# 2 places.
shift "$((OPTIND-1))"

# $# gives the number of command line arguments. After shifting, it should just
# be 1.
if [ $# -gt 1 ]; then
    echo "Error: Too many arguments." >&2
    exit 1
elif [ $# -eq 0 ]; then
    # If not directory was supplied, pass the current directory (.) to the
    # function.
    recurse_dir .
else
    recurse_dir "$1"
fi

# Print the counts discovered during the search.
if [ "$symlink_flag" -eq 1 ]; then
    if [ "$symlink_count" -eq 1 ]; then
        echo "1 symlink found."
    elif [ "$symlink_count" -eq 0 ]; then
        echo "0 symlinks found."
    else
        echo "$symlink_count symlinks found."
    fi
fi

if [ "$directory_flag" -eq 1 ]; then
    if [ "$directory_count" -eq 1 ]; then
        echo "1 directory found."
    elif [ "$directory_count" -eq 0 ]; then
        echo "0 directores found."
    else
        echo "$directory_count directories found."
    fi
fi

# Exit with success.
exit 0
