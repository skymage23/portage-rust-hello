#!/usr/bin/bash
NAME="portage-rust-hello"
WORKDIR="/mnt/${NAME}"

function die {
   >&2 echo "$@. Dying.".
   exit 1
}

if ! which docker; then
    die "Docker not installed or not on the system PATH";
fi

if ! docker ps 2>&1 >/dev/null; then
    die "User has not been authorized to use Docker"
fi

if [ "$( docker ps -a | grep -i build-librustprocps-ng )" == "" ]; then
    echo "Could not find build image."
    echo "Constructing build image."
    docker build -t "${NAME}" .
fi

echo "Launching build container..."
docker run -ti --name "${NAME}" --volume="${PWD}":"${WORKDIR}" -w "${WORKDIR}" "${NAME}"

#Cleanup:
docker rm "${NAME}"


