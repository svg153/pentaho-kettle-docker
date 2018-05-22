FROM schoolscout/pentaho-kettle

RUN apt-get -y install \
        libswt-gtk-3-java \
        firefox \
        libwebkitgtk-1.0-0 \
        > /dev/null 2>&1

CMD ["sh", "./spoon.sh"]
VOLUME ["/home/app/.kettle"]
VOLUME ["/home/app/ws"]
