# $Id: Exim.pm,v 1.2 2010/10/25 20:09:25 ak Exp $
# Kanadzuchi::MTA::
                              
 ######           ##          
 ##      ##  ##       ##  ##  
 ####     ####   ###  ######  
 ##        ##     ##  ######  
 ##       ####    ##  ##  ##  
 ######  ##  ##  #### ##  ##  

# See http://www.exim.org/
package Kanadzuchi::MTA::Exim;
use base 'Kanadzuchi::MTA';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# Error text regular expressions which defined in exim/src/deliver.c
#
# deliver.c:6292| fprintf(f,
# deliver.c:6293|"This message was created automatically by mail delivery software.\n");
# deliver.c:6294|        if (to_sender)
# deliver.c:6295|          {
# deliver.c:6296|          fprintf(f,
# deliver.c:6297|"\nA message that you sent could not be delivered to one or more of its\n"
# deliver.c:6298|"recipients. This is a permanent error. The following address(es) failed:\n");
# deliver.c:6299|          }
# deliver.c:6300|        else
# deliver.c:6301|          {
# deliver.c:6302|          fprintf(f,
# deliver.c:6303|"\nA message sent by\n\n  <%s>\n\n"
# deliver.c:6304|"could not be delivered to one or more of its recipients. The following\n"
# deliver.c:6305|"address(es) failed:\n", sender_address);
# deliver.c:6306|          }
#
# deliver.c:6423|          if (bounce_return_body) fprintf(f,
# deliver.c:6424|"------ This is a copy of the message, including all the headers. ------\n");
# deliver.c:6425|          else fprintf(f,
# deliver.c:6426|"------ This is a copy of the message's headers. ------\n");
#
my $RxEximMTA = {
	'begin' => qr/\AThis message was created automatically by mail delivery software[.]\z/,
	'endof' => qr/\A------ This is a copy of the message.+headers[.] ------\z/,
};

my $RxBounced = {
	'mail' => qr/\AA message that you sent could not be delivered to one or more of its\z/,
	'rcpt' => qr/\Acould not be delivered to one or more of its recipients[.] The following\z/,
	'ldaf' => qr/\A {4}local delivery failed\z/,
};

# src/transports/smtp.c
my $RxSMTPErr = {
	'mail' => qr/\A {4}SMTP error from remote (?:mail server|mailer) after MAIL FROM:/,
	'rcpt' => qr/\A {4}SMTP error from remote (?:mail server|mailer) after RCPT TO:/,
	'data' => qr/\A {4}SMTP error from remote (?:mail server|mailer) after (?:DATA|end of data):/,
};

# find exim/ -type f -exec grep 'message = US' {} /dev/null \;
my $RxTrError = {
	'hostunknown' => [
		qr/ {4}all relevant MX records point to non-existent hosts/,
		qr/ {4}Unrouteable address/,
		qr/ {4}all host address lookups failed permanently/,
	],
	'mailboxfull' => [
		qr/ {4}mailbox is full:?/,
		qr/error: quota exceed/i,
	],
	'notaccept' => [
		qr/ {4}an MX or SRV record indicated no SMTP service/,
		qr/ {4}no host found for existing SMTP connection/
	],
	'systemerror' => [
		qr/ {4}delivery to (?:file|pipe) forbidden/,
	],
	'contenterr' => [
		qr/ {4}Too many ["]Received["] headers /,
	],
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
	return [ 'X-Failed-Recipients' ];
}

sub reperit
{
	# +-+-+-+-+-+-+-+
	# |r|e|p|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Detect an error from Exim
	# @Param <ref>	(Ref->Hash) Message header
	# @Param <ref>	(Ref->String) Message body
	# @Return	(String) Pseudo header content
	my $class = shift();
	my $mhead = shift() || return q();
	my $mbody = shift() || return q();

	return q() unless defined $mhead->{'x-failed-recipients'};
	return q() unless( $mhead->{'subject'} =~ m{\AMail delivery failed(:?: returning message to sender)?\z} );
	return q() unless( $mhead->{'from'} =~ m{\AMail Delivery System} );

	my $xmode = { 'begin' => 1 << 0, 'error' => 1 << 1, 'endof' => 1 << 2 };
	my $xflag = 0;		# (Integer) Flag
	my $pstat = q();	# (String) Stauts code
	my $phead = q();	# (String) Pseudo email header
	my $xsmtp = q();	# (String) SMTP Command in transcript of session

	my $statintxt = q();	# (String) #n.n.n
	my $diagnosis = q();	# (String) Diagnostic-Code:
	my $ldafailed = 0;	# (Integer) local delivery failed
	my $smtperror = 0;	# (Integer) Flag, SMTP Error
	my $smtpermap = { 'mail' => 'rejected', 'rcpt' => 'userunknown', 'data' => 'filtered' };

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		next() if( $el =~ m{\A\z} );
		if( $xflag == 0 && $el =~ $RxEximMTA->{'begin'} )
		{
			# This message was created automatically by mail delivery software.
			$xflag |= $xmode->{'begin'};
			next();
		}

		if( $xflag == $xmode->{'begin'} )
		{
			# A message that you sent could not be delivered to one or more of its
			# recipients. This is a permanent error. The following address(es) failed:
			#  -- OR --
			# could not be delivered to one or more of its recipients. The following
			# address(es) failed: ***@****.**
			$xflag |= $xmode->{'error'} if( $el =~ $RxBounced->{'mail'} 
					|| $el =~ $RxBounced->{'from'} || $el =~ $RxBounced->{'rcpt'} );
			next();
		}

		if( ( $xflag & $xmode->{'begin'} ) && ( $xflag & $xmode->{'error'} ) )
		{
			#  ****@****.**
			#    local delivery failed
			if( $el =~ $RxBounced->{'ldaf'} )
			{
				$ldafailed =  1;
				$diagnosis =  $el;
				$diagnosis =~ s{\A }{}g;
				next();
			}

			SMTP_ERROR: foreach my $se ( keys %$RxSMTPErr )
			{
				if( $el =~ $RxSMTPErr->{$se} )
				{
					$diagnosis .= $el;
					$smtperror += 1;
					$xsmtp = uc $se;
					$pstat = Kanadzuchi::RFC3463->status($smtpermap->{$se},'p','i') || '5.0.900';
					next(EACH_LINE);
				}
			}

			TRANSPORT_ERROR: foreach my $er ( keys %$RxTrError )
			{
				if( grep { $el =~ $_ } @{ $RxTrError->{$er} } )
				{
					$diagnosis .= $diagnosis ? ': '.$el : $el;
					$pstat  = Kanadzuchi::RFC3463->status($er,'p','i') || '5.0.900';
					$phead .= 'Status: '.$pstat.qq(\n);
					last();
				}
			}
		}

		if( $smtperror )
		{
			# SMTP Error
			$diagnosis .= ' '.$el if( $el =~ m{\A[ ]{4}.+\z} );
		}

		last() if( $el =~ $RxEximMTA->{'endof'} );
	}

	if( $smtperror )
	{
		$diagnosis =~ y{ }{}s;
		if( $diagnosis =~ m{\b([45][.][0-9][.][0-9]+)\b} )
		{
			$phead = 'Status: '.$1.qq(\n);
		}
		elsif( $pstat )
		{
			$phead .= 'Status: '.$pstat.qq(\n);
		}
	}

	$xsmtp ||= 'CONN';
	$phead ||= 'Status: 5.0.0'.qq(\n) if( $ldafailed );
	$phead .=  'Final-Recipient: '.$mhead->{'x-failed-recipients'}.qq(\n);
	$phead .=  'X-Diagnosis: '.$diagnosis.qq(\n);
	$phead .=  __PACKAGE__->xsmtpcommand().$xsmtp.qq(\n) if( $phead );
	return $phead;
}

1;
__END__
