const nodemailer = require('nodemailer');
const axios = require('axios');
var fs = require("fs");
const util = require('util');
const exec = util.promisify(require('child_process').exec);
var miner_status = " ";

function runCommand(command, onSuccessResult = null, onErrorResult = null) {
    return new Promise(resolve => {
        exec(command)
            .then(res => {
               resolve(onSuccessResult == null ? res.stdout.replace(/\n/g, '<br/>') : onSuccessResult);
            }).catch(err => {
                resolve(onErrorResult == null ? err : onErrorResult);
            });
    });
}

function sendMail(parseConfigEmail, macAddress, resultFPGA, miner_status, log_status, parseFan) {
    //return Promise.resolve();
    let transporter = nodemailer.createTransport({
        host: "smtp.gmail.com",
        port: 465,
        secure: true, // true for 465, false for other ports
        auth: {
            user: "notifications@dracaena.io", // generated ethereal user
            pass: "zoysydmgzgjedffq", // generated ethereal password
        },
    });


    var header_test = '<h1> Notification from E300 miner</h1>';
  

    header_test = header_test + '<b>E300 network mac addess</b>  : ' + ' ' + macAddress + ' ';
    header_test = header_test + '<br>';
      header_test = header_test + '<br>';

    if (parseConfigEmail.over_heat_temp_noti == 1)
    {
            header_test = header_test + '<b> FPGA temperatures information:</b> <br>';
 
    header_test = header_test + 'FPGA 0: Chip temperature : ' + ' ' + resultFPGA[0].chipTemp + ' ' + 'Board temperature : ' + ' ' + resultFPGA[0].boardTemp;
    header_test = header_test + '<br>';
    header_test = header_test + 'FPGA 1: Chip temperature : ' + ' ' + resultFPGA[1].chipTemp + ' ' + 'Board temperature : ' + ' ' + resultFPGA[1].boardTemp;
    header_test = header_test + '<br>';
    header_test = header_test + 'FPGA 2: Chip temperature : ' + ' ' + resultFPGA[2].chipTemp + ' ' + 'Board temperature : ' + ' ' + resultFPGA[2].boardTemp;
    header_test = header_test + '<br><br>';
    }
    

    if (parseConfigEmail.enable_miner_status_noti == 1)
    {
  
        header_test = header_test + '<b>Miner status</b>  : ' + miner_status.status + '<br> ';    
    }

    if (parseConfigEmail.enable_fan_noti == 1)
    {
        header_test = header_test + '<br>';
        header_test = header_test + '<b> Fans Information:</b> <br>';
        if (parseFan.fan_mode == 0)
        {
        	header_test = header_test + 'Fans mode  : Auto';
        }
        else
        {
        	header_test = header_test + 'Fans mode  : Manual';
        }
        
        header_test = header_test + '<br>';
        header_test = header_test + 'Current level  : ' + parseFan.current_fan_level + ' ';        
    }


   console.log(log_status);

    return transporter.sendMail({
        from: 'Osprey Notification <notifications@dracaena.io>',
        to: parseConfigEmail.desti_email_noti,
        subject: 'OSPREY E300 miner notification: ' + macAddress,
        text: 'your miner got high temps',
        html: header_test,
    });
}

const readEmailConfigFile = axios.get('http://localhost:8200/controller/getEmailConfig');
const readInterfacesFile = fs.promises.readFile('/etc/network/interfaces');
const getAllInfo = axios.get('http://localhost:8200/controller/getAllInfo');
//const getMinerStatus = runCommand('pidof teamredminer', 'online', 'offline'); 
const getMinerStatus = axios.get('http://localhost:8200/controller/getMiningSatus');

//const getLog = runCommand("tail -100 /var/log/syslog | grep 'E300\\|ethash' | cut -d ' ' -f 6-", null, 'no log');
const getLog = runCommand("tail -100 /var/log/syslog | grep 'ethash:' | cut -d ' ' -f 6-", null, 'no log');
const getAllFInfo = axios.get('http://localhost:8200/controller/getAllFanInfo');

//const getLog = runCommand("tail  -100 /var/log/syslog | grep 'E300' | cut -d ' ' -f 6-", null, 'no log');




Promise.all([readEmailConfigFile, readInterfacesFile, getAllInfo, getMinerStatus, getLog, getAllFInfo])

    .then(res => {
        let parseConfigEmail = res[0].data; //JSON.parse(res[0]);
        var network_config = res[1].toString();
        let index = network_config.indexOf("hwaddress ether"); //string leng hwaddress ether is 15
        macAddress = network_config.substring(index + 15, index + 15 + 18);
        resultFPGA = res[2].data.FPGA;
        let miner_status = res[3].data;
        let log_status = res[4];
        let parseFan = res[5].data;

        return sendMail(parseConfigEmail, macAddress, resultFPGA, miner_status, log_status, parseFan);
    }).then(res => {
        console.log('Send done!!!');
        console.log(res);
    })
    .catch(console.error);