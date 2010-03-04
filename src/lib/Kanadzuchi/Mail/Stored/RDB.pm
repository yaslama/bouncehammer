# $Id: RDB.pm,v 1.7 2010/03/04 08:32:20 ak Exp $
# -Id: Stored.pm,v 1.5 2009/12/31 16:30:13 ak Exp -
# -Id: Stored.pm,v 1.1 2009/08/29 07:33:13 ak Exp -
# -Id: Stored.pm,v 1.14 2009/08/12 01:59:20 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Mail::Stored::
                       
 #####  ####   #####   
 ##  ## ## ##  ##  ##  
 ##  ## ##  ## #####   
 #####  ##  ## ##  ##  
 ## ##  ## ##  ##  ##  
 ##  ## ####   #####   
package Kanadzuchi::Mail::Stored::RDB;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use base 'Kanadzuchi::Mail';
use strict;
use warnings;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'id',			# (Integer) Record ID
	'updated',		# (Time::Piece) Updated date
	'disabled',		# (Boolean) Disable flag
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
sub searchandnew
{
	#+-+-+-+-+-+-+-+-+-+-+-+-+
	#|s|e|a|r|c|h|a|n|d|n|e|w|
	#+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	new() by SELECT * FROM t_bouncelogs WHERE '?' = '?'
	# @Param <ref>	(K::RDB)
	# @Param <ref>	(Ref->Hash) Hash reference(use in where cond)
	# @Param <ref>	(Ref->Hash) Ref of Hash reference(pager)
	# @Param <flg>	(Integer) 1 = Create new object, 0 = is hash ref.
	# @Return	(Ref->Array) Array-ref of Hash references if <flg> = 0
	# @Return	(Ref->Array) Array-ref of K::M::S::RDB object if <flg> = 1
	my $class = shift();
	my $dbobj = shift() || return([]);
	my $wcond = shift() || return([]);
	my $pager = shift() || return([]);
	my $oflag = shift() || 0;
	my $arref = [];		# Array reference
	my $rsset = undef();	# Kanadzuchi::RDB::Schema::ResultSet object
	my $rpage = undef();	# DBIx::Class::Pageset
	my $reqrs = defined(wantarray()) ? 1 : 0;

	# Variables for sending query, build WHERE condition
	my $_dbixcresultset = $dbobj->handle->resultset('BounceLogs');
	my $_wherecondition = {};	# Where conditions
	my $_prefetchtables = [];	# Table names for prefetch
	my $_jointablenames = [];	# Table names for JOIN
	my $_joinstatements = {};	# JOIN statements
	my $_resultsperpage = 0;	# Results per page
	my $_currentpagenum = 1;	# Current page number
	my $_colnameorderby = q();	# Order by
	my $_descendorderby = 0;	# Descending order

	# Set pre-fetch tables
	push( @$_prefetchtables, 'senderdomain','destination' );

	# Set page configuration
	$_resultsperpage = defined($$pager->{'resultsperpage'}) ? $$pager->{'resultsperpage'} : 10;
	$_currentpagenum = defined($$pager->{'currentpagenum'}) ? $$pager->{'currentpagenum'} : 1;
	$_colnameorderby = $$pager->{'colnameorderby'} || q(id);
	$_descendorderby = $$pager->{'descendorderby'} ? 1 : 0;

	ORDER_BY: {
		#   ___  ____  ____  _____ ____    ______   __
		#  / _ \|  _ \|  _ \| ____|  _ \  | __ ) \ / /
		# | | | | |_) | | | |  _| | |_) | |  _ \\ V / 
		# | |_| |  _ <| |_| | |___|  _ <  | |_) || |  
		#  \___/|_| \_\____/|_____|_| \_\ |____/ |_|  
		#                                             
		# Add 'me.' to column name if it is 'id'
		foreach my $_c ( 'id', 'disabled', 'description' )
		{
			do{ $_colnameorderby = q{me.}.$_c; last(); } if( $_colnameorderby eq $_c );
		}

		if( $_colnameorderby eq 'senderdomain' || $_colnameorderby eq 'destination' )
		{
			$_colnameorderby .= q{.domainname} 
		}
		elsif( $_colnameorderby eq 'addresser' )
		{
			$_colnameorderby .= q{.email} 
		}

		$_colnameorderby .= q{ desc} if( $_descendorderby );
	}

	WHERE_CONDITION: {
		# __        ___   _ _____ ____  _____    ____ ___  _   _ ____   
		# \ \      / / | | | ____|  _ \| ____|  / ___/ _ \| \ | |  _ \  
		#  \ \ /\ / /| |_| |  _| | |_) |  _|   | |  | | | |  \| | | | | 
		#   \ V  V / |  _  | |___|  _ <| |___  | |__| |_| | |\  | |_| | 
		#    \_/\_/  |_| |_|_____|_| \_\_____|  \____\___/|_| \_|____(_)
		#
		# Where Cond.: id(me.id), disabled = 0
		if( $wcond->{'id'} ){ $_wherecondition->{'me.id'} = $wcond->{'id'}; }
		if( defined($wcond->{'disabled'}) && length($wcond->{'disabled'}) )
		{
			$_wherecondition->{'me.disabled'} = $wcond->{'disabled'};
		}

		# Where Cond.: Addresser
		if( $wcond->{'addresser'} )
		{
			$wcond->{'addresser'} = lc($wcond->{'addresser'});
			$_wherecondition->{'addresser.email'} = $wcond->{'addresser'};
			push( @$_jointablenames, 'addresser' );
		}

		# Where Cond.: Recipient
		if( $wcond->{'recipient'} )
		{
			$wcond->{'recipient'} = lc($wcond->{'recipient'});
			$_wherecondition->{'recipient'} = $wcond->{'recipient'};
		}

		# Where Cond.: Sender domain name
		if( $wcond->{'senderdomain'} )
		{
			$wcond->{'senderdomain'} = lc($wcond->{'senderdomain'});
			$_wherecondition->{'senderdomain.domainname'} = $wcond->{'senderdomain'};
			push( @$_jointablenames, 'senderdomain' );
		}
		elsif( $wcond->{'addresser'} )
		{
			($wcond->{'senderdomain'}) = $wcond->{'addresser'} =~ m{[@](.+)\z};
		}

		# Where Cond.: Destination domain name
		if( $wcond->{'destination'} )
		{
			$wcond->{'destination'} = lc($wcond->{'destination'});
			$_wherecondition->{'destination.domainname'} = $wcond->{'destination'};
			push( @$_jointablenames, 'destination' );
		}
		elsif( $wcond->{'recipient'} )
		{
			($wcond->{'destination'}) = $wcond->{'recipient'} =~ m{[@](.+)\z};
		}

		# Where Cond.: Message token string
		if( $wcond->{'token'} )
		{
			$_wherecondition->{'token'} = $wcond->{'token'};
		}

		# Where Cond.: Provider name
		if( $wcond->{'provider'} )
		{
			$_wherecondition->{'provider'} = lc($wcond->{'provider'});
		}

		# Where Cond.: Host group
		if( $wcond->{'hostgroup'} )
		{
			$_wherecondition->{'hostgroup'} = __PACKAGE__->gname2id($wcond->{'hostgroup'});
		}

		# Where Cond.: Reason
		if( $wcond->{'reason'} )
		{
			$_wherecondition->{'reason'} = __PACKAGE__->rname2id($wcond->{'reason'});
		}

		# WHere Cond.: bounced date
		if( $wcond->{'bounced'} )
		{
			$_wherecondition->{'me.bounced'} = { '>=' => $wcond->{'bounced'}, };
		}
	}

	JOIN_AND_ORDERBY: {
		#      _  ___ ___ _   _      ___  ____  ____  _____ ____    ______   __
		#     | |/ _ \_ _| \ | |    / _ \|  _ \|  _ \| ____|  _ \  | __ ) \ / /
		#  _  | | | | | ||  \| |   | | | | |_) | | | |  _| | |_) | |  _ \\ V / 
		# | |_| | |_| | || |\  |_  | |_| |  _ <| |_| | |___|  _ <  | |_) || |  
		#  \___/ \___/___|_| \_( )  \___/|_| \_\____/|_____|_| \_\ |____/ |_|  
		#                      |/ 
		# Set SQL 'JOIN', 'orderby' statements and prefetch table names 
		$_joinstatements = { 
			'order_by' => $_colnameorderby,
			'join' => $_jointablenames,
			'prefetch' => $_prefetchtables, };
	}

	PAGING: {
		#  ____   _    ____ ___ _   _  ____ 
		# |  _ \ / \  / ___|_ _| \ | |/ ___|
		# | |_) / _ \| |  _ | ||  \| | |  _ 
		# |  __/ ___ \ |_| || || |\  | |_| |
		# |_| /_/   \_\____|___|_| \_|\____|
		# 
		# Set paging configuration: a page number and results per page.
		if( $_resultsperpage && $_currentpagenum )
		{
			$_joinstatements->{'page'} = $_currentpagenum;
			$_joinstatements->{'rows'} = $_resultsperpage;
		}
	}

	#  ____  _____ _   _ ____     ___  _   _ _____ ______   __
	# / ___|| ____| \ | |  _ \   / _ \| | | | ____|  _ \ \ / /
	# \___ \|  _| |  \| | | | | | | | | | | |  _| | |_) \ V / 
	#  ___) | |___| |\  | |_| | | |_| | |_| | |___|  _ < | |  
	# |____/|_____|_| \_|____/   \__\_\\___/|_____|_| \_\|_|  
	# 
	# Send query and set the pager
	$rsset = $_dbixcresultset->search( $_wherecondition, $_joinstatements );
	$rpage = $rsset->pager() if( $_resultsperpage && $_currentpagenum );


	if( defined($rpage) )
	{
		# Set paging information to 'pager' variable(ref)
		$$pager = {
			'colnameorderby'	=> $$pager->{'colnameorderby'},
			'descendorderby'	=> $$pager->{'descendorderby'},
			'firstpagenumber'	=> $rpage->first_page(),
			'lastpagenumber'	=> $rpage->last_page(),
			'resultsperpage'	=> $rpage->entries_per_page(),
			'currentpagenum'	=> $rpage->current_page(),
			'totalentries'		=> $rpage->total_entries(),
			'firstentry'		=> $rpage->first(),
			'lastentry'		=> $rpage->last(), };
	}

	# Count($pager) and return
	return() unless( $reqrs );

	CREATE_OBJECT: while( my $_r = $rsset->next() )
	{
		my $_storedrecord = {
			'id'		=> $_r->id(),
			'addresser'	=> $_r->addresser->email(),
			'recipient'	=> $_r->recipient(),
			'frequency'	=> $_r->frequency(),
			'senderdomain'	=> $_r->senderdomain->domainname(),
			'token'		=> $_r->token(),
			'destination'	=> $_r->destination->domainname(),
			'description'	=> $_r->description(),
			'provider'	=> $_r->provider->name(),
			'hostgroup'	=> __PACKAGE__->id2gname( $_r->hostgroup() ),
			'reason'	=> __PACKAGE__->id2rname( $_r->reason() ),
			'bounced'	=> new Time::Piece( $_r->bounced() ),
			'updated'	=> new Time::Piece( $_r->updated() ),
			'disabled'	=> $_r->disabled(),
		};

		if( $oflag == 1 )
		{
			# Create new K::M::S::RDB object
			push( @{$arref}, __PACKAGE__->new( %$_storedrecord ) );
		}
		else
		{
			# Use hash reference
			$_storedrecord->{'description'} = shift @{
					Kanadzuchi::Metadata->to_object( \$_r->description() ) };

			foreach my $_e ( 'timezoneoffset', 'diagnosticcode', 'deliverystatus' )
			{
				$_storedrecord->{$_e} = $_storedrecord->{'description'}->{$_e};
			}

			push( @{$arref}, $_storedrecord );
		}
	}

	return($arref);
}

sub serialize
{
	#+-+-+-+-+-+-+-+-+-+
	#|s|e|r|i|a|l|i|z|e|
	#+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Serialize hash structure (To saving search condition)
	# @Param <ref>	(Ref->Array) Array reference holds hashref or object
	# @Return	(String) Serialized data(YAML)
	my $class  = shift();
	my $struct = shift() || return(q{});
	my $arrayr = [];
	my $objref = q();

	return(q{}) if( ref($struct) ne q|ARRAY| );

	MAKE_ARRAY_REF: foreach my $_object ( @$struct )
	{
		$objref = ref($_object);

		if( $objref eq q|HASH| )
		{
			# If it is a hash reference
			if( defined($_object->{'description'}) && ref($_object->{'description'}) eq q|HASH| )
			{
				# description is hash reference
				foreach my $n ( 'deliverystatus', 'diagnosticcode', 'timezoneoffset' )
				{
					next() if( defined($_object->{$n}) && length($_object->{$n}) );
					$_object->{$n} = $_object->{'description'}->{$n};
				}
			}
			else
			{
				# description is empty?
				foreach my $n ( 'deliverystatus', 'diagnosticcode', 'timezoneoffset' )
				{
					$_object->{'description'}->{$n} = { $n => $_object->{$n} };
				}
			}
			push( @$arrayr, $_object );
		}
		elsif( $objref eq $class )
		{
			# If it is a hash reference
			if( defined($_object->description()) && length($_object->description()) )
			{
				# description is hash reference
				foreach my $n ( 'deliverystatus', 'diagnosticcode', 'timezoneoffset' )
				{
					next() if( defined($_object->{$n}) && length($_object->{$n}) );
					$_object->{$n} = $_object->{'description'}->{$n};
				}
			}
			else
			{
				# description is empty?
				foreach my $n ( 'deliverystatus', 'diagnosticcode', 'timezoneoffset' )
				{
					$_object->{'description'}->{$n} = { $n => $_object->{$n} };
				}
			}
			# If it is a K::M::S::RDB object
			$_object->description( {
					'deliverystatus' => $_object->deliverystatus(),
					'timezoneoffset' => $_object->timezoneoffset(),
					'diagnosticcode' => $_object->diagnosticcode(), } );
			
			push( @$arrayr, {
				'id'		=> $_object->id() || q(),
				'addresser'	=> $_object->addresser->address() || q(),
				'recipient'	=> $_object->recipient->address() || q(),
				'frequency'	=> $_object->frequency() || q(),
				'senderdomain'	=> $_object->senderdomain() || q(),
				'token'		=> $_object->token() || q(),
				'deliverystatus'=> $_object->deliverystatus() || 0,
				'diagnosticcode'=> $_object->diagnosticcode() || q(),
				'destination'	=> $_object->destination() || q(),
				'description'	=> $_object->description() || q(),
				'timezoneoffset'=> $_object->timezoneoffset() || q(),
				'provider'	=> $_object->provider() || q(),
				'hostgroup'	=> $_object->hostgroup() || q(),
				'reason'	=> $_object->reason() || q(),
				'bounced'	=> $_object->bounced->epoch() || q(),
				'updated'	=> $_object->updated->epoch() || q(),
				'disabled'	=> $_object->disabled() || 0,
			} );
		}
	}

	# Serialize
	# FFR: return as a reference to the scalar
	return( ${ Kanadzuchi::Metadata->to_string( $arrayr ) } );
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub modify
{
	# +-+-+-+-+-+-+
	# |m|o|d|i|f|y|
	# +-+-+-+-+-+-+
	#
	# @Description	modify the rocord(from WebUI)
	# @Param <ref>	(Ref->K::RDB) Kanadzuchi::RDB object
	# @Param <int>	(Integer) Disable the record or not
	# @Returns	(Integer) n = The ID of updated object
	#		(Integer) 0 = Failed to UPDATE
	my $self = shift();
	my $dobj = shift() || return(0);
	my $todi = shift() || 0;
	my $that = undef();

	eval{
		my $_sock = $$dobj->handle->resultset('BounceLogs');
		my $_cond = { 'id' => $self->{'id'}, 'disabled' => 0 };
		my $_data = { 'updated' => time() };

		if( $todi )
		{
			# Disable it
			$_data->{'disabled'} = 1;
		}
		else
		{
			$_data->{'hostgroup'} = __PACKAGE__->gname2id( $self->{'hostgroup'} );
			$_data->{'reason'} = __PACKAGE__->rname2id( $self->{'reason'} );
		}

		$that = $_sock->search( $_cond )->update( $_data );
	};
	return(0) if($@);
	return($that);
}

sub disableit
{
	# +-+-+-+-+-+-+-+-+-+
	# |d|i|s|a|b|l|e|i|t|
	# +-+-+-+-+-+-+-+-+-=
	#
	# @Description	 Disable the rocord
	# @Param <ref>	 (Ref->K::RDB) Kanadzuchi::RDB object
	# @Returns	 (Integer) n = The ID of updated object
	#		 (Integer) 0 = Failed to UPDATE
	my $self = shift();
	my $dobj = shift() || return(0);
	my $that = undef();

	return($self->modify( $dobj, 1 ));
}

1;
__END__
