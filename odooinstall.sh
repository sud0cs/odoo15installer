#!/bin/bash
sudo clear
if [ "$UID" -eq 0 ] 
then
    echo 
    echo "########################################"
    echo "#                                      #"
    echo "#        WELCOME TO ODOOINSTALL        #"
    echo "#                                      #"
    echo "########################################"
    echo ""
    echo ""
    read -p "Are you sure? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        clear
        echo Updating...
        echo ""
        sudo apt-get update > /dev/null
        echo "#######################################"
        echo ""
        echo Installing Python and Postgres...
        sudo apt-get install python3 python3-pip postgresql postgresql-client git -yq
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
        sudo apt-get -yq update
        sudo apt-get install python3-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev libssl1.1 zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libpq-dev software-properties-common libxrender1 libfontconfig1 libx11-dev libjpeg62 libxtst6 fontconfig xfonts-75dpi xfonts-base libjpeg-turbo8 wget -yq
        echo ""
        echo "#######################################"
        echo ""
        echo Installing required Python packages...
        pip3 install setuptools wheel PyPDF2 > /dev/null
        pip3 install -r "/home/$(whoami)/odoo/requirements.txt" > /dev/null
        wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb -O pdf.deb
        sudo dpkg -i "/home/$(whoami)/pdf.deb" > /dev/null
        "/home/$(whoami)/odoo/odoo-bin"
    fi  
fi
