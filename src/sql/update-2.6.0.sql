UPDATE t_reasons SET why = 'rejected', description = 'Bad sender address(x.1.8)' WHERE( id = 7 AND why = '_reserved-07');
UPDATE t_reasons SET why = 'expired', description = 'Delivery time expired(x.4.7)' WHERE( id = 8 AND why = '_reserved-08');
UPDATE t_reasons SET why = 'systemerror', description = 'Mail system or network error(x.3.5)' WHERE( id = 16 AND why = '_reserved-16');
INSERT INTO t_reasons VALUES( 20, 'contenterr', 'Content error(x.6.x)', 0 );
