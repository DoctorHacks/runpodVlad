#!/bin/bash

# webUI startup
if [[ $RUNPOD_STOP_AUTO ]]
then
    echo "Skipping auto-start of webUI"
else
    echo "Started webUI through relauncher script"
    cd /workspace/automatic
    python relauncher.py &
fi

# SSH startup
# Copied from sd-auto-unified start.sh; echoes "ssh: unrecognized service" on
# Pod start
if [[ $PUBLIC_KEY ]]
then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cd ~/.ssh
    echo $PUBLIC_KEY >> authorized_keys
    chmod 700 -R ~/.ssh
    cd /
    service ssh start
    echo "SSH Service Started"
fi

# JupyterLab startup
if [[ $JUPYTER_PASSWORD ]]
then
    cd /
    echo "Starting JupyterLab"
    jupyter lab --allow-root \
    --no-browser \
    --port=8888 \
    --ip=* \
    --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
    --ServerApp.token=$JUPYTER_PASSWORD \
    --ServerApp.allow_origin=* \
    --ServerApp.preferred_dir=/workspace
else
    sleep infinity
fi
