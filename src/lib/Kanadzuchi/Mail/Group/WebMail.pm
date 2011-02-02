# $Id: WebMail.pm,v 1.14.2.2 2011/02/02 02:31:34 ak Exp $
# -Id: AOL.pm,v 1.1 2009/08/29 07:33:21 ak Exp -
# -Id: Google.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# -Id: Hotmail.pm,v 1.1 2009/08/29 07:33:22 ak Exp -
# -Id: WebBased.pm,v 1.2 2009/09/03 18:45:31 ak Exp -
# -Id: Yahoo.pm,v 1.2 2009/12/01 10:33:29 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major webmail provider's domains in The World
#  * http://en.wikipedia.org/wiki/Webmail
#  * http://en.wikipedia.org/wiki/Comparison_of_webmail_providers
sub nominisexemplaria
{
	my $class = shift();
	return {
		'aol' => [
			# AOL; America OnLine
			qr{\Aaim[.](?:com|net)\z},
			qr{\Aaol[.](?:com|be|ch|cl|de|dk|es|fi|fr|hk|in|it|jp|kr|nl|pl|ru|se|tw)\z},
			qr{\Aaol[.]co[.](?:nz|uk)\z},
			qr{\Aaol[.]com[.](?:ar|au|br|co|mx|ve)\z},
			qr{\Anetscape[.]net\z},
			qr{\A(?:games|love|wow|ygm)[.]com\z},	# AOL's Project Phoenix
		],
		'apple' => [
			# mobileme, http://me.com/
			qr{\A(?:mac|me)[.]com\z},
		],
		'excite' => [
			# http://excite.com/
			qr{\Aexcite[.](?:com|co[.]jp)\z},
		],
		'facebook' => [
			# Facebook has half a billion users.
			# http://www.facebook.com/
			qr{\Afacebook[.]com\z},
		],
		'google' => [
			# GMail http://mail.google.com/mail/
			qr{\Agmail[.]com\z},
			qr{\Agmail[.](?:bj|cf|ge|ie|lu|re|ug)\z},

			# GMail in U.K. and Germany
			qr{\Agooglemail[.]com\z},
		],
		'lycos' => [
			# http://www.lycos.com/
			qr{\Alycos(?:mail)?[.]com\z},
		],
		'microsoft' => [
			# Windows Live Hotmail http://www.hotmail.com/
			qr{\Amsn[.](?:com|mv)\z},
			qr{\A(?:hotmail|live|msnhotmail)[.]com\z},
			qr{\Awindowslive[.](?:com|ez)\z},
			qr{\Ahotmail[.](?:ac|as|at|bb|be|bs|ca|ch|cl|cz|de|dk|es|fi|fr|gr|hk|hu)\z},
			qr{\Ahotmail[.](?:it|la|lt|lu|lv|ly|mn|mw|my|nl|no|ph|pn|pt|rs|se|sg|sh|sk|vu)\z},
			qr{\Ahotmail[.]co[.](?:at|id|il|in|jp|kr|nz|pn|th|ug|uk|za)\z},
			qr{\Ahotmail[.]com[.](?:ar|au|bo|br|hk|my|ph|pl|sg|tr|tt|tw|vn)\z},
			qr{\Alive[.](?:at|be|ca|ch|cl|cn|de|dk|fi|fr|hk|ie|in|it|jp|nl|no|ph|ru|se)\z},
			qr{\Alive[.]co[.](?:in|kr|uk|za)\z},
			qr{\Alive[.]com[.](?:ar|au|co|mx|my|pe|ph|pk|pt|sg|ve)\z},
		],
		'myspace' => [
			# MySpace Mail has over 15 million users.
			# http://www.myspace.com/
			qr{\Amyspace[.]com\z},
		],
		'nokia' => [
			# Ovi by Nokia, http://www.ovi.com/
			qr{\Aovi[.]com\z},
		],
		'yahoo' => [
			# Yahoo! Mail; http://world.yahoo.com/
			qr{\Ayahoo[.]com\z},
			qr{\Ayahoo[.](?:at|ca|cl|cn|de|dk|es|fr|gr|ie|in|it|jp|no|pl|ro|se)\z},
			qr{\Ayahoo[.]com[.](?:ar|au|br|cn|co|hk|mx|my|pe|ph|sg|tr|tw|ve|vn)\z},
			qr{\Ayahoo[.]co[.](?:hu|id|in|jp|kr|nz|th|uk)\z},
			qr{\A(?:ymail|rocketmail)[.]com\z},		# From 2008/06/19

			# http://promo.mail.yahoo.co.jp/collabo/
			# From 2009/12/01
			qr{\Ailove-(?:mickey|minnie|pooh|stitch|tinkerbell)[.]jp\z},
			qr{\Agamba[-]fan[.]jp\z},
			qr{\Ahawks[-]fan[.]jp\z},
			qr{\Ay[-]fmarinos[.]com\z},		# From 2010/02/17
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'aol'		=> 'Generic',
		'apple'		=> 'Generic',
		'excite'	=> 'Generic',
		'facebook'	=> 'Generic',
		'google'	=> 'Generic',
		'lycos'		=> 'Generic',
		'microsoft'	=> 'Generic',
		'myspace'	=> 'Generic',
		'nokia'		=> 'Generic',
		'yahoo'		=> 'Yahoo',
	};
}

1;
__END__
