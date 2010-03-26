# $Id: MasterTables.pm,v 1.10 2010/03/26 07:20:08 ak Exp $
# -Id: MasterTables.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: MasterTables.pm,v 1.7 2009/08/15 15:06:56 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                                                                  
 ##  ##                  ##              ######         ##    ###                 
 ######   ####   ##### ###### ####  #####  ##     ####  ##     ##   ####   #####  
 ######      ## ##       ##  ##  ## ##  ## ##        ## #####  ##  ##  ## ##      
 ##  ##   #####  ####    ##  ###### ##     ##     ##### ##  ## ##  ######  ####   
 ##  ##  ##  ##     ##   ##  ##     ##     ##    ##  ## ##  ## ##  ##         ##  
 ##  ##   ##### #####     ### ####  ##     ##     ##### ##### ####  ####  #####   
package Kanadzuchi::UI::Web::MasterTables;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::RDB::MasterTable;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub tablelist_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|a|b|l|e|l|i|s|t|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get list of the table
	# @Param	<None>
	my $self = shift();
	my $aref = [];
	my $tobj = undef();
	my $tmpl = q(mastertable.).$self->{'language'}.q(.html);
	my $tabc = $self->{'webconfig'}->{'database'}->{'table'};
	my $cond = {};	# WHERE Conditioin, For Future Release
	my $page = { 
		'colnameorderby' => lc($self->param('pi_orderby')) || q(),
		'currentpagenum' => $self->param('pi_page') || 1,
		'resultsperpage' => $self->param('pi_rpp') || 10,
	};


	$self->{'tablename'} = lc($self->param('pi_tablename'));

	# Host Groups and Reasons does not use pager
	if( $self->{'tablename'} eq 'hostgroups' || $self->{'tablename'} eq 'reasons' )
	{
		$page->{'resultsperpage'} = 25;
	}

	$tobj = Kanadzuchi::RDB::MasterTable->newtable( $self->{'tablename'} );
	$aref = $tobj->select( $self->{'database'}, $cond, \$page );

	$self->tt_params( 
		'titlename' => ucfirst($self->{'tablename'}),
		'tablename' => $self->{'tablename'},
		'fieldname' => $tobj->field(),
		'sortby' => $page->{'colnameorderby'},
		'isreadonly' => $tabc->{ $self->{'tablename'} }->{'readonly'},
		'contentsname' => 'table',
		'hascondition' => 0,
		'pagersinthequery' => $page,
		'tablecontents' => $aref );
	$self->tt_process($tmpl);
}

sub tablectl_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|a|b|l|e|c|t|l|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Update, Delete, Create record in the table
	# @Param	<None>
	my $self = shift();
	my $href = {};
	my $aref = [];
	my $tmpl = q(div-mastertable-contents.).$self->{'language'}.q(.html);
	my $errt = q(div-mastertable-error.).$self->{'language'}.q(.html);
	my $table = undef();
	my $query = $self->query;
	my $tabcf = $self->{'webconfig'}->{'database'}->{'table'};
	my $action = $ENV{'PATH_INFO'};

	$self->{'tablename'} = lc($self->param('pi_tablename'));
	$table = Kanadzuchi::RDB::MasterTable->newtable( $self->{'tablename'} );

	if( $table )
	{
		$action =~ s{\A.+/([a-zA-Z]+)\z}{$1};
		if( $action eq 'create' )
		{
			require Kanadzuchi::RFC2822;

			$table->name( lc($query->param('newname')) );
			$table->description( $query->param('newdesc') );
			$table->disabled(0);

			if( $tabcf->{ $self->{'tablename'} }->{'readonly'} )
			{
				# Read only table
				$aref = [ { 
					'name' => $table->name(),
					'description' => q(Permission denied, The table is read only.), } ];
				$tmpl = $errt;
			}
			else
			{
				if( Kanadzuchi::RFC2822->is_domainpart($table->name()) && $table->name =~ m{[.]} )
				{
					my $_curid = $table->getidbyname( $self->{'database'} );

					if( $_curid == 0 )
					{
						my $_newid = $table->insert( $self->{'database'} );

						if( $_newid )
						{
							$aref = [ {
								'id' => $_newid,
								'name' => $table->name(),
								'description' => $table->description(),
								'disabled' => $table->disabled() } ];
						}
						else
						{
							# Failed to create
							$aref = [ { 
								'name' => $table->name(),
								'description' => q(Failed to create a new record), } ];
							$tmpl = $errt;
						}
					}
					else
					{
						# Already exists
						$aref = [ { 
							'id' => $_curid,
							'name' => $table->name(),
							'description' => q(Already exists), } ];
						$tmpl = $errt;
					}
				}
				else
				{
					# Invalid name
					$tmpl = $errt;
					$aref = [ { 
						'name' => $table->name(), 
						'description' => q(Invalid name or not FQDN: [).$table->name().q(]), } ];
				}
			}

			$self->tt_params(
				'titlename' => ucfirst($self->{'tablename'}),
				'tablename' => $self->{'tablename'},
				'fieldname' => $table->field(),
				'tablecontents' => $aref );
		}
		elsif( $action eq 'update' )
		{
			$table->id( $query->param('id') );
			$href = $table->getentbyid( $self->{'database'} );

			if( defined($href->{'id'}) )
			{
				$table->name( $href->{'name'} );
				$table->disabled( $href->{'disabled'} );
				$table->description( $query->param('desc') );

				if( $table->update($self->{'database'}) )
				{
					$aref = [ {
						'id' => $table->id(),
						'name' => $table->name(),
						'description' => $table->description(),
						'disabled' => $table->disabled() } ];
				}
				else
				{
					# Failed to UPDATE
					$tmpl = $errt;
					$aref = [ { 'name' => $table->name(), 'description' => q(Failed to update), } ];
				}
			}
			else
			{
				# ID is empty
				$tmpl = $errt;
				$aref = [ { 'name' => $table->name(), 'description' => q(No ID in the query string, Failed), } ];
			}

			$self->tt_params(
				'titlename' => ucfirst($self->{'tablename'}),
				'tablename' => $self->{'tablename'},
				'fieldname' => $table->field(),
				'tablecontents' => $aref );

		}
		elsif( $action eq 'delete' )
		{
			$tmpl = q(mastertable.).$self->{'language'}.q(.html);

			my $_err = q();	# Error message
			my $_old = [];	# Array reference of Removed record
			my $_wbr = {};	# Hash reference of the record(will be removed)

			if( defined($query->param('record_will_be_delete')) )
			{
				$table->id( $query->param('record_will_be_delete') );

				if( defined($query->param('do_delete')) )
				{
					$_wbr = $table->getentbyid($self->{'database'});

					if( exists($_wbr->{'name'}) )
					{
						if( $tabcf->{ $self->{'tablename'} }->{'readonly'} )
						{
							# Read only table
							$_err  = q(Permission denied, The table is read only.);
							$_err .= qq|(ID=|.$table->id().q|)|;
						}
						else
						{
							if( $table->remove($self->{'database'}) )
							{
								# Successfully removed
								$_old = [ $_wbr ];
							}
							else
							{
								# Failed to remove
								$_err  = q(Failed to remove the reocrd);
								$_err .= qq|(ID=|.$table->id().q|)|;
							}
						}
					}
					else
					{
						# No such record
						$_err  = q(No such record);
						$_err .= qq|(ID=|.$table->id().q|)|;
					}
				}
				else
				{
					# Checkbox is not checked
					$_err = q(Checkbox is not checked);
				}
			}

			$aref = $table->select( $self->{'database'} );
			$self->tt_params( 
				'titlename' => ucfirst($self->{'tablename'}),
				'tablename' => $self->{'tablename'},
				'fieldname' => $table->field(),
				'errormessage' => $_err,
				'tablecontents' => $aref,
				'removedrecord' => $_old, );
		}
		else
		{
			# Unknown or empty action
			$tmpl = $errt;
			$self->tt_params(
				'titlename' => ucfirst($self->{'tablename'}),
				'tablename' => $self->{'tablename'},
				'fieldname' => $table->field(),
				'tablecontents' => [ {
					'name' => $self->{'tablename'},
					'description' => q(Unknown or empty action.), } ],
			);

		} # End of if($action)
	}
	else
	{
		# Invalid table name
		$tmpl = $errt;
		$self->tt_params(
			'titlename' => ucfirst($self->{'tablename'}),
			'tablename' => $self->{'tablename'},
			'fieldname' => q(unknown),
			'tablecontents' => [ {
				'name' => $self->{'tablename'},
				'description' => q(Unknown table name.), } ],
		);

	} # End of if($table)

	$self->tt_process($tmpl);
}

1;
__END__
