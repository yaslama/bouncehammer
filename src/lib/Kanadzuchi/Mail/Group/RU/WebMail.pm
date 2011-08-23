# $Id: WebMail.pm,v 1.8.2.1 2011/08/20 20:13:49 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::RU::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::RU::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Russia
sub nominisexemplaria
{
	my $class = shift();
	return {
		# http://qip.ru/
		'qip' => [
			qr{\A(?:qip|pochta|front|hotbox|hotmail|land|newmail)[.]ru\z},
			qr{\A(?:nightmail|nm|pochtamt|pop3|rbcmail|smtp)[.]ru\z},
			qr{\A(?:5ballov|aeterna|ziza|memori|photofile|fotoplenka)[.]ru\z},
			qr{\A(?:fromru|mail15|mail333|pochta)[.]com\z},
			qr{\Akrovatka[.]su\z},
			qr{\Apisem[.]net\z},
		],

		# http://mail.ru/
		'runet' => [
			qr{\A(?:mail|bk|inbox|list)[.]ru\z},
		],

		# http://yandex.ru/
		'yandex' => [
			qr{\Ayandex[.]ru\z},
		],
	};
}

sub classisnomina
{
	my $class = shift();
	return {
		'qip'		=> 'Generic',
		'runet'		=> 'Generic',
		'yandex'	=> 'Generic',
	};
}

1;
__END__
