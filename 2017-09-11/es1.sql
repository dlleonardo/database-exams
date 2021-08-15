/*
 * Scrivere una query che consideri i farmaci a base di diazepam e lorazepam e restituisca codice fiscale e sesso 
 * dei pazienti che hanno assunto tutti i farmaci basati sul primo o, alternativamente, sul secondo principio
 * attivo durante il triennio 2010-2012, e con quale posologia media.
*/
SELECT P.CodFiscale, 
	   P.Sesso,
       AVG(T.Posologia) AS PosologiaMedia
FROM Farmaco F INNER JOIN Terapia T
	 ON F.NomeCommerciale = T.Farmaco
     INNER JOIN Paziente P
     ON T.Paziente = P.CodFiscale
WHERE F.PrincipioAttivo = 'diazepam'
	  AND YEAR(T.DataInizioTerapia) BETWEEN 2010 AND 2012
GROUP BY P.CodFiscale
HAVING COUNT(DISTINCT T.Farmaco) = (SELECT COUNT(*)
									FROM Farmaco
								    WHERE PrincipioAttivo = 'diazepam')
UNION
SELECT P.CodFiscale, 
	   P.Sesso,
       AVG(T.Posologia) AS PosologiaMedia
FROM Farmaco F INNER JOIN Terapia T
	 ON F.NomeCommerciale = T.Farmaco
     INNER JOIN Paziente P
     ON T.Paziente = P.CodFiscale
WHERE F.PrincipioAttivo = 'lorazepam'
	  AND YEAR(T.DataInizioTerapia) BETWEEN 2010 AND 2012
GROUP BY P.CodFiscale
HAVING COUNT(DISTINCT T.Farmaco) = (SELECT COUNT(*)
									FROM Farmaco
								    WHERE PrincipioAttivo = 'lorazepam');