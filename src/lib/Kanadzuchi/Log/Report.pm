# $Id: Report.pm,v 1.7 2010/02/21 20:25:04 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Log::
                                           
 #####                               ##    
 ##  ##  ####  #####   ####  ##### ######  
 ##  ## ##  ## ##  ## ##  ## ##  ##  ##    
 #####  ###### ##  ## ##  ## ##      ##    
 ## ##  ##     #####  ##  ## ##      ##    
 ##  ##  ####  ##      ####  ##       ###  
               ##                          
package Kanadzuchi::Log::Report;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Log';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'layout',	# (String) Output format of summary
	'screen',	# (String) Outout device of summary
	'totalsby',	# (String) Totals by date, hour,...
	'stats',	# (Integer) Print statistics
);
#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
# LaTeX macros
my $TeX = { 
	'textbf'	=> '\textbf',
	'hline'		=> '\hline',
	'newline'	=> '\\\\',
};

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub addupbyhost
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |a|d|d|u|p|b|y|h|o|s|t|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Add up by host group
	# @Param	<None>
	# @Return	(Ref->Hash) Summary structure
	#     _    ____  ____        _   _ ____    ______   __  _   _  ___  ____ _____ 
	#    / \  |  _ \|  _ \      | | | |  _ \  | __ ) \ / / | | | |/ _ \/ ___|_   _|
	#   / _ \ | | | | | | |_____| | | | |_) | |  _ \\ V /  | |_| | | | \___ \ | |  
	#  / ___ \| |_| | |_| |_____| |_| |  __/  | |_) || |   |  _  | |_| |___) || |  
	# /_/   \_\____/|____/       \___/|_|     |____/ |_|   |_| |_|\___/|____/ |_|  
	#                                                                              
	my $self = shift();
	my $data = {
		'userunknown'	=> { 'total' => 0, 'name' => 'Unknown', },
		'filtered'	=> { 'total' => 0, 'name' => 'Filtered', },
		'mailboxfull'	=> { 'total' => 0, 'name' => 'MboxFull', },
		'other'		=> { 'total' => 0, 'name' => 'Others', },
	};

	my $mobile = {
		'group' => 'All Mobile devices',
		'total' => 0,
		'host' => {
			'cellphone'	=> { 'total' => 0, 'data' => {}, 'name' => 'Cellularphone', },
			'smartphone'	=> { 'total' => 0, 'data' => {}, 'name' => 'Smartphone', },
		},
		'error' => {},
	};

	my $computer = {
		'group' => 'Not Mobile devices',
		'total' => 0,
		'host' => {
			'pc'		=> { 'total' => 0, 'data' => {}, 'name' => 'PC', },
			'webmail'	=> { 'total' => 0, 'data' => {}, 'name' => 'WebMail', },
		},
		'error' => {},
	};

	my $summary = { 
		'summarytitle'	=> 'Summary by host/Observed value of the error',
		'totalmessage'	=> { 'name' => 'All The Error Mails', 'total' => 0, },
		'unknownhost'	=> { 'name' => 'Unknown Hosts', 'total' => 0, },
		'errorgroup'	=> $data,
		'hostgroup'	=> { 'mobile' => $mobile, 'computer' => $computer, },
	};

	INITIALIZE_DATA_STRUCTURE: {
		# Initialize each counter

		INIT_JPMOBILE: foreach my $_r ( keys(%{$data}) )
		{
			$mobile->{'error'}->{$_r}->{'total'} = 0;
			foreach my $_h ( keys(%{$mobile->{'host'}}) )
			{
				$mobile->{'host'}->{$_h}->{'data'}->{$_r} = 0;
			}
		}

		INIT_COMPUTER: foreach my $_r ( keys(%{$data}) )
		{
			$computer->{'error'}->{$_r}->{'total'} = 0;
			foreach my $_h ( keys(%{$computer->{'host'}}) )
			{
				$computer->{'host'}->{$_h}->{'data'}->{$_r} = 0;
			}
		}
	}

	ADDUP_BY_HOST: foreach my $it ( @{$self->{'entities'}} )
	{
		#   ____ ___  _   _ _   _ _____ 
		#  / ___/ _ \| | | | \ | |_   _|
		# | |  | | | | | | |  \| | | |  
		# | |__| |_| | |_| | |\  | | |  
		#  \____\___/ \___/|_| \_| |_|  
		#                               
		my $_thereason = q();
		my $_hostgroup = q();
		my $_hostpoint = q();

		if( $it->reason eq 'hostunknown' )
		{
			$summary->{'unknownhost'}->{'total'}++;
			next();
		}

		if( $it->reason eq 'userunknown' || $it->reason eq 'filtered' || $it->reason eq 'mailboxfull' )
		{
			$_thereason = $it->reason;
		}
		else
		{
			$_thereason = 'other';
		}

		if( $it->hostgroup eq 'cellphone' || $it->hostgroup eq 'smartphone' )
		{
			$_hostpoint = $it->hostgroup();
			$_hostgroup = 'mobile';
		}
		else
		{
			# Webmail, PC
			$_hostpoint = $it->hostgroup();
			$_hostgroup = 'computer';
		}

		$summary->{'hostgroup'}->{$_hostgroup}->{'host'}->{$_hostpoint}->{'data'}->{$_thereason}++;
		$summary->{'hostgroup'}->{$_hostgroup}->{'host'}->{$_hostpoint}->{'total'}++;
		$summary->{'hostgroup'}->{$_hostgroup}->{'total'}++;
		$summary->{'hostgroup'}->{$_hostgroup}->{'error'}->{$_thereason}->{'total'}++;
		$summary->{'errorgroup'}->{$_thereason}->{'total'}++;
		$summary->{'totalmessage'}->{'total'}++;
	}

	return($summary);
}

sub addupbycalendar
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |a|d|d|u|p|b|y|c|a|l|e|n|d|a|r|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Add up by Calendar
	# @Param	<None>
	# @Return	(Ref->Hash) Summary structure
	#     _    ____  ____        _   _ ____    ______   __
	#    / \  |  _ \|  _ \      | | | |  _ \  | __ ) \ / /
	#   / _ \ | | | | | | |_____| | | | |_) | |  _ \\ V / 
	#  / ___ \| |_| | |_| |_____| |_| |  __/  | |_) || |  
	# /_/   \_\____/|____/       \___/|_|     |____/ |_|  
	#   ____    _    _     _____ _   _ ____    _    ____  
	#  / ___|  / \  | |   | ____| \ | |  _ \  / \  |  _ \ 
	# | |     / _ \ | |   |  _| |  \| | | | |/ _ \ | |_) |
	# | |___ / ___ \| |___| |___| |\  | |_| / ___ \|  _ < 
	#  \____/_/   \_\_____|_____|_| \_|____/_/   \_\_| \_\
	#                                                     
	my $self = shift();
	my $data = {};

	my $calendar = [];	# Calendar Array
	my $tpmethod = undef();	# Time::Piece Method
	my $datetime = lc($self->{'totalsby'}) || 'date';

	if( $datetime eq 'hour' )
	{
		$calendar = [ 0..23 ];
		$tpmethod = 'hour';
	}
	elsif( $datetime eq 'month' )
	{
		$calendar = [ 1..12 ];
		$tpmethod = 'mon';
	}
	elsif( $datetime eq 'year' )
	{
		$calendar = [];
		$tpmethod = 'year';
	}
	elsif( $datetime eq 'dow' || $datetime eq 'wday' || $datetime eq 'dayofweek' )
	{
		$calendar = [ 1..7 ];
		$tpmethod = 'wday';
	}
	else
	{
		# Initialize in the loop
		$datetime = 'date';
		$calendar = [];
		$tpmethod = 'ymd';
	}

	INITIALIZE_CL: foreach my $clkey ( @$calendar )
	{
		$data->{sprintf( "%02d", $clkey)} = {
				'mobile' => 0,
				'computer' => 0,
				'unknownhost' => 0,
				'subtotal' => 0, };
	}

	ADDUP_BY_CL: foreach my $it ( @{$self->{'entities'}} )
	{
		#   ____ ___  _   _ _   _ _____ 
		#  / ___/ _ \| | | | \ | |_   _|
		# | |  | | | | | | |  \| | | |  
		# | |__| |_| | |_| | |\  | | |  
		#  \____\___/ \___/|_| \_| |_|  
		#                               
		my $_clkey = sprintf( ($datetime eq 'date' ? "%s" : "%02d"), $it->bounced->$tpmethod );

		INIT_INSIDE_LOOP:
		{
			last(INIT_INSIDE_LOOP) if( exists($data->{$_clkey}) );

			if( ( $datetime eq 'date' || $datetime eq 'year' ) )
			{
				$data->{$_clkey} = {
						'mobile' => 0,
						'computer' => 0,
						'unknownhost' => 0,
						'subtotal' => 0, };
			}
		}

		if( $it->reason eq 'hostunknown' )
		{
			$data->{$_clkey}->{'unknownhost'}++;
			$data->{$_clkey}->{'subtotal'}++;
			next();
		}

		if( $it->hostgroup eq 'cellphone' )
		{
			# Cellularphone
			$data->{$_clkey}->{'mobile'}++;
			$data->{$_clkey}->{'subtotal'}++;
		}
		else
		{
			# PC, Smartphone
			$data->{$_clkey}->{'computer'}++;
			$data->{$_clkey}->{'subtotal'}++;
		}
	}

	return($data);
}

sub summary
{
	# +-+-+-+-+-+-+-+
	# |s|u|m|m|a|r|y|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Count records and print summary
	# @Param	<None>
	# @Return	0 = no record to print 
	#		n = the number of ptinted records
	my $self = shift();
	my $data = q();	# Summary data
	my $reqv = defined(wantarray()) ? 1 : 0;

	return(0) unless( defined($self->{'count'}) );
	return(0) unless( $self->{'count'} );
	return(0) unless( @{$self->{'entities'}} );

	my $S = $self->addupbyhost();
	my $_jpm = $S->{'hostgroup'}->{'mobile'};
	my $_com = $S->{'hostgroup'}->{'computer'};

	if( lc($self->{'layout'}) eq 'asciitable' )
	{
		#     _    ____   ____ ___ ___   _____  _    ____  _     _____ 
		#    / \  / ___| / ___|_ _|_ _| |_   _|/ \  | __ )| |   | ____|
		#   / _ \ \___ \| |    | | | |    | | / _ \ |  _ \| |   |  _|  
		#  / ___ \ ___) | |___ | | | |    | |/ ___ \| |_) | |___| |___ 
		# /_/   \_\____/ \____|___|___|   |_/_/   \_\____/|_____|_____|
		#                                                              
		require Text::ASCIITable;
		my $_atab = undef();	# ASCII Table object

		$_atab = new Text::ASCIITable( {
				'headingText' => $S->{'summarytitle'} });
		$_atab->setOptions( 'outputWidth', 80 );
		$_atab->setCols( 'Host Group', 
				$S->{'errorgroup'}->{'userunknown'}->{'name'},
				$S->{'errorgroup'}->{'filtered'}->{'name'},
				$S->{'errorgroup'}->{'mailboxfull'}->{'name'},
				$S->{'errorgroup'}->{'other'}->{'name'}, q(Total) );

		# Cellular phones
		foreach my $_k ( keys(%{$_jpm->{'host'}}) )
		{
			my $it = $_jpm->{'host'};
			next() unless( $it->{$_k}->{'name'} );
			$_atab->addRow( q( - ).$it->{$_k}->{'name'},
					$it->{$_k}->{'data'}->{'userunknown'},
					$it->{$_k}->{'data'}->{'filtered'},
					$it->{$_k}->{'data'}->{'mailboxfull'},
					$it->{$_k}->{'data'}->{'other'},
					$it->{$_k}->{'total'} );
		}
		$_atab->addRowLine();
		$_atab->addRow( $_jpm->{'group'},
				$_jpm->{'error'}->{'userunknown'}->{'total'},
				$_jpm->{'error'}->{'filtered'}->{'total'},
				$_jpm->{'error'}->{'mailboxfull'}->{'total'},
				$_jpm->{'error'}->{'other'}->{'total'},
				$_jpm->{'total'} );
		$_atab->addRowLine();

		# PCs
		foreach my $_k ( keys(%{$_com->{'host'}}) )
		{
			my $it = $_com->{'host'};
			next() unless( $it->{$_k}->{'name'} );
			$_atab->addRow( q( - ).$it->{$_k}->{'name'},
					$it->{$_k}->{'data'}->{'userunknown'},
					$it->{$_k}->{'data'}->{'filtered'},
					$it->{$_k}->{'data'}->{'mailboxfull'},
					$it->{$_k}->{'data'}->{'other'},
					$it->{$_k}->{'total'} );
		}
		$_atab->addRowLine();
		$_atab->addRow( $_com->{'group'},
				$_com->{'error'}->{'userunknown'}->{'total'},
				$_com->{'error'}->{'filtered'}->{'total'},
				$_com->{'error'}->{'mailboxfull'}->{'total'},
				$_com->{'error'}->{'other'}->{'total'},
				$_com->{'total'} );
		$_atab->addRowLine();

		# Unknown hosts
		$_atab->addRow( $S->{'unknownhost'}->{'name'}, q(), q(), q(), q(),
				$S->{'unknownhost'}->{'total'}, );
		$_atab->addRowLine();
		
		# ALL THE ERROR MAILS
		$_atab->addRow( $S->{'totalmessage'}->{'name'},
				$S->{'errorgroup'}->{'userunknown'}->{'total'},
				$S->{'errorgroup'}->{'filtered'}->{'total'},
				$S->{'errorgroup'}->{'mailboxfull'}->{'total'},
				$S->{'errorgroup'}->{'other'}->{'total'},
				( $S->{'totalmessage'}->{'total'} + $S->{'unknownhost'}->{'total'} ) );
		$data = $_atab->draw();
	}

	if( $reqv == 1 )
	{
		return($data);
	}
	else
	{
		if( ref($self->{'screen'}) eq q|IO::File| )
		{
			printf( {$self->{'device'}} "%s", $data );
		}
		elsif( uc($self->{'screen'}) eq q|STDOUT| )
		{
			printf( STDOUT "%s", $data );
		}
		else
		{
			printf( STDERR "%s", $data );
		}

		return($self->{'count'});
	}
}

sub matrix
{
	# +-+-+-+-+-+-+
	# |m|a|t|r|i|x|
	# +-+-+-+-+-+-+
	#
	# @Description	Print Matrix
	# @Param	<None>
	# @Return	0 = no record to print
	#		n = the number of ptinted records
	my $self = shift();
	my $stat = undef();
	my $reqv = defined(wantarray()) ? 1 : 0;
	my $data = {};	
	my $vector = {};
	my $matrix = q();
	my $statistics = q();

	return(0) unless( defined($self->{'count'}) );
	return(0) unless( $self->{'count'} );
	return(0) unless( @{$self->{'entities'}} );

	require Kanadzuchi::Statistics;
	require Kanadzuchi::Time;

	$self->{'totalsby'} ||= q(DayOfWeek);	# Default is 'Day Of Week'

	my $namelist = [];	# Name list
	my $eachname = q();	# Alias name
	my $datatype = lc($self->{'totalsby'});

	$namelist = Kanadzuchi::Time->monthname(0) if( $datatype eq 'month' );
	$namelist = Kanadzuchi::Time->dayofweek(1) if( $datatype eq 'dayofweek' );
	$namelist = Kanadzuchi::Time->hourname(1) if( $datatype eq 'hour' );

	# Add up
	$data = $self->addupbycalendar();

	# Statistics object
	if( $self->{'stats'} )
	{
		$stat = new Kanadzuchi::Statistics( 'rounding' => 5 );
		@{$vector->{'mobile'}} = map { $data->{$_}->{'mobile'} } keys(%$data);
		@{$vector->{'computer'}} = map { $data->{$_}->{'computer'} } keys(%$data);
		@{$vector->{'unknownhost'}} = map { $data->{$_}->{'unknownhost'} } keys(%$data);
		@{$vector->{'subtotal'}} = map { $data->{$_}->{'subtotal'} } keys(%$data);
	}

	# Print matrix
	BUILD_MATRIX:
	{
		if( $self->{'layout'} eq 'csv' )
		{
			$matrix .= sprintf( "%s,%s,%s,%s,%s\n", $self->{'totalsby'},
					'Cellphone', 'Computer', 'Unknown Host', 'Sub Total' );


			foreach my $_dort ( sort(keys(%$data)) )
			{
				$eachname = $_dort;
				$eachname = $_dort.q{(}.$namelist->[int($_dort)-1].q{)} if( $datatype eq 'month' );
				$eachname = $namelist->[int($_dort)-1] if( $datatype eq 'dayofweek' );
				$matrix .= sprintf( "%s,%d,%d,%d,%d\n", $eachname,
						$data->{$_dort}->{'mobile'},
						$data->{$_dort}->{'computer'},
						$data->{$_dort}->{'unknownhost'},
						$data->{$_dort}->{'subtotal'} );
			}

			# Statistics in CSV
			last(BUILD_MATRIX) unless( $self->{'stats'} );
			$statistics .= sprintf("Mean,%.04f,%.04f,%.04f,%.04f\n",
						$stat->mean( $vector->{'mobile'} ),
						$stat->mean( $vector->{'computer'} ),
						$stat->mean( $vector->{'unknownhost'} ),
						$stat->mean( $vector->{'subtotal'} ) );
			$statistics .= sprintf("Variance,%.04f,%.04f,%.04f,%.04f\n",
						$stat->variance( $vector->{'mobile'} ),
						$stat->variance( $vector->{'computer'} ),
						$stat->variance( $vector->{'unknownhost'} ),
						$stat->variance( $vector->{'subtotal'} ) );
			$statistics .= sprintf("Std Deviation,%.04f,%.04f,%.04f,%.04f\n",
						$stat->stddev( $vector->{'mobile'} ),
						$stat->stddev( $vector->{'computer'} ),
						$stat->stddev( $vector->{'unknownhost'} ),
						$stat->stddev( $vector->{'subtotal'} ) );
			$statistics .= sprintf("Median,%.04f,%.04f,%.04f,%.04f\n",
						$stat->median( $vector->{'mobile'} ),
						$stat->median( $vector->{'computer'} ),
						$stat->median( $vector->{'unknownhost'} ),
						$stat->median( $vector->{'subtotal'} ) );
			$statistics .= sprintf("Min,%.04f,%.04f,%.04f,%.04f\n",
						$stat->min( $vector->{'mobile'} ),
						$stat->min( $vector->{'computer'} ),
						$stat->min( $vector->{'unknownhost'} ),
						$stat->min( $vector->{'subtotal'} ) );
			$statistics .= sprintf("Max,%.04f,%.04f,%.04f,%.04f\n",
						$stat->max( $vector->{'mobile'} ),
						$stat->max( $vector->{'computer'} ),
						$stat->max( $vector->{'unknownhost'} ),
						$stat->max( $vector->{'subtotal'} ) );
			$statistics .= sprintf("1st Quartile,%.04f,%.04f,%.04f,%.04f\n",
						$stat->quartile( 1, $vector->{'mobile'} ),
						$stat->quartile( 1, $vector->{'computer'} ),
						$stat->quartile( 1, $vector->{'unknownhost'} ),
						$stat->quartile( 1, $vector->{'subtotal'} ) );
			$statistics .= sprintf("3rd Quartile,%.04f,%.04f,%.04f,%.04f\n",
						$stat->quartile( 3, $vector->{'mobile'} ),
						$stat->quartile( 3, $vector->{'computer'} ),
						$stat->quartile( 3, $vector->{'unknownhost'} ),
						$stat->quartile( 3, $vector->{'subtotal'} ) );
		}
		else
		{
			# ASCII Table
			require Text::ASCIITable;
			my $_atab = undef();	# ASCII Table object

			$_atab = new Text::ASCIITable( { 'headingText' => q{Totals by }.$self->{'totalsby'} });
			$_atab->setOptions( 'outputWidth', 80 );
			$_atab->setCols( $self->{'totalsby'}, 'Cellphone', 'Computer', 'Unknown Host', 'Sub Total' );

			foreach my $_dort ( sort(keys(%$data)) )
			{
				$eachname = $_dort;
				$eachname = $_dort.q{ (}.$namelist->[int($_dort)-1].q{)} if( $datatype eq 'month' );
				$eachname = $namelist->[int($_dort)-1] if( $datatype eq 'dayofweek' );

				$_atab->addRow( $eachname,
						$data->{$_dort}->{'mobile'},
						$data->{$_dort}->{'computer'},
						$data->{$_dort}->{'unknownhost'},
						$data->{$_dort}->{'subtotal'} );
			}

			$matrix = $_atab->draw();

			# Statistics in ASCII Table
			last(BUILD_MATRIX) unless( $self->{'stats'} );
			$_atab->addRowLine();
			$_atab->addRow( 'Mean', 
					sprintf("%.04f", $stat->mean( $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->mean( $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->mean( $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->mean( $vector->{'subtotal'} ) ) );
			$_atab->addRow( 'Variance', 
					sprintf("%.04f", $stat->variance( $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->variance( $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->variance( $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->variance( $vector->{'subtotal'} ) ) );
			$_atab->addRow( 'Std Deviation', 
					sprintf("%.04f", $stat->stddev( $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->stddev( $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->stddev( $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->stddev( $vector->{'subtotal'} ) ) );
			$_atab->addRow( 'Median', 
					sprintf("%.04f", $stat->median( $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->median( $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->median( $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->median( $vector->{'subtotal'} ) ) );
			$_atab->addRow( 'Min', 
					sprintf("%.04f", $stat->min( $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->min( $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->min( $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->min( $vector->{'subtotal'} ) ) );
			$_atab->addRow( 'Max', 
					sprintf("%.04f", $stat->max( $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->max( $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->max( $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->max( $vector->{'subtotal'} ) ) );
			$_atab->addRow( '1st Quartile', 
					sprintf("%.04f", $stat->quartile( 1, $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->quartile( 1, $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->quartile( 1, $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->quartile( 1, $vector->{'subtotal'} ) ) );
			$_atab->addRow( '3rd Quartile', 
					sprintf("%.04f", $stat->quartile( 3, $vector->{'mobile'} ) ),
					sprintf("%.04f", $stat->quartile( 3, $vector->{'computer'} ) ),
					sprintf("%.04f", $stat->quartile( 3, $vector->{'unknownhost'} ) ),
					sprintf("%.04f", $stat->quartile( 3, $vector->{'subtotal'} ) ) );
			$matrix = $_atab->draw();
		}
	}

	if( $reqv == 1 )
	{
		return($matrix.$statistics);
	}
	else
	{
		PRINT_MATRIX:
		{
			if( ref($self->{'screen'}) eq q|IO::File| )
			{
				printf( {$self->{'device'}} "%s", $matrix );
				printf( {$self->{'device'}} "%s", $statistics );
			}
			elsif( uc($self->{'screen'}) eq q|STDOUT| )
			{
				printf( STDOUT "%s", $matrix );
				printf( STDOUT "%s", $statistics );
			}
			else
			{
				printf( STDERR "%s", $matrix );
				printf( STDERR "%s", $statistics );
			}
		}

		return($self->{'count'});
	}
}

1;
__END__
