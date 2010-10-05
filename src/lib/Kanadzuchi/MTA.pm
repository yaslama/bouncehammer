# $Id: MTA.pm,v 1.3 2010/10/05 11:09:56 ak Exp $
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
use Kanadzuchi::RFC2822;
use Kanadzuchi::RFC3463;
use Kanadzuchi::Address;

sub xsmtpcommand { 'X-SMTP-Command: '; }
sub emailheaders { return []; }
sub reperit { return q(); }

1;
__END__
