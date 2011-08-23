# $Id: Biglobe.pm,v 1.1.2.4 2011/08/23 23:19:02 ak Exp $
# Kanadzuchi::MTA::JP::
                                                 
 #####    ##          ###         ##             
 ##  ##        #####   ##   ####  ##      ####   
 #####   ###  ##  ##   ##  ##  ## #####  ##  ##  
 ##  ##   ##  ##  ##   ##  ##  ## ##  ## ######  
 ##  ##   ##   #####   ##  ##  ## ##  ## ##      
 #####   ####     ##  ####  ####  #####   ####   
              #####                              
package Kanadzuchi::MTA::JP::Biglobe;
use strict;
use warnings;
use base 'Kanadzuchi::MTA';

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $RxBiglobe = {
	'begin' => qr{\A   ----- The following addresses had delivery problems -----\z},
	'error' => qr{\A   ----- Non-delivered information -----\z},
	'endof' => qr{\AContent-Type: message/rfc822\z},
};

my $RxErrors = {
	'filtered' => [
		qr{Mail Delivery Failed[.][.][.] User unknown},
	],
	'mailboxfull' => [
		qr{The number of messages in recipient's mailbox exceeded the local limit[.]},
	],
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub version { '0.1.3' };
sub description { 'NEC Biglobe' };
sub xsmtpagent { 'X-SMTP-Agent: JP::Biglobe'.qq(\n); }
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
	return [ '' ];
}

sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error of Biglobe(NEC)
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

	return q() unless( $mhead->{'from'} =~ m{\Apostmaster[@]biglobe[.]ne[.]jp\z} );
	return q() unless( $mhead->{'subject'} =~ m{\AReturned mail:} );

	my $phead = q();
	my $pstat = q();
	my $xsmtp = q();
	my $causa = q();	# (String) Error reason
	my $endof = 0;		# (Integer) The line matched 'endof' regexp.

	my $rcptintxt = q();	# (String) #n.n.n
	my $rhostsaid = q();	# (String) Diagnostic-Code:

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		$endof = 1 if( $endof == 0 && $el =~ $RxBiglobe->{'endof'} );
		next() if( $endof || $el =~ m{\A\z} );

		if( ($el =~ $RxBiglobe->{'begin'}) .. ($el =~ $RxBiglobe->{'endof'}) )
		{
			# This is a MIME-encapsulated message.
			#
			# ----_Biglobe000000/00000.biglobe.ne.jp
			# Content-Type: text/plain; charset="iso-2022-jp"
			#
			#    ----- The following addresses had delivery problems -----
			# ********@***.biglobe.ne.jp
			#
			#    ----- Non-delivered information -----
			# The number of messages in recipient's mailbox exceeded the local limit.
			#
			# ----_Biglobe000000/00000.biglobe.ne.jp
			# Content-Type: message/rfc822

			if( ! $rcptintxt && $el =~ m{\A.+[@].+\z} )
			{
				$rcptintxt = $el;
				next();
			}

			if( $el =~ $RxBiglobe->{'error'} )
			{
				$rhostsaid = $el;
				next();
			}
			elsif( length $rhostsaid )
			{
				$rhostsaid = $el;
				$endof = 1;
				next();
			}
		}
	}

	return q() unless $rcptintxt;
	return q() unless $rhostsaid;
	$rhostsaid =~ y{ }{ }s;
	$rhostsaid =~ s{--\d+[.]\d+/\w.+\z}{};

	foreach my $er ( keys %$RxErrors )
	{
		if( grep { $rhostsaid =~ $_ } @{ $RxErrors->{ $er } } )
		{
			$causa = $er;
			$pstat  = Kanadzuchi::RFC3463->status($er,'p','i');
			last();
		}
	}

	$pstat ||= Kanadzuchi::RFC3463->status('undefined','p','i');
	$phead  .= __PACKAGE__->xsmtpstatus($pstat);
	$phead  .= __PACKAGE__->xsmtpdiagnosis($rhostsaid);
	$phead  .= __PACKAGE__->xsmtpcommand($xsmtp);
	$phead  .= __PACKAGE__->xsmtpagent();
	return( $phead );
}

1;
__END__
