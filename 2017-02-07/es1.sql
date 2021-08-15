/*
 * Scrivere una query che restituisca il codice fiscale dei pazienti che hanno assunto Zitromax nel 2015 solo
 * per curare patologie precedentemente già curate con successo da almeno un altro paziente della stessa città.
*/
SELECT DISTINCT T.Paziente
FROM Terapia T INNER JOIN Esordio E
	 ON T.Paziente = E.Paziente
     INNER JOIN Paziente P
     ON E.Paziente = P.CodFiscale
WHERE T.Farmaco = 'Zitromax'
	  AND YEAR(T.DataInizioTerapia) = 2015
      AND T.Paziente IN (
					  SELECT T2.Paziente
                      FROM Esordio E2 INNER JOIN Terapia T2
						   ON E2.Paziente = T2.Paziente
                           INNER JOIN Paziente P2
                           ON T2.Paziente = P2.CodFiscale
                      WHERE YEAR(T2.DataInizioTerapia) < 2015
						    AND E2.DataGuarigione IS NOT NULL
                            AND P2.Citta = P.Citta
                            AND T2.Farmaco = T.Farmaco
                            AND P2.CodFiscale <> P.CodFiscale
					  );