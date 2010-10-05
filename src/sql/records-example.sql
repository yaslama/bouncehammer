INSERT INTO t_addressers ( email, description ) VALUES( 'sender01@example.jp', 'Example User No.1' );
INSERT INTO t_addressers ( email, description ) VALUES( 'sender02@example.jp', 'Example User No.2' );
INSERT INTO t_senderdomains (domainname, description ) VALUES( 'example.jp','Example Domain(JP)');
INSERT INTO t_destinations ( domainname, description ) VALUES( 'example.org', 'Example(ORG)');
INSERT INTO t_bouncelogs 
	( addresser, recipient, senderdomain, destination, token, bounced, updated, hostgroup, provider, reason, description )
	VALUES
	( 1, 'user01@example.org', 1, 1, '8dbb1b9ce9cc47eb6bb1316096c858cd', 1234567890, 1234567899, 2, 1, 2,
		'{ "deliverystatus": "5.0.0", "timezoneoffset": "+0900", "diagnosticcode": "Example1" }' );
INSERT INTO t_bouncelogs 
	( addresser, recipient, senderdomain, destination, token, bounced, updated, hostgroup, provider, reason, description )
	VALUES
	( 2, 'user02@example.org', 1, 1, 'ac69fa7503ac32dc0291a91fd90e7ea3', 1011121314, 1012141618, 2, 2, 3, 
		'{ "deliverystatus": "5.2.2", "timezoneoffset": "-0400", "diagnosticcode": "Example2" }' );
