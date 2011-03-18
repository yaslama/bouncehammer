#__PERLEXECUTABLE__
# $Id: summarizer.PL,v 1.14.2.2 2011/03/18 05:46:12 ak Exp $
# -Id: summarizer.PL,v 1.13 2010/02/22 05:09:01 ak Exp -
# -Id: summarizer.PL,v 1.2 2009/10/06 09:10:32 ak Exp -
# -Id: summarizer.PL,v 1.3 2009/08/27 05:09:59 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi:Command::
                                             ##                       
  ##### ##  ## ##  ## ##  ##  ####  #####        ###### ####  #####   
 ##     ##  ## ###### ######     ## ##  ##  ###     ## ##  ## ##  ##  
  ####  ##  ## ###### ######  ##### ##       ##    ##  ###### ##      
     ## ##  ## ##  ## ##  ## ##  ## ##       ##   ##   ##     ##      
 #####   ##### ##  ## ##  ##  ##### ##      #### ###### ####  ##      
package Kanadzuchi::Command::Summarizer;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use lib '__KANADZUCHIROOT__/lib';
use strict;
use warnings;
use Kanadzuchi;
use Kanadzuchi::UI::CLI;
use Kanadzuchi::Time;
use Error ':try';
use Digest::MD5;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $Zci;		# (Kanadzuchi) System object
my $Cmd;		# (Kanadzuchi::UI::CLI) Database object
my $Rdb;		# (Kanadzuchi::BdDR) Database object
my $Fmt = q();		# (String) Output format
my $Log = [];		# (Ref->Array) Log files
my $Col = [];		# (Ref->Array) Aggregate by ...
my $Date = [];		# (Ref->Array) Date(s)
my $Unit = 'w';		# (String) Totals by ...

my $CLIOPTION = {
	'conf'		=> ( 1 << 0 ),
	'test'		=> ( 1 << 1 ),
	'aggregate'	=> ( 1 << 2 ),
	'dailyupdates'	=> ( 1 << 3 ),
	'database'	=> ( 1 << 4 ),
	'summary'	=> ( 1 << 5 ),
};

#  __  __    _    ___ _   _ 
# |  \/  |  / \  |_ _| \ | |
# | |\/| | / _ \  | ||  \| |
# | |  | |/ ___ \ | || |\  |
# |_|  |_/_/   \_\___|_| \_|
#
# Create Kanadzuchi object
$Zci = new Kanadzuchi();
$Cmd = new Kanadzuchi::UI::CLI(
		'option' => $CLIOPTION,
		'commandline' => join(q{ }, $0, @ARGV ));

# Parse options, initialize object
try {
	if( $Cmd->operation( parse_options() ) == 0 )
	{
		Kanadzuchi::Exception::Command->throw( '-text' => 'Try --help' );
	}

	my $_load = $Zci->load( $Cmd->cf() );
	if( Kanadzuchi->is_exception($_load) )
	{
		Kanadzuchi::Exception::System->throw( '-text' => $_load );
	}

	$Cmd->init( $Zci );
	$Cmd->d( 1, sprintf( "Config file = %s\n", $Cmd->cf() ));
}
otherwise {
	$Cmd->exception(shift());
	$Cmd->abort();
};

# Set signal handlers
foreach my $sig qw( INT QUIT TERM KILL )
{
	$SIG{$sig} = sub { $Cmd->catch_signal($sig); };
}

if( $Cmd->operation & ( $Cmd->option->{'aggregate'} + $Cmd->option->{'dailyupdates'} ) )
{
	my $statistics = undef();	# (Kanazuchi::Statistics::Stored::*) Statistics object
	my $dailyulogs = undef();	# (Kanadzuchi::BdDR::DailyUpdates::*) DailyUpdates Table object
	my $asciitable = undef();	# (Text::ASCIITable) ASCII Table object
	my $smprogress = undef();	# (Term::ProgressBar ) Progress bar object
	my $whereconds = undef();	# (Ref->Hash) WHERE Condition
	my $samplesize = 0;		# (Integer) Sample size
	my $afrequency = 0;		# (Integer) Sum. of frequency
	my $aggregated = {};		# (Ref->Hash) Aggregated Data(Ref->Array)
	my $summarized = {};		# (Ref->Hash) Summarized Data(Ref->Array)
	my $outputdata = q();		# (String) Output data for displaying
	my $graphchara = '+';		# (String) Graph character in ASCII Table
	my $graphscale = 100;		# (Integer) Graph scale in ASCII Table

	require Text::ASCIITable if( $Fmt eq 'asciitable' );

	if( $Rdb && ( $Cmd->operation & $Cmd->option->{'database'} ) )
	{
		# Set values to Kanadzuchi::BdDR object, Create data source name
		try {
			$Rdb->setup( $Zci->config->{'database'} );
			Kanadzuchi::Exception::Database->throw( 
				'-text' => 'Failed to connect DB' ) unless( $Rdb->connect() );
			$Cmd->d(2,"Connecting to the database\n") if( defined $Rdb->handle() );

			( $Rdb->hostname() ne 'localhost' && $Rdb->port() ne q() )
				? $Cmd->d(2,sprintf("Database host = %s:%s\n", $Rdb->hostname(), $Rdb->port()))
				: $Rdb->hostname() eq 'localhost' ? $Cmd->d(2,'Database host = Socket'.qq{\n}) : 1;

			$Cmd->d(2,sprintf("Database name = %s(%s)\n", $Rdb->dbname(), $Rdb->dbtype()));
			$Cmd->d(2,sprintf("Database user = %s\n", $Rdb->username()));
		}
		catch Kanadzuchi::Exception::Database with {
			my $e = shift();
			my $b = '-' x 64;
			my $m = $e;

			if( length $Rdb->error->{'string'} )
			{
				$m .= "\n".$b;
				$m .= "\n ".$Rdb->error->{'string'};
				$m .= $b;
				$m .= "\n";
				$e .= ': '.$Rdb->error->{'string'};
			}
			$Cmd->exception($m);
			$Cmd->abort();
		};

		if( $Cmd->operation & $Cmd->option->{'aggregate'} )
		{
			# Aggregate records in the Database
			require Kanadzuchi::Statistics::Stored::BdDR;
			$statistics = new Kanadzuchi::Statistics::Stored::BdDR();
			$statistics->handle( $Rdb->handle );
			$Cmd->d(1,sprintf("Aggregate records in the Database: %s\n", $Rdb->dbname()));
		}
		elsif( $Cmd->operation & $Cmd->option->{'dailyupdates'} )
		{
			# Daily Updates
			require Kanadzuchi::Statistics if( $Cmd->operation & $Cmd->option->{'summary'} );
			require Kanadzuchi::BdDR::DailyUpdates;
			require Kanadzuchi::BdDR::Page;

			$dailyulogs = new Kanadzuchi::BdDR::DailyUpdates::Data( 'handle' => $Rdb->handle() );
			$Cmd->d(1,sprintf("Daily Updates in the Database: %s\n", $Rdb->dbname()));
		}
	}
	else
	{
		if( $Cmd->operation & $Cmd->option->{'aggregate'} )
		{
			# Aggregate records in the log file
			require Kanadzuchi::Statistics::Stored::YAML;
			$statistics = new Kanadzuchi::Statistics::Stored::YAML();

			# Create the log file name by the day(-t, -y, -b, or -d option )
			if( scalar(@$Log) == 0 && scalar(@$Date) )
			{
				# Set the log file name
				push( @$Log, new Path::Class::File( 
						$Zci->get_logfile( 'r', { 'date' => $Date->[0] } ) ) );
			}

			try {
				foreach my $f ( @$Log )
				{
					next() if( -e $f && -s _ && -T _ && -r _ );
					Kanadzuchi::Exception::File->throw( '-text' => 'No such file: '.$f ) unless( -e $f );
					Kanadzuchi::Exception::File->throw( '-text' => 'Cannot read: '.$f ) unless( -r $f );
					Kanadzuchi::Exception::File->throw( '-text' => 'Empty file: '.$f ) unless( -s $f );
					Kanadzuchi::Exception::File->throw( '-text' => 'Not text: '.$f ) unless( -T $f );
				}
				continue
				{
					$Cmd->d( 1, sprintf("Log file = %s\n", $f->stringify() ));
				}
			}
			catch Kanadzuchi::Exception::File with {
				$Cmd->exception(shift());
				$Cmd->abort();
			};

			$statistics->file( $Log );
			$statistics->load();
		}
	}


	if( $Cmd->operation & $Cmd->option->{'aggregate'} )
	{
		#     _                                    _       
		#    / \   __ _  __ _ _ __ ___  __ _  __ _| |_ ___ 
		#   / _ \ / _` |/ _` | '__/ _ \/ _` |/ _` | __/ _ \
		#  / ___ \ (_| | (_| | | |  __/ (_| | (_| | ||  __/
		# /_/   \_\__, |\__, |_|  \___|\__, |\__,_|\__\___|
		#         |___/ |___/          |___/               
		#                                                         
		$Cmd->d( 1, sprintf("Aggregate by %s\n", join( ', ', @$Col ) ) );

		# WHERE Condition
		if( scalar @$Date )
		{
			if( scalar @$Date == 1 )
			{
				# Certain Date
				my $_otimepiece = Time::Piece->strptime($Date->[0],"%Y-%m-%d");
				$whereconds = {
					'bounced' => [
						{ '>' => ($_otimepiece->epoch() - 1) },
						{ '<' => ($_otimepiece->epoch() + 86400) },
					]
				};
				$Cmd->d( 1, sprintf("The Date = %s\n", $Date->[0]) );
			}
			elsif( scalar @$Date == 2 )
			{
				# Period
				my $_xtimepiece = Time::Piece->strptime($Date->[0],"%Y-%m-%d");
				my $_ytimepiece = Time::Piece->strptime($Date->[1],"%Y-%m-%d");
				$whereconds = {
					'bounced' => [
						{ '>' => ($_xtimepiece->epoch() - 1) },
						{ '<' => ($_ytimepiece->epoch() + 86400) },
					]
				};
				$Cmd->d( 1, sprintf("Period = %s -> %s\n", $Date->[0], $Date->[1] ) );
			}
			else
			{
				; # scalar @$Date > 2 ...?
			}
		}

		# Prepare the progress bar
		if( $Cmd->stream->{out} && $Cmd->debuglevel > -1 )
		{
			require Term::ProgressBar;
			$smprogress = new Term::ProgressBar( { 
						'fh' => \*STDERR,
						'ETA' => 'linear',
						'name' => 'Aggregation',
						'count' => scalar(@$Col) * 2 } );
		}

		while( my $c = shift @$Col )
		{
			$aggregated->{$c} = $statistics->aggregate($c,$whereconds);
			map { $samplesize += $_->{'size'} } @{ $statistics->cache() } unless $samplesize;
			map { $afrequency += $_->{'freq'} } @{ $statistics->cache() } unless $afrequency;
			$smprogress->update() if( defined $smprogress );

			if( $Cmd->operation & $Cmd->option->{'summary'} )
			{
				# Calculate descriptive statistics
				foreach my $x ( 'size', 'freq' )
				{
					$statistics->sample( [ map { $_->{$x} } @{ $statistics->cache() } ] );
					$statistics->rounding(3);
					$summarized->{$c}->{$x}->{'min'} = $statistics->min();
					$summarized->{$c}->{$x}->{'max'} = $statistics->max();
					$summarized->{$c}->{$x}->{'mean'} = $statistics->mean();
					$summarized->{$c}->{$x}->{'stddev'} = $statistics->stddev();

					# NA?
					foreach my $s ( qw(min max mean stddev) )
					{
						$summarized->{$c}->{$x}->{$s} = 
							$summarized->{$c}->{$x}->{$s} eq 'NA'
								? 'NA'
								: sprintf( "%0.2f", $summarized->{$c}->{$x}->{$s} );
					}
				}
			}
			$smprogress->update() if( defined $smprogress );
		}

		foreach my $col ( keys %$aggregated )
		{
			unless( $samplesize )
			{
				$Cmd->d( 1, sprintf("No data, sample size = %d\n", $samplesize ) );
				last();
			}

			my $_ratio = {};
			my $_graph = {};

			foreach my $e ( @{ $aggregated->{$col} } )
			{
				$_ratio->{$e}->{'size'} = $samplesize > 0 ? sprintf( "%0.3f", $e->{'size'} / $samplesize ): 'NA';
				$_ratio->{$e}->{'freq'} = $afrequency > 0 ? sprintf( "%0.3f", $e->{'freq'} / $afrequency ): 'NA';
				$_graph->{$e} = $graphchara x int( ( $e->{'size'} / $samplesize ) * $graphscale );
			}

			if( $Fmt eq 'asciitable' )
			{
				# Human readable ASCII table
				$asciitable = new Text::ASCIITable( { 'headingText' => 'Aggregate by '.$col } );
				$asciitable->setOptions( 'outputWidth', 80 );
				$asciitable->setCols( 'Name', 'Count', 'Freq.', 'Ratio(Count/Freq.)', 'Graph(Count)' );

				foreach my $e ( @{ $aggregated->{$col} } )
				{
					$asciitable->addRow( $e->{'name'}, $e->{'size'}, $e->{'freq'},
								' '.$_ratio->{$e}->{'size'}.' / '.$_ratio->{$e}->{'freq'},
								$_graph->{$e} );
				}

				$asciitable->addRowLine() if( scalar @{ $asciitable->{'tbl_rows'} } );
				$asciitable->addRow( 'Sum', $samplesize, $afrequency, ' 1.000 / 1.000' );

				if( $Cmd->operation & $Cmd->option->{'summary'} )
				{
					$asciitable->addRowLine();
					foreach my $d ( 'min', 'mean', 'max', 'stddev' )
					{
						$asciitable->addRow( 
							( $d eq 'min' || $d eq 'max' ) ? ucfirst($d).'.' : ucfirst($d),
							$summarized->{ $col }->{'size'}->{ $d },
							$summarized->{ $col }->{'freq'}->{ $d },
						);
					}
				}
				print $asciitable->draw();
			}
			else
			{
				my $outputform = {};		# (Ref->Hash) Output format

				if( $Fmt eq 'yaml' )
				{
					# YAML format
					$outputform->{'head'} .= qq|%s:\n|;
					$outputform->{'head'} .= qq|  data:\n|;
					$outputform->{'data'} .= qq|    - { name: %s, count: %d, ratio-of-count: %0.3f, freq: %d, ratio-of-freq: %0.3f }\n|;
					$outputform->{'summ'} .= qq|  sum: { count: %d, freq: %d }\n|;
					$outputform->{'stat'} .= qq|  summary:\n|;
					$outputform->{'stat'} .= qq|    min: { count: %0.2f, freq: %0.2f }\n|;
					$outputform->{'stat'} .= qq|    mean: { count: %0.2f, freq: %0.2f }\n|;
					$outputform->{'stat'} .= qq|    max: { count: %0.2f, freq: %0.2f }\n|;
					$outputform->{'stat'} .= qq|    stddev: { count: %0.2f, freq: %0.2f }\n|;
				}
				elsif( $Fmt eq 'csv' )
				{
					# CSV format
					$outputform->{'head'} .= qq|name,count,ratio-of-count,frequency,ratio-of-freq\n|;
					$outputform->{'data'} .= qq|%s,%d,%0.3f,%d,%0.3f\n|;
					$outputform->{'summ'} .= q();
					$outputform->{'stat'} .= qq|min.,%0.2f,,%0.2f,\n|;
					$outputform->{'stat'} .= qq|mean,%0.2f,,%0.2f,\n|;
					$outputform->{'stat'} .= qq|max.,%0.2f,,%0.2f,\n|;
					$outputform->{'stat'} .= qq|stddev.,%0.2f,,%0.2f,\n|;
				}

				printf( $outputform->{'head'}, $col );
				foreach my $y ( @{ $aggregated->{$col} } )
				{
					printf( $outputform->{'data'}, 
						$y->{'name'}, $y->{'size'}, $_ratio->{$y}->{'size'}, $y->{'freq'}, $_ratio->{$y}->{'freq'} );
				}
				printf( $outputform->{'summ'}, $samplesize, $afrequency );

				if( $Cmd->operation & $Cmd->option->{'summary'} )
				{
					printf( $outputform->{'stat'}, 
						map { 
							$summarized->{ $col }->{'size'}->{ $_ },
							$summarized->{ $col }->{'freq'}->{ $_ } } qw(min mean max stddev) );
				}
			}
		}
	}
	elsif( $Cmd->operation & $Cmd->option->{'dailyupdates'} )
	{
		 ####           ##  ###         ##  ##             ##          ##                 
		 ## ##  ####         ##  ##  ## ##  ##  #####      ##   #### ###### ####   #####  
		 ##  ##    ##  ###   ##  ##  ## ##  ##  ##  ##  #####      ##  ##  ##  ## ##      
		 ##  ## #####   ##   ##  ##  ## ##  ##  ##  ## ##  ##   #####  ##  ######  ####   
		 ## ## ##  ##   ##   ##   ##### ##  ##  #####  ##  ##  ##  ##  ##  ##         ##  
		 ####   #####  #### ####    ##   ####   ##      #####   #####   ### ####  #####   
		                         ####           ##                                        
		my $pagination = undef();	# (Kanadzuchi::BdDR::Page) Pagination object
		my $duiterator = undef();	# (Kanadzuchi::Iterator) Iterator object
		my $nrecordsin = 0;		# (Integer) The number of records in the DB
		my $sampledata = [];		# (Ref->Array) Samples for summary
		my $outputform = {};		# (Ref->Hash) Output format( YAML and CSV )
		my $headingtxt = q();		# (String) Heading text for ASCII Table
		my $stunitname = { 'd' => 'Day', 'w' => 'Week', 'm' => 'Month', 'y' => 'Year' };
		my $rppforunit = { 'd' => 31, 'w' => 188, 'm' => 732, 'y' => 3660 };
		my $columnname = [ 'estimated', 'inserted', 'updated', 'skipped', 'failed', 'executed' ];

		# WHERE Condition
		if( scalar @$Date )
		{
			if( scalar @$Date == 1 )
			{
				# Certain Date
				$whereconds = { 'thedate' => $Date->[0] };
				$headingtxt = '('.$Date->[0].')';
				$Cmd->d( 1, sprintf("The Date = %s\n", $Date->[0]) );
			}
			elsif( scalar @$Date == 2 )
			{
				# Period
				my $_xtimepiece = Time::Piece->strptime($Date->[0],"%Y-%m-%d");
				my $_ytimepiece = Time::Piece->strptime($Date->[1],"%Y-%m-%d");
				my $_dateoffset = int(abs($_xtimepiece->epoch - $_ytimepiece->epoch) / 86400 );

				$whereconds = {
					'thetime' => [ '-and' =>
						{ '>' => ($_xtimepiece->epoch() - 1) },
						{ '<' => ($_ytimepiece->epoch() + 86400) },
					]
				};

				unless( $Unit )
				{
					if( $_dateoffset > 1100 )
					{
						$Unit = 'y';	# Year
					}
					elsif( $_dateoffset > 180 )
					{
						$Unit = 'm';	# Month
					}
					elsif( $_dateoffset > 50 )
					{
						$Unit = 'w';	# Week
					}
					else
					{
						$Unit = 'w';	# Default: week
					}
				}
				$headingtxt = '('.$Date->[0].' -> '.$Date->[1].')';
				$Cmd->d( 1, sprintf("Period = %s -> %s\n", $Date->[0], $Date->[1] ) );
			}
			else
			{
				; # scalar @$Date > 2 ...?
			}
		}
		$headingtxt .= ' Subtotals by '.$stunitname->{ $Unit };
		$Cmd->d( 1, sprintf("Subtotals by %s\n", $stunitname->{ $Unit } ) );

		if( $Fmt eq 'asciitable' )
		{
			# Human readable ASCII table
			$asciitable = new Text::ASCIITable( { 'headingText' => 'Daily Updates'.$headingtxt } );
			$asciitable->setOptions( 'outputWidth', 80 );
			$asciitable->setCols( $stunitname->{ $Unit }, 
						map( ucfirst($_), @$columnname ), 'Last Modified' );
		}
		else
		{
			if( $Fmt eq 'yaml' )
			{
				$outputform->{'head'} .= qq|dailyupdates:\n|;
				$outputform->{'head'} .= qq|  subtotalsby: %s\n|;
				$outputform->{'head'} .= qq|  data:\n|;
				$outputform->{'data'} .= qq|    %s: { estimated: %d, inserted: %d, updated: %d, skipped: %d,|;
				$outputform->{'data'} .= qq| failed: %d, executed: %d, last-modified: '%s' }\n|;
				$outputform->{'summ'} .= qq|  sum: { estimated: %d, inserted: %d, updated: %d, skipped: %d, failed: %d, executed: %d }\n|;
				$outputform->{'stat'} .= qq|  summary:\n|;
				$outputform->{'stat'} .= qq|    min: { estimated: %0.2f, inserted: %0.2f, updated: %0.2f,|;
				$outputform->{'stat'} .= qq| skipped: %0.2f, failed: %0.2f, executed: %0.2f }\n|;
				$outputform->{'stat'} .= qq|    mean: { estimated: %0.2f, inserted: %0.2f, updated: %0.2f,|;
				$outputform->{'stat'} .= qq| skipped: %0.2f, failed: %0.2f, executed: %0.2f }\n|;
				$outputform->{'stat'} .= qq|    max: { estimated: %0.2f, inserted: %0.2f, updated: %0.2f,|;
				$outputform->{'stat'} .= qq| skipped: %0.2f, failed: %0.2f, executed: %0.2f }\n|;
				$outputform->{'stat'} .= qq|    stddev: { estimated: %0.2f, inserted: %0.2f, updated: %0.2f,|;
				$outputform->{'stat'} .= qq| skipped: %0.2f, failed: %0.2f, executed: %0.2f }\n|;
			}
			elsif( $Fmt eq 'csv' )
			{
				$outputform->{'head'} .= qq|%s,%s,%s,%s,%s,%s,%s,%s\n|;
				$outputform->{'data'} .= qq|%s,%d,%d,%d,%d,%d,%d,%s\n|;
				$outputform->{'summ'} .= q();
				$outputform->{'stat'} .= qq|min.,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f\n|;
				$outputform->{'stat'} .= qq|mean,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f\n|;
				$outputform->{'stat'} .= qq|max.,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f\n|;
				$outputform->{'stat'} .= qq|stddev.,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f,%0.2f\n|;
			}
		}

		$nrecordsin = $dailyulogs->db->count( $whereconds );
		$Cmd->finish() unless $nrecordsin;

		$statistics = new Kanadzuchi::Statistics() if( $Cmd->operation & $Cmd->option->{'summary'} );
		$pagination = new Kanadzuchi::BdDR::Page();
		$pagination->resultsperpage( $rppforunit->{ $Unit } );
		$pagination->set( $nrecordsin );
		$pagination->colnameorderby( 'thedate' );
		$dailyulogs->totalsby($Unit);

		# Prepare the progress bar
		if( $Cmd->stream->{out} && $Cmd->debuglevel > -1 )
		{
			require Term::ProgressBar if( $Cmd->debuglevel > -1 );
			$smprogress = new Term::ProgressBar( { 
						'fh' => \*STDERR,
						'ETA' => 'linear',
						'name' => 'DailyUpdates',
						'count' => $pagination->lastpagenumber() } );
		}

		while(1)
		{
			$duiterator = $dailyulogs->quaerit( $whereconds, $pagination, $Unit );

			if( $Unit eq 'd' )
			{
				my $lasty = q();	# Last year and month
				my $thisy = q();	# This year and month

				# Output header string of YAML or CSV
				printf( $outputform->{'head'}, lc $stunitname->{ $Unit } ) if( $Fmt eq 'yaml' );
				printf( $outputform->{'head'}, lc $stunitname->{ $Unit },
					map( lc($_), @$columnname ), 'last-modified' ) if( $Fmt eq 'csv' );

				while( my $_r = $duiterator->next() )
				{
					if( $Fmt eq 'asciitable' )
					{
						$thisy = $1 if( $_r->{'thedate'} =~ m{\A(\d{4}[-]\d{2})} );

						if( $duiterator->count > 10 && $lasty && ( $thisy ne $lasty ) )
						{
							$asciitable->addRowLine()
						}

						$asciitable->addRow(
							$_r->{'thedate'}, $_r->{'estimated'}, $_r->{'inserted'},
							$_r->{'updated'}, $_r->{'skipped'}, $_r->{'failed'}, 
							$_r->{'executed'}, $_r->{'modified'}->cdate() );
						$lasty = $thisy;
					}
					else
					{
						# YAML or CSV
						printf( $outputform->{'data'}, 
							$_r->{'thedate'}, $_r->{'estimated'}, $_r->{'inserted'},
							$_r->{'updated'}, $_r->{'skipped'}, $_r->{'failed'},
							$_r->{'executed'}, $_r->{'modified'}->cdate() );
					}

					push( @$sampledata, $_r ) if( $Cmd->operation & $Cmd->option->{'summary'} );
				}
			}
			else
			{
				$dailyulogs->congregat( $duiterator->all() );
			}

			$smprogress->update() if( $smprogress );
			last() unless $pagination->hasnext();
			$pagination->next();

		} # End of while(1)

		if( scalar @{ $dailyulogs->subtotal() } )
		{
			# Output header string of YAML or CSV
			printf( $outputform->{'head'}, lc $stunitname->{ $Unit } ) if( $Fmt eq 'yaml' );
			printf( $outputform->{'head'}, lc $stunitname->{ $Unit },
				map( lc($_), @$columnname ), 'last-modified' ) if( $Fmt eq 'csv' );

			foreach my $_s ( @{ $dailyulogs->subtotal() } )
			{
				if( $Fmt eq 'asciitable' )
				{
					# ASCII Table
					$asciitable->addRow(
						$_s->{'name'}, $_s->{'estimated'}, $_s->{'inserted'},
						$_s->{'updated'}, $_s->{'skipped'}, $_s->{'failed'},
						$_s->{'executed'}, $_s->{'modified'}->cdate() );
				}
				else
				{
					# YAML or CSV
					printf( $outputform->{'data'}, 
						$_s->{'name'}, $_s->{'estimated'}, $_s->{'inserted'},
						$_s->{'updated'}, $_s->{'skipped'}, $_s->{'failed'},
						$_s->{'executed'}, $_s->{'modified'}->cdate() );
				}
				push( @$sampledata, $_s ) if( $Cmd->operation & $Cmd->option->{'summary'} );
			}
		}


		if( $Cmd->operation & $Cmd->option->{'summary'} )
		{
			foreach my $c ( @$columnname )
			{
				$aggregated->{ $c } = [ map( $_->{ $c }, @$sampledata ) ];
			}

			foreach my $c ( @$columnname )
			{
				$summarized->{ $c }->{'sum'} = $statistics->sum( $aggregated->{ $c } );
				$summarized->{ $c }->{'min'} = $statistics->min( $aggregated->{ $c } );
				$summarized->{ $c }->{'mean'} = $statistics->mean( $aggregated->{ $c } );
				$summarized->{ $c }->{'max'} = $statistics->max( $aggregated->{ $c } );
				$summarized->{ $c }->{'stddev'} = $statistics->sd( $aggregated->{ $c } );

				foreach my $s ( qw( min mean max stddev) )
				{
					$summarized->{ $c }->{ $s } = 
						$summarized->{ $c }->{ $s } eq 'NA'
							? 'NA'
							: sprintf( "%0.2f", $summarized->{ $c }->{ $s } );
				}
			}

			if( $Fmt eq 'asciitable' )
			{
				$asciitable->addRowLine();
				$asciitable->addRow( 'Sum', map( $summarized->{ $_ }->{'sum'}, @$columnname ) );
				$asciitable->addRowLine();
				$asciitable->addRow( 'Min.', map( $summarized->{ $_ }->{'min'}, @$columnname ) );
				$asciitable->addRow( 'Mean', map( $summarized->{ $_ }->{'mean'}, @$columnname ) );
				$asciitable->addRow( 'Max.', map( $summarized->{ $_ }->{'max'}, @$columnname ) );
				$asciitable->addRow( 'Stddev', map( $summarized->{ $_ }->{'stddev'}, @$columnname ) );
			}
			else
			{
				# YAML or CSV
				printf( $outputform->{'stat'}, 
						map( $summarized->{ $_ }->{'min'}, @$columnname ),
						map( $summarized->{ $_ }->{'mean'}, @$columnname ),
						map( $summarized->{ $_ }->{'max'}, @$columnname ),
						map( $summarized->{ $_ }->{'stddev'}, @$columnname ) )
			}
		}

		print $asciitable->draw() if( defined $asciitable );
	}
}

$Cmd->finish();


#  _____ _   _ _   _  ____ _____ ___ ___  _   _ ____  
# |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___| 
# | |_  | | | |  \| | |     | |  | | | | |  \| \___ \ 
# |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
# |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/ 
# 
sub parse_options
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |p|a|r|s|e|_|o|p|t|i|o|n|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Parse given options, and set the operation mode.
	# @Param	None
	# @Return	n = Integer: operation value(24bit integer)

	require Getopt::Long;
	my $operation = 0;

	# Variables for decide operation
	my (
		$opt_aggregate,
		$opt_aggregateall,
		$opt_before,
		$opt_conf,
		$opt_dailyupdates,
		$opt_database,
		$opt_date,
		$opt_format,
		$opt_host,
		$opt_period,
		$opt_port,
		$opt_silent,
		$opt_summary,
		$opt_test,
		$opt_today,
		$opt_totalsby,
		$opt_type,
		$opt_verbose,
		$opt_yesterday,
	);

	# Relations of the option name and the option value
	Getopt::Long::Configure( 'bundling', 'no_ignore_case' ); 
	Getopt::Long::GetOptions(
			'C=s'		=> \$opt_conf,
			'conf=s'	=> \$opt_conf,
			'help'		=> sub { help(); exit(0); },
			'T'		=> \$opt_test,
			'test'		=> \$opt_test,
			'silent'	=> sub { $Cmd->silent(1); },
			'verbose'	=> \$opt_verbose,
			'v+'		=> \$opt_verbose,
			'version'	=> sub { printf(STDERR "%s\n", $Zci->version()); exit(0); },

			# Date options
			'b=i'		=> \$opt_before,
			'before=i'	=> \$opt_before,
			'd=s'		=> \$opt_date,
			'date=s'	=> \$opt_date,
			'p=s'		=> \$opt_period,
			'period=s'	=> \$opt_period,
			't'		=> \$opt_today,
			'today'		=> \$opt_today,
			'y'		=> \$opt_yesterday,
			'yesterday'	=> \$opt_yesterday,

			# Aggreagate and Daily Updates options
			'A'		=> \$opt_aggregateall,
			'aggregate-all'	=> \$opt_aggregateall,
			'a=s'		=> \$opt_aggregate,
			'aggregate=s'	=> \$opt_aggregate,
			'U'		=> \$opt_dailyupdates,
			'dailyupdates'	=> \$opt_dailyupdates,
			's'		=> \$opt_summary,
			'summary'	=> \$opt_summary,
			'totalsby=s'	=> \$opt_totalsby,

			# Format options
			'format=s'	=> \$opt_format,
			'F=s'		=> \$opt_format,

			# Database options
			'D'		=> \$opt_database,
			'database'	=> \$opt_database,
			'host=s'	=> \$opt_host,
			'port=i'	=> \$opt_port,
			'type=s'	=> \$opt_type,
		);


	# (verbose|debug|silent) mode
	$Cmd->debuglevel( ( $opt_verbose ? $opt_verbose : 0 ) - 1 );

	# Specify Config File(YAML)	
	if( defined($opt_conf) )
	{
		# Use specified config file(YAML)
		$operation |= $Cmd->option->{'conf'};
		$Cmd->cf( new Path::Class::File($opt_conf) );
	}
	elsif( $opt_test )
	{
		# Test mode,
		$Cmd->cf( new Path::Class::File('/dev/null'));
		$operation |= $Cmd->option->{'test'};
	}
	else
	{
		# Use default config file(YAML)
		$Cmd->cf( new Path::Class::File($Kanadzuchi::SYSCONF)->absolute());
		$Cmd->cf->cleanup();
	}

	if( $opt_aggregateall || $opt_aggregate || $opt_dailyupdates )
	{
		if( $opt_aggregateall || $opt_aggregate )
		{
			# Aggregation
			require Kanadzuchi::BdDR::BounceLogs::Masters;
			my $mastertable = q|Kanadzuchi::BdDR::BounceLogs::Masters::Table|;

			if( $opt_aggregate )
			{
				$opt_aggregate = 'w' if( lc $opt_aggregate eq 'r' );
				$Col = [ $mastertable->whichtable( lc substr($opt_aggregate,0,1) )];
				$Cmd->e('Invalid column name: '.$opt_aggregate ) unless( $Col->[0] );
			}
			else
			{
				foreach my $c qw(s d h p w)
				{
					push( @$Col, $mastertable->whichtable(lc $c) );
				}
			}

			map { $_ = lc $_; chop $_ } @$Col;
			$operation |= $Cmd->option->{'aggregate'};
		}
		else
		{
			# DailyUpdates
			require Kanadzuchi::BdDR::DailyUpdates;
			$operation |= $Cmd->option->{'dailyupdates'};
		}


		if( $opt_database || ( $operation & $Cmd->option->{'dailyupdates'} ) )
		{
			# Create Kanadzuchi::BdDR object
			require Kanadzuchi::BdDR;
			$Rdb = new Kanadzuchi::BdDR();

			# Database spec option, Override values in the config file
			if( $opt_host ){ $Rdb->hostname($opt_host); }
			if( $opt_type ){ $Rdb->dbtype($opt_type); }
			if( $opt_port ){ $Rdb->port($opt_port); }
			$operation |= $Cmd->option->{'database'};
		}


		if( $operation & ( $Cmd->option->{'aggregate'} + $Cmd->option->{'dailyupdates'} ) )
		{
			if( $opt_today || $opt_yesterday || $opt_before )
			{
				# The day
				my $_offset = $opt_today ? 0
						: $opt_yesterday ? 1
							: defined($opt_before) ? abs $opt_before
								: $Cmd->e('Invalid date offset value');
				$Date->[0] = Kanadzuchi::Time->o2d($_offset);
			}
			elsif( $opt_date )
			{
				# Certain date
				if( $opt_date =~ m{\A(\d{4})(?:-|/)(\d{1,2})(?:-|/)(\d{1,2})\z} )
				{
					$Date->[0] = sprintf("%04d-%02d-%02d", $1, $2, $3 );

					# See http://en.wikipedia.org/wiki/Year_2038_problem
					$Date->[0] = '2038-01-19' if( $1 >= 2038 && $2 >= 1 && $3 >= 19 );
					$Date->[0] = '1970-01-01' if( $1 <  1970 );
				}
				else
				{
					$Cmd->e('Invalid date format: '.$opt_date.', See --help');
				}
			}
			elsif( $opt_period ) 
			{
				my @_period = split(':',$opt_period);
				my $_theday = q();
				$Cmd->e('-p(--period) option requires -D(--database) option') unless( $Rdb );
				$Cmd->e('Invalid period format: '.$opt_period.', See --help') unless( scalar(@_period) == 2 );

				foreach my $_d ( @_period )
				{
					if( $_d =~ m{\A(\d{4})(?:-|/)(\d{1,2})(?:-|/)(\d{1,2})\z} )
					{
						$_theday = sprintf("%04d-%02d-%02d", $1, $2, $3 );

						# See http://en.wikipedia.org/wiki/Year_2038_problem
						$_theday = '2038-01-19' if( $1 >= 2038 && $2 >= 1 && $3 >= 19 );
						$_theday = '1970-01-01' if( $1  < 1970 );

						push( @$Date, $_theday );
					}
					else
					{
						$Cmd->e('Invalid date format: '.$_d.', See --help')
					}
				}
			}
			else
			{
				# Default is 'today' if there is no database option
				$Date->[0] = Kanadzuchi::Time->o2d(0) unless( $Rdb );
			}
			@$Date = sort @$Date if scalar @$Date;

			if( $opt_totalsby )
			{
				$Unit = substr( lc $opt_totalsby, 0, 1 );

				if( $Unit && $Unit !~ m{(?:d|m|w|y)} )
				{
					$Cmd->e('Invalid unit string: '.$opt_totalsby.', See --help');
				}
			}

			if( ( $operation & $Cmd->option->{'aggregate'} ) && ! $Rdb )
			{
				DETECT_LOG_FILES: {
					last(DETECT_LOG_FILES) if( scalar(@ARGV) == 0 || $ARGV[0] eq '-' );

					my @_logfs = @ARGV;
					map { $_ =~ y{[ ]}{}d; } @_logfs;
					map { $_ =~ s{\A[ ]}{}g; $_ =~ s{[ ]\z}{}g; } @_logfs;

					@$Log = map { Path::Class::File->new($_); } @_logfs;
				}
			}

		}

		$operation |= $Cmd->option->{'summary'} if( $opt_summary );
	}
	else
	{
		$Cmd->e('Aggregation option -A or -a, DailyUpdates option -U or --dailyupdates required ');
	}

	# Output format options
	if( $opt_format )
	{
		my $_1stcharacter = substr( $opt_format, 0, 1 );
		$Fmt =  $_1stcharacter eq 'y' ? 'yaml' :
			$_1stcharacter eq 'c' ? 'csv'  :
			$_1stcharacter eq 'a' ? 'asciitable' : 'asciitable';
	}
	else
	{
		$Fmt = 'asciitable';
	}

	# Check whether or not Required options are specified.
	return($operation);
}

sub help
{
	# +-+-+-+-+
	# |h|e|l|p|
	# +-+-+-+-+
	#
	# @Description	Print help messages
	# @Param	NONE
	# @Return	1
	printf( STDERR "%s/%s %s\n", $Zci->myname(), $Cmd->calledfrom(), $Zci->version() );
	printf( STDERR "Usage: %s <AGGREGATE OPTION> [OPTIONS] [file]\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );
	printf( STDERR " * AGGREGATION OPTION\n" );
	printf( STDERR "    -A, --aggregate-all : Aggregate by all of the following columns <c>.\n");
	printf( STDERR "    -a, --aggregate <c> : Aggregate by the following column <c>: \n");
	printf( STDERR "                          a = [a]ddresser, s = [s]enderdomain, d = [d]estinations\n");
	printf( STDERR "                          h = [h]ostgroup, p = [p]rovider, r,w = [r]easons([w]hy)\n");
	printf( STDERR "    -D, --database      : (Database) Aggregate records in the database\n");
	printf( STDERR "\n" );
	printf( STDERR " * DAILY UPDATES OPTION\n" );
	printf( STDERR "    -U, --dailyupdates  : Print DailyUpdates data\n" );
	printf( STDERR "    -p, --period <x:y>  : Set a certain period of time. The format of period is following,\n");
	printf( STDERR "                          2009/04/29:2009/05/09 or 2009-12-23:2010-01-23\n" );
	printf( STDERR "    --totalsby <unit>   : Totals by [d]ay, [w]eek, [m]onth, [y]ear\n");
	printf( STDERR "\n" );
	printf( STDERR " * COMMON OPTION(AGGREGATION AND DAILY UPDATES)\n" );
	printf( STDERR "    -b, --before <n>    : The day before of the <n>th\n");
	printf( STDERR "    -d, --date <ymd>    : The date: e.g.) 2009/04/29 or 2009-12-23 \n");
	printf( STDERR "    -y, --yesterday     : Yesterday's log.\n");
	printf( STDERR "    -t, --today         : Today's log(default)\n");
	printf( STDERR "    -s, --summary       : Display descriptive statistics\n");
	printf( STDERR "\n" );
	printf( STDERR "\n" );
	printf( STDERR " * DATABASE SPEC OPTIONS(Overrides the value in config file)\n" );
	printf( STDERR "    --type <d>          : DB Type, p:Postgres, m:MySQL, s=SQLite .\n");
	printf( STDERR "    --host <hostname>   : DB Host name or IP address.\n");
	printf( STDERR "    --port <portnum>    : DB Host port number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * OTHER OPTIONS\n" );
	printf( STDERR "    -C, --conf <config> : Location of the configuration file used instead of \n");
	printf( STDERR "                          __KANADZUCHIETC__/bouncehammer.cf .\n");
	printf( STDERR "    -T, --test          : Test mode, same as ``-C /path/to/test-run.cf''\n");
	printf( STDERR "    -F, --format <char> : Output(STDOUT only) format, the followings are available.\n");
	printf( STDERR "                          [y]aml, [c]sv, [a]sciitable (Default)\n");
	printf( STDERR "    --silent            : Silent mode, All MESSAGES WILL NOT BE DISPLAYED.\n");
	printf( STDERR "    -v, --verbose       : Run in verbose mode, -vv is more verbose, -vvv is more.\n");
	printf( STDERR "    --help              : Print help message(This screen)\n");
	printf( STDERR "    --version           : Print version number.\n");
	printf( STDERR "\n" );
	printf( STDERR " * Examples\n" );
	printf( STDERR "  %s -D -At\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -ah __KANADZUCHIVAR__/log/hammer.2009-04-29.log\n", $Cmd->calledfrom() );
	printf( STDERR "  %s -U --totalsby year\n", $Cmd->calledfrom() );
	printf( STDERR "\n" );

	printf( STDERR "\n" );
	printf( STDERR " * FIELDS\n" );
	printf( STDERR "    estimated = Estimated number of bounces for the day = Inserted + Updated + Skipped / Executed\n" );
	printf( STDERR "    inserted  = The number of inserted records for each day by bin/databasectl command. \n" );
	printf( STDERR "    updated   = The number of updated records for each day by the command. \n" );
	printf( STDERR "    skipped   = The number of skipped(for inserting, updating) records for each day. \n" );
	printf( STDERR "    failed    = The number of failed(for inserting, updating) records for each day. \n" );
	printf( STDERR "    executed  = The number of times for execution of the command.\n" );
	printf( STDERR "    modified  = Last modified date of each record.\n" );
	printf( STDERR "\n" );

	return(1);
}


__END__
