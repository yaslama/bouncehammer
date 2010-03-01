# $Id: Google.pm,v 1.2 2010/03/01 23:42:02 ak Exp $
# -Id: Google.pm,v 1.1 2009/08/29 08:50:36 ak Exp -
# -Id: Google.pm,v 1.1 2009/07/31 09:04:38 ak Exp -
# Kanadzuchi::Mbox::

  ####                        ###          
 ##  ##  ####   ####   #####   ##   ####   
 ##     ##  ## ##  ## ##  ##   ##  ##  ##  
 ## ### ##  ## ##  ## ##  ##   ##  ######  
 ##  ## ##  ## ##  ##  #####   ##  ##      
  ####   ####   ####      ##  ####  ####   
                      #####                
package Kanadzuchi::Mbox::Google;
use strict;
use warnings;

#   ____ ____ ____ ____ ____ ____ ____ 
#  ||M |||e |||t |||h |||o |||d |||s ||
#  ||__|||__|||__|||__|||__|||__|||__||
#  |/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub detectus
{
	# +-+-+-+-+-+-+-+-+
	# |d|e|t|e|c|t|u|s|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Detect an error via Google(Gmail)
	# @Param <ref>	(Ref->MIME::Head) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();
	my $phead = q();

	# * Check the body part
	#	This is an automatically generated Delivery Status Notification
	#	Delivery to the following recipient failed permanently:
	#
	#		recipient-address-here@example.jp
	#
	#	Technical details of permanent failure: 
	#	Google tried to deliver your message, but it was rejected by the
	#	recipient domain. We recommend contacting the other email provider
	#	for further information about the cause of this error. The error
	#	that the other server returned was: 
	#	550 550 <recipient-address-heare@example.jp>: User unknown (state 14).
	#

	return(q{}) unless( $mhead->{'from'} =~ m{[@]googlemail[.]com[>]?\z} );
	return(q{}) unless( $mhead->{'subject'} =~ m{Delivery[ ]Status[ ]Notification} );
	return(q{}) unless( $$mbody =~ m{This is an automatically generated Delivery Status Notification}i );

	$phead .= sprintf("Date: %s\n", $mhead->{'date'} );
	$phead .= sprintf("From: %s\n", $mhead->{'to'} );
	$phead .= q(Action: failed).qq(\n);

	# X-Failed-Recipients: recipient-address-here@example.jp
	if( lc($mhead->{'x-failed-recipients'}) =~ m{\A[ ]?(.+)[ ]*\z} )
	{
		my $frcpt = $1;
		my $ebody = qr{Delivery[ ]to[ ]the[ ]following[ ]recipient[ ]failed[ ]permanently:}io;
		my $ectxt = qr{The[ ]error[ ]that[ ]the[ ]other[ ]server[ ]returned[ ]was:}io;
		my $dcode = q();
		my $dstat = q(5.9.9);

		return(q{}) unless( $$mbody =~ m{$ebody\n\n.+$frcpt} );

		if( $$mbody =~ m{$ectxt[ ]+\d+[ ](.+)[ ]+[(]state[ ]\d+[)][.]\n}is )
		{
			# Get the delivery status value from Diagnostic-Code header
			$dcode = $1;
			if( $dcode =~ m{[^\d]+[#]?(\d[.]\d[.]\d)[^\d]+} ){ $dstat = $1; }

			$phead .= q(Diagnostic-Code: SMTP; ).qq($dcode\n);
			$phead .= q(Status: ).qq($dstat\n);
			$phead .= q(Final-Recipient: rfc822; ).qq($frcpt\n);
			$phead .= q(To: ).qq($frcpt\n);
		}
	}
	else
	{
		return(q{});
	}

	return( $phead );
}

1;
__END__
