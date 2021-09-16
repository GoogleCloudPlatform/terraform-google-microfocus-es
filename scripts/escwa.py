import requests

class EscwaClient:
  baseurl : ""
  cookies: {}
  def getHeaders(self):
    headers = {
            'Origin': self.baseurl,
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Requested-With': 'AgileDev'
            }
    return headers
  def get(self, apiPath, data=""):
    url=self.baseurl + apiPath
    response = requests.get(url, headers=self.getHeaders(), cookies=self.cookies, json=data)
    return response
  def post(self, apiPath, data):
    url=self.baseurl + apiPath
    response = requests.post(url, headers=self.getHeaders(), cookies=self.cookies, json=data)
    return response
  def put(self, apiPath, data):
    url=self.baseurl + apiPath
    response = requests.put(url, headers=self.getHeaders(), cookies=self.cookies, json=data)
    return response
  def delete(self, apiPath, data=""):
    url=self.baseurl + apiPath
    response = requests.delete(url, headers=self.getHeaders(), cookies=self.cookies, json=data)
    return response
  def login(self, url, username="", password=""):
    self.baseurl=url
    data={'mfUser': username, 'mfPassword': password}
    response=requests.post(self.baseurl + "/logon", headers=self.getHeaders(), json=data)
    print(response.cookies)
    self.cookies = response.cookies
    return response
  def logoff(self):
    return self.delete("/logoff")

#helper methods
  def getDirectoryServers(self):
    return self.get("/server/v1/config/mfds").json()
  def getSORS(self):
    return self.get("/server/v1/config/groups/sors").json()
  def getPACS(self):
    return self.get("/server/v1/config/groups/pacs").json()

  def deleteAllDirectoryServers(self):
    for ds in self.getDirectoryServers():
      self.delete("/server/v1/config/mfds/"+ds["Uid"])
  def deleteAllSORS(self):
    for sor in self.getSORS():
      self.delete("/server/v1/config/groups/sors/"+sor["Uid"])
  def deleteAllPACS(self):
    for pac in self.getPACS():
      self.delete("/server/v1/config/groups/pacs/"+pac["Uid"])
