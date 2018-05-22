#!/bin/sh

docker run --rm \
  -e APP_UID=1000 -e APP_GID=1000 \
  -e DATABASE_TYPE=MYSQL \
  -e DATABASE_HOST=mysql.example.com \
  -e DATABASE_DATABASE=mydb \
  -e DATABASE_PORT=3306 \
  -e DATABASE_USER=myuser \
  -e DATABASE_PASSWORD=mypass \
  -e DISPLAY=$DISPLAY \
  -v $HOME/.kettle:/home/app/.kettle \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  schoolscout/pentaho-spoon
