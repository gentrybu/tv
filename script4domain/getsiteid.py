#!/usr/bin/python

import json
import sys

def getsiteid(jsonfile,sitename):
    jfile=open(jsonfile)
    jdict=json.load(jfile)

    for site in jdict["data"]:
        if site["siteName"]==sitename:
            print site["siteId"]
	    return 
    print -1
    return 
	
	

if __name__ == '__main__':
    getsiteid(sys.argv[1],sys.argv[2])
