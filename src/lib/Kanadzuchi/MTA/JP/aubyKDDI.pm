# $Id: aubyKDDI.pm,v 1.3 2010/07/07 05:42:04 ak Exp $
# -Id: aubyKDDI.pm,v 1.1 2009/08/29 08:50:38 ak Exp -
# -Id: aubyKDDI.pm,v 1.1 2009/07/31 09:04:51 ak Exp -
# Kanadzuchi::MTA::JP::
                                                            
                 ##              ##  ## ####   ####  ####   
  ####  ##  ##   ##     ##  ##   ## ##  ## ##  ## ##  ##    
     ## ##  ##   #####  ##  ##   ####   ##  ## ##  ## ##    
  ##### ##  ##   ##  ## ##  ##   ####   ##  ## ##  ## ##    
 ##  ## ##  ##   ##  ##  #####   ## ##  ## ##  ## ##  ##    
  #####  #####   #####     ##    ##  ## ####   ####  ####   
                        ####                                
package Kanadzuchi::MTA::JP::aubyKDDI;
use base 'Kanadzuchi::MTA';
use strict;
use warnings;
use Kanadzuchi::RFC1893;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $RxEzweb = {
	'disable' => qr{\AThe[ ]user[(]s[)][ ]account[ ]is[ ]disabled[.]\z},
	'limited' => qr{\AThe[ ]user[(]s[)][ ]account[ ]is[ ]temporarily[ ]limited[.]\z},
	'timeout' => qr{\AThe[ ]following[ ]recipients[ ]did[ ]not[ ]receive[ ]this[ ]message:\z},
};
my $RxauOne = {
	'auone' => qr{\AYour[ ]mail[ ]sent[ ]on[:][ ][A-Z][a-z]{2}[,]},
	'error' => qr{\A\s+Could[ ]not[ ]be[ ]delivered[ ]to[:][ ]},
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub emailheaders
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |e|m|a|i|l|h|e|a|d|e|r|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Required email headers
	# @Param 	<None>
	# @Return	(Ref->Array) Header names
	my $class = shift();
	return [ 'X-SPASIGN' ];
}

sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from aubyKDDI
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();
	my $phead = q();
	my $pstat = q();
	my $isau1 = 0;

	# Pre-Process eMail headers of NON-STANDARD bounce message
	# au by KDDI(ezweb.ne.jp)
	# Subject: Mail System Error - Returned Mail
	# From: <Postmaster@ezweb.ne.jp>
	# Received: from ezweb.ne.jp (wmflb12na02.ezweb.ne.jp [222.15.69.197])
	# Received: from nmomta.auone-net.jp ([aaa.bbb.ccc.ddd]) by ...
	#
	$isau1++ if( lc $mhead->{'from'} =~ m{[<]?(?>postmaster[@]ezweb[.]ne[.]jp)[>]?} );
	$isau1++ if( $mhead->{'subject'} eq 'Mail System Error - Returned Mail' );
	return q() unless( $isau1 || scalar @{ $mhead->{'received'} } );

	$isau1++ if( grep { $_ =~ m{\Afrom[ ]ezweb[.]ne[.]jp[ ]} } @{ $mhead->{'received'} } ||
			grep { $_ =~ m{\Afrom[ ]\w+[.]auone-net[.]jp[ ]} } @{ $mhead->{'received'} } );
	return q() unless( $isau1 );

	if( $mhead->{'x-spasign'} eq 'NG' )
	{
		# Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
		# Filtered recipient returns message that include 'X-SPASIGN' header
		$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('filtered'));
		$phead .= q(Status: ).$pstat.qq(\n);

	}

	if( grep { $_ =~ m{\Afrom[ ]ezweb[.]ne[.]jp[ ]} } @{ $mhead->{'received'} } )
	{
		my $ezweb = 0;		# (Boolean) Flag, Set 1 if the line begins with the string 'The user(s) account is disabled.'
		my $diagn = q();	# (String) Pseudo-Diagnostic-Code:
		my $frcpt = q();	# (String) Pusedo-Final-Recipient:
		my $icode = q();	# (String) Internal error code
		my $etype = { 'userunknown' => 'permanent', 'suspended' => 'temporary', 'onhold' => 'permanent' };
		my $error = { 'disable' => 0, 'limited' => 0, 'timeout' => 0 };

		# Bounced from ezweb.ne.jp
		EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
		{
			next() if( ! $ezweb && $el !~ m{\AThe[ ]} );

			foreach my $__e ( qw{disable limited timeout} )
			{
				next() unless( $el =~ $RxEzweb->{$__e} );

				$diagn .= $el;
				$ezweb  = 1;
				$error->{$__e} = 1;
				last();
			}

			next() unless( $el =~ m{\A[<]} );

			if( $error->{'disable'} )
			{
				# The user(s) account is disabled.
				if( $el =~ m{\A[<](.+[@].+)[>]\z} )
				{
					# The recipient may be unpaid user...?
					$icode = 'suspended';
					$frcpt = $1;
				}
				elsif( $el =~ m{\A[<](.+[@].+)[>][:]\s*.+\s*user[ ]unknown} )
				{
					# Unknown user
					$icode = 'userunknown';
					$frcpt = $1;
				}
			}
			elsif( $error->{'timeout'} )
			{
				# THIS BLOCK IS NOT TESTED
				# Destination host many be down ...?
				if( $el =~ m{\A[<](.+[@].+)[>]\z} )
				{
					$icode = 'suspended';
					$frcpt = $1;
				}
			}
			elsif( $error->{'limited'} )
			{
				# THIS BLOCK IS NOT TESTED
				if( $el =~ m{\A[<](.+[@].+)[>]\z} )
				{
					$icode = 'suspended';
					$frcpt = $1;
				}
			}

			last() if( $icode && $frcpt );

		} # End of foreach(EACH_LINE)

		if( $frcpt )
		{
			$frcpt = Kanadzuchi::RFC2822->cleanup($frcpt);
			$icode ||= 'onhold';

			if( Kanadzuchi::RFC2822->is_emailaddress($frcpt) )
			{
				$phead .= q(Final-Recipient: RFC822; ).$frcpt.qq(\n);
			}

			$pstat  = Kanadzuchi::RFC1893->int2code( Kanadzuchi::RFC1893->internalcode( $icode, $etype->{$icode} ) );
			$phead .= q(Status: ).$pstat.qq(\n);
			$phead .= q(Diagnostic-Code: ).$diagn.qq(\n);
			$phead .= q(From: ).$mhead->{'to'}.qq(\n);
			$phead .= q(Date: ).$mhead->{'date'}.qq(\n);
		}
	}
	else
	{
		my $auone = 0;		# (Boolean) Flag, Set 1 if the line begins with the string 'Your mail sent on: ...'
		my $error = 0;		# (Boolean) Flag, Set 1 if the line begins with the string 'Could not be delivered to..'
		my $diagn = q();	# (String) Pseudo-Diagnostic-Code:

		# Bounced from auone-net.jp
		EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
		{
			# The line which begins with the string 'Your mail sent on: ...'
			if( ! $auone && $el =~ $RxauOne->{'auone'} )
			{
				$diagn .= $el;
				$auone  = 1;
				next();
			}
			elsif( ! $error && $el =~ $RxauOne->{'error'} )
			{
				$diagn .= ' '.$el;
				$error  = 1;
				next();
			}

			next() if( ! $auone || ! $error );

			if( $el =~ qr{\A\s+As[ ]their[ ]mailbox[ ]is[ ]full[.]\z} )
			{
				# Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
				#     Could not be delivered to: <******@**.***.**>
				#     As their mailbox is full.
				$pstat  = Kanadzuchi::RFC1893->int2code(Kanadzuchi::RFC1893->internalcode('mailboxfull','temporary'));
				$phead .= q(Status: ).$pstat.qq(\n);
				$phead .= q(Diagnostic-Code: ).$diagn.' '.$el.qq(\n);
				last();
			}
		}
	}

	return $phead;
}

1;
__END__
