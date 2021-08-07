ARG pyversion=latest
FROM python:${pyversion}

RUN \
  apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    gosu \
    sudo \
    wait-for-it \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install poetry

RUN \
  useradd -ms /bin/bash builder \
  && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
RUN \
  echo '. <(buildenv init)' >> ~/.bashrc \
  && git config --global user.email "builder@poetry" \
  && git config --global user.name "poetry builder" \
  && poetry config virtualenvs.in-project true

USER root
WORKDIR /home/builder

ENV \
  DEFAULT_SCRIPT=python \
  GIT_REPO="" \
  LANG=C.UTF-8

COPY buildenv/entrypoint.sh /buildenv-entrypoint.sh
COPY buildenv/buildenv.sh /usr/local/bin/buildenv

COPY buildenv/buildenv.conf /etc/
COPY buildenv.d/ /etc/buildenv.d/

RUN sed -i 's/^#DOTCMDS=.*/DOTCMDS=setup/' /etc/buildenv.conf

ENTRYPOINT ["/buildenv-entrypoint.sh"]
CMD ["/bin/bash"]
