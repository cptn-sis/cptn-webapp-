#!/bin/bash

while [ "$1" != "" ]; do
    case $1 in
        -u | --url )           shift
                                URL_API=$1
                                ;;
        * )                     DIR_APP=$1
    esac
    shift
done

if [ "$DIR_APP" != "" ]; then
    #git checkout develop;
    #npm install;
    echo "Construyendo empaquetado de aplicación \n";
    npm run build;

    sed -i 's,/static/,/'"$DIR_APP"'/static/,g' "dist/index.html";

    if [ "$URL_API" != "" ]; then
      echo "Reemplazando URL de la API por $URL_API";
      find dist/static/js -type f -exec sed -i 's,localhost:3400,'"$URL_API"',g' {} \;
    fi
    
    echo "Deploy en /var/www/html/$DIR_APP";
    cp -r dist/. /var/www/html/$DIR_APP/.;
else
   echo "Es necesario al menos el parámetro de directorio de deploy."
   echo "Por ejemplo: 'webapp' para deploy en '/var/www/html/webapp'"
fi
