/* 
 * Scrivere una query che indichi ogni città i cui pazienti, nel complesso, hanno incrementato di oltre il 20%
 * le visite ortopediche nel quarto trimestre 2011, rispetto allo stesso periodo dell'anno precedente.
*/
CREATE OR REPLACE VIEW VisiteOrtopediche2011 AS
SELECT P.Citta,
	   COUNT(*) AS NumeroVisite
FROM Medico M INNER JOIN Visita V
	 ON M.Matricola = V.Medico
     INNER JOIN Paziente P 
     ON V.Paziente = P.CodFiscale
WHERE M.Specializzazione = 'Ortopedia'
	  AND MONTH(V.Data) BETWEEN 10 AND 12
      AND YEAR(V.Data) = 2011
GROUP BY P.Citta;

CREATE OR REPLACE VIEW VisiteOrtopediche2010 AS
SELECT P.Citta,
	   COUNT(*) AS NumeroVisite
FROM Medico M INNER JOIN Visita V
	 ON M.Matricola = V.Medico
     INNER JOIN Paziente P 
     ON V.Paziente = P.CodFiscale
WHERE M.Specializzazione = 'Ortopedia'
	  AND MONTH(V.Data) BETWEEN 10 AND 12
      AND YEAR(V.Data) = 2010
GROUP BY P.Citta;

SELECT VO1.Citta
FROM VisiteOrtopediche2011 VO1
	 INNER JOIN
     VisiteOrtopediche2010 VO2
     ON VO1.Citta = VO2.Citta
WHERE VO1.NumeroVisite > 1.2*VO2.NumeroVisite;