INSERT INTO t_addressers ( email, description ) VALUES( 'sender01@example.jp', 'Example User No.1' );
INSERT INTO t_addressers ( email, description ) VALUES( 'sender02@example.jp', 'Example User No.2' );
INSERT INTO t_senderdomains (domainname, description ) VALUES( 'example.jp','Example Domain(JP)');
INSERT INTO t_destinations ( domainname, description ) VALUES( 'example.org', 'Example(ORG)');
INSERT INTO t_bouncelogs 
	( addresser, recipient, senderdomain, destination, token, bounced, updated, hostgroup, provider, reason, description )
	VALUES
	( 1, 'user01@example.org', 1, 1, '0c1f60a7c2b7e2d12d3f2bc29e310274', 1234567890, 1234567899, 2, 1, 2,
		'{ "deliverystatus": 500, "timezoneoffset": "+0900", "diagnosticcode": "Example1" }' );
INSERT INTO t_bouncelogs 
	( addresser, recipient, senderdomain, destination, token, bounced, updated, hostgroup, provider, reason, description )
	VALUES
	( 2, 'user02@example.org', 1, 1, '6b364965626bf70b9c91aadd3cd591c3', 1011121314, 1012141618, 2, 2, 3, 
		'{ "deliverystatus": 522, "timezoneoffset": "-0400", "diagnosticcode": "Example2" }' );
