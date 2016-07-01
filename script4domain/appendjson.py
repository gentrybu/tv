#!/usr/bin/python

import json
import sys

def appendjson(jsonfile,fieldname,value):
    jfile=open(jsonfile,'r')
    jdict=json.load(jfile)
    jfile.close()
    if fieldname not in jdict:
        jdict[fieldname]=[]
    if fieldname=="subnets":
        subnetlist=value.strip("[]").split(",")
        for subnet in subnetlist:
            if subnet!='':
                ipmask=subnet.split("/")
                jdict[fieldname].append({"address": ipmask[0],"mask": int(ipmask[1]),"description": "","subnetName": ipmask[0]+"_"+ipmask[1]})
    elif fieldname=="interfaces":
        interfacelist=value.strip("[]").split(",")
        for interface in interfacelist:
            if interface!='':
                deviceIf=interface.split("/")
                jdict[fieldname].append({"deviceAddress": deviceIf[0],"ifIndex": int(deviceIf[1])})
    elif fieldname=="ipSubnetIds":
        valuelist=value.strip("[]").split(",")
        for theValue in valuelist:
            if theValue!='':
                jdict[fieldname].append(int(theValue))
    else:
        valuelist=value.strip("[]").split(",")
        for theValue in valuelist:
            if theValue!='':
                jdict[fieldname].append(theValue)
    jfile=open(jsonfile,'w')
    json.dump(jdict,jfile)


if __name__ == '__main__':
    appendjson(sys.argv[1],sys.argv[2],sys.argv[3])
