# $Id: Fallback.pm,v 1.2 2010/11/13 19:18:03 ak Exp $
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
sub xsmtpagent
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |x|s|m|t|p|a|g|e|n|t|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Return pseudo-header for SMTP Agent(MTA)
	# @Param <str>	(String) SMTP agnet name
	# @Returns	(String) Pseudo-header
	my $class = shift(); 
	my $agent = shift() || q();
	$agent = '('.$agent.')' if $agent;
	return 'X-SMTP-Agent: Fallback'.$agent.qq(\n);
}

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
	my $ucode = Kanadzuchi::RFC3463->status('undefind','p','i');

	$pstat  = Kanadzuchi::RFC3463->status($mdata->{'reason'},'p','i') || $ucode;
	$phead .= __PACKAGE__->xsmtpstatus($pstat);
	$phead .= __PACKAGE__->xsmtpdiagnosis($mdata->{'message'});
	$phead .= __PACKAGE__->xsmtpcommand('QUIT');
	$phead .= __PACKAGE__->xsmtpagent( $mdata->{'mda'} );
	return $phead;
}

1;
__END__
