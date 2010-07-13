#!/usr/bin/python
# $Id: request-to-api.py,v 1.2 2010/07/13 09:08:31 ak Exp $
# coding: utf-8
import urllib2
import simplejson
import md5

# Message Token
addresser = 'sender01@example.jp'
recipient = 'user01@example.org'
mesgtoken = md5.new('\x02%s\x1e%s\x03' % (addresser,recipient))
queryhost = 'http://apitest.bouncehammer.jp/modperl/a.cgi'
response = urllib2.urlopen( queryhost + '/select/' + mesgtoken.hexdigest() )
metadata = simplejson.load(response)
for j in metadata:
	print j['recipient'] + ': ' + j['reason']

# Recipient
response = urllib2.urlopen( queryhost + '/search/recipient/' + recipient )
metadata = simplejson.load(response)
for j in metadata:
	print j['recipient'] + ': ' + j['reason']

