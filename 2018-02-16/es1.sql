/* 
 * Scrivere una query che restituisca il reddito medio dei pazienti i cui esordi hanno solo terapie con posologia
 * e durata (in giorni) superiori a quelle riportate nelle indicazioni del farmaco
*/
SELECT AVG(P.Reddito) AS RedditoMedio
FROM Paziente P INNER JOIN Esordio E
	 ON P.CodFiscale = E.Paziente
     INNER JOIN Terapia T
     ON E.Paziente = T.Paziente
     INNER JOIN Indicazione I 
     ON T.Farmaco = I.Farmaco
WHERE T.Posologia > I.DoseGiornaliera
	  AND DATEDIFF(T.DataFineTerapia, T.DataInizioTerapia) > I.NumGiorni
      AND E.DataGuarigione IS NOT NULL
      AND T.DataFineTerapia IS NOT NULL
      AND NOT EXISTS (
					 SELECT *
                     FROM Esordio E2 INNER JOIN Terapia T2 
						  ON E2.Paziente = T2.Paziente
						  INNER JOIN Indicazione I2
						  ON T2.Farmaco = I2.Farmaco
                     WHERE T2.Paziente = T.Paziente 
						   AND T2.Posologia < I2.DoseGiornaliera
                           AND DATEDIFF(T2.DataFineTerapia, T2.DataInizioTerapia) < I2.NumGiorni
                           AND E2.DataGuarigione IS NOT NULL
                           AND T2.DataFineTerapia IS NOT NULL
					 );