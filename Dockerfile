FROM ubuntu:22.04

RUN apt-get update && \
apt-get --no-install-recommends install -y \
g++="4:11.2.0-1ubuntu1" \
cmake="3.22.1-1ubuntu1.22.04.2" \
make="4.3-4.1build1" \
git="1:2.34.1-1ubuntu1.10" \
python3="3.10.6-1~22.04" \
python3-pip="22.0.2+dfsg-1ubuntu0.4" \
python3-venv="3.10.6-1~22.04" \
clang-tidy="1:14.0-55~exp2" \
clang-format="1:14.0-55~exp2" \
jq="1.6-2.1ubuntu3" \
ccache="4.5.1-1" && \
apt-get autoremove -y && \
apt-get purge -y --auto-remove && \
rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY requirements.txt .
ENV PYTHON_VENV=/opt/venv
ENV PATH=${PYTHON_VENV}/bin:${PATH}

RUN python3 -m venv $PYTHON_VENV && \
pip install --no-cache-dir -r requirements.txt && \
pip check
