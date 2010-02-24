# $Id: TestRun.pm,v 1.4 2010/02/21 20:25:02 ak Exp $
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::Config::
                                                    
 ######                  ##   #####                 
   ##     ####   ##### ###### ##  ## ##  ## #####   
   ##    ##  ## ##       ##   ##  ## ##  ## ##  ##  
   ##    ######  ####    ##   #####  ##  ## ##  ##  
   ##    ##         ##   ##   ## ##  ##  ## ##  ##  
   ##     ####  #####     ### ##  ##  ##### ##  ##  
package Kanadzuchi::Config::TestRun;
use strict;
use warnings;
use Kanadzuchi;

#  ____ ____ ____ ____ ____ ____ _________ ____ ____ ____ ____ 
# ||G |||l |||o |||b |||a |||l |||       |||v |||a |||r |||s ||
# ||__|||__|||__|||__|||__|||__|||_______|||__|||__|||__|||__||
# |/__\|/__\|/__\|/__\|/__\|/__\|/_______\|/__\|/__\|/__\|/__\|
#
our $Configuration = {
	'system'	=> 'BounceHammer',
	'version'	=> $Kanadzuchi::VERSION,
	'file'		=> {
		'maxsize' => { 'cli' => 0, 'web' => 524288, },
		'templog' => { 'prefix' => 'hammer', 'suffix' => 'tmp' },
		'storage' => { 'prefix' => 'hammer', 'suffix' => 'log' },
	},
	'directory'	=> {
		'conf'	=> '/tmp',
		'pid'	=> '/tmp',
		'log'	=> '/tmp',
		'tmp'	=> '/tmp/',
		'cache'	=> '/tmp',
		'spool'	=> '/tmp',
		'incoming' => '/tmp',
	},
};

1;
__END__
