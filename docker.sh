#!/bin/bash

BASENAME="$(basename "$0")"
DOCKER_IMAGE_NAME="nkavid/reqt:0.0.2"
SOURCE_PATH=$(dirname "$0")

if [[ "$1" == "image" ]]; then
  echo "${BASENAME} building..."
  docker build --tag "${DOCKER_IMAGE_NAME}" .
fi

if [[ "$1" == "cpp" ]]; then
  echo "${BASENAME} running..."
  CONTAINER_NAME="nkavid-reqt-container"
  docker create --name "${CONTAINER_NAME}" -v "${SOURCE_PATH}:/workspace" -t "${DOCKER_IMAGE_NAME}"
  docker start "${CONTAINER_NAME}"
  docker exec "${CONTAINER_NAME}" bash -c "echo ${PWD}"
  docker exec "${CONTAINER_NAME}" bash -c "cmake -Bbuild -S${SOURCE_PATH}"
  docker exec "${CONTAINER_NAME}" bash -c "cmake --build build -j8"
  docker exec "${CONTAINER_NAME}" bash -c "./build/bin/demo schemas/requirement.json"
  docker kill "${CONTAINER_NAME}" > /dev/null
  docker rm "${CONTAINER_NAME}"
fi

if [[ "$1" == "python" ]]; then
  echo "${BASENAME} running..."
  CONTAINER_NAME="nkavid-reqt-container"
  docker create --name "${CONTAINER_NAME}" -v "${SOURCE_PATH}:/workspace" -t "${DOCKER_IMAGE_NAME}"
  docker start "${CONTAINER_NAME}"
  docker exec "${CONTAINER_NAME}" bash -c "python3 script/main.py"
  docker kill "${CONTAINER_NAME}" > /dev/null
  docker rm "${CONTAINER_NAME}"
fi

if [[ "$1" == "check" ]]; then
  echo "${BASENAME} checks..."
  CONTAINER_NAME="nkavid-reqt-container"
  docker create --name "${CONTAINER_NAME}" -v "${SOURCE_PATH}:/workspace" -t "${DOCKER_IMAGE_NAME}"
  docker start "${CONTAINER_NAME}"
  echo "${BASENAME} clang-tidy..."
  docker exec "${CONTAINER_NAME}" bash -c "clang-tidy -p build src/main.cpp"
  echo "${BASENAME} clang-format..."
  docker exec "${CONTAINER_NAME}" bash -c "clang-format --dry-run --Werror src/main.cpp"
  echo "${BASENAME} json..."
  docker exec "${CONTAINER_NAME}" bash -c "./bin/format-json.sh schemas/requirement.json"
  docker kill "${CONTAINER_NAME}" > /dev/null
  docker rm "${CONTAINER_NAME}"
fi
