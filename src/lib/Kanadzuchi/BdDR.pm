# $Id: BdDR.pm,v 1.3 2010/07/07 11:21:37 ak Exp $
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
	'port',		# (Integer) Database Port
	'username',	# (String) Database User
	'password',	# (String) Database Password
	'datasn',	# (String) Data Source Name
	'handle',	# (DBI::db) Database Handle
	'error',	# (Ref->Hash) Error Information
	'autocommit',	# (Integer) AutoCommit for DBI
	'raiseerror',	# (Integer) RaiseError for DBI
	'printerror',	# (Integer) PrintError for DBI
);

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
		# Set values to Kanadzuchi::BdDR object
		foreach my $v ( 'hostname', 'port', 'dbtype' )
		{
			$self->{$v} = $conf->{$v} unless defined($self->{$v});
		}

		$self->{'dbname'}   = $conf->{'dbname'} || ':memory:';
		$self->{'dbtype'} ||= 'SQLite';
		$self->{'username'} = $conf->{'username'} || undef();
		$self->{'password'} = $conf->{'password'} || undef();

		# Make the data source name
		my $ty = lc $self->{'dbtype'};
		my $ch = length($ty) == 1 ? substr( $ty, 0, 1 ) : 'x';
		my( $dr, $db, $ds, $pt );

		if( $ty =~ m{(?>(?:postgre(?>(?:s|sql))|pgsql))} || $ch eq 'p' )
		{
			$dr = 'Pg';
			$pt = $self->{'port'} || 5432;
			$db = 'PostgreSQL';
		}
		elsif( $ty eq 'mysql' || $ch eq 'm' )
		{
			$dr = 'mysql';
			$pt = $self->{'port'} || 3306;
			$db = 'MySQL';
		}
		elsif( $ty eq 'sqlite' || $ch eq 's' )
		{
			$dr = 'SQLite';
			$db = 'SQLite';
		}
		else
		{
			# Unsupported database type
			$self->{'dbname'} = q();
			$self->{'datasn'} = q();
			return $self;
		}

		if( defined($self->{'hostname'}) && defined($pt) )
		{
			# Use TCP/IP connection
			$ds = sprintf( "dbi:%s:dbname=%s;host=%s;port=%s;",
					$dr, $self->{'dbname'}, $self->{'hostname'}, $pt );
		}
		else
		{
			# Use UNIX Domain socket
			$ds = sprintf( "dbi:%s:dbname=%s", $dr, $self->{'dbname'} );
		}

		$self->{'dbtype'} = $db;
		$self->{'datasn'} = $ds;
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
