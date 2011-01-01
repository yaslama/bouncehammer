# $Id: MDA.pm,v 1.2 2010/12/15 09:00:47 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                       
 ##  ## ####     ##    
 ###### ## ##   ####   
 ###### ##  ## ##  ##  
 ##  ## ##  ## ######  
 ##  ## ## ##  ##  ##  
 ##  ## ####   ##  ##  
package Kanadzuchi::MDA;
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $MDASign = {
	# dovecot/src/deliver/deliver.c
	# 11: #define DEFAULT_MAIL_REJECTION_HUMAN_REASON \
	# 12: "Your message to <%t> was automatically rejected:%n%r"
	'dovecot'    => qr{\AYour message to .+ was automatically rejected:\z},
	'mail.local' => qr{\Amail[.]local: },
	'procmail'   => qr{\Aprocmail: },
	'maildrop'   => qr{\Amaildrop: },
	'vpopmail'   => qr{\Avdelivermail: },
	'vmailmgr'   => qr{\Avdeliver: },
};

my $bSenders = [
	qr{\AMail Delivery Subsystem},	# dovecot/src/deliver/mail-send.c:94
	qr{\AMAILER-DAEMON}i,
	qr{\A[Pp]ostmaster},
];

my $bMessage = {
	'dovecot' => {
		'userunknown' => [
			qr{\AMailbox doesn't exist: },
		],
		'mailboxfull' => [
			qr{\AQuota exceeded [(]mailbox for user is full[)]\z},	# dovecot/src/plugins/quota/quota.c
			qr{\ANot enough disk space\z},
		],
	},
	'mail.local' => {
		'userunknown' => [
			qr{: User unknown},
			qr{: Invalid mailbox path},
			qr{: User missing home directory},
		],
		'mailboxfull' => [
			qr{Disc quota exceeded\z},
			qr{Mailbox full or quota exceeded},
		],
		'systemerror' => [
			qr{Temporary file write error},
		],
	},
	'procmail' => {
		'mailboxfull' => [
			qr{Quota exceeded while writing},
		],
		'systemfull' => [
			qr{No space left to finish writing},
		],
	},
	'maildrop' => {
		'userunknown' => [
			qr{Invalid user specified[.]\z},
			qr{Cannot find system user},
		],
		'mailboxfull' => [
			qr{maildir over quota[.]\z},
		],
	},
	'vpopmail' => {
		'userunknown' => [
			qr{Sorry, no mailbox here by that name[.]},
		],
		'filtered' => [
			qr{account is locked email bounced},
			qr{user does not exist, but will deliver to },
		],
		'mailboxfull' => [
			qr{(?:domain|user) is over quota},
		],
	},
	'vmailmgr' => {
		'userunknown' => [
			qr{Invalid or unknown base user or domain},
			qr{Invalid or unknown virtual user},
			qr{User name does not refer to a virtual user},
		],
		'mailboxfull' => [
			qr{Delivery failed due to system quota violation},
		],
	},
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub parse
{ 
	# +-+-+-+-+-+
	# |p|a|r|s|e|
	# +-+-+-+-+-+
	#
	# @Description	Parse message body and return reason and text
	# @Param <ref>	(Ref->Hash) Message Header
	# @Param <ref>	(Ref->Scalar) Message body
	# @Return	(Ref->Hash) Error reason and error text
	my $class = shift();
	my $mhead = shift() || return undef();
	my $mbody = shift() || return undef();

	return undef() unless ref($mhead) eq q|HASH|;
	return undef() unless grep { $mhead->{'from'} =~ $_ } @$bSenders;
	return undef() unless ref($mbody) eq q|SCALAR|;
	return undef() unless length $$mbody;

	my $mdais = q();	# (String) MDA name
	my $error = q();	# (String) Error reason
	my $mtext = q();	# (String) Error message
	my @lines = split( qq(\n), $$mbody );
	my @mbbuf = ();

	WHAT_MDA: foreach my $mda ( keys %$MDASign )
	{
		@mbbuf = ();
		EACH_LINE: foreach my $el ( @lines )
		{
			next() if( $mdais eq q() && $el !~ $MDASign->{ $mda } );
			$mdais ||= $mda;
			push( @mbbuf, $el );
			last() if( $el =~ m{\A\z} );
		}

		last() if( $mdais );
	}

	return undef() unless $mdais;
	return undef() unless scalar @mbbuf;

	DETECT_AN_ERROR: foreach my $er ( keys %{ $bMessage->{ $mdais } } )
	{
		foreach my $lb ( @mbbuf )
		{
			next() unless grep { $lb =~ $_ } @{ $bMessage->{ $mdais }->{ $er } };
			$mtext = $lb;
			$error = $er;
			last();
		}
		last() if( $mtext && $error );
	}

	return { 'mda' => $mdais, 'reason' => $error, 'message' => $mtext };
}

1;
__END__
