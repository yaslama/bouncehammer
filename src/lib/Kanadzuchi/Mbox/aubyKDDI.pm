# $Id: aubyKDDI.pm,v 1.5 2010/05/24 16:54:27 ak Exp $
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
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift();
	my $mbody = shift();
	my $phead = q();
	my $pstat = q();

	if( ( $mhead->{'content-type'} =~ m{\Atext/plain} ) && ( $mhead->{'x-spasign'} eq q{NG} ) )
	{
		# Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
		# Filtered recipient returns message that include 'X-SPASIGN' header
		$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('filtered'));
		$phead .= q(Status: ).$pstat.qq(\n);
	}
	else
	{
		my $auone = 0;		# (Boolean) Flag, Set 1 if the line begins with the string 'Your mail sent on: ...'
		my $error = 0;		# (Boolean) Flag, Set 1 if the line begins with the string 'Could not be delivered to..'
		my $diagn = q();	# (String) Pseudo-Diagnostic-Code:
		my $rxau1 = {
			'auone' => qr{\AYour[ ]mail[ ]sent[ ]on[:][ ][A-Z][a-z]{2}[,]},
			'error' => qr{\A\s+Could[ ]not[ ]be[ ]delivered[ ]to[:][ ]},
		};
		my $rxerr = {
			'mailboxfull' => qr{\A\s+As[ ]their[ ]mailbox[ ]is[ ]full[.]\z}
		};

		# Bounced from auone-net.jp
		EACH_LINE: foreach my $_ln ( split( qq{\n}, $$mbody ) )
		{
			# The line which begins with the string 'Your mail sent on: ...'
			if( ! $auone && $_ln =~ $rxau1->{'auone'} )
			{
				$diagn .= $_ln;
				$auone  = 1;
				next();
			}
			elsif( ! $error && $_ln =~ $rxau1->{'error'} )
			{
				$diagn .= ' '.$_ln;
				$error  = 1;
				next();
			}

			next() if( ! $auone || ! $error );

			if( $_ln =~ $rxerr->{'mailboxfull'} )
			{
				# Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
				#     Could not be delivered to: <******@**.***.**>
				#     As their mailbox is full.
				$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('mailboxfull'));
				$phead .= q(Status: ).$pstat.qq(\n);
				$phead .= q(Diagnostic-Code: ).$diagn.' '.$_ln.qq(\n);
			}
		}
	}

	return( $phead );
}

1;
__END__
