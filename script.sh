#!/bin/bash



##### ESTILOS

TEXT_BOLD=$(tput bold)     ### ESTILO NEGRITA
TEXT_RESET=$(tput sgr0)    ### RESET
TEXT_RED=$(tput setaf 1)   ### COLOR ROJO
TEXT_CYAN=$(tput setaf 6)  ### COLOR CYAN

##### VARIABLES
DIRECTORIO=
GITIGNORE="node_modules/\ndist/\nbuild/\n.cache/\n.parcel-cache/\n.vscode/"
STYLELINT="{\n  \"extends\": \"stylelint-config-standard\",\n   \"rules\": {}\n}"

##### FUNCIONES

usage()
{   
  echo -e "\n\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo -e "${TEXT_RED}${TEXT_BOLD}\tAyuda : Elija una de las opciones siguientes al ejecutar el script${TEXT_RESET}"
  echo -e "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
  echo -e "${TEXT_CYAN}${TEXT_BOLD}\t./parcel-script.sh [-p | --parcel ] -> Creación de estructura de directorios para proyecto con parcel\n${TEXT_RESET}" 
  echo -e "${TEXT_CYAN}${TEXT_BOLD}\t./parcel-script.sh [-h | --help] -> Guia de ayuda \n${TEXT_RESET}"
}

exit_error()
{
  echo -e "$1" 1>&2
  usage 
  exit 1
}

parcel_build() 
{
  echo "CREANDO ESTRUCTURA DE FICHEROS"
  read -p "Introduzca el nombre del directorio: " directory
  DIRECTORIO=$directory
  mkdir $DIRECTORIO && cd $DIRECTORIO
  mkdir -p src/{css,js,assets} && mkdir dist
  touch src/{index.html,css/index.css,js/index.js}

  echo "|-----------------|"
  echo "Inicializando Git"
  echo "Creando y editando .gitignore..."
  touch .gitignore
  echo -e $GITIGNORE >> .gitignore
  read -p "Indique la dirección ssh del repositorio: " sshAddress
  git init
  echo "Readme" >> README.md
  git add .
  git commit -m "First commit"
  git branch -M main
  git remote add origin $sshAddress
  git push -u origin main

  echo "|-----------------|"
  echo "Instalando paquetes NPM"
  npm init -y
  read -p "¿Desea instalar el paquete stylelint?(y/n): " option
  if [ "$option" == "y" ] 
  then 
      npm install -D stylelint stylelint-config-standard
      echo "Creando y editando .stylelintrc..."
      touch .stylelintrc
      echo -e $STYLELINT >> .stylelintrc
  fi
  read -p "¿Desea instalar el paquete eslint?(y/n): " option
  if [ "$option" == "y" ] 
  then 
      npm install -D eslint
      npx eslint --init
  fi
  read -p "¿Desea instalar el paquete parcel-bundler?(y/n): " option
  if [ "$option" == "y" ] 
  then 
      npm install -D parcel-bundler
  fi

  read -p "¿Desea instalar el paquete gh-pages?(y/n): " option
  if [ "$option" == "y" ] 
  then 
      npm install -D gh-pages
  fi

  echo -e "
  \n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Ahora solo te queda configurar los scripts en tu package.json, si quieres te hago algunas recomendaciones:\n
  \"scripts\": {
    \"start\": \"parcel serve src/index.html\",
    \"build\": \"rm -rf build && parcel build -d build --public-url /projectname/ src/index.html\",
    \"deploy\": \"rm -rf build && parcel build -d build --public-url /projectname/ src/index.html && gh-pages -d build\"
  }
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n
  "
  read -p "¿Desea añadir este script a su package.json?(y/n): " installOption
  if [ "$installOption" == "y" ] 
  then
      if ! type "jq" > /dev/null; then
        read -p "No tiene instalado el comando \"jq\" en su sistema, ¿quiere hacerlo?(y/n): " option
        if [ "$option" == "y" ] 
        then 
            read -p "Elija el sistema(ios | linux): " opSystem
        fi

        if [ "$opSystem" == "linux" ]
        then
          sudo apt-get install jq
        fi

        if [ "$opSystem" == "ios" ]
        then
          brew install jq
        fi
      fi

      read -p "Indique el nombre del repositorio: " name

      variable="rm -rf build && parcel build src/index.html -d build --public-url /"$name"/ && gh-pages -d build"

      jq 'del(.scripts.test)' package.json >> aux.json
      rm -rf package.json && mv aux.json package.json
      jq --arg newVal "$variable" '.scripts.start="parcel serve src/index.html" | .scripts.deploy= $newVal' package.json >> aux.json
      rm -rf package.json && mv aux.json package.json
      cat package.json
  fi
}

if [[ $1 == "" ]]
then
    usage
    exit 0
fi

while [ "$1" != "" ]; do
  case $1 in
    -p | --parcel )
      parcel_build
      exit 0
    ;;
    -h | --help )
      usage
      exit 0
    ;;

    * )
      exit_error "${TEXT_BOLD}Opción desconocida , saliendo...${TEXT_RESET}"
      ;;
  esac
  shift
done
