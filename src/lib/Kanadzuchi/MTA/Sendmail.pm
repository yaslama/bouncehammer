# $Id: Sendmail.pm,v 1.6.2.3 2011/08/23 21:28:27 ak Exp $
# Kanadzuchi::MTA::
                                                          
  #####                    ##                  ##  ###    
 ###      ####  #####      ##  ##  ##  ####         ##    
  ###    ##  ## ##  ##  #####  ######     ##  ###   ##    
   ###   ###### ##  ## ##  ##  ######  #####   ##   ##    
    ###  ##     ##  ## ##  ##  ##  ## ##  ##   ##   ##    
 #####    ####  ##  ##  #####  ##  ##  #####  #### ####   
package Kanadzuchi::MTA::Sendmail;
use base 'Kanadzuchi::MTA';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Error text regular expressions which defined in sendmail/savemail.c
#
# savemail.c:1040|if (printheader && !putline("   ----- Transcript of session follows -----\n",
# savemail.c:1041|			mci))
# savemail.c:1042|	goto writeerr;
#
my $RxSendmail = {
	'from' => qr{\AMail Delivery Subsystem},
	'begin'	=> qr{\A\s+[-]+ Transcript of session follows [-]+\z},
	'error' => qr{\A[.]+ while talking to .+[:]\z},
	'endof' => qr{\AReporting-MTA: },
	'subject' => qr{see transcript for details\z},
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub version { '2.1.3' }
sub description { 'V8Sendmail: /usr/sbin/sendmail' };
sub xsmtpagent { 'X-SMTP-Agent: Sendmail'.qq(\n); }
sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from Sendmail
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

	return q() unless( $mhead->{'subject'} =~ $RxSendmail->{'subject'} );
	return q() unless( $mhead->{'from'} =~ $RxSendmail->{'from'} );

	my $phead = q();	# (String) Pseudo email header
	my $pstat = q();	# (String) Stauts code
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( ($el =~ $RxSendmail->{'begin'}) .. ($el =~ $RxSendmail->{'endof'}) )
		{
			next() if( $xsmtp && $pstat );
			if( ! length($xsmtp) & $el =~ m{\A[>]{3}[ ]([A-Z]{4})[ ]?} )
			{
				# ----- Transcript of session follows -----
				# ... while talking to mta.example.org.:
				# >>> DATA
				# <<< 550 Unknown user recipient@example.jp
				# 554 5.0.0 Service unavailable
				# ...
				# Reporting-MTA: dns; mx.example.jp
				# Received-From-MTA: DNS; x1x2x3x4.dhcp.example.ne.jp
				# Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
				$xsmtp = $1;
				next();
			}

			if( ! length($pstat) & $el =~ m{\A\d{3} ([45][.]\d[.]\d+)} )
			{
				# 554 5.0.0 Service unavailable
				$pstat = $1;
				next();
			}
		}
	}

	$phead .= __PACKAGE__->xsmtpcommand($xsmtp);
	$phead .= __PACKAGE__->xsmtpstatus($pstat);
	$phead .= __PACKAGE__->xsmtpagent();
	return $phead;
}

1;
__END__
