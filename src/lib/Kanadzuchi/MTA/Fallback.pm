# $Id: Fallback.pm,v 1.1 2010/10/05 11:21:25 ak Exp $
# Kanadzuchi::MTA::
                                                    
 ######       ###  ###  ##                  ##      
 ##     ####   ##   ##  ##      ####   #### ##      
 ####      ##  ##   ##  #####      ## ##    ## ##   
 ##     #####  ##   ##  ##  ##  ##### ##    ####    
 ##    ##  ##  ##   ##  ##  ## ##  ## ##    ## ##   
 ##     ##### #### #### #####   #####  #### ##  ##  
package Kanadzuchi::MTA::Fallback;
use base 'Kanadzuchi::MTA';
use Kanadzuchi::MDA;
use strict;
use warnings;

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
	# @Description	Detect an error from Sendmail
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();
	my $mdata = Kanadzuchi::MDA->parse($mhead,$mbody) || return q();
	my $pstat = 0;
	my $phead = q();

	$pstat  = Kanadzuchi::RFC3463->status($mdata->{'reason'},'p','i') || '5.0.900';
	$phead .= 'Status: '.$pstat.qq(\n);
	$phead .= 'Diagnostic-Code: '.$mdata->{'message'}.qq(\n);
	$phead .= __PACKAGE__->xsmtpcommand().qq(QUIT\n) if( $phead );
	return $phead;
}

1;
__END__
