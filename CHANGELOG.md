# Changes

## 2018/05/22

* Added [`.editorconfig`] file.
* Remove `ssh` (security problems, better connect by VPN and ssh, and then `docker exec -it NAME /bin/bash`)
* Added [`.gitignore`].
* Improved [`run-spoon7.sh`] more modular and now permit args by cli.
* Installed `libwebkitgtk-1.0-0` because of this [error](https://jira.pentaho.com/browse/PDI-17062)

## 2017/04/24

* Updated Pentaho Data Integration to 7 -> [`kettle/Dockerfile`] line 34
  * Change the `WORKDIR` to `/usr/src/app/data-integration`
* Updated JDBC -> [`kettle/Dockerfile`] line 39
  * In version 7 the `libext/JDBC/` doesn't exist, so I had to copy into `/usr/src/app/data-integration/lib`
* Make ws (workspace) volume to share the project folder ->
  * [`kettle/configure_adn_start`] line 5
  * [`spoon/Dockerfile`] line 7
  * [`spoon/README.md`] line 9 and 20
  * [`run-spoon7.sh`] line 16 and 27

[`kettle/Dockerfile`]: kettle/Dockerfile
[`kettle/configure_adn_start`]: kettle/configure_adn_start
[`spoon/Dockerfile`]: spoon/Dockerfile
[`spoon/README.md`]: spoon/README.md
[`run-spoon7.sh`]: run-spoon7.sh
[`.gitignore`]: .gitignore
[`.editorconfig`]: .editorconfig