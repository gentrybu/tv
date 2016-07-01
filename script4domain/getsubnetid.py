#!/usr/bin/python

import json
import sys

def getsubnetid(jsonfile,subnetname):
    jfile=open(jsonfile)
    jdict=json.load(jfile)

    for subnet in jdict["data"]:
        if subnet["subnetName"]==subnetname:
            print subnet["subnetId"]
	    return 
    print -1
    return 
	
	

if __name__ == '__main__':
    getsubnetid(sys.argv[1],sys.argv[2])
