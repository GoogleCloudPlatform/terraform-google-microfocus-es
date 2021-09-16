import sys
import os
import escwa as escwa
from subprocess import PIPE, Popen
import json

#if len(sys.argv) == 5:
escwaEndpoint = sys.argv[1]     #"http://35.214.23.66:10086"
redisEndpoint = sys.argv[2]     #"10.84.62.4:6379"
region = sys.argv[3]            #"europe-west2"
instanceGroupName = sys.argv[4] #"testjs6-es-mig"

def runcmd(cmd):
  output = Popen(args=cmd,stdout=PIPE,shell=True).communicate()[0].decode('ascii')
  #obj = json.loads(output)
  return output;
  
def getInstancesInInstanceGroup(region, instanceGroupName):
  format="value[separator='.'](NAME,ZONE)"
  output=runcmd("gcloud compute instance-groups managed list-instances --region="+region+" "+instanceGroupName+" --format=\""+format+"\"")
  instances=output.split()
  return instances
  
client = escwa.EscwaClient()
client.login(escwaEndpoint, "user", "pwd")

client.deleteAllSORS()
client.deleteAllPACS()
client.deleteAllDirectoryServers()

instances=getInstancesInInstanceGroup(region, instanceGroupName)
for instance in instances:
  print("Adding Directory Server " + instance)
  data={
    'MfdsHost':instance,
    'MfdsIdentifier':instance,
    'MfdsPort':"1086",
  }
  client.post("/server/v1/config/mfds", data)

print("Adding PSOR")
data={
  'SorName':"DemoPSOR",
  'SorDescription':'Demo Redis',
  'SorType':'redis',
  'SorConnectPath':redisEndpoint
}
sor=client.post("/server/v1/config/groups/sors", data).json()

print("Adding PAC")
data={
   'PacName':'DemoPAC',
   'PacDescription':'Demo Redis',
   'SorType':'redis',
   'PacResourceSorUid':sor['Uid']
}
pac=client.post("/server/v1/config/groups/pacs", data).json()

print("Installing regions into PAC")
regionName="BNKDM"
regions=[]
for instance in instances:
  region={
    'Host':instance,
    'Port':'1086',
    'CN':regionName
  }
  regions.append(region)
  
data={
   'Regions':regions
}
print(client.post("/native/v1/config/groups/pacs/"+pac['Uid']+"/install", data))

client.logoff()

sys.exit()

