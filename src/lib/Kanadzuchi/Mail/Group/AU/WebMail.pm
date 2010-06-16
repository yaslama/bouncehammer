# $Id: WebMail.pm,v 1.2 2010/06/16 08:15:17 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::CA::
                                                   
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
		# http://fastmail.fm/
		'fastmail' => [
			qr{\Afastmail[.](?:cn|com[.]au|es|fm|in|jp|net|to|us)\z},
			qr{\A(?:fastmail|fmail)[.]co[.]uk\z},
			qr{\A(?:4e|all|hail|jete|juste|own|nospam|reale|warp|yep)[.]net\z},
			qr{\A(?:150|16|50|clue|fast[-]e|myfast|mymac|theinternete|xs)mail[.]com\z},
			qr{\A(?:2|imap|internet[-]e|ssl|swift|your)[-]mail[.]com\z},
			qr{\A(?:123|elite|imap|speedy)mail[.]org\z},
			qr{\A(?:fast|internet)[-]mail[.]org\z},
			qr{\Aemail(?:cornet|engine|groups|user)[.]net\z},
			qr{\Aemail(?:engine|plus)[.]org\z},
			qr{\Asent[.](?:as|at|com)\z},
			qr{\Amail[-](?:central|page)[.]com\z},
			qr{\Amail(?:andftp|as|bolt|can|ftp|haven|ite|might|new)[.]com\z},
			qr{\Amail(?:c|force|sent|up)[.]net\z},
			qr{\Amail(?:ingaddress|works)[.]org\z},
			qr{\A(?:best|faste|h[-])mail[.]us\z},
			qr{\Ainternet(?:emails|mailing)[.]net\z},
			qr{\Areallyfast[.](?:biz|info)\z},
			qr{\A(?:eml|fastest|imap)[.]cc\z},
			qr{\A(?:fea|mm)[.]st\z},
			qr{\Afast(?:en|emailer|imap|messaging)[.]com\z},
			qr{\A(?:fmail|inout|post|pro)inbox[.]com\z},
			qr{\A(?:air|speed)post[.]net\z},
			qr{\A(?:rushpost|fmgirl|fmguy|petml|150ml|promessage|the[-]quickest)[.]com\z},
			qr{\A(?:fastmailbox|ftml|ml1|postpro|the[-]fastest|veryspeedy)[.]net\z},
			qr{\Alatterboxes[.]org\z},
			qr{\Af[-]m[.]fm\z},
			qr{\Amailservice[.]ms\z},
			qr{\Averyfast[.]biz\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'fastmail'	=> 'Generic',
	};
}

1;
__END__
