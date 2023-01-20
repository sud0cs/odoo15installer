#!/bin/bash
sudo clear
port='"8069:8069"'
echo "########################################"
echo "#                                      #"
echo "#        WELCOME TO ODOOINSTALL        #"
echo "#                                      #"
echo "########################################"
echo ""
echo ""
echo "1) Odoo 15"
echo "2) Odoo 15 production via Docker"
echo "3) Odoo 15 development version via Docker"
echo "4) Odoo 15 production via Docker (docker-compose)"
echo "5) Odoo 15 development version via Docker (docker-compose)"
read installMethod
clear
if [[ $installMethod -eq 1 ]]
then
    echo Updating...
    echo ""
    sudo apt update > /dev/null
    echo "#######################################"
    echo ""
    echo Installing Python and Postgres...
    sudo apt install python3 python3-pip postgresql postgresql-client git -y > /dev/null
    echo ""
    echo "#######################################"
    echo ""
    echo Downloading Odoo...
    git clone https://github.com/Odoo/odoo.git --depth 1 --branch 15.0 --single-branch odoo > /dev/null
    clear
    echo "Creating Postgres user $(whoami)..."
    sudo su -c "createuser -d -P $(whoami)" postgres
    sudo apt-add-repository -y "deb http://security.ubuntu.com/ubuntu
    focal-security main"
    clear
    echo Installing dependencies...
    sudo apt-get -yq update > /dev/null
    sudo apt install python3-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev libssl1.1 zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libpq-dev software-properties-common libxrender1 libfontconfig1 libx11-dev libjpeg62 libxtst6 fontconfig xfonts-75dpi xfonts-base libjpeg-turbo8 wget -y > /dev/null
    echo ""
    echo "#######################################"
    echo ""
    echo Installing required Python packages...
    pip3 install setuptools wheel PyPDF2 > /dev/null
    pip3 install -r "/home/$(whoami)/odoo/requirements.txt"
    wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb -O pdf.deb
    sudo dpkg -i "/home/$(whoami)/pdf.deb"
    "/home/$(whoami)/odoo/odoo-bin"
else
    echo Installing Docker...
    sudo apt-get update > /dev/null
    sudo apt-get install ca-certificates curl gnupg lsb-release -y > /dev/null
    sudo mkdir -p /etc/apt/keyrings > /dev/null
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update > /dev/null
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y> /dev/null
    clear
    if [[ $installMethod -eq 2 ]]
    then
        echo Installing Postgres...
        echo ""
        echo "#######################################"
        echo ""
        sudo docker run -d -v /home/$(whoami)/odooProd/dataPG:/var/lib/postgresql/data -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:13
        clear
        echo Installing Odoo... Remember to ctrl c when odoo starts!
        echo ""
        echo "#######################################"
        echo ""
        sudo docker run -d -p 8069:8069 --name odoo --link db:db -t odoo:15
        sudo docker stop odoo > /dev/null
        sudo docker stop db > /dev/null
        echo ""
        echo "#######################################"
        echo ""
        echo To start odoo use:
        echo sudo docker start db
        echo sudo docker start odoo
    fi
    if [[ $installMethod -eq 3 ]]
    then
        echo Installing Postgres...
        echo ""
        echo "#######################################"
        echo ""
        sudo docker run -d -v /home/$(whoami)/odooDev/dataPG:/var/lib/postgresql/data -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:13
        clear
        echo Installing Odoo... Remember to ctrl c when odoo starts!
        echo ""
        echo "#######################################"
        echo ""
        sudo docker run -d -v /home/$(whoami)/odooDev/volumesOdoo/addons:/mnt/extra-addons -v /home/$(whoami)/odooDev/volumesOdoo/firestore:/var/lib/odoo/filestore -v /home/usuari/$(whoami)/volumesOdoo/sessions:/var/lib/odoo/sessions -p 8069:8069 --name odoodev --user="root" --link db:db -t odoo:15 --dev=all
        sudo docker stop odoo > /dev/null
        sudo docker stop db > /dev/null
        echo ""
        echo "#######################################"
        echo ""
        echo To start odoo use:
        echo sudo docker start db
        echo sudo docker start odoodev
    fi
    if [[ $installMethod -eq 4 ]]
    then
        echo "version: '3.1'
services:
  web:
    image: odoo:15.0
    depends_on:
      - db
    ports:
      - $port
    volumes:
      - odoo-web-data:/var/lib/odoo
      - ./config:/etc/odoo
      - ./addons:/mnt/extra-addons
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - /home/$(whoami)/odooDev/dataPG:/var/lib/postgresql/data
volumes:
  odoo-web-data:
  odoo-db-data:" > docker-compose.yml
        sudo docker-compose up
    fi
    if [[ $installMethod -eq 5 ]]
    then
        echo "version: '3.1'
services:
  web:
    image: odoo:15.0
    depends_on:
      - db
    ports:
      - $port
    volumes:
      - odoo-web-data:/var/lib/odoo
      - ./config:/etc/odoo
      - /home/$(whoami)/odooDev/volumesOdoo/addons:/mnt/extra-addons
      - /home/$(whoami)/odooDev/volumesOdoo/firestore:/var/lib/odoo/filestore
      - /home/$(whoami)/odooDev/volumesOdoo/sessions:/var/lib/odoo/sessions
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - /home/$(whoami)/odooDev/dataPG:/var/lib/postgresql/data
volumes:
  odoo-web-data:
  odoo-db-data:" > docker-compose.yml
        sudo docker-compose up
    fi
fi