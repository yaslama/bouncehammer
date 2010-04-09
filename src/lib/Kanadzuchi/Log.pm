# $Id: Log.pm,v 1.15 2010/04/09 03:52:58 ak Exp $
# -Id: Log.pm,v 1.2 2009/10/06 06:21:47 ak Exp -
# -Id: Log.pm,v 1.11 2009/07/16 09:05:33 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                      
 ##                   
 ##     ####   #####  
 ##    ##  ## ##  ##  
 ##    ##  ## ##  ##  
 ##    ##  ##  #####  
 ###### ####      ##  
              #####   
package Kanadzuchi::Log;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Kanadzuchi::Metadata;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'directory',	# (Path::Class::Dir) log directory
	'logfile',	# (Path::Class::File::Lockable) log file.
	'entities',	# (Ref->Array) K::M::* object
	'files',	# (Path::CLass::File) Temporary log files
	'count',	# (Integer) the number of bounced messages
	'format',	# (String) Log format
	'header',	# (Integer) 1 = Output the header part
	'footer',	# (Integer) 1 = Output the footer part
	'comment',	# (String) Additional description in the header
	'device',	# (String) Log device, file handle, screeen, ...
);

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param
	# @Return	Kanadzuchi::Log Object
	my $class = shift();
	my $argvs = { @_ };

	DEFAULT_VALUES: {
		$argvs->{'format'} = q(yaml) unless( $argvs->{'format'} );
		$argvs->{'comment'} = q() unless( $argvs->{'comment'} );
	}
	return( $class->SUPER::new( $argvs ) );
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub logger
{
	# +-+-+-+-+-+-+
	# |l|o|g|g|e|r|
	# +-+-+-+-+-+-+
	#
	# @Description	Log to the file(JSON::Syck::Dump)
	# @Param
	# @Return	0 = device not found or no record to log
	#		n = the number of logged records
	# @See		dumper()
	my $self = shift(); $self->{'format'} = q(yaml);
	my $reqv = defined(wantarray()) ? 1 : 0;
	my $data = undef();

	if( $reqv == 1 )
	{
		$data = $self->dumper();
		return($data);
	}
	else
	{
		return( $self->dumper() );
	}
}

sub dumper
{
	# +-+-+-+-+-+-+
	# |d|u|m|p|e|r|
	# +-+-+-+-+-+-+
	#
	# @Description	Dump to the file or screen with format
	# @Param	<None>
	# @Return	0 = No record to dump 
	#		1 = Successfully dumped
	my $self = shift();
	my $atab = undef();
	my $data = undef();
	my $reqv = defined(wantarray()) ? 1 : 0;
	my $time = localtime();
	my $head = q();
	my $foot = q();

	my $outputformat = { 'yaml' => q(), 'json' => q() };
	my $recdelimiter = { 'yaml' => q(), 'json' => q(,) };

	$outputformat->{'json'} .= qq|{ "bounced": %d, "addresser": "%s", "recipient": "%s", |;
	$outputformat->{'json'} .= qq|"senderdomain": "%s", "destination": "%s", "reason": "%s", |;
	$outputformat->{'json'} .= qq|"hostgroup": "%s", "provider": "%s", "frequency": %d, |;
	$outputformat->{'json'} .= qq|"description": %s, "token": "%s" }|;
	$outputformat->{'yaml'} .= qq|- |.$outputformat->{'json'};

	my $outputheader = {
		'yaml'		=> q|# Generated: |.$time->ymd('/').q| |.$time->hms(':').qq| \n|,
		'json'		=> q|# Generated: |.$time->ymd('/').q| |.$time->hms(':').qq| \n|,
	};

	return(0) if( $self->{'count'} == 0 );

	# Decide header and footer
	if( $self->{'header'} )
	{
		$head .= $outputheader->{ $self->{'format'} };
		$head .= q|# |.qq|$self->{'comment'}\n| if( length($self->{'comment'}) );
	}

	if( $self->{'footer'} )
	{
		$foot .= q|# |.qq|$self->{'comment'}\n| if( length($self->{'comment'}) );
	}

	# Print header
	if( $self->{'format'} eq q(asciitable) )
	{
		require Text::ASCIITable;
		$atab->{'tab'} = new Text::ASCIITable( { 'headingText' => 'Bounce Messages' } );
		$atab->{'tab'}->setOptions( 'outputWidth', 80 );
		$atab->{'tab'}->setCols( '#', 'Date', 'Addresser', 'Recipient', 'Stat', 'Reason' );
		$atab->{'num'} = 0;
	}
	else
	{
		$data .= $head;
	}

	# Print left square bracket character for the format JSON
	$data .= '[ ' if( $self->{'format'} eq q(json) );

	PREPARE_LOG: foreach my $_e ( @{$self->{'entities'}} )
	{
		my $_h = {
			'Ltoken' => $_e->token(),
			'Lreason' => $_e->reason(),
			'Lbounced' => $_e->bounced->epoch(),
			'Lprovider' => $_e->provider(),
			'Lhostgroup' => $_e->hostgroup(),
			'Lfrequency' => $_e->frequency(),
			'Laddresser' => $_e->addresser->address(),
			'Lrecipient' => $_e->recipient->address(),
			'Ldatestring' => $_e->bounced->ymd('/').q{ }.$_e->bounced->hms(':'),
			'Ldescription' => ${ Kanadzuchi::Metadata->to_string($_e->description()) },
			'Ldestination' => $_e->destination(),
			'Lsenderdomain' => $_e->senderdomain(),
			'Ldeliverystatus' => $_e->deliverystatus(),
		};

		if( defined($atab) )
		{
			$atab->{'num'}++;
			$atab->{'tab'}->addRow( $atab->{'num'}, $_h->{'Ldatestring'}, $_h->{'Laddresser'},
				$_h->{'Lrecipient'}, $_h->{'Ldeliverystatus'}, $_h->{'Lreason'} );
		}
		else
		{
			$data .= sprintf( $outputformat->{$self->{'format'}},
					$_h->{'Lbounced'}, $_h->{'Laddresser'}, $_h->{'Lrecipient'},
					$_h->{'Lsenderdomain'}, $_h->{'Ldestination'},
					$_h->{'Lreason'}, $_h->{'Lhostgroup'}, $_h->{'Lprovider'}, 
					$_h->{'Lfrequency'}, $_h->{'Ldescription'}, $_h->{'Ltoken'} );
			$data .= $recdelimiter->{ $self->{'format'} }.qq(\n);
		}
	} # End of foreach() PREPARE_LOG:

	# Replace the ',' at the end of data with right square bracket for the format JSON
	$data =~ s{,\n\z}{ ]\n} if( $self->{'format'} eq 'json' );

	if( defined($atab) && $atab->{'num'} > 0 )
	{
		$atab->{'tab'}->addRowLine();
		$atab->{'tab'}->addRow( q{}, q{}, q{}, q{Total}, $self->{'count'} );
		$data = $atab->{'tab'}->draw();
	}
	else
	{
		$data .= $foot if( length($foot) );
	}

	if( $reqv == 1 )
	{
		# Return as a scalar(dumped data)
		return($data);
	}
	else
	{
		# Dumped data are not required, return true;
		if( ref($self->{'device'}) eq q|IO::File| )
		{
			print( {$self->{'device'}} $data );
		}
		else
		{
			print( STDOUT $data );
		}
		return(1);
	}
}

1;
__END__
