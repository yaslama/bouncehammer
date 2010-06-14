# $Id: WebMail.pm,v 1.1 2010/06/14 07:29:21 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Group::EG::
                                                   
 ##  ##         ##     ##  ##           ##  ###    
 ##  ##   ####  ##     ######   ####         ##    
 ##  ##  ##  ## #####  ######      ##  ###   ##    
 ######  ###### ##  ## ##  ##   #####   ##   ##    
 ######  ##     ##  ## ##  ##  ##  ##   ##   ##    
 ##  ##   ####  #####  ##  ##   #####  #### ####   
package Kanadzuchi::Mail::Group::EG::WebMail;
use base 'Kanadzuchi::Mail::Group';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Major company's Webmail domains in Egypt, The Middle East region
my $Domains = {
	# http://www.gawab.com/
	# http://www.gawab.com/webfront/main.php?doc=moreDomains
	'gawab' => [
		qr{\Agawab[.]com\z},

		# Algeria
		qr{\A(?:algerie|oran)[.]cc\z},
		qr{\A(?:blida[.]info|mascara[.]ws)\z},
		qr{\Aoued[.](?:info|org)\z},

		# Egypt
		qr{\A(?:alex4all[.]com|mansoura[.]tv)\z},
		qr{\A(?:alexandria|aswan|banha|giza|ismailia|portsaid)[.]cc\z},
		qr{\A(?:sharm|sinai|suez|tanta|zagazig)[.]cc\z},

		# Jordan
		qr{\Airbid[.]ws\z},
		qr{\A(?:amman|aqaba|jerash|karak|urdun|zarqa)[.]cc\z},

		# Kuwait
		qr{\Asafat[.](?:biz|info|us|ws)\z},
		qr{\A(?:kuwaiti[.]tv|salmiya[.]biz)\z},

		# Lebanon
		qr{\A(?:baalbeck|hamra|lebanese)[.]cc\z},
		qr{\Alubnan(?:cc|ws)\z},

		# Morocco
		qr{\A(?:agadir|maghreb|marrakesh|meknes|nador|rabat|tangiers|tetouan)[.]cc\z},
		qr{\Ajadida[.](?:cc|org)\z},
		qr{\Aoujda[.](?:biz|cc)\z},
	
		# Oman
		qr{\Amuscat[.](?:tv|ws)\z},
		qr{\A(?:dhofar|gabes|ibra|salalah|seeb)[.]cc\z},
		qr{\Aomani[.]ws\z},
		
		# Palestine
		qr{\A(?:falasteen|nablus|quds|rafah|ramallah|yunus)[.]cc\z},
		qr{\Ahebron[.]tv\z},

		# Saudi Arabia
		qr{\A(?:ahsa|arar)[.]ws\z},
		qr{\A(?:abha|albaha|alriyadh|buraydah|dhahran|jizan)[.]cc\z},
		qr{\A(?:jouf|khobar|madinah|qassem|tabouk|tayef|yanbo)[.]cc\z},

		# Sudan
		qr{\A(?:khartoum|omdurman|sudanese)[.]cc\z},

		# Syria
		qr{\Ahasakah[.]com\z},
		qr{\A(?:homs|latakia|siria)[.]cc\z},
		qr{\Apalmyra[.](?:cc|ws)\z},

		# Tunisia
		qr{\A(?:bizerte|gafsa|kairouan|nabeul|sousse|tunisian)[.]cc\z},
		qr{\A(?:nabeul[.]info|sfax[.]ws)\z},

		# United Arab Emirates
		qr{\Aajman[.](?:cc|us|ws)\z},
		qr{\Afujairah[.](?:cc|us|ws)\z},
		qr{\Akhaimah[.]cc\z},

		# Yemen
		qr{\A(?:sanaa|yemeni)[.]cc\z},

		# Bahrain, Cameroon, Djibouti, East Timor, Eritrea, Guinea, Iraq, Kyrgyzstan,
		qr{\A(?:bahraini|manama|cameroon|djibouti|timor|eritrea|guinea|najaf|kyrgyzstan)[.]cc\z},

		# South Africa, Tajikistan, Zambia
		qr{\A(?:dominican|tajikistan|zambia)[.]cc\z},

		# Pakistan
		qr{\Apakistani[.]ws\z},
	],
};

my $Classes = {
	'gawab'		=> 'Generic',
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	
	# @Description	Detect and load the class for the domain
	# @Param <str>	(String) Domain part
	# @Return	(Ref->Hash) Class, Group, Provider name or Empty string
	my $class = shift();
	my $dpart = shift() || return({});
	my $mdata = { 'class' => q(), 'group' => q(), 'provider' => q(), };
	my $cpath = q();

	foreach my $d ( keys(%$Domains) )
	{
		next() unless( grep { $dpart =~ $_ } @{ $Domains->{$d} } );

		$mdata->{'class'} = q|Kanadzuchi::Mail::Bounced::|.$Classes->{$d};
		$mdata->{'group'} = 'webmail';
		$mdata->{'provider'} = $d;
		last();
	}

	return($mdata);
}

1;
__END__
