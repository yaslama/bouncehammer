# $Id: DBI.pm,v 1.2 2010/08/16 12:01:16 ak Exp $
package Kanadzuchi::Test::DBI;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;

sub buildtable
{
	my $class = shift();
	my $dbhdl = shift() || return(0);
	my $dbhst = 0;
	my $sqlst = q();
	my $files = [
		'./src/sql/SQLite.sql',
		'./src/sql/SQLite-dailyupdates.sql',
		'./src/sql/mastertable-hostgroups.sql',
		'./src/sql/mastertable-providers.sql',
		'./src/sql/mastertable-reasons.sql',
		'./src/sql/records-example.sql',
		'./src/sql/more-example-senderdomains.sql' ];

	foreach my $_sqlf ( @$files )
	{
		my $_sqlhandle = undef();
		my $_statement = q();

		open( $_sqlhandle, q{<}, $_sqlf );
		while( my $_line = <$_sqlhandle> )
		{
			next() if( $_line =~ m{^-} || $_line =~ m{^$} );
			$_line =~ s{\t}{ }g;
			$_line =~ s{[\n\r]}{}g;
			$_statement .= $_line;

			next() unless( $_line =~ m{;} );
			$dbhst += $dbhdl->do( $_statement );
			$_statement = q();
		}
		$_sqlhandle->close();
	}
	return($dbhst);
}

sub flushtable
{
	my $class = shift();
	my $dbhdl = shift() || return(0);
	my $table = shift() || return(0);

	$dbhdl->do( q{DELETE FROM }.$table );
	return(1);
}

1;
__END__
