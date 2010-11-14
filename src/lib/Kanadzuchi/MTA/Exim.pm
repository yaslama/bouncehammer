# $Id: Exim.pm,v 1.4 2010/11/13 19:18:03 ak Exp $
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
	'from' => qr/\AMail Delivery System/,
	'begin' => qr/\AThis message was created automatically by mail delivery software[.]\z/,
	'endof' => qr/\A------ This is a copy of the message.+headers[.] ------\z/,
	'subject' => qr/\AMail delivery failed(:?: returning message to sender)?\z/,
	'message-id' => qr/\A[<]\w+[-]\w+[-]\w+[@].+\z/,
	# Message-Id: <E1P1YNN-0003AD-Ga@example.org>
};

my $RxBounced = {
	'mail' => qr/\AA message that you sent could not be delivered to (?:one or more|all) of its/,
	'rcpt' => qr/\Acould not be delivered to one or more of its recipients[.] The following/,
};

# src/transports/smtp.c
my $RxSMTPErr = {
	'mail' => qr/SMTP error from remote (?:mail server|mailer) after MAIL FROM:/,
	'rcpt' => qr/SMTP error from remote (?:mail server|mailer) after RCPT TO:/,
	'data' => qr/SMTP error from remote (?:mail server|mailer) after (?:DATA|end of data):/,
};

# find exim/ -type f -exec grep 'message = US' {} /dev/null \;
my $RxTrError = {
	'userunknown' => [
		qr/user not found/,
	],
	'hostunknown' => [
		qr/all relevant MX records point to non-existent hosts/,
		qr/Unrouteable address/,
		qr/all host address lookups failed permanently/,
	],
	'mailboxfull' => [
		qr/mailbox is full:?/,
		qr/error: quota exceed/i,
	],
	'notaccept' => [
		qr/an MX or SRV record indicated no SMTP service/,
		qr/no host found for existing SMTP connection/
	],
	'systemerror' => [
		qr/delivery to (?:file|pipe) forbidden/,
		qr/local delivery failed/,
	],
	'contenterr' => [
		qr/Too many ["]Received["] headers /,
	],
};

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub xsmtpagent { 'X-SMTP-Agent: Exim'.qq(\n); }
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
	return q() unless( $mhead->{'subject'} =~ $RxEximMTA->{'subject'} );
	return q() unless( $mhead->{'from'} =~ $RxEximMTA->{'from'} );
	# return q() unless( $mhead->{'message-id'} =~ $RxEximMTA->{'message-id'} );

	my $xmode = { 'begin' => 1 << 0, 'error' => 1 << 1, 'endof' => 1 << 2 };
	my $xflag = 0;		# (Integer) Flag
	my $pstat = q();	# (String) Stauts code
	my $phead = q();	# (String) Pseudo email header
	my $xsmtp = q();	# (String) SMTP Command in transcript of session
	my $causa = q();	# (String) Error reason
	my $ucode = Kanadzuchi::RFC3463->status('undefined','p','i');

	my $statintxt = q();	# (String) #n.n.n
	my $rhostsaid = q();	# (String) Diagnostic-Code:
	my $ldafailed = 0;	# (Integer) local delivery failed
	my $smtperror = 0;	# (Integer) Flag, SMTP Error
	my $smtpermap = { 'mail' => 'rejected', 'rcpt' => 'userunknown', 'data' => 'filtered' };

	EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
	{
		if( ($el =~ $RxEximMTA->{'begin'}) .. ($el =~ $RxEximMTA->{'endof'}) )
		{
			# This message was created automatically by mail delivery software.
			#
			if( $el =~ $RxBounced->{'mail'} || $el =~ $RxBounced->{'rcpt'} )
			{
				# A message that you sent could not be delivered to one or more of its
				# recipients. This is a permanent error. The following address(es) failed:
				#  -- OR --
				# could not be delivered to one or more of its recipients. The following
				# address(es) failed: ***@****.**
				$rhostsaid = $el;
				next();
			}

			if( $rhostsaid )
			{
				last() if( $el =~ $RxEximMTA->{'endof'} );
				$rhostsaid .= ' '.$el;
			}
		}
	}

	return q() unless $rhostsaid;
	$rhostsaid =~ s{\A }{}g;
	$rhostsaid =~ s{ \z}{}g;
	$rhostsaid =~ y{ }{ }s;
	$rhostsaid =~ s{\A.+address[(]es[)] failed: }{};

	SMTP_ERROR: foreach my $s ( keys %$RxSMTPErr )
	{
		if( $rhostsaid =~ $RxSMTPErr->{ $s } )
		{
			$xsmtp = uc $s;
			last();
		}
	}

	TRANSPORT_ERROR: foreach my $t ( keys %$RxTrError )
	{
		if( grep { $rhostsaid =~ $_ } @{ $RxTrError->{ $t } } )
		{
			$causa = $t;
			last();
		}
	}

	if( $rhostsaid =~ m{\b([45][.][0-9][.][0-9]+)\b} )
	{
		$pstat = $1;
	}
	elsif( $causa )
	{
		$pstat = Kanadzuchi::RFC3463->status( $causa, 'p', 'i' );
	}
	else
	{
		$pstat = $ucode if $rhostsaid;
	}

	$phead .= 'Final-Recipient: '.$mhead->{'x-failed-recipients'}.qq(\n);
	$phead .= __PACKAGE__->xsmtpdiagnosis($rhostsaid);
	$phead .= __PACKAGE__->xsmtpcommand($xsmtp);
	$phead .= __PACKAGE__->xsmtpstatus($pstat);
	$phead .= __PACKAGE__->xsmtpagent();

	return $phead;
}

1;
__END__
