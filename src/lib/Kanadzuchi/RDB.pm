# $Id: RDB.pm,v 1.9 2010/03/04 08:31:40 ak Exp $
# -Id: Database.pm,v 1.2 2009/08/29 19:01:14 ak Exp -
# -Id: Database.pm,v 1.7 2009/08/13 07:13:28 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                       
 #####  ####   #####   
 ##  ## ## ##  ##  ##  
 ##  ## ##  ## #####   
 #####  ##  ## ##  ##  
 ## ##  ## ##  ##  ##  
 ##  ## ####   #####   
package Kanadzuchi::RDB;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'records',	# (Ref->Array->K::Mail::*)
	'count',	# (Integer) The number of bounced messages
	'handle',	# (K::R::Schema) Database Handle
	'dbname',	# (String) Database Name
	'dbtype',	# (String) Database Type
	'hostname',	# (String) Database Host
	'port',		# (Integer) Database Port
	'username',	# (String) Database User
	'password',	# (String) Database Password
	'datasn',	# (String) Data Source Name
	'table',	# (String) Table name(H::Schema::*)
	'cache',	# (Hashref) Record cache
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
	# @Param	<None>
	# @Return	TheHammer::Log Object
	my $class = shift();
	my $argvs = { @_ };

	DEFAULT_VALUES: {
		$argvs->{'count'} = 0 unless( defined($argvs->{'count'}) );
		$argvs->{'records'} = [] unless( defined($argvs->{'records'}) );
		$argvs->{'cache'} = {} unless( defined($argvs->{'cache'}) );
	}
	return($class->SUPER::new($argvs));
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
	# @Return	(Integer) 0 = Failed to setup
	#		(Integer) 1 = Successfully 
	my $self = shift();
	my $conf = shift() || return(0);

	return(0) unless( ref($conf) eq q|HASH| );

	# Set values to Kanadzuchi::RDB object
	SET_VALUES: {
		foreach my $v ( 'hostname', 'port', 'dbtype' )
		{
			$self->{$v} = $conf->{$v} unless( defined($self->{$v}) );
		}

		$self->{'dbname'} = $conf->{'dbname'};
		$self->{'username'} = $conf->{'username'};
		$self->{'password'} = $conf->{'password'};
	}

	return(0) unless($self->{'dbname'});
	return(0) unless($self->{'dbtype'});

	MAKE_DSN: {
		my $ty = lc( $self->{'dbtype'} );
		my $ch = length($ty) == 1 ? substr( $ty, 0, 1 ) : q(x);
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
		elsif( $ty eq 'sybase' || $ch eq 'y' )
		{
			$dr = 'Sybase';
			$db = 'Sybase';
			$pt = $self->{'port'} || 4100;
		}
		else
		{
			# Unsupported database type
			return(0);
		}

		if( defined($self->{'hostname'}) && defined($pt) )
		{
			# Use TCP/IP connection
			$ds = sprintf( "dbi:%s:dbname=%s;host=%s;port=%s;",
					$dr, $self->{'dbname'}, $self->{'hostname'}, $pt );
		}
		else
		{
			# Use local socket
			$ds = sprintf( "dbi:%s:dbname=%s", $dr, $self->{'dbname'} );
		}

		$self->{'dbtype'} = $db;
		$self->{'datasn'} = $ds;
	}

	return(1);
}

sub makecache
{
	# +-+-+-+-+-+-+-+-+-+
	# |m|a|k|e|c|a|c|h|e|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Send query and save it to the cache
	# @Param <tab>	(String) Table name
	# @Param <col>	(String) Column name
	# @Return	(Integer) 0 = No such record
	#		(Integer) n = The number of records
	my $self = shift();
	my $ttab = shift() || return(0);
	my $tcol = shift() || return(0);

	# Return keys if the record exists in the cache
	return(keys(%{$self->{'cache'}->{$ttab}})) if(exists($self->{'cache'}->{$ttab}));

	my $_rs = $self->{'handle'}->resultset($ttab)->search( { 'disabled' => 0 } );
	my $_nr = 0;

	while( my $_cr = $_rs->next() )
	{
		$self->{'cache'}->{$ttab}->{$_cr->$tcol} = $_cr->id;
		$_nr++;
	}
	return($_nr);
}

1;
__END__
