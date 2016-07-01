#!/bin/bash
#This file include the fun of  basic option like add/delete/update site/server/device/interface/app
# By ricky, version 3.0  2015/9/9

#--------------------------------------------------------------------------------------------------------#
addsite_obsolete()
#This fun is to post site collection to domain/10/Sites. 
#The parameter include: sitename [subnetid] [interfaceid], if no subnetid/interfaceid is contained, use []
#example: addsite siteBeijing [1,2] [1,3]
#if success, echo the site id, if fail, echo -1
{
#Create site jsonfile

cat > newsite$$.json <<EOF
    {
      "_id": {
        "timestamp": 1438091765,
        "machineIdentifier": $RANDOM,
        "processIdentifier": $RANDOM,
        "counter": 16162828,
        "time": 1438091765000,
        "date": 1438091765000,
        "timeSecond": 1438091765
      },
      "isEnabled": true,
      "siteName": "$1",
      "description": "IPv4/v6 Catch-all Site.",
      "lastUpdated": 0,
      "flags": 0,
      "netFlowIntfsAreLocal": false,
      "NetFlowIntfsAreDedicated": false,
      "country": "United States",
      "province": "Massachusetts ",
      "city": "Boston",
      "inSpeed": 0,
      "outSpeed": 0,
      "NetFlowInSpeed": 0,
      "NetFlowOutSpeed": 0,
      "ipSubnetIds": 
        $2,
      "networkInterfaceIds": 
        $3,
      "siteId": 999
    }
EOF



jsoncurl POST http://localhost:9092/api/v1/config/collection/domain/10/Sites @newsite$$.json | grep success &> templog.txt
if [ $? != 0 ] 
then
		echo "Fail to add site"; 
		echo -1
		return 1
else
#Check if the site is added in the config and return siteid 
		jsoncurl GET http://localhost:9092/api/v1/config/collection/domain/10/Sites | python -m json.tool > sitecollection$$.json
		idnum=`python getsiteid.py sitecollection$$.json "$1"` 
#		printf "Success to add site. Site id is below"
		if [ $idnum != -1 ]
		then
			echo $idnum
			return 0
		else
			echo -1
			return 1
		fi
fi
	
}




#--------------------------------------------------------------------------------------------------------#
addsite()
#This fun is to post site collection to domain/10/Sites. 
#The parameter include: sitename [subnet1/mask1,subnet2/mask2..] domainid 
# the subnet/mask and deviceip/ifindex are seperated by ",", no blank. If no subnet/mask or deviceip/ifindex,use argument []
#example: addsite siteBeijing [172.1.1.0/24,172.1.2.0/24,172.1.3.0/24] 10
#if success, echo the site id, if fail, echo -1
{
#Create site jsonfile

cat > newsite$$.json <<EOF
  {
      "subnets": [
      ],
      "siteName": "$1",
      "description": "this is for performance test",
      "latitude": "",
      "longitude": "",
      "country": "America",
      "province": "Maryland",
      "city": "Rockville",
      "netFlowIntfsAreLocal": true,
      "netFlowIntfsAreDedicated": true,
      "ipSubnetIds": [
      ],
      "siteId": 2,
      "netFlowInSpeed": "",
      "netFlowOutSpeed": "",
      "interfaces": [
        {
                    "description": "",
                    "deviceAddress": "10.250.16.9",
                    "deviceIp": "10.250.16.9",
                    "deviceName": "hagerman",
                    "id": 74055680,
                    "ifIndex": 15,
                    "name": "ifindex 15"
                },
                {
                    "description": null,
                    "deviceAddress": "172.24.0.1",
                    "deviceIp": "172.24.0.1",
                    "deviceName": "172.24.0.1",
                    "id": 76021809,
                    "ifIndex": 50,
                    "name": "interface: 50"
                }
      ]
    }
EOF

#append the subnets and interfaces field in json file
python appendjson.py newsite$$.json "subnets" $2
#python appendjson.py newsite$$.json "interfaces" $3


#post subnets and append id to ipSubnetIds field in json file
#subnetstr=`echo $2 | sed 's/\[\(.*\)\]/\1/'`
#subnetlist=(${subnetstr//,/ })
#for subnet in ${subnetlist[@]}
#do
#	ipmask=(${subnet//'/'/ })
#	subnetid=`addsubnet ${ipmask[0]} ${ipmask[1]}`
#	python appendjson.py newsite$$.json "ipSubnetIds" $subnetid
	
#done


jsoncurl POST http://localhost:9092/api/v1/config/collection/domain/$3/Sites @newsite$$.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add site $1 in domain $3" >> siteerror.txt; 
		echo -1
		return 1
else
		printf "Success to add site $1 in domain $3"
fi
	
}



#---------------------------------------------------------------------------------------------------#
getsiteID()
#This fun is to get site id with the site name. 
#The parameter include: sitename
#example: getsiteID auto1
#if the site is found, echo the site id, if not, echo -1
{
jsoncurl GET http://localhost:9092/api/v1/config/collection/domain/10/Sites | python -m json.tool > sitecollection$$.json
idnum=`python getsiteid.py sitecollection$$.json "$1"` 
#printf "Success to add site. Site id is below"
if [ $idnum != -1 ]
then
	echo $idnum
	return 0
else
	echo -1
	return 1
fi
}

#---------------------------------------------------------------------------------------------------#
deletesite()
#This fun is to delete site with the site name. 
#The parameter include: sitename
#example: deletesite auto1
#no return.  if success, $?==0
{
	idnum=`getsiteID $1`
	if [ idnum != -1 ]
	then
		jsoncurl DELETE http://localhost:9092/api/v1/config/collection/domain/10/Sites/$idnum | grep success &> templog.txt
		if [ $? = 0 ]; then return 0; else return 1; fi 
		
	else
		echo "Site is not found"
		return 1
	fi
}


#--------------------------------------------------------------------------------------------------------#
addsubnet()
#This fun is to post subnet collection to domain/10/Subnets. 
#The parameter include: address mask
#example: addsubnet 172.1.0.0 16
#if success, echo the subnet id, if fail, echo -1
{
#Create site jsonfile

cat > newsubnet$$.json <<EOF
    {
            "address": "$1",
            "description": "",
            "mask": $2,
            "subnetName": "$1_$2"
    }
EOF

jsoncurl POST http://localhost:9092/api/v1/config/collection/domain/10/Subnets @newsubnet$$.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add subnet:$1_$2" >> subneterror.txt; 
		echo -1
		return 1
else
		printf "Success to add subnet $1_$2"
		echo `getsubnetID $1_$2`
fi
	
}

#---------------------------------------------------------------------------------------------------#
getsubnetID()
#This fun is to get subnet id with the subnet name. 
#The parameter include: subnetname
#example: getsubnetID subnet1
#if the subnet is found, echo the subnet id, if not, echo -1
{
jsoncurl GET http://localhost:9092/api/v1/config/collection/domain/10/Subnets | python -m json.tool > subnetcollection$$.json
idnum=`python getsubnetid.py subnetcollection$$.json "$1"` 
#printf "Success to add subnet. subnet id is below"
if [ $idnum != -1 ]
then
	echo $idnum
	return 0
else
	echo -1
	return 1
fi
}

#---------------------------------------------------------------------------------------------------#
deletesubnet()
#This fun is to delete subnet with the subnet name. 
#The parameter include: subnetname
#example: deletesubnet subnet1
#no return.  if success, $?==0
{
	idnum=`getsubnetID $1`
	if [ idnum != -1 ]
	then
		jsoncurl DELETE http://localhost:9092/api/v1/config/collection/domain/10/Subnets/$idnum | grep success &> templog.txt
		if [ $? = 0 ]; then return 0; else return 1; fi 
		
	else
		echo "subnet is not found"
		return 1
	fi
}




#---------------------------------------------------------------------------------------------------#
add_site_subnet()
#This fun is to add site and associated subnet in one step. 
#The parameter include: sitename subnetname address mask
#example: add_site_subnet site1 subnet1 172.1.0.0/16 16
#if success, echo the site id, if fail, echo -1
{
	subnetid=`addsubnet $2 $3 $4`
	if [ subnetid != -1 ]
	then
		siteid=`addsite $1 [$subnetid] []`
		if [ siteid != -1 ]
		then
			echo $siteid
			return 0
		else
			echo -1
			return 1
		fi
	else
		echo -1
		return 1
	fi
}






#--------------------------------------------------------------------------------------------------------#
addserver()
#This fun is to post server collection to domain/10/Servers. 
#The parameter include: server_address server_name domainid, if server_name is blank,use server_address as server_name
#example: addserver 172.1.1.1 server1 10
#if success, echo the server id, if fail, echo -1
{
#Create server jsonfile
if [ $# = 3 ]
then
	servername=$2
elif [ $# = 2 ]
then
	servername=$1;
else
	echo -1
	return 1
fi	

cat > newserver$$.json <<EOF
    {
      "lastSeen": 1456799565622,
      "serverIpAddress": "$1",
      "serverName": "$servername",
      "description": "This is for performance test",
      "ipTranslation": "None",
      "associatedServerIPAddresses": "",
      "polled": true,
      "snmpType": "default",
      "useDomainSnmp": true,
      "serverSnmp": null,
      "bestName": "$servername",
      "monitored": true,
      "discovered": false
    }
EOF


jsoncurl POST http://localhost:9092/api/v1/config/collection/domain/$3/Servers @newserver$$.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add server:$1 in domain $3" >> servererror.txt; 
		echo -1
		return 1
else
		printf "Success to add server $1 in domain $3"
fi
	
}


#---------------------------------------------------------------------------------------------------#
getserverID()
#This fun is to get server id with the server address. 
#The parameter include: server_address
#example: getserverID 172.1.1.1
#if the server is found, echo the server id, if not, echo -1
{
jsoncurl GET http://localhost:9092/api/v1/config/collection/domain/10/Servers | python -m json.tool > servercollection$$.json
idnum=`python getserverid.py servercollection$$.json "$1"` 
#printf "Success to add server. server id is below"
if [ $idnum != -1 ]
then
	echo $idnum
	return 0
else
	echo -1
	return 1
fi
}


#---------------------------------------------------------------------------------------------------#
deleteserver()
#This fun is to delete server with the server address. 
#The parameter include: server_address
#example: deleteserver 172.1.1.1
#no return.  if success, $?==0
{
	idnum=`getserverID $1`
	if [ idnum != -1 ]
	then
		jsoncurl DELETE http://localhost:9092/api/v1/config/collection/domain/10/Servers/$idnum | grep success &> templog.txt
		if [ $? = 0 ]; then return 0; else return 1; fi 
		
	else
		echo "server is not found"
		return 1
	fi
}





#---------------------------------------------------------------------------------------------------#
getappID()
#This fun is to get app id with the app name. 
#The parameter include: appname
#example: getappID HTTP
#if the app is found, echo the app id, if not, echo -1
{
jsoncurl GET http://localhost:9092/api/v1/config/collection/domain/10/Applications | python -m json.tool > appcollection$$.json
idnum=`python getappid.py appcollection$$.json "$1"` 
if [ $idnum != -1 ]
then
	echo $idnum
	return 0
else
	echo -1
	return 1
fi
}



#--------------------------------------------------------------------------------------------------------#
addapp()
#This fun is to post app collection to domain/10/Applications. 
#The parameter include: appname appport domainid
#example: addapp rokftp 2121 10
#if success, echo the app id, if fail, echo -1
{
#Create app jsonfile

cat > newapp$$.json <<EOF
{
            "addressRanges": [
                {
                    "description": "",
                    "end": "1.1.1.255",
                    "hostCount": "256",
                    "mask": "24",
                    "scopeIpType": "subnet",
                    "start": "1.1.1.0"
                }
            ],
            "appClassification": "business",
            "appName": "$1",
            "appType": "custom",
            "classification": 1,
            "description": "This is for performance Test",
            "enableAggStatStorage": true,
            "enableFlowStorage": false,
            "enablePacketStorage": false,
            "enableStatStorage": true,
            "enableTranStorage": false,
            "enabled": true,
            "flags": 2,
            "hasPerformanceData": false,
            "hasTransactionDetail": false,
            "ipProtocols": [
                {
                    "name": "TCP",
                    "number": 6,
                    "portRange": "$2"
                }
            ],
            "packetSlicing": 65535,
            "protocolIds": [],
            "protocolType": 1,
            "protocolsMode": "custom",
            "serversMode": "custom",
            "suppressedMetric": {
                "enabled": false,
                "lowerBound": 0,
                "metricType": "",
                "upperBound": 0
            }
        }
EOF


jsoncurl POST http://localhost:9092/api/v1/config/collection/domain/$3/Applications @newapp$$.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add application:$1 in domain $3" >> applicationerror.txt; 
		echo -1
		return 1
else
		printf "Success to add application $1 in domain $3"
fi
	
}


#---------------------------------------------------------------------------------------------------#
deleteapp()
#This fun is to delete app with the app name. 
#The parameter include: appname
#example: deleteapp auto1
#no return.  if success, $?==0
{
	idnum=`getappID $1`
	if [ idnum != -1 ]
	then
		jsoncurl DELETE http://localhost:9092/api/v1/config/collection/domain/10/Applications/$idnum | grep success &> templog.txt
		if [ $? = 0 ]; then return 0; else return 1; fi 
		
	else
		echo "app is not found"
		return 1
	fi
}




#--------------------------------------------------------------------------------------------------------#
adddomain-deleted()
#This fun is to add new domain. 
#The parameter include: domain_id
#example: adddomain 11
#if success, echo the server id, if fail, echo -1
{
#Create server jsonfile
cat > newdomain$$.json <<EOF
    {
     "adminUserIds": [
                1
            ],
            "basicUserlIds": [
                2,
                3
            ],
            "description": "User-added domain $1 that is temporarily hardcoded in the prototype system.",
            "domainId": $1,
            "domainName": "Domain$1",
            "isEnabled": true
    }
EOF


jsoncurl POST http://localhost:9092/api/v1/config/collection/system/Domains @newdomain$$.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add domain$1" >> domainerror.txt; 
		echo -1
		return 1
else
		printf "Success to add domain $1"
fi
	
}



#--------------------------------------------------------------------------------------------------------#
addsitetemp()
#This fun is to post site collection to domain/10/Sites. 
#The parameter include: sitename [subnet1/mask1,subnet2/mask2..] [deviceip1/ifindex1,deviceip2/ifindex2...] 
# the subnet/mask and deviceip/ifindex are seperated by ",", no blank. If no subnet/mask or deviceip/ifindex,use argument []
#example: addsite siteBeijing [172.1.1.0/24,172.1.2.0/24,172.1.3.0/24] [10.2.1.2/101,10.23.1.3/501]
#if success, echo the site id, if fail, echo -1
{
#Create site jsonfile

cat > newsitetemp.json <<EOF
   {
            "city": "",
            "country": "",
            "description": "",
            "interfaces": [],
            "latitude": "",
            "longitude": "",
            "province": "",
            "siteAttributes": "",
			"siteId": 100000,
            "siteName": "$1"
        }
EOF

#append the subnets and interfaces field in json file
#python appendjson.py newsite$$.json "subnets" $2
python appendjson.py newsitetemp.json "interfaces" $3




jsoncurl POST http://localhost:9092/api/v1/config/collection/domain/10/Sites @newsitetemp.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add site $1" >> siteerror.txt; 
		echo -1
		return 1
else
#Check if the site is added in the config and return siteid 
		printf "Success to add site $1"
fi
	
}



adddomain()
#This fun is to add new domain. 
#The parameter include: domain_id
#example: adddomain 11
#if fail, echo -1
{
#Create domain jsonfile
cat > newdomain$$.json <<EOF
{
      "description": "This is for performance test",
      "allInterfaces": true,
      "enableApm": true,
      "enableNpm": true,
      "enableHealth": true,
      "enableVoip": true,
      "enableCitrix": true,
      "domainId": $1,
      "domainName": "autodomain$1"
    }
EOF


jsoncurl POST http://localhost:9092/api/v1/config/collection/system/Domains @newdomain$$.json | egrep "\"affectedRecords\":1"
if [ $? != 0 ] 
then
		echo "Fail to add domain$1" >> domainerror.txt; 
		echo -1
		return 1
else
		printf "Success to add domain $1"
fi
	
}



#-----------------------------------------------------------------------------------------------------#
test()
{
str="[172.1.1.0/24,172.1.2.0/24,172.1.3.0/24]"
subnetstr=`echo $str | sed 's/\[\(.*\)\]/\1/'`
echo subnetstr $subnetstr
subnetlist=(${subnetstr//,/ })
echo subnetlist $subnetlist
for subnet in $subnetlist
do
	echo subnet $subnet
	ipmask=(${subnet//'/'/ })
	echo ipmask $ipmask
	echo $subnet ${ipmask[0]} ${ipmask[1]}
#	subnetid=`addsubnet $subnet ${ipmask[0]} ${ipmask[1]}`
#	python appendjson.py newsite$$.json "ipSubnetIds" $subnetid
	
done


}


