#!/usr/bin/python
# $Id: request-to-api.py,v 1.1 2010/03/19 11:06:59 ak Exp $
# coding: utf-8
import urllib2
import simplejson
import md5

addresser = 'sender01@example.jp'
recipient = 'user01@example.org'
mesgtoken = md5.new('\x02%s\x1e%s\x03' % (addresser,recipient))
queryhost = 'http://apitest.bouncehammer.jp/index.cgi/query/'
response = urllib2.urlopen( queryhost + mesgtoken.hexdigest() )
metadata = simplejson.load(response)

for j in metadata:
	print j['recipient'] + ': ' + j['reason']

