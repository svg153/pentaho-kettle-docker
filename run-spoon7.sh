#!/bin/bash



#
# -> GLOBAL VARS
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PWD=`pwd`
NAME=`basename "$0"`

#
# <- GLOBAL VARS
#



#
# -> PROJECT VARS
#

docker_app_home_path=/home/app
WS_PATH=${PWD}/ws
KETTLE_DOTFOLDER=${PWD}/.kettle

LAB_CONF_FILEPATH=${WS_PATH}/lab.conf
MYSQL_HOST_PORT=$(grep port /etc/mysql/my.cnf | awk '{print $3}' | head -n -1)
mysql_connection_local_flag=0

KETTLE_DOCKER_IMAGE_TAG="kettle"
SPOON_DOCKER_IMAGE_TAG="spoon"

#
# <- other vars
#



#
# -> FUNCTIONS
#

function print_usage() {
    msg i "Usage: ${NAME} -h | --help"
    msg i "Usage: ${NAME} [OPTIONS]"
    msg i ""
    msg i "  OPTIONS:"
    msg i "    -k <kettle_dotfolder_path> | --kettle-dotfolder=<kettle_dotfolder_path>"
    msg i "        Absolute path of kettle dotfolder."
    msg i "            Default: \"${KETTLE_DOTFOLDER}\""
    msg i ""
    msg i "    -w <workspace_path> | --workspace=<workspace_path>"
    msg i "        Absolute path of your workspace."
    msg i "            Default: \"${WS_PATH}\""
    msg i ""
    msg i "    -c <lab_conf_filepath> | --lab-conf=<lab_conf_filepath>"
    msg i "        Absolute path of your lab-conf."
    msg i "            Default: \"${LAB_CONF_FILEPATH}\""
    msg i ""
    msg i "    -m <mysql_port> | --mysql-port=<mysql_port>"
    msg i "        The port of your local MySQL."
    msg i "            Default: None"
    exit 0
}


function build_kettle() {
  local kettle_dockerfile="Dockerfile"
  cd kettle
  docker build -f ${kettle_dockerfile} --tag ${KETTLE_DOCKER_IMAGE_TAG} .
  cd ..
}

function build_spoon() {
  local spoon_dockerfile="Dockerfile"
  local new_spoon_dockerfile="Dockerfile-spoon-new"
  local old_from='FROM schoolscout/pentaho-kettle'
  local new_from="FROM ${KETTLE_DOCKER_IMAGE_TAG}"
  cd spoon
  sed "s%${old_from}%${new_from}%" ${spoon_dockerfile} > ${new_spoon_dockerfile}
  docker build -f ${new_spoon_dockerfile} --tag ${SPOON_DOCKER_IMAGE_TAG} .
  cd ..
}

function run_spoon() {
  local myuid=`id -u`
  local mygid=`id -g`
  CMD="docker run --rm \
    -e APP_UID=${myuid} -e APP_GID=${mygid} \
    -e DATABASE_TYPE=MYSQL \
    -e DATABASE_HOST=${PDI_LAB_MYSQL_SERVER} \
    -e DATABASE_DATABASE=${PDI_LAB_MYSQL_DATABASE} \
    -e DATABASE_PORT=${PDI_LAB_MYSQL_PORT} \
    -e DATABASE_USER=${PDI_LAB_MYSQL_USER} \
    -e DATABASE_PASSWORD=${PDI_LAB_MYSQL_PASSWORD} \
    "
  if [[ ${mysql_connection_local_flag} -eq 1 ]] ; then
    CMD="${CMD} -p 127.0.0.1:${PDI_LAB_MYSQL_PORT}:${MYSQL_HOST_PORT} \ "
  fi
  CMD="${CMD}
    -v ${KETTLE_DOTFOLDER}:${docker_app_home_path}/.kettle:rw \
    -v ${WS_PATH}:${docker_app_home_path}/ws:rw \
    -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    ${SPOON_DOCKER_IMAGE_TAG}"
  eval ${CMD}
}

function load_labconf() {
  local labconf=${1:-LAB_CONF_FILEPATH}
  [[ -f ${labconf} ]] && echo "ERROR: ${labconf} does not exist"
  export source ${labconf}
  [[ $! -ne 0 ]] && echo "ERROR: ${labconf} format incorrect"
}



function main() {

  argc=$#
  argv=( "$@" )


  #
  # ARGSPARSE
  # 
  
  TEMP=$(getopt -o w:c:k:p:h --long workspace:,lab-conf:,kettle-dotfolder:,mysql-port,h,help, -- "${argv[@]}")
  ex=$?
  [ ${ex} -eq 2 ] && msg e "Parameter is not correct." && exit 1
  [ ${ex} -ne 0 ] && msg e "Error in getopt" && exit 1
  eval set -- "${TEMP}"
  while true ; do
    opt=${1}
    value=${2}
    case ${opt} in
      -w|--workspace )
        WS_PATH=${value} ; exit 0 ;;
      -c|--lab-conf)
        LAB_CONF_FILEPATH=${value} ; shift 2 ; exit 0 ;;
      -k|--kettle-dotfolder )
        KETTLE_DOTFOLDER=${value} ; shift 2 ; exit 0 ;;
      -p|--mysql-port )
        MYSQL_HOST_PORT=${value}
        mysql_connection_local_flag=1
        shift 2 ; exit 0 ;;
      
      -h|-help|--h|--help )
        print_help ; shift 1 ; exit 0 ;;
      --)
        shift 1 ; break ;;
      *)
        print_usage; exit 1 ;;
    esac
  done


  #
  # MAIN
  # 

  build_kettle

  build_spoon

  load_labconf

  run_spoon

}

#
# <- FUNCTIONS
#



#
# -> MAIN
#

main "$@"
exit $?

#
# <- MAIN
#