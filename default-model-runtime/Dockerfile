# Get some prerequisites out of the way
FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04 AS prerequisites

# for software-properties-common prompts
ENV DEBIAN_FRONTEND noninteractive

RUN \
    # general updates
    apt update && \
    apt upgrade -y && \

    # dependency installs
    apt install --yes --no-install-recommends \
    # to clone Vlad repo, and is used in install.py
    git \
    # stuff start_server needs in launch.py
    libgl1 libglib2.0-0 \

    # These are only needed to install other things, and are removed later in
    # this RUN instruction.
    # software-properties-common installs add-apt-repository installs Python3.10
    # curl needed for get-pip.py
    software-properties-common curl && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    apt purge --auto-remove --yes curl && \

    # Install Python3.10 & Python3.10-venv, uninstall Python3.8 (installed w/
    # software-properties-common) and the Python3.10/Python3.10-venv installers,
    # set python3 and python symlinks
    add-apt-repository ppa:deadsnakes/ppa && \
    apt install --yes --no-install-recommends python3.10 python3.10-venv && \
    add-apt-repository --remove ppa:deadsnakes/ppa && \
    apt purge --yes --auto-remove python3.8 software-properties-common && \
    # set Python and Python3 symlinks to point to Python3.10
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \

    # installs pip (obv)
    python get-pip.py && \

    # clean up
    rm get-pip.py && \
    apt autoremove -y && \
    apt clean -y

# Build stage; sets everything up in /workspace/automatic
FROM prerequisites AS builder

# Begin installing Vlad Diffusion
# Clone repo, create python virtual environment
WORKDIR /workspace
RUN git clone https://github.com/vladmandic/automatic
WORKDIR /workspace/automatic
RUN python -m venv /workspace/automatic/venv

# Install Vlad required modules and JupyterLab
ADD install.py .
RUN . /workspace/automatic/venv/bin/activate && \
    python -m install && \
    # TensorFlow (for Vlad) is otherwise installed at runtime
    pip install --upgrade --no-cache-dir tensorflow==2.12.0 \
    jupyterlab \
    # xformers \
    && \
    rm -rf /root/.cache/pip

# Final stage; copy /workspace/automatic to root dir (copied back in start.sh)
FROM prerequisites AS final
COPY --from=builder /workspace /

# Copy in the Stable Diffusion models
COPY --from=runpod/stable-diffusion:models-1.0.0 SDv1-5.ckpt /automatic/models/Stable-diffusion/
COPY --from=runpod/stable-diffusion:models-1.0.0 SDv2-768.ckpt /automatic/models/Stable-diffusion/

# start.sh -> relauncher.py -> webui.sh (reads from webui-user.sh) -> launch.py
ADD start.sh /
ADD relauncher.py /automatic/
ADD webui-user.sh /automatic/
RUN chmod a+x /start.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
CMD [ "./start.sh" ]
