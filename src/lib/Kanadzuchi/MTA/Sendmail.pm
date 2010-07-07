# $Id: Sendmail.pm,v 1.3 2010/07/07 05:42:03 ak Exp $
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
my $RxSendmail = qr{\A\s+[-]+ Transcript of session follows [-]+\z};

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
	#
	# @Description	Detect an error from qmail
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

	return q() unless( $mhead->{'subject'} =~ m{see transcript for details\z} );
	return q() unless( $mhead->{'from'} =~ m{\AMail Delivery Subsystem} );

	my $xflag = 0;		# (Integer) Flag, 1 = is Sendmail, 2 = ...While talking..., 4 = Reporting MTA
	my $phead = q();	# (String) Pseudo email header
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( $xflag == 0 && $el =~ $RxSendmail )
		{
			# ----- Transcript of session follows -----
			$xflag |= 1;
			next();
		}

		if( $xflag == 1 )
		{
			# ... while talking to mta.example.org.:
			$xflag |= 2 if( $el =~ m{\A[.]+ while talking to .+[:]\z} );
			next();
		}

		if( $xflag == 3 )
		{
			# ... while talking to mta.example.jp.:
			# >>> DATA
			# <<< 550 Unknown user recipient@example.jp
			# 554 5.0.0 Service unavailable
			$xsmtp = $1 if( length($xsmtp) == 0 && $el =~ m{\A[>]{3}[ ]([A-Z]{4})[ ]} );

			# Reporting-MTA: dns; mx.example.jp
			# Received-From-MTA: DNS; x1x2x3x4.dhcp.example.ne.jp
			# Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
			last() if( $el =~ m{\AReporting-MTA: } );
		}
	}

	$xsmtp ||= 'CONN';
	$phead  .= __PACKAGE__->xsmtpcommand().$xsmtp.qq(\n);
	return $phead;
}

1;
__END__
