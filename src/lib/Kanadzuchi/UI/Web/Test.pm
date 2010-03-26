# $Id: Test.pm,v 1.15 2010/03/26 07:20:08 ak Exp $
# -Id: Test.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Test.pm,v 1.10 2009/08/17 12:39:31 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                               
 ######                  ##    
   ##     ####   ##### ######  
   ##    ##  ## ##       ##    
   ##    ######  ####    ##    
   ##    ##         ##   ##    
   ##     ####  #####     ###  
package Kanadzuchi::UI::Web::Test;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::Metadata;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub test_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|e|s|t|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Draw test(parse) form in HTML
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = q(test.).$self->{'language'}.q(.html);
	$self->tt_params( 'maxsize' => $self->{'webconfig'}->{'upload'}->{'maxsize'} );
	$self->tt_process($file);
}

sub parse_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |p|a|r|s|e|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Execute test parse on the web.
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = q(iframe-parseddata.).$self->{'language'}.q(.html);
	my $cgiq = $self->query();
	my $aref = [];

	if( defined($cgiq->param('emailfile')) ||
		( defined($cgiq->param('emailtext')) && length($cgiq->param('emailtext'))) ){

		require Path::Class;
		require File::Spec;

		# Mailbox parser executable and config file
		my $configfile = $self->param('cf');
		my $mboxparser = $self->param('px') || q(mailboxparser);
		my $databasectl = $self->param('cx') || q(databasectl);

		# Temporary mail box file in '/tmp'
		my $temporaryd = ( -w q{/tmp} ? q{/tmp} : File::Spec->tmpdir() );
		my $temporaryf = q();
		my $tmpmailbox = undef();

		$temporaryf .= $self->{'sysconfig'}->{'file'}->{'templog'}->{'prefix'}.q(-draw.);
		$temporaryf .= time().q(.).$ENV{'REMOTE_ADDR'}.q(.).sprintf("%4x",$ENV{'REMOTE_PORT'}).$$.q(.);
		$temporaryf .= (rand(8) * 1000).q(.).$self->{'sysconfig'}->{'file'}->{'templog'}->{'suffix'};
		$tmpmailbox = new Path::Class::File( qq{$temporaryd/$temporaryf} );

		my $givenemail = q();	# Email file name
		my $pastedmail = q();	# Pasted email text
		my $datasource = q();	# Filename or string as data source
		my $fileformat = $cgiq->param('format') || q(html);
		my $pnmessages = $cgiq->param('parsenmessages') || 5;
		my $registerit = ( defined($cgiq->param('register')) && $cgiq->param('register') eq 'on' ? 1 : 0 );
		my $parseddata = q();	# String, contents of given file
		my $parsedline = q();	# String, for calculate data size
		my $parseerror = q();	# Error string
		my $pseudofrom = q();	# Pseudo 'From' Line
		my $serialized = undef();
		my $dctlreturn = q();	# The result of 'databasectl' if it is executed
		my $dcresulthr = {};	# Serialized 'dctlreturn'

		PARSE: while( 1 )
		{
			$tmpmailbox->touch();
			last(PARSE) unless( -w $tmpmailbox->stringify() );	# Should be writable
			last(PARSE) unless( -T $tmpmailbox->stringify() );	# Should be text file
			
			# Write temporary mailbox.
			my $_tmpmf = $tmpmailbox->openw();
			my $_maxfs = $self->{'webconfig'}->{'upload'}->{'maxsize'};
			my $_ctype = q();

			if( defined($cgiq->param('emailfile')) && length($cgiq->param('emailfile')) )
			{
				$givenemail = $cgiq->param('emailfile');
				$datasource = sprintf("%s",$givenemail);
				$_ctype = lc($cgiq->uploadInfo($givenemail)->{'Content-Type'}) || q{text/plain};

				if( $_ctype =~ m{\A(audio|application|image|video)/}m )
				{
					$parseerror = q(nottext);
				} 
				else
				{
					WRITE: while( <$givenemail> )
					{ 
						( my $_thisline = $_ ) =~ s{(\x0d\x0a|\x0d|\x0a)}{\n}gm;	# CRLF, CR -> LF
						$parsedline .= $_thisline;

						if( $_maxfs != 0 && length($parsedline) > $_maxfs )
						{
							$parseerror = q(toobig);
							last(PARSE);
						}

						# Skip if it is Base64 encoded text
						next(WRITE) if( $_thisline =~ m{\A[a-zA-Z0-9+/=]+\z}gm );
						printf( $_tmpmf "%s", $_thisline );

					} # End of while(), Write temporary mbox
				}
				$datasource .= q|(|.length($parsedline).q| Bytes)|;
			}

			# Append e-Mail text(textarea) to the temporary mailbox file
			if( defined($cgiq->param('emailtext')) && length($cgiq->param('emailtext')) )
			{
				if( length($datasource) )
				{
					# Content of e-mail file that is already loaded
					$datasource .= q{, };
					$parsedline .= qq{\n\n};
				}

				$pseudofrom = q();
				$pastedmail = $cgiq->param('emailtext');
				$pastedmail =~ s{(\x0d\x0a|\x0d|\x0a)}{\n}gm;	# CRLF, CR -> LF
				
				# Add Pseudo 'From' line
				if( $pastedmail =~ m{\AFrom: .+ [@]ezweb[.]ne[.]jp[>]?\z}m )
				{
					# For mailboxparser command
					$pseudofrom = q(From Postmaster@ezweb.ne.jp Sun Dec 31 23:59:59 2000).qq(\n);
				}
				else
				{
					$pseudofrom = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000).qq(\n);
				}

				$pastedmail = $pseudofrom.$pastedmail;
				$parsedline .= $pastedmail;

				if( length($parsedline) > $_maxfs )
				{
					$parseerror = q(toobig);
					last(PARSE);
				}


				printf( $_tmpmf "%s", $pastedmail );
				$datasource .= q|Pasted text(|.length($pastedmail).q| Bytes)|;
			}

			# Parse mailbox
			my $_outputformat = ( $fileformat eq 'html' ? q{y} : substr($fileformat,0,1) );
			my $_pcommandline = qq{$mboxparser -g $tmpmailbox --conf $configfile -F$_outputformat --remove};
			my $_nparsedmesgs = 0;

			$parseddata = qx{$_pcommandline};
			last() unless($parseddata);

			if( $registerit )
			{
				# Online registration
				my $_temporaryy = $temporaryf.q(.rr.yaml);
				my $_tempbyyaml = new Path::Class::File( qq{$temporaryd/$_temporaryy} );
				my $_tempresult = $_tempbyyaml->openw();
				my $_dbccommand = qq{$databasectl -UB --conf $configfile }.$_tempbyyaml->stringify();

				# Write the result into the temprary YAML|JSON file
				printf( $_tempresult "%s", $parseddata );

				# Insert the results by databasectl command
				$dctlreturn = qx{$_dbccommand};
				$_tempbyyaml->remove();
			}

			$serialized = Kanadzuchi::Metadata->to_object( \$parseddata );
			$dcresulthr = shift @{ Kanadzuchi::Metadata->to_object( \$dctlreturn ) };

			# last() if the format is 'asciitable'
			last() if( ref($serialized) ne q|ARRAY| );
			last() if( $registerit && ref($dcresulthr) ne q|HASH| );

			foreach my $__y ( @$serialized )
			{
				(my $__s = $__y->{'addresser'}) =~ s{\A.+[@]}{}gm;
				(my $__d = $__y->{'recipient'}) =~ s{\A.+[@]}{}gm;

				my $__dateobject = {
					'b' => bless( localtime($__y->{'bounced'}), 'Time::Piece' ),
					'u' => bless( localtime(), 'Time::Piece' ), };
				my $__datestring = {
					'b' => $__dateobject->{'b'}->ymd('/')
						.q|(|.$__dateobject->{'b'}->wdayname().q|) |.$__dateobject->{'b'}->hms(':'),
					'u' => $__dateobject->{'u'}->ymd('/')
						.q|(|.$__dateobject->{'u'}->wdayname().q|) |.$__dateobject->{'u'}->hms(':'), };

				push( @$aref,
					{
						'id' => sprintf("TEMP-%03d",++$_nparsedmesgs),
						'token' => $__y->{'token'},
						'reason' => $__y->{'reason'},
						'bounced' => $__datestring->{'b'},
						'updated' => $__datestring->{'u'},
						'addresser' => $__y->{'addresser'},
						'recipient' => $__y->{'recipient'},
						'frequency' => 1,
						'destination' => $__d,
						'description' => $__y->{'description'},
						'senderdomain' => $__s,
						'hostgroup' => $__y->{'hostgroup'},
						'deliverystatus' => $__y->{'status'},
						'timezoneoffset' => $__y->{'description'}->{'timezoneoffset'},
						'diagnosticcode' => $__y->{'description'}->{'diagnosticcode'},
					}
				);

				last() if( $_nparsedmesgs >= $pnmessages );

			} # End of foreach(), read serialized string

			eval{ $tmpmailbox->remove(); };
			last();
		} # End of while(1)
		
		$self->tt_params( 
			'bouncemessages' => $aref,
			'parseddatatext' => $parseddata,
			'parsedfilename' => $datasource,
			'parsedfilesize' => length($parsedline),
			'parsedmessages' => ( $fileformat eq q{asciitable} ? 1 : scalar(@$aref) ),
			'outputformat' => $fileformat,
			'onlineparse' => 1,
			'onlineupdate' => $registerit,
			'updateresult' => $dcresulthr,
			'parseerror' => $parseerror, );
	}

	$self->tt_process($file);
}

1;
__END__
