FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y g++ cmake git
RUN apt-get install -y python3 pip python3-venv

WORKDIR workspace

ENV PYTHON_VENV=/opt/venv

RUN python3 -m venv $PYTHON_VENV
ENV PATH=${PYTHON_VENV}/bin:${PATH}

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN pip check
