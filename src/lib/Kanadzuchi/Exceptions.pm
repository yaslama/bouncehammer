# $Id: Exceptions.pm,v 1.3 2010/03/01 23:41:41 ak Exp $
# -Id: Exceptions.pm,v 1.2 2009/10/04 13:41:27 ak Exp -
# -Id: Exceptions.pm,v 1.3 2009/06/05 22:54:12 ak Exp -
# Copyright (C) 2009,2010 Cubicroot Co. Ltd.
# Kanadzuchi::

 ######                           ##    ##                        
 ##     ##  ## #### ####  ##### ######       ####  #####   #####  
 ####    #### ##   ##  ## ##  ##  ##   ###  ##  ## ##  ## ##      
 ##       ##  ##   ###### ##  ##  ##    ##  ##  ## ##  ##  ####   
 ##      #### ##   ##     #####   ##    ##  ##  ## ##  ##     ##  
 ###### ##  ## #### ####  ##       ### ####  ####  ##  ## #####   
                          ##                                      
package Kanadzuchi::Exceptions;
1;

package Kanadzuchi::Exception::IO;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('I/O Error'); }
1;

package Kanadzuchi::Exception::File;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Invalid Format'); }
1;

package Kanadzuchi::Exception::System;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('System Error'); }
1;

package Kanadzuchi::Exception::Data;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Data Format Error'); }
1;

package Kanadzuchi::Exception::Command;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Command Error'); }
1;

package Kanadzuchi::Exception::Permission;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Permission Denied'); }
1;

package Kanadzuchi::Exception::Security;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Security Risk'); }
1;

package Kanadzuchi::Exception::Database;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Database Error'); }
1;

package Kanadzuchi::Exception::Config;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Invalid Configuration'); }
1;

package Kanadzuchi::Exception::Network;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Network Connection Error'); }
1;

package Kanadzuchi::Exception::Web;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('Internal Error'); }
1;

package Kanadzuchi::Exception::API;
use base 'Error';
use overload '""' => sub { shift->stacktrace };
sub head { my $self = shift(); return('API Error'); }
1;

__END__
