# $Id: Table.pm,v 1.12 2010/03/04 08:33:25 ak Exp $
# -Id: Table.pm,v 1.1 2009/08/29 09:08:01 ak Exp -
# -Id: Table.pm,v 1.6 2009/05/29 08:22:21 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::RDB::
                                   
 ######         ##    ###          
   ##     ####  ##     ##   ####   
   ##        ## #####  ##  ##  ##  
   ##     ##### ##  ## ##  ######  
   ##    ##  ## ##  ## ##  ##      
   ##     ##### ##### ####  ####   
package Kanadzuchi::RDB::Table;

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
__PACKAGE__->mk_ro_accessors( 'table', 'field' );
__PACKAGE__->mk_accessors( 'id', 'name', 'description', 'disabled' );

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
	# @Return	(K::R::Table::*) Object
	my $class = shift();
	my $argvs = { @_, 'table' => $class };
	my $tfmap = {
		'Addressers'	=> 'email',
		'SenderDomains' => 'domainname',
		'Destinations'	=> 'domainname',
		'HostGroups'	=> 'name',
		'Providers'	=> 'name',
		'Reasons'	=> 'why', };

	# Set table name
	TABLE_NAME: {
		$argvs->{'table'} =~ s{(?>\AKanadzuchi::RDB::Table::)}{}x;
		$argvs->{'table'} =  q() if( $argvs->{'table'} eq q|Kanadzuchi::RDB::Table| );
		$argvs->{'field'} =  $tfmap->{$argvs->{'table'}} || q();
	}

	EMPTY_OR_ZEOR: {
		$argvs->{'id'} = 0 unless( defined($argvs->{'id'}) );
		$argvs->{'disabled'} = 0 unless( defined($argvs->{'disabled'}) );
		$argvs->{'name'} = q() unless( defined($argvs->{'name'}) );
		$argvs->{'description'} = q() unless( defined($argvs->{'description'}) );
	}

	return( $class->SUPER::new($argvs));
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub _is_validid
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |_|i|s|_|v|a|l|i|d|i|d|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Database ID validation
	# @Param	<None>
	# @Return	(Integer) 1 = Is valid ID
	#		(Integer) 0 = Is not
	my $self = shift();
	
	return(0) unless( defined($self->{'id'}) );
	return(0) unless( $self->{'id'} );
	return(0) unless( $self->{'id'} =~ m{\A\d+\z} );
	return(1);
}

sub _is_validcolumn
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |_|i|s|_|v|a|l|i|d|c|o|l|u|m|n|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
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

sub getidbyname
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|i|d|b|y|n|a|m|e|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get ID by the name
	# @Param <ref>	(K::RDB)
	# @Return	(Integer) 0 = Failed
	#		(Integer) n = The ID
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = 0;

	return(0) unless(defined($self->{'name'}));
	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		my $_cond = { $self->{'field'} => $self->{'name'} };
		$that = $_sock->search( $_cond )->first->id() || 0;
	};
	return($that);
}

sub getnamebyid
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|n|a|m|e|b|y|i|d|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get name by the ID 
	# @Param <ref>	(K::RDB)
	# @Return	(String) '' = Failed or not found
	#		(String) value of 'name' field
	my $self = shift();
	my $dobj = shift() || return(q{});
	my $name = q();

	return(q{}) unless( $self->_is_validid() );
	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		$name = $_sock->find( $self->{'id'} )->get_column( $self->{'field'} ) || q();
	};
	return($name);
}

sub getentbyid
{
	# +-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|e|n|t|b|y|i|d|
	# +-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get a entry by the ID 
	# @Param <ref>	(K::RDB)
	# @Return	(Ref->Hash) Entity
	my $self = shift();
	my $dobj = shift() || return({});
	my $that = undef();
	my $href = {};

	return({}) unless( $self->_is_validid() );
	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		$that = $_sock->find( $self->{'id'} ) || return(0);
		$href = {
			'id' => $self->{'id'},
			'name' => $that->get_column( $self->{'field'} ),
			'description' => $that->get_column('description'),
			'disabled' => $that->get_column('disabled'),
		};
	};
	return({}) if($@);
	return($href);
}

sub getthenextid
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |g|e|t|t|h|e|n|e|x|t|i|d|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get the next ID
	# @Param <ref>	(K::RDB)
	# @Return	(Integer) 0 = Missing argument
	#		(Integer) n = The next ID(max(id)+1)
	my $self = shift();
	my $dobj = shift() || return(0);
	my $next = 0;

	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		$next = $_sock->search->get_column('id')->max() || 0;
	};
	return( $next + 1 );
}

sub select
{
	# +-+-+-+-+-+-+
	# |s|e|l|e|c|t|
	# +-+-+-+-+-+-+
	#
	# @Description	Not Implemented
	# @Param <ref>	(K::RDB)
	# @Param <key>	(String) Sort order(column name)
	# @Return	(Arrayref) records
	my $self = shift();
	my $dobj = shift() || return([]);
	my $sort = shift() || q(id);
	my $rset = undef();	# K::R::S::Resultset
	my $aref = [];
	my $name = $self->{'field'};

	$sort = $self->_is_validcolumn($sort) ? $sort : q(id);
	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		my $_cond = {};
		my $_sort = { 'order_by' => $sort };
		$rset = $_sock->search( $_cond, $_sort );
	};
	return([]) if( $@ );

	while( my $_r = $rset->next() )
	{
		push( @$aref, {	'id' => $_r->id(),
				'name' => $_r->$name,
				'disabled' => $_r->disabled(),
				'description' => $_r->description(), } );
	}
	return($aref);
}

sub insert
{
	# +-+-+-+-+-+-+
	# |i|n|s|e|r|t|
	# +-+-+-+-+-+-+
	#
	# @Description	INSERT: create a new record
	# @Param <ref>	(K::RDB)
	# @Return	(Integer) 0 = Failed to create or parameter error
	#		(Integer) n = ID of Inserted record, Successfully created
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = undef();
	my $nuid = 0;
	my $bool = $self->{'disabled'} ? 1 : 0;

	return(0) if( $self->{'name'} =~ m{[\x00-\x1f\x7f]} );
	return(0) unless( $self->validation() );

	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		my $_data = {
			$self->{'field'} => $self->{'name'},
			'description' => $self->{'description'},
			'disabled' => $bool, };

		$that = $_sock->create( $_data );
		$nuid = $that->id();
	};

	return(0) if($@);
	return($nuid);
}

sub update
{
	# +-+-+-+-+-+-+
	# |u|p|d|a|t|e|
	# +-+-+-+-+-+-+
	#
	# @Description	UPDATE: modify the record
	# @Param <ref>	(K::RDB)
	# @Return	(Integer) 0 = Failed to update or parameter error
	#		(Integer) 1 = Successfully updated 
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = undef();
	my $bool = $self->{'disabled'} ? 1 : 0;

	return(0) unless( $self->_is_validid() );
	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		my $_cond = { 'id' => $self->{'id'} };
		my $_data = {
			$self->{'field'} => $self->{'name'}, 
			'description' => $self->{'description'},
			'disabled' => $bool, };

		$that = $_sock->search( $_cond )->update( $_data );
	};
	return(0) if($@);
	return($that);
}

sub remove
{
	# +-+-+-+-+-+-+
	# |r|e|m|o|v|e|
	# +-+-+-+-+-+-+
	#
	# @Description	DELETE: remove the reocrd
	# @Param <ref>	(K::RDB) object
	# @Return	(Integer) 0 = Failed to remove or parameter error
	#		(Integer) 1 = Successfully removed
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = undef();

	return(0) unless( $self->_is_validid() );
	eval {
		my $_sock = $dobj->handle->resultset( $self->{'table'} );
		my $_cond = { 'id' => $self->{'id'} };

		$that = $_sock->search( $_cond )->delete();
	};
	return(0) if($@);
	return(1);
}

1;
__END__
