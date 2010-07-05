# $Id: MTA.pm,v 1.2 2010/07/04 23:45:35 ak Exp $
# Copyright (C) 2010 Cubicroot Co. Ltd.
# Kanadzuchi::
                     
 ##  ## ###### ##    
 ######   ##  ####   
 ######   ## ##  ##  
 ##  ##   ## ######  
 ##  ##   ## ##  ##  
 ##  ##   ## ##  ##  
package Kanadzuchi::MTA;
use strict;
use warnings;

sub xsmtpcommand { 'X-SMTP-Command: '; }
sub emailheaders { return []; }
sub reperit { return q(); }

1;
__END__
