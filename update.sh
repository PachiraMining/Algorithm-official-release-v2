#!/bin/bash


if [ ${#2} -lt 5 ]; then
    echo "Version $2"
    echo "Version length < 5"
    exit 0
fi


# Function to check and delete file if it exists

 wasRunningAstrix=0
 wasRunningIronfish=0
 wasRunningHoohash=0
 wasRunningWala=0

 #phase out out date services

 sudo systemctl stop teamredminer.service
 sudo systemctl stop firmware_update.service
 sudo systemctl stop kaspa.service
 sudo systemctl stop radiant.service
 sudo systemctl stop etica.service
 sudo systemctl stop alephium.service
 sudo systemctl stop gram.service
 sudo systemctl stop k1miner.service

 sudo systemctl disable teamredminer.service
 sudo systemctl disable kaspa.service
 sudo systemctl disable radiant.service
 sudo systemctl disable etica.service
 sudo systemctl disable alephium.service
 sudo systemctl disable gram.service
 sudo systemctl disable k1miner.service
 

echo "+++++++++++++++++++++++++++++++++++ START UPDATE SCRIPT ++++++++++++++++++++++++++++++++++"
if [ -z "$1" ]; then
    echo "require a path"
else
    # ================================== update modules ================================
    echo "================================== update modules ================================"

    pwd

    # make folder

    #keep old status
    if systemctl is-active --quiet astrix.service; then
        wasRunningAstrix=1  
        echo $wasRunningAstrix
    else
        wasRunningAstrix=0
        echo $wasRunningAstrix  
    fi

    if systemctl is-active --quiet ironfish.service; then
        wasRunningIronfish=1  
        echo $wasRunningIronfish
    else
        wasRunningIronfish=0
        echo $wasRunningIronfish  
    fi

    if systemctl is-active --quiet hoohash.service; then
        wasRunningHoohash=1  
        echo $wasRunningHoohash
    else
        wasRunningHoohash=0
        echo $wasRunningHoohash  
    fi

    if systemctl is-active --quiet wala.service; then
        wasRunningWala=1  
        echo $wasRunningWala
    else
        wasRunningWala=0
        echo $wasRunningWala  
    fi


    # stop all service
    echo "stop apache2222222222"
    sudo systemctl stop webserver.service
    sudo systemctl kill webserver.service
    sudo systemctl stop apache2.service
    sudo systemctl kill apache2.service
    sudo systemctl stop frontail.service
    ps -aux |grep qcmap_web_cgi.cgi |  awk '{print $2}' |sudo  xargs kill -9

    sudo systemctl stop xvc_server_1.service
    sudo systemctl stop xvc_server_2.service
    sudo systemctl stop xvc_server_3.service
    sudo systemctl disable xvc_server_1.service
    sudo systemctl disable xvc_server_2.service
    sudo systemctl disable xvc_server_3.service


    sudo systemctl stop alephium_trm.service
    sudo systemctl stop alephium_wf.service
    sudo systemctl stop  radiant.service

    sudo systemctl stop astrix.service  
    sudo systemctl stop wala.service  
    sudo systemctl stop hoohash.service  
    sudo systemctl stop pyrin.service  
    sudo systemctl stop ironfish.service   
    sudo systemctl stop nexell.service 

    # copy services
    sudo cp -R $1/modules/* /opt/
    sudo cp -r $1/modules/services/* /etc/systemd/system/
    
    sudo chmod 777 /opt/*/*
    #copy frontail and update apache2 rsyslog.conf
    sudo chmod 777 /etc/apache2/mods-available/dir.conf

    echo "================================== update modules done! ============================="

    echo "================================== update web ======================================="

    sudo cp $1/web/cgi/qcmap_web_cgi.cgi /usr/lib/cgi-bin/qcmap_web_cgi.cgi
    sudo cp  $1/modules/trm/dir.conf /etc/apache2/mods-available/dir.conf
    sudo cp $1/web/cgi/qcmap_web_cgi.cgi /usr/sbin/qcmap_web_cgi.cgi
    sudo cp $1/modules/trm/webserver /usr/sbin/webserver
    sudo cp -r $1/modules/trm /opt/

    sudo chmod 777 /usr/sbin/webserver
     

    sudo cp $1/web/cgi/qcmap_auth.cgi /usr/lib/cgi-bin/qcmap_auth.cgi
    sudo chmod 777  /usr/lib/cgi-bin*

    sudo cp -R  $1/web/html/* /var/www/html/
    sudo chown -R www-data:www-data /var/www/html/
    

    echo "start apache2"
    sudo systemctl start apache2
    sudo systemctl start frontail.service
    echo "================================== update web done! ================================="

    
    sudo systemctl restart webserver.service  
    # restart
 
    # sudo systemctl daemon-reload

    # create apps dir

    if [ ${#2} -ge 5 ]; then
        sudo echo $2 > /opt/algorithm/algorithm_version.txt
    fi

    # echo "================================== reboot ================================="


    if [[ $wasRunningAstrix -eq 1 ]]; then
        sudo systemctl restart astrix.service
        echo "Astrix service restarted."
    fi

    if [[ $wasRunningHoohash -eq 1 ]]; then
        sudo systemctl restart hoohash.service
        echo "hoohash service restarted."
    fi

    if [[ $wasRunningIronfish -eq 1 ]]; then
        sudo systemctl restart ironfish.service
        echo "ironfish service restarted."
    fi

    if [[ $wasRunningWala -eq 1 ]]; then
        sudo systemctl restart wala.service
        echo "wala service restarted."
    fi

fi
 sudo systemctl start firmware_update.service
sudo systemctl daemon-reload
echo "+++++++++++++++++++++++++++++++++++ DONE UPDATE SCRIPT ++++++++++++++++++++++++++++++++++"
