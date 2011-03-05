# $Id: TestRun.pm,v 1.8.2.3 2011/03/05 10:28:52 ak Exp $
# -Id: TestRun.pm,v 1.4 2009/09/01 23:19:46 ak Exp -
# -Id: TestRun.pm,v 1.2 2009/08/27 05:09:32 ak Exp -
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
sub configuration {
	return {
		'system'	=> 'bounceHammer',
		'version'	=> $Kanadzuchi::VERSION,
		'name'		=> 'Test Run',
		'file'		=> {
			'maxsize' => 0,
			'templog' => { 'prefix' => 'hammer', 'suffix' => 'tmp' },
			'storage' => { 'prefix' => 'hammer', 'suffix' => 'log' },
		},
		'directory'	=> {
			'conf'	=> '/tmp',
			'pid'	=> '/tmp',
			'log'	=> '/tmp',
			'tmp'	=> '/tmp',
			'cache'	=> '/tmp',
			'spool'	=> '/tmp',
			'incoming' => '/tmp',
		},
		'environment'	=> { 'timeout' => 60, },
		'syslog'	=> { 'enabled' => 0, 'facility' => 'user' }
	};
}

1;
__END__
