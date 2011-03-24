# $Id: WebMail.pm,v 1.4.2.1 2011/03/24 05:40:58 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::AU::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::AU::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Australia
sub nominisexemplaria
{
	my $class = shift();
	return {
		'aussiemail' => [
			# Aussiemail; http://www.aussiemail.com.au/
			qr{\Aaussiemail[.]com[.]au\z},
		],
		'fastmail' => [
			# FastMail http://fastmail.fm/
			qr{\Afastmail[.](?:fm|cn|co[.]uk|com[.]au|es|in|jp|net|to|us)\z},
			qr{\Amail(?:bolt|can|haven|might|as|ftp|ite|new)[.]com\z},
			qr{\Amail-(?:central|page)[.]com\z},
			qr{\Asent[.](?:as|at|coom)\z},
			qr{\A(?:150|pet)ml[.]com\z},
			qr{\A(?:150|16|2-|clue|xs|theinternete|opera)mail[.]com\z},
			qr{\Amy(fast|mac)mail[.]com\z},
			qr{\A(?:imap|internet-e|swift|your|ssl)-mail[.]com\z},
			qr{\A(?:4e|all|hail|nospam|own|warp|yep)mail[.]com\z},
			qr{\A(?:jet|just|real)email[.]com\z},
			qr{\A(?:123|speedy|elite|fast-|imap|internet-)mail[.]org\z},
			qr{\Aemail(?:corner|engine|groups|user)[.]net\z},
			qr{\Aemail(?:engine|plus)[.]org\z},
			qr{\Apost(?:inbox[.]com|pro[.]net)\z},
			qr{\A(?:speed|air|rush)post[.]com\z},
			qr{\Afast(?:-email|em|emailer|imap|messaging)[.]com\z},
			qr{\A(?:best|faste|h-)mail[.]us\z},
			qr{\A(?:fastest|eml|imap)[.]cc\z},
			qr{\A(?:fea|mm)[.]st\z},
			qr{\Ainternet(?:emails|mailing)[.]net\z},
			qr{\A(?:fmail|inout|proin)box[.]com\z},
			qr{\Amail(?:c|force|sent|up)[.]net\z},
			qr{\Amail(?:ingaddress|works)[.]org\z},
			qr{\Areallyfast[.](?:biz|info)\z},
			qr{\Avery(?:fast[.]biz|speedy[.]info)\z},
			qr{\Afm(?:girl|guy)[.]com\z},
			qr{\A(?:the-quickest|promessage)[.]com\z},
			qr{\A(?:the-fastest|fastmailbox|ml1|ftml)[.]net\z},
			qr{\Aletterboxes[.]org\z},
			qr{\Afmail[.]co[.]uk\z},
			qr{\Af-m[.]fm\z},
			qr{\Amailservice[.]ms\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'aussiemail'	=> 'Generic',
		'fastmail'	=> 'Generic',
	};
}

1;
__END__
