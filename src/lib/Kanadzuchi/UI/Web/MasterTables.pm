# $Id: MasterTables.pm,v 1.15 2010/06/08 19:15:05 ak Exp $
# -Id: MasterTables.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: MasterTables.pm,v 1.7 2009/08/15 15:06:56 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                                                                
 ##  ##                  ##              ######       ##    ###                 
 ######   ####   ##### ###### ####  #####  ##   ####  ##     ##   ####   #####  
 ######      ## ##       ##  ##  ## ##  ## ##      ## #####  ##  ##  ## ##      
 ##  ##   #####  ####    ##  ###### ##     ##   ##### ##  ## ##  ######  ####   
 ##  ##  ##  ##     ##   ##  ##     ##     ##  ##  ## ##  ## ##  ##         ##  
 ##  ##   ##### #####     ### ####  ##     ##   ##### ##### ####  ####  #####   
package Kanadzuchi::UI::Web::MasterTables;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use utf8;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::BdDR;
use Kanadzuchi::BdDR::BounceLogs::Masters;

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
	require Kanadzuchi::BdDR::Page;
	my $self = shift();
	my $bddr = $self->{'database'};
	my $list = [];

	my $templatef = 'mastertable.'.$self->{'language'}.'.html';
	my $tableconf = $self->{'webconfig'}->{'database'}->{'table'};
	my $tablename = lc $self->param('pi_tablename');
	my $tableisro = $tableconf->{$tablename}->{'readonly'};
	my $wherecond = {};
	my $mastertab = new Kanadzuchi::BdDR::BounceLogs::Masters::Table( 
				'alias' => $tablename, 'handle' => $bddr->handle() );
	my $paginated = Kanadzuchi::BdDR::Page->new(
				'colnameorderby' => lc($self->param('pi_orderby')) || 'id',
				'resultsperpage' => $self->param('pi_rpp') || 10 );

	$paginated->resultsperpage(25) if( $tablename eq 'hostgroups' || $tablename eq 'reasons' );
	$paginated->set( $mastertab->count( $wherecond ) );
	$paginated->skip( $self->param('pi_page') || 1 );
	$list = $mastertab->search( $wherecond, $paginated );
	map { utf8::encode($_->{'description'}) if( utf8::is_utf8($_->{'description'}) ) } @$list;

	$self->tt_params( 
		'sortby' => $paginated->colnameorderby(),
		'titlename' => ucfirst $tablename,
		'tablename' => $tablename,
		'fieldname' => $mastertab->field(),
		'isreadonly' => $tableconf->{$tablename}->{'readonly'},
		'pagination' => $paginated,
		'contentsname' => 'table',
		'hascondition' => 0,
		'tablecontents' => $list );
	$self->tt_process($templatef);
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
	my $bddr = $self->{'database'};

	my $templatef = 'div-mastertable-contents.'.$self->{'language'}.'.html';
	my $templatee = 'div-mastertable-error.'.$self->{'language'}.'.html';
	my $tablename = lc $self->param('pi_tablename');
	my $tableconf = $self->{'webconfig'}->{'database'}->{'table'};
	my $tableisro = $tableconf->{$tablename}->{'readonly'};
	my $mastertab = new Kanadzuchi::BdDR::BounceLogs::Masters::Table(
				'alias' => $tablename, 'handle' => $bddr->handle() );

	if( $mastertab )
	{
		# Pick up the string from PATH_INFO
		my $paginated = undef();		# (Kanadzuchi::BdDR::Page) Pagination object
		my $tabrecord = [];			# (Ref->Array) Record in the mastertable
		my $cgidquery = $self->query();		# Query Strings
		my $curmtdata = {};			# (Ref->Hash) Current data on the mastertable
		my $newmtdata = {};			# (Ref->Hash) New data for mastertable
		my $wherecond = {};			# (Ref->Hash) WHERE Condition
		my $currentid = 0;			# (Integer) Current ID of the record
		my $tabaction = $cgidquery->param('action') || $ENV{'PATH_INFO'};

		$tabaction =~ s{\A.+/([a-zA-Z]+)\z}{$1};

		if( $tabaction eq 'create' )
		{
			#  ___ _   _ ____  _____ ____ _____   ___ _   _ _____ ___  
			# |_ _| \ | / ___|| ____|  _ \_   _| |_ _| \ | |_   _/ _ \ 
			#  | ||  \| \___ \|  _| | |_) || |    | ||  \| | | || | | |
			#  | || |\  |___) | |___|  _ < | |    | || |\  | | || |_| |
			# |___|_| \_|____/|_____|_| \_\|_|   |___|_| \_| |_| \___/ 
			#                                                          
			require Kanadzuchi::RFC2822;
			$newmtdata->{'name'} = lc $cgidquery->param('newname');
			$newmtdata->{'description'} = $cgidquery->param('newdesc');
			$newmtdata->{'disabled'} = 0;

			if( $tableisro )
			{
				# The table is read only table, Set error template
				$tabrecord = [ { 
					'name' => $newmtdata->{'name'},
					'description' => q(Permission denied, The table is read only.), } ];
				$templatef = $templatee;
			}
			else
			{
				# The table is writable
				if( Kanadzuchi::RFC2822->is_domainpart($newmtdata->{'name'}) && $newmtdata->{'name'} =~ m{[.]} )
				{
					$currentid = $mastertab->getidbyname( $newmtdata->{'name'} );
					if( $currentid )
					{
						# The record already exists, CANNOT INSERT
						$tabrecord = [ { 
							'id' => $currentid,
							'name' => $newmtdata->{'name'},
							'description' => q(Already exists), } ];
						$templatef = $templatee;
					}
					else
					{
						# The record does not exist in the mastertable
						$newmtdata->{'id'} = $mastertab->insert( $newmtdata );

						if( $newmtdata->{'id'} )
						{
							$tabrecord = [ $newmtdata ];
						}
						else
						{
							# Failed to create
							$tabrecord = [ { 
								'name' => $newmtdata->{'name'},
								'description' => q(Failed to create a new record), } ];
							$templatef = $templatee;
						}
					}
				}
				else
				{
					# Invalid key name
					$tabrecord = [ { 
						'name' => $newmtdata->{'name'},
						'description' => 'Invalid name or not FQDN: ['.$newmtdata->{'name'}.']', } ];
					$templatef = $templatee;
				}
			}

			$self->tt_params(
				'titlename' => ucfirst $tablename,
				'tablename' => $tablename,
				'fieldname' => $mastertab->field(),
				'isreadonly' => $tableisro,
				'contentsname' => 'table',
				'tablecontents' => $tabrecord );
		}
		elsif( $tabaction eq 'update' )
		{
			#  _   _ ____  ____    _  _____ _____ 
			# | | | |  _ \|  _ \  / \|_   _| ____|
			# | | | | |_) | | | |/ _ \ | | |  _|  
			# | |_| |  __/| |_| / ___ \| | | |___ 
			#  \___/|_|   |____/_/   \_\_| |_____|
			#                                     
			$wherecond->{'id'} = $cgidquery->param('id');
			$curmtdata = $mastertab->getentbyid($wherecond->{'id'});

			if( exists($curmtdata->{'id'}) && $curmtdata->{'id'} )
			{
				$newmtdata->{'name'} = $curmtdata->{'name'};
				$newmtdata->{'description'} = $cgidquery->param('desc');
				$newmtdata->{'disabled'} = $curmtdata->{'disabled'};

				if( $mastertab->update( $newmtdata, $wherecond ) )
				{
					# Successfully UPDATEd
					$tabrecord = [ {
						'id' => $curmtdata->{'id'},
						'name' => $newmtdata->{'name'},
						'disabled' => $newmtdata->{'disabled'},
						'description' => $newmtdata->{'description'}, } ];
				}
				else
				{
					# Failed to UPDATE
					$templatef = $templatee;
					$tabrecord = [ { 'name' => $curmtdata->{'name'}, 'description' => q(Failed to update), } ];
				}
			}
			else
			{
				# ID is empty
				$templatef = $templatee;
				$tabrecord = [ { 
					'name' => $cgidquery->param('name'),
					'description' => q(No ID in the query string, Failed), } ];
			}

			$self->tt_params(
				'titlename' => ucfirst $tablename,
				'tablename' => $tablename,
				'fieldname' => $mastertab->field(),
				'isreadonly' => $tableisro,
				'contentsname' => 'table',
				'tablecontents' => $tabrecord );
		}
		elsif( $tabaction eq 'delete' )
		{
			#  ____  _____ _     _____ _____ _____   _____ ____   ___  __  __ 
			# |  _ \| ____| |   | ____|_   _| ____| |  ___|  _ \ / _ \|  \/  |
			# | | | |  _| | |   |  _|   | | |  _|   | |_  | |_) | | | | |\/| |
			# | |_| | |___| |___| |___  | | | |___  |  _| |  _ <| |_| | |  | |
			# |____/|_____|_____|_____| |_| |_____| |_|   |_| \_\\___/|_|  |_|
			#                                                                 
			require Kanadzuchi::BdDR::Page;
			my $theidwillberm = $cgidquery->param('record_will_be_delete');
			my $errormessages = q();
			my $willberemoved = {};
			my $removedrecord = [];

			$templatef = 'mastertable.'.$self->{'language'}.'.html';
			$paginated = Kanadzuchi::BdDR::Page->new(
					'colnameorderby' => $cgidquery->param('colnameorderby') || 'id',
					'resultsperpage' => $cgidquery->param('resultsperpage') || 10 );
			$paginated->set( $mastertab->count( $wherecond ) );
			$paginated->skip( $cgidquery->param('currentpagenum') || 1 );

			if( $theidwillberm )
			{
				$wherecond->{'id'} = $theidwillberm;

				if( defined($cgidquery->param('do_delete')) )
				{
					$willberemoved = $mastertab->getentbyid($theidwillberm);

					if( exists($willberemoved->{'name'}) )
					{
						if( $tableisro )
						{
							# The table is read only
							$errormessages .= 'Permission denied, The table is read only.';
							$errormessages .= '(ID='.$theidwillberm.')';
						}
						else
						{
							if( $mastertab->remove($wherecond) )
							{
								# Successfully removed
								$removedrecord = [ $willberemoved ];
							}
							else
							{
								# Failed to remove
								$errormessages .= 'Failed to remove the reocrd';
								$errormessages .= '(ID='.$theidwillberm.')';
							}
						}
					}
					else
					{
						# No such record
						$errormessages .= 'No such record';
						$errormessages .= '(ID='.$theidwillberm.')';
					}
				}
				else
				{
					# Checkbox is not checked
					$errormessages .= 'Checkbox is not checked';
				}
			}

			$tabrecord = $mastertab->search( {}, $paginated );
			map {
				utf8::encode($_->{'description'}) if( utf8::is_utf8($_->{'description'}) ) 
			} @$tabrecord, @$removedrecord;

			$self->tt_params( 
				'titlename' => ucfirst $tablename,
				'tablename' => $tablename,
				'fieldname' => $mastertab->field(),
				'isreadonly' => $tableisro,
				'pagination' => $paginated,
				'contentsname' => 'table',
				'hascondition' => 0,
				'errormessage' => $errormessages,
				'tablecontents' => $tabrecord,
				'removedrecord' => $removedrecord );
		}
		else
		{
			# Unknown or empty action
			$templatef = $templatee;
			$self->tt_params(
				'titlename' => ucfirst $tablename,
				'tablename' => $tablename,
				'fieldname' => $mastertab->field(),
				'isreadonly' => $tableisro,
				'contentsname' => 'table',
				'tablecontents' => [ {
					'name' => $tablename,
					'description' => 'Unknown or empty action.', } ],
			);

		} # End of if($action)
	}
	else
	{
		# Invalid table name
		$templatef = $templatee;
		$self->tt_params(
			'titlename' => ucfirst $tablename,
			'tablename' => $tablename,
			'fieldname' => 'unknown',
			'isreadonly' => $tableisro,
			'contentsname' => 'table',
			'tablecontents' => [ {
				'name' => $tablename,
				'description' => 'Unknown table name.', } ],
		);

	} # End of if($table)

	$self->tt_process($templatef);
}

1;
__END__
