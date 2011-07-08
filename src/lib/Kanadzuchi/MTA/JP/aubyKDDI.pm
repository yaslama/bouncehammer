# $Id: aubyKDDI.pm,v 1.6.2.3 2011/07/08 01:02:05 ak Exp $
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

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub xsmtpagent { 'X-SMTP-Agent: JP::aubyKDDI'.qq(\n); }
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
	my $isau1 = 0;

	# Pre-Process eMail headers of NON-STANDARD bounce message
	# au by KDDI(ezweb.ne.jp)
	# Subject: Mail System Error - Returned Mail
	# From: <Postmaster@ezweb.ne.jp>
	# Received: from ezweb.ne.jp (wmflb12na02.ezweb.ne.jp [222.15.69.197])
	# Received: from nmomta.auone-net.jp ([aaa.bbb.ccc.ddd]) by ...
	#
	$isau1++ if( lc($mhead->{'from'}) =~ m{[<]?(?>postmaster[@]ezweb[.]ne[.]jp)[>]?} );
	$isau1++ if( $mhead->{'reply-to'} && lc($mhead->{'reply-to'}) =~ m{[<]?.+[@]\w+[.]auone-net[.]jp[>]?\z} );
	$isau1++ if( $mhead->{'subject'} eq 'Mail System Error - Returned Mail' );
	return q() unless( $isau1 || scalar @{ $mhead->{'received'} } );

	$isau1++ if( grep { $_ =~ m{\Afrom ezweb[.]ne[.]jp } } @{ $mhead->{'received'} } );
	$isau1++ if( grep { $_ =~ m{\Afrom \w+[.]auone[-]net[.]jp } } @{ $mhead->{'received'} } );
	return q() unless( $isau1 );

	my $phead = q();	# (String) Pseudo-Header
	my $pstat = q();	# (String) Pseudo Status for X-SMTP-STatus
	my $causa = q();	# (String) Error Reason
	my $xsmtp = q();	# (String) SMTP command for X-SMTP-Command
	my $endof = 0;		# (Integer) The line matched 'endof' regexp.

	my $rhostsaid = q();	# (String) Pseudo-Diagnostic-Code:, X-SMTP-Diagnosis:
	my $rcptintxt = q();	# (String) Pusedo-Final-Recipient:
	my $statintxt = q();	# (String) Status: in the message body

	if( defined $mhead->{'x-spasign'} && $mhead->{'x-spasign'} eq 'NG' )
	{
		# Content-Type: text/plain; ..., X-SPASIGN: NG (spamghetti, au by KDDI)
		# Filtered recipient returns message that include 'X-SPASIGN' header
		$pstat  = Kanadzuchi::RFC3463->status('filtered','p','i');
		$phead .= __PACKAGE__->xsmtpstatus($pstat);
		return $phead;
	}

	if( grep { $_ =~ m{\Afrom[ ]ezweb[.]ne[.]jp[ ]} } @{ $mhead->{'received'} } )
	{
		#    ____                         _                    _       
		#   / __ \  ___ ______      _____| |__   _ __   ___   (_)_ __  
		#  / / _` |/ _ \_  /\ \ /\ / / _ \ '_ \ | '_ \ / _ \  | | '_ \ 
		# | | (_| |  __// /  \ V  V /  __/ |_) || | | |  __/_ | | |_) |
		#  \ \__,_|\___/___|  \_/\_/ \___|_.__(_)_| |_|\___(_)/ | .__/ 
		#   \____/                                          |__/|_|    
		my $typemap = { 'notaccept' => 'p', 'suspend' => 'p', 'expired' => 't', 'onhold' => 'p' };
		my $RxEzweb = {
			# The user(s) 
			'begin' => qr{\A(?:The user[(]s[)] |Your message |Each of the following|The following)},
			'endof' => qr{\A--},
		};

		my $RxError = {
			'notaccept' => [
				qr{\AThe following recipients did not receive this message:},
			],
			'mailboxfull' => [
				qr{\AThe user[(]s[)] account is temporarily over quota},
			],
			# http://www.naruhodo-au.kddi.com/qa3429203.html
			'suspend' => [
				# The recipient may be unpaid user...?
				qr{\AThe user[(]s[)] account is disabled[.]},

				# ***** THE FOLLOWING PATTERNS ARE NOT TESTED *****
				qr{\AThe user[(]s[)] account is temporarily limited[.]},
			],
			'expired' => [
				# Your message was not delivered within 0 days and 1 hours.
				# Remote host is not responding.
				qr{\AYour message was not delivered within },
			],
			'onhold' => [
				qr{Each of the following recipients was rejected by a remote mail server},
			],
		};


		EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
		{
			if( ($el =~ $RxEzweb->{'begin'}) .. ($el =~ $RxEzweb->{'endof'}) )
			{
				if( $el =~ $RxEzweb->{'begin'} )
				{
					$rhostsaid .= $el;
					next();
				}

				if( $el =~ $RxEzweb->{'endof'} )
				{
					$endof = 1;
					next();
				}

				if( $rhostsaid )
				{
					next() if( $endof || $el =~ m{\A--} || $el =~ m{\A\z} );
					if( $el =~ m{\A[<](.+[@].+)[>]:?(.*)\z} )
					{
						# The user(s) account is disabled.
						#
						# <***@ezweb.ne.jp>: 550 user unknown (in reply to RCPT TO command)
						$rcptintxt = Kanadzuchi::Address->canonify($1);
						$rhostsaid .= ' '.$2;
					}
					elsif( $el =~ m{\A +Recipient: [<](.+[@].+)[>]} )
					{
						# Each of the following recipients was rejected by a remote
						# mail server.
						#
						#    Recipient: <******@ezweb.ne.jp>
						#    >>> RCPT TO:<******@ezweb.ne.jp>
						#    <<< 550 <******@ezweb.ne.jp>: User unknown
						$rcptintxt = Kanadzuchi::Address->canonify($1);
					}
					else
					{
						$rhostsaid .= ' '.$el;
					}
				}
			}
		}

		return q() unless $rhostsaid;

		$rhostsaid =~ y{ }{}s;
		$rhostsaid =~ s{\A }{};
		$rhostsaid =~ s{ \z}{};

		$rcptintxt ||= Kanadzuchi::Address->canonify($rhostsaid);
		return q() unless $rcptintxt;

		foreach my $r ( keys %$RxError )
		{
			if( grep { $rhostsaid =~ $_ } @{ $RxError->{ $r } } )
			{
				if( $rhostsaid =~ m{[(]in reply to .*([A-Z]{4}).*command[)]} )
				{
					# postfix/src/smtp/smtp_proto.c: "host %s said: %s (in reply to %s)",
					$xsmtp = $1;
					$xsmtp = 'MAIL' if( $xsmtp eq 'HELO' || $xsmtp eq 'EHLO' );
					$causa = 'onhold';
				}
				elsif( $rhostsaid =~ m{[>]{3} *([A-Z]{4})} )
				{
					# Each of the following recipients was rejected by a remote
					# mail server.
					#
					#    Recipient: <******@ezweb.ne.jp>
					#    >>> RCPT TO:<******@ezweb.ne.jp>
					#    <<< 550 <******@ezweb.ne.jp>: User unknown
					$xsmtp = $1;
					$xsmtp = 'MAIL' if( $xsmtp eq 'HELO' || $xsmtp eq 'EHLO' );
					$causa = 'onhold';
					$rhostsaid =~ s/\A.+[<]{3} //;
				}
				elsif( $rhostsaid =~ m{user unknown}i )
				{
					$xsmtp = 'DATA';
					$causa = 'userunknown';
				}
				else
				{
					$causa = $r;
				}

				$statintxt = $1 if( $rhostsaid =~ m{\b[#]?([45][.]\d[.]\d+)\b} );
				last();
			}
		}

		if( Kanadzuchi::RFC2822->is_emailaddress($rcptintxt) )
		{
			$phead .= q(Final-Recipient: RFC822; ).$rcptintxt.qq(\n);
		}

		$pstat  = $statintxt || Kanadzuchi::RFC3463->status( $causa, $typemap->{ $causa }, 'i' );
		$phead .= __PACKAGE__->xsmtpstatus($pstat);
		$phead .= __PACKAGE__->xsmtpdiagnosis($rhostsaid);
		$phead .= __PACKAGE__->xsmtpagent();
		$phead .= __PACKAGE__->xsmtpcommand($xsmtp);

		return $phead;
	}
	else
	{
		# Bounced from auone-net.jp(DION)
		#                                                _                   _       
		#   __ _ _   _  ___  _ __   ___       _ __   ___| |_   _ __   ___   (_)_ __  
		#  / _` | | | |/ _ \| '_ \ / _ \_____| '_ \ / _ \ __| | '_ \ / _ \  | | '_ \ 
		# | (_| | |_| | (_) | | | |  __/_____| | | |  __/ |_ _| | | |  __/_ | | |_) |
		#  \__,_|\__,_|\___/|_| |_|\___|     |_| |_|\___|\__(_)_| |_|\___(_)/ | .__/ 
		#                                                                 |__/|_|    
		my $RxauOne = {
			'begin' => [
				qr{\AYour mail sent on:? [A-Z][a-z]{2}[,]},
				qr{\AYour mail attempted to be delivered on:? [A-Z][a-z]{2}[,]},
			],
			'endof' => qr{\AContent-Type: message/rfc822\z},
			'error'  => qr{Could not be delivered to:? },
		};

		my $RxError = {
			'mailboxfull' => qr{As their mailbox is full},
			'relaydenied' => qr{Due to the following SMTP relay error},
			'nohostexist' => qr{As the remote domain doesnt exist},
		};

		EACH_LINE: foreach my $el ( split( qq{\n}, $$mbody ) )
		{
			if( (grep { $el =~ $_ } @{ $RxauOne->{'begin'} }) .. ($el =~ $RxauOne->{'endof'}) )
			{
				$endof = 1 if( $endof == 0 && $el =~ $RxauOne->{'endof'} );
				next() if( $endof || $el =~ m{\A--} || $el =~ m{\A\z} );
				$rhostsaid .= $el;
			}
		}

		return q() unless $rhostsaid;
		$rhostsaid =~ y{ }{}s;
		$rhostsaid =~ s/\A.+($RxauOne->{'error'}.+)\z/$1/;

		if( $rhostsaid =~ $RxError->{'mailboxfull'} )
		{
			# Your mail sent on: Thu, 29 Apr 2010 11:04:47 +0900 
			#     Could not be delivered to: <******@**.***.**>
			#     As their mailbox is full.
			$pstat  = Kanadzuchi::RFC3463->status('mailboxfull','t','i');
		}
		elsif( $rhostsaid =~ $RxError->{'relaydenied'} )
		{
			# Your mail sent on Thu, 29 Apr 2010 11:15:36 +0900 
			#     Could not be delivered to <*****@***.****.***> 
			#     Due to the following SMTP relay error 
			$pstat  = Kanadzuchi::RFC3463->status('systemerror','p','i');
		}
		elsif( $rhostsaid =~ $RxError->{'nohostexist'} )
		{
			# Your mail attempted to be delivered on Thu, 29 Apr 2010 12:08:36 +0900 
			#     Could not be delivered to <*****@***.**.***> 
			#     As the remote domain doesnt exist.
			$pstat  = Kanadzuchi::RFC3463->status('hostunknown','p','i');
			last();
		}

		if( $pstat )
		{
			$phead .= __PACKAGE__->xsmtpstatus($pstat);
			$phead .= __PACKAGE__->xsmtpdiagnosis($rhostsaid);
			$phead .= __PACKAGE__->xsmtpagent();
			$phead .= __PACKAGE__->xsmtpcommand($xsmtp);
		}

		return $phead;
	}

}

1;
__END__
