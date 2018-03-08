FROM alpine:latest

# Which borg version to download
# {freebsd64, linux32, linux64, macosx64}
ENV ARCH linux64

# Prepare environment, create user, etc...
ENV LANG C.UTF-8
RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

RUN adduser -D -g "Borg Backup" borg && \
    mkdir -p /var/run/sshd && \
    mkdir -p /var/backups/borg && \
    mkdir -p /home/borg/.ssh && \
    mkdir -p /home/borg/data

RUN apk add --no-cache \
    borgbackup \
    curl \
    wget \
    bash \
    openssh-server \
    shadow

# Remove keyboard-interactive, password authentication and disable root login from ssh configuration
RUN sed -i -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
           -e 's/^PermitRootLogin without-password$/PermitRootLogin no/g' \
           -e 's/^#ChallengeResponseAuthentication yes$/ChallengeResponseAuthentication no/g' \
    /etc/ssh/sshd_config

# https://unix.stackexchange.com/questions/193066/how-to-unlock-account-for-public-key-ssh-authorization-but-not-for-password-aut
# On Linux, you can disable password-based access to an account while allowing SSH access (with some other authentication method, typically a key pair) with
RUN usermod -p '*' borg
# The user won't be able to change the account back to having a password, because that requires them to enter a valid password.

# Install Borg
WORKDIR /tmp
RUN curl https://api.github.com/repos/borgbackup/borg/releases/latest | grep "browser_download_url" | grep $ARCH | grep -v ".asc" | cut -d : -f 2,3 | tr -d "\" " | wget -i -
RUN mv borg* /usr/local/bin/borg && chown root:root /usr/local/bin/borg && chmod 755 /usr/local/bin/borg

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
