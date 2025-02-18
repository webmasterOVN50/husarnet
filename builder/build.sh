#!/bin/bash
source $(dirname "$0")/../util/bash-base.sh

echo "[HUSARNET BS] Building the builder"

pushd ${base_dir}
DOCKER_BUILDKIT=0 docker compose -f builder/compose.yml build builder
popd

echo "To inspect the image manually run:"
echo './builder/shell.sh'
