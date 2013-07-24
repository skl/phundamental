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
    local SEARCH=`echo $1 | sed 's#/#\\\/#g'`
    local REPLACE=`echo $2 | sed 's#/#\\\/#g'`
    local TARGET=$3

    [ ! -f ${TARGET} ] && echo "ph_search_and_replace() failed! ${TARGET} is not a file"

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

    cp -i ${SOURCE} ${TARGET} && ph_search_and_replace ${SEARCH} ${REPLACE} ${TARGET}
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
# (Nicely) create a symlink
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
        echo "ph_symlink(): Real file or directory already exists where you're trying to create a symlink: ${TARGET}"
        rm -ri ${TARGET}

        # Abort symlink creation if user did not delete existing file/directory
        if [ -f ${TARGET} ] || [ -d ${TARGET} ] && [ ! -L ${TARGET} ]; then
            echo "ph_symlink(): Aborting symlink creation..."
            return 1
        fi
    fi

    echo -n "Creating symlink ${TARGET} -> ${SOURCE} ... "

    if ${FORCE} ; then
        ln -sf ${SOURCE} ${TARGET} 2>/dev/null && { echo "success!"; return 0; } || { echo "failed!"; return 1; }
    else
        ln -sn ${SOURCE} ${TARGET} 2>/dev/null && { echo "success!"; return 0; } || { echo "failed!"; return 1; }
    fi
}


##
# Install a phundamental module
#
# @param string $1 <install|uninstall>
# @param string $2 Module name
#
function ph_module_action() {
    local ACTION=$1
    local MODULE=$2
    local RESULT_MSG='with an unknown status'
    local ACTION_FILE=${PH_INSTALL_DIR}/modules/${MODULE}/${ACTION}.sh

    # Check module directory exists
    if [ ! -d ${PH_INSTALL_DIR}/modules/${MODULE} ]; then
        echo "ph_module_action(): Module '${MODULE}' does not exist!"
        return 1
    fi

    # Check action file is executable
    if [ ! -x ${ACTION_FILE} ]; then
        echo "ph_module_action(): ${MODULE}/${ACTION}.sh is not executable, skipping..."
        return 1
    fi

    . ${ACTION_FILE} && RESULT='successfully' || RESULT='unsuccessfully'
    echo "[phundamental/${MODULE}] ${ACTION} script finished ${RESULT}."

    if [[ "${RESULT}" == "successfully" ]]; then
        return 0
    else
        return 1
    fi
}


##
# Process application arguments to deal with request appropriately
#
# @param string $1 <install|uninstall>
# @param list      An optional list of module names to action.
#
function ph_front_controller() {
    local ACTION=$1

    case $# in \
    0)
        echo "Usage: ${PH_INSTALL_DIR}/<install|uninstall> [<module> [<module> ..]]"
    ;;

    # Action all modules
    1)
        for MODULE in `ls -1 ${PH_INSTALL_DIR}/modules`; do
            echo ''
            read -p "[phundamental/installer] Would you like to ${ACTION} ${MODULE}? [y/n] " REPLY
            [ "y" == $REPLY ] && ph_module_action ${ACTION} ${MODULE}
        done
    ;;

    # Action one or more modules
    *)
        # Ignore first parameter as it's stored in ${ACTION}
        shift

        # Loop through all remaining arguments and assume they're module names
        while (( "$#" )); do
            ph_module_action ${ACTION} $1
            shift
        done
    esac
}
