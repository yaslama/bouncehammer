# $Id: Token.pm,v 1.6 2010/08/28 17:22:09 ak Exp $
# -Id: Digest.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Digest.pm,v 1.4 2009/08/13 07:13:57 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::UI::Web::
                                     
 ######         ##                   
   ##     ####  ##     ####  #####   
   ##    ##  ## ## ## ##  ## ##  ##  
   ##    ##  ## ####  ###### ##  ##  
   ##    ##  ## ## ## ##     ##  ##  
   ##     ####  ##  ## ####  ##  ##  
package Kanadzuchi::UI::Web::Token;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||L |||i |||b |||r |||a |||r |||i |||e |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
use strict;
use warnings;
use base 'Kanadzuchi::UI::Web';
use Kanadzuchi::String;

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub maketoken
{
	# +-+-+-+-+-+-+-+-+-+
	# |m|a|k|e|t|o|k|e|n|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Make message token
	# @Param	<None>
	# @Return
	my $self = shift();
	my $file = 'messagetoken.html';
	my $cgiq = $self->query();

	if( defined $cgiq->param('fe_makenewtoken') && $cgiq->param('fe_makenewtoken') == 1 )
	{
		$file = 'div-new-message-token.html';
		my $sender = defined $cgiq->param('fe_addresser')
				? lc $cgiq->param('fe_addresser') 
				: q();
		my $recipt = defined $cgiq->param('fe_recipient')
				? lc $cgiq->param('fe_recipient')
				: q();
		my $string = q();
		return $self->e('missingargument') unless( $sender && $recipt );

		$string = Kanadzuchi::String->token( $sender, $recipt );
		return $self->e('failedtocreate') unless $string;

		$self->tt_params( 
			'pv_addresser' => $sender,
			'pv_recipient' => $recipt,
			'pv_token' => $string );
	}

	return $self->tt_process($file);
}

1;
__END__
