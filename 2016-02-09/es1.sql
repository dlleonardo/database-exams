/* 
 * Considerate le sole visite otorinolaringoiatriche, scrivere una query che restituisca il numero di pazienti, ad
 * oggi maggiorenni, che sono stati visitati solo da otorini di Firenze durante il primo trimestre del 2015.
*/
SELECT COUNT(DISTINCT V.Paziente) AS NumeroPazienti
FROM Medico M INNER JOIN Visita V
	 ON M.Matricola = V.Medico
     INNER JOIN Paziente P
     ON V.Paziente = P.CodFiscale
WHERE M.Specializzazione = 'Otorinolaringoiatria'
	  AND P.DataNascita >= CURRENT_DATE - INTERVAL 18 YEAR
      AND M.Citta = 'Firenze'
      AND YEAR(V.Data) = 2015
      AND MONTH(V.Data) BETWEEN 1 AND 3
      AND NOT EXISTS (
					 SELECT *
                     FROM Medico M2 INNER JOIN Visita V2
						  ON M2.Matricola = V2.Medico
                     WHERE M2.Specializzazione <> M.Specializzazione
						   AND M2.Citta <> M.Citta
                           AND YEAR(V2.Data) = 2015
                           AND MONTH(V2.Data) BETWEEN 1 AND 3
                           AND V2.Paziente = V.Paziente
					 );