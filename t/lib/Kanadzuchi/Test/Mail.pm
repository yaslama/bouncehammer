# $Id: Mail.pm,v 1.9 2010/03/29 08:25:40 ak Exp $
package Kanadzuchi::Test::Mail;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
our $MethodList = {
	'BaseClass' => [
		'id2gname',
		'id2rname',
		'gname2id',
		'rname2id',
	],
	'Bounced' => [
		'eatit',
		'tellmewhy',
		'is_filtered',
		'is_userunknown',
		'is_hostunknown',
		'is_mailboxfull',
		'is_toobigmesg',
		'is_exceedlimit',
		'is_norelaying',
		'is_securityerror',
		'is_mailererror',
		'is_onhold',
		'is_somethingelse',
		'is_permerror',
		'is_temperror',
	],
	'Stored::YAML' => [
		'loadandnew',
		'insert',
		'update',
		'findbytoken',
	],
	'Stored::RDB' => [
		'searchandnew',
		'serialize',
		'modify',
	],
};

1;
__END__
