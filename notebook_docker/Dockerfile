FROM ubuntu:latest

# If you are using Linux, USERID would be important to share files between container and host.
# For Windows, Windows file has permission 777, and Windows user can read all the files.
ARG USERID=1000
ARG PASSWORD=neo
# USERNAME is just internal and fixed (to use it in chown option for ADD)
ENV USERNAME=neo
ENV SHELL=/bin/bash

USER root
RUN apt-get update \
    && apt-get install -y \
        g++ \
        make \
        bzip2 \
        wget \
        unzip \
        sudo \
        git \
        nkf \
        libpng-dev libfreetype6-dev \
        postgresql-client libpq-dev \
        sqlite3 \
        graphviz \
        python3-dev \
        python3-pip \
        python3-venv

# remove ubuntu user to use UID 1000 for us
RUN userdel -rf ubuntu
RUN useradd --no-log-init --create-home -ms /bin/bash --uid ${USERID} ${USERNAME}
RUN usermod -aG sudo ${USERNAME}
RUN echo "${USERNAME}:${PASSWORD}" | chpasswd

USER ${USERNAME}
WORKDIR /home/${USERNAME}/
RUN mkdir -p /home/${USERNAME}/pythonlib \
        /home/${USERNAME}/notebook_workspace  
ADD --chown=${USERNAME}:${USERNAME} context/pythonlib /home/${USERNAME}/pythonlib
ADD --chown=${USERNAME}:${USERNAME} context/00-first.ipy /home/${USERNAME}/.ipython/profile_default/startup/
ADD --chown=${USERNAME}:${USERNAME} context/jupyter_notebook_config.py /home/${USERNAME}/.jupyter/

# To install cuid
ENV LANG=en_US.UTF-8
RUN python3 -m venv venv && chmod 700 ./venv/bin/activate
RUN venv/bin/pip install -U pip setuptools
RUN venv/bin/pip install jupyter notebook pandas
RUN venv/bin/pip install -r /home/${USERNAME}/pythonlib/requirements.txt

WORKDIR /home/${USERNAME}/notebook_workspace
EXPOSE 8888
ENV PYTHONPATH=/home/${USERNAME}/pythonlib/
ENV PATH=/home/${USERNAME}/venv/bin:$PATH
CMD ["../venv/bin/jupyter", "notebook"]
