# $Id: Test.pm,v 1.23.2.4 2011/10/10 09:52:34 ak Exp $
# -Id: Test.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Test.pm,v 1.10 2009/08/17 12:39:31 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                               
 ######                  ##    
   ##     ####   ##### ######  
   ##    ##  ## ##       ##    
   ##    ######  ####    ##    
   ##    ##         ##   ##    
   ##     ####  #####     ###  
package Kanadzuchi::UI::Web::Test;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::Mail::Stored::YAML;
use Kanadzuchi::Metadata;
use Time::Piece;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub puttestform
{
	# +-+-+-+-+-+-+-+-+-+-+-+
	# |p|u|t|t|e|s|t|p|a|g|e|
	# +-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Test pagsing page
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'test.html';
	$self->tt_params( 
		'pv_maxsize' => $self->{'webconfig'}->{'upload'}->{'maxsize'}
	);
	return $self->tt_process($file);
}

sub onlineparser
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	# |o|n|l|i|n|e|p|a|r|s|e|r|
	# +-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Execute test parsing on the web.
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'iframe-parseddata.html';
	my $cgiq = $self->query();
	my $data = [];

	my $emailfile = $cgiq->param('fe_emailfile') || q();
	my $emailtext = $cgiq->param('fe_emailtext') || q();

	if( $emailfile || length $emailtext )
	{
		require Kanadzuchi::Mail::Bounced;
		require Kanadzuchi::Mbox;
		require Path::Class;
		require File::Spec;

		my $objzcimbox = undef();	# (Kanadzuchi::Mbox) Mailbox object
		my $mpiterator = undef();	# (Kanadzuchi::Iterator) Iterator for mailbox parser
		my $damnedobjs = [];		# (Ref->Array) Damned hash references 
		my $datasource = q();		# (String) Email text as data source
		my $errortitle = q();		# (String) Error string
		my $sizeofmail = 0;		# (Integer) Size of email file and text
		my $first5byte = q();		# (String) First 5bytes data of mail
		my $serialized = q();		# (String) Serialized data text(YAML|JSON)

		my $kanadzuchi = $self->{'kanadzuchi'};
		my $pseudofrom = q(From MAILER-DAEMON Sun Dec 31 23:59:59 2000).qq(\n);
		my $fileconfig = $self->{'sysconfig'}->{'file'}->{'templog'};
		my $maxtxtsize = $self->{'webconfig'}->{'upload'}->{'maxsize'};
		my $dataformat = $cgiq->param('fe_format') || 'html';
		my $parseuntil = $cgiq->param('fe_parsenmessages') || 10;

		my $registerit = ( defined $cgiq->param('fe_register') && $cgiq->param('fe_register') ) eq 'on' ? 1 : 0;
		my $execstatus = {
			'update' => 0, 'insert' => 0, 'tooold' => 0, 'exceed' => 0,
			'failed' => 0, 'nofrom' => 0, 'whited' => 0, };

		my $sourcelist = [];		# (Ref->Array) Data source names
		my $givenctype = q();		# (String) Content-Type of the email file
		my $givenemail = $emailfile || undef();
		my $pastedmail = $emailtext || q();

		# Read email from uploaded file
		if( ref $givenemail && -s $givenemail )
		{
			READ_EMAIL_FILE: while(1)
			{
				push( @$sourcelist, $givenemail );
				$sizeofmail = -s $givenemail;
				$givenctype = lc $cgiq->uploadInfo( $givenemail )->{'Content-Type'} || 'text/plain';
				$errortitle = 'toobig' if( $maxtxtsize > 0 && length $sizeofmail > $maxtxtsize );
				$errortitle = 'nottext' if( $givenctype =~ m{\A(audio|application|image|video)/}m );
				last() if( $errortitle );

				# Check first 5bytes of the email
				read( $givenemail, $first5byte, 5 );
				seek( $givenemail, 0, 0 );
				$datasource .= $pseudofrom unless( $first5byte eq 'From ' );

				READ: while( my $__thisline = <$givenemail> )
				{
					$__thisline =~ s{(\x0d\x0a|\x0d|\x0a)}{\n}gm;		# CRLF, CR -> LF
					next() if( $__thisline =~ m{\A[a-zA-Z0-9+/=]+\z}gm );	# Skip if it is Base64 encoded text
					$datasource .= $__thisline;

				} # End of while(READ)

				$datasource .= qq(\n);
				last();

			} # Enf of while(READ_EMAIL_FILE)
		}

		# Read email from pasted text
		if( length $pastedmail )
		{
			$sizeofmail += length($pastedmail);
			$first5byte  = substr( $pastedmail, 0, 5 );
			$datasource .= $pseudofrom unless( $first5byte eq 'From ' );
			$datasource .= $pastedmail;
			push( @$sourcelist, 'Pasted email test' );
		}

		# Check the size of email text
		$errortitle = 'nosize' if( $sizeofmail == 0 );
		$errortitle = 'toobig' if( $maxtxtsize > 0 && length($datasource) > $maxtxtsize );

		if( $errortitle )
		{
			$kanadzuchi->historique('err', 
				'stat='.( $errortitle eq 'nosize' ? 'mailbox is empty' : 'mailbox is too big').
				'name='.$self->{'configname'} );
			$self->e( $errortitle );
		}

		SLURP_AND_EAT: while(1)
		{
			last() if( $errortitle );
			my $temporaryd = ( -w '/tmp' ? '/tmp' : File::Spec->tmpdir() );
			my $counter4id = 0;

			# Slurp , parse, and eat
			$objzcimbox = new Kanadzuchi::Mbox( 'file' => \$datasource );
			$objzcimbox->greed(1);
			$objzcimbox->slurpit() || last();
			$objzcimbox->parseit() || last();
			$mpiterator = Kanadzuchi::Mail::Bounced->eatit( 
					$objzcimbox, [], { 'cache' => $temporaryd, 'verbose' => 0, 'fast' => 1, } );

			unless( $mpiterator->count() )
			{
				$kanadzuchi->historique('err',
					sprintf("stat=there is no bounced email, name=%s",
						$self->{'configname'} ));
				last();
			}

			if( $mpiterator->count > $parseuntil )
			{
				splice( @{ $mpiterator->data }, $parseuntil );
				$mpiterator->count( scalar @{ $mpiterator->data } );
				$kanadzuchi->historique('warn',
					sprintf("stat=too many emails, name=%s", 
						$self->{'configname'} ));
			}

			# syslog
			$kanadzuchi->historique( 'info',
				sprintf( "size=%d, emails=%d, bounces=%d, parsed=%d, output=%s, stat=ok, name=%s",
					$sizeofmail, $objzcimbox->nmails(), $objzcimbox->nmesgs(), 
					$mpiterator->count(), $dataformat, $self->{'configname'} ));

			# Convert from object to hash reference
			if( $dataformat eq 'html' )
			{
				#      __    _   _ _____ __  __ _     
				#      \ \  | | | |_   _|  \/  | |    
				#  _____\ \ | |_| | | | | |\/| | |    
				# |_____/ / |  _  | | | | |  | | |___ 
				#      /_/  |_| |_| |_| |_|  |_|_____|
				#                                     
				LOAD_AND_DAMN: while( my $o = $mpiterator->next() )
				{
					my $eachdamned = $o->damn();
					my $tmpupdated = new Time::Piece();

					# Human readable date string
					$eachdamned->{'id'} = sprintf( "TEMP-%03d", ++$counter4id );
					$eachdamned->{'updated'}  = $tmpupdated->ymd().'('.$tmpupdated->wdayname().') '.$tmpupdated->hms();
					$eachdamned->{'bounced'}  = $o->bounced->ymd().'('.$o->bounced->wdayname().') '.$o->bounced->hms();
					$eachdamned->{'bounced'} .= ' '.$o->timezoneoffset() if( $o->timezoneoffset() );
					push( @$damnedobjs, $eachdamned );
				}
			}
			else
			{
				#      __   __   __ _    __  __ _       _       _ ____   ___  _   _ 
				#      \ \  \ \ / // \  |  \/  | |     | |     | / ___| / _ \| \ | |
				#  _____\ \  \ V // _ \ | |\/| | |     | |  _  | \___ \| | | |  \| |
				# |_____/ /   | |/ ___ \| |  | | |___  | | | |_| |___) | |_| | |\  |
				#      /_/    |_/_/   \_\_|  |_|_____| | |  \___/|____/ \___/|_| \_|
				#                                      |_|                          
				# Create serialized data for the format YAML or JSON, CSV
				require Kanadzuchi::Log;
				my $kanazcilog = Kanadzuchi::Log->new();

				$kanazcilog->count( $mpiterator->count() );
				$kanazcilog->format( $dataformat );
				$kanazcilog->entities( $mpiterator->all() );
				$serialized = $kanazcilog->dumper();
			}

			if( $registerit )
			{
				#      __    ____    _  _____  _    ____    _    ____  _____ 
				#      \ \  |  _ \  / \|_   _|/ \  | __ )  / \  / ___|| ____|
				#  _____\ \ | | | |/ _ \ | | / _ \ |  _ \ / _ \ \___ \|  _|  
				# |_____/ / | |_| / ___ \| |/ ___ \| |_) / ___ \ ___) | |___ 
				#      /_/  |____/_/   \_\_/_/   \_\____/_/   \_\____/|_____|
				#                                                            
				require Kanadzuchi::BdDR::BounceLogs;
				require Kanadzuchi::BdDR::BounceLogs::Masters;
				require Kanadzuchi::BdDR::Cache;
				require Kanadzuchi::BdDR::DailyUpdates;
				require Kanadzuchi::Mail::Stored::YAML;
				require Kanadzuchi::Mail::Stored::BdDR;

				my $tablecache = undef();	# (Kanadzuchi::BdDR::Cache) Table cache object
				my $xntableobj = undef();	# (Kanadzuchi::BdDR::BounceLogs::Table) Txn table object
				my $mastertabs = {};		# (Ref->Hash) Kanadzuchi::BdDR::BounceLogs::Masters::Table objects
				my $xntabalias = q();		# (String) lower cased txn table alias

				my $dupdataobj = undef();	# (Kanadzuchi::BdDR::DailyUpdates::Data) Daily Updates
				my $dupdatarec = 0;		# (Integer) The number of data in the t_dailyupdates tables
				my $theupdated = {};		# (Ref->Hash) Data for Daily Updates
				my $tobupdated = [];

				my $recinthedb = 0;		# (Integer) The number of records in the db
				my $okorfailed = q();		# (String) OK or Failed
				my $bddrobject = $self->{'database'};
				my $xsoftlimit = $self->{'sysconfig'}->{'database'}->{'table'}->{'bouncelogs'}->{'maxrecords'} || 0;
				my $yamlkeymap = { 'inserted' => 'insert', 'updated' => 'update', 'failed' => 'failed' };

				$mpiterator->reset();
				$tablecache = Kanadzuchi::BdDR::Cache->new();
				$xntableobj = Kanadzuchi::BdDR::BounceLogs::Table->new( 'handle' => $bddrobject->handle() );
				$mastertabs = Kanadzuchi::BdDR::BounceLogs::Masters::Table->mastertables( $bddrobject->handle() );

				$xntabalias = lc $xntableobj->alias();
				$recinthedb = $xntableobj->count();

				$dupdataobj = Kanadzuchi::BdDR::DailyUpdates::Data->new( 'handle' => $bddrobject->handle() );
				$dupdatarec = $dupdataobj->db->count();	# Dummy connection for detecting the table

				DATABASECTL: while( my $o = $mpiterator->next() )
				{
					my $thiscached = {};		# (Ref->Hash) Cached data of each table
					my $thisdateis = q();		# (String) This date: e.g.) 2009-04-29
					my $thismtoken = q();		# (String) This record's message token
					my $thismepoch = 0;		# (Integer) Bounced time
					my $thisstatus = 0;		# (Integer) Returned status value
					my $execinsert = 0;		# (Integer) Flag; Exec INSERT

					bless( $o, q|Kanadzuchi::Mail::Stored::YAML| );

					# Check limit the number of records
					if( $xsoftlimit > 0 && ( $execstatus->{'insert'} + $recinthedb) >= $xsoftlimit )
					{
						# Exceeds limit!
						$execstatus->{'exceed'}++;
						next();
					}

					# Check cached data
					$thismtoken = $o->token();
					$thismepoch = $o->bounced->epoch();
					$thisdateis = $o->bounced->ymd('-');
					$thiscached = $tablecache->getit( $xntabalias, $thismtoken );

					if( exists($thiscached->{'bounced'}) )
					{
						# Cache hit!
						# This record's bounced date is OLDER THAN the record in the cache.
						if( $thiscached->{'bounced'} >= $thismepoch )
						{
							$execstatus->{'tooold'}++;
							$theupdated->{$thisdateis}->{'skipped'}++;
							next();
						}
					}
					else
					{
						# No cache data of this entity
						if( $o->findbytoken($xntableobj,$tablecache) )
						{
							# The record that has same token exists in the database
							$thiscached = $tablecache->getit( $xntabalias, $thismtoken );

							if( $thiscached->{'bounced'} >= $thismepoch )
							{
								# This record's bounced date is older than the record in the database.
								$execstatus->{'tooold'}++;
								$theupdated->{$thisdateis}->{'skipped'}++;
								next();
							}
							elsif( $thiscached->{'reason'} eq 'whitelisted' )
							{
								# The whitelisted record is not updated without --force option.
								$execstatus->{'whited'}++;
								$theupdated->{$thisdateis}->{'skipped'}++;
								next();
							}
						}
						else
						{
							# Record that have same token DOES NOT EXIST in the database
							# Does the senderdomain exist in the mastertable?
							if( $mastertabs->{'senderdomains'}->getidbyname($o->senderdomain()) )
							{
								$execinsert = 1;
							}
							else
							{
								# The senderdomain DOES NOT EXIST in the mastertable
								$execstatus->{'nofrom'}++;
								$theupdated->{$thisdateis}->{'skipped'}++;
								next();
							}
						}
					}

					# UPDATE OR INSERT
					if( $execinsert )
					{
						# INSERT this record INTO the database
						$thisstatus = $o->insert( $xntableobj, $mastertabs, $tablecache );
						$okorfailed = ( $thisstatus > 0 ) ? 'inserted' : 'failed';
					}
					else
					{
						# UPDATE
						$thisstatus = $o->update( $xntableobj, $tablecache );
						$okorfailed = ( $thisstatus == 1 ) ? 'updated' : 'failed';
					}

					$execstatus->{ $yamlkeymap->{ $okorfailed } }++;
					$theupdated->{ $thisdateis }->{ $okorfailed }++;

				} # End of while(DATABASECTL)

				if( $dupdataobj->db->{'error'}->{'count'} == 0 )
				{
					foreach my $d ( keys %$theupdated )
					{
						push( @$tobupdated, { 
								'thedate' => $d,
								'inserted' => $theupdated->{$d}->{'inserted'} || 0,
								'updated' => $theupdated->{$d}->{'updated'} || 0,
								'skipped' => $theupdated->{$d}->{'skipped'} || 0,
								'failed' => $theupdated->{$d}->{'failed'} || 0,
							} );
					}

					$dupdatarec = $dupdataobj->recordit($tobupdated);
				}

				# syslog
				$kanadzuchi->historique('info',
					sprintf("logs=WebUI, records=%d, inserted=%d, updated=%d, skipped=%d, failed=%d, mode=update, stat=ok, name=%s",
						$mpiterator->count(), $execstatus->{'insert'}, $execstatus->{'update'}, 
						($execstatus->{'nofrom'} + $execstatus->{'tooold'} + $execstatus->{'whited'} + $execstatus->{'exceed'}),
						$dupdataobj->db->{'error'}->{'count'}, $self->{'configname'} ));

			} # End of if(REGISTERIT)

			last(SLURP_AND_EAT);

		} # End of while(SLURP_AND_EAT)

		$self->tt_params( 
			'pv_bouncemessages' => $damnedobjs,
			'pv_parseddatatext' => $serialized,
			'pv_parsedfilename' => join( ',', @$sourcelist ),
			'pv_parsedfilesize' => $datasource ? length($datasource) : $sizeofmail,
			'pv_parsedmessages' => defined($mpiterator) ? $mpiterator->count() : 0,
			'pv_outputformat' => $dataformat,
			'pv_onlineparse' => 1,
			'pv_onlineupdate' => $registerit,
			'pv_updateresult' => $execstatus,
			'pv_parseerror' => $errortitle );
		return $self->tt_process($file);
	}
}

1;
__END__
