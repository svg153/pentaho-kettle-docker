#!/bin/sh

PWD=`pwd`

cd kettle
docker build -f Dockerfile --tag kettle .
cd ..

cd spoon
old='FROM schoolscout/pentaho-kettle'
new='FROM kettle'
sed "s%$old%$new%" Dockerfile > Dockerfile-spoon-new
docker build -f Dockerfile-spoon-new --tag spoon .
cd ..

WS_PATH=$PWD/ws

docker run --rm \
  -e APP_UID=1000 -e APP_GID=1000 \
  -e DATABASE_TYPE=MYSQL \
  -e DATABASE_HOST=mysql.example.com \
  -e DATABASE_DATABASE=mydb \
  -e DATABASE_PORT=3306 \
  -e DATABASE_USER=myuser \
  -e DATABASE_PASSWORD=mypass \
  -v $HOME/.kettle:/home/app/.kettle:rw \
  -v $WS_PATH:/home/app/ws/:rw \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  spoon
