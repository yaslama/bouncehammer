#!/usr/bin/ruby1.9
# $Id: request-to-api.rb,v 1.2 2010/07/13 09:08:31 ak Exp $
require 'open-uri'
require 'digest/md5'
require 'json'

# Message Token
addresser = 'sender01@example.jp'
recipient = 'user01@example.org'
mesgtoken = Digest::MD5.new.update(sprintf("\x02%s\x1e%s\x03", addresser,recipient))
queryhost = 'http://apitest.bouncehammer.jp/modperl/a.cgi'
metadata = nil
response = open( queryhost + '/select/' + mesgtoken.hexdigest, 'r' ){|p|
	metadata = JSON.parse(p.read)
}
for j in metadata
	print j['recipient'] + ': ' + j['reason'] + "\n"
end

# Recipient
response = open( queryhost + '/search/recipient/' + recipient, 'r' ){|p|
	metadata = JSON.parse(p.read)
}
for j in metadata
	print j['recipient'] + ': ' + j['reason'] + "\n"
end
