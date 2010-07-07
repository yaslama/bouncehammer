# $Id: Masters.pm,v 1.11 2010/07/07 01:06:24 ak Exp $
# -Id: Addressers.pm,v 1.4 2010/03/04 08:33:28 ak Exp -
# -Id: Addressers.pm,v 1.4 2010/02/21 20:42:02 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::BdDR::BounceLogs::
                                                   
 ##  ##                  ##                        
 ######   ####   ##### ###### ####  #####   #####  
 ######      ## ##       ##  ##  ## ##  ## ##      
 ##  ##   #####  ####    ##  ###### ##      ####   
 ##  ##  ##  ##     ##   ##  ##     ##         ##  
 ##  ##   ##### #####     ### ####  ##     #####   
package Kanadzuchi::BdDR::BounceLogs::Masters;
use DBIx::Skinny;
1;
                                         
  #####        ##                           
 ###      #### ##      ####  ##  ##  ####   
  ###    ##    #####  ##  ## ######     ##  
   ###   ##    ##  ## ###### ######  #####  
    ###  ##    ##  ## ##     ##  ## ##  ##  
 #####    #### ##  ##  ####  ##  ##  #####  
package Kanadzuchi::BdDR::BounceLogs::Masters::Schema;
use DBIx::Skinny::Schema;

# UTF-8 Columns
install_utf8_columns('description');

# Addressers
install_table( 't_addressers' => schema { 
			pk('id');
			columns( join(',',qw{id email description disabled}) );
		} );

# SenderDomains
install_table( 't_senderdomains' => schema { 
			pk('id');
			columns( join(',',qw{id domainname description disabled}) );
		} );

# Destinations
install_table( 't_destinations' => schema { 
			pk('id');
			columns( join(',',qw{id domainname description disabled}) );
		} );

# HostGroups
install_table( 't_hostgroups' => schema { 
			pk('id');
			columns( join(',',qw{id name description disabled}) );
		} );

# Providers
install_table( 't_providers' => schema { 
			pk('id');
			columns( join(',',qw{id name description disabled}) );
		} );

# Reasons
install_table( 't_reasons' => schema { 
			pk('id');
			columns( join(',',qw{id why description disabled}) );
		} );

1;

 ######         ##    ###          
   ##     ####  ##     ##   ####   
   ##        ## #####  ##  ##  ##  
   ##     ##### ##  ## ##  ######  
   ##    ##  ## ##  ## ##  ##      
   ##     ##### ##### ####  ####   
package Kanadzuchi::BdDR::BounceLogs::Masters::Table;
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Kanadzuchi::BdDR::Page;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_ro_accessors( 
	'table',	# (String) Table name
	'alias',	# (String) Alias of the table name
	'field'		# (String) Column name
);
__PACKAGE__->mk_accessors(
	'object',	# (K::BdDR::BounceLogs::Masters)
	'handle',	# (DBI::db) Database handle
	'error'		# (String) Latest error information
);

#  ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||C |||l |||a |||s |||s |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub whichtable
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |w|h|i|c|h|t|a|b|l|e|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Which table should I use?
	# @Param <str>	(String) Table alias or symbol character
	# @Return	(String) MasterTable class name
	my $class = shift();
	my $alias = lc(shift()) || return undef();
	my $klass = q();

	if( $alias eq 'addressers' || $alias eq 'a' )
	{
		$klass = 'Addressers';
	}
	elsif( $alias eq 'senderdomains' || $alias eq 's' )
	{
		$klass = 'SenderDomains';
	}
	elsif( $alias eq 'reasons' || $alias eq 'w' || $alias eq 'r' )
	{
		$klass = 'Reasons';
	}
	elsif( $alias eq 'destinations' || $alias eq 'd' )
	{
		$klass = 'Destinations';
	}
	elsif( $alias eq 'hostgroups' || $alias eq 'h' )
	{
		$klass = 'HostGroups';
	}
	elsif( $alias eq 'providers' || $alias eq 'p' )
	{
		$klass = 'Providers';
	}

	return $klass;
}

sub mastertables
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |m|a|s|t|e|r|t|a|b|l|e|s|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Wrapper method of new()s
	# @Param <obj>	(DBI::db) Database handle
	# @Param <ref>	(Ref->Array) Mastertable names to new()
	# @Return	(Ref->Hash) K::BdDR::BounceLogs::Masters::Table Objects
	my $class = shift();
	my $mtdbh = shift() || return {};
	my $mtabs = shift() || [];
	my $alias = [ 'addressers', 'senderdomains', 'destinations',
			'hostgroups', 'providers', 'reasons' ];
	$mtabs = $alias unless( scalar(@$mtabs) );
	return({ map { $_ => $class->new( 'alias' => $_, 'handle' => $mtdbh ) } @$mtabs });
}

sub new
{
	# +-+-+-+
	# |n|e|w|
	# +-+-+-+
	#
	# @Description	Wrapper method of new()
	# @Param <str>	(Ref->Hash) Arguments
	# @Return	(K::BdDR::BounceLogs::Masters) Object
	my $class = shift();
	my $argvs = { @_ };
	my $tfmap = {
		'Addressers'	=> { 'table' => 't_addressers', 'field' => 'email' },
		'SenderDomains' => { 'table' => 't_senderdomains', 'field' => 'domainname' },
		'Destinations'	=> { 'table' => 't_destinations', 'field' => 'domainname' },
		'HostGroups'	=> { 'table' => 't_hostgroups', 'field' => 'name' },
		'Providers'	=> { 'table' => 't_providers', 'field' => 'name' },
		'Reasons'	=> { 'table' => 't_reasons', 'field' => 'why' },
	};
	my $klass = q|Kanadzuchi::BdDR::BounceLogs::Masters|;

	# Check table alias
	my $alias = $class->whichtable($argvs->{'alias'});
	return(undef()) unless( $alias );

	foreach my $t ( keys(%$tfmap) )
	{
		next() unless( $t eq $alias );

		$argvs->{'alias'} = $alias;
		$argvs->{'table'} = $tfmap->{ $t }->{'table'};
		$argvs->{'field'} = $tfmap->{ $t }->{'field'};
		$argvs->{'error'} = { 'string' => q(), 'count' => 0 };
		$argvs->{'object'} = $klass->new( {'dbh' => $argvs->{'handle'} });
		last();
	}

	return $class->SUPER::new($argvs);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub is_validid
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|v|a|l|i|d|i|d|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Database ID validation
	# @Param	<None>
	# @Return	(Integer) 1 = Is valid ID
	#		(Integer) 0 = Is not
	my $self = shift();
	my $anid = shift() || $self->{'id'};

	return(0) unless( defined($anid) );
	return(0) unless( $anid );
	return(0) unless( $anid =~ m{\A\d+\z} );
	return(1);
}

sub is_validcolumn
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |i|s|_|v|a|l|i|d|c|o|l|u|m|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Column name validation
	# @Param <str>	(String) Column name
	# @Return	(Integer) 1 = Is valid column name
	#		(Integer) 0 = Is not
	my $self = shift();
	my $colm = shift() || return(0);

	return(1) if( $colm eq $self->{'field'} || $colm eq 'id' );
	return(1) if( $colm eq 'description' || $colm eq 'disabled' );
	return(0);
}

sub count
{
	# +-+-+-+-+-+
	# |c|o|u|n|t|
	# +-+-+-+-+-+
	#
	# @Description	Count the number of records in mastertable
	# @Param <ref>	(Ref->Hash) Where Conditions
	# @Return	(Integer) n = The number of records
	#		undef       = Failed to connect
	my $self = shift();
	my $cond = shift() || {};
	my $nofr = 0;

	eval {
		# Set column name, other condition, and send query
		my $_cond = {};
		map { $_cond->{$_} = $cond->{$_} if( defined($cond->{$_}) ) } (qw{id disabled description});
		$_cond->{ $self->{'field'} } = $cond->{'name'} if( defined($cond->{'name'}) );
		$nofr = $self->{'object'}->count( $self->{'table'}, 'id', $_cond );
	};
	return( $nofr ) unless( $@ );

	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub getidbyname
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|i|d|b|y|n|a|m|e|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get ID by the name
	# @Param <str>	(String) name
	# @Return	(Integer) 0 = Failed
	#		(Integer) n = The ID
	my $self = shift();
	my $name = shift() || return(0);
	my $anid = 0;

	eval {
		my $_tobj = $self->{'object'};
		my $_tsql = sprintf( "SELECT id FROM %s WHERE %s = :name", $self->{'table'}, $self->{'field'} );
		my $_iter = $_tobj->search_named( $_tsql, { 'name' => $name } );
		my $_row1 = defined($_iter) ? $_iter->first() : undef();
		$anid = defined($_row1) ? $_row1->get_column('id') : 0;
	};

	return( $anid ) unless($@);
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub getnamebyid
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|n|a|m|e|b|y|i|d|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get name by the ID 
	# @Param <id>	(Integer) ID
	# @Return	(String) '' = Failed or not found
	#		(String) value of 'name' field
	my $self = shift();
	my $anid = shift() || return(q{});
	my $name = q();

	return(q{}) unless( $self->is_validid($anid) );
	eval {
		my $_tobj = $self->{'object'};
		my $_tsql = sprintf( "SELECT %s FROM %s WHERE id = :id", $self->{'field'}, $self->{'table'} );
		my $_iter = $_tobj->search_named( $_tsql, { 'id' => $anid } );
		my $_row1 = defined($_iter) ? $_iter->first() : undef();
		$name = defined($_row1) ? $_row1->get_column($self->{'field'}) : q();
	};
	return( $name ) unless($@);
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return( q{} );
}

sub getentbyid
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|e|n|t|b|y|i|d|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get a entry by the ID 
	# @Param <id>	(Integer) ID
	# @Return	(Ref->Hash) Entity
	my $self = shift();
	my $anid = shift() || return({});
	my $trow = {};

	return({}) unless( $self->is_validid($anid) );

	eval {
		my $_tobj = $self->{'object'};
		my $_tcol = $self->{'field'};
		my $_that = $_tobj->single( $self->{'table'}, { 'id' => $anid } );

		if( defined($_that) )
		{
			$trow = { 'id' => $_that->id(),
				  'name' => $_that->$_tcol,
				  'disabled' => $_that->disabled(),
				  'description' => $_that->description() || q() };
		}
	};

	return($trow) unless($@);
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return({});
}

sub search
{
	# +-+-+-+-+-+-+
	# |s|e|a|r|c|h|
	# +-+-+-+-+-+-+
	#
	# @Description	SELECT FROM...
	# @Param <ref>	(Ref->Hash) WHERE condition
	# @Param <obj>	(Kanadzuchi::BdDR::Page) Pagination object
	# @Return	(Ref->Array) records
	my $self = shift();
	my $cond = shift() || {};
	my $page = shift() || new Kanadzuchi::BdDR::Page();
	my $recs = [];

	return([]) unless( ref($cond) eq q|HASH| );
	return([]) unless( ref($page) eq q|Kanadzuchi::BdDR::Page| );

	eval {
		my $_qopt = $page->to_hashref();
		my $_tobj = $self->{'object'};
		my $_tcol = $self->{'field'};
		my $_that = undef();
		my $_cond = {};

		# Set column name, other condition, and send query
		map { $_cond->{$_} = $cond->{$_} if( defined($cond->{$_}) ) } (qw{id disabled description});
		$_cond->{ $self->{'field'} } = $cond->{'name'} if( defined($cond->{'name'}) );
		$_that = $_tobj->search( $self->{'table'}, $_cond, $_qopt );

		if( defined($_that) )
		{
			while( my $_e = $_that->next() )
			{
				push( @$recs, { 'id' => $_e->id(),
						'name' => $_e->$_tcol,
						'description' => $_e->description() || q(),
						'disabled' => $_e->disabled() || 0, } );
			}
		}
	};
	return($recs) unless($@);

	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return([]);
}

sub insert
{
	# +-+-+-+-+-+-+
	# |i|n|s|e|r|t|
	# +-+-+-+-+-+-+
	#
	# @Description	INSERT: create a new record
	# @Param <ref>	(Ref->Hash) New data
	# @Return	(Integer) 0 = Failed to create or parameter error
	#		(Integer) n = ID of Inserted record, Successfully created
	my $self = shift();
	my $data = shift() || {};
	my $nuid = 0;

	return(0) unless( ref($data) eq q|HASH| );
	return(0) unless( $data->{'name'} );
	return(0) if( $data->{'name'} =~ m{[\x00-\x1f\x7f]} );

	eval {
		my $_name = lc($data->{'name'});
		my $_tobj = $self->{'object'};
		my $_bool = ( exists($data->{'disabled'}) && $data->{'disabled'} ) ? 1 : 0,
		my $_that = $_tobj->find_or_insert( $self->{'table'}, {
					$self->{'field'} => $_name,
					'description' => $data->{'description'} || q(),
					'disabled' => $data->{'disabled'}, } );
		$nuid = defined($_that) ? $_that->id() : 0;
	};
	return($nuid) unless($@);

	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub update
{
	# +-+-+-+-+-+-+
	# |u|p|d|a|t|e|
	# +-+-+-+-+-+-+
	#
	# @Description	UPDATE: modify the record
	# @Param <ref>	(Ref->Hash) New data
	# @Param <ref>	(Ref->Hash) Where condition
	# @Return	(Integer) 0 = Failed to update or parameter error
	#		(Integer) n = ID, Successfully updated 
	my $self = shift();
	my $data = shift() || {};
	my $cond = shift() || {};
	my $stat = 0;

	return(0) if( ref($data) ne q|HASH| || ref($cond) ne q|HASH| );
	return(0) unless( $self->is_validid($cond->{'id'}) );

	eval {
		my $_new1 = {};
		my $_tobj = $self->{'object'};
		my $_bool = defined($data->{'disabled'}) && $data->{'disabled'} ? 1 : 0;

		$_new1->{ $self->{'field'} } = $data->{'name'} if( defined($data->{'name'}) );
		$_new1->{'description'} = $data->{'description'} if( defined($data->{'description'}) );
		$_new1->{'disabled'} = $data->{'disabled'} if( defined($data->{'disabled'}) );

		$stat = $_tobj->update( $self->{'table'}, $_new1, { 'id' => $cond->{'id'} } );
	};
	return($cond->{'id'}) if( $stat && ! $@ );
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub remove
{
	# +-+-+-+-+-+-+
	# |r|e|m|o|v|e|
	# +-+-+-+-+-+-+
	#
	# @Description	DELETE: remove the reocrd
	# @Param <ref>	(Ref->Hash) Where condition
	# @Return	(Integer) 0 = Failed to remove or parameter error
	#		(Integer) 1 = Successfully removed
	my $self = shift();
	my $cond = shift() || {};
	my $stat = 0;

	return(0) unless( ref($cond) eq q|HASH| );
	return(0) unless( $self->is_validid($cond->{'id'}) );
	eval {
		my $_tobj = $self->{'object'};
		my $_cond = { 'id' => $cond->{'id'} };

		$stat = $_tobj->delete( $self->{'table'}, $_cond );
	};
	return($cond->{'id'}) if( $stat && ! $@ );
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

1;
__END__
