# $Id: Sendmail.pm,v 1.1 2010/07/04 23:45:50 ak Exp $
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
	my $mhead = shift() || return();
	my $mbody = shift() || return();

	return q() unless( $mhead->{'subject'} eq 'Postmaster notify: see transcript for details' );
	return q() unless( $mhead->{'from'} =~ m{\AMail Delivery Subsystem} );

	my $xflag = 0;		# (Integer) Flag, 1 = is Sendmail, 2 = ...While talking..., 4 = Reporting MTA
	my $phead = q();	# (String) Pseudo email header
	my $pbody = q();	# (String) Pseudo body part
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( $xflag == 0 && $el =~ $RxSendmail )
		{
			# ----- Transcript of session follows -----
			$xflag |= 1;
			next();
		}

		if( ( $xflag & 1 ) && ! ( $xflag & 4 ) )
		{
			# ... while talking to mta.example.org.:
			do { $xflag |= 2; next(); } if( $el =~ m{\A[.]+ while talking to .+[:]\z} );

			# Reporting-MTA: dns; mx.example.jp
			# Received-From-MTA: DNS; x1x2x3x4.dhcp.example.ne.jp
			# Arrival-Date: Wed, 29 Apr 2009 16:03:18 +0900
			#
			do { $xflag |= 4; next(); } if( $el =~ m{\AReporting-MTA: } );

		}

		if( ( $xflag & 2 ) && length($xsmtp) == 0 )
		{
			# ... while talking to mfsmax.docomo.ne.jp.:
			# >>> DATA
			# <<< 550 Unknown user ellesan-osuzaru1976-01-04@docomo.ne.jp
			# 554 5.0.0 Service unavailable
			$xsmtp = $1 if( $el =~ m{\A[>]{3}[ ]([A-Z]{4})[ ]} );
		}

		$pbody .= $el.qq(\n) if( $xflag & 7 );
	}

	$xsmtp ||= 'CONN';
	$phead  .= __PACKAGE__->xsmtpcommand().$xsmtp.qq(\n);
	return $phead.$pbody;
}

1;
__END__
