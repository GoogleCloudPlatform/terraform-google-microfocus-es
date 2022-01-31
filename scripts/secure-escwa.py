#Adds an MLDAP ESM and have ESCWA use it for security
#example use:
#python secure-escwa.py "http://35.214.23.66:10086" "10.84.62.4:389" "" ""

import sys
import os
import escwa as escwa
from subprocess import PIPE, Popen
import json

escwaEndpoint = sys.argv[1]     #"http://35.214.23.66:10086"
activeDirectoryEndpoint = sys.argv[2]     #"10.84.62.4:389"
adUser=sys.argv[3]
adPass=sys.argv[4]

client = escwa.EscwaClient()
print(client.login(escwaEndpoint, "SYSAD", "SYSAD"))
print(client.get("/server/v1/info").json())
#Create MLDAP ESM
data={
  "Name": "mldap_esm",
  "Module": "mldap_esm",
  "ConnectionPath": activeDirectoryEndpoint,
  "AuthorizedID": adUser,
  "Password": adPass,
  "Enabled": True,
  "CacheLimit": 1024,
  "CacheTTL": 600,
  "Config": "",
  "Description": "mldap_esm"
}
resp=client.post("/server/v1/config/esm", data)
esmUid=resp.json()['Uid']
print(esmUid)
#Set ESM for ESCWA security
data = {
  "currentUserName": "SYSAD",
  "currentUserPassword": "SYSAD",
  "newUserName": "SYSAD",
  "newUserPassword": "SYSAD",
  "ActiveEsms": [
    esmUid
  ]
}
print(client.put("/server/v1/config/security", data))
client.logoff()
sys.exit()

