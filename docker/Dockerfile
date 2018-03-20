FROM ubuntu:16.04
MAINTAINER GitLab Inc. <support@gitlab.com>

SHELL ["/bin/sh", "-c"],

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      ca-certificates \
      openssh-server \
      wget \
      apt-transport-https \
      vim \
      tzdata \
      nano \
    && rm -rf /var/lib/apt/lists/* \
    && sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd

# Remove MOTD
RUN rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic
RUN ln -fs /dev/null /run/motd.dynamic

# Resolve error: TERM environment variable not set.
ENV TERM xterm

# Copy assets
COPY assets/ /assets/
RUN /assets/setup

# Allow to access embedded tools
ENV PATH /opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:$PATH

RUN echo '#!/bin/sh \n\
if ! whoami &> /dev/null; then \n\
  if [ -w /etc/passwd ]; then \n\
    echo "openshift:x:$(id -u):0:Openshift user:/opt/gitlab:/sbin/nologin" >> /etc/passwd \n\
  fi \n\
fi \n\
exec "$@" \n' > /assets/uid_entrypoint && chmod a+x /assets/uid_entrypoint

# Ensure that the folders exist and the permissions are right
RUN /bin/bash -c 'export FOLDERS="/opt/gitlab /etc/gitlab /var/opt/gitlab /var/log/gitlab /assets"; \
                  for i in $FOLDERS; \
                  do \
                  [ -d $i ] || mkdir -p $i && touch $i/.empty && chmod g+wrx $i; \
                  ls -lah $i; \
                  chgrp -R 0 $i; \
                  chmod -R g=u $i; \
                  ls -lah $i; \
                  done'

RUN /bin/bash -c 'export TEMP_PATH=/etc/passwd; chmod -R g=u $(echo $TEMP_PATH); chgrp -R 0 $(echo $TEMP_PATH)'

# Expose web & ssh
EXPOSE 443 80 22

# Change the user
USER 1001

# Define data volumes
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
ENTRYPOINT [ "/assets/uid_entrypoint" ]

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/assets/wrapper"]

HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
CMD /opt/gitlab/bin/gitlab-healthcheck --fail
