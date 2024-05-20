#!/bin/bash

FILE=$1

if [[ ! -f ${FILE} ]]; then
	echo "ERROR: ${FILE} is not a file"
	exit 1
fi

if [[ ${FILE} != *.json ]]; then
	echo "ERROR: Filename ${FILE} does not have a JSON extension"
	exit 1
fi

FAILURE=0

jq . "${FILE}" >"${FILE}.tmp" || FAILURE=1

if [[ ${FAILURE} == 1 ]]; then
	rm "${FILE}.tmp"
	echo "ERROR: jq parsing failed"
	exit 1
else
	mv "${FILE}.tmp" "${FILE}"
fi
