#!/bin/bash


source /data_dirs.env
DATA_PATH=/data


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
# Si se actualiza de un contenedor anterior, mover el archivo cgi.cfg
#
if [ -e /etc/naemon/cgi.cfg ]
then
  echo "UPGRADE: Moving the cgi.cfg file to the new location..."
  mv /etc/naemon/cgi.cfg /etc/thruk/cgi.cfg
fi


# #
# # Si existe carpeta /etc/naemon/conf.d borrar archivos
# if [ -e /etc/naemon/conf.d/contacts.cfg]
# then
#   echo "Remove files"
#   rm -r /etc/naemon/conf.d/contacts.cfg
 

# fi
# #
# # Si existe carpeta /etc/naemon/conf.d borrar archivos
# if [ -e /etc/naemon/conf.d/printer.cfg]
# then
#   echo "Remove files"
#   rm -r /etc/naemon/conf.d/printer.cfg
  
# fi
# #
# # Si existe carpeta /etc/naemon/conf.d borrar archivos
# if [ -e /etc/naemon/conf.d/switch.cfg]
# then
#   echo "Remove files"
  
#   rm -r /etc/naemon/conf.d/switch.cfg
  

# fi
# # Si existe carpeta /etc/naemon/conf.d borrar archivos
# if [ -e /etc/naemon/conf.d/windows.cfg]
# then
#   echo "Remove files"
#   rm -r /etc/naemon/conf.d/windows.cfg
# fi

# #
# # Si existe carpeta /etc/naemon/conf.d/templates borrarla
# #
# if [ -e /etc/naemon/conf.d/templates ]
# then
#   echo "Remove directory templates"
#   rm -R  /etc/naemon/conf.d/templates
# fi
#
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