# $Id: DailyUpdates.pm,v 1.4 2010/10/05 11:16:31 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::BdDR::
                                                                                  
 ####           ##  ###         ##  ##             ##          ##                 
 ## ##  ####         ##  ##  ## ##  ##  #####      ##   #### ###### ####   #####  
 ##  ##    ##  ###   ##  ##  ## ##  ##  ##  ##  #####      ##  ##  ##  ## ##      
 ##  ## #####   ##   ##  ##  ## ##  ##  ##  ## ##  ##   #####  ##  ######  ####   
 ## ## ##  ##   ##   ##   ##### ##  ##  #####  ##  ##  ##  ##  ##  ##         ##  
 ####   #####  #### ####    ##   ####   ##      #####   #####   ### ####  #####   
                         ####           ##                                        
package Kanadzuchi::BdDR::DailyUpdates;
use DBIx::Skinny;
1;

  #####        ##                           
 ###      #### ##      ####  ##  ##  ####   
  ###    ##    #####  ##  ## ######     ##  
   ###   ##    ##  ## ###### ######  #####  
    ###  ##    ##  ## ##     ##  ## ##  ##  
 #####    #### ##  ##  ####  ##  ##  #####  
package Kanadzuchi::BdDR::DailyUpdates::Schema;
use DBIx::Skinny::Schema;
use Kanadzuchi::Mail;
use Time::Piece;

install_utf8_columns('description');
install_inflate_rule( 
		'^(thetime|modified)$' => callback {
			inflate { return( Time::Piece->new(shift()) ) };
			deflate { return( shift()->epoch()) };
		}
	);
install_table( 't_dailyupdates' => schema { 
			pk('id');
			columns( qw{ id thetime thedate inserted updated skipped
				failed executed modified description disabled} ); 
		}
	);

1;

 ######         ##    ###          
   ##     ####  ##     ##   ####   
   ##        ## #####  ##  ##  ##  
   ##     ##### ##  ## ##  ######  
   ##    ##  ## ##  ## ##  ##      
   ##     ##### ##### ####  ####   
package Kanadzuchi::BdDR::DailyUpdates::Table;
use strict;
use warnings;
use base 'Class::Accessor::Fast::XS';
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
	'object',		# (K::BdDR::DailyUpdates::Table)
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
	# @Return	(K::BdDR::DailyUpdates::Table) Object
	my $class = shift();
	my $argvs = { @_ };
	my $klass = q|Kanadzuchi::BdDR::DailyUpdates|;

	$argvs->{'table'} = 't_dailyupdates';
	$argvs->{'alias'} = 'DailyUpdates';
	$argvs->{'error'} = { 'string' => q(), 'count' => 0 };
	$argvs->{'fields'} = {
		'trxn' => [ qw(id thetime thedate inserted updated skipped
				failed executed modified description disabled) ],
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
	return(0);
}

sub search
{
	#+-+-+-+-+-+-+
	#|s|e|a|r|c|h|
	#+-+-+-+-+-+-+
	#
	# @Description	new() by SELECT * FROM t_dailyupdates WHERE '?' = '?'
	# @Param <ref>	(Ref->Hash) Where Condition
	# @Param <obj>	(Kanadzuchi::BdDR::Page) Pagination object
	# @Param <flg>	(Integer) Flag, 1=Count only
	# @Return	(Ref->Array) Hash references
	my $self = shift();
	my $cond = shift() || {};
	my $page = shift() || new Kanadzuchi::BdDR::Page;
	my $cflg = shift() || 0;
	my $rset = undef();	# (DBIx::Skinny::SQL) ->resultset()
	my $tobj = $self->{'object'};
	my $data = [];

	my $iterator = undef();	# (Kanadzuchi::Iterator)
	my $nrecords = 0;	# (Integer) The number of records in the database
	my $rssetopt = {};	# (Ref->Hash) Options for Resultset
	my $colnames = $self->{'fields'}->{'trxn'};

	eval {
		# Build Resultset object, and set the limit, and the order.
		if( $cflg )
		{
			# SELECT count(id) AS x FROM ...
			$rssetopt = { 'select' => [ 'COUNT(id) as x' ] };
		}
		else
		{
			# SELECT ... FROM
			$rssetopt = {
				'limit' => $page->resultsperpage(),
				'offset' => $page->offsetposition(),
				'select' => $colnames,
				'order' => { 
					'desc' => $page->descendorderby ? 'DESC' : q(),
					'column' => $page->colnameorderby(),
				},
			};
		}
		$rset = $tobj->resultset( $rssetopt );

		# FROM ...
		$rset->from( [ $self->{'table'} ] );

		# Where Condition
		foreach my $_c ( @$colnames )
		{
			next() unless( defined $cond->{$_c} );
			# $rset->add_where( $self->{'table'}.'.'.$_c => $cond->{$_c} );
			$rset->add_where( $_c => $cond->{$_c} );
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
				push( @$data, {
					'id'		=> $_r->id(),
					'thetime'	=> $_r->thetime(),
					'thedate'	=> $_r->thedate(),
					'inserted'	=> $_r->inserted(),
					'updated'	=> $_r->updated(),
					'skipped'	=> $_r->skipped(),
					'failed'	=> $_r->failed(),
					'executed'	=> $_r->executed(),
					'modified'	=> $_r->modified(),
					'description'	=> $_r->description(),
					'disabled'	=> $_r->disabled(), }
				);
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

sub size
{
	#+-+-+-+-+
	#|s|i|z|e|
	#+-+-+-+-+
	#
	# @Description	SELECT count(*) FROM t_dailyupdates;
	# @Param	<None>
	# @Return	(Integer) The number of records
	my $self = shift();
	my $size = 0;

	eval { $size = $self->search( {}, Kanadzuchi::BdDR::Page->new(), 1 ) };
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
	# @Description	SELECT count(*) FROM t_dailyupdates WHERE '?' = '?'
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

	return(0) if( ! defined $cond->{'thetime'} && ! defined $cond->{'thedate'} );
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

	return(0) unless( $self->is_validid($cond->{'id'}) );
	return(0) if( ! defined $cond->{'thetime'} && ! defined $cond->{'thedate'} );
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
	return(0) unless( $self->is_validid($cond->{'id'}) );
	return(0) if( ! defined $cond->{'thetime'} && ! defined $cond->{'thedate'} );
	return $self->update( { 'disabled' => 1 }, $cond );
}

1;

                           
 ####          ##          
 ## ##  #### ###### ####   
 ##  ##    ##  ##      ##  
 ##  ## #####  ##   #####  
 ## ## ##  ##  ##  ##  ##  
 ####   #####   ### #####  

package Kanadzuchi::BdDR::DailyUpdates::Data;
use strict;
use warnings;
use base 'Class::Accessor::Fast::XS';
use Time::Piece;
use List::Util;
use Kanadzuchi::Iterator;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'db',			# (Kanadzuchi::BdDR::DailyUpdates) Ojbect
	'handle',		# (DBI::db) Database Handle
	'totalsby',		# (String) Totals by (week|month|year)
	'data',			# (Ref->Array) Data(SELECTED|TO BE INSERTED)
	'subtotal',		# (Ref->Array) Subtotals(totals by...)
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
	# @Return	(Kanadzuchi::BdDR::DailyUpdates::Data) Object
	my $class = shift();
	my $argvs = { @_ }; 
	my $tunit = q();

	return unless defined $argvs->{'handle'};

	$tunit = substr( lc $argvs->{'totalsby'}, 0, 1 ) if( $argvs->{'totalsby'} );
	$tunit = 'w' if( $tunit eq q() || $tunit !~ m{\A(?:d|m|w|y)\z} );
	$argvs->{'totalsby'} = $tunit;

	map {
		$argvs->{$_} = [] if( ! defined $argvs->{$_} 
					|| ref($argvs->{$_}) ne q|ARRAY| )
	} qw(data subtotal);
	$argvs->{'db'} = new Kanadzuchi::BdDR::DailyUpdates::Table( 'handle' => $argvs->{'handle'} );
	return $class->SUPER::new($argvs);
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub recordit
{
	# +-+-+-+-+-+-+-+-+
	# |r|e|c|o|r|d|i|t|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	 INSERT INTO|UPDATE SET...
	#		 Wrapper method of K::BdDR::DailyUpdates::Table->insert, update
	# @Param	 (Ref->Array) Data
	# @Return	 (Integer) n = The number of inserted|updated records
	#		 (Integer) 0 = Failed to INSERT|UPDATE
	my $self = shift();
	my $data = shift() || $self->{'data'};

	my $dbobj = $self->{'db'};
	my $ndata = {};
	my $xdata = {};
	my $dates = [];
	my $xstat = 0;
	my $xcols = [ 'inserted', 'updated', 'skipped', 'failed' ];

	return 0 unless( ref($data) eq q|ARRAY| );

	foreach my $eachdatum ( @$data )
	{
		push( @$dates, $eachdatum->{'thedate'} ) unless grep { $eachdatum->{'thedate'} eq $_ } @$dates;
		if( $dbobj->count( { 'thedate' => $eachdatum->{'thedate'} } ) )
		{
			# UPDATE
			$ndata->{'description'} = $eachdatum->{'description'} if defined $eachdatum->{'description'};
			$ndata->{'disabled'} = $eachdatum->{'disabled'} if defined $eachdatum->{'disabled'};
			map { $ndata->{$_} = \qq($_ + $eachdatum->{$_}) if defined $eachdatum->{$_} } @$xcols;

			$xstat++ if $dbobj->update( $ndata, { 'thedate' => $eachdatum->{'thedate'} } );
		}
		else
		{
			# INSERT
			$ndata = {
				'thetime' => Time::Piece->strptime( $eachdatum->{'thedate'}, "%Y-%m-%d" ),
				'thedate' => $eachdatum->{'thedate'},
				'description' => $eachdatum->{'description'} || q(),
			};
			map { $ndata->{$_} = $eachdatum->{$_} || 0 } @$xcols;
			$xstat++ if $dbobj->insert( $ndata );
		}
	}

	# UPDATE 2 columns; executed and modified
	while( my $d = shift(@$dates) )
	{
		$dbobj->update( {
			'executed' => \'executed + 1',
			'modified' => Time::Piece->new() }, { 'thedate' => $d } );
	}

	return $xstat;
}

sub quaerit
{
	# +-+-+-+-+-+-+-+
	# |q|u|a|e|r|i|t|
	# +-+-+-+-+-+-+-+
	#
	# @Description	 SELECT FROM ..., 
	#		 Wrapper method of K::BdDR::DailyUpdates::Table->search
	# @Param <ref>	 (Ref->Hash) WHERE Condition
	# @Param <obj>	 (Kanadzuchi::BdDR::Page) Pagination object
	# @Param <str>	 (String) Unit; [d]ay, [w]eek, [m]onth, or [y]ear
	# @Return	 (Kanadzuchi::Iterator) Results in the iterator
	#		 (Integer) The number of results
	#
	my $self = shift();
	my $cond = shift() || {};
	my $page = shift() || Kanadzuchi::BdDR::Page->new( 'resultsperpage' => 31 );
	my $unit = shift() || 'd';
	my $dobj = $self->{'db'};
	my $data = [];		# Data in the current page

	SCAN_AND_JOIN: while(1)
	{
		$page->colnameorderby( 'thedate' );
		$data = $dobj->search( $cond, $page );

		last() if( $unit eq 'd' );
		last() if( scalar @$data == 1 );

		my $leaf = undef();	# (Kanadzuchi::Page) Pagination for getting the next entry
		my $this = [];		# (Ref->Array) This year[0], month[1], and day[2] by split()
		my $that = [];		# (Ref->Array) That year[0], month[1], and day[2] by split()
		my $xrpp = $unit eq 'w' ? 7 : $unit eq 'm' ? 31 : 366;

		if( $page->hasnext() )
		{
			#  _____                          _  __   __  
			# |  ___|____      ____ _ _ __ __| | \ \  \ \ 
			# | |_ / _ \ \ /\ / / _` | '__/ _` |  \ \  \ \
			# |  _| (_) \ V  V / (_| | | | (_| |  / /  / /
			# |_|  \___/ \_/\_/ \__,_|_|  \__,_| /_/  /_/ 
			#                                             
			my $last = q();		# (String) Date string of the last entry
			my $next = [];		# (Ref->Array) Data in the next page

			$leaf = new Kanadzuchi::BdDR::Page(
					'colnameorderby' => $page->colnameorderby(),
					'descendorderby' => $page->descendorderby(),
					'numofrecordsin' => $page->numofrecordsin(),
					'resultsperpage' => $xrpp,
			);
			$leaf->currentpagenum( int($page->resultsperpage * $page->currentpagenum / $xrpp) );
			$leaf->lastpagenumber( int($page->numofrecordsin() / $xrpp) + 1 );
			$leaf->offsetposition( $page->currentpagenum * $page->resultsperpage );

			# Get the next page
			$next = $dobj->search( $cond, $leaf );
			last() unless scalar @$next;		# There is no next entry

			# Join
			$last = $data->[-1]->{'thedate'};	# Date string of the last entry
			$this = [ map { int $_ } split( '-', $last ) ];

			JOIN_FORWARD: foreach my $e ( @$next )
			{
				$that = [ map { int $_ } split( '-', $e->{'thedate'} ) ];

				if( $unit eq 'y' || $unit eq 'm' )
				{
					# Same year and same month
					last() if( $this->[0] != $that->[0] || $this->[1] != $that->[1] );
					push( @$data, $e );
				}
				else
				{
					# Same week
					last() unless( $this->[0] == $that->[0] );

					my $__this = Time::Piece->strptime($e->{'thedate'},"%Y-%m-%d");
					my $__that = Time::Piece->strptime(join('-',@$that),"%Y-%m-%d");

					last() unless( $__this->week == $__that->week() );
					push( @$data, $e );
				}
			} # End of foreach(JOIN_FORWARD)
		} # End of FORWARD

		if( $page->currentpagenum > 1 )
		{
			#   __   __  ____             _                           _ 
			#  / /  / / | __ )  __ _  ___| | ____      ____ _ _ __ __| |
			# / /  / /  |  _ \ / _` |/ __| |/ /\ \ /\ / / _` | '__/ _` |
			# \ \  \ \  | |_) | (_| | (__|   <  \ V  V / (_| | | | (_| |
			#  \_\  \_\ |____/ \__,_|\___|_|\_\  \_/\_/ \__,_|_|  \__,_|
			#                                                           
			my $head = q();		# (String) Date string of the first entry
			my $prev = [];		# (Ref->Array) Data in the previous page

			$leaf = new Kanadzuchi::BdDR::Page(
					'colnameorderby' => $page->colnameorderby(),
					'descendorderby' => $page->descendorderby(),
					'numofrecordsin' => $page->numofrecordsin(),
					'resultsperpage' => $xrpp,
			);
			$leaf->currentpagenum( int($page->resultsperpage * $page->currentpagenum / $xrpp) - 1 );
			$leaf->lastpagenumber( int($page->numofrecordsin() / $xrpp) + 1 );
			$leaf->offsetposition( $page->offsetposition - $xrpp );

			# Get the next page
			$prev = $dobj->search( $cond, $leaf );
			last() unless scalar @$prev;		# There is no previous entry

			# Join
			$head = $data->[0]->{'thedate'};	# Date string of the first entry
			$this = [ map { int $_ } split( '-', $head ) ];

			JOIN_BACKWARD: foreach my $e ( reverse @$prev )
			{
				$that = [ map { int $_ } split( '-', $e->{'thedate'} ) ];

				if( $unit eq 'y' || $unit eq 'm' )
				{
					# Same year and same month
					last() if( $this->[0] != $that->[0] || $this->[1] != $that->[1] );
					push( @$data, $e );
				}
				else
				{
					# Same week
					last() unless( $this->[0] == $that->[0] );

					my $__this = Time::Piece->strptime($e->{'thedate'},"%Y-%m-%d");
					my $__that = Time::Piece->strptime(join('-',@$that),"%Y-%m-%d");

					last() unless( $__this->week == $__that->week() );
					push( @$data, $e );
				}
			} # End of foreach(JOIN_BACKWARD)
		} # End of BACKWARD

		last();

	} # End of while(SCAN_AND_JOIN)

	# Calculate estimated number of bounces
	foreach my $x ( @$data )
	{
		my $s = $x->{'executed'} ? int( $x->{'skipped'} / $x->{'executed'} ) : 0;
		$x->{'estimated'} = $x->{'inserted'} + $x->{'updated'} + $s;
	}

	if( defined wantarray() )
	{
		return new Kanadzuchi::Iterator( $data );
	}
	else
	{
		$self->{'data'} = $data;
	}
}

sub congregat
{
	# +-+-+-+-+-+-+-+-+-+
	# |c|o|n|g|r|e|g|a|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Aggregate per week, month, and year
	# @Param <ref>	(Ref->Array) Data
	# @Return	(Ref->Hash)
	#
	my $self = shift();
	my $data = shift() || $self->{'data'};
	my $unit = $self->{'totalsby'} || 'w';
	my $subt = $self->{'subtotal'} || [];
	my $subx = {};
	my $list = [];
	my $cols = [ qw(inserted updated skipped failed executed) ];

	return 0 if( ref($data) ne q|ARRAY| );
	return 0 if( $unit eq 'd' );

	my $timepobj = undef();	# (Time::Piece)
	my $modified = undef();	# (Time::Piece) Last Modified (Table)
	my $thistime = undef();	# (Time::Piece) The time(machine time)
	my $subtotal = {};	# (Ref->Hash) Alias for each $totalled->{?}
	my $totalled = {};	# (Ref->Hash) Data, already totalled.
	my $hkstring = q();	# (String) Hash key string

	# Convert from List to Hash
	foreach my $e ( @$subt )
	{
		my $s = $e->{'executed'} ? int( $e->{'skipped'} / $e->{'executed'} ) : 0;
		my $n = $e->{'name'};

		map { $totalled->{ $n }->{$_} = $e->{$_} } @$cols;
		$totalled->{ $n }->{'modified'} = $e->{'modified'};
		$totalled->{ $n }->{'estimated'} = $e->{'inserted'} + $e->{'updated'} + $s;
	}

	while( my $thisdata = shift( @$data ) )
	{
		$timepobj = Time::Piece->strptime( $thisdata->{'thedate'}, "%Y-%m-%d" );
		$modified = ref( $thisdata->{'modified'} ) eq q|Time::Piece|
				? $thisdata->{'modified'}
				: Time::Piece->new( $thisdata->{'modified'} );
		$thistime = ref( $thisdata->{'thetime'} ) eq q|Time::Piece|
				? $thisdata->{'thetime'}
				: Time::Piece->new( $thisdata->{'thetime'} );

		if( $unit eq 'w' )
		{
			$hkstring  = sprintf("%04d-%02d", $timepobj->year(), $timepobj->week());
		}
		elsif( $unit eq 'm' )
		{
			$hkstring = sprintf("%04d-%02d", $timepobj->year(), $timepobj->mon());
		}
		elsif( $unit eq 'y' )
		{
			$hkstring = sprintf("%04d", $timepobj->year() );
		}

		$subtotal = $totalled->{ $hkstring };
		map { $subtotal->{$_} += $thisdata->{$_} } @$cols;
		$subtotal->{'estimated'} += $thisdata->{'estimated'};

		if( ! $subtotal->{'modified'} || $subtotal->{'modified'} < $modified )
		{
			$subtotal->{'modified'} = $modified;
		}

		if( ! $subtotal->{'thetime'} || $subtotal->{'thetime'} > $thistime )
		{
			$subtotal->{'thetime'} = $thistime;
		}
		$totalled->{ $hkstring } = $subtotal;
	}

	# Convert from Hash to List
	foreach my $name ( sort keys %$totalled )
	{
		$subx = { 'name' => $name };
		map { $subx->{$_} = $totalled->{ $name }->{$_} } @$cols;

		$subx->{'estimated'} = $totalled->{ $name }->{'estimated'};
		$subx->{'modified'} = $totalled->{ $name }->{'modified'};
		$subx->{'thetime'} = $totalled->{ $name }->{'thetime'};

		push( @$list, $subx );
	}

	$self->{'subtotal'} = $list;
}

1;
__END__
