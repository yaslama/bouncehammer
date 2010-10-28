# $Id: BdDR.pm,v 1.5 2010/10/28 07:12:49 ak Exp $
# -Id: RDB.pm,v 1.9 2010/03/04 08:31:40 ak Exp -
# -Id: Database.pm,v 1.2 2009/08/29 19:01:14 ak Exp -
# -Id: Database.pm,v 1.7 2009/08/13 07:13:28 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                              
 #####      ## ####   #####   
 ##  ##     ## ## ##  ##  ##  
 #####   ##### ##  ## ##  ##  
 ##  ## ##  ## ##  ## #####   
 ##  ## ##  ## ## ##  ## ##   
 #####   ##### ####   ##  ##  
package Kanadzuchi::BdDR;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use DBI;
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'dbname',	# (String) Database Name
	'dbtype',	# (String) Database Type
	'hostname',	# (String) Database Host
	'port',		# (String) Database Port or Socket
	'username',	# (String) Database User
	'password',	# (String) Database Password
	'datasn',	# (String) Data Source Name
	'handle',	# (DBI::db) Database Handle
	'error',	# (Ref->Hash) Error Information
	'autocommit',	# (Integer) AutoCommit for DBI
	'raiseerror',	# (Integer) RaiseError for DBI
	'printerror',	# (Integer) PrintError for DBI
);

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
my $DBs = [ qw(postgresql mysql sqlite) ];
my $DBI = {
	'postgresql' => {
		'dbtype' => 'PostgreSQL',
		'dbport' => 5432,
		'driver' => 'Pg',
		'dbname' => 'dbname',
		'socket' => 'host',
	},
	'mysql' => {
		'dbtype' => 'MySQL',
		'dbport' => 3306,
		'driver' => 'mysql',
		'dbname' => 'database',
		'socket' => 'mysql_socket',
	},
	'sqlite' => {
		'dbtype' => 'SQLite',
		'dbport' => q(),
		'driver' => 'SQLite',
		'dbname' => 'dbname',
		'socket' => q(),
	},
};

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
	# @Param	<None>
	# @Return	Kanadzuchi::Database Object
	my $class = shift();
	my $argvs = { @_ };

	$argvs->{'error'} = { 'string' => q(), 'count' => 0 };
	$argvs->{'autocommit'} = 1;
	$argvs->{'raiseerror'} = 1;
	$argvs->{'printerror'} = 0;
	return $class->SUPER::new($argvs);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub setup
{
	# +-+-+-+-+-+
	# |s|e|t|u|p|
	# +-+-+-+-+-+
	#
	# @Description	Setting up connection information
	# @Param <ref>	(ref->Kanadzuchi) config->{database}
	# @Return	(Kanadzuchi::BdDR) This object
	my $self = shift();
	my $conf = shift() || return $self;

	if( ref($conf) eq q|HASH| )
	{
		$self->{'dbtype'}   ||= lc $conf->{'dbtype'} || $DBI->{'sqlite'}->{'dbtype'};
		$self->{'dbname'}   ||= $conf->{'dbname'} || q(:memory:);
		$self->{'hostname'} ||= $conf->{'hostname'} || 'localhost';
		$self->{'port'}     ||= $conf->{'port'} || q();
		$self->{'username'} ||= $conf->{'username'} || q();
		$self->{'password'} ||= $conf->{'password'} || q();

		my $dbtype = lc $self->{'dbtype'};
		my $dbhost = $self->{'hostname'};
		my $whatdb = ( $dbtype =~ m{(?>(?:postgre(?>(?:s|sql))|pgsql))} ) ? 'postgresql' : lc $dbtype;
		my $dbport = $self->{'port'} || ( ( $dbhost ne 'localhost' ) ? $DBI->{ $whatdb }->{'dbport'} : q() );
		my $datasn = q();

		# Unsupported database
		return $self unless( grep { $dbtype eq $_ } @$DBs );

		if( $whatdb eq 'sqlite' )
		{
			$datasn = q|dbi:SQLite:dbname=|.$self->{'dbname'};
			$self->{'username'} = q();
			$self->{'password'} = q();
			$self->{'hostname'} = q();
			$self->{'port'} = q();
		}
		else
		{
			if( $dbhost eq 'localhost' )
			{
				# Use UNIX domain socket
				#  Postgresql: dbi:Pg:dbname=name;host=/path/to/socket/dir;"
				#  MySQL: dbi:mysql:database=name;mysql_socket=/path/to/socket;
				#
				$datasn = sprintf( "dbi:%s:%s=%s;%s=%s", $DBI->{ $whatdb }->{'driver'},
						$DBI->{ $whatdb }->{'dbname'}, $self->{'dbname'},
						$DBI->{ $whatdb }->{'socket'}, $dbport );
				$self->{'port'} = q();
				$self->{'hostname'} = 'localhost';
			}
			else
			{
				# Use TCP/IP connection
				$dbport = $DBI->{ $whatdb }->{'dbport'} unless( $dbport =~ m{\A\d+\z} );
				$datasn = sprintf( "dbi:%s:%s=%s;host=%s;port=%d", 
						$DBI->{ $whatdb }->{'driver'},
						$DBI->{ $whatdb }->{'dbname'}, $self->{'dbname'}, 
						$dbhost, $dbport );
				$self->{'port'} = $dbport;
			}
		}

		$self->{'dbtype'} = $DBI->{ $whatdb }->{'dbtype'};
		$self->{'datasn'} = $datasn;
	}

	return $self;
}

sub connect
{
	# +-+-+-+-+-+-+-+
	# |c|o|n|n|e|c|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Connect to the database
	# @Param 	<None>
	# @Return	(DBI::db) Database handle
	#		(undef) Failed to connect
	my $self = shift();
	my $dsnx = $self->{'datasn'} || return undef();
	my $dopt = {};

	eval { 
		$dopt = {
			'AutoCommit' => $self->{'autocommit'},
			'RaiseError' => $self->{'raiseerror'},
			'PrintError' => $self->{'printerror'},
		};

		$self->{'handle'} = DBI->connect( 
			$dsnx, $self->{'username'}, $self->{'password'}, $dopt );
	};
	return( $self->{'handle'} ) unless $@;

	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return undef();
}

sub disconnect
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |d|i|s|c|o|n|n|e|c|t|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Disconnect
	# @Param 	<None>
	# @Return	(Integer) 1 = Successfully disconnected
	#		(Integer) 0 = Failed to disconnect
	my $self = shift();
	my $dbhx = $self->{'handle'} || return(0);

	eval { 
		$dbhx->disconnect();
		$self->{'handle'} = undef();
	};

	return(1) unless $@;
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub DESTROY
{
	# +-+-+-+-+-+-+-+
	# |D|E|S|T|R|O|Y|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Destoractor
	# @Param 	<None>
	# @Return	(Integer) 1
	my $self = shift();
	return $self->disconnect();
}

1;
__END__
