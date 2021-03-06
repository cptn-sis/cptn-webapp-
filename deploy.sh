#!/bin/bash

env='test'
branch='develop'
ambiente='Testing'

while [ "$1" != "" ]; do
    case $1 in
        -e | --env )           shift
                                env=$1
                                ;;
        * )                     dir_webapp=$1
    esac
    shift
done

if [ $env = "prod" ]; then
    branch='master'
    ambiente='Producción'
fi

if [ "$dir_webapp" != "" ]; then
    echo  "Actualizando repositorio, ambiente de $ambiente"
    git checkout $branch --quiet;
    git pull --quiet;

    echo "Instalando dependencias";
    npm install --silent;
    # npm update ;

    echo "Construyendo empaquetado de aplicación";
    if [ $env = "test" ]; then
        sed -i 's/Vue.use(Vuetify)/Vue.use(Vuetify, { theme: { primary: colors.orange.darken1, secondary: colors.orange.lighten4 } })/g' src/main.js;
    fi

    npm run build --silent;

    if [ $env = "test" ]; then
        sed -i 's/Vue.use(Vuetify, { theme: { primary: colors.orange.darken1, secondary: colors.orange.lighten4 } })/Vue.use(Vuetify)/g' src/main.js;    
    fi

    #sed -i 's,/static/,/'"$dir_webapp"'/static/,g' "dist/index.html";

    echo "Limpieza de archivos antiguos en /var/www/html/$dir_webapp"
    rm -r /var/www/html/$dir_webapp/*

    echo "Copiando Aplicación Web en /var/www/html/$dir_webapp";
    cp -r dist/. /var/www/html/$dir_webapp/.;
    cp src/.htaccess /var/www/html/$dir_webapp/.htaccess;

    echo -e "\e[1;32m Aplicación Web Desplegada Exitosamente :D \e[1;0m"
else
   echo -e "\e[1;31m Es necesario al menos el parámetro de directorio de despliegue \e[1;0m"
   echo -e "\e[1;33m Por ejemplo: 'webapp' para deploy en '/var/www/html/webapp' \e[1;0m"
fi