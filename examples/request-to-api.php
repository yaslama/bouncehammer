<?php
// $Id: request-to-api.php,v 1.2 2010/07/13 09:08:31 ak Exp $

// Message token
$addresser = 'sender01@example.jp';
$recipient = 'user01@example.org';
$mesgtoken = md5(sprintf( "\x02%s\x1e%s\x03", $addresser, $recipient ));
$queryhost = 'http://apitest.bouncehammer.jp/modperl/a.cgi';
$response = file($queryhost.'/select/'.$mesgtoken);
$metadata = json_decode(implode($response),TRUE);
foreach ($metadata as $j )
{
	echo $j['recipient'].': '.$j['reason']."\n";
}

// Recipient
$response = file($queryhost.'/search/recipient/'.$recipient);
$metadata = json_decode(implode($response),TRUE);
foreach ($metadata as $j )
{
	echo $j['recipient'].': '.$j['reason']."\n";
}

?>
