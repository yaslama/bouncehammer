#!/usr/bin/ruby1.9
# $Id: request-to-api.rb,v 1.1 2010/03/19 11:06:59 ak Exp $
require 'open-uri'
require 'digest/md5'
require 'json'

addresser = 'sender01@example.jp'
recipient = 'user01@example.org'
mesgtoken = Digest::MD5.new.update(sprintf("\x02%s\x1e%s\x03", addresser,recipient))
queryhost = 'http://apitest.bouncehammer.jp/index.cgi/query/'
metadata = nil
response = open( queryhost + mesgtoken.hexdigest, 'r' ){|p|
	metadata = JSON.parse(p.read)
}

for j in metadata
	print j['recipient'] + ': ' + j['reason'] + "\n"
end
