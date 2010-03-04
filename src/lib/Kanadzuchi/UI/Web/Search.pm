# $Id: Search.pm,v 1.18 2010/03/04 08:35:42 ak Exp $
# -Id: Search.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Search.pm,v 1.11 2009/08/13 07:13:58 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                           
  #####                            ##      
 ###      ####  ####  #####   #### ##      
  ###    ##  ##    ## ##  ## ##    #####   
   ###   ###### ##### ##     ##    ##  ##  
    ###  ##    ##  ## ##     ##    ##  ##  
 #####    ####  ##### ##      #### ##  ##  
package Kanadzuchi::UI::Web::Search;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub search_ontheweb
{
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	# |s|e|a|r|c|h|_|o|n|t|h|e|w|e|b|
	# +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	#
	# @Description	Send query and receive results
	# @Param	<None>
	# @Return
	require Kanadzuchi::Mail::Stored::RDB;

	my $self = shift();
	my $aref = [];			# Array reference of '$href's
	my $file = q(search.).$self->{'language'}.q(.html);

	my $paramsinthequery = {};	# Parameters in the query
	my $errorsinthequery = {};	# Parameter errors in the query
	my $pagersinthequery = {};	# Pager settings in the query
	my $hassearchcondition = 0;	# Does advanced search use?
	my $encryptedcondition = q();	# Encrypted condition in PAHT_INFO
	my $decryptedcondition = q();	# Decrypted condition(YAML)

	my $enabledownload = 0;		# Download flag
	my $requiresobject = 0;		# searchandnew() Requires object
	my $downloadformat = q();	# File fotmat for downloading

	# Do not include a record that is disabled(=1)
	$paramsinthequery->{'disabled'} = 0;

	if( $self->param('pi_condition') || $self->param('pi_recipient') )
	{
		#  _____ _   _  ____ ______   ______ _____ _____ ____  
		# | ____| \ | |/ ___|  _ \ \ / /  _ \_   _| ____|  _ \ 
		# |  _| |  \| | |   | |_) \ V /| |_) || | |  _| | | | |
		# | |___| |\  | |___|  _ < | | |  __/ | | | |___| |_| |
		# |_____|_| \_|\____|_| \_\|_| |_|    |_| |_____|____/ 
		# 
		# Check and decrypt the encrypted condition
		require Kanadzuchi::Mail::Stored::YAML;

		if( $self->param('pi_condition') )
		{
			$encryptedcondition = $self->param('pi_condition');
			$hassearchcondition++;
		}
		else
		{
			$encryptedcondition = $self->param('pi_recipient');
		}

		$decryptedcondition = $self->decryptit($encryptedcondition);
		my $_ar = Kanadzuchi::Mail::Stored::YAML->loadandnew($decryptedcondition);

		foreach my $__s ( @{$_ar} )
		{
			last() if( ref($__s) ne q|HASH| );
			$paramsinthequery = $__s;

			# Multi-plex condition is not implemented yet.
			last();	
		}

		#   ___  ____  ____  _____ ____    ______   __
		#  / _ \|  _ \|  _ \| ____|  _ \  | __ ) \ / /
		# | | | | |_) | | | |  _| | |_) | |  _ \\ V / 
		# | |_| |  _ <| |_| | |___|  _ <  | |_) || |  
		#  \___/|_| \_\____/|_____|_| \_\ |____/ |_|  
		#                                             
		if( $self->param('pi_orderby') )
		{
			my $_name = q(); my $_desc = 0;

			if( $self->param('pi_orderby') =~ m{\A(.+)[,]([01])\z} )
			{
				$_name = $1;
				$_desc = $2;
			}
			$pagersinthequery->{'colnameorderby'} = lc($_name) || q(id);
			$pagersinthequery->{'descendorderby'} = $_desc || 0;
		}
		

		# Pager
		$pagersinthequery->{'currentpagenum'} = $self->param('pi_page') || 1;
		$pagersinthequery->{'resultsperpage'} = $self->param('pi_rpp') || 10;

		# Downloading
		if( $ENV{'PATH_INFO'} =~ m{/download} )
		{
			$enabledownload = 1;
			$downloadformat = lc($self->param('pi_format')) || q(yaml);
			$requiresobject = 1;
		}
	}
	else
	{
		#  ____   ___  ____ _____ _____ ____     ___  _   _ _____ ______   __
		# |  _ \ / _ \/ ___|_   _| ____|  _ \   / _ \| | | | ____|  _ \ \ / /
		# | |_) | | | \___ \ | | |  _| | | | | | | | | | | |  _| | |_) \ V / 
		# |  __/| |_| |___) || | | |___| |_| | | |_| | |_| | |___|  _ < | |  
		# |_|    \___/|____/ |_| |_____|____/   \__\_\\___/|_____|_| \_\|_|  
		#
		# Make 'paramsinthequery' hash reference
		require Kanadzuchi::RFC2822;
		my $_r2822 = q|Kanadzuchi::RFC2822|;
		my $_query = $self->query;
		my $_wcond = { 'recipient' => q(), };

		if( length($_query->param('recipient')) )
		{
			# Pre-Process Recipient address
			$_wcond->{'recipient'} =  lc($_query->param('recipient'));
			$_wcond->{'recipient'} =~ y{[;'" ]}{}d;
			$_wcond->{'recipient'} =  $_r2822->cleanup($_wcond->{'recipient'});
		}
		$paramsinthequery->{'recipient'} = $_wcond->{'recipient'};

		foreach my $_w ( 'addresser', 'senderdomain', 'destination', 'token' )
		{
			my $_valid = 0;
			next() unless( defined($_query->param($_w)) );
			($_wcond->{$_w} = lc($_query->param($_w))) =~ y{[;'" ]}{}d;

			$_valid = $_r2822->is_emailaddress($_wcond->{$_w}) if( $_w eq 'addresser' );
			$_valid = $_r2822->is_domainpart($_wcond->{$_w}) if( $_w eq 'senderdomain' || $_w eq 'destination' );
			$_valid = 1 if( $_w eq 'token' && $_wcond->{$_w} =~ m{\A[0-9a-f]{32}\z} );

			if( $_valid )
			{
				$paramsinthequery->{$_w} = $_wcond->{$_w};
				$hassearchcondition++;
			}
			else
			{
				$errorsinthequery->{$_w} = $_wcond->{$_w};
			}
		}

		foreach my $_w ( 'hostgroup', 'reason' )
		{
			if( $_query->param($_w) ne '_' )
			{
				$paramsinthequery->{$_w} = $_query->param($_w);
				$hassearchcondition++;
			}
			else
			{
				$errorsinthequery->{$_w} = q{Unselectable value};
			}
		}

		# How recent the record has been bounced
		if( $_query->param('howrecent') )
		{
			require Kanadzuchi::Time;
			$paramsinthequery->{'bounced'} = Kanadzuchi::Time->to_second($_query->param('howrecent'));

			if( $paramsinthequery->{'bounced'} > 0 && $paramsinthequery->{'bounced'} < time() )
			{
				$paramsinthequery->{'bounced'} = int( time() - $paramsinthequery->{'bounced'} );
			}
			else
			{
				$paramsinthequery->{'bounced'} = 0;
			}
		}

		# Pager
		$pagersinthequery->{'currentpagenum'} = $_query->param('thenextpagenum') || 1;
		$pagersinthequery->{'resultsperpage'} = $_query->param('resultsperpage') || 10;

		# Order
		$pagersinthequery->{'colnameorderby'} = lc($_query->param('orderby')) || q(id);
		$pagersinthequery->{'descendorderby'} = $_query->param('descend') ? 1 : 0;

		# Crypt
		$decryptedcondition = Kanadzuchi::Mail::Stored::RDB->serialize([$paramsinthequery]);
		$encryptedcondition = $self->encryptit($decryptedcondition);

		# Downloading
		$enabledownload = $_query->param('enabledownload') ? 1 : 0;
		$requiresobject = $_query->param('enabledownload') ? 1 : 0;
		$downloadformat = $_query->param('downloadformat') || q(yaml);
	}


	if( $enabledownload )
	{
		#      __    _____ ___ _     _____ 
		#      \ \  |  ___|_ _| |   | ____|
		#  _____\ \ | |_   | || |   |  _|  
		# |_____/ / |  _|  | || |___| |___ 
		#      /_/  |_|   |___|_____|_____|
		#                                  
		use Switch;
		require Kanadzuchi::Log;
		require File::Spec;
		require Path::Class;
		require Digest::MD5;
		require Perl6::Slurp;


		my $_queryp = $self->query;
		my $_config = $self->{'settings'};
		my $_uiconf = $self->{'webconfig'};
		my $_dbconf = $self->{'settings'}->{'database'};

		#  _____ ___  ____  __  __    _  _____ 
		# |  ___/ _ \|  _ \|  \/  |  / \|_   _|
		# | |_ | | | | |_) | |\/| | / _ \ | |  
		# |  _|| |_| |  _ <| |  | |/ ___ \| |  
		# |_|   \___/|_| \_\_|  |_/_/   \_\_|  
		#                                      
		use Kanadzuchi::Archive;
		my $_aclass = q|Kanadzuchi::Archive::|;
		my $_format = $_queryp->param('compress')
				|| $_uiconf->{'archive'}->{'compress'}->{'type'}
				|| Kanadzuchi::Archive->ARCHIVEFORMAT();

		switch( $_format ) {
			case 'gzip' {
				require Kanadzuchi::Archive::Gzip;
				$_aclass = q|Kanadzuchi::Archive::Gzip|;
			}
			case 'bzip2' {
				require Kanadzuchi::Archive::Bzip2;
				$_aclass = q|Kanadzuchi::Archive::Bzip2|;
			}
			case 'zip' {
				require Kanadzuchi::Archive::Zip;
				$_aclass = q|Kanadzuchi::Archive::Zip|;
			}
		}


		#  ___ _   _ ____  _   _ _____ 
		# |_ _| \ | |  _ \| | | |_   _|
		#  | ||  \| | |_) | | | | | |  
		#  | || |\  |  __/| |_| | | |  
		# |___|_| \_|_|    \___/  |_|  
		#                              
		# Decide cache directory
		my $_ifname = undef();		# Input file name
		my $_digest = undef();		# Digest::MD5 Object
		my $_prefix = undef();		# Prefix of the text file
		my $_cached = ( -w $_config->{'directory'}->{'cache'} )
					? $_config->{'directory'}->{'cache'}
					: File::Spec::tmpdir();

		# Prepare empty file(Prefix)
		switch( $downloadformat )
		{
			case 'asciitable' { $_prefix = 'txt'; }
			case [ 'sendmail','postfix' ] { $_prefix = 'access_db'; }
			else { $_prefix = $downloadformat; }
		}

		# Decide source file name
		$_digest = Digest::MD5->new();
		$_digest->add( $_dbconf->{'hostname'}, $_dbconf->{'port'}, $_dbconf->{'dbtype'}, $_dbconf->{'dbname'} );
		$_digest->add( $_prefix, $decryptedcondition );
		$_ifname = $_digest->hexdigest().q{.}.$_prefix;

		#   ___  _   _ _____ ____  _   _ _____ 
		#  / _ \| | | |_   _|  _ \| | | |_   _|
		# | | | | | | | | | | |_) | | | | | |  
		# | |_| | |_| | | | |  __/| |_| | | |  
		#  \___/ \___/  |_| |_|    \___/  |_|  
		#                                      
		my $_efname = lc($_config->{'system'}).q(.).$self->{'datetime'}->ymd('-');
		my $_ofname = $_cached.q{/}.$_ifname;
		my $_zipped = $_aclass->new( 
					'input' => $_cached.q{/}.$_ifname, 
					'output' => $_ofname,
					'filename' => $_efname.q{.}.$_prefix,
					'override' => 1 );

		undef($_digest);
		undef($_cached);
		undef($_ifname);
		undef($_efname);
		undef($_ofname);

		CREATE_FILE: {
			#  ____  _   _ __  __ ____        __  
			# |  _ \| | | |  \/  |  _ \       \ \ 
			# | | | | | | | |\/| | |_) |  _____\ \
			# | |_| | |_| | |  | |  __/  |_____/ /
			# |____/ \___/|_|  |_|_|          /_/ 
			#                                     
			require File::Copy;

			if( -e $_zipped->output() )
			{
				# Is there a cache file?
				my $_exp = Kanadzuchi::Time->to_second($_uiconf->{'archive'}->{'expires'}) || 3600;
				my $_zsz = $_zipped->output->stat->size();
				my $_zmt = $_zipped->output->stat->mtime();
				my $_dzf = q();

				# Use and download the cache file
				if( $_zsz && ( $self->{'datetime'}->epoch() < ( $_zmt + $_exp ) ))
				{
					$_dzf = $_zipped->output->dir().q{/}.$_zipped->filename();
					File::Copy::copy( $_zipped->output(), $_dzf );
					$_zipped->output( new Path::Class::File($_dzf) );
					last();
				}

				# Remove old cache file
				eval { $_zipped->output->remove(); };
			}

			SEARCH_AND_NEW: {

				my( $_tempar, $_templg );

				# Pager and order, and description
				$pagersinthequery->{'currentpagenum'} = 1;
				$pagersinthequery->{'resultsperpage'} = 1000;
				$pagersinthequery->{'colnameorderby'} = lc($_queryp->param('orderby')) || q(id);
				$pagersinthequery->{'descendorderby'} = $_queryp->param('descend') ? 1 : 0; 

				# Search and Print
				$_zipped->input->touch();

				# Send query and receive results
				$_tempar = Kanadzuchi::Mail::Stored::RDB->searchandnew(
						$self->{'database'}, $paramsinthequery, \$pagersinthequery, $requiresobject );
				last() unless( scalar(@$_tempar) );

				$_templg = new Kanadzuchi::Log( 
							'count'	=> scalar(@$_tempar),
							'entities' => $_tempar,
							'device' => $_zipped->input->openw(),
							'format' => $downloadformat, );

				$_templg->header(0);
				$_templg->header(1) if( $pagersinthequery->{'currentpagenum'} == 1 );
				$_templg->dumper();

				last() if( $pagersinthequery->{'currentpagenum'} >= $pagersinthequery->{'lastpagenumber'} );
				$pagersinthequery->{'currentpagenum'}++;

			} # End of the loop
			return(q{No data}) unless( $_zipped->input->stat->size() );

			#   ____ ___  __  __ ____  ____  _____ ____ ____        __  
			#  / ___/ _ \|  \/  |  _ \|  _ \| ____/ ___/ ___|       \ \ 
			# | |  | | | | |\/| | |_) | |_) |  _| \___ \___ \   _____\ \
			# | |__| |_| | |  | |  __/|  _ <| |___ ___) |__) | |_____/ /
			#  \____\___/|_|  |_|_|   |_| \_\_____|____/____/       /_/ 
			#                                                           
			# Compress, and create archive file
			my $_dfname = $_zipped->output->dir().q{/}.$_zipped->filename();
			my $_dzname = $_dfname.q{.}.$_zipped->prefix();

			File::Copy::copy( $_zipped->input(), $_dfname );
			File::Copy::copy( $_zipped->output(), $_dzname );

			$_zipped->input( new Path::Class::File($_dfname) );
			$_zipped->output( new Path::Class::File($_dzname) );
			$_zipped->cleanup(1);
			$_zipped->override(1);
			$_zipped->compress();

			last();

		} # End of the block 'CREATE_FILE'

		# Set size of the archive file
		return(q{Failed to create zip file}) unless( $_zipped->output->stat->size() );

		#  ____   _____        ___   _ _     ___    _    ____        __  
		# |  _ \ / _ \ \      / / \ | | |   / _ \  / \  |  _ \       \ \ 
		# | | | | | | \ \ /\ / /|  \| | |  | | | |/ _ \ | | | |  _____\ \
		# | |_| | |_| |\ V  V / | |\  | |__| |_| / ___ \| |_| | |_____/ /
		# |____/ \___/  \_/\_/  |_| \_|_____\___/_/   \_\____/       /_/ 
		#                                                                
		# eval { $_textfile->path->remove(); };
		$self->header_props(
			'-type' => q(application/octet-stream),
			'-content-disposition' => q(attachment;filename=).$_zipped->output->basename(),
			'-content-length' => $_zipped->output->stat->size(),
		);
		return( Perl6::Slurp::slurp( $_zipped->output->stringify() ) );
	}
	else
	{
		#      __    _   _ _____ __  __ _     
		#      \ \  | | | |_   _|  \/  | |    
		#  _____\ \ | |_| | | | | |\/| | |    
		# |_____/ / |  _  | | | | |  | | |___ 
		#      /_/  |_| |_| |_| |_|  |_|_____|
		#                                     
		# Send query and receive results
		$aref = Kanadzuchi::Mail::Stored::RDB->searchandnew(
				$self->{'database'}, $paramsinthequery, \$pagersinthequery, $requiresobject );
		$self->tt_params( 
			'bouncemessages' => $aref,
			'hascondition' => $hassearchcondition,
			'searchcondition' => $paramsinthequery,
			'encryptedforuri' => $encryptedcondition,
			'pagersinthequery' => $pagersinthequery,
			'errorsinthequery' => $errorsinthequery, );
		$self->tt_process($file);
	}
}

1;
__END__
