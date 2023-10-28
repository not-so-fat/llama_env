FROM ubuntu:latest

# USERID is important if you want to access files on host (refer build.sh also)
ARG USERID=8888
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
        python3-pip

RUN pip3 install virtualenv

RUN useradd -ms /bin/bash --uid ${USERID} ${USERNAME}
RUN usermod -aG sudo ${USERNAME}
RUN echo "${USERNAME}:${PASSWORD}" | chpasswd
RUN mkdir -p /home/${USERNAME}
RUN chown -R ${USERNAME} /home/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}/
RUN mkdir -p /home/${USERNAME}/pythonlib \
        /home/${USERNAME}/notebook_workspace \
        /home/${USERNAME}/install \
        /home/${USERNAME}/llama2
ADD --chown=${USERNAME}:${USERNAME} context/pythonlib /home/${USERNAME}/pythonlib
ADD --chown=${USERNAME}:${USERNAME} context/00-first.ipy /home/${USERNAME}/.ipython/profile_default/startup/
ADD --chown=${USERNAME}:${USERNAME} context/jupyter_notebook_config.py /home/${USERNAME}/.jupyter/
ADD --chown=${USERNAME}:${USERNAME} context/ggml-model-q4_0.gguf /home/${USERNAME}/llama2/


WORKDIR /home/${USERNAME}/llama2
ENV LLAMA_PATH=/home/${USERNAME}/llama2/ggml-model-q4_0.gguf

# To install cuid
WORKDIR /home/${USERNAME}/
ENV LANG=en_US.UTF-8
RUN virtualenv -p python3 venv && chmod 700 ./venv/bin/activate
RUN venv/bin/pip install -U pip setuptools
RUN venv/bin/pip install jupyter notebook pandas
RUN venv/bin/pip install -r /home/${USERNAME}/pythonlib/requirements.txt
RUN FORCE_CMAKE=1 venv/bin/pip install llama-cpp-python
RUN venv/bin/pip install pypdf sentence-transformers chromadb langchain

WORKDIR /home/${USERNAME}/notebook_workspace
EXPOSE 8888
ENV PYTHONPATH=/home/${USERNAME}/pythonlib/
ENV PATH=/home/${USERNAME}/venv/bin:$PATH
CMD ["jupyter", "notebook"]
