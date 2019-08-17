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
chown -R naemon:naemon /data/usr/local/pnp4nagios/var

chown -R www-data:www-data /data/var/log/thruk /data/etc/thruk

#
# Cambiar permisos para poder escribir
#
chmod 775 /var/cache/naemon

#Modify pnp4nagios.cfg for Naemon

if grep -q 'Nagios' /data/etc/apache2/conf-available/pnp4nagios.conf ; then

echo "Modifying PNP4Nagios config access"
sed -i 's|Nagios|Naemon |' /data/etc/apache2/conf-available/pnp4nagios.conf 
fi

if grep -q 'AuthUserFile /usr/local/nagios/etc/htpasswd.users' /data/etc/apache2/conf-available/pnp4nagios.conf ; then

echo "Modifying PNP4Nagios config access users"
sed -i 's|AuthUserFile /usr/local/nagios/etc/htpasswd.users|AuthUserFile /etc/naemon/htpasswd|' /data/etc/apache2/conf-available/pnp4nagios.conf 
fi

# #Modify config_local.php for Naemon

# if grep -q '$conf[‘nagios_base’] = “/nagios/cgi-bin”;' /data/usr/local/pnp4nagios/etc/config_local.php; then

# echo "Modify config_local.php for Naemon"
# sed -i 's|$conf[‘nagios_base’] = “/nagios/cgi-bin”;|$conf[‘nagios_base’] = “/naemon/cgi-bin”;|' /data/usr/local/pnp4nagios/etc/config_local.php
# fi
# if PNP4Nagios setup not already done  nable Naemon performance data
if grep -q 'process_performance_data=0' /data/etc/naemon/naemon.cfg; then

echo "Started PNP4Nagios setup"
sed -i 's|process_performance_data=0|process_performance_data=1|' /data/etc/naemon/naemon.cfg

cat <<'EOT' >> /data/etc/naemon/naemon.cfg
#
# service performance data
#
service_perfdata_file=/usr/local/pnp4nagios/var/service-perfdata
service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$
service_perfdata_file_mode=a
service_perfdata_file_processing_interval=15
service_perfdata_file_processing_command=process-service-perfdata-file
#
#
#
host_perfdata_file=/usr/local/pnp4nagios/var/host-perfdata
host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$
host_perfdata_file_mode=a
host_perfdata_file_processing_interval=15
host_perfdata_file_processing_command=process-host-perfdata-file
EOT

cat <<'EOT' > /data/etc/naemon/conf.d/pnp4nagios_commands.cfg
define command{
       command_name    process-service-perfdata-file
       command_line    /bin/mv /usr/local/pnp4nagios/var/service-perfdata /usr/local/pnp4nagios/var/spool/service-perfdata.$TIMET$
}
define command{
       command_name    process-host-perfdata-file
       command_line    /bin/mv /usr/local/pnp4nagios/var/host-perfdata /usr/local/pnp4nagios/var/spool/host-perfdata.$TIMET$
}
EOT

cat <<'EOT' >> /data/etc/naemon/conf.d/templates/hosts.cfg
define host {
   name host-pnp
   process_perf_data 1
   action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=_HOST_' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=_HOST_
   register 0
}
EOT

cat <<'EOT' >> /data/etc/naemon/conf.d/templates/services.cfg
define service {
   name service-pnp
   process_perf_data 1
   action_url /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=$SERVICEDESC$
   register 0
}
EOT
fi

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