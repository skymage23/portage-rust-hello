#!/usr/bin/env bash

ROOT="${PWD}"
[ "${PORTAGE_ROOT}" == "" ] && PORTAGE_ROOT="${ROOT}/portage_root"
[ "${PORTAGE_DIR}" == "" ] && PORTAGE_DIR="${ROOT}/submodules/third_party/portage"
PORTAGE_SETUP="./setup.py"  #This will help catch "wrong dir" mistakes.


#Utility functions:
function __die {
   >&2 echo "$1"
   exit $2
}

function die {
    local func_name=$1
    local message=$2
    local errcode=$3

    [ ${errcode} -lt 1 ] && __die "die: Inappropriate errcode argument."
    __die "${func_name}: ${message}" "${errcode}"
}

function die_with_usage {
    local func_name=$1
    local message=$2
    local errcode=$3

    [ ${errcode} -lt 1 ] && __die "die_with_usage: Inappropriate errcode argument."
    >&2 echo "${func_name}: ${message}"
    action_usage 1
    exit ${errcode}
}

#Action functions:
#help_install-submods="Installs git submodules if they are not already set up."
function action_install-submods {
    if [ "$(git submodule summary)" == "" ]; then
        echo "Initializing Git submodules..."
        git submodule update --init --recursive
    fi
}


help_install="Install Portage into the PORTAGE_ROOT"
function action_install {\
    local __func_name="${FUNCNAME[0]}"

    [ ! -d "${PORTAGE_DIR}" ] && \
    die "${_func_name}" "\"${PORTAGE_DIR}\" does not exist"


    if [ ! -d "${PORTAGE_ROOT}" ]; then
        ! mkdir "${PORTAGE_ROOT}" && \
	die "${__func_name}" "Unable to create \"${PORTAGE_ROOT}\""
    fi

    if [ "$(echo ${PORTAGE_DIR}/*)" == "${PORTAGE_DIR}/*" ]; then 
        action_install-submods
    fi
    
    echo "Executing Portage install..."
    (
        cd ${PORTAGE_DIR};
        echo "PWD: ${PWD}"
        ! ${PORTAGE_SETUP} install --root="${PORTAGE_ROOT}" && \
        ${PORTAGE_SETUP} clean && \
	die "${__func_name}" "Unable to install Portage" 1;

	${PORTAGE_SETUP} clean
    )
}

help_clean="Delete the PORTAGE_ROOT and remove build artifacts."
function action_clean {
    rm -rfd "${PORTAGE_ROOT}"
}


help_usage="Display the Help screen."
function action_usage {
    skip_preamble=$1
    if [ "${skip_preamble}" == "" ] || [ ${skip_preamble} -lt 1 ]; then
        echo "setup-portage.sh"
        echo
        echo "Initializes the Portage build system for project use"
    fi
    echo "Usage:"
    printf "\tsetup-portage.sh <action>\n\n"
    echo "List of possible actions:"
    echo
    for var in ${!actions[@]}; do
        echo
        printf "${var}:\t\t${help_msgs[${var}]}"
    done
    echo
    echo
}

__func_name="<main>"
#Register action functions:
__action="usage"

declare -A actions
declare -A help_msgs


#Populate "actions" array.
#Add logic to handle defining the same action twice:
tmp=""
action_name=""
while read var; do
    IFS='_' read tmp action_name <<< "${var}"
    
    #Add Action to array
    actions["${action_name}"]="${var}"
done <<< $(declare -F | awk '$3~/^action_/ {print $3}' )

#Populate "help_msg" array.
help_name=""
while read var; do
  IFS='_' read tmp help_name <<< "${var}"
  help_msgs["${help_name}"]="$(echo \"${!var}\")"
done <<< $(set -o posix; set | awk 'BEGIN { FS = "="} /^help_/ {print $1}')
unset tmp

[ ! $# -eq 1 ] && die_with_usage "${__func_name}" "Inappropriate number of arguments." 1;

action="${1}"
action_func="${actions[${1}]}"
[ "${action_func}" == "" ] && die "<main>" "\"${action}\" is not a valid action" 1
${action_func}
