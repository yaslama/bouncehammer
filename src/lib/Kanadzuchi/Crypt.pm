# $Id: Crypt.pm,v 1.1 2010/08/28 17:10:29 ak Exp $
# -Id: Index.pm,v 1.7 2010/07/11 06:48:03 ak Exp -
# -Id: Index.pm,v 1.1 2009/08/29 09:30:33 ak Exp -
# -Id: Index.pm,v 1.3 2009/08/13 07:13:57 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                                    
  ####                        ##    
 ##  ## #####  ##  ## ##### ######  
 ##     ##  ## ##  ## ##  ##  ##    
 ##     ##     ##  ## ##  ##  ##    
 ##  ## ##      ##### #####   ##    
  ####  ##        ##  ##       ###  
               ####   ##            
package Kanadzuchi::Crypt;
use base 'Class::Accessor::Fast::XS';
use strict;
use warnings;
use Crypt::CBC;
use Compress::Zlib;

#  ____ ____ ____ ____ ____ ____ ____ ____ ____ 
# ||A |||c |||c |||e |||s |||s |||o |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
__PACKAGE__->mk_accessors(
	'salt',		# (String) Salt for encryption
	'key',		# (String) Secret key
	'cipher',	# (String) Cipher type
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
	# @Return	Kanadzuchi::Crypt Object
	my $class = shift();
	my $argvs = { @_ };
	my $lname = $argvs->{'cipher'} || 'DES';
	my $lpath = 'Crypt/'.$lname.'.pm';

	eval { require $lpath; };
	return $class->SUPER::new($argvs) unless $@;
	return undef();
}

#  ____ ____ ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ ____ ____ ____ 
# ||I |||n |||s |||t |||a |||n |||c |||e |||       |||M |||e |||t |||h |||o |||d |||s ||
# ||__|||__|||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
#
sub cryptcbc
{
	# +-+-+-+-+-+-+-+-+
	# |c|r|y|p|t|c|b|c|
	# +-+-+-+-+-+-+-+-+
	#
	# @Description	Encrypt/Decrypt text|data
	# @Param <str>	(String) Plain text|Encrypted data
	# @Param <flg>	(Character) e = Encrypt, d = Decrypt
	# @Return	(String) Encrypted hex string
	#		(String) Decrypted plain text
	my $self = shift();
	my $data = shift() || q();
	my $flag = shift() || 'e';

	my $hakata = $self->{'salt'} || 'kanadzuchi';
	my $seckey = $self->{'key'} || '794-Uguisu-Heiankyo';
	my $cipher = $self->{'cipher'} || 'DES';
	my $ocrypt = Crypt::CBC->new(
			'-key' => $seckey,
			'-cipher' => $cipher );

	if( $flag eq 'e' )
	{
		$ocrypt->salt($hakata);
		return $ocrypt->encrypt_hex( Compress::Zlib::compress($data) )
	}
	elsif( $flag eq 'd' )
	{
		return Compress::Zlib::uncompress( $ocrypt->decrypt_hex($data) );
	}
}

sub encryptit
{
	# +-+-+-+-+-+-+-+-+-+
	# |e|n|c|r|y|p|t|i|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Wrapper method of cryptcbc()
	# @Param <str>	(String) Plain text
	# @Return	(String) Encrypted hex string
	# @See		cryptcbc()
	my( $self, $data ) = @_;
	return $self->cryptcbc( $data, 'e' );
}

sub decryptit
{
	# +-+-+-+-+-+-+-+-+-+
	# |d|e|c|r|y|p|t|i|t|
	# +-+-+-+-+-+-+-+-+-+
	#
	# @Description	Wrapper method of cryptcbc()
	# @Param <str>	(String) Encrypted text(hex)
	# @Return	(String) Plain text
	# @See		cryptcbc()
	my( $self, $data ) = @_;
	return $self->cryptcbc( $data, 'd' );
}

1;
__END__
