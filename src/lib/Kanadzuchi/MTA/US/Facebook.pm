# $Id: Facebook.pm,v 1.1.2.5 2011/10/07 06:23:15 ak Exp $
# Copyright (C) 2009-2011 Cubicroot Co. Ltd.
# Kanadzuchi::MTA::US::
                                                       
 ######                   ##                   ##      
 ##     ####   #### ####  ##      ####   ####  ##      
 ####      ## ##   ##  ## #####  ##  ## ##  ## ## ##   
 ##     ##### ##   ###### ##  ## ##  ## ##  ## ####    
 ##    ##  ## ##   ##     ##  ## ##  ## ##  ## ## ##   
 ##     #####  #### ####  #####   ####   ####  ##  ##  
package Kanadzuchi::MTA::US::Facebook;
use base 'Kanadzuchi::MTA';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $RxFacebook = {
	'from' => qr{\AFacebook [<]mailer-daemon[@]mx[.]facebook[.]com[>]\z},
	'begin' => qr{\AThis message was created automatically by Facebook[.]\z},
	'endof' => qr{\AAction: },
	'subject' => qr{\ASorry, your message could not be delivered\z},
};

# http://postmaster.facebook.com/response_codes
# NOT TESTD EXCEPT RCP-P2
my $RxErrors = {
	'userunknown' => [
		'RCP-P1',	# The attempted recipient address does not exist.
		'INT-P1',	# The attempted recipient address does not exist.
		'INT-P3',	# The attempted recpient group address does not exist.
		'INT-P4',	# The attempted recipient address does not exist.
	],
	'filtered' => [
		'RCP-P2',	# The attempted recipient's preferences prevent messages from being delivered.
	],
	'mesgtoobig' => [
		'MSG-P1',	# The message exceeds Facebook's maximum allowed size.
		'INT-P2',	# The message exceeds Facebook's maximum allowed size.
	],
	'contenterr' => [
		'MSG-P2',	# The message contains an attachment type that Facebook does not accept.
		'POL-P6',	# The message contains a url that has been blocked by Facebook.
	],
	'securityerr' => [
		'POL-P1',	# Your mail server's IP Address is listed on the Spamhaus PBL.
		'POL-P2',	# Facebook will no longer accept mail from your mail server's IP Address.
		'POL-P5',	# The message contains a virus.
		'POL-P7',	# The message does not comply with Facebook's Domain Authentication requirements.
	],
	'notaccept' => [
		'POL-P3',	# Facebook is not accepting messages from your mail server. This will persist for 4 to 8 hours.
		'POL-P4',	# Facebook is not accepting messages from your mail server. This will persist for 24 to 48 hours.
		'POL-T1',	# Facebook is not accepting messages from your mail server, but they may be retried later. This will persist for 1 to 2 hours.
		'POL-T2',	# Facebook is not accepting messages from your mail server, but they may be retried later. This will persist for 4 to 8 hours.
		'POL-T3',	# Facebook is not accepting messages from your mail server, but they may be retried later. This will persist for 24 to 48 hours.
	],
	'rejected' => [
		'DNS-P1',	# Your SMTP MAIL FROM domain does not exist.
		'DNS-P2',	# Your SMTP MAIL FROM domain does not have an MX record.
		'DNS-T1',	# Your SMTP MAIL FROM domain exists but does not currently resolve.
	],
	'undefined' => [
		'DNS-P3',	# Your mail server does not have a reverse DNS record.
		'DNS-T2',	# You mail server's reverse DNS record does not currently resolve.
		'RCP-T1',	# The attempted recipient address is not currently available due to an internal system issue. This is a temporary condition.
		'MSG-T1',	# The number of recipients on the message exceeds Facebook's allowed maximum.
		'CON-T1',	# Facebook's mail server currently has too many connections open to allow another one.
		'CON-T2',	# Your mail server currently has too many connections open to Facebook's mail servers.
		'CON-T3',	# Your mail server has opened too many new connections to Facebook's mail servers in a short period of time.
		'CON-T4',	# Your mail server has exceeded the maximum number of recipients for its current connection.
	],
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub version { '0.1.6' };
sub description { 'Facebook mail' };
sub xsmtpagent { 'X-SMTP-Agent: US::Facebook'.qq(\n); }
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from Facebook
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

	#  _____              _                 _    
	# |  ___|_ _  ___ ___| |__   ___   ___ | | __
	# | |_ / _` |/ __/ _ \ '_ \ / _ \ / _ \| |/ /
	# |  _| (_| | (_|  __/ |_) | (_) | (_) |   < 
	# |_|  \__,_|\___\___|_.__/ \___/ \___/|_|\_\
	#                                            
	return q() unless( $mhead->{'subject'} =~ $RxFacebook->{'subject'} );
	return q() unless( $mhead->{'from'} =~ $RxFacebook->{'from'} );

	my $phead = q();	# (String) Pseudo email header
	my $pstat = q();	# (String) #n.n.n Status code in message body
	my $pdate = q();	# (String) *Date: header
	my $xsmtp = 'DATA';	# (String) SMTP Command in transcript of session
	my $rhostsaid = q();	# (String) Remote host said: ...
	my $rcptintxt = q();	# (String) Recipient address in message body
	my $statintxt = q();	# (String) Facebook Postmaster status

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( ($el =~ $RxFacebook->{'begin'}) .. ($el =~ $RxFacebook->{'endof'}) )
		{
			next() if( $rhostsaid && $rcptintxt );

			# For future release or unknown pattern
			if( $el =~ m{\ADiagnostic-Code: (.+)\z} )
			{
				$rhostsaid = $1;
			}
			elsif( $el =~ m{\AFinal-Recipient:\s?rfc822;\s?([^\s]+[@][^\s]+)\z}i )
			{
				$rcptintxt = $1;
			}
		}

	} # End of foreach(EACH_LINE)

	return q() unless length $rhostsaid;
	$statintxt = $1 if( $rhostsaid =~ m{\s([A-Z]{3}[-][A-Z][1-9])\shttp} );
	$$mbody = q();	# For rewriting Status: header...

	foreach my $_er ( keys %$RxErrors )
	{
		if( grep { $statintxt eq $_ } @{ $RxErrors->{$_er} } )
		{
			$pstat = Kanadzuchi::RFC3463->status($_er,'p','i');
			last();
		}
	}

	$pstat ||= Kanadzuchi::RFC3463->status('undefined','p','i');
	$phead  .= __PACKAGE__->xsmtprecipient($rcptintxt);
	$phead  .= __PACKAGE__->xsmtpstatus($pstat);
	$phead  .= __PACKAGE__->xsmtpdiagnosis($rhostsaid);
	$phead  .= __PACKAGE__->xsmtpcommand($xsmtp);
	$phead  .= __PACKAGE__->xsmtpagent();
	return $phead;
}

1;
__END__
