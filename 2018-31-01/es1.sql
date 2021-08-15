/* 
 * Scrivere una query che restituisca la città dalla quale provengono più pazienti 
 * che non hanno contratto l'influenza nel periodo invernale degli ultimi tre anni.
 * In caso di pari merito, restituire result set vuoto
*/
CREATE OR REPLACE VIEW PazientiTarget AS
SELECT E.Paziente
FROM Paziente P INNER JOIN Esordio E
	 ON P.CodFiscale = E.Paziente
WHERE YEAR(E.DataEsordio) <= YEAR(CURRENT_DATE)
	  AND YEAR(E.DataEsordio) >= YEAR(CURRENT_DATE) - INTERVAL 2 YEAR
      AND E.Patologia = 'influenza'
      AND (
		  (MONTH(E.DataEsordio) <= 3
		   AND DAY(E.DataEsordio) <= 20)
	  OR  (MONTH(E.DataEsordio) = 12
		   AND DAY(E.DataEsordio) >= 21)
		  )
GROUP BY E.Paziente;

CREATE OR REPLACE VIEW CittaTarget AS
SELECT P2.Citta,
	   COUNT(*) AS NumeroPazienti
FROM Paziente P2
WHERE P2.CodFiscale NOT IN (SELECT Paziente
						    FROM PazientiTarget)
GROUP BY P2.Citta;

SELECT IF(COUNT(*) = 1, CT.Citta, "") AS Citta
FROM CittaTarget CT
WHERE CT.NumeroPazienti = (SELECT MAX(CT2.NumeroPazienti)
						   FROM CittaTarget CT2);