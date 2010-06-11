# $Id: KLab.pm,v 1.7 2010/06/10 10:28:51 ak Exp $
# -Id: KLab.pm,v 1.1 2009/08/29 08:50:36 ak Exp -
# -Id: KLab.pm,v 1.1 2009/07/31 09:04:39 ak Exp -
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
use Kanadzuchi::RFC1893;

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub reperio
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|o|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error via AccelMail
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();
	my $phead = q();
	my $pstat = q();

	$phead .= sprintf("Date: %s\n", $mhead->{'date'} );
	$phead .= sprintf("From: %s\n", $mhead->{'to'} );

	if( lc($mhead->{'x-amerror'}) =~ m{\A[ ]?550[ ]+unknown[ ]+user[ ]+(\S+)\z} )
	{
		$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('userunknown'));
		$phead .= q(Status: ).$pstat.qq(\n);
		$phead .= q(Final-Recipient: rfc822; ).qq($1\n);
		$phead .= q(To: ).qq($1\n);
	}
	elsif( lc($mhead->{'x-amerror'}) =~ m{ ?504[ ]+command[ ]+parameter[ ]+not[ ]+implemented} )
	{
		$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('filtered'));
		$phead .= q(Status: ).$pstat.qq(\n);
	}
	else
	{
		$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('onhold'));
		$phead .= q(Status: ).$pstat.qq(\n);
	}

	return( $phead );
}

1;
__END__
