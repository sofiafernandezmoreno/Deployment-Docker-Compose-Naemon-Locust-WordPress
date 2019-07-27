# Docker Naemon TFG Sofía Fernández Moreno

[Naemon](http://www.naemon.org) imagen lista para su despliegue. 
1. Configuración de naemon a través del volumen `/data` acceso desde `/var/lib/docker/volumes`


## Creación de imagen
```
docker build -t chui274/naemontfg .
```

## Run composer

```
 docker-compose up
```

## Run compose with 3 worker instances

```
 docker-compose up --scale locust-worker=3

```

## Remove the container and default network, but preserves database.

```
 docker-compose down

```


## Remove the container and default network and database.

```
 docker-compose down --volumes

```  

## Variables de entorno


### Thruk  Configuración 
* __WEB_ADMIN_PASSWORD__: The password to use for the thrukadmin user. The default is a randomly generated password that will be output on the command line at initial setup.
* __WEB_USERS_FULL_ACCESS__: Allow all authenticated users full access to the Web UI monitoring. Useful for situations where the `WEB_LDAP_FILTER` already restricts access to users with specific attributes. Default `false`.


## Gestionar Configuración de Naemon Confiuration

La configuración de Naemon puede ser encontrada en el volumen  `/data/etc/naemon/` y puede ser gestionada a través de su interfaz de monitorización Thruk o el sistema de archivos propio de Naemon.


# Nueva actualización: 
1. Cambios referentes al enlazado del host
2. Creación de wordpress para generar balanceo de carga
3. Especificación para comenzar con la creación de la variable de entorno para poder acceder al archivo de configuración de host y enlazarlo con wordpress


# Proxima versión: Realización de pruebas de carga a través de la herramienta Locust con balanceo de carga de WordPress




