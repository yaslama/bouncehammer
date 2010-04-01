# $Id: aubyKDDI.pm,v 1.3 2010/04/01 08:04:50 ak Exp $
# -Id: aubyKDDI.pm,v 1.1 2009/08/29 08:50:38 ak Exp -
# -Id: aubyKDDI.pm,v 1.1 2009/07/31 09:04:51 ak Exp -
# Kanadzuchi::Mbox::
                                                            
                 ##              ##  ## ####   ####  ####   
  ####  ##  ##   ##     ##  ##   ## ##  ## ##  ## ##  ##    
     ## ##  ##   #####  ##  ##   ####   ##  ## ##  ## ##    
  ##### ##  ##   ##  ## ##  ##   ####   ##  ## ##  ## ##    
 ##  ## ##  ##   ##  ##  #####   ## ##  ## ##  ## ##  ##    
  #####  #####   #####     ##    ##  ## ####   ####  ####   
                        ####                                
package Kanadzuchi::Mbox::aubyKDDI;
use strict;
use warnings;
use Kanadzuchi::RFC1893;

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
	# @Description	Detect an error from aubyKDDI
	# @Param <ref>	(Ref->MIME::Head) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();
	my $phead = q();
	my $pstat = q();

	# Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
	# Filtered recipient returns message that include 'X-SPASIGN' header
	if( ( $mhead->{'content-type'} =~ m{\Atext/plain} ) && ( $mhead->{'x-spasign'} eq q{NG} ) )
	{
		$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('filtered'));
		$phead .= q(Action: failed).qq(\n);
		$phead .= q(Status: ).$pstat.qq(\n);
	}

	return( $phead );
}

1;
__END__
