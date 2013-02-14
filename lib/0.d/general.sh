#!/bin/bash

##
# Checks to see if a command ($1) is available
#
# @param  string  Command to check
# @return boolean True if the command exists
#
function ph_is_installed() {
    command -v $1 > /dev/null 2>&1 && return 0 || return 1
}


##
# Cross-platform wrapper for sed -i
#
# @param string Search pattern
# @param string Replacement pattern
# @param string Path to target file
#
function ph_search_and_replace() {
    local SEARCH=$1
    local REPLACE=$2
    local TARGET=$3

    [ ! -f ${TARGET} ] && echo "ph_search_and_replace() failed! ${TARGET} not found"

    sed -ie "s/${SEARCH}/${REPLACE}/g" ${TARGET}

    # OSX fix
    [ -f "${TARGET}e" ] && rm "${TARGET}e"
}


##
# Copy file and execute an inplace string replacement
#
# @param string Path to source file
# @param string Path to target file
# @param string Search pattern
# @param string Replacement pattern
#
ph_cp_inject() {
    local SOURCE=$1
    local TARGET=$2
    local SEARCH=$3
    local REPLACE=$4

    if [ ! -f ${SOURCE} ]; then
        echo "ph_cp_inject() failed! ${SOURCE} is not a file"
        return 1
    fi

    cp ${SOURCE} ${TARGET} && ph_search_and_replace ${SEARCH} ${REPLACE} ${TARGET}
}


##
# Creates all directories ($@) if they don't already exist
#
# @param list Directories to create
#
function ph_mkdirs() {
    for DIR in $@; do
        [ ! -d $DIR ] && mkdir -p $DIR
    done
}


##
# Force ovewrite symlink on filesystem
#
# @param string   Path to source
# @param string   Path to target
# @param boolean  Force symlink creation <true|false>
# @return boolean True if the symlink was created
#
function ph_symlink() {
    local SOURCE="$1"
    local TARGET="$2"
    local FORCE=$3

    if [ -f ${TARGET} ] || [ -d ${TARGET} ] && [ ! -L ${TARGET} ]; then
        echo "ph_symlink() - Aborting! - Real file already exists where you're trying to create a symlink: ${TARGET}"
        return 1
    else
        rm -f ${TARGET}
    fi

    echo -n "Creating symlink ${TARGET} -> ${SOURCE} ... "

    if ${FORCE} ; then
        ln -sf ${SOURCE} ${TARGET} && { echo "success!"; return 0; } || { echo "failed!"; return 1; }
    else
        ln -s ${SOURCE} ${TARGET} && { echo "success!"; return 0; } || { echo "failed!"; return 1; }
    fi
}
