# $Id: BounceLogs.pm,v 1.12 2010/07/26 08:11:43 ak Exp $
# -Id: BounceLogs.pm,v 1.9 2010/03/04 08:33:28 ak Exp -
# -Id: BounceLogs.pm,v 1.1 2009/08/29 08:58:48 ak Exp -
# -Id: BounceLogs.pm,v 1.6 2009/08/27 05:09:55 ak Exp -
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::BdDR::
                                                                     
 #####                                   ##                          
 ##  ##  ####  ##  ## #####   #### ####  ##     ####   #####  #####  
 #####  ##  ## ##  ## ##  ## ##   ##  ## ##    ##  ## ##  ## ##      
 ##  ## ##  ## ##  ## ##  ## ##   ###### ##    ##  ## ##  ##  ####   
 ##  ## ##  ## ##  ## ##  ## ##   ##     ##    ##  ##  #####     ##  
 #####   ####   ##### ##  ##  #### ####  ###### ####      ## #####   
                                                      #####          
package Kanadzuchi::BdDR::BounceLogs;
use DBIx::Skinny;
1;

  #####        ##                           
 ###      #### ##      ####  ##  ##  ####   
  ###    ##    #####  ##  ## ######     ##  
   ###   ##    ##  ## ###### ######  #####  
    ###  ##    ##  ## ##     ##  ## ##  ##  
 #####    #### ##  ##  ####  ##  ##  #####  
package Kanadzuchi::BdDR::BounceLogs::Schema;
use DBIx::Skinny::Schema;
use Kanadzuchi::Mail;
use Time::Piece;

install_utf8_columns('description');
install_inflate_rule( 
		'^(bounced|updated)$' => callback {
			inflate { return( Time::Piece->new(shift()) ) };
			deflate { return( shift()->epoch()) };
		}
	);
install_inflate_rule( 
		'hostgroup' => callback {
			inflate { return( Kanadzuchi::Mail->id2gname(shift()) ) };
			deflate { return( Kanadzuchi::Mail->gname2id(shift()) ) };
		}
	);
install_inflate_rule( 
		'reason' => callback {
			inflate { return( Kanadzuchi::Mail->id2rname(shift()) ) };
			deflate { return( Kanadzuchi::Mail->rname2id(shift()) ) };
		}
	);

install_table( 't_bouncelogs' => schema { 
			pk('id');
			columns( join( ',', qw{
					id addresser recipient senderdomain destination
					token frequency bounced updated hostgroup 
					provider reason description disabled } )
			); 
		}
	);

1;

 ######         ##    ###          
   ##     ####  ##     ##   ####   
   ##        ## #####  ##  ##  ##  
   ##     ##### ##  ## ##  ######  
   ##    ##  ## ##  ## ##  ##      
   ##     ##### ##### ####  ####   
package Kanadzuchi::BdDR::BounceLogs::Table;
use strict;
use warnings;
use base 'Class::Accessor::Fast::XS';
use Kanadzuchi::BdDR::BounceLogs::Masters;
use Kanadzuchi::BdDR::Page;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_ro_accessors(
	'table',		# (String) Table name
	'alias',		# (String) Table alias
	'fields'		# (Ref->Array) Column names
);
__PACKAGE__->mk_accessors(
	'object',		# (K::BdDR::BounceLogs::Table)
	'handle',		# (DBI::db) Database handle
	'error'			# (Ref->Hash) Latest Error information
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
	# @Return	(K::BdDR::BounceLogs::Table) Object
	my $class = shift();
	my $argvs = { @_ };
	my $klass = q|Kanadzuchi::BdDR::BounceLogs|;

	$argvs->{'table'} = 't_bouncelogs';
	$argvs->{'alias'} = 'BounceLogs';
	$argvs->{'error'} = { 'string' => q(), 'count' => 0 };
	$argvs->{'fields'} = {
		'join' => [ qw(addresser senderdomain destination provider) ],
		'desc' => [ qw(timezoneoffset diagnosticcode deliverystatus) ],
		'trxn' => [ qw(id recipient token frequency bounced updated
				hostgroup reason description disabled) ],
	};
	$argvs->{'object'} = $argvs->{'handle'}
				? $klass->new( { 'dbh' => $argvs->{'handle'} } )
				: undef();
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
	my $anid = shift() || return(0);

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
	my $acol = shift() || return(0);
	my $cols = $self->{'fields'};

	return(1) if( grep { $acol eq $_ } @{ $cols->{'trxn'} } );
	return(1) if( grep { $acol eq $_ } @{ $cols->{'join'} } );
	return(0);
}

sub search
{
	#+-+-+-+-+-+-+
	#|s|e|a|r|c|h|
	#+-+-+-+-+-+-+
	#
	# @Description	new() by SELECT * FROM t_bouncelogs WHERE '?' = '?'
	# @Param <ref>	(Ref->Hash) Where Condition
	# @Param <obj>	(Kanadzuchi::BdDR::Page) Pagination object
	# @Param <flg>	(Integer) Flag, 1=Count only
	# @Return	(Ref->Array) Hash references
	my $self = shift();
	my $cond = shift() || {};
	my $page = shift() || new Kanadzuchi::BdDR::Page;
	my $cflg = shift() || 0;

	my $data = [];		# (Ref->Array) Kanadzuchi::Mail::Stored or hash
	my $rset = undef();	# (DBIx::Skinny::SQL) ->resultset()
	my $mtab = undef();	# (Kanadzuchi::BdDR::BounceLogs::Masters)
	my $tobj = $self->{'object'};

	my $iterator = undef();	# (Kanadzuchi::Iterator)
	my $nrecords = 0;	# (Integer) The number of records in the database
	my $wherecnd = {};	# (Ref->Hash) WHERE Condition for sending query
	my $mtobject = {};	# (Ref->Hash) Mastertable objects
	my $rssetopt = {};	# (Ref->Hash) Options for Resultset
	my $joincols = $self->{'fields'}->{'join'};
	my $trxncols = $self->{'fields'}->{'trxn'};
	my $desccols = $self->{'fields'}->{'desc'};

	eval {
		# Build Resultset object, and set the limit, and the order.
		if( $cflg )
		{
			# SELECT count(token) AS x FROM ...
			$rssetopt = { 'select' => [ 'COUNT(token) AS x' ] };
		}
		else
		{
			# SELECT ... FROM
			$rssetopt = {
				'limit' => $page->resultsperpage(),
				'offset' => $page->offsetposition(),
				'select' => [ map { $self->{'table'}.'.'.$_ } @$trxncols ],
				'order' => { 
					'desc' => $page->descendorderby ? 'DESC' : q(),
					'column' => $page->colnameorderby =~ m{\A(?:id|disabled|description)\z}
							? $self->{'table'}.'.'.$page->colnameorderby()
							: $page->colnameorderby()
				},
			};
		}
		$rset = $tobj->resultset( $rssetopt );

		# Mastertable objects for INNER JOIN
		$mtobject = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables( $tobj->dbh() );

		INNER_JOIN: foreach my $_c ( @$joincols )
		{
			$mtab = $mtobject->{ $_c.'s' };
			$rset->add_select( $mtab->table().'.'.$mtab->field() => $_c ) if( $cflg == 0 );
			$rset->add_join( $self->{'table'} => [ { 
						'type' => 'inner',
						'table' => $mtab->table(),
						'condition' => sprintf("%s.%s = %s.id", $self->{'table'}, $_c, $mtab->table() ),
					} ] );
		}

		# Where Condition
		COLUMNS_IN_TXNTABLE: foreach my $_c ( @$trxncols )
		{
			next() unless( defined($cond->{$_c}) );

			if( $_c eq 'hostgroup' )
			{
				$wherecnd->{$_c} = Kanadzuchi::Mail->gname2id($cond->{$_c}) unless $cond->{$_c} =~ m{\A\d+\z};
			}
			elsif( $_c eq 'reason' )
			{
				$wherecnd->{$_c} = Kanadzuchi::Mail->rname2id($cond->{$_c}) unless $cond->{$_c} =~ m{\A\d+\z};
			}
			elsif( $_c eq 'bounced' || $_c eq 'updated' || $_c eq 'frequency' )
			{
				$wherecnd->{$_c} = $cond->{$_c};
			}
			else
			{
				$wherecnd->{$_c} = lc($cond->{$_c});
			}
			$rset->add_where( $self->{'table'}.'.'.$_c => $wherecnd->{$_c} );
		}

		COLUMNS_IN_MASTERTABLE: foreach my $_c ( @$joincols )
		{
			next() unless defined($cond->{$_c});
			$mtab = $mtobject->{ $_c.'s' };
			$rset->add_where( $mtab->table().'.'.$mtab->field() => lc($cond->{$_c}) );
		}

		# Send the query and retrieve the results
		$iterator = $rset->retrieve();

		if( $cflg )
		{
			$nrecords = $iterator->first->x();
		}
		else
		{
			RETRIEVE: while( my $_r = $iterator->next() )
			{
				my $__data = {
					'id'		=> $_r->id(),
					'addresser'	=> $_r->addresser(),
					'recipient'	=> $_r->recipient(),
					'frequency'	=> $_r->frequency(),
					'senderdomain'	=> $_r->senderdomain(),
					'token'		=> $_r->token(),
					'destination'	=> $_r->destination(),
					'provider'	=> $_r->provider(),
					'hostgroup'	=> $_r->hostgroup(),
					'reason'	=> $_r->reason(),
					'bounced'	=> $_r->bounced(),
					'updated'	=> $_r->updated(),
					'disabled'	=> $_r->disabled(),
					'description'	=> shift @{ Kanadzuchi::Metadata->to_object(\$_r->description()) },
				};

				map { $__data->{$_} = $__data->{'description'}->{$_} } @$desccols;
				push( @$data, $__data );
			}
		}
	};

	if( $@ )
	{
		$self->{'error'}->{'string'} = $@; 
		$self->{'error'}->{'count'}++;
	}
	return $nrecords if $cflg;
	return $data;
}

sub groupby
{
	# +-+-+-+-+-+-+-+
	# |g|r|o|u|p|b|y|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Aggregate by specified column
	# @Param <str>	(String) Column name
	# @Return	(Ref->Array) Aggregated data
	my $self = shift();
	my $name = shift() || return {};
	my $rset = undef();
	my $mtab = q();
	my $data = [];

	my $iterator = undef();
	my $xtobject = $self->{'object'};
	return [] unless( grep { $name eq $_ }
			( @{ $self->{'fields'}->{'join'} }, 'hostgroup', 'reason' ) );

	eval {
		if( $name eq 'hostgroup' || $name eq 'reason' )
		{
			my $_sqlx = 'SELECT '.$name.', ';
			$_sqlx .= 'COUNT(token) AS x, ';
			$_sqlx .= 'SUM(frequency) AS y ';
			$_sqlx .= 'FROM '.$self->{'table'}.' GROUP BY '.$name;

			$iterator = $xtobject->search_by_sql( $_sqlx );
		}
		else
		{
			my $_mtab = new Kanadzuchi::BdDR::BounceLogs::Masters::Table(
						'alias' => $name.'s', 'handle' => $self->{'handle'} );
			my $_ropt = {   'group' => { 'column' => $_mtab->table().'.'.$_mtab->field() },
					'select' => [ 
						'COUNT(token) AS x', 
						'SUM(frequency) AS y', 
					],
				};

			my $_rset = $xtobject->resultset( $_ropt );
			my $_cond = sprintf( "%s.%s = %s.id", $self->{'table'}, $name, $_mtab->table() );
			my $_join = { 'type' => 'inner', 'table' => $_mtab->table(), 'condition' => $_cond };

			$_rset->add_select( $_mtab->table().'.'.$_mtab->field() => $name );
			$_rset->add_join( $self->{'table'} => [ $_join ] );
			$iterator = $_rset->retrieve(); 
		}
	};

	if( $@ )
	{
		$self->{'error'}->{'string'} = $@;
		$self->{'error'}->{'count'}++;
		return [];
	}

	RETRIEVE: while( my $r = $iterator->next() )
	{
		push( @$data, { 'name' => $r->$name, 'size' => $r->x(), 'freq' => $r->y() } )
	}
	return $data;
}

sub size
{
	#+-+-+-+-+
	#|s|i|z|e|
	#+-+-+-+-+
	#
	# @Description	SELECT count(*) FROM t_bouncelogs;
	# @Param	<None>
	# @Return	(Integer) The number of records
	my $self = shift();
	my $size = 0;

	eval{ $size = $self->search( {}, Kanadzuchi::BdDR::Page->new(), 1 ) };
	return $size unless $@;

	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub count
{
	#+-+-+-+-+-+
	#|c|o|u|n|t|
	#+-+-+-+-+-+
	#
	# @Description	SELECT count(*) FROM t_bouncelogs WHERE '?' = '?'
	# @Param <ref>	(Ref->Hash) Where Condition
	# @Param <obj>	(Kanadzuchi::BdDR::Page) Pagination object
	# @Return	(Integer) The number of records
	my $self = shift();
	my $cond = shift() || {};
	my $page = shift() || new Kanadzuchi::BdDR::Page;
	my $size = 0;

	eval{ $size = $self->search( $cond, $page, 1 ) };
	return $size unless $@;

	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);
}

sub insert
{
	# +-+-+-+-+-+-+
	# |i|n|s|e|r|t|
	# +-+-+-+-+-+-+
	#
	# @Description	INSERT the rocord
	# @Param <ref>	(Ref->Hash) New data
	# @Returns	(Integer) n = The ID of inserted object
	#		(Integer) 0 = Failed to INSERT
	my $self = shift();
	my $data = shift() || return(0);
	my $that = undef();
	my $nuid = 0;

	eval {
		$that = $self->{'object'}->insert( $self->{'table'}, $data );
		$nuid = $that->get_column('id') if( defined($that) );
	};
	return $nuid unless $@;
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
	# @Description	Update the rocord
	# @Param <ref>	(Ref->Hash) New data
	# @Param <ref>	(Ref->Hash) Where Condition
	# @Returns	(Integer) 1 = Successfully updated
	#		(Integer) 0 = Failed to UPDATE
	my $self = shift();
	my $data = shift() || return(0);
	my $cond = shift() || return(0);
	my $stat = 0;

	return(0) if( ! $self->is_validid($cond->{'id'}) && ! $cond->{'token'} );
	eval {
		$stat = $self->{'object'}->update( $self->{'table'}, $data, $cond );
	};
	return $stat unless $@;
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
	my $cond = shift() || return(0);
	my $stat = 0;

	return(0) if( ! $self->is_validid($cond->{'id'}) && ! $cond->{'token'} );
	eval {
		$stat = $self->{'object'}->delete( $self->{'table'}, $cond );
	};
	return $stat unless $@;
	$self->{'error'}->{'string'} = $@;
	$self->{'error'}->{'count'}++;
	return(0);

}

sub disable
{
	# +-+-+-+-+-+-+-+
	# |d|i|s|a|b|l|e|
	# +-+-+-+-+-+-+-+
	#
	# @Description	Disable the rocord
	# @Param <ref>	(Ref->Hash) Where Condition
	# @Returns	(Integer) 1 = Successfully disabled the record
	#		(Integer) 0 = Failed to UPDATE
	my $self = shift();
	my $cond = shift() || return(0);
	return(0) if( ! $self->is_validid($cond->{'id'}) && ! $cond->{'token'} );
	return $self->update( { 'disabled' => 1 }, $cond );
}

1;
__END__
