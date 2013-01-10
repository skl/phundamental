#!/bin/bash

function ph_createuser_mac() {
    local USERNAME=$1

    local MAX_USER_ID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
    local NEW_USER_ID=`expr ${MAX_USER_ID} + 1`

    # Return early if user exists
    dscl . -read /Users/${USERNAME} >/dev/null 2&>1 && return 0

    dscl . -create /Users/${USERNAME}
    dscl . -create /Users/${USERNAME} UniqueID "${NEW_USER_ID}"
}

function ph_deleteuser_mac() {
    local USERNAME=$1

    dscl . -delete /Users/${USERNAME}
}

function ph_creategroup_mac() {
    local GROUPNAME=$1

    local MAX_GROUP_ID=`dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -n | tail -1`
    local NEW_GROUP_ID=`expr ${MAX_GROUP_ID} + 1`

    # Return early if group exists
    dscl . -read /Groups/${GROUPNAME} >/dev/null 2&>1 && return 0

    dscl . -create /Groups/${GROUPNAME}
    dscl . -create /Groups/${GROUPNAME} PrimaryGroupID ${NEW_GROUP_ID}
}

function ph_deletegroup_mac() {
    local GROUPNAME=$1

    dscl . -delete /Groups/${GROUPNAME}
}

function ph_assigngroup_mac() {
    local GROUPNAME=$1
    local USERNAME=$2

    # Return early if membership already exists
    dscl . -read /Groups/${GROUPNAME} | grep ${USERNAME} >/dev/null && return 0

    dscl . -append /Groups/${GROUPNAME} GroupMembership ${USERNAME}
}

function ph_createuser_linux() {
    local USERNAME=$1

    # Return early if user already exists
    id -u ${USERNAME} 2>/dev/null && return 0

    # Create system user
    useradd -r ${USERNAME}
}

function ph_deleteuser_linux() {
    local USERNAME=$1

    userdel ${USERNAME}
}

function ph_creategroup_linux() {
    local GROUPNAME=$1

    # Return early if group already exists
    cat /etc/group | grep "^${GROUPNAME}" >/dev/null && return 0

    groupadd -r mysql
}

function ph_deletegroup_linux() {
    local GROUPNAME=$1

    groupdel ${GROUPNAME}
}

function ph_assigngroup_linux() {
    local GROUPNAME=$1
    local USERNAME=$2

    # Return early if membership already exists
    cat /etc/group | grep "^${GROUPNAME}" | cut -d: -f4 | grep ${USERNAME} >/dev/null && return 0

    usermod -G ${GROUPNAME} ${USERNAME}
}

function ph_createuser() {
    local USERNAME=$1

    if [ ${PH_OS} == "mac" ]; then
        ph_createuser_mac ${USERNAME}

    elif [ ${PH_OS} == "linux" ]; then
        ph_createuser_linux ${USERNAME}
    fi
}

function ph_deleteuser() {
    local USERNAME=$1

    if [ ${PH_OS} == "mac" ]; then
        ph_deleteuser_mac ${USERNAME}

    elif [ ${PH_OS} == "linux" ]; then
        ph_deleteuser_linux ${USERNAME}
    fi
}

function ph_creategroup() {
    local GROUPNAME=$1

    if [ ${PH_OS} == "mac" ]; then
        ph_creategroup_mac ${GROUPNAME}

    elif [ ${PH_OS} == "linux" ]; then
        ph_creategroup_linux ${GROUPNAME}
    fi
}

function ph_deletegroup() {
    local GROUPNAME=$1

    if [ ${PH_OS} == "mac" ]; then
        ph_deletegroup_mac ${GROUPNAME}

    elif [ ${PH_OS} == "linux" ]; then
        ph_deletegroup_linux ${GROUPNAME}
    fi
}

function ph_assigngroup() {
    local GROUPNAME=$1
    local USERNAME=$2

    if [ ${PH_OS} == "mac" ]; then
        ph_assigngroup_mac ${GROUPNAME} ${USERNAME}

    elif [ ${PH_OS} == "linux" ]; then
        ph_assigngroup_linux ${GROUPNAME} ${USERNAME}
    fi
}
