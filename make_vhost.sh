#!/bin/bash

end_script(){
   echo -e "${YELLOW}====================================================${CANCEL}\n";
   exit 1;
}

#Funkce pro rollback
rollback(){
    #parametry
    if [[ -z "$1" || -z "$2" ]]; then
        return 1;
    fi;

    VHOST=$2;

    #smaž conf file
    if [[ $1 -ge 1 ]]; then
        rm "/etc/apache2/sites-available/$VHOST.conf"
        echo -e "${RED}ROLLBACK:\t${CANCEL} Removing /etc/apache2/sites-available/$VHOST.conf!";
    fi;

    #smaž složky ve /var/www
    if [[ $1 -ge 2 ]]; then
        rm -r "/var/www/$VHOST";
        echo -e "${RED}ROLLBACK:\t${CANCEL} Removing /var/www/$VHOST!";
    fi;
}

#Základní proměnné
LOCATION=$(dirname "$0");
DEFAULT_IP="127.0.0.1";
GREEN='\033[0;32m';
YELLOW='\033[1;33m';
RED='\033[0;31m';
CANCEL='\033[0m';
BLUE='\033[1;34m';

echo -e "\n${YELLOW}============== STARTING VHOST CREATOR ==============${CANCEL}";

#má práva?
if [ "$EUID" -ne 0 ];then 
    echo -e "${RED}ERROR:\t\t${CANCEL} Please, run as a root!";
    end_script;
    exit 1;
fi

#načti název vhostu
VHOST=$1;
if [[ -z "$VHOST" ]]; then
    echo -e "${RED}ERROR:\t\t${CANCEL} Script expects VHOST as first parameter, none given!";
    end_script;
    exit 1;
fi

#zkontroluj, jestli vhost už existuje
EXISTING=$(a2query -s | grep "^$VHOST" | cut -d' ' -f1);
if [[ -n "$EXISTING" ]]; then
    echo -e "${RED}ERROR:\t\t${CANCEL} This vhost does already exists!";
    end_script;
    exit 1;
fi

#teď začni vytvářet potřebný věci

#vytvoř conf soubor ve sites-available
DEST="/var/www/$VHOST";
export SERVER_NAME="$VHOST";
export ROOT="$DEST/public_html";
export LOGS="$DEST/logs";

if [[ -f "/etc/apache2/sites-available/$VHOST.conf" ]]; then
    echo -e "${RED}ERROR:\t\t${CANCEL} Config file in sites-available/ already exists!";
    end_script;
    exit 1;
fi
envsubst < "$LOCATION/template.conf" > "/etc/apache2/sites-available/$VHOST.conf";
echo -e "${GREEN}STATUS:\t\t${CANCEL} $VHOST.conf file created!";

#složky ve /var/www/
if [[ -d "$DEST" ]] || [[ -d "$LOGS" ]] || [[ -d "$ROOT" ]]; then
    echo -e "${RED}ERROR:\t\t${CANCEL} Couldn't create /var/www/ folders, they already exists!";
    rollback 1 $VHOST;
    end_script;
    exit 1;
else
    mkdir "$DEST" "$LOGS" "$ROOT";
    chown -R $SUDO_USER:www-data $DEST;
    echo "<h1>Hello there!</h1><p>- $VHOST</p>">"$ROOT/index.php";
    echo -e "${GREEN}STATUS:\t\t${CANCEL} /var/www/ folders created!"
fi;

#přidání záznamu do /etc/hosts
NUMBER=$(awk -v line='' '$0 == line {print "", NR, "from", FILENAME}' /etc/hosts | cut -d' ' -f2);
sed -i "${NUMBER}i$DEFAULT_IP\t$VHOST" /etc/hosts;
echo -e "${GREEN}STATUS:\t\t${CANCEL} $VHOST added to /etc/hosts!";

a2ensite "$VHOST" > /dev/null;
service apache2 restart;
echo -e "${GREEN}STATUS:\t\t${CANCEL} Apache restarted!";

echo -e "\n${BLUE}VHOST successfully created! You can place your files in $ROOT!${CANCEL}";
end_script;


