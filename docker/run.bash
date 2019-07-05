#!/bin/bash


source /data_dirs.env
DATA_PATH=/data

#echo "data{ $1 }" > /etc/naemon/conf.d/host.cfg

for datadir in "${DATA_DIRS[@]}"; do
  if [ ! -e "${DATA_PATH}/${datadir#/*}" ]
  then
    echo "Installing ${datadir}"
    mkdir -p ${DATA_PATH}/${datadir#/*}
    if [ "$(ls -A ${datadir}-template 2> /dev/null)"  ]
    then
      cp -pr ${datadir}-template/* ${DATA_PATH}/${datadir#/*}/
    fi
  fi
done

#
# # En caso de versiones antiguas de Naemon
# # 
# if [ -e /etc/naemon/htpasswd ]
# then
#   echo "UPGRADE: Moving the htpasswd file to the new location..."
#   mv /etc/naemon/htpasswd /etc/thruk/htpasswd
#   # We assume the naemon password was set in an upgrade situation
#   touch /etc/thruk/._install_script_password_set
# fi

# #
# # Para establecer contraseña random
# #
# if [ ! -e /etc/thruk/._install_script_password_set ]
# then
#   RANDOM_PASS=`date +%s | md5sum | base64 | head -c 8`
#   WEB_ADMIN_PASSWORD=${WEB_ADMIN_PASSWORD:-$RANDOM_PASS}
#   htpasswd -bc /etc/thruk/htpasswd thrukadmin ${WEB_ADMIN_PASSWORD}
#   echo "Set the thrukadmin password to: $WEB_ADMIN_PASSWORD"
#   touch /etc/thruk/._install_script_password_set
# fi


#
# Si se actualiza de un contenedor anterior, mover el archivo cgi.cfg
#
if [ -e /etc/naemon/cgi.cfg ]
then
  echo "UPGRADE: Moving the cgi.cfg file to the new location..."
  mv /etc/naemon/cgi.cfg /etc/thruk/cgi.cfg
fi

#
# Establecer autorizaciones
#
WEB_USERS_FULL_ACCESS=${WEB_USERS_FULL_ACCESS:-false}
if [ $WEB_USERS_FULL_ACCESS == true ]
then
  sed -i 's/authorized_for_\(.\+\)=thrukadmin/authorized_for_\1=*/' /etc/thruk/cgi.cfg
fi

#Función de salida para parar servicios

function salida_exitosa(){
  /etc/init.d/apache2 stop
  pkill naemon
  exit $1
}

#
# Asignación de permisos para carpetas nuevas
#
chown -R naemon:naemon /data/etc/naemon /data/var/log/naemon
chown -R www-data:www-data /data/var/log/thruk /data/etc/thruk

#
# Cambiar permisos para poder escribir
#
chmod 775 /var/cache/naemon

# Inicio de servicios
service naemon start
/etc/init.d/apache2 start

# Comprobación de estado Apache y Naemon
trap "salida_exitosa 0;" SIGINT SIGTERM

while true
do
  service naemon status > /dev/null
  if (( $? != 0 ))
  then
    echo "Naemon no longer running"
    salida_exitosa 1
  fi
  
  /etc/init.d/apache2 status > /dev/null
  if (( $? != 0 ))
  then
    echo "Apache no longer running"
    salida_exitosa 2
  fi
  sleep 1
done