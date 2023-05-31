# Get some prerequisites out of the way
FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04 as prerequisites

# for software-properties-common prompts
ENV DEBIAN_FRONTEND noninteractive

# Update, install dependencies, clean stuff up
RUN apt update && \
    apt upgrade -y && \
    apt install --yes --no-install-recommends \
    git \
    # for pip installation
    curl \
    # for add-apt-repository (which is needed for installing python 3.10)
    software-properties-common \
    # for copying files back to /workspace in start.sh
    rsync \
    # for something start_server needs in launch.py
    libgl1 \
    # something else start_server needs
    libglib2.0-0 && \
    apt autoremove -y && \
    apt clean -y

# Remove python 3.8, install python 3.10 & 3.10-venv, set symlinks
# python -> python3.10
# python3 -> python3.10
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt purge --yes --auto-remove python3.8 && \
    apt install --yes --no-install-recommends python3.10 python3.10-venv && \
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    apt autoremove -y && \
    apt clean -y

# pip installation (for JupyterLab, among other things)
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip install --no-cache-dir jupyterlab \
    # xformers isn't used under Vlad default settings, but is an option
    # xformers \
    && \
    rm -rf /root/.cache/pip

# Build stage; sets everything up in /workspace/automatic
FROM prerequisites AS builder

# Begin installing Vlad Diffusion
# Clone repo, create python virtual environment
WORKDIR /workspace
RUN git clone https://github.com/vladmandic/automatic
WORKDIR /workspace/automatic
RUN python -m venv /workspace/automatic/venv
ENV PATH="/workspace/automatic/venv/bin:$PATH"

# Install required modules
ADD install.py .
RUN python -m install && \
    rm -rf /root/.cache/pip

# Copy in the Stable Diffusion models
COPY --from=runpod/stable-diffusion:models-1.0.0 SDv1-5.ckpt /workspace/automatic/models/Stable-diffusion/
COPY --from=runpod/stable-diffusion:models-1.0.0 SDv2-768.ckpt /workspace/automatic/models/Stable-diffusion/

# final stage; copy /workspace/automatic to root dir (copied back in start.sh)
FROM prerequisites AS final
COPY --from=builder /workspace /

# start.sh -> relauncher.py -> webui.sh (reads from webui-user.sh) -> launch.py
ADD start.sh /
ADD relauncher.py /automatic/
ADD webui-user.sh /automatic/
RUN chmod a+x /start.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
CMD [ "./start.sh" ]
