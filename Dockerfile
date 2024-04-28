FROM ubuntu:22.04

RUN apt-get update && \
apt-get --no-install-recommends install -y \
g++ cmake make git python3 pip python3-venv clang-tidy clang-format jq && \
apt-get autoremove -y && \
apt-get purge -y --auto-remove && \
rm -rf /var/lib/apt/lists/*

WORKDIR workspace

COPY requirements.txt .
ENV PYTHON_VENV=/opt/venv
ENV PATH=${PYTHON_VENV}/bin:${PATH}

RUN python3 -m venv $PYTHON_VENV && \
pip install -r requirements.txt && \
pip check
