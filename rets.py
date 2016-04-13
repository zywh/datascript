#!/usr/bin/python

import librets

class rets_connection:
   user_id = "D15yzh"
   passwd = "Da$3778"
   login_url = "http://rets.torontomls.net:6103/rets-treb3pv/server/login"
      


try:
   session = librets.RetsSession(rets_connection.login_url)
   #At this point you're connected to the Rets server, but not authenticated so not even worth checking for success
   #If you need to change user-agent (Rapattoni servers)
   #session.SetUserAgent("myAgentCode/1.5")
   if (not session.Login(rets_connection.user_id, rets_connection.passwd)):
       #
       sys.exit(2)
   metadata = session.GetMetadata()
   systemdata = metadata.GetSystem()
   for attribute in systemdata.GetAttributeNames():
         print attribute, systemdata.GetStringAttribute(attribute)

   session.Logout()
except Exception, e:
   print "Exception: ", e
