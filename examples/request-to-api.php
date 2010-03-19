<?php
// $Id: request-to-api.php,v 1.1 2010/03/19 11:06:59 ak Exp $
$addresser = 'sender01@example.jp';
$recipient = 'user01@example.org';
$mesgtoken = md5(sprintf( "\x02%s\x1e%s\x03", $addresser, $recipient ));
$queryhost = 'http://apitest.bouncehammer.jp/index.cgi/query/';
$response = file($queryhost.$mesgtoken);
$metadata = json_decode(implode($response),TRUE);

foreach ($metadata as $j )
{
	echo $j['recipient'].': '.$j['reason']."\n";
}

?>
