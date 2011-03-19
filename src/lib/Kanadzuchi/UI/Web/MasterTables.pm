# $Id: MasterTables.pm,v 1.19.2.1 2011/03/19 09:41:42 ak Exp $
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
sub tablelist
{
	# +-+-+-+-+-+-+-+-+-+
	# |t|a|b|l|e|l|i|s|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Get list of the table
	# @Param	<None>
	require Kanadzuchi::BdDR::Page;
	my $self = shift();
	my $bddr = $self->{'database'};
	my $list = [];

	my $templatef = 'mastertable.html';
	my $tableconf = $self->{'webconfig'}->{'database'}->{'table'};
	my $tablename = lc $self->param('pi_tablename');
	my $asacolumn = $tablename; $asacolumn =~ s{s\z}{};
	my $tableisro = $tableconf->{ $tablename }->{'readonly'} || 0;
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
		'pv_sortby' => $paginated->colnameorderby(),
		'pv_titlename' => ucfirst $tablename,
		'pv_tablename' => $tablename,
		'pv_asacolumn' => $asacolumn,
		'pv_fieldname' => $mastertab->field(),
		'pv_isreadonly' => $tableisro,
		'pv_pagination' => $paginated,
		'pv_contentsname' => 'table',
		'pv_hascondition' => 0,
		'pv_tablecontents' => $list );
	return $self->tt_process($templatef);
}

sub tablecontrol
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |t|a|b|l|e|c|o|n|t|r|o|l|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Update, Delete, Create record in the table
	# @Param	<None>
	my $self = shift();
	my $bddr = $self->{'database'};

	my $templatef = 'div-mastertable-contents.html';
	my $templatee = 'div-mastertable-error.html';
	my $tablename = lc $self->param('pi_tablename');
	my $tableconf = $self->{'webconfig'}->{'database'}->{'table'};
	my $tableisro = $tableconf->{$tablename}->{'readonly'} || 0;
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
		my $tabaction = $cgidquery->param('fe_action') || $ENV{'PATH_INFO'};
		my $kanadzchi = $self->{'kanadzuchi'};

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
			$newmtdata->{'name'} = lc $cgidquery->param('fe_newname');
			$newmtdata->{'description'} = $cgidquery->param('fe_newdesc');
			$newmtdata->{'disabled'} = 0;

			# The table is read only table, Set error template
			if( $tableisro )
			{
				$kanadzchi->historique( 'err', 
					'removed=0, id=?, mode=remove, stat=readonly table' );
				return $self->e( 'readonlytable' );
			}

			# The table is writable
			if( Kanadzuchi::RFC2822->is_domainpart($newmtdata->{'name'}) 
				&& $newmtdata->{'name'} =~ m{[.]} ){

				$currentid = $mastertab->getidbyname( $newmtdata->{'name'} );

				if( $currentid )
				{
					$kanadzchi->historique('err',
						sprintf("mode=insert, stat=%s already exists", $newmtdata->{'name'} ));
					return $self->e( 'alreadyexists', 'name: '.$newmtdata->{'name'} )
				}

				# The record does not exist in the mastertable
				$newmtdata->{'id'} = $mastertab->insert( $newmtdata );

				if( $newmtdata->{'id'} )
				{
					$tabrecord = [ $newmtdata ];
					$kanadzchi->historique( 'info', 
						sprintf( "inserted=1, id=%d, name=%s, mode=insert, stat=ok",
							 $newmtdata->{'id'}, $newmtdata->{'name'} ) );
				}
				else
				{
					$kanadzchi->historique( 'err', 
						sprintf( "inserted=0, id=?, name=%s, mode=insert, stat=failed", 
								$newmtdata->{'name'} ) );
					return $self->e( 'failedtocreate', [
							'name: '.$newmtdata->{'name'},
							'desciption: '.$newmtdata->{'description'}
						] );
				}
			}
			else
			{
				# Invalid key name
				$kanadzchi->historique( 'err', 
					sprintf( "inserted=0, id=?, name=%s, mode=insert, stat=data format error", 
							$newmtdata->{'name'} ) );
				return $self->e('dataformaterror', [
							'name: '.$newmtdata->{'name'},
							'desciption: '.$newmtdata->{'description'}
						] );
			}

			$self->tt_params(
				'pv_titlename' => ucfirst $tablename,
				'pv_tablename' => $tablename,
				'pv_fieldname' => $mastertab->field(),
				'pv_isreadonly' => $tableisro,
				'pv_contentsname' => 'table',
				'pv_tablecontents' => $tabrecord );
		}
		elsif( $tabaction eq 'update' )
		{
			#  _   _ ____  ____    _  _____ _____ 
			# | | | |  _ \|  _ \  / \|_   _| ____|
			# | | | | |_) | | | |/ _ \ | | |  _|  
			# | |_| |  __/| |_| / ___ \| | | |___ 
			#  \___/|_|   |____/_/   \_\_| |_____|
			#                                     
			# The table is read only table, Set error template
			$wherecond->{'id'} = $cgidquery->param('fe_id');
			$curmtdata = $mastertab->getentbyid($wherecond->{'id'});

			if( $tableisro )
			{
				# The table is read only table, Set error template
				$templatef = $templatee;
				$tabrecord = [ { 
					'head' => 'readonlytable',
					'id' => $curmtdata->{'id'},
					'name' => $curmtdata->{'name'}, 
					'description' => $curmtdata->{'description'} } ];
				$kanadzchi->historique( 'err', 
					sprintf("updated=0, id=%d, mode=update, stat=readonly table",
						$curmtdata->{'id'} ));
			}
			else
			{
				if( exists($curmtdata->{'id'}) && $curmtdata->{'id'} )
				{
					$newmtdata->{'name'} = $curmtdata->{'name'};
					$newmtdata->{'description'} = $cgidquery->param('fe_desc');
					$newmtdata->{'disabled'} = $curmtdata->{'disabled'};

					if( $mastertab->update( $newmtdata, $wherecond ) )
					{
						# Successfully UPDATEd
						$tabrecord = [ {
							'id' => $curmtdata->{'id'},
							'name' => $newmtdata->{'name'},
							'disabled' => $newmtdata->{'disabled'},
							'description' => $newmtdata->{'description'}, } ];

						# syslog
						$kanadzchi->historique( 'info',
							sprintf("updated=1, id=%d, mode=update, stat=ok",
								$curmtdata->{'id'}) );
					}
					else
					{
						# Failed to UPDATE
						$templatef = $templatee;
						$tabrecord = [ { 
							'head' => 'failedtoupdate',
							'id' => $curmtdata->{'id'},
							'name' => $curmtdata->{'name'}, 
							'description' => $curmtdata->{'description'} } ];

						# syslog
						$kanadzchi->historique( 'err', 
							sprintf( "updated=0, id=%d, mode=update, stat=ok",
								$curmtdata->{'id'} ));
					}
				}
				else
				{
					# ID is empty
					$templatef = $templatee;
					$tabrecord = [ { 
						'head' => 'dataformaterror',
						'id' => $cgidquery->param('fe_id'),
						'name' => $cgidquery->param('fe_name'),
						'description' => $cgidquery->param('fe_desc'), } ];

					# syslog
					$kanadzchi->historique( 'err', 
						sprintf( "updated=0, id=%d, mode=update, stat=data format error",
							$cgidquery->param('fe_id') ));
				}
			}

			$self->tt_params(
				'pv_titlename' => ucfirst $tablename,
				'pv_tablename' => $tablename,
				'pv_fieldname' => $mastertab->field(),
				'pv_isreadonly' => $tableisro,
				'pv_contentsname' => 'table',
				'pv_tablecontents' => $tabrecord );
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
			my $theidwillberm = $cgidquery->param('fe_record_will_be_delete');
			my $errormessages = q();
			my $willberemoved = {};
			my $removedrecord = [];

			$templatef = 'mastertable.html';
			$paginated = Kanadzuchi::BdDR::Page->new(
					'colnameorderby' => $cgidquery->param('fe_colnameorderby') || 'id',
					'resultsperpage' => $cgidquery->param('fe_resultsperpage') || 10 );
			$paginated->set( $mastertab->count( $wherecond ) );
			$paginated->skip( $cgidquery->param('fe_currentpagenum') || 1 );

			if( $theidwillberm )
			{
				$wherecond->{'id'} = $theidwillberm;

				if( defined($cgidquery->param('fe_do_delete')) )
				{
					$willberemoved = $mastertab->getentbyid($theidwillberm);

					if( exists($willberemoved->{'name'}) )
					{
						if( $tableisro )
						{
							# The table is read only
							$kanadzchi->historique( 'err', 
								sprintf( "removed=0, id=%d, mode=remove, stat=readonly table",
									$theidwillberm ) );
							$self->e('readonlytable', 'ID: #'.$theidwillberm );
						}
						else
						{
							if( $mastertab->remove($wherecond) )
							{
								# Successfully removed
								$removedrecord = [ $willberemoved ];
								$kanadzchi->historique( 'info', 
									sprintf("removed=1, id=%d, mode=remove, stat=ok",
										$theidwillberm ));
							}
							else
							{
								# Failed to remove
								$self->e('failedtodelete', 'ID: #'.$theidwillberm );
								$kanadzchi->historique( 'err', 
									sprintf( "removed=0, id=%d, mode=remove, stat=failed",
										$theidwillberm ));
							}
						}
					}
					else
					{
						# No such record
						$kanadzchi->historique( 'err', 
							sprintf( "removed=0, id=%d, mode=remove, stat=no such record",
								$theidwillberm ));
						$self->e( 'nosuchrecord', 'ID: #'.$theidwillberm );
					}
				}
				else
				{
					# Checkbox is not checked
					$kanadzchi->historique( 'err', 
						sprintf( "removed=0, id=%d, mode=remove ,stat=checkbox is off",
							$theidwillberm ));
					$self->e( 'checkboxisoff' );
				}
			}

			$tabrecord = $mastertab->search( {}, $paginated );
			map {
				utf8::encode($_->{'description'}) if( utf8::is_utf8($_->{'description'}) ) 
			} @$tabrecord, @$removedrecord;

			$self->tt_params( 
				'pv_titlename' => ucfirst $tablename,
				'pv_tablename' => $tablename,
				'pv_fieldname' => $mastertab->field(),
				'pv_isreadonly' => $tableisro,
				'pv_pagination' => $paginated,
				'pv_contentsname' => 'table',
				'pv_hascondition' => 0,
				'pv_errormessage' => $errormessages,
				'pv_tablecontents' => $tabrecord,
				'pv_removedrecord' => $removedrecord );
		}
		else
		{
			# Unknown or empty action
			$templatef = $templatee;
			$self->tt_params(
				'pv_titlename' => ucfirst $tablename,
				'pv_tablename' => $tablename,
				'pv_fieldname' => $mastertab->field(),
				'pv_isreadonly' => $tableisro,
				'pv_contentsname' => 'table',
				'pv_tablecontents' => [ {
					'name' => $tablename,
					'description' => 'Unknown or empty action.', }
				],
			);

		} # End of if($action)
	}
	else
	{
		# Invalid table name
		$templatef = $templatee;
		$self->tt_params(
			'pv_titlename' => ucfirst $tablename,
			'pv_tablename' => $tablename,
			'pv_fieldname' => 'unknown',
			'pv_isreadonly' => $tableisro,
			'pv_contentsname' => 'table',
			'pv_tablecontents' => [ {
				'name' => $tablename,
				'description' => 'Unknown table name.', }
			],
		);

	} # End of if($table)

	return $self->tt_process($templatef);
}

1;
__END__
