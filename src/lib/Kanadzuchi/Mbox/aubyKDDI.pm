# $Id: aubyKDDI.pm,v 1.1 2009/12/26 10:35:54 ak Exp $
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

	# Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
	# Filtered recipient returns message that include 'X-SPASIGN' header
	if( ( $mhead->{'content-type'} =~ m{\Atext/plain} ) && ( $mhead->{'x-spasign'} eq q{NG} ) )
	{
		$phead .= q(Action: failed).qq(\n);
		$phead .= q(Status: 5.2.0).qq(\n);
	}

	return( $phead );
}

1;
__END__
