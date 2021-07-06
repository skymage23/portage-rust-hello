#!/bin/sh

ROOT="${PWD}"
PORTAGE_ROOT="${ROOT}/portage_root"
PORTAGE_DIR="${ROOT}/submodules/third_party/portage"
PORTAGE_SETUP="./setup.py"  #This will help catch "wrong dir" mistakes.

(
cd ${PORTAGE_DIR};
echo "PWD: ${PWD}"
! ${PORTAGE_SETUP} install --root="${PORTAGE_ROOT}" && \
${PORTAGE_SETUP} clean && exit 1;
)
