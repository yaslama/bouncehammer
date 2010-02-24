# $Id: KLab.pm,v 1.1 2009/12/26 10:35:54 ak Exp $
# Kanadzuchi::Mbox::
                             
 ##  ## ##           ##      
 ## ##  ##     ####  ##      
 ####   ##        ## #####   
 ####   ##     ##### ##  ##  
 ## ##  ##    ##  ## ##  ##  
 ##  ## ###### ##### #####   

package Kanadzuchi::Mbox::KLab;
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
	# @Description	Detect an error via AccelMail
	# @Param <ref>	(Ref->MIME::Head) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();
	my $phead = q();

	$phead .= sprintf("Date: %s\n", $mhead->{'date'} );
	$phead .= sprintf("From: %s\n", $mhead->{'to'} );
	$phead .= q(Action: failed).qq(\n);

	if( lc($mhead->{'x-amerror'}) =~ m{\A[ ]?550[ ]+unknown[ ]+user[ ]+(\S+)\z} )
	{
		$phead .= q(Status: 5.1.1).qq(\n);
		$phead .= q(Final-Recipient: rfc822; ).qq($1\n);
		$phead .= q(To: ).qq($1\n);
	}
	elsif( lc($mhead->{'x-amerror'}) =~ m{ ?504[ ]+command[ ]+parameter[ ]+not[ ]+implemented} )
	{
		$phead .= q(Status: 5.2.0).qq(\n);
	}
	else
	{
		$phead .= q(Status: 5.9.9).qq(\n);
	}

	return( $phead );
}

1;
__END__
