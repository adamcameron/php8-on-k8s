FROM mariadb:10.11-jammy

RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "zip", "unzip", "git", "vim"]

RUN echo "alias ll='ls -alF'" >> ~/.bashrc
RUN echo "alias cls='clear; printf \"\033[3J\"'" >> ~/.bashrc

COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=30s \
    --retries=3 \
    CMD sh -c 'mysqladmin ping -h localhost -u $MARIADB_USER --password=$MARIADB_PASSWORD || exit 1'

CMD ["mariadbd"]

EXPOSE 3306
