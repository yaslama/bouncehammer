# $Id: Log.pm,v 1.18 2010/06/21 05:01:40 ak Exp $
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
my $OutputFormat = { 'yaml' => q(), 'json' => q(), 'csv' => q() };
my $OutputHeader = { 'yaml' => q(), 'json' => q(), 'csv' => q() };
my $RecDelimiter = { 'yaml' => q(), 'json' => ',', 'csv' => q() };

# Dump with YAML/JSON format
$OutputFormat->{'json'} .= qq|{ "bounced": %d, "addresser": "%s", "recipient": "%s", |;
$OutputFormat->{'json'} .= qq|"senderdomain": "%s", "destination": "%s", "reason": "%s", |;
$OutputFormat->{'json'} .= qq|"hostgroup": "%s", "provider": "%s", "frequency": %d, |;
$OutputFormat->{'json'} .= qq|"description": %s, "token": "%s" }|;
$OutputFormat->{'yaml'} .= qq|- |.$OutputFormat->{'json'};

# Dump with CSV format
$OutputFormat->{'csv'} .= qq|%d,%s,%s,%s,%s,%s,%s,%s,%d,%d,%s,%s,%s|;
$OutputHeader->{'csv'} .= q|bounced,addresser,recipient,senderdomain,destination,reason,|;
$OutputHeader->{'csv'} .= q|hostgroup,provider,frequency,deliverystatus,timezoneoffset,|;
$OutputHeader->{'csv'} .= q|diagnosticcode,token|.qq|\n|;

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
	# @Param	<None>
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
	my $damn = {};
	my $head = q();
	my $foot = q();

	return(0) if( $self->{'count'} == 0 );

	# Output header
	if( $self->{'format'} eq 'csv' )
	{
		$self->{'header'} = 1;
	}
	else
	{
		my $_t = localtime();
		$OutputHeader->{ $self->{'format'} } = '# Generated: '.$_t->ymd('/').' '.$_t->hms(':').qq| \n|,
	}


	# Decide header and footer
	if( $self->{'header'} )
	{
		$head .= $OutputHeader->{ $self->{'format'} };
		$head .= q|# |.qq|$self->{'comment'}\n| if( length($self->{'comment'}) );
	}

	if( $self->{'footer'} )
	{
		$foot .= q|# |.qq|$self->{'comment'}\n| if( length($self->{'comment'}) );
	}

	# Print header
	if( $self->{'format'} eq 'asciitable' )
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
		$damn = $_e->damn();

		if( defined($atab) )
		{
			$atab->{'num'}++;
			$damn->{'datestring'} = $_e->bounced->ymd('/').' '.$_e->bounced->hms(':');
			$atab->{'tab'}->addRow( $atab->{'num'}, $damn->{'datestring'}, $damn->{'addresser'},
				$damn->{'recipient'}, $damn->{'deliverystatus'}, $damn->{'reason'} );
		}
		else
		{
			if( $self->{'format'} eq 'csv' )
			{
				$damn->{'diagnosticcode'} =~ y{,}{ };
				$data .= sprintf( $OutputFormat->{ $self->{'format'} },
						$damn->{'bounced'}, $damn->{'addresser'}, $damn->{'recipient'},
						$damn->{'senderdomain'}, $damn->{'destination'}, $damn->{'reason'}, 
						$damn->{'hostgroup'}, $damn->{'provider'}, $damn->{'frequency'}, 
						$damn->{'deliverystatus'}, $damn->{'timezoneoffset'},
						$damn->{'diagnosticcode'}, $damn->{'token'} );

			}
			else
			{
				$data .= sprintf( $OutputFormat->{ $self->{'format'} },
						$damn->{'bounced'}, $damn->{'addresser'}, $damn->{'recipient'},
						$damn->{'senderdomain'}, $damn->{'destination'},
						$damn->{'reason'}, $damn->{'hostgroup'}, $damn->{'provider'}, 
						$damn->{'frequency'}, $damn->{'description'}, $damn->{'token'} );
			}
			$data .= $RecDelimiter->{ $self->{'format'} }.qq(\n);
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
