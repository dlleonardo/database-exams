/*
 * Scrivere una query che restituisca le coppie mese-anno del triennio 2013-2015 caratterizzate da terapie tutte
 * iniziate e concluse nello stesso mese, a prescindere dall’esito.
*/
SELECT DISTINCT MONTH(T.DataInizioTerapia),
	   YEAR(T.DataInizioTerapia)
FROM Terapia T
WHERE T.DataFineTerapia IS NOT NULL
	  AND YEAR(T.DataInizioTerapia) BETWEEN 2013 AND 2015
	  OR  (
		   YEAR(T.DataInizioTerapia) = 2013
           AND YEAR(T.DataFineTerapia) = 2013
           AND MONTH(T.DataInizioTerapia) = MONTH(T.DataFineTerapia)
		  )
	  OR (
		   YEAR(T.DataInizioTerapia) = 2014
           AND YEAR(T.DataFineTerapia) = 2014
           AND MONTH(T.DataInizioTerapia) = MONTH(T.DataFineTerapia)      
		  )
	  OR (
		   YEAR(T.DataInizioTerapia) = 2015
           AND YEAR(T.DataFineTerapia) = 2015
           AND MONTH(T.DataInizioTerapia) = MONTH(T.DataFineTerapia)      
		 )
ORDER BY YEAR(T.DataInizioTerapia), MONTH(T.DataInizioTerapia) ASC;